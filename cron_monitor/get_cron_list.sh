#!/bin/bash
#获取当前用户的crontab内容(不包含注释和空行)
#作者：陈凯
#日期：2015-02-10

#返回值类型：string
function get_cron_list() {
    cron_tmp=cron_`date +%Y%m%d%H%M%S`.tmp;
    crontab -l | \
        #过滤注释和空行
        grep -vE '^\#|^$' | \
        #将“*”转义，否则echo ${cron_tmp}时输出不和预期
        sed 's/*/\\\\*/g' > ${cron_tmp};
    
    while read line
    do
        #每行用"[br]"连接
        res_str=${res_str}[br]${line}; 
    done < ${cron_tmp};
    rm -fr ${cron_tmp};
    
    echo ${res_str} | \
        #删除字符串左端"[br]"
        sed "s/^\[br\]//" | \
        #将字符串中的空格替换为“[sp]”（shell中空格为数组的默认分隔符）
        sed "s/ /[sp]/g";
}
