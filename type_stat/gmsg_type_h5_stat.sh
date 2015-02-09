#!/bin/bash
#从app log中统计粉服移动端群发私信类型占比情况
#作者：陈凯

#常量定义
LOG_DIR="/data3/logs/prof/publicplatform";
LOG_FILE_PRE="publicplatform";
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";

#引入公用模块
source ${SCRIPT_DIR}get_log_dates.sh

#第一步：生成起始、结束时间段内的日期
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


#第三步：生成待执行的命令
res_log_pre=${dates_arr[0]//-/}"-"${dates_arr[${#dates_arr[@]}-1]//-/};


#获取所有含"ua":"PC"或"ua":"H5"的logid
all_logids_name=${res_log_pre}"_all_logids.log"; 
cmd_get_all_logids="cat "${log_file_names}" | grep -E 'h5/aj/groupmsg/submitgmsgaudit' | grep -E '\"ua\":\"H5\"' | awk -F \"|\" '{ print \$3 }' >> "${all_logids_name};
#echo ${cmd_get_all_logids};

#获取所有含'request={"subscribe":...'的行，如：578929752858116#_#request={"subscribe":"1041","unSubscribe":"0","data":"[\u5475\u5475]\u65e9\u4e0a\u597d\uff01","type":"text","target":"dy","group_rule_id":"","order_id":"3794479570271063","publishType":"immediately","_t":"0"}
all_params_name=${res_log_pre}"_all_params.log";
cmd_get_all_params="cat "${log_file_names}" | grep -E 'h5/aj/groupmsg/submitgmsgaudit' | grep FS_INFO_APP | awk -F \"|\" 'BEGIN{OFS=\"#_#\"}{ print \$3,\$10}' >> "${all_params_name};
#echo ${cmd_get_all_params};

#从${cmd_get_all_params}中过滤出所有logid在${all_logids_name}中的记录行
all_filtered_params_name=${res_log_pre}"_all_filtered_params.log";
cmd_get_all_filtered_params="awk -F \"#_#\" 'BEGIN{OFS=\"#_#\"}ARGIND==1{S[\$1]=1} ARGIND==2{if(S[\$1]==1) print \$1,\$2}' "${all_logids_name}" "${all_params_name}" >> "${all_filtered_params_name};
#echo ${cmd_get_all_filtered_params};

#从${all_filtered_params_name}中获取私信类型原始数据
#注：grep -v \"^$\" 过滤空行
raw_msg_type_name=${res_log_pre}"_raw_msg_type.log";
cmd_get_raw_msg_type="cat "${all_filtered_params_name}" | awk -F \"\\\"type\\\"\" '{ print \$2}' | awk -F \":\" '{ print \$2}' | awk -F \",\" '{ print \$1}' | grep -v \"^$\" >> "${raw_msg_type_name};
#echo ${cmd_get_raw_msg_type};

#${raw_msg_type_name}结果集排序
sort_msg_type_name=${res_log_pre}"_sorted_msg_type.log";
cmd_sort_msg_type_data="cat "${raw_msg_type_name}" | sort -r >> "${sort_msg_type_name};
#echo ${cmd_sort_msg_type_data};

#私信类型统计
count_msg_type_name=${res_log_pre}"_uniq_sorted_msg_type.log";
cmd_uniq_msg_type_data="cat "${sort_msg_type_name}" | uniq -c >> "${count_msg_type_name};
#echo ${cmd_uniq_msg_type_data};

#输出结果
cmd_print_res="cat "${count_msg_type_name};

#执行命令
cmd_whole=${cmd_get_all_logids}" && "${cmd_get_all_params}" && "${cmd_get_all_filtered_params}" && "${cmd_get_raw_msg_type}" && "${cmd_sort_msg_type_data}" && "${cmd_uniq_msg_type_data}" && "${cmd_print_res}
#echo ${cmd_whole};

echo "总天数："${#dates_arr[@]};
eval ${cmd_whole};
exit;
