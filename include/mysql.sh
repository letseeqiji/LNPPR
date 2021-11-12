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

MySQL_Check_Installed()
{
    [[ -s ${Mysql_Install_Dir}/bin/mysql && -s ${Mysql_Install_Dir}/bin/mysqld_safe && -s /etc/my.cnf ]]
}

MySQL_Get_Install_Base_Ver()
{
    if echo "${Mysql_Install_Ver}" | grep -Eqi '^5.7.'; then
        MySQL_Install_Base_Ver=57
    elif echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.'; then
        MySQL_Install_Base_Ver=80
    else
        return 1
    fi
}

Check_DB()
{
    if MySQL_Check_Installed; then
        MySQL_Bin="${Mysql_Install_Dir}/bin/mysql"
    else
        return 1
    fi
}

Do_Query()
{
    local Sql=$1
    Check_DB && ${MySQL_Bin} -uroot -p${MySQL_Root_Passwd} -hlocalhost -e "${Sql}"
}

Mysql_Optimize()
{
    local MyCnf=${MySQL_DSYSCONFDIR}/my.cnf
    local MemTotal=$(free -m | grep Mem | awk '{print  $2}')
    local per=0

    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -lt 2048 ]]; then
        per=1
    elif [[ ${MemTotal} -ge 2048 && ${MemTotal} -lt 4096 ]]; then
        per=2
    elif [[ ${MemTotal} -ge 4096 && ${MemTotal} -lt 8192 ]]; then
        per=3
    elif [[ ${MemTotal} -ge 8192 && ${MemTotal} -lt 16384 ]]; then
        per=4
    elif [[ ${MemTotal} -ge 16384 && ${MemTotal} -lt 32768 ]]; then
        per=5
    elif [[ ${MemTotal} -ge 32768 ]]; then
        per=6
    fi

    if [[ ${per} -gt 0 ]];then
        sed -i "s#^key_buffer_size.*#key_buffer_size = "$[32*(2**($per-1))]"M#" ${MyCnf}
        sed -i "s#^table_open_cache.*#table_open_cache = "$[128*(2**($per-1))]"#" ${MyCnf}
        if [ $per -eq 1 ];then
            sed -i "s#^sort_buffer_size.*#sort_buffer_size = 768K#" ${MyCnf}
            sed -i "s#^read_buffer_size.*#read_buffer_size = 768K#" ${MyCnf}
        else
            sed -i "s#^sort_buffer_size.*#sort_buffer_size = "$[1*(2**($per-2))]"M#" ${MyCnf}
            sed -i "s#^read_buffer_size.*#read_buffer_size = "$[1*(2**($per-2))]"M#" ${MyCnf}
        fi
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = "$[8*(2**($per-1))]"M#" ${MyCnf}
        sed -i "s#^thread_cache_size.*#thread_cache_size = "$[16*(2**($per-1))]"#" ${MyCnf}
        sed -i "s#^query_cache_size.*#query_cache_size = "$[16*(2**($per-1))]"M#" ${MyCnf}
        sed -i "s#^tmp_table_size.*#tmp_table_size = "$[32*(2**($per-1))]"M#" ${MyCnf}
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = "$[128*(2**($per-1))]"M#" ${MyCnf}
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = "$[32*(2**($per-1))]"M#" ${MyCnf}
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = "$[1000*(2**($per-1))]"#" ${MyCnf}
    fi
}

MySQL_Check_Data_Dir()
{
    if Check_Dir_Exist "${MySQL_Data_Dir}"; then
        datetime=$(date +"%Y%m%d%H%M%S")
        Make_Dir /root/mysql-data-dir-backup${datetime}/
        Copy_File ${MySQL_Data_Dir}/* /root/mysql-data-dir-backup${datetime}/
        Rm_Dir ${MySQL_Data_Dir}/*
    else
        Make_Dir ${MySQL_Data_Dir}
    fi
}

MySQL_User_Add()
{
    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql
}

MySQL_User_Del()
{
    Delete_User mysql
}

MySQL_Initialize_Insecure()
{
    MySQL_Check_Data_Dir
    chown -R mysql:mysql ${MySQL_Data_Dir}
    ${Mysql_Install_Dir}/bin/mysqld --initialize-insecure --basedir=${Mysql_Install_Dir} --datadir=${MySQL_Data_Dir} --user=mysql
    chgrp -R mysql ${Mysql_Install_Dir}/.
}

MySQL_Add_Init_Service()
{
    local Etc_Init_Mysql=/etc/init.d/mysql
    local Etc_Systemd_Mysql_Service=/etc/systemd/system/mysql.service
    Copy_File support-files/mysql.server "${Etc_Init_Mysql}"
    Copy_File ${current_dir}/init.d/mysql.service "${Etc_Systemd_Mysql_Service}"
    chmod 755 "${Etc_Init_Mysql}"
    Set_Startup mysql
}

MySQL_Remove_Init_Service()
{
    local Etc_Init_Mysql=/etc/init.d/mysql
    local Etc_Systemd_Mysql_Service=/etc/systemd/system/mysql.service
    Rm_File "${Etc_Init_Mysql}"
    Rm_File "${Etc_Systemd_Mysql_Service}"
    Remove_Startup mysql
}

MySQL_Ldconfig()
{
    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    ${Mysql_Install_Dir}/lib
    /usr/local/lib
EOF
    ldconfig
    Ln_S "${Mysql_Install_Dir}"/lib/mysql /usr/lib/mysql
    Ln_S "${Mysql_Install_Dir}"/include/mysql /usr/include/mysql
}

MySQL_Delete_Ldconfig()
{
    Rm_File /etc/ld.so.conf.d/mysql.conf
}

MySQL_Lns_Bin()
{
    Ln_S "${Mysql_Install_Dir}"/bin/mysql /usr/bin/mysql
    Ln_S "${Mysql_Install_Dir}"/bin/mysqldump /usr/bin/mysqldump
    Ln_S "${Mysql_Install_Dir}"/bin/myisamchk /usr/bin/myisamchk
    Ln_S "${Mysql_Install_Dir}"/bin/mysqld_safe /usr/bin/mysqld_safe
    Ln_S "${Mysql_Install_Dir}"/bin/mysqlcheck /usr/bin/mysqlcheck
}

MySQL_Admin_Set_Root_Passwd()
{
    /usr/bin/expect<<EOF
    set time 30
    spawn ${Mysql_Install_Dir}/bin/mysqladmin -uroot -p password "${MySQL_Root_Passwd}"
    expect {
    "Enter password:" { send "\r"; exp_continue }
    }
EOF
}

MySQL_Enable_Remote_Port()
{
    Firewall_Enable_Port "${MySQL_Port}"
    IPTables_Enable_Port "${MySQL_Port}"
}

MySQL_Disable_Remote_Port()
{
    Firewall_Disable_Port "${MySQL_Port}"
    IPTables_Disable_Port "${MySQL_Port}"
}

MySQL_Set_Remote()
{
    echo "${lang_set_remote}"
    if  echo "${Mysql_Install_Ver}" | grep -Eqi '^5.7.'; then
        Do_Query "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MySQL_Root_Passwd}' WITH GRANT OPTION;"
    elif  echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.'; then
        Do_Query "create user 'root'@'%' identified by '${MySQL_Root_Passwd}';"
        Do_Query "grant all privileges on *.* to root@'%' with grant option;"
    fi
    Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."  
}

MySQL_Remove_Remote()
{
    echo "${lang_set_remote}"
    Do_Query "Delete From mysql.user Where User='root' And Host='%';"
    Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."   
}

MySQL_Update_Root_Passwd()
{
    Do_Query ""
    if Check_Up; then
        echo "OK, ${lang_root_pwd_porrect}."
        echo "${lang_update_root_pwd}"
        if  echo "${Mysql_Install_Ver}" | grep -Eqi '^5.7.'; then
            Do_Query "UPDATE mysql.user SET authentication_string=PASSWORD('${MySQL_Root_Passwd}') WHERE User='root';"
        elif  echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.'; then
            Do_Query "SET PASSWORD FOR 'root'@'localhost' = '${MySQL_Root_Passwd}';"
        fi
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
        echo "${lang_reload_privilege}..."
        ${Mysql_Install_Dir}/bin/mysqladmin flush-privileges
        Check_Up && echo "${lang_success}..." || echo "${lang_fail}..."
        StartOrStop restart mysql
    fi
}

MySQL_Sec_Setting()
{
    if Check_Dir_Exist "/procvz"; then
        ulimit -s unlimited
    fi

    StartOrStop start mysql
    MySQL_Lns_Bin
    StartOrStop restart mysql
    sleep 2

    MySQL_Admin_Set_Root_Passwd
    StartOrStop restart mysql
    MySQL_Update_Root_Passwd
}

MySQL_Cmake_57()
{
    cmake -DCMAKE_INSTALL_PREFIX=${Mysql_Install_Dir} -DSYSCONFDIR=${MySQL_DSYSCONFDIR} -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=${MySQL_DEFAULT_CHARSET} -DDEFAULT_COLLATION=${MySQL_DEFAULT_CHARSET}_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1  -DWITH_BOOST=boost
}

MySQL_Create_Mycnf_57()
{
    cat > ${MySQL_DSYSCONFDIR}/my.cnf<<EOF
[client]  
password   = ${MySQL_Root_Passwd}
port        = ${MySQL_Port}
socket      = ${MySQL_Sock}

[mysqld]
port        = ${MySQL_Port}
socket      = ${MySQL_Sock}
datadir = ${MySQL_Data_Dir}
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
performance_schema_max_table_instances = 500

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
early-plugin-load = ""

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_data_home_dir = ${MySQL_Data_Dir}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${MySQL_Data_Dir}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer_size = 2M
write_buffer_size = 2M

[mysqlhotcopy]
interactive-timeout

EOF
}

MySQL_Cmake_80()
{
    cmake .. -DCMAKE_INSTALL_PREFIX=${Mysql_Install_Dir} -DSYSCONFDIR=${MySQL_DSYSCONFDIR} -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DFORCE_INSOURCE_BUILD=1 -DWITH_BOOST=${current_dir}/src/mysql-8.0.27/boost 
}

MySQL_Create_Mycnf_80()
{
    cat > ${MySQL_DSYSCONFDIR}/my.cnf<<EOF
[client]
password   = ${MySQL_Root_Passwd}
port        = ${MySQL_Port}
socket      = ${MySQL_Sock}

[mysqld]
port        = ${MySQL_Port}
socket      = ${MySQL_Sock}
datadir = ${MySQL_Data_Dir}
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
tmp_table_size = 16M
performance_schema_max_table_instances = 500

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535
default_authentication_plugin = mysql_native_password

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
binlog_expire_logs_seconds = 864000
early-plugin-load = ""

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_data_home_dir = ${MySQL_Data_Dir}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${MySQL_Data_Dir}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer_size = 2M
write_buffer_size = 2M

[mysqlhotcopy]
interactive-timeout

EOF
}

MySQL_Delete_Mycnf()
{
    Rm_File ${MySQL_DSYSCONFDIR}/my.cnf
}

MySQL_Common_Install()
{
    local MyTarFile=mysql-boost-${Mysql_Install_Ver}.tar.gz
    MySQL_Get_Install_Base_Ver || return 1
    Echo_Smile "${lang_install_start_app} mysql-boost-${Mysql_Install_Ver}"
    cd ${current_dir}/src
    if ! Check_File_Exist ${MyTarFile};then
        echo "${lang_file_not_find}: ${MyTarFile}, ${lang_dir_check}..."
        return 1
    else
        Check_Equal "${Install_Env}" 'pro' && Rm_Dir mysql-${Mysql_Install_Ver}
        Tar ${MyTarFile}
        cd mysql-${Mysql_Install_Ver}
    fi
    Back_Up_File ${MySQL_DSYSCONFDIR}/my.cnf

    if Check_Equal "${MySQL_Install_Base_Ver}" '80';then
        Check_Equal ${Install_Env} 'pro' && Rm_Dir bld
        Make_Dir bld
        cd bld
    fi
    MySQL_Cmake_${MySQL_Install_Base_Ver}
    Make_Install
    MySQL_User_Add
    MySQL_Create_Mycnf_${MySQL_Install_Base_Ver}
    Mysql_Optimize
    MySQL_Initialize_Insecure
    MySQL_Add_Init_Service
    MySQL_Ldconfig
}

MySQL_Check_Config()
{
    echo "${lang_check_configure_start}: Mysql_Install_Ver..."
    if Check_Empty ${Mysql_Install_Ver};then
        local Mysql_Default_Install_Ver=5.7.35
        echo "${lang_check_configure_empty_use_default}: mysql-boost-${Mysql_Default_Install_Ver}"
        Mysql_Install_Ver=${Mysql_Default_Install_Ver}
        read -p  "${lang_install_final_confirm}"
    fi

    if ! (echo "${Mysql_Install_Ver}" | grep -Eqi '^5.7.') && ! (echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.'); then
        echo "${lang_enable_version}: MySQL-5.7.x | MySQL-8.0.x "
        echo "${lang_reconfig}: Mysql_Install_Ver"
        return 1
    fi

    echo "${lang_check_configure_start}: Mysql_Install_Dir..."
    if Check_Empty ${Mysql_Install_Dir};then 
        local Mysql_Default_Install_Dir='/usr/local/mysql'
        echo "${lang_check_configure_empty_use_default}: ${Mysql_Default_Install_Dir}"
        Mysql_Install_Dir=${Mysql_Default_Install_Dir}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_check_configure_start}: MySQL_Port..."
    if Check_Empty ${MySQL_Port};then 
        local Mysql_Default_Port=3306
        echo "${lang_check_configure_empty_use_default}: ${Mysql_Default_Port}"
        MySQL_Port=${Mysql_Default_Port}
    else
        echo "${lang_check_configured_pass}"
    fi

    echo "${lang_interface_used_check}..."
    if ! Check_Empty ${MySQL_Port};then
        if Check_Interface_Used ${MySQL_Port} ;then
            echo "${MySQL_Port} ${lang_used_reconfig}: MySQL_Port..."
            return 1
        else
            echo "${lang_check_configured_pass}"
        fi
    fi
    
    echo "${lang_check_configure_start}: MySQL_Root_Passwd..."
    if Check_Empty ${MySQL_Root_Passwd};then 
        local MySQL_Default_Root_Passwd='12345678'
        echo "${lang_check_configure_empty_use_default}: ${MySQL_Default_Root_Passwd}"
        MySQL_Root_Passwd=${MySQL_Default_Root_Passwd}
    else
        echo "${lang_check_configured_pass}"
    fi
    
    echo "${lang_check_configure_start}: MySQL_DSYSCONFDIR..."
    if Check_Empty ${MySQL_DSYSCONFDIR};then 
        local MySQL_Default_DSYSCONFDIR='/etc'
        echo "${lang_check_configure_empty_use_default}: ${MySQL_Default_DSYSCONFDIR}"
        MySQL_DSYSCONFDIR=${MySQL_Default_DSYSCONFDIR}
    else
        echo "${lang_check_configured_pass}"
    fi
    
    echo "${lang_check_configure_start}: MySQL_DEFAULT_CHARSET..."
    if Check_Empty ${MySQL_DEFAULT_CHARSET};then 
        local MySQL_CHARSET=utf8mb4
        echo "${lang_check_configure_empty_use_default}: ${MySQL_CHARSET}"
        MySQL_DEFAULT_CHARSET=${MySQL_CHARSET}
    else
        echo "${lang_check_configured_pass}"
    fi
    
    echo "${lang_check_configure_start}: MySQL_Sock..."
    if Check_Empty ${MySQL_Sock};then 
        local MySQL_Default_Sock=/tmp/mysql.sock
        echo "${lang_check_configure_empty_use_default}: ${MySQL_Default_Sock}"
        MySQL_Sock=${MySQL_Default_Sock}
    else
        echo "${lang_check_configured_pass}"
    fi
}

MySQL_Get_Sourcefile()
{
    local MySQL_Source_File=mysql-boost-${Mysql_Install_Ver}.tar.gz
    cd ${current_dir}/src/
    if echo "${Mysql_Install_Ver}" | grep -Eqi '^5.7.'; then
        Check_File_Exist ${MySQL_Source_File} 'not_null' || wget ${MySQL_Base_Download_Url}/MySQL-5.7/${MySQL_Source_File}
    elif  echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.'; then
        Check_File_Exist ${MySQL_Source_File} 'not_null' || wget ${MySQL_Base_Download_Url}/MySQL-8.0/${MySQL_Source_File}
    else
        return 1
    fi
}

MySQL_Install_Depend()
{
    if [ "${PM}" = 'apt' ];then
        local Packets=(build-essential cmake bison libncurses5-dev libssl-dev pkg-config expect git wget lsof)
    elif Check_Equal "${PM}" 'yum';then
        local Packets=(cmake gcc gcc-c++ ncurses ncurses-devel libaio-devel openssl openssl-devel expect git wget lsof)
    else
        return 1
    fi

    for packet in "${Packets[@]}"
    do
        echo ${packet}
        ${PM} install "${packet}" -y 
    done
}

MySQL_Check_CMPT()
{
    if echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.'; then
        if echo "${Ubuntu_Version}" | grep -Eqi "^1[0-7]\." || echo "${Debian_Version}" | grep -Eqi "^[4-8]" || echo "${Raspbian_Version}" | grep -Eqi "^[4-8]" || echo "${CentOS_Version}" | grep -Eqi "^[4-7]"  || echo "${RHEL_Version}" | grep -Eqi "^[4-7]" || echo "${Fedora_Version}" | grep -Eqi "^2[0-3]"; then
            return 1
        fi
    fi
}

MySQL_Install_Finish()
{
    if Check_Equal ${Install_Env} 'pro';then
        Rm_Dir ${current_dir}/src/mysql-${Mysql_Install_Ver}
    fi
}
    
MySQL_Install()
{
    MySQL_Check_CMPT
    if ! Check_Up;then
        Echo_Red "${lang_mysql_need_new_os}"
        return 1
    fi

    if MySQL_Check_Installed; then
        echo "${lang_installed_already} mysql, ${lang_no_need_install}"
    else
        MySQL_Check_Config  
        if Check_Up;then
            echo "${lang_all_configure_pass}"
        else
            echo "${lang_configure_error}"
            return 1
        fi

        MySQL_Install_Depend
        if Check_Up;then
            echo "${lang_dependency_succeeded}"
        else
            echo "${lang_dependency_fail}"
            return 1
        fi

        MySQL_Get_Sourcefile
        if Check_Up;then
            echo "${lang_download_success}"
        else
            echo "${lang_download_not_found}"
            return 1
        fi

        MySQL_Common_Install
        if Check_Up;then
            echo "${lang_install_success}"
        else
            echo "${lang_install_fail},${lang_install_rollback}"
            MySQL_Uninstall
            return 1
        fi
        
        MySQL_Sec_Setting
        if Check_Up;then
            echo "${lang_confighure_success}"
        else
            echo "${lang_confighure_fail}，${lang_install_rollback}"
            MySQL_Uninstall
            return 1
        fi

        if Check_Equal "${MySQL_Enable_Remote}" 'y';then
            MySQL_Set_Remote
            MySQL_Enable_Remote_Port
        fi

        MySQL_Install_Finish
        Echo_Green "====== MySQL install completed ======"
        Echo_Smile "MySQL ${lang_install_success} !"
    fi
}

MySQL_Uninstall()
{
    if MySQL_Check_Installed; then
        Echo_Red "${lang_uninstall_start} mysql"
        sleep 1
        StartOrStop stop mysql
        sleep 3
        MySQL_Remove_Init_Service
        MySQL_Delete_Ldconfig
        MySQL_Delete_Mycnf
        Rm_Dir ${Mysql_Install_Dir}
        # Back_Up_File "${MySQL_Data_Dir}" "/root"
        Rm_Dir ${MySQL_Data_Dir}
        Rm_File ${MySQL_Sock}
        MySQL_User_Del
        MySQL_Disable_Remote_Port
    fi
}
