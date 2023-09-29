#!/bin/bash

source config.sh
source curl_errors.sh

# be verbose when stdout is a tty
if [ ! -t 0 ]; then
  CURL_OPTS_adm="$CURL_OPTS_adm --silent --show-error"
fi

download_adm() {
  local list_type=$1
  local output=$2
  local disable_alert=$3

  local FILE_adm0='tmp/landing_page.html'
  local FILE_adm1='tmp/elenco_siti_inibiti.txt'
  local FILE_adm2='tmp/elenco_siti_inibiti.sha-256'

if [ "x$disable_alert" != "x" ]  ; then
	NOC_EMAIL=""
fi

  curl --fail --location --remote-time $CURL_OPTS_adm \
    --output $FILE_adm0.tmp $URL_adm
  CURL_RETURN=$?
  if [ $CURL_RETURN != 0 ] ; then
        SUBJECT="Error while fetching $list_type lists"
        TXT="Curl on $(hostname -f) have returned $CURL_RETURN:\n\n${curl_errors[$CURL_RETURN]}\n\n when trying to get $URL_adm."
        if [ $ALERT_ENABLE == true ] && [ "x$NOC_EMAIL" != 'x' ] ; then
                echo -e "Subject: $SUBJECT\nFrom:$FROM_EMAIL\n$TXT" | sendmail $NOC_EMAIL
        fi
        echo "Warning: $TXT" >&2
  else
        test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Successfully downloaded file $URL_adm" >> $LOGFILE
  fi
  mv $FILE_adm0.tmp $FILE_adm0

  ELENCO=$(cat $FILE_adm0 | grep txt | grep -i Elenco | cut -d\" -f2) 
  CONTROLLO=$(cat $FILE_adm0 | grep txt | grep -i Controllo | cut -d\" -f2)
  BASE=$(echo $URL_adm | cut -d\/ -f-3)
  URL_adm1="$BASE$ELENCO"
  URL_adm2="$BASE$CONTROLLO"

  curl --fail --location --remote-time $CURL_OPTS_adm \
    --output $FILE_adm1.tmp $URL_adm1
  CURL_RETURN=$?
  if [ $CURL_RETURN != 0 ] ; then
        SUBJECT="Error while fetching Censura lists"
        TXT="Curl on $(hostname -f) have returned $CURL_RETURN:\n\n${curl_errors[$CURL_RETURN]}\n\n when trying to get $URL_adm1."
	if [ $ALERT_ENABLE == true ] && [ "x$NOC_EMAIL" != 'x' ] ; then
        	echo -e "Subject: $SUBJECT\nFrom:$FROM_EMAIL\n$TXT" | sendmail $NOC_EMAIL
	fi
	echo "Warning: $TXT" >&2
  else	
	test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Successfully downloaded file $URL_adm1" >> $LOGFILE	
  fi
  mv $FILE_adm1.tmp $FILE_adm1

  curl --fail --location --remote-time $CURL_OPTS_adm \
    --output $FILE_adm2.tmp $URL_adm2
  CURL_RETURN=$?
  if [ $CURL_RETURN != 0 ] ; then
        SUBJECT="Error while fetching Censura lists"
        TXT="Curl on $(hostname -f) have returned $CURL_RETURN:\n\n${curl_errors[$CURL_RETURN]}\n\n when trying to get $URL_adm2."
 	if [ $ALERT_ENABLE == true ] && [ "x$NOC_EMAIL" != 'x' ] ; then
        	echo -e "Subject: $SUBJECT\nFrom:$FROM_EMAIL\n$TXT" | sendmail $NOC_EMAIL
	fi
	echo "Warning: $TXT" >&2
  else
	test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Successfully downloaded file $URL_adm2" >> $LOGFILE

  fi
  mv $FILE_adm2.tmp $FILE_adm2


  if [ $SKIP_SHA256_CKSUM != true ] && ! echo "$(cat $FILE_adm2) $FILE_adm1" | sha256sum --check --status ; then
    TXT="Invalid SHA-256 checksum for $FILE_adm1!"
    SUBJECT="Error while fetching ADM lists"
    test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Invalid SHA-256 checksum for $output!" >> $LOGFILE
    echo "Invalid SHA-256 checksum for $FILE_adm1!" >&2
    if [ $ALERT_ENABLE == true ] && [ "x$NOC_EMAIL" != 'x' ] ; then 
    	echo -e "Subject: $SUBJECT\nFrom:$FROM_EMAIL\n$TXT" | sendmail $NOC_EMAIL
    fi 
    exit 1
  fi

test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Parsing Started for file $output" >> $LOGFILE

./parse_adm $list_type $FILE_adm1 $output 2>&1 | tee -a $LOGFILE
if [ $? == 0 ] ; then
	test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Parsing Ended for file $output" >> $LOGFILE
else
	test $LOGGING_ENABLE == true && echo "$(date '+%d/%m/%y %H:%M:%S') - Error while Parsing $FILE_adm1" >> $LOGFILE
fi
}

