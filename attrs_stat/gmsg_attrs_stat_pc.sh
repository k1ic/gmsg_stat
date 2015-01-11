#!/bin/bash
#统计指定起、止日期内PC端群发私信属性筛选的分布情况
#作者：陈凯
#日期：2015/01/08

#引入公用模块
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
source ${SCRIPT_DIR}get_log_dates.sh


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


#第三步：获取属性筛选原始数据
res_log_pre=${dates_arr[0]//-/}"-"${dates_arr[${#dates_arr[@]}-1]//-/};

raw_log_name=${res_log_pre}"_pc_raw.log";
cmd_get_raw_data="cat "${log_file_names}" | grep groupmsg/confirm | grep FS_INFO_APP | awk -F '|' '{ print \$4\"#_#\"\$10; }' | grep -v \"^$\" > "${raw_log_name};
#echo ${cmd_get_raw_data};
eval ${cmd_get_raw_data};


#第四步：获取分组、性别、地区原始数据

#获取分组信息（自定义分组、规则名分组）
raw_group_name=${res_log_pre}"_pc_group_raw.log";
cmd_get_raw_group_data="cat "${raw_log_name}" | awk -F '#_#' '{ print \$2 }' | awk -F '\"group_rule_id\":' '{ print \$2 }' | awk -F ',' '{ print \$1 }' > "${raw_group_name};
#echo ${cmd_get_raw_group_data};
eval ${cmd_get_raw_group_data};

#获取性别信息
raw_gender_name=${res_log_pre}"_pc_gender_raw.log";
cmd_get_raw_gender_data="cat "${raw_log_name}" | awk -F '#_#' '{ print \$2 }' | awk -F '\"gender\":' '{ print \$2 }' | awk -F ',' '{ print \$1 }' > "${raw_gender_name};
#echo ${cmd_get_raw_gender_data};
eval ${cmd_get_raw_gender_data};

#获取地区信息
raw_area_name=${res_log_pre}"_pc_area_raw.log";
cmd_get_raw_area_data="cat "${raw_log_name}" | awk -F '#_#' '{ print \$2 }' | awk -F '\"area\":' '{ print \$2 }' | awk -F ',' '{ print \$1 }' > "${raw_area_name};
#echo ${cmd_get_raw_area_data};
eval ${cmd_get_raw_area_data};


#第五步：计算分组、性别、地区使用率

function usage_rate_calculate() {
    total=`cat $1 | awk '{ sum += $2 }; END { print sum }'`;
    #echo ${total};
    
    not_use=`cat $1 | awk '{ if($1 == "\"\"") { print $2 } }'`;
    #echo ${not_use};
    use=`expr ${total} - ${not_use}`;
    #echo ${use};
    
    echo "scale=4; ${use}/${total}" | bc | awk '{ printf("%.3f", $1) }' | awk '{ printf("%s", $1*100"%") }'
}

#分组
ripe_group_name=${res_log_pre}"_pc_group_ripe.log";
cmd_get_ripe_group_data="cat "${raw_group_name}" | sort -rn | uniq -c | awk '{ print \$2\" \"\$1 }' > "${ripe_group_name};
#echo ${cmd_get_ripe_group_data};
eval ${cmd_get_ripe_group_data};
group_usage_rate=`usage_rate_calculate ${ripe_group_name}`;
#echo ${group_usage_rate};

#性别
ripe_gender_name=${res_log_pre}"_pc_gender_ripe.log";
cmd_get_ripe_gender_data="cat "${raw_gender_name}" | sort -rn | uniq -c | awk '{ print \$2\" \"\$1 }' > "${ripe_gender_name};
#echo ${cmd_get_ripe_gender_data};
eval ${cmd_get_ripe_gender_data};
gender_usage_rate=`usage_rate_calculate ${ripe_gender_name}`;
#echo ${gender_usage_rate};

#地区
ripe_area_name=${res_log_pre}"_pc_area_ripe.log";
cmd_get_ripe_area_data="cat "${raw_area_name}" | sort -rn | uniq -c | awk '{ print \$2\" \"\$1 }' > "${ripe_area_name};
#echo ${cmd_get_ripe_area_data};
eval ${cmd_get_ripe_area_data};
area_usage_rate=`usage_rate_calculate ${ripe_area_name}`;
#echo ${area_usage_rate};


#第六步：输出统计结果
#表头
#th="time_range,group_usage,gender_usage,area_usage";

#数据行
begin_date=`echo ${dates_arr[0]} | sed "s/-//g"`;
end_date=`echo ${dates_arr[${#dates_arr[@]}-1]} | sed "s/-//g"`;
tr=${begin_date}"-"${end_date}","${group_usage_rate}","${gender_usage_rate}","${area_usage_rate};

echo ${tr};
exit;
