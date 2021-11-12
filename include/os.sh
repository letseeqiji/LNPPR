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
Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}

Check_WSL() {
    if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then
        echo "running on WSL"
        isWSL="y"
    else
        isWSL="n"
    fi
}

LSB_Install()
{
    if [ "$PM" = "yum" ]; then
        yum -y install redhat-lsb
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get --no-install-recommends install -y lsb-release
    fi
}

Get_OS_Version()
{
    if command -v lsb_release >/dev/null 2>&1; then
        OS_Version=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS_Version="${DISTRIB_RELEASE}"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_Version="${VERSION_ID}"
    fi
    if [ "${OS_Version}" = "" ]; then
        if command -v python2 >/dev/null 2>&1; then
            OS_Version=$(python2 -c 'import platform; print platform.linux_distribution()[1]')
        elif command -v python3 >/dev/null 2>&1; then
            OS_Version=$(python3 -c 'import platform; print(platform.linux_distribution()[1])')
        else
            LSB_Install
            OS_Version=`lsb_release -rs`
        fi
    fi
}

Get_OS_Info()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release >/dev/null; then
        OS_NAME='CentOS'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun Linux" /etc/*-release >/dev/null; then
        OS_NAME='Aliyun'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release >/dev/null; then
        OS_NAME='Amazon'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release >/dev/null; then
        OS_NAME='Fedora'
        PM='yum'
    elif grep -Eqi "Oracle Linux" /etc/issue || grep -Eq "Oracle Linux" /etc/*-release >/dev/null; then
        OS_NAME='Oracle'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux" /etc/issue || grep -Eq "Red Hat Enterprise Linux" /etc/*-release; then
        OS_NAME='RHEL'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        OS_NAME='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        OS_NAME='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        OS_NAME='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        OS_NAME='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release >/dev/null; then
        OS_NAME='Mint'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        OS_NAME='Kali'
        PM='apt'
    else
        OS_NAME='unknow'
    fi
    # 获取系统位数
    Get_OS_Bit
    Check_WSL
    Get_OS_Version
}

Get_RHEL_Version()
{
    Check_null $PM && Get_Release_Info
    if Check_Equal ${OS_NAME} "RHEL"; then
        RHEL_Ver=`grep -Ei "release.*[0-9].*" /etc/redhat-release | sed -n -r 's/.*release[[:space:]]([0-9])..*/\1/g;p'`
    fi
}

Set_Startup()
{
    init_name=$1

    echo "Add ${init_name} service at system startup..."
    if command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${init_name}.service || -s /lib/systemd/system/${init_name}.service || -s /usr/lib/systemd/system/${init_name}.service ]]; then
        systemctl daemon-reload
        systemctl enable ${init_name}.service
        systemctl daemon-reload
    else
        if Check_Equal $PM "yum"; then
            chkconfig --add ${init_name}
            chkconfig ${init_name} on
        elif Check_Equal $PM "apt" ]; then
            update-rc.d -f ${init_name} defaults
        fi
    fi
}

Remove_Startup()
{
    init_name=$1

    echo "Removing ${init_name} service at system startup..."
    if command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${init_name}.service || -s /lib/systemd/system/${init_name}.service || -s /usr/lib/systemd/system/${init_name}.service ]]; then
        systemctl disable ${init_name}.service
        systemctl daemon-reload
    else
        if Check_Equal $PM "yum"; then
            chkconfig ${init_name} off
            chkconfig --del ${init_name}
        elif Check_Equal $PM "apt"; then
            update-rc.d -f ${init_name} remove
        fi
    fi
}

StartOrStop()
{
    local action=$1
    local service=$2
    if Check_Command systemctl && Check_File_Exist /etc/systemd/system/${service}.service "not_null"; then
        systemctl ${action} ${service}.service
    fi
}

PM_Install()
{
    Check_null $PM && Get_Release_Info
    local AppName=$1
    "$PM" install "$AppName" -y
}

Iptable_Save_Reload()
{
    if Check_Equal "$PM" "yum"; then
        service iptables save
        service iptables reload
    elif Check_Equal "$PM" "apt"; then
        if Check_File_Exist '/etc/init.d/netfilter-persistent' 'not_null'; then
            /etc/init.d/netfilter-persistent save
            /etc/init.d/netfilter-persistent reload
        fi
        if Check_File_Exist '/etc/init.d/iptables-persistent' 'not_null'; then
            /etc/init.d/iptables-persistent save
            /etc/init.d/iptables-persistent reload
        fi
    fi
}