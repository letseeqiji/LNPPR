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
Redis_Image_Port=6379

Redis_Img_Pull()
{
    Docker_Image_Pull "${Redis_Img}" "${Redis_Default_Ver}" || return 1
}

Redis_Add_To_Composess()
{
    local App_Compose="${App_Dir}/${Compose_File}"

    if ! grep -qr "^[[:space:]]*${Redis_Service}:" "${App_Compose}";then
        cat >> "${App_Compose}" <<EOF
    ${Redis_Service}:
        image: redis:${Redis_Default_Ver}
        restart: always
        command: redis-server --requirepass ${Redis_Remote_Passwd}
EOF
        if Check_Equal "${Redis_Enable_Remote}" 'y';then
            cat >> ${App_Compose} <<EOF
        ports:
        - "${Redis_Remote_port}:${Redis_Image_Port}"
EOF
        fi
    fi

     grep -qr '^[[:space:]]*redis:' "${App_Compose}" || return 1
}

Redis_Remove_From_Compose()
{
    Yml_Del_Section_And_Children "${App_Compose}" "redis"
}

Redis_Enable_Remote_Port()
{
    Firewall_Enable_Port "${Redis_Remote_port}"
    IPTables_Enable_Port "${Redis_Remote_port}"
}

Redis_Disable_Remote_Port()
{
    Firewall_Disable_Port "${Redis_Remote_port}"
    IPTables_Disable_Port "${Redis_Remote_port}"
}

Redis_Add_Rails_Initalizer()
{
    local Redis_Initaliz="${App_Dir}/config/initializers/redis.rb"
    Check_File_Exist "${Redis_Initaliz}" && Back_Up_File "${Redis_Initaliz}"
    cat > "${Redis_Initaliz}"<<EOF
\$redis = Redis.new(:host=>'${Redis_Service}', :port=>${Redis_Remote_port}, :password=>'${Redis_Remote_Passwd}')
EOF
}

