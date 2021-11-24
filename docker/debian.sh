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
Docker_Debian_Remove_Old_Ver()
{
    Check_Command docker && echo "${lang_uninstall_try} docker" && sleep 1 || return 0
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    ! Check_Command docker && Docker_Remove_Lib_Dir
}
