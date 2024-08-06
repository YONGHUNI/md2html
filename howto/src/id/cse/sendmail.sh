#!/bin/bash
set -euo pipefail

RECEIVER=$1
SUBJECT=$2

# 아래 값은 실행하는 사람들이 알아서 고쳐쓰시오
SENDER=jangho@bacchus.snucse.org
SMTP_SERVER=smtp.jangho.io:587
SMTP_USER=jangho@mango.jangho.io
SMTP_PASSWORD=$(pass system/hosts/mango/smtp.jangho.io/jangho@mango.jangho.io)
# 끝

mailx -v -r "${SENDER}" -s "${SUBJECT}" -S "smtp=${SMTP_SERVER}" -S smtp-use-starttls -S smtp-auth=login \
	-S "smtp-auth-user=${SMTP_USER}" -S smtp-auth-password="${SMTP_PASSWORD}" "${RECEIVER}"
