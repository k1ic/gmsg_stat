#!/bin/bash
#生成给定起、止日期内的所有日期(不支持跨年)
#作者：陈凯
#日期：2015-01-08

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
