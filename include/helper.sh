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
# os ----------------------------------------------------
Check_Equal()
{
    [ "$1" = "$2" ]
}
Check_Not_Equal()
{
    [ ! "$1" = "$2" ]
}
Check_null()
{
    [ -z $1 ]
}
Check_Not_null()
{
    [ -n $1 ]
}
Check_Empty()
{
    Check_Equal $1 ''
}
Check_Up()
{
    Check_Equal "$?" "0"
}
Check_Up_OK()
{
    if ! Check_Up;then
        echo "${lang_fail}"
        return 1
    else
        echo "${lang_success}"
    fi
}
Check_Command()
{
    local C_Command=$1
    command -v $C_Command --version > /dev/null 2>&1
}
Check_Command_Version()
{
    local C_Command=$1
    $C_Command --version
}
# 不使用 Check_Command_Running  因为程序运行不一定会提供对应命令  程序 !== 命令
Check_App_Running()
{
    local App=$1
    local PsCnt=`ps -ef | grep $App | grep -v grep | grep -c -v $0`
    Check_Equal $PsCnt 0 && echo "${App} has stopped" || echo "${App} is running"
}
Check_Interface_Used()
{
    local Interface=$1
    Check_Command lsof && lsof -i :"${Interface}"
}
Check_User_Exist()
{
    local User=$1
    id -u $User > /dev/null 
}
Check_Group_Exist()
{
    local Group=$1
    grep -q -E "^${Group}" /etc/group
}
Check_Dir_Exist()
{
    local DirUrl=$1
    [[ -d $DirUrl ]]
}
Check_File_Exist()
{
    local FileUrl=$1
    local Can_Null="y"
    Check_null $2 || Can_Null="n"
    Check_Equal $Can_Null "y" && [ -f "${FileUrl}" ] || [ -s "${FileUrl}" ]
}
Check_Dir_Not_Empty()
{
    local DirUrl=$1
    [ "$(ls -A $DirUrl)" ]
}
Date_Time()
{
    Date_Now=$(date +"%Y%m%d%H%M%S")
}
Export_Path()
{
    local Pathinfo=$1
    local FileName=$2

    cat $Pathinfo>> $FileName
    source $FileName
}
Edit_Profile()
{
	local Edit=$1

    for Profile in `find /home -name ".profile"`
    do
        $Edit $Profile
        source $Profile
    done
}
Edit_Shrc()
{
    # 
	local Edit=$1

    for Shrc in `find /home -name ".*shrc"`
    do
        $Edit $Shrc
        source $Shrc
    done
}
# file-------------------------------------------------------
Chown_Dir()
{
    local Owner=$1
    local DirUrl=$2
    local User=`echo $Owner | awk -F ":" '{print $1}'`
    local Group=`echo $Owner | awk -F ":" '{print $2}'`

    Check_Dir_Exist $DirUrl && Check_User_Exist $User && Check_Group_Exist $Group
    Check_Up && chown -R $Owner $DirUrl
}
Change_Mod()
{
    local DirUrl=$1
    local Permission="755"
    Check_null "$2" || Permission=$2
    chmod $Permission -Rf "$DirUrl"
}
Make_Dir()
{
	local DirUrl=$1
    Check_Dir_Exist "${DirUrl}" || Check_Command "sudo" && sudo mkdir -p "${DirUrl}" || mkdir -p "${DirUrl}"
}
Rm_Dir()
{
	local DirUrl=$1
    Check_Dir_Exist "${DirUrl}" && rm -Rf "${DirUrl}"
}
Rm_File()
{
    local FileUrl=$1
    Check_File_Exist "${FileUrl}" && rm -f "${FileUrl}"
}
Copy_File()
{
    local UrlFrom=$1
    local UrlTo=$2
    Check_File_Exist $UrlFrom && \cp -a ${UrlFrom} ${UrlTo}
}
Back_Up_File()
{
    local FileUrl=$1
    local Back_Dir="."
    [ -z $2 ] || Back_Dir=$2
    Date_Time
    Check_File_Exist $FileUrl && mv ${FileUrl} ${Back_Dir}/${FileUrl}.bak.${Date_Now}
}
Download_Files()
{
    local URL=$1
    local FileName=$2
    if Check_File_Exist ${FileName} "not_null"; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        # 使用wget下载
        Check_Command wget && wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate ${URL}
    fi
}
Create_User()
{
    local UserName=$1
    # 存在 || 不存在并创建
    Check_User_Exist $UserName || useradd -m -s /bin/bash $UserName
    Check_Dir_Exist /home/${UserName} || ( Make_Dir /home/${UserName} && Change_Mod /home/${UserName} &&  Chown_Dir ${UserName}:${UserName} /home/${UserName} )
}
Delete_User()
{
    local UserName=$1
    Check_User_Exist $UserName || userdel -f $UserName
}
# tar ---------------------------------------------------
Get_Tarfile_Name()
{
    local FileName=$1
    # awk -F "." '{printf "%s", $1}' ${FileName}
    echo ${FileName} | sed -r 's/(.*).tar..*/\1/g'
}
Tar()
{
    local FileName=$1
    local DirName=$(Get_Tarfile_Name ${FileName})
    # echo $DirName

    Check_Dir_Exist ${DirName} && Rm_Dir ${DirName}
    echo "${start_uncompress} ${FileName}..."
    tar zxf ${FileName}
}
Tarj()
{
    local FileName=$1
    local DirName=$(Get_Tarfile_Name ${FileName})

    Check_Dir_Exist ${DirName} && Rm_Dir ${DirName}
    echo "Uncompress ${FileName}..."
    tar jxf ${FileName}
}
TarJ()
{
    local FileName=$1
    local DirName=$(Get_Tarfile_Name ${FileName})

    Check_Dir_Exist ${DirName} && Rm_Dir ${DirName}
    echo "Uncompress ${FileName}..."
    tar Jxf ${FileName}
}
Ln_S()
{
    local Source=$1
    local Aim=$2
    Check_File_Exist ${Aim} && Back_Up_File ${Aim}
    Check_File_Exist ${Source} && ln -sf $Source $Aim
}
# text -------------------------------------------
Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}
Echo_Red()
{
  echo $(Color_Text "$1" "31")
}
# 绿色输出
Echo_Green()
{
  echo $(Color_Text "$1" "32")
}
Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}
Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}
# message---------------------------------------------------------------------
Echo_Smile()
{
    local Message=$1
    Echo_Green "-------------------------------------"
    Echo_Green "   ${Message} ~ 😀😀😀"
    Echo_Green "-------------------------------------"
}
Echo_Angry()
{
    local Message=$1
    Echo_Red "---------------------------------------"
    Echo_Red "   ${Message} ~ 😡😡😡"
    Echo_Red "---------------------------------------"
}
Echo_Sad()
{
    local Message=$1
    Echo_Yellow "---------------------------------------"
    Echo_Yellow "   ${Message} ~ 😰😰😰"
    Echo_Yellow "---------------------------------------"
}
Echo_Bye()
{
    Echo_Smile 'Bye'
}
Echo_Part_Line()
{
	echo "-----------------------------------------"
}
Echo_Null_Line()
{
	echo ""
}
Echo_Countdown()
{
    local C_Time=10
    Check_null $1 || C_Time=$1

    for i in $(seq $C_Time -1 1)
    do
        echo -en "$i ";
        sleep 1
    done
}
Echo_Countdown_Do_Message()
{
    local Message=$1
    local Countdown_Time=10
    Check_null $2 || Countdown_Time=$2
    # 此刻加🔓应该禁止输入任何内容 
    Echo_Blue "您有${Countdown_Time}秒的时间 ${Message}, 时间到了会自动结束" 
    Echo_Countdown $Countdown_Time
    # 此刻放开🔓
}
Clear_Screen()
{
	clear
}
HSleep()
{
	[ -z $1 ] && sleep 2 || sleep $1
}
Press_Start()
{
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Add_Bin_To_Path()
{
    local Expr=$1
    local Export_Path=$2
    local Skip_Sh=("cshrc" "tcshrc")

    [ -z "$2" ] &&  Export_Path=$Expr

    for shrc in `find /home -name ".*shrc"`
    do
        [[ "${Skip_Sh[@]}" =~ $(echo "${shrc}" | awk -F "." '{printf("%s"), $2}') ]] && continue
        grep "'${Expr}'" $shrc>/dev/null && continue
        echo ''${Export_Path}'' >> $shrc
        source $shrc
    done

    for shrc in `find /root -name ".*shrc"`
    do
        [[ "${Skip_Sh[@]}" =~ $(echo "${shrc}" | awk -F "." '{printf("%s"), $2}') ]] && continue
        grep "'${Expr}'" $shrc>/dev/null && continue
        echo ''${Export_Path}'' >> $shrc
        source $shrc
    done
}
Remove_Bin_From_Path()
{
    local PathInfo=$1
    PathInfo=$(echo ${PathInfo} | sed -e 's/\//\\\//g')
    local Skip_Sh=("cshrc" "tcshrc")

    for shrc in `find /home -name ".*shrc"`
    do
        [[ "${Skip_Sh[@]}" =~ $(echo "${shrc}" | awk -F "." '{printf("%s"), $2}') ]] && continue
        sed -i -e "/${PathInfo}/d" $shrc
        source $shrc
    done

    for shrc in `find /root -name ".*shrc"`
    do
        [[ "${Skip_Sh[@]}" =~ $(echo "${shrc}" | awk -F "." '{printf("%s"), $2}') ]] && continue
        sed -i -e "/${PathInfo}/d" $shrc
        source $shrc
    done
}
Make_Install()
{
    make -j `grep 'processor' /proc/cpuinfo | wc -l`
    Check_Up || make
    make install
}
IPTables_Enable_Port()
{
    local Port=$1
    if Check_Command 'iptables'; then
        if iptables -C INPUT -i lo -j ACCEPT; then
            iptables -A INPUT -p tcp --dport ${Port} -j DROP
            Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
            Iptable_Save_Reload
        fi
    fi
}
IPTables_Disable_Port()
{
    local Port=$1
    if Check_Command 'iptables'; then
        echo "${lang_del_iptables_rule}"
        iptables -D INPUT -p tcp --dport ${Port} -j DROP
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
        Iptable_Save_Reload
    fi
}
Firewall_Enable_Port()
{
    local Port=$1
    if Check_Command 'firewall-cmd'; then
        local Firewall_State=$(firewall-cmd --state) #= 'running' ]
        [ Firewall_State = 'running' ] || StartOrStop start firewalld
        firewall-cmd --zone=public --add-port=${Port}/tcp --permanent
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
        firewall-cmd --reload
        [ Firewall_State = 'running' ] || StartOrStop stop firewalld
    fi

    if Check_Command 'ufw'; then
        ufw allow ${Port}
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
    fi
}
Firewall_Disable_Port()
{
    local Port=$1
    if Check_Command 'firewall-cmd'; then
        local Firewall_State=$(firewall-cmd --state) #= 'running' ]
        [ Firewall_State = 'running' ] || StartOrStop start firewalld
        firewall-cmd --zone=public --remove-port=${Port}/tcp --permanent
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
        firewall-cmd --reload
        [ Firewall_State = 'running' ] || StartOrStop stop firewalld
    fi

    if Check_Command 'ufw'; then
        ufw deny ${Port}
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
    fi
}
Memory_Get_Total()
{
    Mem_Total=$(free -m | sed -n '2p' | awk '{print $2}')
}
Disk_Last_Space()
{
    Dist_Last_Spac=0
    [ -z $1 ] && return 0
    local Dir=$1

    Dist_Last_Spac=$(df -hlm "${Dir}" | sed -n '2p' | awk '{print $4}')
}