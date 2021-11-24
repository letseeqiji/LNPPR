# Copyright (C) 2020 - 2021 LetSeeQiJi <wowiwo@yeah.net>
#
# This file is part of the LNPPR script.
#
# LNPPR is a powerful bash script for the installation of
# Nodejs + Nginx + Rails + MySQL/MySQLQL + Redis and so on.
# You can install Nginx + Rails + MySQL/MySQLql in an very easy way.
# Just need to edit the install.conf file to choose what you want to install before installation.
# And all things will be done in a few minutes.
#
# Website:  https://bossesin.cn
# Github:   https://github.com/letseeqiji/LNPPR
MySQL_Image_Port=3306
Env_File_Dir="${Env_Dir}/env_file"

MySQL_Image_Pull()
{
    Docker_Image_Pull "${MySQL_Img}" "${MySQL_Default_Ver}" || return 1
}

#.env/development/mysql
    # MYSQL_USER: 'lnppr'
    # MYSQL_PASSWORD: '123456'
    # MYSQL_ROOT_PASSWORD: "123456"
    # MYSQL_DATABASE="myapp_development"
#.env/development/web
    # DATABASE_HOST=mysql
MySQL_Make_Env()
{
    Make_Dir "${Env_File_Dir}"
    echo "DATABASE_HOST=${MySQL_Host}" > "${Env_File_Dir}/${Rails_Service}"
    cat > "${Env_File_Dir}/${MySQL_Host_File}" <<EOF
MYSQL_USER="${MySQL_User}"
MYSQL_PASSWORD="${MySQL_Passwd}"
MYSQL_ROOT_PASSWORD="${MySQL_Root_Passwd}"
MYSQL_DATABASE="${App_Name}_${Rails_ENV}"
EOF
}

MySQL_Make_Mycnf()
{
    local MySQL_ENV_Conf_Dir="${App_Dir}/${Env_Dir}/mysql/conf"
    local Mycnf="${MySQL_ENV_Conf_Dir}/my.cnf"
    Make_Dir "${MySQL_ENV_Conf_Dir}"
    if ! Check_Up;then
        echo "mkdir ${MySQL_ENV_Conf_Dir} error"
        return 1
    fi
    Check_File_Exist "${Mycnf}" && Back_Up_File "${Mycnf}"
    cat >"${Mycnf}"<<EOF
[mysqld]
user=root
default-storage-engine=${MySQL_Default_Storage_Engine}
character-set-server=${MySQL_Default_Character}
[client]
default-character-set=${MySQL_Default_Character}
[mysql]
default-character-set=${MySQL_Default_Character}
EOF
}

MySQL_Make_Init_SQL()
{
    local MySQL_ENV_Init_Dir="${App_Dir}/${Env_Dir}/mysql/init"
    local MySQL_Init_SQL="${MySQL_ENV_Init_Dir}/init.sql"

    Make_Dir "${MySQL_ENV_Init_Dir}"
    if ! Check_Up;then
        echo "mkdir ${MySQL_ENV_Init_Dir} error"
        return 1
    fi

    Check_File_Exist "${MySQL_Init_SQL}" && Back_Up_File "${MySQL_Init_SQL}"
    cat>"${MySQL_Init_SQL}"<<EOF
-- you can add sql here
EOF
}

#     web:
#         depends_on:
#         - mysql
#         env_file:
#         - .env/development/env_file/mysql
#         - .env/development/env_file/web
#     mysql:
#         image: mysql:latest
#         ports:
#         - "3306:3306"
#         command: --default-authentication-plugin=mysql_native_password
#         restart: always
#         env_file:
#         - .env/development/env_file/mysql
#         volumes:
#             - development_mysql_db_data:/var/lib/mysql
#             - ./.env/development/mysql/conf/my.cnf:/etc/my.cnf
#             - ./.env/development/mysql/init:/docker-entrypoint-initdb.d/
# volumes:
#     development_mysql_db_data:
MySQL_Add_To_Compose()
{
    local App_Compose="${App_Dir}/${Compose_File}"
    local MySQL_Img_Data_Dir="/var/lib/mysql"

    MySQL_Make_Mycnf || return 1
    MySQL_Make_Init_SQL || return 1

    #     mysql:
    #         image: mysql:latest
    #         ports:
    #         - "3306:3306"
    #         command: --default-authentication-plugin=mysql_native_password
    #         restart: always
    #         env_file:
    #         - .env/development/env_file/mysql
    #         volumes:
    #             - development_mysql_db_data:/var/lib/mysql
    #             - ./.env/development/mysql/conf/my.cnf:/etc/my.cnf
    #             - ./.env/development/mysql/init:/docker-entrypoint-initdb.d/
    # volumes:
    #     development_mysql_db_data:
    if ! grep "${MySQL_Service}:" ${App_Compose};then
        cat >> ${App_Compose} <<EOF
    ${MySQL_Service}:
        image: ${MySQL_Img}:${MySQL_Default_Ver}
EOF
        if Check_Equal "${MySQL_Enable_Remote}" 'y';then
            cat >> ${App_Compose} <<EOF
        ports:
        - "${MySQL_Remote_port}:${MySQL_Image_Port}"
EOF
        fi

        cat >> ${App_Compose} <<EOF
        command: --default-authentication-plugin=mysql_native_password
        restart: always
        env_file:
        - ${Env_File_Dir}/${MySQL_Host_File}
        volumes:
            - ${MySQL_Data_Valume}:${MySQL_Img_Data_Dir}
            - ./${Env_Dir}/mysql/conf/my.cnf:/etc/my.cnf
            - ./${Env_Dir}/mysql/init:/docker-entrypoint-initdb.d/
volumes:
    ${MySQL_Data_Valume}:
EOF
        Check_Up || return 1
    fi

    #     web:
    #         depends_on:
    #         - mysql
    #         env_file:
    #         - .env/development/env_file/mysql
    #         - .env/development/env_file/web
    # if "web:"  exit
    if grep "${Rails_Service}" ${App_Compose};then
        # if can not find "- .env/development/web"
        if ! grep -qE "\- ${Env_File_Dir}/${Rails_Service}" ${App_Compose};then
            # find the parallel web section ; this does not surpot the last section
            aim=$(sed -r -n '/'${Rails_Service}'/,/^ {0,4}[^ \n]+/p' ${App_Compose} | tail -1)
            sed -i "/${aim}/i |        env_file:|"  ${App_Compose}
            sed -i "/${aim}/i |        - ${Env_File_Dir}/${MySQL_Host_File}|"  ${App_Compose}
            sed -i "/${aim}/i |        - ${Env_File_Dir}/${Rails_Service}|"  ${App_Compose}
            sed -i  "s/|//g"  ${App_Compose}
        fi
    fi
}

MySQL_Make_Rails_DbConfig()
{
    local Rails_Db_Config_File="${App_Dir}/config/database.yml"
    Back_Up_File ${Rails_Db_Config_File}

    cat > ${Rails_Db_Config_File} <<EOF
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV.fetch("MYSQL_USER") %>
  password: <%= ENV.fetch("MYSQL_PASSWORD") %>
  host: <%= ENV.fetch('DATABASE_HOST') %>

development:
  <<: *default
  database: ${App_Name}_development

test:
  <<: *default
  database: ${App_Name}_test

production:
  <<: *default
  database: ${App_Name}_production
EOF
}

MySQL_Enable_Remote_Port()
{
    Firewall_Enable_Port "${MySQL_Remote_port}"
    IPTables_Enable_Port "${MySQL_Remote_port}"
}

MySQL_Enable_Remote_Port()
{
    Firewall_Disable_Port "${MySQL_Remote_port}"
    IPTables_Disable_Port "${MySQL_Remote_port}"
}

# docker-compose stop web
# docker-compose build web
# docker-compose run --rm web rails db:create
# docker-compose up -d --force-recreate web