#!/bin/bash

## 一些工具函数


function batch_test_software {
    # 批量检查软件是否存在的函数
    # 用法 batch_test_software python r fastqc 

    # 决定脚本是否终止
    exit_task=""

    while  [ $1 ] ; 
        do  
            if [ ! -x "$(command -v $1)" ]; then
                echo "[Error]: Can't find software $1, you need install it by conda."
                exit_task=true
            fi 
            shift 
        done

    # bash 脚本没有 bool 值 ，空值  "" 就是 bool 值
    if [ $exit_task ]; then
        # 中止脚本，报错
        echo end
        exit 1
    fi

}

function batch_test_folder {
    # 检测文件夹是否存在，不存在的话就创建
    # 用法 batch_test_folder qc data ./software ../reference  # 这些都可以

    while [ $1 ]; 
        do  
            if [ ! -d $1 ]; then
                mkdir -p  $1
            fi 
            shift 
        done
}

