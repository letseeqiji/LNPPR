# LNPPR一键安装脚本

#### <u>让工作更快更轻松!</u>

--> LNPPR-Docker: https://github.com/letseeqiji/LNPPR/tree/lnppr-docker

## 脚本说明
**LNPPR = Linux + Nginx + Puma + PostgreSQL + Rails**

LNPPR 一键安装脚本是基于配置文件的 Shell 脚本文件.

它可以快速的帮您搭建 基于linux 平台包含反向代理的的 Rails 服务器.

其中的套件包含不仅包含 :Nodejs + Yarn + Nginx + Ruby + Rails + Sqlite3/MySQL/PostgreSQL + Redis 等等.

你可以通过修改脚本根目录下的 install.conf 文件来控制软件的安装和一系列配置.

然后就是  **一键安装 ~~**

## 脚本特点

- 最小化安装: 只安装必要的软件,保持您系统的稳定和苗条!
- 过程透明: 不"偷偷"修改系统配置,一切都在您的掌控!
- 自动回滚: 安装失败会自动清除已经安装的软件残留, 走也要走的干干净净!
- 多语言支持: 内置语言包, 嫌提示不好看? 那就定制成自己专属界面!
- 基于配置: 无需界面操作与等待, 配置好了,安装即可,这才是真正的 "一键搞定"!
- 更多独立工具: 想用就用,不想绝不强塞! 要扩展,就弄个新包上去! 
- 更多功能来袭 !!!

## 使用要求
#### 特殊说明
- 仅支持64位系统! 仅支持64位系统! 仅支持64位系统!
- **目前,目前,目前** 不支持 WSL!

#### 安装要求
- 硬件要求
    - 若安装 MySQL5.7.x 
        - 需要内存至少1G
        - 硬盘空间至少10G
    - 若安装 MySQL8.x 
        - 需要内存至少2G
        - 硬盘空间至少25G 
    - 若安装 PostgreSQL 
        - 需要内存至少1G
        - 硬盘空间至少1G
    
- 系统
    - linux 64位系统
        - 目前支持的系统列表

        | 系统       | 版本         | 位数 |
        | ---------- | ------------ | ---- |
        | centOS     | 7.0 及以上   | 64位 |
        | Ubuntu     | 20.04 及以上 | 64位 |
        | Debian     | 9 及以上     | 64位 |
        | Linux Mint | 20 及以上    | 64位 |
        | Fedora     | 32 及以上    | 64位 |
        | Mint       | 20及以上     | 64位 |
        | Deepin     | 20及以上     | 64位 |
        | Oracle     | 7及以上      | 64位 |
        | RHEL       | 7及以上      | 64位 |
        | Kali       | 2020及以上   | 64位 |
        | ...        | ...          | ...  |

## 使用说明
- 克隆脚本到本地文件夹;
- **一定要! 必须要! ** 切换目录到 **脚本根目录**;
- 配置 **脚本根目录下的**配置文件: **install.conf** ;
- 给与 install.sh 可执行权限:

    - ```shell
        # chmod +x install.sh
        ```
- 使用root用户执行脚本:
  
    - ```shell
        # su root
        # ./install.sh
        ```
- 喝杯茶, 等着吧~ ;
- 完成后, **不用**重启计算机! **不用**重启计算机! **不用**重启计算机!


## * 配置文件 install.conf 说明 *

```bash
# 选择界面显示语言: zh | en
Language=zh
# 要安装的环境 dev | pro | test
Install_Env=pro

# 控制要安装的软件：y-安装 | n-不安装
# 安装Nodejs:默认安装
Nodejs_Enable_Install='y'
# 安装Yarn:默认安装
Yarn_Enable_Install='y'
# 安装Nginx:默认安装
Nginx_Enable_Install='y'
# 安装Ruby:默认安装
Ruby_Enable_Install='y'
# 安装Rails:默认安装
Rails_Enable_Install='y'
# 安装Puma:默认安装
Puma_Enable_Install='y'
# 安装Sqlite3:默认安装
Sqlite3_Enable_Install='y'
# 安装Mysql:默认不安装
Mysql_Enable_Install='n'
# 安装PostgreSQL:默认不安装
PostgreSQL_Enable_Install='n'
# 安装Redis:默认不安装
Redis_Enable_Install='n'

# Nodejs 相关配置
# 要安装的版本
Nodejs_Install_Ver=14.18.1
# 镜像下载地址
Nodejs_Base_Download_Url='https://mirrors.aliyun.com/nodejs-release'
# 安装路径
Nodejs_Install_Dir=/usr/local/nodejs
# 修改npm国内源
Nodejs_Reset_Registry='淘宝'
Nodejs_Registry_Url=https://registry.npm.taobao.org

# Yarn 相关配置
# 安装版本
Yarn_Install_Ver=1.22.4

# ruby 相关配置
# 安装版本
Ruby_Install_Ver=3.0.2
# 安装路径
Ruby_Install_Dir=/usr/local/ruby

# rails 相关配置
# 安装版本
# Rails_Install_Ver=5.2.5
Rails_Install_Ver=6.1.4

# sqlite 相关配置
# 安装版本
Sqlite3_Install_Ver=3.36.0
# 安装路径
Sqlite3_Install_Dir=/usr/local/sqlite

# MySQL 相关配置
# 安装版本
# Mysql_Install_Ver=8.0.27
Mysql_Install_Ver=5.7.36
# 镜像下载地址
MySQL_Base_Download_Url='https://mirrors.aliyun.com/mysql'
# 安装路径
Mysql_Install_Dir='/usr/local/mysql'
# 数据目录
MySQL_Data_Dir='/data/mysql/data'
# 使用端口
MySQL_Port=3306
# 要设置的root密码
MySQL_Root_Passwd='123456'
# 默认配置文件所在目录
MySQL_DSYSCONFDIR='/etc'
# 默认数据编码
MySQL_DEFAULT_CHARSET=utf8mb4
# socket文件所在目录
MySQL_Sock=/tmp/mysql.sock
# 是否开启远程登录访问
MySQL_Enable_Remote='y'

# PgSql 相关配置
# 安装版本
# PgSQL_Install_Ver=10.19
# PgSQL_Install_Ver=11.14
# PgSQL_Install_Ver=12.9
# PgSQL_Install_Ver=14.1
PgSQL_Install_Ver=13.5
# 镜像下载地址
PgSQL_Base_Download_Url='https://mirrors.aliyun.com/postgresql'
# 安装路径
PgSQL_Install_Dir='/usr/local/pgsql'
# 数据目录
PgSQL_Data_Dir='/data/pgsql'
# 使用端口
PgSQL_Port=5432
# 是否开启远程登录访问
PgSQL_Enable_Remote='y'

# Redis 相关配置
# 安装版本
Redis_Install_Ver=6.2.6
# 是否开启远程登录访问
Redis_Enable_Remote='y'
# 设置登录需要密码
Redis_Enable_Passwd='y'
# 登录用密码
Redis_Passwd='123456'
# 安装路径
Redis_Install_Dir='/usr/local/redis'
# 使用端口
Redis_Port=6379
# 数据目录
Redis_Data_Dir='/data/redis/data'
# 日志目录
Redis_Log_Dir='/data/redis/log'
Redis_Log_File='/data/redis/log/redis_log'
# 配置文件所在目录
Redis_Config_Dir='/usr/local/redis/etc'
Redis_Config_File='/usr/local/redis/etc/redis.conf'
# pid文件所在目录
Redis_Pid_File='/var/run/redis.pid'

# Nginx 相关配置
# 安装版本
Nginx_Install_Ver=1.20.1
# nginx用户
Nginx_User=www
# nginx用户组
Nginx_Group=www
# 安装路径
Nginx_Install_Dir='/usr/local/nginx'
# 使用端口
Nginx_Port=80
# 日志目录
Nginx_Log_Dir='/data/nginx/log'
Nginx_Log_File='/data/nginx/log/error.log'
# 配置文件目录
Nginx_Config_Dir='/usr/local/nginx/conf'
Nginx_Config_File='/usr/local/nginx/conf/nginx.conf'
# 网站默认的路径
Default_Website_Dir='/data/wwwroot/default'
```

## 安装参考
### 硬件配置

| 名称 | 大小/核心数/转速/速率 | 类型       |
| ---- | --------------------- | ---------- |
| CPU  | 2.80GHz               | 4核心4线程 |
| 内存 | 4GB                   | 2666MHz    |
| 硬盘 | 7200rpm               | 机械       |
| 带宽 | 10M                   | 光纤       |

### 测试平台: CentOS 7.9x64
### GCC版本: 4.8.5

| 软件       | 版本    | 安装时长      | 安装过程最大占用空间 | 安装后占用空间 |
| ---------- | ------- | ------------- | -------------------- | -------------- |
| Nodejs     | 14.18.1 | 5秒           | 108MB                | 107MB          |
| Yarn       | 1.22.4  | 10秒          | 5.5MB                | 5.2MB          |
| Nginx      | 1.20.1  | 1.3min-1.8min | 39MB                 | 6.4MB          |
| Ruby       | 3.0.2   | 2.3min-3min   | 677MB                | 113MB          |
| Rails      | 6.1.4   | 1min-1.1min   | 42MB                 | 41.5M          |
| Sqlite3    | 3.36.0  | 1min-1.3min   | 90MB                 | 26MB           |
| PostgreSQL | 13.4    | 1.5min-2min   | 227MB                | 67MB           |
| MySQL5     | 5.7.36  | 15.3min-18min | 6.3GB                | 2173.6MB       |
| MySQL8     | 8.0.27  | 35min-40min   | 22.3GB               | 2470MB         |
| Redis      | 6.2.6   | 1.3min-1.5min | 179MB                | 19MB           |
| 软件依赖库 | ---     | 1.5min-2min   | <300MB               | 260MB          |

### 测试平台: Debian 11x64
### GCC版本: 10.2.1

| 软件       | 版本    | 安装时长      | 安装过程最大占用空间 | 安装后占用空间 |
| ---------- | ------- | ------------- | -------------------- | -------------- |
| Nodejs     | 14.18.1 | 5秒           | 130MB                | 110MB          |
| Yarn       | 1.22.4  | 10秒          | 15MB                 | 8MB            |
| Nginx      | 1.20.1  | 1.3min-1.8min | 39MB                 | 5.5MB          |
| Ruby       | 3.0.2   | 2.3min-3min   | 700MB                | 126MB          |
| Rails      | 6.1.4   | 1min-1.1min   | 55MB                 | 43.5M          |
| Sqlite3    | 3.36.0  | 1min-1.3min   | 107MB                | 38MB           |
| PostgreSQL | 13.4    | 1.5min-2min   | 207MB                | 28MB           |
| MySQL5     | 5.7.36  | 15.3min-18min | 6.7GB                | 2273.6MB       |
| MySQL8     | 8.0.27  | 35min-40min   | 22.3GB               | 2566MB         |
| Redis      | 6.2.6   | 1.3min-1.5min | 179MB                | 25MB           |
| 软件依赖库 | ---     | 1.5min-2min   | <300MB               | 235.6MB        |
