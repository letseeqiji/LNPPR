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

Npm=${Nodejs_Install_Dir}/${Nodejs_Install_Ver}/bin/npm

Nodejs_Check_Installed()
{
	Check_Command npm
}

Nodejs_Download_File()
{
	local File_Name="node-v${Nodejs_Install_Ver}-linux-x64.tar.gz"
	local Download_File="${Nodejs_Base_Download_Url}/v${Nodejs_Install_Ver}/${File_Name}"
	Check_File_Exist ${File_Name} || wget ${Download_File}
}

Nodejs_Prepare_Dir()
{
	Make_Dir ${Nodejs_Install_Dir}
	Change_Mod ${Nodejs_Install_Dir} 755
}

Nodejs_Mv_File()
{
	Nodejs_Prepare_Dir
	Copy_File ${Nodejs_Install_Ver} ${Nodejs_Install_Dir}/${Nodejs_Install_Ver}
	Rm_Dir ${Nodejs_Install_Ver}
}

Nodejs_Add_Link_To_Usr_Bin()
{
	 Ln_S ${Nodejs_Install_Dir}/${Nodejs_Install_Ver}/bin/node /usr/bin/node
	 Ln_S ${Nodejs_Install_Dir}/${Nodejs_Install_Ver}/bin/npm /usr/bin/npm
	 Ln_S ${Nodejs_Install_Dir}/${Nodejs_Install_Ver}/bin/npx /usr/bin/npx
}

Nodejs_Remove_Link_From_Usr_Bin()
{
	 Rm_File /usr/bin/node
	 Rm_File /usr/bin/npm
}

Nodejs_Set_Registry()
{
	Check_Command ${Npm} && ${Npm} conf set registry ${Nodejs_Registry_Url} --global
}

Nodejs_Chmod_dir()
{
	chmod 777 -Rf ${Nodejs_Install_Dir}/${Nodejs_Install_Ver}/lib/node_modules
}

Nodejs_Install()
{
	Echo_Smile "${lang_install_start_app} node-v${Nodejs_Install_Ver}"
	
	if Nodejs_Check_Installed;then
		echo "${lang_installed_already} nodejs, ${lang_no_need_install}" 
	else
		local File_Name="node-v${Nodejs_Install_Ver}-linux-x64.tar.gz"
		local Tar_Dir_Name="node-v${Nodejs_Install_Ver}-linux-x64"
		cd ${current_dir}/src
		Nodejs_Download_File
		if ! Check_Up;then
			echo "${lang_download_not_found} ${Nodejs_Install_Ver}，请访问nodejs官网获取正确的版本号并配置在 config/lnmrp.conf 中重新安装。"
			return 1
		fi

		Tar ${File_Name}
		mv ${Tar_Dir_Name} ${Nodejs_Install_Ver}

		Nodejs_Mv_File
		if ! Check_Up;then
			echo "${lang_node_mv_file_error}，${lang_install_rollback}"
			Nodejs_Uninstall
			return 1
		fi

		Nodejs_Add_Link_To_Usr_Bin
		if ! Check_Up; then
			echo "${lang_node_lns_error}，${lang_install_rollback}"
			Nodejs_Uninstall
			return 1
		fi

		Check_Empty Nodejs_Reset_Registry || Nodejs_Set_Registry
		if Check_Up;then
			echo "${lang_confighure_success}"
		else
			echo "${lang_confighure_fail}"
			Nodejs_Uninstall
			return 1
		fi

		echo "配置nodejs相关目录权限"
		Nodejs_Chmod_dir
		if Check_Up;then
			echo "${lang_confighure_success}"
		else
			echo "${lang_confighure_success}"
			Nodejs_Uninstall
			return 1
		fi

		Echo_Green "====== Nodejs install completed ======"
		Echo_Smile "Nodejs ${lang_install_success} !"
	fi
}

Nodejs_Uninstall()
{
	Rm_Dir ${Nodejs_Install_Dir}
	Nodejs_Remove_Link_From_Usr_Bin
	Rm_File $Home/.node
}
