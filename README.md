各脚本使用示例
1.gmsg_create_stat.sh
gmsg_create_stat.sh 2014-12-13 2014-12-26 #统计多天，支持日期月、日部分没有前导0
gmsg_create_stat.sh 2014-12-13 2014-12-13 #统计单天，支持日期月、日部分没有前导0

2.gmsg_ua_stat_daily.sh
无需参数，但依赖gmsg_create_stat.sh

3.gmsg_ua_stat_daily.sh
无需参数，但依赖gmsg_ua_stat_daily.sh的执行结果

4.gmsg_type_all_stat.sh
gmsg_type_all_stat.sh 2014-02-01 2014-02-01 #统计单天，支持日期月、日部分没有前导0
gmsg_type_all_stat.sh 2014-02-01 2014-02-08 #统计多天，支持日期月、日部分没有前导0

5.gmsg_type_pc_stat.sh
gmsg_type_pc_stat.sh 2014-02-01 2014-02-01 #统计单天，支持日期月、日部分没有前导0
gmsg_type_pc_stat.sh 2014-02-01 2014-02-08 #统计多天，支持日期月、日部分没有前导0

6.gmsg_type_h5_stat.sh
gmsg_type_h5_stat.sh 2014-02-01 2014-02-01 #统计单天，支持日期月、日部分没有前导0
gmsg_type_h5_stat.sh 2014-02-01 2014-02-08 #统计多天，支持日期月、日部分没有前导0
