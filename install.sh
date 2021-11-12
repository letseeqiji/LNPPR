#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
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

if [ $(id -u) != "0" ]; then
    Echo_Sad "Error: You must be root to run this script!"
    exit
fi

Enable_Lang=(zh en)
current_dir=$(pwd)

. version
. install.conf
[[ "${Enable_Lang[@]}" =~ "${Language}" ]] || Language=zh
. i18n/${Language}.lang
. include/show_welcome.sh
. include/helper.sh
. include/os.sh
. include/begin.sh
. include/nodejs.sh
. include/yarn.sh
. include/nginx.sh
. include/ruby.sh
. include/rails.sh
. include/sqlite.sh
. include/pgsql.sh
. include/redis.sh
. include/mysql.sh
. include/finish.sh

Get_OS_Info
Check_Equal "${OS_NAME}" "unknow" && Echo_Sad "ooh~, ${lang_OS_not_surport}." && exit 1
Check_Not_Equal  "${Is_64bit}" 'y' && Echo_Sad "ooh~, ${lang_OS_only_surport_x64}" && exit 1
Check_Equal "${isWSL}" 'y' && Echo_Sad "ooh~, ${lang_OS_not_surport_WSL}" && exit 1
! Check_OS_Vsersion && Echo_Sad "ooh!, ${lang_OS_too_old}" && exit 1
! Check_Script_Full && Echo_Sad "ooh~, ${lang_script_not_full}" && exit 1
Check_Hardware_Need || exit 1

clear
Show_Welcome_${Language}
echo
echo "${lang_check_install_app_list}："
Show_Install_List
Echo_Green "😀 ${lang_note}：${lang_change_app_list} "
Echo_Green "😀 ${lang_modify_install_config} "
Echo_Green "-----------------------------------------------------------------------------"
echo
echo "${lang_install_final_confirm}"
Press_Start

Echo_Green "${lang_install_dependency}" 2>&1 | tee root/install_depend_history.md
Check_Env 2>&1 | tee /root/install-check-env.log

Check_Depend_Install || exit

Install()
{
    [ "${Nodejs_Enable_Install}" = 'y' ] && Nodejs_Install 2>&1 | tee /root/install-nodejs-${Nodejs_Install_Ver}.log
    [ "${Yarn_Enable_Install}" = 'y' ] && Yarn_Install 2>&1 | tee /root/install-yarn-${Yarn_Install_Ver}.log
    [ "${Nginx_Enable_Install}" = 'y' ] && Nginx_Install 2>&1 | tee /root/install-nginx-${Nginx_Install_Ver}.log
    [ "${Ruby_Enable_Install}" = 'y' ] && Ruby_Install 2>&1 | tee /root/install-ruby-${Ruby_Install_Ver}.log
    [ "${Rails_Enable_Install}" = 'y' ] && Rails_Install 2>&1 | tee /root/install-rails-${Rails_Install_Ver}.log
    [ "${Sqlite3_Enable_Install}" = 'y' ] && Sqlite_Install 2>&1 | tee /root/install-sqlite-${Sqlite3_Install_Ver}.log
    [ "${PostgreSQL_Enable_Install}" = 'y' ] && PgSQL_Install 2>&1 | tee /root/install-pgsql-${PgSQL_Install_Ver}.log
    [ "${Mysql_Enable_Install}" = 'y' ] && MySQL_Install 2>&1 | tee /root/install-mysql-${Mysql_Install_Ver}.log
    [ "${Redis_Enable_Install}" = 'y' ] && Redis_Install 2>&1 | tee /root/install-redis-${Redis_Install_Ver}.log
}

Install

if Check_Up;then
    Echo_Smile "${lang_install_success} Enjoy it"
    Show_System_Ctl_Commands_List
fi