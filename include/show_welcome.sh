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
Show_Welcome_zh()
{
	echo "+-----------------------------------------------------------------------+"
	echo "|************************- 让工作更快更轻松！ -*************************|"
	echo "+-----------------------------------------------------------------------+"
	echo "|             欢迎使用 LNPPR-Docker 助手 V${LNPPR_Version}, 作者：${Author}               |"
	echo "+-----------------------------------------------------------------------+"
	echo "|                  ${Author_Git}                  |"
	echo "+-----------------------------------------------------------------------+"
}

Show_Welcome_en()
{
	echo "+-----------------------------------------------------------------------+"
	echo "|*******************- Make work faster and easier！-********************|"
	echo "+-----------------------------------------------------------------------+"
	echo "|     Welcome to use LNPPR-Docker helper V${LNPPR_Version}, Written by ${Author}       |"
	echo "+-----------------------------------------------------------------------+"
	echo "|             Quick installation based on configuration                 |"
	echo "+-----------------------------------------------------------------------+"
	echo "|                  ${Author_Git}                  |"
	echo "+-----------------------------------------------------------------------+"
}