#!/bin/bash
#统计过去7天群发私信类型的分布情况
#作者：陈凯
#日期：2015/01/05
#对应crontab：10 3 * * 1 gmsg_type_stat_all_weekly.sh

RES_LOG_DIR="/data1/fans_api_log/chenkai3/gmsg_type_stat/res_log/all/";
WEEKLY_LOG_DIR=${RES_LOG_DIR}"weekly/";

SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
BASE_SCRIPT=${SCRIPT_DIR}"gmsg_type_all_stat.sh";

#第一步：获取起始、结束日期
begin=`date +%Y-%m-%d --date "7 days ago"`;
end_=`date +%Y-%m-%d --date "1 days ago"`;

begin_date=`echo ${begin} | sed "s/-//g"`;
end_date=`echo ${end} | sed "s/-//g"`;


#第二步：获取该时间段内群发类型分布原始数据
cmd_get_raw_data="/bin/sh "${BASE_SCRIPT}" "${begin}" "${end};
#echo ${cmd_get_raw_data};
eval ${cmd_get_raw_data};

raw_data_file=${WEEKLY_LOG_DIR}${begin_date}"-"${end_date}"_uniq_sorted_msg_type.log";
#echo ${raw_data_file};


#第三步：生成最终结果
res_data_file=${WEEKLY_LOG_DIR}${begin_date}"-"${end_date}"_gmsg_type_stat_all.csv";
#echo ${res_data_file};

raw_data_str=`cat ${raw_data_file} | sed "s/\"//g" | awk -F " " '{ print $2":"$1 }'`;

raw_data_arr=( ${raw_data_str} );
#echo ${raw_data_arr[2]};

# 遍历数组
for var in ${raw_data_arr[@]};
do
    tmp=`echo $var | awk -F ":" '{ print $1" "$2 }'`;
    item=( ${tmp} );
    key=${item[0]};
    val=${item[1]};
    
    if [ "${key}" == "text" ]                          
    then                                               
        text=${val};                                   
    elif [ "${key}" == "image" ]                       
    then                                               
        image=${val};                                  
    elif [ "${key}" == "voice" ]                       
    then                                               
        voice=${val};                                  
    elif [ "${key}" == "articles" ]                    
    then                                               
        articles=${val};                               
    elif [ "${key}" == "music" ]                       
    then                                               
        music=${val};                                  
    fi;    
done;


#补全空字段
if [ "${text}" == "" ]                          
then                                               
    text=0;                                 
elif [ "${image}" == "" ]                       
then                                               
    image=0;
elif [ "${voice}" == "" ]                       
then                                               
    voice=0;
elif [ "${articles}" == "" ]                    
then                                               
    articles=0;
elif [ "${music}" == "" ]                       
then                                               
    music=0;
fi;

total=`echo ${text}"+"${image}"+"${voice}"+"${articles}"+"${music}|bc`;

#表头
th="time_range,text,image,voice,articels,music,total";
#数据行
tr=${begin_date}"-"${end_date}","${text}","${image}","${voice}","${articles}","${music}","${total};

echo -e ${th}"\n"${tr} > ${res_data_file};

exit;
