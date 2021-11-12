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
# 设置时区
Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    Rm_Dir /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

Set_Host()
{
	# 配置 127.0.0.1 localhost
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        echo "Hosts: ok."
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
}

Set_DNS()
{
	# 配置dns
    if grep -Eqi '^nameserver[[:space:]]*114.114.114.114' /etc/resolv.conf; then
    	echo "DNS...ok"
    else
    	echo "Writing nameserver to /etc/resolv.conf ..."
        echo "nameserver 114.114.114.114" >> /etc/resolv.conf
    fi
}

# 检查hosts
Check_Hosts()
{
    Set_Host
    Set_DNS
}

# 禁用selinux
Disable_Selinux()
{
    [ -s /etc/selinux/config ] && sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
}

Make_Install()
{
    make -j `grep 'processor' /proc/cpuinfo | wc -l`
    Check_Up || make
    make install
}


Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${cur_dir}/src
    Check_null ${Mysql_Ver} || ( Check_File_Exist ${Mysql_Ver}.tar.gz ||  Download_Files ${Download_Mirror}/datebase/mysql/${Mysql_Ver}.tar.gz ${Mysql_Ver}.tar.gz )
    if Check_Equal ${SelectMalloc} "1"; then
        Check_File_Exist ${TCMalloc_Ver}.tar.gz|| Download_Files ${Download_Mirror}/lib/tcmalloc/${TCMalloc_Ver}.tar.gz ${TCMalloc_Ver}.tar.gz
        Check_File_Exist ${Libunwind_Ver}.tar.gz|| Download_Files ${Download_Mirror}/lib/libunwind/${Libunwind_Ver}.tar.gz ${Libunwind_Ver}.tar.gz
    fi

    if Check_Equal ${Install_Nginx} "y" ];then
        Check_File_Exist ${Nginx_Ver}.tar.gz || Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    fi
}
