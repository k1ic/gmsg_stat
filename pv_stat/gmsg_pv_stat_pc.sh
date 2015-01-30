#!/bin/bash
#统计PC端群发PV
#作者：陈凯
#日期：2015/01/29

#引入公用模块
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
source ${SCRIPT_DIR}get_log_dates.sh
source ${SCRIPT_DIR}error_exit.sh

LOG_DIR="/data3/logs/prof/publicplatform";
LOG_FILE_PRE="publicplatform";


#第一步：获取起始、结束时间段内的所有日期（逗号分隔的字符串）
if [ ! -z $1 ]&&[ ! -z $2 ]
then
    res_dates=`get_log_dates $1 $2;`
elif [ ! -z $1 ]&&[ -z $2 ]
then
    res_dates=`date -d $1 "+%Y-%m-%d"`;
else
    echo "请输入日期";
    exit;
fi
#echo ${res_dates};

#将字符串内的逗号替换为空格
dates=${res_dates//,/ };

#将字符串转换为数组
dates_arr=($dates);

#获取数组长度
#echo ${#dates_arr[@]};
#获取数组中某个元素
#echo ${dates_arr[0]}


#第二步：生成需要cat的所有日志文件名（如：publicplatform-2014-12-02* publicplatform-2014-12-03*）
log_file_names='';
for var_d in ${dates_arr[@]};
do
    file_name=${LOG_DIR}"/"${LOG_FILE_PRE}"-"${var_d}"* ";
    log_file_names=${log_file_names}${file_name};
done;
#echo ${log_file_names};


#第三步：输出原始结果
cmd_cat="cat "${log_file_names}" | grep v1/public/groupmsg/main | grep FS_INFO_APP";
#echo ${cmd_cat};
eval ${cmd_cat};

exit;
