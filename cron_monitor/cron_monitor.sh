#!/bin/bash
#监控当前用户的crontab，若有任务未按时执行，则自动执行
#作者：陈凯
#日期：2015/02/07

#引入公用模块
SCRIPT_DIR="/data1/fans_api_log/chenkai3/scripts/";
source ${SCRIPT_DIR}error_exit.sh
source ${SCRIPT_DIR}get_cron_list.sh


#第一步：获取当前用户的所有crontab（不含空行和注释）
cron_list=`get_cron_list`;
cron_list=${cron_list//\[br\]/ };
cron_list_arr=(${cron_list});


#第二步：判断crontab是否已按时执行，如未按时执行则执行之
for line in ${cron_list_arr[@]};
do
    cron=${line//\[sp\]/ };
    cron=(${cron});

    time_set="${cron[0]} ${cron[1]} ${cron[2]} ${cron[3]} ${cron[4]}";
    #echo ${time_set};
    
    cmd=${cron[5]};
    #echo ${cmd};
done;

exit;
