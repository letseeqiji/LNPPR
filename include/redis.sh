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
Redis_Init_File='/etc/init.d/redis'
Redis_Service_File='/etc/systemd/system/redis.service'

Redis_Check_Installed()
{
    local Redis_Server_File=${Redis_Install_Dir}/bin/redis-server
    Check_Command redis-server || Check_File_Exist ${Redis_Server_File} 'not_null'
}

Redis_Get_Sourcefile(){
    local Redis_Source_File="redis-${Redis_Install_Ver}.tar.gz"
    local Download_Url="https://download.redis.io/releases/redis-${Redis_Install_Ver}.tar.gz"
    if ! Check_File_Exist "${Redis_Source_File}"; then
        wget "${Download_Url}"
    fi
}

Redis_Tar_And_Cd_Sourcefile()
{
    local Redis_Source_File="redis-${Redis_Install_Ver}.tar.gz"
    Check_Equal "${Install_Env}" "pro" && Rm_Dir "redis-${Redis_Install_Ver}"
    Tar "${Redis_Source_File}" 
    cd redis-"${Redis_Install_Ver}" 
}

Redis_Make_And_Install()
{
    make PREFIX=${Redis_Install_Dir} install
}

Redis_Create_Config_File()
{
    Make_Dir ${Redis_Config_Dir}
    Copy_File redis.conf ${Redis_Config_File}
}

Redis_Main_Config()
{
    sed -i 's/daemonize no/daemonize yes/g' ${Redis_Config_File}
    if ! grep -Eqi '^bind[[:space:]]*127.0.0.1' ${Redis_Config_File}; then
        sed -i 's/^# (bind 127.0.0.1 -::1)/\1/g' ${Redis_Config_File}
    fi
    sed -i 's#^pidfile.*#pidfile '${Redis_Pid_File}'#g' ${Redis_Config_File}
    Make_Dir ${Redis_Data_Dir} && Change_Mod ${Redis_Data_Dir} 777
    sed -i 's#^dir[[:space:]]*.*#dir '${Redis_Data_Dir}'#g' ${Redis_Config_File}
    Make_Dir ${Redis_Log_Dir} && Change_Mod ${Redis_Log_Dir} 777
    sed -i 's#^logfile[[:space:]]*.*#logfile '${Redis_Log_File}'#g' ${Redis_Config_File}
    sed -i 's#^port[[:space:]]*.*#port '${Redis_Port}'#g' ${Redis_Config_File}
}

Redis_Add_Bin_To_Path()
{
    Add_Bin_To_Path 'export PATH="$PATH:'${Redis_Install_Dir}'/bin"'
}

Redis_Remove_Bin_From_Path()
{
    Remove_Bin_From_Path 'export PATH="$PATH:'${Redis_Install_Dir}'/bin"' 
}

Redis_Add_Init_D()
{
    local Template_Init_File="${current_dir}/init.d/init.d.redis"
    if ! Check_File_Exist "${Template_Init_File}";then
        echo "${Template_Init_File} ${lang_file_not_find}"
        return 1
    fi
    Check_File_Exist "${Redis_Init_File}" && Back_Up_File "${Redis_Init_File}"
    Copy_File "${Template_Init_File}" "${Redis_Init_File}"
    Change_Mod "${Redis_Init_File}" a+x
}

Redis_Remove_Init_D()
{
    Rm_File "${Redis_Init_File}"
}

Redis_Add_Systemd_Service()
{
    local Template_Service_File="${current_dir}/init.d/redis.service"
    if ! Check_File_Exist "${Template_Service_File}";then
        echo "${Template_Service_File} ${lang_file_not_find}"
        return 1
    fi
    Check_File_Exist "${Redis_Service_File}" && Back_Up_File "${Redis_Service_File}"
    Copy_File "${Template_Service_File}" "${Redis_Service_File}"
}

Redis_Remove_Systemd_Service()
{
    Rm_File ${Redis_Service_File}
}

Redis_Set_Start_Up()
{
    Set_Startup redis
}

Redis_Remove_Start_Up()
{
    Remove_Startup redis
}

Redis_Enable_Remote_Port()
{
    Firewall_Enable_Port "${Redis_Port}"
    IPTables_Enable_Port "${Redis_Port}"
}

Redis_Disable_Remote_Port()
{
    Firewall_Disable_Port "${Redis_Port}"
    IPTables_Disable_Port "${Redis_Port}"
}

Redis_Set_Remote()
{
    local Rgx1='^[[:space:]]*bind[[:space:]]*127.0.0.1'
    local Rgx2='^[[:space:]]*protected-mode[[:space:]]*yes'

    if grep -Eqi "$Rgx1" $Redis_Config_File; then
        sed -i 's/'$Rgx1'/# bind 127.0.0.1/g' $Redis_Config_File
    fi

    if grep -Eqi "$Rgx2" $Redis_Config_File; then
        sed -i 's/'$Rgx2'/protected-mode no/g' $Redis_Config_File
    fi

    StartOrStop restart redis
}

Redis_Remove_Remote()
{
    local Rgx1='^[[:space:]]*#[[:space:]]*bind[[:space:]]*127.0.0.1[[:space:]]*$'
    local Rgx2='^[[:space:]]*protected-mode[[:space:]]*no'

    if grep -Eqi "$Rgx1" $Redis_Config_File; then
        sed -i 's/'$Rgx1'/bind 127.0.0.1/g' $Redis_Config_File
    fi
    
    if grep -Eqi "$Rgx2" $Redis_Config_File; then
        sed -i 's/'$Rgx2'/protected-mode yes/g' $Redis_Config_File
    fi

    StartOrStop restart redis
}

Redis_Set_Passwd()
{
    local Rgx1='^#[[:space:]]*requirepass[[:space:]]*.*'
    local Rgx2='^[[:space:]]*requirepass[[:space:]]*.*'

    if grep -Eqi "$Rgx1" $Redis_Config_File; then
        sed -i 's/'$Rgx1'/requirepass '$Redis_Passwd'/g' $Redis_Config_File
    elif grep -Eqi "$Rgx2" $Redis_Config_File; then
        sed -i 's/'$Rgx2'/requirepass '$Redis_Passwd'/g' $Redis_Config_File
    fi

    StartOrStop restart redis
}

Redis_Remove_Passwd()
{
    local Rgx='^[[:space:]]*requirepass[[:space:]]*.*'

    if grep -Eqi "$Rgx" $Redis_Config_File; then
        sed -i -r 's/('$Rgx')/# \1/g' $Redis_Config_File
        StartOrStop restart redis
    fi
}

Redis_Install_Finish()
{
    if Check_Equal ${Install_Env} 'pro';then
        Rm_Dir "$current_dir"/src/redis-"${Redis_Install_Ver}"
    fi
}

Redis_Common_Install()
{
    Redis_Tar_And_Cd_Sourcefile
    if ! Check_Up;then
        echo "${lang_dir_not_find}"
        return 1
    fi

    echo "${lang_start_make_install}"
    Redis_Make_And_Install
    if ! Check_Up;then
        echo "${lang_make_install_fail}"
        return 1
    fi

    echo "创建配置文件"
    Redis_Create_Config_File
    if ! Check_Up;then
        echo "创建配置文件失败"
        return 1
    fi

    echo "配置主文件"
    Redis_Main_Config
    if ! Check_Up;then
        echo "配置文件失败"
        return 1
    fi
}

Redis_Sec_Setting()
{
    echo "${lang_add_bin_to_path}"
    Redis_Add_Bin_To_Path
    if Check_Up;then
        echo "${lang_confighure_success}"
    else
        echo "${lang_confighure_fail}"
        return 1
    fi

    echo "${lang_add_init}"
    Redis_Add_Init_D
    if Check_Up;then
        echo "${lang_add_success}"
    else
        echo "${lang_add_fail}"
        return 1
    fi

    echo "${lang_add_systemd_service}"
    Redis_Add_Systemd_Service
    if Check_Up;then
        echo "${lang_add_success}"
    else
        echo "${lang_add_fail}"
        return 1
    fi

    echo "${lang_add_auto_start}"
    Redis_Set_Start_Up
    if Check_Up;then
        echo "${lang_confighure_success}"
    else
        echo "${lang_confighure_fail}"
        return 1
    fi
}

Redis_Check_Config()
{
    echo "${lang_check_configure_start}: Redis_Install_Ver..."
    if Check_Empty ${Redis_Install_Ver};then
        local Redis_Default_Install_Ver=6.2.6
        echo "${lang_check_configure_empty_use_default}: redis-${Redis_Default_Install_Ver}"
        Redis_Install_Ver=${Redis_Default_Install_Ver}
        read -p  "${lang_install_final_confirm}"
    fi

    local Gcc_Ver=$(gcc --version | grep 'gcc' | awk '{printf("%s"), $3}' | awk -F "." '{printf("%d%d"), $1, $2}')
    if [ ${Gcc_Ver} -lt 48 ];then
        echo "gcc ${lang_version_too_old}, set rails version 5.0.9"
        Redis_Install_Ver='5.0.9'
    fi

    echo "${lang_check_configure_start}: Redis_Install_Dir..."
    if Check_Empty ${Redis_Install_Dir};then 
        local Redis_Default_Install_Dir='/usr/local/redis'
        echo "${lang_check_configure_empty_use_default}: ${Redis_Default_Install_Dir}"
        Redis_Install_Dir=${Redis_Default_Install_Dir}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_check_configure_start}: Redis_Data_Dir..."
    if Check_Empty ${Redis_Data_Dir};then 
        local Redis_Default_Data_Dir='/data/redis/data'
        echo "${lang_check_configure_empty_use_default}: ${Redis_Default_Data_Dir}"
        Redis_Data_Dir=${Redis_Default_Data_Dir}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_check_configure_start}: Redis_Log_Dir..."
    if Check_Empty ${Redis_Log_Dir};then 
        local Redis_Default_Log_Dir='/data/redis/log'
        echo "${lang_check_configure_empty_use_default}: ${Redis_Default_Log_Dir}"
        Redis_Log_Dir=${Redis_Default_Log_Dir}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_check_configure_start}: Redis_Port..."
    if Check_Empty ${Redis_Port};then 
        local Redis_Default_Port=6379
        echo "${lang_check_configure_empty_use_default}: ${Redis_Default_Port}"
        Redis_Port=${Redis_Default_Port}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_interface_used_check}..."
    if ! Check_Empty ${Redis_Port};then
        if Check_Interface_Used ${Redis_Port} ;then
            echo "${Redis_Port} ${lang_used_reconfig}: Redis_Port..."
            return 1
        else
            echo "${lang_check_configured_pass}"
        fi
    fi
    
    echo "${lang_check_configure_start}: Redis_Pid_File..."
    if Check_Empty ${Redis_Pid_File};then 
        local Redis_Default_Pid_File='/var/run/redis.pid'
        echo "${lang_check_configure_empty_use_default}: ${Redis_Default_Pid_File}"
        Redis_Pid_File=${Redis_Default_Pid_File}
    else
        echo "${lang_check_configured_pass}"
    fi
}

Redis_Install()
{
    echo "Install ${Redis_Install_Ver} Stable Version..."

    if Redis_Check_Installed;then
        echo "Redis server already exists."
    else
        Redis_Check_Config  
        if Check_Up;then
            echo "${lang_all_configure_pass}"
        else
            echo "${lang_configure_error}"
            return 1
        fi

        cd ${current_dir}/src
        Redis_Get_Sourcefile
        if Check_Up;then
            echo "${lang_download_success}"
        else
            echo "${lang_download_not_found}"
            return 1
        fi

        Redis_Common_Install
        if Check_Up;then
            echo "${lang_install_success}"
        else
            echo "${lang_install_fail},${lang_install_rollback}"
            Redis_Uninstall
            return 1
        fi

        Redis_Sec_Setting
        if Check_Up;then
            echo "${lang_confighure_success}"
        else
            echo "${lang_confighure_fail}，${lang_install_rollback}"
            Redis_Uninstall
            return 1
        fi

        if Redis_Check_Installed; then
            if Check_Equal ${Redis_Enable_Remote} 'y';then
                echo "${lang_set_remote}"
                Redis_Enable_Remote_Port
                Redis_Set_Remote
            fi
            if Check_Equal ${Redis_Enable_Passwd} 'y';then
                echo "${lang_set_passwd}"
                Redis_Set_Passwd
            fi
            Echo_Green "====== Redis install completed ======"
            Echo_Smile "Redis ${lang_install_success} !"
        else
            Echo_Red "Redis install failed!"
        fi

        Redis_Install_Finish
    fi
}

Redis_Uninstall()
{
    if Redis_Check_Installed;then
        echo "${lang_uninstall_start} Redis..."
        echo "stop Redis ..."
        StartOrStop stop redis
        Redis_Remove_Bin_From_Path
        Redis_Remove_Init_D
        Redis_Remove_Systemd_Service
        Redis_Remove_Start_Up
        Rm_Dir ${Redis_Install_Dir}
        Redis_Disable_Remote_Port

        Echo_Green "${lang_uninstall_success}."
    fi
}
