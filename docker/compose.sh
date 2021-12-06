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
Local_Bin_Compose="/usr/local/bin/docker-compose"
Bin_Compose="/usr/bin/docker-compose"
Download_Compose_File="docker-compose-linux-x86_64"

Compose_Get_Binary()
{
	Check_File_Exist "${Download_Compose_File}" || wget "${Compose_Binary_Download}/v${Compose_Install_Ver}/${Download_Compose_File}"
}

Compose_Mv_To_Local_Bin()
{
	Check_File_Exist "${Local_Bin_Compose}" && Back_Up_File "${Local_Bin_Compose}"
	mv "${Download_Compose_File}" "${Local_Bin_Compose}"
	Check_Up_OK || return 1
	chmod +x "${Local_Bin_Compose}"
}

Compose_Lns_To_Bin()
{
	Check_File_Exist "${Bin_Compose}" && Back_Up_File "${Bin_Compose}"
	ln -s "${Local_Bin_Compose}" "${Bin_Compose}"
}

Compose_Add_Instruction()
{
	local Compose_Exp="${Compose_Instruction}"
	local Compose_Alias='alias '${Compose_Instruction}'="docker-compose"'
	Add_Bin_To_Path "${Compose_Exp}" "${Compose_Alias}"

	local Rails_Exp="${Rails_Instruction}"
	local Rails_Alias='alias '${Rails_Instruction}'="[ ! -f docker-compose.yml ] && rails || docker-compose run --rm '${Rails_Service}' rails"'
	Add_Bin_To_Path "${Rails_Exp}" "${Rails_Alias}"

	local Bundle_Exp='bundle'
	local Bundle_Alias='alias bundle="[ ! -f docker-compose.yml ] && bundle || docker-compose run --rm '${Rails_Service}' bundle"'
	Add_Bin_To_Path "${Bundle_Exp}" "${Bundle_Alias}"

	local Mysql_Exp='mysql'
	local Mysql_Alias='alias mysql="[ ! -f docker-compose.yml ] && mysql || docker-compose run --rm '${MySQL_Service}' mysql"'
	Add_Bin_To_Path "${Mysql_Exp}" "${Mysql_Alias}"

	local Sqlite_Exp='sqilte3'
	local Sqlite_Alias='alias sqilte3="[ ! -f docker-compose.yml ] && sqilte3 || docker-compose run --rm '${Rails_Service}' sqilte3"'
	Add_Bin_To_Path "${Sqlite_Exp}" "${Sqlite_Alias}"
}

Compose_Install()
{
	! Check_Dir_Exist ${current_dir}/src && echo "wrong dir" && return 1
	cd ${current_dir}/src

	echo "${lang_download_start}"
	Compose_Get_Binary
	Check_Up && echo "${lang_download_success}" || return 1

	Compose_Mv_To_Local_Bin
	Check_Up_OK || return 1

	Compose_Lns_To_Bin
	Check_Up_OK || return 1

	Compose_Add_Instruction
	Check_Up_OK || return 1

	docker-compose --version
}

Compose_Uninstall()
{
	Check_File_Exist "${Local_Bin_Compose}" && Rm_File "${Local_Bin_Compose}"
	Check_File_Exist "${Bin_Compose}" && Rm_File "${Bin_Compose}"
	Check_Up_OK || return 1
}

