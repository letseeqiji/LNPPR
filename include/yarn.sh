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
Yarn_Check_Installed()
{
	Check_Command yarn
}

Yarn_Check_Npm_Installed()
{
	Check_Command "${Nodejs_Install_Dir}"/"${Nodejs_Install_Ver}"/bin/npm
}

Yarn_Common_Install()
{
	"${Nodejs_Install_Dir}"/"${Nodejs_Install_Ver}"/bin/npm install yarn -g
}

Yarn_Lns_To_Bin()
{
    Ln_S "${Nodejs_Install_Dir}"/"${Nodejs_Install_Ver}"/bin/yarn /usr/bin/yarn
}

Yarn_Install()
{
	if ! Check_Command npm;then
		echo "${lang_should_install_first} npm"
		return 1
	fi
	if Yarn_Check_Installed;then
		echo "${lang_installed_already} yarn, ${lang_no_need_install}" 
	else
		echo "${lang_installed_check} yarn"
		if ! Yarn_Check_Npm_Installed; then
			echo "${lang_should_install_first} npm"
			return 1
		fi

		echo "${lang_install_start_app} yarn"
		Yarn_Common_Install
		if Check_Up;then
			echo "${lang_install_success}"
		else
			echo "${lang_install_fail}"
			return 1
		fi
		
		echo "yarn ${lang_lns_to_bin}"
        Yarn_Lns_To_Bin
        if Check_Up; then
            echo "yarn ln s ${lang_confighure_success}"
        else
            echo "yarn ln s ${lang_confighure_fail}"
            Yarn_Uninstall
            return 1
        fi

        Echo_Green "====== Yarn install completed ======"
    	Echo_Smile "Yarn ${lang_install_success} !" 
	fi
}

Yarn_Uninstall()
{
	if Yarn_Check_Installed;then
		npm uninstall yarn -g  
		echo "${lang_uninstall_success}"
	else
		echo "${lang_no_yarn_install}"
	fi
}
