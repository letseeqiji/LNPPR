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
. include/puma.sh

Sqlite_Source_File=ruby-"${Ruby_Install_Ver}".tar.gz

Ruby_Check_Installed() {
    Check_Command "${Ruby_Install_Dir}"/"${Ruby_Install_Ver}"/bin/ruby
}

Ruby_Install_Depend() {
    if Check_Equal "${PM}" 'apt'; then
        local Packets=(gcc g++ libtool automake build-essential libgmp3-dev libpcre3-dev libssl-dev zlib1g-dev libsqlite3-dev libgdbm-dev libncurses5-dev libreadline6-dev libgdbm-dev libcurl4-openssl-dev)
    elif Check_Equal "${PM}" 'yum'; then
        local Packets=(gcc gcc-c++ gdbm-devel readline-devel openssl-devel sqlite-devel)  
    else
        return 1
    fi

    for packet in "${Packets[@]}"
    do
        echo ${packet}
        ${PM} install "${packet}" -y 
    done
}

Ruby_Get_Sourcefile()
{
    local Ruby_Base_Ver=`echo $Ruby_Install_Ver | awk -F '.' '{printf "%s.%s", $1,$2}'`
    cd ${current_dir}/src/
    if ! Check_File_Exist "${Sqlite_Source_File}"; then
        wget https://cache.ruby-lang.org/pub/ruby/"${Ruby_Base_Ver}"/"${Sqlite_Source_File}"
    fi
}

Ruby_Tar_And_Cd_Sourcefile()
{
    Check_Equal "${Install_Env}" "pro" && Rm_Dir ruby-"${Ruby_Install_Ver}"
    Tar "${Sqlite_Source_File}"
    cd ruby-"${Ruby_Install_Ver}" || return 1
}

Ruby_Check_Install_Dir()
{
    if Check_Dir_Exist "${Ruby_Install_Dir}";then
        Back_Up_File "${Ruby_Install_Dir}"
    fi
    Make_Dir "${Ruby_Install_Dir}"
}

Ruby_Make_Install_Configure()
{
    Ruby_Check_Install_Dir
    ./configure --prefix="${Ruby_Install_Dir}"/"${Ruby_Install_Ver}" --enable-shared --disable-install-doc
}

Ruby_Add_Bin_To_Path()
{
    local expr='export PATH=$PATH:.*ruby.*'
    local PathInfo='export PATH=$PATH:'${Ruby_Install_Dir}'/'${Ruby_Install_Ver}'/bin'
    local C_Command=${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/ruby
    Add_Bin_To_Path  "$expr" "${PathInfo}"
}

Ruby_Lns_To_Bin()
{
    Ln_S ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/ruby /usr/bin/ruby
    Ln_S ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/gems /usr/bin/gems
    Ln_S ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/bundle /usr/bin/bundle
}

Ruby_Chmod_Install_Dir()
{
    local Permission=777
    # local Dir=/usr/local/ruby/v3
    chmod ${Permission} -Rf ${Ruby_Install_Dir}/${Ruby_Install_Ver}
}

Ruby_Change_Gem_Sources()
{
    "${Ruby_Install_Dir}"/"${Ruby_Install_Ver}"/bin/gem sources -r https://rubygems.org/ -a https://gems.ruby-china.com/
    "${Ruby_Install_Dir}"/"${Ruby_Install_Ver}"/bin/gem sources | grep 'https://gems.ruby-china.com/'
}

Ruby_Chmod_Gem_Dir()
{
    chmod 777 -Rf "${Ruby_Install_Dir}"/"${Ruby_Install_Ver}"/lib/ruby/gems
}

Ruby_Install_Finish()
{
    if Check_Equal ${Install_Env} 'pro';then
        Rm_Dir "$current_dir"/src/ruby-"$Ruby_Install_Ver"
    fi
}

Ruby_Install() {
    if Ruby_Check_Installed; then
        echo "ruby ${lang_installed_already}, ${lang_no_need_install}"
    else
        cd "${current_dir}"/src || return 1

        echo "ruby ${lang_install_dependency}"
        Ruby_Install_Depend
        if ! Check_Up; then
            echo "Ruby ${lang_install_fail}"
            return 1
        fi

        echo "ruby ${lang_download_start}"
        Ruby_Get_Sourcefile
        if Check_Up;then
            echo "Ruby Source file ${lang_download_success}"
        else
            echo "Ruby Source file ${lang_download_not_found}"
            return 1
        fi

        echo "ruby ${lang_start_uncompress}"
        Ruby_Tar_And_Cd_Sourcefile
        if ! Check_Up;then
            echo "${lang_dir_not_find}"
            return 1
        fi

        echo "ruby ${lang_install_start_configure}"
        Ruby_Make_Install_Configure
        if Check_Up;then
            echo "make install ${lang_confighure_success}"
        else
            echo "make install ${lang_confighure_fail}"
            return 1
        fi

        echo "ruby ${lang_start_make_install}"
        Make_Install
        if Check_Up;then
            echo "Ruby ${lang_install_success}"
        else
            echo "Ruby ${lang_install_fail}"
            Ruby_Uninstall
            return 1
        fi

        echo "ruby ${lang_lns_to_bin}"
        Ruby_Add_Bin_To_Path
        if Check_Up;then
            echo "add bin ${lang_confighure_success}"
        else
            echo "add bin ${lang_confighure_fail}"
            Ruby_Uninstall
            return 1
        fi

        echo "ruby ${lang_lns_to_bin}"
        Ruby_Lns_To_Bin
        if Check_Up; then
            echo "ruby ln s ${lang_confighure_success}"
        else
            echo "ruby ln s ${lang_confighure_fail}"
            Ruby_Uninstall
            return 1
        fi

        echo "${lang_installed_check}"
        if Ruby_Check_Installed;then
            Ruby_Install_Finish
            Echo_Smile "Ruby ${lang_install_success}"
        else 
            echo "Ruby ${lang_install_fail}"
            Ruby_Uninstall
            return 1
        fi

        Ruby_Chmod_Install_Dir
        if Check_Up;then
            echo "chmod ${lang_confighure_success}"
        else
            echo "chmod ${lang_confighure_fail}"
            Ruby_Uninstall
            return 1
        fi

        Ruby_Chmod_Gem_Dir
        if Check_Up;then
            echo "gem chmod ${lang_confighure_success}"
        else
            echo "gem chmod ${lang_confighure_fail}"
            Ruby_Uninstall
            return 1
        fi

        Ruby_Change_Gem_Sources
        if Check_Up; then
            echo "gem source ${lang_confighure_success}"
        else
            echo "gem source ${lang_confighure_fail}"
        fi

        echo "${lang_install_start_app} puma"
        Puma_Install
        Check_Up && echo "${lang_install_success} puma" 

        Echo_Green "====== Puma install completed ======"
        Echo_Smile "Puma ${lang_install_success} !"  
    fi
}

Ruby_Uninstall() {
    local PathInfo='export PATH=$PATH:'${Ruby_Install_Dir}'/'${Ruby_Install_Ver}'/bin'
    local C_Command=ruby
    Remove_Bin_From_Path "${PathInfo}"
    Rm_Dir "${Ruby_Install_Dir}"
    Check_Command "${C_Command}" && echo "${lang_uninstall_fail}" || echo "${lang_uninstall_success}"
}
