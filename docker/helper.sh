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
Docker_Binary_Tar="docker-${Docker_Install_Ver}.tgz"

Docker_Check_Image_Exist()
{
    local REPOSITORY=$1
    local TAG=$2

    docker images | grep "${REPOSITORY}" | grep "${TAG}"
}
Docker_Image_Pull()
{
    local Img=$1
    local Ver=$2

    Docker_Check_Image_Exist "${Img}" "${Ver}" || docker pull "${Img}:${Ver}"
}
Docker_Remove_Lib_Dir()
{
    # 会删除docker镜像文件目录
    Rm_Dir /var/lib/docker
    Rm_Dir /var/lib/containerd
}
Docker_Enable_Auto_Start()
{
    Set_Startup docker
    StartOrStop restart docker
}
Docker_Add_User_To_Docker_Grp()
{
    local User=$1
    echo "${lang_add_user_to_group} docker" 
    groupadd docker 
    gpasswd -a "${User}" docker 
}
Docker_Registry_Mirrors()
{
    ! Check_Command docker && return 0
    ! Check_Dir_Exist /etc/docker && Make_Dir /etc/docker
    StartOrStop stop docker

    if Check_Empty ${Docker_Main_Registry} || Check_null ${Docker_Main_Registry};then
        Docker_Main_Registry="https://hub-mirror.c.163.com"
    fi
    cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "${Docker_Main_Registry}",
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
    if grep -Eqi "${Docker_Main_Registry}" /etc/docker/daemon.json;then
        echo "${lang_success}"
    else
        echo "${lang_fail}"
        return 1
    fi
    StartOrStop start docker
}
Docker_Get_Binary()
{
    Check_Command wget || ${PM} install -y wget
    Check_File_Exist ${Docker_Binary_Tar} || wget ${Docker_Binary_Download}/${Docker_Binary_Tar}
}
Docker_Tar()
{
    Check_File_Exist ${Docker_Binary_Tar} && echo "tar file" && tar -xzf ${Docker_Binary_Tar}
}
Docker_Add_To_Bin()
{
    Check_Dir_Exist docker  || echo "没有docker文件夹" 

    echo "copy file to bin ..."
    cp docker/* /usr/bin/
}
Docker_Add_To_Systemd()
{
    cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
  
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
  
[Install]
WantedBy=multi-user.target
EOF
}
# compose
Compose_Make_Base_Compose_File()
{
    cat > docker-compose.yml <<EOF
version: '${Compose_Version}'
services:
EOF
}
Compose_Build_App()
{
    docker-compose build
}
Compose_Build_Service()
{
    local Service=$1
    docker-compose build ${Service}
}
# start | stop
Compose_Ctl()
{
    local Ctrl=$1
    local Service=$2
    docker-compose ${Ctrl} ${Service}
}
Compose_Up_Or_Down()
{
    local Ctrl=$1
    local Opt=$2
    docker-compose ${Ctrl} ${Opt}
}
# rails
Rails_Add_Or_Remove_Gem()
{
    ! Check_File_Exist Gemfile && echo "gemfile 不存在" && return 1

    local Control=$1
    local Gem=$2
    if Check_Equal $Control 'add';then
        ! grep -E "^[[:space:]]*gem[[:space:]]*'${Gem}'" Gemfile && echo "gem '${Gem}'" >> Gemfile
    fi
    if Check_Equal $Control 'rm';then
        grep -E "^[[:space:]]*gem[[:space:]]*'${Gem}'" Gemfile && sed -i "/^[[:space:]]*gem[[:space:]]*'${Gem}'/d" Gemfile
    fi
}