#!/bin/bash
#按天统计PC端群发PV（只统计PC端新建群发页）
#作者：陈凯
#日期：2015/01/29

#常量定义及公用模块引入
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
source ${SCRIPT_DIR}get_log_dates.sh
source ${SCRIPT_DIR}error_exit.sh

LOG_DIR="/data3/logs/prof/publicplatform";

RES_LOG_DIR="/data1/fans_api_log/chenkai3/gmsg_pv_stat/res_log/pc/";
DAILY_LOG_DIR=${RES_LOG_DIR}"daily/";

SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
SCRIPT_NAME="gmsg_pv_stat_pc.sh";

script_sh=${SCRIPT_DIR}${SCRIPT_NAME};

yesterday_date=`date -d last-day +%Y-%m-%d`;
#echo ${yesterday_date};
yesterday=`echo ${yesterday_date} | sed "s/-//g"`;


#第零步：切换至工作目录
cmd_cd="cd "${DAILY_LOG_DIR};
#echo ${cmd_cd};
if [ ! -d ${DAILY_LOG_DIR} ]
then
    mkdir -m 755 -p ${DAILY_LOG_DIR} || error_exit "创建工作目录失败";
fi;
eval ${cmd_cd};


#第一步：获取每日访问原始数据
raw_log_name=${yesterday}"-"${yesterday}"_raw.log";
cmd_get_raw_log="/bin/sh "${script_sh}" "${yesterday_date}" > "${raw_log_name};
#echo ${cmd_get_raw_log};
eval ${cmd_get_raw_log};


#第二步：计算每日PV
total_pv=`cat ${raw_log_name} | wc -l`;


#第三步：生成csv文件
res_data_file=${yesterday}"-"${yesterday}"_pc_pv_daily.csv";

#表头
th="date,total";

#数据行
tr=${yesterday}","${total_pv};

#写入数据
echo -e ${th}"\n"${tr} > ${res_data_file};
exit;
