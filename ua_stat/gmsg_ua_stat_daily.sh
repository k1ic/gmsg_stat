#!/bin/bash
#统计昨天群发私信ua分布
#作者：陈凯

RES_LOG_DIR="/data1/fans_api_log/chenkai3/gmsg_ua_stat/res_log/";
DAILY_LOG_DIR=${RES_LOG_DIR}"daily/";

SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
SCRIPT_NAME="gmsg_create_stat.sh";

script_sh=${SCRIPT_DIR}${SCRIPT_NAME};

yesterday_date=`date -d last-day +%Y-%m-%d`;
#echo ${yesterday_date};

cmd_cd="cd "${DAILY_LOG_DIR};
#echo ${cmd_cd};

cmd_sh="/bin/sh "${script_sh}" "${yesterday_date};
#echo ${cmd_sh};

cmd_all=${cmd_cd}" && "${cmd_sh};
#echo ${cmd_all};

eval ${cmd_all};
exit;
