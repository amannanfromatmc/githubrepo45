#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage:\n\n\t./deploy.sh <appname>\n"
	exit 1
fi
CF_APP_NAME=$1

if ! cf app $CF_APP_NAME; then  
  cf push $CF_APP_NAME
else
  rollback() {
    set +e	
    if cf app $OLD_CF_APP_NAME; then
      cf logs $CF_APP_NAME --recent
      cf delete $CF_APP_NAME -f
      cf rename $OLD_CF_APP_NAME $CF_APP_NAME
    fi
    exit 1
  }
  OLD_CF_APP_NAME=${CF_APP_NAME}-OLD-$(date +"%s")
  set -e
  trap rollback ERR
  cf rename $CF_APP_NAME $OLD_CF_APP_NAME
  cf push $CF_APP_NAME
  cf delete $OLD_CF_APP_NAME -f
fi

# View logs
#cf logs "${CF_APP_NAME}" --recent

