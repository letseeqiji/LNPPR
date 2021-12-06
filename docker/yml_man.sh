# Copyright (C) 2020 - 2021 LetSeeQiJi <wowiwo@yeah.net>
#
# This file is part of the LNPPR script.
#
# LNPPR is a powerful bash script for the installation of
# Nodejs + Nginx + Rails + MySQL/PostgreSQL + Redis and so on.
# You can install Nginx + Rails + MySQL/Postgresql in an very easy way.
# Just need to edit the install.conf file to choose what you want to install before installation.
# And all things will be done in a few minutes.
#
# Website:  https://bossesin.cn
# Github:   https://github.com/letseeqiji/LNPPR
# 一行行读文件
Yml_Read_File_In_Style_By_Line()
{
    local File=$1

    if Check_File_Exist "${File}" 'not_null' ;then
        Old_IFS=${IFS}
        IFS=$'\n'
        for line in $(cat ${File})
        do
            echo $line
        done
        IFS=${Old_IFS}
    fi
}
# 获取第一行
Get_First_Line()
{
    local Exp=$1
    local File=$2
    sed '/'$Exp'/p' $File | head -1
}
# 获取最后一行
Get_Last_Line()
{
    local Exp=$1
    local File=$2
    sed '/'$Exp'/p' $File | tail -1
}
# 获取以n个空格开头的行
Get_Lines_Start_With_Sapce()
{
    local File=$1
    local Number=$2
    grep -E '^[[:space:]]{'${Number}'}[^ /\n]+' ${File}
}
# 获取 这个没有问题  饰演过了
Get_Space_Count_Before_Word()
{
    local Word=$1
    local Spaces=$(echo "${Word}" | sed -r 's/^([[:space:]]*)[^[[:space:]]]*/\1/')
    echo ${#Spaces}
}
Yml_get_Section()
{
    File=$1
    Sec_Name=$2
    Full_Sec_Name=grep "${Sec_Name}" $File 

    Spaces=$(Get_Space_Count_Before_Word ${Full_Sec_Name})
    sed -n -r '/'${Sec_Name}'/,/^[[:space:]]{'$Spaces'}[^ /\n]+/p' ./docker-compose.yml
}
Yml_Del_Section_And_Children()
{
    local File=$1
    local Section=$2
    # sed -n '0,/redis/{/redis/p}' docker-compose2.yml
    Redis_Line=$(sed -n '0,/'${Section}'/{/'{Section}'/p}' ${File})
    Spaces_Cnt=$(Get_Space_Count_Before_Word "${Redis_Line}")

    # 找到第一个空格小于等于redis的行
    Lines_To_Next=$(sed -n -r '/'${Section}'/,/^ {0,'${Spaces_Cnt}'}[^ /\n]+/p' ${File} | wc -l)
    Lines_To_End=$(sed -n -r '/'${Section}'/,$p' ${File} | wc -l)
    # 如果redis到最后的行数和第一个行数相当 则判断是最后一行
    if [ $Lines_To_Next = $Lines_To_End ];then
        echo "${Section} is the last section"
        sed -r -i '/'${Section}'/,$d' ${File}
    else
        let Lines_To_Next-=2
        sed -r -i '/'${Section}'/,+'${Lines_To_Next}'d' ${File}
    fi
}
