#!/bin/bash
#统计过去7天群发ua分布
#作者：陈凯

RES_LOG_DIR="/data1/fans_api_log/chenkai3/gmsg_ua_stat/res_log/";

SOURCE_DATA_DIR=${RES_LOG_DIR}"daily/";
WEEKLY_LOG_DIR=${RES_LOG_DIR}"weekly/";

#第零步：切换至工作目录
#cmd_cd="cd "${WEEKLY_LOG_DIR};
##echo ${cmd_cd};
#
#if [ -d ${WEEKLY_LOG_DIR} ];
#then
#    eval ${cmd_cd};
#else
#    mkdir -m 755 -p ${WEEKLY_LOG_DIR};
#fi;


#第一步：生成过去7天的日期
function get_past_seven_dates() {
    # 变量初始化
    res_dates_str=""; #返回值
    res_dates=(); #中间变量

    for((i=7; i>=1; --i));
    do
        date=`date +%Y%m%d --date "$i days ago"`;
        res_dates=( "${res_dates[@]}" ${date} );
    done;
    
    # 遍历数组
    for var in ${res_dates[@]};
    do
        #echo $var;
        res_dates_str=${res_dates_str},$var;
    done
    
    #使用echo方式回传返回值
    echo ${res_dates_str} | sed "s/^,//g";
}

res_dates=`get_past_seven_dates`;
#echo ${res_dates};

#将字符串内的逗号替换为空格
dates=${res_dates//,/ };

#将字符串转换为数组
dates_arr=($dates);

#获取数组长度
#echo ${#dates_arr[@]};
#获取数组中某个元素
#echo ${dates_arr[0]}


#第二步：生成待读取的文件列表
function get_data_file_list() {
    #变量初始化
    res_list_str=""; #返回值
    res_list=(); #中间变量
    
    date_arr="$@";
    for date in ${date_arr};
    do
        file=${SOURCE_DATA_DIR}${date}"-"${date}"_uniq_desc_ua.log";
        res_list=( "${res_list[@]}" ${file} ); #数组追加元素
    done;

    # 遍历数组
    for var in ${res_list[@]};
    do
        #echo $var;
        res_list_str=${res_list_str},$var;
    done
    
    #使用echo方式回传返回值
    echo ${res_list_str} | sed "s/^,//g";
}

res_file_list=`get_data_file_list "${dates_arr[@]}"`;
#echo ${res_file_list};


#第三步：读取上一步生成的文件列表中的内容，并放入目标文件中

seven_day_file_name=${dates_arr[0]}"-"${dates_arr[${#dates_arr[@]}-1]}"_7day_ua_distr.csv";
res_des_file_name=${WEEKLY_LOG_DIR}${seven_day_file_name};
#echo ${res_des_file_name};

#表头
th="time_range,pc,h5,all";
echo ${th} > ${res_des_file_name};

#将字符串内的逗号替换为空格
files_str=${res_file_list//,/ };

#将字符串转换为数组
file_arr=($files_str);

#获取数组长度
#echo ${#file_arr[@]};
#获取数组中某个元素
#echo ${file_arr[0]};

for item in ${file_arr[@]};
do
    date=`echo ${item} | awk '{ split($0, S, "-"); print S[2]; }' | awk '{ split($0, P, "_"); print P[1]; }'`;

    if [ -f $item ];
    then
        total_pc=`head -1 $item | awk '{ print $1 }'`;
        total_h5=`tail -1 $item | awk '{ print $1 }'`;
    else
        total_pc=0;
        total_h5=0;
    fi;
    
    total_all=`echo ${total_pc}"+"${total_h5}|bc`;

    single_line_content=${date}","${total_pc}","${total_h5}","${total_all};
    #echo ${single_line_content};
    
    eval "echo "${single_line_content}" >> "${res_des_file_name};
done;

exit;
