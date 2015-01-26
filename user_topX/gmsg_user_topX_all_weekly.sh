#!/bin/bash
#统计过去7天群发私信类型的分布情况
#作者：陈凯
#日期：2015/01/23
#对应crontab：10 5 * * 1 gmsg_user_topX_all_weekly.sh

TOPX=20;
RES_LOG_DIR="/data1/fans_api_log/chenkai3/gmsg_user_topx/res_log/all/";
WEEKLY_LOG_DIR=${RES_LOG_DIR}"weekly/";

SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
BASE_SCRIPT=${SCRIPT_DIR}"gmsg_user_topX.sh";

#第零步：切换至工作目录
cd ${WEEKLY_LOG_DIR};


#第一步：获取起始、结束日期
begin=`date +%Y-%m-%d --date "7 days ago"`;
end=`date +%Y-%m-%d --date "1 days ago"`;

begin_date=`echo ${begin} | sed "s/-//g"`;
end_date=`echo ${end} | sed "s/-//g"`;

res_log_pre=${begin_date}"-"${end_date};


#第二步：获取该时间段内群发用户topN及次数原始数据
raw_data_log_name=${res_log_pre}"_raw.log";
cmd_get_raw_data="/bin/sh "${BASE_SCRIPT}" "${begin}" "${end}" "${topN}" > "${raw_data_log_name};
#echo ${cmd_get_raw_data};
eval ${cmd_get_raw_data};


#第三步：生成群发用户topN csv文件
uid_topX_log_name=${res_log_pre}"_gmsg_user_top"${TOPX}".csv";

#表头
th="uid,count";
echo ${th}" > "${uid_topX_log_name};

#数据行
cat ${cmd_get_raw_data} | awk -F " " '{ print $1","$2; }' >> "${uid_topX_log_name};

exit;
