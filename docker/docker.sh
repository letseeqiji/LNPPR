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
Docker_Install_Enable_Check()
{
    # only surport X64
    if Check_Equal "${Is_64bit}" 'n';then
        Echo_Red "The current script only surport amdX64 OS! Sorry"
        return 1
    fi
}

Docker_Installed_Check()
{
    if Check_Command docker;then
        Echo_Green "You have installed $(docker --version)"
        return 0
    else
        return 1
    fi
}

Docker_Uninstall_Old_Ver()
{
    case ${OS_NAME} in
        'CentOS')
        Docker_CentOS_Remove_Old_Ver || return 1
        ;;
        'Debian')
        Docker_Debian_Remove_Old_Ver || return 1
        ;;
        'Fedora')
        Docker_Fedora_Remove_Old_Ver || return 1
        ;;
        'RHEL')
        Docker_RHEL_Remove_Old_Ver || return 1
        ;;
        'Ubuntu')
        Docker_Ubuntu_Remove_Old_Ver || return 1
        ;;
        *)
        return 0
        ;;
    esac
}

Docker_Common_Install()
{
    echo "${lang_download_start}"
    Docker_Get_Binary
    Check_Up_OK || return 1

    echo "${lang_start_uncompress}"
    Docker_Tar
    Check_Up_OK || return 1

    echo "move file to bin"
    Docker_Add_To_Bin
    echo "${lang_success}"
}

Docker_Sec_Config()
{
    echo "${lang_reset_registry}"
    Docker_Registry_Mirrors
    echo "ok"

    echo "${lang_add_systemd_service}"
    Docker_Add_To_Systemd
    Check_Up_OK || return 1

    echo "${lang_add_auto_start}"
    Docker_Enable_Auto_Start
    Check_Up_OK || return 1

    read -p "请输入您要添加到docker群组的用户：" duser
    [ ! ${duser} = '' ] && Docker_Add_User_To_Docker_Grp ${duser} 

    StartOrStop restart docker
}

Docker_Install()
{
    Docker_Install_Enable_Check || return 1

    Docker_Installed_Check && return 0

    echo "${lang_uninstall_try} old version docker"
    Docker_Uninstall_Old_Ver
    Check_Up_OK || return 1

    Check_Dir_Exist ${current_dir}/src || mkdir ${current_dir}/src
    cd ${current_dir}/src

    echo "${lang_install_start_app} docker"
    Docker_Common_Install
    Check_Up_OK || return 1

    echo "${lang_configure_satrt}"
    Docker_Sec_Config
    Check_Up_OK || return 1
}

Docker_Ubinstall()
{
    StartOrStop stop docker
    Remove_Startup docker
    Rm_File /etc/systemd/system/docker.service
    Rm_File /usr/bin/containerd
    Rm_File /usr/bin/containerd-shim
    Rm_File /usr/bin/containerd-shim-runc-v2
    Rm_File /usr/bin/ctr
    Rm_File /usr/bin/docker
    Rm_File /usr/bin/docker-init
    Rm_File /usr/bin/docker-proxy
    Rm_File /usr/bin/dockerd
    Rm_File /usr/bin/runc
    Docker_Remove_Lib_Dir
}