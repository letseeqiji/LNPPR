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
Rails_Base_Dockerfile="${current_dir}/config/dockerfiles/lnppr_rails/Dockerfile"
Lnppr_Rails_Img="lnppr/rails:${Ruby_Default_Ver}-${Rails_Default_Ver}"
Rails_Docker_Workdir="/usr/src/app"
Rails_Img="lnppr/rails"
Rails_Img_Port=3000


Rails_Install_Depend()
{
    Check_Command expect || ${PM} install expect -y
    Check_Command wget || ${PM} install wget -y
    Check_Command curl || ${PM} install curl -y
}

# make ruby+rails image
# ==========================================
Rails_Make_Base_Dockerfile()
{
    Back_Up_File ${Rails_Base_Dockerfile}
    Check_Equal "${Rails_Default_Ver}" 'latest' && Rails_Default_Ver='6.1.4'

    cat > ${Rails_Base_Dockerfile} <<EOF
FROM ruby:${Ruby_Default_Ver}
RUN gem sources -r https://rubygems.org/ -a https://${Ruby_Registry}/ \
&& apt-get update -yqq \
&& apt-get install -yqq --no-install-recommends nodejs \
&& apt-get install -yqq --no-install-recommends npm \
&& npm conf set registry https://${Node_Registry} --global \
&& npm install -g yarn \
&& gem install rails -v=${Rails_Default_Ver} \
&& gem install puma
EOF

    if Check_Up;then
        echo "Dockerfile ${lang_create_success}"
    else
        echo "Dockerfile ${lang_create_fail}"
        return 1
    fi
}
# 只在创建新的 ruby+rails版本的时候运行
Rails_Make_Base_Docker_Img()
{
    if ! Check_Command docker;then
        echo "${lang_no_install} docker"
        return 1
    fi

    if Docker_Check_Image_Exist "lnppr/rails" "${Ruby_Default_Ver}-${Rails_Default_Ver}";then
        echo "lnppr/rails:${Ruby_Default_Ver}-${Rails_Default_Ver} has already exits!"
    else
        Rails_Make_Base_Dockerfile
        docker build -f ${Rails_Base_Dockerfile} -t ${Lnppr_Rails_Img} .
    fi
}

Rails_Init_Env()
{
    Rails_Install_Depend || return 1
    if ! Docker_Check_Image_Exist lnppr/rails "${Ruby_Default_Ver}-${Rails_Default_Ver}";then
        if ! Docker_Check_Image_Exist ruby ${Ruby_Default_Ver};then
            docker pull ruby:${Ruby_Default_Ver}
            if Docker_Check_Image_Exist ruby ${Ruby_Default_Ver};then
                echo "ruby:${Ruby_Default_Ver} pulled OK"
            else
                echo "ruby:${Ruby_Default_Ver} pulled fail"
                return 1
            fi
        fi
        Rails_Make_Base_Docker_Img
        if Docker_Check_Image_Exist lnppr/rails "${Ruby_Default_Ver}-${Rails_Default_Ver}";then
            echo "lnppr/rails:${Ruby_Default_Ver}-${Rails_Default_Ver} make OK"
        else
            echo "lnppr/rails:${Ruby_Default_Ver}-${Rails_Default_Ver} make fail"
            return 1
        fi
    fi
    if Check_Equal $Rails_New_Option_Redis 'redis';then
        if ! Docker_Check_Image_Exist redis ${Redis_Default_Ver};then
            docker pull redis:${Redis_Default_Ver}
            if Docker_Check_Image_Exist redis ${Redis_Default_Ver};then
                echo "redis:${Redis_Default_Ver} pulled OK"
            else
                echo "redis:${Redis_Default_Ver} pulled fail"
                return 1
            fi
        fi
    fi
    if Check_Equal $Rails_New_Option_Database 'mysql';then
        if ! Docker_Check_Image_Exist mysql ${MySQL_Default_Ver};then
            docker pull mysql:${MySQL_Default_Ver}
            if Docker_Check_Image_Exist mysql ${MySQL_Default_Ver};then
                echo "mysql:${MySQL_Default_Ver} pulled OK"
            else
                echo "mysql:${MySQL_Default_Ver} pulled fail"
                return 1
            fi
        fi
    fi
    if Check_Equal $Rails_New_Option_Database 'postgresql';then
        if ! Docker_Check_Image_Exist postgres ${Postgres_Default_Ver};then
            docker pull postgres:${Postgres_Default_Ver}
            if Docker_Check_Image_Exist postgres ${Postgres_Default_Ver};then
                echo "postgres:${Postgres_Default_Ver} pulled OK"
            else
                echo "postgres:${Postgres_Default_Ver} pulled fail"
                return 1
            fi
        fi
    fi
}

# about Project 
# ===========================================
Rails_Make_New_Options()
{
    local Rails_New_Options=""
    local Database=("mysql" "postgresql" "sqlite3" "oracle" "sqlserver" "jdbcmysql" "jdbcsqlite3" "jdbcpostgresql" "jdbc")
    local Webpacker=("WEBPACK" "react" "vue" "angular" "elm" "stimulus")
    local Api=("--api" "--no-api")
    local Skip_Test=("--skip-test" "--no-skip-test")
    local Minimal=("--minimal" "--no-minimal")
    local Skip_Gemfile=("--skip-gemfile" "--no-skip-gemfile")
    local Skip_Git=("--skip-git" "--no-skip-git")
    local Skip_Action_Mailer=("--skip-action-mailer" "--no-skip-action-mailer")
    local Skip_Action_Mailbox=("--skip-action-mailbox" "--no-skip-action-mailbox")
    local Skip_Action_Text=("--skip-action-text" "--no-skip-action-text")
    local Skip_Active_Record=("--skip-active-record" "--no-skip-active-record")
    local Skip_Active_Job=("--skip-active-job" "--no-skip-active-job")
    local Skip_Active_Storage=("--skip-active-storage" "--no-skip-active-storage")
    local Skip_Puma=("--skip-puma" "--no-skip-puma")
    local Skip_Action_Cable=("--skip-action-cable" "--no-skip-action-cable")
    local Skip_Javascript=("--skip-javascript" "--no-skip-javascript")
    local Skip_Turbolinks=("--skip-turbolinks" "--no-skip-turbolinks")
    local Skip_System_Test=("--skip-system-test" "--no-skip-system-test")
    local Skip_Bootsnap=("--skip-bootsnap" "--no-skip-bootsnap")
    local Skip_Webpack_Install=("--skip-webpack-install" "--no-skip-webpack-install")

    if [[ "${Database[@]}" =~ "${Rails_New_Option_Database}" ]];then
        Rails_New_Options="--database=${Rails_New_Option_Database}" || Rails_New_Options="--database=sqlite3"
    fi
    if [[ "${Webpacker[@]}" =~ "${Rails_New_Option_Webpacker}" ]];then
        Rails_New_Options="${Rails_New_Options} --webpack=${Rails_New_Option_Webpacker}"
    fi
    if [[ "${Api[@]}" =~ "${Rails_New_Option_Api}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Api}"
    fi
    if [[ "${Skip_Test[@]}" =~ "${Rails_New_Option_Skip_Test}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Test}"
    fi
    if [[ "${Minimal[@]}" =~ "${Rails_New_Option_Minimal}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Minimal}"
    fi
    if [[ "${Skip_Gemfile[@]}" =~ "${Rails_New_Option_Skip_Gemfile}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Gemfile}"
    fi
    if [[ "${Skip_Git[@]}" =~ "${Rails_New_Option_Skip_Git}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Git}"
    fi
    if [[ "${Skip_Action_Mailer[@]}" =~ "${Rails_New_Option_Skip_Action_Mailer}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Action_Mailer}"
    fi
    if [[ "${Skip_Action_Mailbox[@]}" =~ "${Rails_New_Option_Skip_Action_Mailbox}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Action_Mailbox}"
    fi
    if [[ "${Skip_Action_Text[@]}" =~ "${Rails_New_Option_Skip_Action_Text}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Action_Text}"
    fi
    if [[ "${Skip_Active_Record[@]}" =~ "${Rails_New_Option_Skip_Active_Record}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Active_Record}"
    fi
    if [[ "${Skip_Active_Storage[@]}" =~ "${Rails_New_Option_Skip_Active_Storage}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Active_Storage}"
    fi
    if [[ "${Skip_Puma[@]}" =~ "${Rails_New_Option_Skip_Puma}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Puma}"
    fi
    if [[ "${Skip_Action_Cable[@]}" =~ "${Rails_New_Option_Skip_Action_Cable}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Action_Cable}"
    fi
    if [[ "${Skip_Javascript[@]}" =~ "${Rails_New_Option_Skip_Javascript}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Javascript}"
    fi
    if [[ "${Skip_Turbolinks[@]}" =~ "${Rails_New_Option_Skip_Turbolinks}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Turbolinks}"
    fi
    if [[ "${Skip_System_Test[@]}" =~ "${Rails_New_Option_Skip_System_Test}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_System_Test}"
    fi
    if [[ "${Skip_Bootsnap[@]}" =~ "${Rails_New_Option_Skip_Bootsnap}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Bootsnap}"
    fi
    if [[ "${Skip_Webpack_Install[@]}" =~ "${Rails_New_Option_Skip_Webpack_Install}" ]];then
        Rails_New_Options="${Rails_New_Options} ${Rails_New_Option_Skip_Webpack_Install}"
    fi
    if [ ! "${Rails_New_Option_Template}" = "" ];then
        Rails_New_Options="${Rails_New_Options} --template=${Rails_New_Option_Template}"
    fi
    echo $Rails_New_Options
}

Rails_Make_Project_Dockerfile()
{
    cat > Dockerfile <<EOF
FROM ${Lnppr_Rails_Img}
LABEL ${Docker_File_Label}
COPY . ${Rails_Docker_Workdir}
WORKDIR ${Rails_Docker_Workdir}
RUN bundle
CMD ["rails", "s", "-b", "0.0.0.0"]
EOF

    if Check_Up;then
        echo "Dockerfile ${lang_create_success}"
    else
        echo "Dockerfile ${lang_create_fail}"
        return 1
    fi
}

Rails_New_App()
{
    local App_Name=$1
    echo "try to make an rails app："
    echo "install prepaire"
    Rails_Init_Env
    if Check_Up;then
        echo "everything is ok"
    else
        echo "can not prepaire the env, exit!"
        return 1
    fi
    local New_Options=$(Rails_Make_New_Options)

    if ! Check_Dir_Exist ${App_Name};then
        /usr/bin/expect<<EOF
        set timeout -1
        spawn docker run -i -t --rm -v ${PWD}:${Rails_Docker_Workdir} "${Lnppr_Rails_Img}" bash
        expect ":/#"  {send "cd ${Rails_Docker_Workdir}\r"}
        expect ":${Rails_Docker_Workdir}#" {send "rails new ${App_Name} --skip-bundle ${New_Options}\r"}
        expect ":${Rails_Docker_Workdir}#" {send "sed -i 's/rubygems.org/${Ruby_Registry}/' ${App_Name}/Gemfile\r"}
        expect ":${Rails_Docker_Workdir}#" {send "chmod 777 -Rf ${App_Name}\r"}
        expect ":${Rails_Docker_Workdir}#" {send "exit\r";exp_continue}
EOF
    fi
}

Rails_Add_Composefile_Service()
{
    if Check_Empty ${Rails_New_Option_Port};then
        Rails_New_Option_Port=${Rails_Default_Port}
    fi
    cat >> "${Compose_File}" <<EOF
    ${Rails_Service}:
        build: .
        restart: always
        ports:
        - "${Rails_New_Option_Port}:${Rails_Img_Port}"
        volumes:
        - .:${Rails_Docker_Workdir}
EOF
}

Rails_Compose_build()
{
    Compose_Build_Service ${Rails_Service}
}

Rails_Compose_Service_Ctl()
{
    local Ctrl=$1
    Compose_Ctl ${Ctrl} ${Rails_Service}
}

Rails_Compose_Add_denpends()
{
    local Depend=$1

    # this doesn't surport the last section
    aim=$(sed -r -n '/'${Rails_Service}'/,/^ {0,4}[^ ]+/p' "${Compose_File}"  | tail -1)
    if Check_Equal $(sed -r -n '/'${Rails_Service}'/,/^ {0,4}[^ ]+/{ /^ {8}depends_on/p }' "${Compose_File}") '';then
        sed -r -i "/${aim}/i  |        depends_on:|" "${Compose_File}"
    fi

    aim=$(sed -r -n "/${Rails_Service}/,/^ {0,4}[^ ]+/{/depends_on/p}" "${Compose_File}")
    sed -i "/${aim}/a |        - ${Depend}|" "${Compose_File}"
    sed -i  "s/|//g"  "${Compose_File}"
}

Rails_Add_Redis()
{
    Redis_Img_Pull || return 1
    Redis_Add_To_Composess  || return 1
    Rails_Compose_Add_denpends ${Redis_Service} || return 1
    Rails_Add_Or_Remove_Gem 'add' "redis"  || return 1
    Redis_Add_Rails_Initalizer  || return 1
}

Rails_Add_Postgres()
{
    Postgres_Image_Pull || return 1
    Postgres_Make_Env || return 1
    Postgres_Add_To_Compose || return 1
    Rails_Compose_Add_denpends ${Postgres_Service} || return 1
    Postgres_Make_Rails_DbConfig || return 1
}

Rails_Add_MySQL()
{
    MySQL_Image_Pull || return 1
    MySQL_Make_Env || return 1
    MySQL_Add_To_Compose || return 1
    Rails_Compose_Add_denpends ${MySQL_Service} || return 1
    MySQL_Make_Rails_DbConfig || return 1
}

Rails_Compose_New_App()
{
    App_Name=$1
    App_Base_Dir=$2
    App_Dir="${App_Base_Dir}/${App_Name}"

    Check_Dir_Exist ${App_Base_Dir} || Make_Dir ${App_Base_Dir}
    chmod 777 -Rf ${App_Base_Dir}

    cd ${App_Base_Dir}
    Rails_New_App ${App_Name}
    cd ${App_Name}
    cat > .dockerignore <<EOF
.git
.gitignore
log/*
tmp/*
*.swp
*.swo
EOF

    Rails_Make_Project_Dockerfile
    Compose_Make_Base_Compose_File
    Rails_Add_Composefile_Service
    chmod 777 -Rf .

    if Check_Equal $Rails_New_Option_Redis "redis";then
        Rails_Add_Redis
        if ! Check_Up;then
            echo "add redis error"
            return 1
        fi
        if Check_Equal ${Redis_Enable_Remote}, 'y';then
            echo "enable remote"
            Redis_Enable_Remote_Port
        fi
    fi

    if Check_Equal "${Rails_New_Option_Database}" "postgresql";then
        Rails_Add_Postgres
        if ! Check_Up;then
            echo "add pgsql error"
            return 1
        fi
        if Check_Equal ${Postgres_Enable_Remote}, 'y';then
            echo "enable remote"
            Postgres_Enable_Remote_Port
        fi
    fi

    if Check_Equal "${Rails_New_Option_Database}" "mysql";then
        Rails_Add_MySQL
        if ! Check_Up;then
            echo "add mysql error"
            return 1
        fi
        if Check_Equal ${MySQL_Enable_Remote}, 'y';then
            echo "enable remote"
            MySQL_Enable_Remote_Port
        fi
    fi

    Compose_Build_App
    if ! Check_Equal $Rails_New_Option_Api '--api' && ! Check_Equal $Rails_New_Option_Skip_Webpack_Install "--skip-webpack-install" ;then
        echo "run webpacker"
        docker-compose run --rm ${Rails_Service} rails webpacker:install
    fi
    echo "start ...." && sleep 1
    Compose_Up_Or_Down up -d
    if Check_Equal ${Rails_New_Option_Database} 'postgresql';then
        echo "init database"
        docker-compose run --rm ${Rails_Service} rails db:create
    fi
    docker-compose ps
}

Rails_Add_Redis_Service()
{
    Rails_Add_Redis
    docker-compose up -d ${Redis_Service}
    docker-compose logs ${Redis_Service}
    echo "redis is running！"

    docker-compose stop "${Rails_Service}"
    # 重新定制 web
    docker-compose build "${Rails_Service}"
    # 启动 web
    docker-compose up -d "${Rails_Service}"
    docker-compose ps | grep -q "${Rails_Service}" && echo "up success"
}