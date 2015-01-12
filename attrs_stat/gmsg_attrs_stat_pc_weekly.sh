#!/bin/bash
#统计过去7天群发私信属性筛选使用率
#作者：陈凯
#日期：2015/01/11
#对应crontab：10 4 * * 1 gmsg_attrs_stat_pc_weekly.sh

RES_LOG_DIR="/data1/fans_api_log/chenkai3/gmsg_attrs_stat/res_log/pc/";
WEEKLY_LOG_DIR=${RES_LOG_DIR}"weekly/";

SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
BASE_SCRIPT=${SCRIPT_DIR}"gmsg_attrs_stat_pc.sh";

#第零步：切换至工作目录
cd ${WEEKLY_LOG_DIR}; #TODO:增加异常处理


#第一步：获取起始、结束日期
begin=`date +%Y-%m-%d --date "7 days ago"`;
end=`date +%Y-%m-%d --date "1 days ago"`;

begin_date=`echo ${begin} | sed "s/-//g"`;
end_date=`echo ${end} | sed "s/-//g"`;


#第二步：获取该时间段内群发属性筛选使用率数据
cmd_get_usage_data="/bin/sh "${BASE_SCRIPT}" "${begin}" "${end};
#echo ${cmd_get_usage_data};
res_data=`eval ${cmd_get_usage_data}`;
#echo ${res_data};


#第三步：最终结果写入文件
res_data_file=${WEEKLY_LOG_DIR}${begin_date}"-"${end_date}"_7day_gmsg_attrs_stat_pc.csv";

#表头
th="time_range,group_usage,gender_usage,area_usage";

#数据行
tr=${res_data};
echo -e ${th}"\n"${tr} > ${res_data_file};
exit;
