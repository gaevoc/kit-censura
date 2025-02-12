#!/bin/bash
#
# Kit Configuration File
##############################

# Lists to be processed
# Currently available options are: manuale aams tabacchi agcom cncpo consob
LISTS="manuale giochi tabacchi agcom cncpo"

# Local work directories
LISTS_DIR='./lists'
TMP_DIR='./tmp'

# CNCPO URL
URL_cncpo='https://212.14.145.50/'

# Local File for CNCPO
FILE_cncpo="$TMP_DIR/blacklist.csv"

# Local File for AGCOM
# To be manyally updated from https://www.agcom.it/provvedimenti-a-tutela-del-diritto-d-autore
FILE_agcom='lista.agcom'

# Skip SHA256 Checks 
SKIP_SHA256_CKSUM=false

# Local file for Consob list
# To be manully updated from https://www.consob.it/web/area-pubblica/oscuramenti
# -- Not mandatory until explicit request from Consob --
FILE_consob='lista.consob'

# Local file for Manuale
FILE_manuale='lista.manuale'

# curl options
CERTS_cncpo='--cert cncpo.pem --key cncpo.key --cacert cncpo-ca.pem'

# curl options for cncpo
CURL_OPTS_cncpo="--http1.1 $CERTS_cncpo"

# curl options for ADM (giochi and tabacchi)
CURL_OPTS_adm=''

# path of the file on each remote target DNS server
CONFFILE='/etc/named/censura/named.conf'

# list of target DNS servers
SERVERS='root@172.16.91.154'

# do not waste too much time trying to connect to unresponsive remote servers
RSYNC_OPTIONS='--timeout=30 -rt'

# the local file
CONF="$LISTS_DIR/named.conf"

# the directory on the name servers containing the zone files
CONFDIR='/etc/named/censura'

############ Blackholing

# Lists to be applied for blackholing
ROUTES_LISTS='cncpo'

# Blackhole Nexthop
BLACKHOLE_NEXTHOP='192.168.254.254'


############ Logging

# Set true to enable logging to file
LOGGING_ENABLE=true

# Logfile path
LOG_DIR='./log'
LOGFILE="$LOG_DIR/kit-censura.log"


########### Alerting 

# Set true to enable alerting 
ALERT_ENABLE=true
# insert NOC email to enable alerting
NOC_EMAIL=''
# sender address
FROM_EMAIL='cncpo@optimaitalia.com'
