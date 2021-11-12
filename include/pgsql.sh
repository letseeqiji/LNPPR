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
PgSQL_Source_File="postgresql-${PgSQL_Install_Ver}.tar.gz"

PgSQL_Check_Need_Make_Ver()
{
	# GNU make版本3.80或以上
	local Make_Ver=`make -v | grep 'GNU[[:space:]]Make' | awk -F " " '{print $3}' | awk -F "." '{printf "%s%s", $1, $2}'`
	if [ $Make_Ver -lt 38 ];then
		echo "make version must >= 3.80"
		return 1
	fi
}

PgSQL_Check_Install_Need_File()
{
	local Template_Init_File="${current_dir}/init.d/init.d.pgsql"
	if ! Check_File_Exist "${Template_Init_File}";then
		echo "${Template_Init_File} ${lang_file_not_find}"
		return 1
	fi

	local Template_Service_File="${current_dir}/init.d/pgsql.service"
	if ! Check_File_Exist "${Template_Service_File}";then
		echo "${Template_Service_File} ${lang_file_not_find}"
		return 1
	fi
}

PgSQL_Check_Installed()
{
	Check_File_Exist /usr/local/pgsql/bin/pg_ctl
}

PgSQL_Check_Is_Running()
{
	Check_App_Running pgsql
}

PgSQL_Install_Depend() {
    if Check_Equal "${PM}" 'apt'; then
        local Packets=(readline-doc build-essential zlib1g lib1g-dev)
    elif Check_Equal "${PM}" 'yum'; then
        local Packets=(readline-devel zlib-devel)  
    else
        return 1
    fi

    for packet in "${Packets[@]}"
    do
        echo ${packet}
        ${PM} install "${packet}" -y 
    done
}

PgSQL_Add_User_Postgres()
{
	echo "${lang_user_check_exist}"
	Check_User_Exist postgres
	if Check_Up;then
		echo "postgres ${lang_user_exist}"
		return 0
	fi

	echo "${lang_user_start_create} postgres"
	Create_User postgres
	if Check_Up;then
		echo "${lang_user_create_success}"
	else
		echo "${lang_user_create_fail}"
		return 1
	fi
}

PgSQL_Del_User_Postgres()
{
	Check_User_Exist postgres && Delete_User postgres
}

PgSQL_Get_Sourcefile()
{
	local PgSQL_Source_File="postgresql-${PgSQL_Install_Ver}.tar.gz"
    local Download_Url="${PgSQL_Base_Download_Url}/source/v${PgSQL_Install_Ver}/${PgSQL_Source_File}"
    cd ${current_dir}/src/
    if ! Check_File_Exist "${PgSQL_Source_File}"; then
        wget "${Download_Url}"
    fi
}

PgSQL_Tar_And_Cd_Sourcefile()
{
    Check_Equal "${Install_Env}" "pro" && Rm_Dir "postgresql-${PgSQL_Install_Ver}"
    Tar "${PgSQL_Source_File}" 
    cd "postgresql-${PgSQL_Install_Ver}" 
}

PgSQL_Check_Data_Dir()
{
	Check_Dir_Exist "${PgSQL_Data_Dir}" && Back_Up_File "${PgSQL_Data_Dir}"
	Make_Dir "${PgSQL_Data_Dir}" && Chown_Dir postgres:postgres "${PgSQL_Data_Dir}"
}

PgSQL_Remove_Data_Dir()
{
	# 安装 过程中 不适用 Back_Up_File "${PgSQL_Data_Dir}" "/root"
	Check_Dir_Exist "${PgSQL_Data_Dir}" && Rm_Dir "${PgSQL_Data_Dir}"
}

PgSQL_Add_Bin_To_Path()
{
	Add_Bin_To_Path 'export PGHOME=/usr/local/pgsql'
	Add_Bin_To_Path 'export PGDATA=/data/pgsql' 
	Add_Bin_To_Path 'PATH=$PGHOME/bin:$PATH' 
	Add_Bin_To_Path 'MANPATH=$PGHOME/share/man:$MANPATH' 
	Add_Bin_To_Path 'LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH' 
}

PgSQL_Remove_Bin_From_Path()
{
	Remove_Bin_From_Path 'export PGHOME=/usr/local/pgsql' 
	Remove_Bin_From_Path 'export PGDATA=/data/pgsql' 
	Remove_Bin_From_Path 'PATH=$PGHOME/bin:$PATH' 
	Remove_Bin_From_Path 'MANPATH=$PGHOME/share/man:$MANPATH' 
	Remove_Bin_From_Path 'LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH'
}

PgSQL_Add_Init_D()
{
	local Template_Init_File="${current_dir}/init.d/init.d.pgsql"
	local Init_File="/etc/init.d/pgsql"
	if ! Check_File_Exist "${Template_Init_File}";then
		echo "${Template_Init_File} ${lang_file_not_find}"
		return 1
	fi
	Check_File_Exist "${Init_File}" && Back_Up_File "${Init_File}"
	Copy_File "${Template_Init_File}" "${Init_File}" 
	Change_Mod "${Init_File}" a+x
}

PgSQL_Remove_Init_D()
{
	Rm_File /etc/init.d/pgsql
}

PgSQL_Add_Systemd_Service()
{
	local Template_Service_File="${current_dir}/init.d/pgsql.service"
	local Service_File="/etc/systemd/system/pgsql.service"
	if ! Check_File_Exist "${Template_Service_File}";then
		echo "${Template_Service_File} ${lang_file_not_find}"
		return 1
	fi
	Check_File_Exist "${Service_File}" && Back_Up_File "${Service_File}"
	Copy_File "${Template_Service_File}" "${Service_File}"
}

PgSQL_Remove_Systemd_Service()
{
	Rm_File /etc/systemd/system/pgsql.service
}

PgSQL_Enable_Remote_Port()
{
    Firewall_Enable_Port "${PgSQL_Port}"
    IPTables_Enable_Port "${PgSQL_Port}"
}

PgSQL_Disable_Remote_Port()
{
    Firewall_Disable_Port "${PgSQL_Port}"
    IPTables_Disable_Port "${PgSQL_Port}"
}

PgSQL_Set_Remote()
{
	local Pg_Hba_Config="${PgSQL_Data_Dir}"/pg_hba.conf
	local Pg_Config="${PgSQL_Data_Dir}"/postgresql.conf
	local Host_All='host all all 0.0.0.0/0 trust'
	local Host_Replication='host replication all 0.0.0.0/0 trust'
	local Listen_Addr="listen_addresses = '*'"

	grep "${Host_All}" "${Pg_Hba_Config}" >/dev/null || echo ''${Host_All}'' >> "${Pg_Hba_Config}"
	grep "${Host_Replication}" "${Pg_Hba_Config}" >/dev/null || echo ''${Host_Replication}'' >> "${Pg_Hba_Config}"
	grep "^${Listen_Addr}" "${Pg_Config}" >/dev/null || echo ''${Listen_Addr}'' >> "${Pg_Config}"
}

PgSQL_Remove_Remote()
{
	local Pg_Hba_Config="${PgSQL_Data_Dir}"/pg_hba.conf
	local Pg_Config="${PgSQL_Data_Dir}"/postgresql.conf

	sed -i '/host[[:space:]]*all[[:space:]]*all[[:space:]]*0.0.0.0\/0[[:space:]]*trust/d' ${Pg_Hba_Config}
	sed -i '/host[[:space:]]*replication[[:space:]]*all[[:space:]]*0.0.0.0\/0[[:space:]]*trust/d' ${Pg_Hba_Config}
	sed -i '/^listen_address.*/d' ${Pg_Config}
}

PgSQL_Install_Configure_And_Make_Install()
{
	echo "${lang_install_start_configure}"
	./configure --prefix=${PgSQL_Install_Dir}

	echo "${lang_start_make_install}"
	Make_Install
}

PgSQL_Common_Install()
{
	echo "${lang_add_user} postgresql..."
	PgSQL_Add_User_Postgres || return 1

	PgSQL_Tar_And_Cd_Sourcefile
	if ! Check_Up;then
		echo "${lang_dir_not_find}"
		return 1
	fi

	echo "${lang_start_make_install}"
	PgSQL_Install_Configure_And_Make_Install
	if ! Check_Up;then
		echo "${lang_make_install_fail}"
		return 1
	fi
}

PgSQL_Sec_Setting()
{
	echo "${lang_start_configure}"
	
	echo "${lang_create_data_dir}"
	PgSQL_Check_Data_Dir
	if Check_Up;then
		echo "${lang_create_success}"
	else
		echo "${lang_create_fail}"
		return 1
	fi

	echo "${lang_add_bin_to_path}"
	PgSQL_Add_Bin_To_Path
	if Check_Up;then
		echo "${lang_confighure_success}"
	else
		echo "${lang_confighure_fail}"
		return 1
	fi

	echo "${lang_add_init}"
	PgSQL_Add_Init_D
	if Check_Up;then
		echo "${lang_add_success}"
	else
		echo "${lang_add_fail}"
		return 1
	fi

	echo "${lang_add_systemd_service}"
	PgSQL_Add_Systemd_Service
	if Check_Up;then
		echo "${lang_add_success}"
	else
		echo "${lang_add_fail}"
		return 1
	fi

	echo "${lang_add_auto_start}"
    Set_Startup pgsql
    if Check_Up;then
		echo "${lang_confighure_success}"
	else
		echo "${lang_confighure_fail}"
		return 1
	fi

	echo "${lang_init_data}"
	su - postgres -c "/usr/local/pgsql/bin/initdb -D /data/pgsql"
	if Check_Up;then
		echo "${lang_init_success}"
	else
		echo "${lang_init_fail}"
		return 1
	fi
}

PgSQL_Install_Finish()
{
	if Check_Equal ${Install_Env} 'pro';then
        Rm_Dir "${current_dir}/src/postgresql-${PgSQL_Install_Ver}"
    fi
}

PgSQL_Check_Config()
{
    echo "${lang_check_configure_start}: PgSQL_Install_Ver..."
    if Check_Empty ${PgSQL_Install_Ver};then
        local PgSQL_Default_Install_Ver=13.4
        echo "${lang_check_configure_empty_use_default}: ${PgSQL_Default_Install_Ver}"
        PgSQL_Install_Ver=${PgSQL_Default_Install_Ver}
        read -p  "${lang_install_final_confirm}"
    fi

    echo "${lang_check_configure_start}: PgSQL_Install_Dir..."
    if Check_Empty ${PgSQL_Install_Dir};then 
        local PgSQL_Default_Install_Dir='/usr/local/pgsql'
        echo "${lang_check_configure_empty_use_default}: ${PgSQL_Default_Install_Dir}"
        PgSQL_Install_Dir=${PgSQL_Default_Install_Dir}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_check_configure_start}: PgSQL_Port..."
    if Check_Empty ${PgSQL_Port};then 
        local PgSQL_Default_Port=5432
        echo "${lang_check_configure_empty_use_default}: ${PgSQL_Default_Port}"
        PgSQL_Port=${PgSQL_Default_Port}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_interface_used_check}..."
    if ! Check_Empty ${PgSQL_Port};then
        if Check_Interface_Used ${PgSQL_Port} ;then
            echo "${PgSQL_Port} ${lang_used_reconfig}: PgSQL_Port..."
            return 1
        else
            echo "${lang_check_configured_pass}"
        fi
    fi
}

PgSQL_Install()
{
	Echo_Green "${lang_install_start_app} PostgreSQL ${PgSQL_Install_Ver}"
	
	if PgSQL_Check_Installed; then
        echo "${lang_installed_already} PostgreSQL, ${lang_no_need_install}"
    else
    	echo "${lang_check_configure_start} make version"
		if ! PgSQL_Check_Need_Make_Ver;then
			return 1
		fi

		echo "${lang_check_configure_start} install need file"
		if ! PgSQL_Check_Install_Need_File;then
			return 1
		fi

		PgSQL_Check_Config  
        if Check_Up;then
            echo "${lang_all_configure_pass}"
        else
            echo "${lang_configure_error}"
            return 1
        fi

    	PgSQL_Install_Depend
		echo "${lang_dependency_succeeded}"

        PgSQL_Get_Sourcefile
        if Check_Up;then
            echo "${lang_download_success}"
        else
            echo "${lang_download_not_found}"
            return 1
        fi

        PgSQL_Common_Install
        if Check_Up;then
            echo "${lang_install_success}"
        else
            echo "${lang_install_fail},${lang_install_rollback}"
            PgSQL_Uninstall
            return 1
        fi

        PgSQL_Sec_Setting
        if Check_Up;then
            echo "${lang_confighure_success}"
        else
            echo "${lang_confighure_fail}，${lang_install_rollback}"
            PgSQL_Uninstall
            return 1
        fi

        if Check_Equal "${PgSQL_Enable_Remote}" 'y';then
            PgSQL_Set_Remote
            PgSQL_Enable_Remote_Port
        fi

        PgSQL_Install_Finish

        StartOrStop start pgsql
		Echo_Green "====== PostgreSQL install completed ======"
        Echo_Smile "PostgreSQL ${lang_install_success} !"
    fi
}

PgSQL_Uninstall()
{
    if PgSQL_Check_Installed; then
        Echo_Red "${lang_uninstall_start} PostgreSQL"
        sleep 1
        StartOrStop stop pgsql
        sleep 3
        PgSQL_Remove_Init_D
        PgSQL_Remove_Systemd_Service
        PgSQL_Disable_Remote_Port
        PgSQL_Remove_Bin_From_Path
        PgSQL_Remove_Data_Dir
        Rm_Dir "${PgSQL_Install_Dir}"
        PgSQL_Del_User_Postgres
    fi
}