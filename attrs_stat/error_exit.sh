#!/bin/bash
#通用异常处理模块
#作者：陈凯
#日期：2015-01-13

function error_exit() {
    echo "$1" 1>&2;
    exit 1;
}
