#!/bin/bash
#从app log中统计e.weibo.com调用d.e.weibo.com接口创建群发私信的情况
#作者：陈凯
#注：目前不支持跨年，支持单天

LOG_DIR="/data3/logs/prof/publicplatform";
LOG_FILE_PRE="publicplatform";

#第一步：生成起始、结束时间段内的日期
function get_log_dates() {
    # 变量初始化
    res_dates_str=""; #返回值
    res_dates=(); #中间变量
    
    # 接收入参，起始、结束日期字符串，如：2014-11-23
    s_date=$1;
    e_date=$2;
 
    # 字符串分割为数组，分割符“-”
    s_date_info=(${s_date//-/ });
    e_date_info=(${e_date//-/ });

    # 起始日期的年、月、日
    s_year=${s_date_info[0]};
    s_month=${s_date_info[1]};
    s_day=${s_date_info[2]};

    # 结束日期的年、月、日
    e_year=${e_date_info[0]};
    e_month=${e_date_info[1]};
    e_day=${e_date_info[2]};

    #echo ${s_date} ${e_date};
    #echo ${s_year} ${s_month} ${s_day};
    #echo ${e_year} ${e_month} ${e_day};

    # 生成起止日期段内的所有日期
    if [ ${s_month} -lt ${e_month} ] #waring： “[”和变量之间要有空格
    then
        #echo "<";
        for((i=${s_month}; i<=${e_month}; ++i));
        do
            # 每月最后一天
            last_day_of_month=`cal $i ${s_year} | grep -v "^$" | tail -n 1 | awk '{print $NF}'`; 
            #echo ${last_day_of_month};

            # 如果是起始月份
            if [ $i -eq ${s_month} ]
            then
                for((j=${s_day}; j<=${last_day_of_month}; ++j));
                do
                    #格式化日期，月、日增加前导0
                    date=`date -d "${s_year}-${s_month}-$j" "+%Y-%m-%d";`
                    res_dates=( "${res_dates[@]}" ${date} ); #数组追加元素
                done;

            # 如果是中间月份
            elif test $i -gt ${s_month} -a $i -lt ${e_month} 
            then
                for((j=1; j<=${last_day_of_month}; ++j));
                do
                    date=`date -d "${e_year}-$i-$j" "+%Y-%m-%d";`
                    res_dates=( "${res_dates[@]}" ${date} );
                done;

            # 如果是结束月份
            elif [ $i -eq ${e_month} ]
            then
                for((j=1; j<=${e_day}; ++j));
                do
                    date=`date -d "${e_year}-${e_month}-$j" "+%Y-%m-%d";`
                    res_dates=( "${res_dates[@]}" ${date} );
                done;
            fi
        done;
    elif [ ${s_month} -eq ${e_month} ]
    then
        #echo "=";
        for((j=${s_day}; j<=${e_day}; ++j));
        do
            date=`date -d "${s_year}-${s_month}-$j" "+%Y-%m-%d";`
            res_dates=( "${res_dates[@]}" ${date} );
        done;
    elif [ ${s_month} -gt ${e_month} ]
    then
        echo "起始、结束日期写反啦";
        exit;
    fi

    res_dates_str='';
    # 遍历数组
    for var in ${res_dates[@]};
    do
        #echo $var;
        res_dates_str=${res_dates_str},$var;
    done

    #使用echo方式回传返回值
    echo ${res_dates_str} | sed "s/^,//g";
}

#获取起始、结束时间段内的所有日期（逗号分隔的字符串）
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

raw_log_name=${res_log_pre}".log";
cmd_cat_raw="cat "${log_file_names}" | grep push/message/create >> "${raw_log_name};
#echo ${cmd_cat_raw}

ua_log_name=${res_log_pre}"_ua.log";
cmd_get_ua="cat "${raw_log_name}" | awk -F '\"ua\":' '{print \$2}' | awk -F \"}\" '{print \$1}' >> "${ua_log_name};
#echo ${cmd_get_ua};

sort_ua_log_name=${res_log_pre}"_desc_ua.log";
cmd_desc_ua="sort -rn "${ua_log_name}" >> "${sort_ua_log_name};
#echo ${cmd_desc_ua};

uniq_sort_log_name=${res_log_pre}"_uniq_desc_ua.log";
cmd_uniq_desc="uniq -c "${sort_ua_log_name}" >> "${uniq_sort_log_name};
#echo ${cmd_uniq_desc};

cmd_whole=${cmd_cat_raw}" && "${cmd_get_ua}" && "${cmd_desc_ua}" && "${cmd_uniq_desc}" && cat "${uniq_sort_log_name};
#echo ${cmd_whole};

echo "总天数："${#dates_arr[@]};
eval ${cmd_whole};
exit;
