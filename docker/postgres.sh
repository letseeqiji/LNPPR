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
Postgres_Image_Port=5432

Postgres_Image_Pull()
{
    Docker_Image_Pull "${Postgres_Img}" "${Postgres_Default_Ver}" || return 1
}

Postgres_Make_Env()
{
    Make_Dir "${Env_Dir}"
    echo "DATABASE_HOST=${Postgres_Host}" > "${Env_Dir}/${Rails_Service}"
    cat > "${Env_Dir}/${Postgres_Host_File}" <<EOF
POSTGRES_USER="${Postgres_User}"
POSTGRES_PASSWORD="${Postgres_Passwd}"
POSTGRES_DB="${Postgres_Db}"
EOF
}

Postgres_Add_To_Compose()
{
    local App_Compose="${App_Dir}/${Compose_File}"
    local Postgresql_Img_Data_Dir="/var/lib/postgresql/data"

    if grep "${Rails_Service}" ${App_Compose};then
        if ! grep -qE "\- ${Env_Dir}/${Rails_Service}" ${App_Compose};then
            aim=$(sed -r -n '/'${Rails_Service}'/,/^ {4}[^ \n]+/p' ${App_Compose} | tail -1)
            sed -i "/${aim}/i |        env_file:|"  ${App_Compose}
            sed -i "/${aim}/i |        - ${Env_Dir}/${Postgres_Host_File}|"  ${App_Compose}
            sed -i "/${aim}/i |        - ${Env_Dir}/${Rails_Service}|"  ${App_Compose}
            sed -i  "s/|//g"  ${App_Compose}
        fi
    fi
    if ! grep "${Postgres_Service}:" ${App_Compose};then
        cat >> ${App_Compose} <<EOF
    ${Postgres_Service}:
        image: ${Postgres_Img}:${Postgres_Default_Ver}
        restart: always
EOF
        if Check_Equal "${Postgres_Enable_Remote}" 'y';then
            cat >> ${App_Compose} <<EOF
        ports:
        - "${Postgres_Remote_port}:${Postgres_Image_Port}"
EOF
        fi
        cat >> ${App_Compose} <<EOF
        env_file:
        - ${Env_Dir}/${Postgres_Host_File}
        volumes:
        - ${Postgres_Data_Valume}:${Postgresql_Img_Data_Dir}
volumes:
    ${Postgres_Data_Valume}:
EOF
    fi
}

Postgres_Make_Rails_DbConfig()
{
    local Rails_Db_Config_File="${App_Dir}/config/database.yml"
    Back_Up_File ${Rails_Db_Config_File}

    cat > ${Rails_Db_Config_File} <<EOF
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch('DATABASE_HOST') %>
  username: <%= ENV.fetch('POSTGRES_USER') %>
  password: <%= ENV.fetch('POSTGRES_PASSWORD') %>
  database: <%= ENV.fetch('POSTGRES_DB') %>
  pool: 5
  statement_timeout: 5000

development:
  <<: *default
  database: ${Rails_Service}_development

test:
  <<: *default
  database: ${Rails_Service}_test

production:
  <<: *default
  database: ${Rails_Service}_production
EOF
}

Postgres_Enable_Remote_Port()
{
    Firewall_Enable_Port "${Postgres_Remote_port}"
    IPTables_Enable_Port "${Postgres_Remote_port}"
}

Postgres_Disable_Remote_Port()
{
    Firewall_Disable_Port "${Postgres_Remote_port}"
    IPTables_Disable_Port "${Postgres_Remote_port}"
}


# docker-compose stop web
# docker-compose build web
# docker-compose run --rm web rails db:create
# docker-compose up -d --force-recreate web