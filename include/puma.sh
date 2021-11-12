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
Puma_Check_Instelled()
{
	Check_Command puma
}

Puma_Verstion()
{
	puma -v
}

Puma_Lns_To_Bin()
{
    Ln_S ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/puma /usr/bin/puma
}

Puma_Install()
{
	if Check_Command ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/gem;then
		${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/gem install puma
		if Check_Up;then
			Puma_Lns_To_Bin
		fi
	fi
}

Puma_Uninstall()
{
	Check_Command puma && ${Ruby_Install_Dir}/${Ruby_Install_Ver}/bin/gem uninstall puma
	Rm_File /usr/bin/puma
}