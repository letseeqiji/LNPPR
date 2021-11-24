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
Check_OS_Vsersion()
{
	if echo "${OS_Version}" | grep '.'>/dev/null;then
		OS_Version=$(echo "${OS_Version}" | awk -F '.' '{printf("%s"), $1}')
	fi

	case ${OS_NAME} in
		'CentOS')
		[ "${OS_Version}" -lt '7' ] && return 1
		;;
		'Fedora')
		if [ "${OS_Version}" -lt '33' ];then
			Echo_Red "Fedora 版本必须高于 33 !"
			return 1
		fi
		;;
		'Oracle')
		if [ "${OS_Version}" -lt '7' ];then
			Echo_Red "Oracle 版本必须高于 7 !"
			return 1
		fi
		;;
		'RHEL')
		Get_RHEL_Version
		OS_Version=$(echo "${OS_Version}" | awk -F '.' '{printf("%s"), $1}')
		if [ "${OS_Version}" -lt '7' ];then
			Echo_Red "RHEL 版本必须高于 7 !"
			return 1
		fi
		;;
		'Debian')
		if [ "${OS_Version}" -lt '10' ];then
			Echo_Red "Debian 版本必须高于 10 !"
			return 1
		fi
		;;
		'Ubuntu')
		if [ "${OS_Version}" -lt '20' ];then
			Echo_Red "Ubuntu 版本必须高于 20.x !"
			return 1
		fi
		;;
		'Raspbian')
		echo "系统是Raspbian"
		;;
		'Deepin')
		if [ "${OS_Version}" -lt '20' ];then
			Echo_Red "Deepin 版本必须高于 20.x !"
			return 1
		fi
		;;
		'Mint')
		if [ "${OS_Version}" -lt '20' ];then
			Echo_Red "Mint 版本必须高于 20.x !"
			return 1
		fi
		;;
		'Kali')
		echo "系统是Kali"
		if [ "${OS_Version}" -lt '2020' ];then
			Echo_Red "Kali版本必须高于 2020.x !"
			return 1
		fi
		;;
		'unknow')
		echo "系统是unknow"
		;;
	esac
}

Disable_Selinux()
{
	local Selinux_Config
    Check_File_Exist "${Selinux_Config}" && sed -i 's/^SELINUX=.*/SELINUX=disabled/g' "${Selinux_Config}"
}

Init_ENV()
{
	local Packets=(gcc gcc-c++ g++ cmake make autoconf libssl-dev zlib zlib-devel libpcre3 libpcre3-dev pcre pcre-devel curl wget openssl openssl-devel bison bison-devel perl perl-devel build-essential pkg-config libncurses5-dev ncurses ncurses-devel libreadline-dev zlib1g-dev readline readline-dev xml2 libxml2-dev libxml2 libxslt libxslt-dev libperl-dev libperl uuid uuid-dev)
	for packet in "${Packets[@]}"
    do
        echo ${packet}
        ${PM} install "${packet}" -y
    done
}

Check_Env()
{
	Disable_Selinux
	Init_ENV
}

Check_Script_Full()
{
	Check_File_Exist "${current_dir}/version" || return 1

	if Check_Equal "${Version}" "0.1";then
		local Include_File=("begin.sh" "show_welcome.sh" "gem.sh" "git.sh" "helper.sh" "mysql.sh" "nginx.sh" "nodejs.sh" "os.sh" "pgsql.sh" "puma.sh" "rails.sh" "redis.sh" "ruby.sh" "sqlite.sh" "yarn.sh")
		for file in "${Include_File[@]}"
		do
			Check_File_Exist "${current_dir}/include/${file}" || return 1
		done

		local I18n_File=("zh.lang" "en.lang")
		for file in "${I18n_File[@]}"
		do
			Check_File_Exist "${current_dir}/i18n/${file}" || return 1
		done

		local Initd_File=("init.d.nginx" "nginx.service" "init.d.pgsql" "pgsql.service" "init.d.redis" "redis.service" "mysql.service")
		for file in "${Initd_File[@]}"
		do
			Check_File_Exist "${current_dir}/init.d/${file}" || return 1
		done

		local Main_File=("install.sh" "install.conf")
		for file in "${Main_File[@]}"
		do
			Check_File_Exist "${current_dir}/${file}" || return 1
		done
	fi
}

Check_Hardware_Need()
{
	Memory_Get_Total
	local Ok=0

	if Check_Equal "${PostgreSQL_Enable_Install}" "y";then
		if [ "${Mem_Total}" -lt "1000" ];then
			Echo_Angry "${lang_memory_not_enougth} 1G, PostgreSQL ${lang_app_can_not_install}"
			Ok=1
		fi
	fi

	if Check_Equal "${Mysql_Enable_Install}" "y";then
		Disk_Last_Space "${current_dir}"

		if echo "${Mysql_Install_Ver}" | grep -Eqi '^5.7.';then
			if [ "${Mem_Total}" -lt "1000" ];then
				Echo_Angry "${lang_memory_not_enougth} 1G, MySQL-5.7.x ${lang_app_can_not_install}"
				Ok=1
			fi
			if [ "${Dist_Last_Spac}" -lt "7168" ];then
				Echo_Angry "${lang_disk_not_enougth} 7g，MySQL-5.7 ${lang_make_may_fail}"
				Ok=1
			fi
		fi

		if echo "${Mysql_Install_Ver}" | grep -Eqi '^8.0.';then
			if [ "${Mem_Total}" -lt "2000" ];then
				Echo_Angry "${lang_memory_not_enougth} 2G, MySQL-8.0.x ${lang_app_can_not_install}"
				Ok=1
			fi
			if [ "${Dist_Last_Spac}" -lt "24576" ];then
				Echo_Angry "${lang_disk_not_enougth} 24g，MySQL-8.0  ${lang_make_may_fail}"
				Ok=1
			fi
		fi
	fi

	return $Ok
}

Check_Depend_Install()
{
    local Ok=0
    if [ "${Yarn_Enable_Install}" = 'y' ] && ! Check_Command npm && ! Check_File_Exist /usr/local/nodejs/bin/npm && ! [ "${Nodejs_Enable_Install}" = 'y' ];then
        Echo_Angry "${lang_yarn_need_npm}"
        echo
        Ok=1
    fi

    if [ "${Rails_Enable_Install}" = 'y' ] && ! Check_Command ruby && ! Check_File_Exist /usr/local/ruby/bin/ruby && ! [ "${Ruby_Enable_Install}" = 'y' ];then
        Echo_Angry "${lang_rails_need_ruby}"
        echo
        Ok=1
    fi
    return $Ok
}

