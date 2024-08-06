#!/bin/bash
set -euo pipefail
shopt -s expand_aliases

# id.snucse.rog DB에서 '대학원생' 그룹의 인덱스
CSE_GROUP_IDX=136

RANDOM_PASSWORD=$(pwgen 20 1)

#
# Prepare SSH connection
#
ssh_connect() {
	local -r socket_name=$1
	local -r remote_username=$2
	local -r remote_hostname=$3
	local -r remote_port=$4
	if [[ -e "${socket_name}" ]]; then
		return
	fi
	ssh -o ControlMaster=yes -o "ControlPath=${socket_name}" -o ServerAliveInterval=30 -f -N "-l${remote_username}" "-p${remote_port}" "${remote_hostname}"

}

echo '이 스크립트 실행을 위해 Bacchus waiter 이용을 위한 KUBECONFIG 설정이 필요합니다.'
echo 'ssh 연결을 테스트합니다. 패스워드를 묻는 창이 발생할 수 있습니다.'
echo '학외에서 스크립트를 실행중이라면, TCP 커넥션 드랍 현상으로 인해 스크립트를 다시 실행해야 하는 상황이 발생할 수 있습니다.'
echo '자세한 정보: https://github.com/bacchus-snu/work/issues/745'
ssh_connect control-path-cse bacchus cse.snu.ac.kr 22
alias sshcse='ssh -o ControlMaster=no -o ControlPath=control-path-cse -lbacchus -p22 cse.snu.ac.kr'

sshcse hostname

echo -e 'ssh 커넥션 테스트 완료\n'

#
# Get Input from the Administrator
#

# "Your registered ID in https://id.snucse.org system."
ID_USERNAME=$1

# 문의를 보낼 때 사용한 이메일 주소 그대로
EMAIL_ADDRESS=$2

#
# Check eligibility
#

send_email() {
	local -r audience=$1
	local -r content=$2
	local receiver=${EMAIL_ADDRESS}
	local subject_prefix=''
	if [[ "${audience}" = bacchus ]]; then
		receiver=contact@bacchus.snucse.org
		subject_prefix="[cse-account-script][${EMAIL_ADDRESS}] "
	fi
	echo "안녕하세요, 항상 여러분과 함께하는 관리자모임 바쿠스입니다.
컴퓨터공학부 홈페이지 https://cse.snu.ac.kr/ 계정 요청의 처리 결과를 알려드립니다.

${content}

이 이메일은 발신 전용으로, 문의사항이 있으시면 답장을 하지 마시고 contact@bacchus.snucse.org 로 새로운 메일을 작성해주세요.

감사합니다.
바쿠스 드림" | ./sendmail.sh "${receiver}" "${subject_prefix}컴퓨터공학부 홈페이지 계정 안내"
}

deny() {
	local -r message=$1
	echo '판정 결과: 거절'
	echo "사유: ${message}"
	echo ''
	read -r -n1 -p '거절 사유를 이메일로 보낼까요? [Y/N] ' proceed_yn
	echo ''
	if [[ "${proceed_yn}" != 'Y' && "${proceed_yn}" != 'y' ]]; then
		echo '이메일 보내지 않음'
	else
		send_email user "계정 발급이 거절되었습니다. 사유: ${message}"
		send_email bacchus "계정 발급이 거절되었습니다. 사유: ${message}"
	fi
	exit 0
}

if [[ "$(echo "${EMAIL_ADDRESS}" | cut '-d@' -f2)" != 'snu.ac.kr' ]]; then
	deny "문의를 보내실 때는 @snu.ac.kr 메일주소를 통하여 보내시기 바랍니다."
fi
SNUMAIL_USERNAME=$(echo "${EMAIL_ADDRESS}" | cut '-d@' -f1)

PG_PASSWORD_ENV="PGPASSWORD=$(kubectl -n id get secret/id-db-creds -ojsonpath='{.data.password}' | base64 -d)"

psql_exists() {
	local -r expected=$' exists \n--------\n t\n(1 row)'
	local -r query=$1
	local result
	result=$(kubectl -n id exec sts/id-postgresql -- env "${PG_PASSWORD_ENV}" psql -U id -c "SELECT EXISTS(${query})")
	[[ "${result}" = "${expected}" ]]
}

if ! psql_exists "SELECT idx FROM users WHERE username='${ID_USERNAME}'"; then
	deny "통합계정(계정명: ${ID_USERNAME})은 존재하지 않습니다. https://id.snucse.org/ 에서 회원가입 및 대학원생 그룹 가입을 먼저 완료해주세요."
fi

HAS_DRUPAL_ACCOUNT=0
HAS_SNUCSE2_OAUTH=0
mysql_exists() {
	local -r expected=$'e\n1'
	local -r query=$1
	result=$(sshcse sudo mysql drupal -e "\"SELECT EXISTS(${query}) AS e\"")
	[[ "${result}" = "${expected}" ]]
}
if mysql_exists "SELECT name FROM users WHERE name='${ID_USERNAME}'"; then
	# 이미 cse.snu.ac.kr 에 계정이 있다
	HAS_DRUPAL_ACCOUNT=1
fi
if mysql_exists "SELECT openid FROM users, oauth_snucse_map WHERE users.uid=oauth_snucse_map.uid AND users.name='${ID_USERNAME}'"; then
	# 이미 cse.snu.ac.kr 에 계정이 있으면서, 구 스누씨(SNUCSE 2.0)와 연결되어 있다
	# 이는 구 스누씨로부터 마이그레이션된 계정이 id.snucse.org 에 있을 것임을 암시한다
	# 구 스누씨는 "@snu.ac.kr" 메일을 쓰도록 강제하지 않았기 때문에, 구 스누씨에서 마이그레이션되어 id.snucse.org 에 존재하는 계정은
	# "@snu.ac.kr" 이메일 주소를 가지지 않을 수도 있다.
	HAS_SNUCSE2_OAUTH=1
fi

# 이메일 검사는 SNUCSE 2.0 과 연결된 계정이 아닐 때만 진행한다
if [[ "${HAS_SNUCSE2_OAUTH}" -eq 0 ]]; then
	if ! psql_exists "SELECT owner_idx FROM users, email_addresses WHERE users.idx=email_addresses.owner_idx AND address_domain='snu.ac.kr' and address_local='${SNUMAIL_USERNAME}' and username='${ID_USERNAME}'"; then
		deny "통합계정(계정명 ${ID_USERNAME}) 에 등록된 이메일 주소 중 귀하가 요청 메일을 보내실 때 사용된 주소(${EMAIL_ADDRESS})가 없습니다."
	fi
fi

if ! psql_exists "SELECT username, group_idx FROM users, user_memberships WHERE users.idx=user_memberships.user_idx AND user_memberships.group_idx=${CSE_GROUP_IDX} AND username='${ID_USERNAME}'"; then
	deny "통합계정(계정명: ${ID_USERNAME})이 컴퓨터공학부 대학원생으로 확인되지 않았습니다. https://id.snucse.org/group 에서 대학원생 그룹에 가입을 신청했는지 확인해주세요. 신청 승인은 컴퓨터공학부 행정실에서 진행하며, 바쿠스는 이 과정에 관여할 수 없습니다. 신청 후에도 오래도록 승인이 이루어지지 않으면 행정실에 문의하세요.

대학원생 그룹에 가입이 승인된 사실을 확인하시고 나서, 다시 contact@bacchus.snucse.org 로 문의를 주세요."
fi

echo '판정 결과: 승인'
if [[ "${HAS_DRUPAL_ACCOUNT}" -eq 0 ]]; then
	echo '신규 cse.snu.ac.kr 계정을 발급합니다.'
else
	echo '기존 cse.snu.ac.kr 계정의 패스워드를 리셋합니다.'
	if [[ "${HAS_SNUCSE2_OAUTH}" -eq 0 ]]; then
		echo '(old.snucse.org 와 연동되어 있지 않은 계정입니다. id.snucse.org 에 등록된 @snu.ac.kr 메일주소와 주어진 메일주소가 일치함을 확인했습니다.)'
	else
		echo '(또한 old.snucse.org 와의 연동을 해제합니다. @snu.ac.kr 메일 주소 일치 여부는 검사하지 않았습니다.)'
	fi
fi

echo ''
read -r -n1 -p '이대로 진행합니까? [Y/N] ' proceed_yn
echo ''
if [[ "${proceed_yn}" != 'Y' && "${proceed_yn}" != 'y' ]]; then
	echo '중단'
	exit 1
fi

#
# Execute
#

get_drupal_uid() {
	local -r username=$1
	sshcse sudo mysql drupal -e "\"SELECT uid FROM users WHERE name='${username}'\"" | tail -n1
}

drush() {
	local -r command=$1
	sshcse "cd /srv/cse/drupal && drush ${command}"
}

DRUPAL_UID=null
if [[ "${HAS_DRUPAL_ACCOUNT}" -eq 1 ]]; then
	DRUPAL_UID=$(get_drupal_uid "${ID_USERNAME}")
	drush "user-information ${DRUPAL_UID}"
	echo "기존 계정의 Drupal UID는 ${DRUPAL_UID} 입니다."
fi

if [[ "${HAS_SNUCSE2_OAUTH}" -eq 1 ]]; then
	echo "drupal(mysql): uid ${DRUPAL_UID} 에 대해 old.snucse.org 연동 해제..."
	sshcse sudo mysql drupal -e "\"DELETE FROM oauth_snucse_map WHERE uid='${DRUPAL_UID}'\""
	echo 'drupal(mysql): 연동 해제 완료'
fi

echo "랜덤 패스워드는 ${RANDOM_PASSWORD}"
if [[ "${HAS_DRUPAL_ACCOUNT}" -eq 1 ]]; then
	echo "drupal(drush): uid ${DRUPAL_UID} 패스워드를 리셋합니다..."
	drush "user-password ${DRUPAL_UID} --password=${RANDOM_PASSWORD}"
	echo 'drupal(drush): 패스워드 리셋 완료'
else
	echo 'drupal(drush): 신규 계정을 생성합니다...'
	drush "user-create ${ID_USERNAME} --mail=${EMAIL_ADDRESS} --password=${RANDOM_PASSWORD}"
	drush "user-add-role Student --mail=${EMAIL_ADDRESS}"
	DRUPAL_UID=$(get_drupal_uid "${ID_USERNAME}")
	echo "신규 계정의 Drupal UID는 ${DRUPAL_UID} 입니다."
fi

#
# Report
#

report_success() {
	local -r before_password=$1
	local -r after_password=$2
	send_email user "${before_password}
- Password: ${RANDOM_PASSWORD}
${after_password}"
	send_email bacchus "${before_password}
- Password: [- SNIP -]
${after_password}"
}

if [[ "${HAS_DRUPAL_ACCOUNT}" -eq 0 ]]; then
	report_success "신규 계정이 발급되었습니다. https://cse.snu.ac.kr/user 에서 아래 정보로 로그인하실 수 있습니다.

- ID: ${ID_USERNAME}" "
로그인하신 후 https://cse.snu.ac.kr/user/${DRUPAL_UID}/edit 에서 본인의 성함과 시간대를 설정하고, 패스워드는 꼭 변경해주세요."
	echo '메일 발송 완료'
	exit 0
fi

if [[ "${HAS_SNUCSE2_OAUTH}" -eq 1 ]]; then
	report_success "기존에 사용하시던 학부홈페이지 계정을 사용하실 수 있도록 조치했습니다 (SNUCSE 2.0 시스템과의 연동을 해제했습니다).
https://cse.snu.ac.kr/user 에서 아래 정보로 로그인하실 수 있습니다.

- ID: ${ID_USERNAME}" "
로그인하신 후 https://cse.snu.ac.kr/user/${DRUPAL_UID}/edit 에서 패스워드를 꼭 변경해주세요."
	echo '메일 발송 완료'
	exit 0
fi

if [[ "${HAS_SNUCSE2_OAUTH}" -eq 0 ]]; then
	report_success "기존에 사용하시던 학부홈페이지 계정의 패스워드를 초기화했습니다.
https://cse.snu.ac.kr/user 에서 아래 정보로 로그인하실 수 있습니다.

- ID: ${ID_USERNAME}" "
로그인하신 후 https://cse.snu.ac.kr/user/${DRUPAL_UID}/edit 에서 패스워드를 꼭 변경해주세요."
	echo '메일 발송 완료'
	exit 0
fi
