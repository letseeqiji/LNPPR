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
Sqlite_Dir_Name=sqlite-autoconf-3360000
Sqlite_Source_File_Download_Url=https://www.sqlite.org/2021/"${Sqlite_Dir_Name}".tar.gz
Sqlite_Version_Installed=0
Sqlite_Version_Min=38

Sqlite_Version()
{
    Sqlite_Version_Installed=$(sqlite3 --version | awk -F '.' '{printf("%s%s"),$1,$2}')
}

Sqlite_Check_Installed()
{
    # centos 上的sqlite版本太低了,如果碰到低版本,我们还是需要安装
	if Check_Command sqlite3;then
        Sqlite_Version
        if [ ${Sqlite_Version_Installed} -lt ${Sqlite_Version_Min} ];then
            echo "${lang_version_too_old}, ${lang_version_update}"
            return 1
        fi
    else
        return 1
    fi
}

Sqlite_Get_Sourcefile()
{
    cd ${current_dir}/src/
    if ! Check_File_Exist "${Sqlite_Dir_Name}".tar.gz; then
        wget "${Sqlite_Source_File_Download_Url}"
    fi
}

Sqlite_Tar_And_Cd_Sourcefile()
{
  Check_Equal "${Install_Env}" "pro" && Rm_Dir "${Sqlite_Dir_Name}"
  Tar "${Sqlite_Dir_Name}".tar.gz
  cd "${Sqlite_Dir_Name}"
}

Sqlite_Check_Install_Dir()
{
    if Check_Dir_Exist "${Sqlite3_Install_Dir}";then
      Back_Up_File "${Sqlite3_Install_Dir}"
    fi
    Make_Dir "${Sqlite3_Install_Dir}"
}

Sqlite_Make_Install_Configure()
{
    Sqlite_Check_Install_Dir
    ./configure --prefix="${Sqlite3_Install_Dir}"
}

Sqlite_Lns_Bin()
{
    Ln_S "${Sqlite3_Install_Dir}"/bin/sqlite3 /usr/bin/sqlite3
}

Sqlite_Ldconfig()
{
    echo "${Sqlite3_Install_Dir}/lib" > /etc/ld.so.conf.d/sqlite3.conf
    ldconfig
}

Sqlite_Install_Finish()
{
    if Check_Equal "${Install_Env}" "pro";then
        Rm_Dir "${current_dir}"/src/"${Sqlite_Dir_Name}"
    fi
}

Sqlite_Install()
{
  if Sqlite_Check_Installed;then
    echo "${lang_installed_already} sqlite3, ${lang_no_need_install}"
  else
    cd "${current_dir}"/src

    echo "sqlite3 ${lang_download_start}"
    Sqlite_Get_Sourcefile
    if Check_Up;then
        echo "${lang_download_success}"
    else
        echo "${lang_download_not_found}"
        return 1
    fi

    echo "sqlite3 ${lang_start_uncompress}"
    Sqlite_Tar_And_Cd_Sourcefile
    if ! Check_Up;then
        echo "${lang_dir_not_find}"
        return 1
    fi

    echo "sqlite3 ${lang_install_start_configure}"
    Sqlite_Make_Install_Configure
    if Check_Up;then
        echo "${lang_confighure_success}"
    else
        echo "${lang_confighure_fail}"
        return 1
    fi

    echo "sqlite3 ${lang_start_make_install}"
    Make_Install
    if Check_Up;then
        echo "${lang_install_success}"
    else
        echo "${lang_install_fail}"
        Sqlite_Uninstall
        return 1
    fi

    echo "sqlite3 ${lang_lns_to_bin}"
    Sqlite_Lns_Bin
    if Sqlite_Check_Installed;then
      echo "${lang_install_success}"
    else
      echo "${lang_install_fail}"
      Sqlite_Uninstall
      return 1
    fi

    echo "sqlite3 ${lang_ldconfig}"
    Sqlite_Ldconfig
    if Check_Up;then
      echo "${lang_install_success}"
    else
      echo "${lang_install_fail}"
      Sqlite_Uninstall
      return 1
    fi

    Sqlite_Install_Finish
    Echo_Green "====== Sqlite install completed ======"
    Echo_Smile "Sqlite ${lang_install_success} !"  
  fi    
}

Sqlite_Uninstall()
{
	Rm_Dir ${Sqlite3_Install_Dir}
	Sqlite_Check_Installed && echo "sqlite ${lang_uninstall_fail}" || echo "sqlite ${lang_uninstall_success}"
}
