#!/bin/bash
#群发统计结果下载
#作者：陈凯
#日期：2015/01/26

#常量定义
RES_LOG_DIR="/data1/fans_api_log/chenkai3";
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";

#公用模块引入
source ${SCRIPT_DIR}"/get_log_dates.sh";
source ${SCRIPT_DIR}"/error_exit.sh";


#第一步：文件列表生成
res_log_pre=`date +%Y%m%d --date "7 days ago"`"-"`date +%Y%m%d --date "1 days ago"`;

gmsg_arrs_pc_weekly=${RES_LOG_DIR}"/gmsg_attrs_stat/res_log/pc/weekly/"${res_log_pre}"_7day_gmsg_attrs_stat_pc.csv";
gmsg_type_all_weekly=${RES_LOG_DIR}"/gmsg_type_stat/res_log/all/weekly/"${res_log_pre}"_7day_gmsg_type_stat_all.csv";
gmsg_ua_weekly=${RES_LOG_DIR}"/gmsg_ua_stat/res_log/weekly/"${res_log_pre}"_7day_ua_distr.csv";
gmsg_user_top20_weekly=${RES_LOG_DIR}"/gmsg_user_topx/res_log/all/weekly/"${res_log_pre}"_gmsg_user_top20.csv";

file_list=${gmsg_arrs_pc_weekly}" "${gmsg_type_all_weekly}" "${gmsg_ua_weekly}" "${gmsg_user_top20_weekly};
#echo ${file_list};


#第二步：下载文件列表中的文件
sz ${file_list};

exit;
