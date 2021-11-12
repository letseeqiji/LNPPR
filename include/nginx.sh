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
Nginx_Init_File='/etc/init.d/nginx'
Nginx_Service_File='/etc/systemd/system/nginx.service'
Nginx_Source_File=nginx-${Nginx_Install_Ver}.tar.gz

Nginx_Check_Install_Need_File()
{
    local Template_Init_File="${current_dir}/init.d/init.d.nginx"
    if ! Check_File_Exist "${Template_Init_File}";then
        echo "${Template_Init_File} ${lang_file_not_find}"
        return 1
    fi

    local Template_Service_File="${current_dir}/init.d/nginx.service"
    if ! Check_File_Exist "${Template_Service_File}";then
        echo "${Template_Service_File} ${lang_file_not_find}"
        return 1
    fi
}

Nginx_Check_Installed()
{
    local Nginx_Server_File=${Nginx_Install_Dir}/sbin/nginx
    Check_Command nginx || Check_File_Exist ${Nginx_Server_File} 'not_null'
}

Nginx_Get_Sourcefile(){
    Check_File_Exist "${Nginx_Source_File}" 'not_null' || wget http://nginx.org/download/"${Nginx_Source_File}"
}

Nginx_Tar_And_Cd_Sourcefile()
{
    Check_Equal "${Install_Env}" "pro" && Rm_Dir "nginx-${Nginx_Install_Ver}"
    Tar "${Nginx_Source_File}" 
    cd "nginx-${Nginx_Install_Ver}" 
}

Nginx_Create_User()
{   
    groupadd ${Nginx_Group}
    Check_User_Exist ${Nginx_User} || useradd -s /sbin/nologin -g ${Nginx_User} ${Nginx_Group}
}

Nginx_Check_Need_Dir()
{   
    if ! Check_Equal "${Nginx_Config_Dir}" '/usr/local/nginx/conf';then
        Make_Dir ${Nginx_Config_Dir}
        Change_Own ${Nginx_Config_Dir} ${Nginx_User}
        Change_Mod ${Nginx_Config_Dir} 755
    fi

    Make_Dir ${Nginx_Log_Dir} && Change_Mod ${Nginx_Log_Dir} 777
}

Nginx_Configure()
{   
    ./configure --user=${Nginx_User} --group=${Nginx_Group} --prefix=${Nginx_Install_Dir} --conf-path=${Nginx_Config_File} --error-log-path=${Nginx_Log_File} --with-http_ssl_module --with-http_v2_module
}

Nginx_Make_Install()
{   
    Make_Install
}

Nginx_Lns_Bin()
{
    local Bin_Nginx=/usr/bin/nginx
    Check_File_Exist "${Bin_Nginx}" && Back_Up_File "${Bin_Nginx}"
    Ln_S "${Nginx_Install_Dir}/sbin/nginx" "${Bin_Nginx}"
}

Nginx_Remove_Lns_Bin()
{
    Rm_File /usr/bin/nginx
}

Nginx_Add_Init_D()
{
    local Template_Init_File="${current_dir}/init.d/init.d.nginx"
    if ! Check_File_Exist "${Template_Init_File}";then
        echo "${Template_Init_File} ${lang_file_not_find}"
        return 1
    fi
    Check_File_Exist "${Nginx_Init_File}" && Back_Up_File "${Nginx_Init_File}"
    Copy_File "${Template_Init_File}" "${Nginx_Init_File}" 
    Change_Mod "${Nginx_Init_File}" a+x
}

Nginx_Remove_Init_D()
{
    Rm_File ${Nginx_Init_File}
}

Nginx_Add_Systemd_Service()
{
    local Template_Service_File="${current_dir}/init.d/nginx.service"
    if ! Check_File_Exist "${Template_Service_File}";then
        echo "${Template_Service_File} ${lang_file_not_find}"
        return 1
    fi
    Check_File_Exist "${Nginx_Service_File}" && Back_Up_File "${Nginx_Service_File}"
    Copy_File "${Template_Service_File}" "${Nginx_Service_File}"
}

Nginx_Remove_Systemd_Service()
{
    Rm_File ${Nginx_Service_File}
}

Nginx_Set_Startup()
{
    Set_Startup nginx
}

Nginx_Remove_Startup()
{
    Remove_Startup nginx
}

Nginx_Enable_Remote_Port()
{
    Firewall_Enable_Port "${Nginx_Port}"
    IPTables_Enable_Port "${Nginx_Port}"
}

Nginx_Disable_Remote_Port()
{
    Firewall_Disable_Port "${Nginx_Port}"
    IPTables_Disable_Port "${Nginx_Port}"
}

Nginx_Install_Finish()
{
    if Check_Equal ${Install_Env} 'pro';then
        Rm_Dir "$current_dir/src/nginx-${Nginx_Install_Ver}"
    fi
}

Nginx_Common_Install()
{
    echo "${lang_add_user} ..."
    Nginx_Create_User || return 1

    Nginx_Check_Need_Dir
    if ! Check_Up;then
        echo "${lang_dir_not_find}"
        return 1
    fi

    Nginx_Tar_And_Cd_Sourcefile
    if ! Check_Up;then
        echo "${lang_dir_not_find}"
        return 1
    fi

    echo "${lang_start_configure}"
    Nginx_Configure || return 1

    echo "${lang_start_make_install}"
    Nginx_Make_Install || return 1
}

Nginx_Sec_Setting()
{
    echo "${lang_lns_to_bin}"
    Nginx_Lns_Bin || return 1

    echo "${lang_add_init}"
    Nginx_Add_Init_D
    if Check_Up;then
        echo "${lang_add_success}"
    else
        echo "${lang_add_fail}"
        return 1
    fi

    echo "${lang_add_systemd_service}"
    Nginx_Add_Systemd_Service
    if Check_Up;then
        echo "${lang_add_success}"
    else
        echo "${lang_add_fail}"
        return 1
    fi

    echo "${lang_add_auto_start}"
    Nginx_Set_Startup
    if Check_Up;then
        echo "${lang_confighure_success}"
    else
        echo "${lang_confighure_fail}"
        return 1
    fi
}

Nginx_Install()
{
    echo "Install ${Nginx_Install_Ver} Stable Version..."

    if Nginx_Check_Installed;then
        echo "Nginx server already exists."
    else
        echo "${lang_check_configure_start} install need file"
        if ! Nginx_Check_Install_Need_File;then
            return 1
        fi

        cd ${current_dir}/src
        
        Nginx_Get_Sourcefile
        if Check_Up;then
            echo "${lang_download_success}"
        else
            echo "${lang_download_not_found}"
            return 1
        fi

        Nginx_Common_Install
        if Check_Up;then
            echo "${lang_install_success}"
        else
            echo "${lang_install_fail},${lang_install_rollback}"
            Nginx_Uninstall
            return 1
        fi

        Nginx_Sec_Setting
        if Check_Up;then
            echo "${lang_confighure_success}"
        else
            echo "${lang_confighure_fail}，${lang_install_rollback}"
            Nginx_Uninstall
            return 1
        fi

        echo "${lang_start_app} nginx"
        StartOrStop start nginx
        if Check_Up;then
            echo "${lang_start_success}"
        else
            echo "${lang_start_fail}"
        fi
		
		echo "${lang_set_remote}"
		Nginx_Enable_Remote_Port

        if Nginx_Check_Installed; then
            Echo_Green "====== Nginx install completed ======"
            Echo_Smile "Nginx ${lang_install_success} !"
        else
            Echo_Red "Nginx install failed!"
        fi

        Nginx_Install_Finish
    fi

}

Nginx_Uninstall()
{
    if Nginx_Check_Installed;then
        echo "Uninstall Nginx..."
        echo "stop Nginx ..."
        StartOrStop stop Nginx
        Nginx_Remove_Lns_Bin
        Nginx_Remove_Init_D
        Nginx_Remove_Systemd_Service
        Rm_Dir ${Nginx_Install_Dir}
        Nginx_Disable_Remote_Port
        Echo_Green "Uninstall Nginx completed."
    fi
}


