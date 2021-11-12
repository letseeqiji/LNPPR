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
Rails_Check_Installed()
{
	Check_Command ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/rails
}

Show_Rails_Verstion()
{
	${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/rails -v
}

Rails_Lns_To_Bin()
{
    Ln_S ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/rails /usr/bin/rails
}

Rails_Chmod_Gem_Dir()
{
    chmod 777 -Rf "${Ruby_Install_Dir}"/"${Ruby_Install_Ver}"/lib/ruby/gems
}

Rails_Install()
{
	if Rails_Check_Installed;then
		echo "rails ${lang_installed_already}, ${lang_no_need_install}"
	else
		if ! Check_Command "${Ruby_Install_Dir}"/"${Ruby_Install_Ver}"/bin/ruby;then
			echo "${lang_should_install_first} ruby"
			return 1
		fi

		${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/gem install rails -v ${Rails_Install_Ver}
		if Rails_Check_Installed;then
			echo "rails ${lang_install_success}"
		else
			echo "rails ${lang_install_fail}"
			return 1
		fi

		echo "ruby ${lang_lns_to_bin}"
        Rails_Lns_To_Bin
        if Check_Up; then
            echo "rails ln s ${lang_confighure_success}"
        else
            echo "rails ln s ${lang_confighure_fail}"
            Ruby_Uninstall
            return 1
        fi

		Rails_Chmod_Gem_Dir

		Echo_Green "====== Rails install completed ======"
        Echo_Smile "Rails ${lang_install_success} !"
	fi
}

Rails_Uninstall()
{
	if ! Rails_Check_Installed;then
		echo "no install Rails"
	else
		${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/gem uninstall rails -v ${Rails_Install_Ver}
	fi 
}