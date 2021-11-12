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
Show_System_Ctl()
{
    local AppName=$1
    local C_Command=$2
    Echo_Green "- ${AppName} Commands:"
    echo "systemctl start/stop/restart/reload/status ${C_Command}"
}

Show_Nginx_System_Ctl()
{
    Show_System_Ctl "Nginx" "nginx"
}

Show_PostgreSQL_System_Ctl()
{
    Show_System_Ctl "PostgreSQL" "pgsql"
}

Show_Mysql_System_Ctl()
{
    Show_System_Ctl "Mysql" "mysql"
}

Show_Redis_System_Ctl()
{
    Show_System_Ctl "Redis" "redis"
}

Show_System_Ctl_Commands_List()
{
    echo
    [[ "${Nginx_Enable_Install}" = 'y' || "${PostgreSQL_Enable_Install}" = 'y' || "${Mysql_Enable_Install}" = 'y' || "${Redis_Enable_Install}" = 'y' ]] && echo "Commands List [命令清单] ---------------------------------------"
    [ "${Nginx_Enable_Install}" = 'y' ] && Show_Nginx_System_Ctl
    [ "${PostgreSQL_Enable_Install}" = 'y' ] && Show_PostgreSQL_System_Ctl
    [ "${Mysql_Enable_Install}" = 'y' ] && Show_Mysql_System_Ctl
    [ "${Redis_Enable_Install}" = 'y' ] && Show_Redis_System_Ctl
    [[ "${Nginx_Enable_Install}" = 'y' || "${PostgreSQL_Enable_Install}" = 'y' || "${Mysql_Enable_Install}" = 'y' || "${Redis_Enable_Install}" = 'y' ]] && echo "--------------------------------------------------------------"
    echo
}