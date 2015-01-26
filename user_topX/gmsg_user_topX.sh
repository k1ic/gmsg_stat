#!/bin/bash
#统计群发用户topX
#作者：陈凯
#日期：2015/01/16

#常量定义
[ ! -z $3 ] && TOPX_VALUE=$3 || TOPX_VALUE=20;
LOG_FILE_PRE="publicplatform";

LOG_DIR="/data3/logs/prof/publicplatform";
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts";

#公用模块引入
source ${SCRIPT_DIR}"/get_log_dates.sh";
source ${SCRIPT_DIR}"/error_exit.sh";


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

#字符串转为数组
dates_arr=(${res_dates//,/ });

#获取数组长度
#echo ${#dates_arr[@]};
#获取数组中某个元素
#echo ${dates_arr[0]}


#第二步：生成待cat的日志文件名
for var_d in ${dates_arr[@]};
do
    file_name=${LOG_DIR}"/"${LOG_FILE_PRE}"-"${var_d}"* ";
    log_file_names=${log_file_names}${file_name};
done;
#echo ${log_file_names};


#第三步：过滤出调用“push/message/create”接口的原始日志
res_log_pre=${dates_arr[0]//-/}"-"${dates_arr[${#dates_arr[@]}-1]//-/};

raw_log_name=${res_log_pre}"_push_msg_create_raw.log";
cmd_get_raw_data="cat "${log_file_names}" | grep push/message/create | grep FS_INFO_API | grep -v \"^$\" > "${raw_log_name};
#echo ${cmd_get_raw_data};
#eval ${cmd_get_raw_data};


#第四步：获取调用接口uid topX及次数
cmd_get_uid_topX="cat "${raw_log_name}" | awk -F \"|\" '{ print \$4 }' | sort -nr | uniq -c | sort -nr | awk -F \" \" '{ print \$2\" \"\$1 }' |  head -"${TOPX_VALUE};
#echo ${cmd_get_uid_topX};
eval ${cmd_get_uid_topX};

exit;
