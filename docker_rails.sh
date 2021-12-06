#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Enable_Lang=(zh en)
current_dir=$(pwd)

. version
. docker.conf
. rails_new.conf
[[ "${Enable_Lang[@]}" =~ "${Language}" ]] || Language=zh
. i18n/${Language}.lang
. include/helper.sh
. include/os.sh
. include/show_welcome.sh
. include/begin.sh
. docker/helper.sh
. docker/yml_man.sh
. docker/docker.sh
. docker/compose.sh
. docker/centos.sh
. docker/debian.sh
. docker/fedora.sh
. docker/RHEL.sh
. docker/ubuntu.sh
. docker/redis.sh
. docker/postgres.sh
. docker/mysql.sh
. docker/rails.sh
Get_OS_Info

if [ $(id -u) != "0" ]; then
    Echo_Sad "Error: You must be root to run this script!"
    exit
fi

if ! Check_Command docker;then
    Echo_Smile "Could not find the Docker, Would you install Docker?(y|n): "
    read Choose_Install
    if Check_Equal "$Choose_Install" 'y';then
        echo "Docker installing ..."
        Docker_Install
        if Check_Command docker;then
            Echo_Green "Docker install OK!"
            sleep 1
        else
            Echo_Sad "Docker install fail!"
            exit
        fi
    else
    	exit
    fi
fi

if ! Check_Command docker-compose;then
    Echo_Smile "Could not find the docker-compose"
    echo "docker-compose installing ..."
    Compose_Install
    if Check_Command docker-compose;then
        Echo_Green "docker-compose install OK!"
        sleep 1
    else
        Echo_Sad "docker-compose install fail!"
        exit
    fi
fi

Docker_Show_Welcome()
{
	echo ""
	Show_Welcome_${Language}
	echo ""
	echo " 1, ${lang_create_app} ;"
	echo " 2, ${lang_create_app_use_compose} ;"
	echo " q, ${lang_exit} ."
	echo ""
}

clear
while true
do
Docker_Show_Welcome
read -p "😀${lang_input_your_choose}:" Control

case $Control in 
	1)
	read -p "😀${lang_input_app_name}：" NP_Name
	if Check_Empty $NP_Name;then
		Echo_Sad "${lang_need_app_name}，🛑${lang_stop_create}"
		sleep 3
		clear
		continue
	fi
	read -p "${lang_input_app_path} (${lang_default}:/data/www)" NP_Dir
	if Check_Empty $NP_Dir;then
		NP_Dir="/data/www"
	fi
	if Check_Dir_Exist "${NP_Dir}/${NP_Name}";then
		echo "${NP_Dir}/${NP_Name} ${lang_already_exits}, ${lang_use_other}"
		continue
	fi
	echo "${lang_create_app} ${NP_Dir}/${NP_Name}"
	Make_Dir ${NP_Dir} && chmod 777 -Rf ${NP_Dir}
	cd ${NP_Dir}
	Rails_New_App ${NP_Name}
	ls "${NP_Dir}/${NP_Name}"
	Echo_Green "${lang_create_success}"
	sleep 3
	;;
	2)
	read -p "😀${lang_input_app_name}：" NPC_Name
	if Check_Empty $NPC_Name;then
		Echo_Sad "${lang_need_app_name}，🛑${lang_stop_create}"
		sleep 3
		clear
		continue
	fi
	read -p "😀${lang_input_app_path} (${lang_default}:/data/www)" NPC_Dir
	if Check_Empty $NPC_Dir;then
		NPC_Dir="/data/www"
	fi
	if Check_Dir_Exist "${NPC_Dir}/${NPC_Name}";then
		echo "${NPC_Dir}/${NPC_Name}  ${lang_already_exits}, ${lang_use_other}"
		continue
	fi
	echo "${lang_create_app} ${NPC_Dir}/${NPC_Name}"
	Rails_Compose_New_App ${NPC_Name} ${NPC_Dir}
	Echo_Green "${lang_create_success}"
	sleep 3
	;;
	q|Q)
	echo ""
	Echo_Smile "bye~~"
	sleep 3
	clear
	exit
	;;
	*)
	Echo_Angry "${lang_input_unlegal}"
	sleep 1
	clear
	continue
	;;
esac
done
