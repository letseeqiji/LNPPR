# LNPPR-Docker 一键安装脚本

#### <u>让工作更快更轻松!</u>

--> LNPPR-Docker: https://github.com/letseeqiji/LNPPR/tree/lnppr-docker

## 脚本说明
**LNPPR-Docker = Docker ( Linux + Nginx + Puma + PosrgreSQL + Rails )**

LNPPR-Docker  一键安装脚本是基于配置文件的 Shell 脚本文件.

它从dokcer的自动安装到可以基于 Docker-compose 快速的帮您搭建在 linux 平台上 包含服务器的 Rails 项目.

其中的套件包含不仅包含 :Docker + Docker-compose + Nodejs + Yarn + Nginx + Ruby + Rails + Sqlite3/MySQL/PostgreSQL + Redis 等等.

你可以通过修改脚本根目录下的 docker.conf 文件来控制软件的版本, 也可以通过修改 rails_new.conf 来定义rails 项目的参数.

然后就是  **一键创建新项目 ~~**

## 脚本特点

- 多语言支持: 内置语言包, 嫌提示不好看? 那就定制成自己专属界面!
- 基于配置: 无需界面操作与等待, 配置好了,安装即可,这才是真正的 "一键搞定"!
- 基于Docker: 自动根据配置拉去和创建image!
- 自动维护Docker-compose: 自动根据选择创建 Docker-compose 文件!
- 自动配置: 根据配置实现项目的自动配置!
- 内置指令集: 提供原生的开发体验!
- 更多独立工具: 想用就用,不想绝不强塞! 要扩展,就弄个新包上去!
- 更多功能来袭 !!!

## 使用要求
#### 特殊说明
- 仅支持64位系统! 仅支持64位系统! 仅支持64位系统!
- 软件版本
    - Ruby: 2.7.4+
    - Rails: 5.2.5+
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
- 配置 **脚本根目录下的**配置文件: **docker.conf 和 rails_new.conf** ;
- 给与 docker_rails.sh 可执行权限:

    - ```shell
        # chmod +x docker_rails.sh
        ```
- 使用root用户执行脚本:

    - ```shell
        # su root
        # ./docker_rails.sh
        ```
- 喝杯茶, 等着吧~ ;

## * 配置文件 docker.conf 说明 *

```bash
# 界面语言 zh | en
Language=zh

# Docker
# docker 下载地址
Docker_Binary_Download="https://mirrors.163.com/docker-ce/linux/static/stable/x86_64/"
# docker 主镜像地址
Docker_Main_Registry="https://hub-mirror.c.163.com"
# 要安装的docker版本
Docker_Install_Ver="20.10.9"

# Compose
# docker-compose 下载地址
Compose_Binary_Download="https://get.daocloud.io/docker/compose/releases/download"
# docker-compose 安装版本
Compose_Install_Ver="2.1.1"
# docker-compose.yml version
Compose_Version="3.8"
# 默认的 docker-compose 文件名
Compose_File="docker-compose.yml"
# 内置制定集自定义
Compose_Instruction=compose
Rails_Instruction=rails

# dockerfile
Docker_File_Label="maintainer=qiji"

# Rails App default value
# rails 服务名
Rails_Service="web"
# 3位如：3.0.2 2.7.4
# ruby镜像使用版本
Ruby_Default_Ver="3.0.2"
# 3位如：6.1.4 5.2.5
# rails 默认镜像版本
Rails_Default_Ver="6.1.4"
# rails 默认的使用的端口号
Rails_Default_Port=3000
# product || development || test
Rails_ENV="development"
# 是否安装redis
Rails_Enable_Redis="n"
# 默认的项目地址
Rails_Default_Project_Dir="/data/www"
# 项目env文件默认文件夹
Env_Dir=".env/${Rails_ENV}"

# Node 镜像地址
Node_Registry="registry.npm.taobao.org"

#ruby 镜像地址
Ruby_Registry="gems.ruby-china.com"

# Postgres 服务名
Postgres_Service="postgres"
# Postgres镜像名
Postgres_Img="postgres"
# Postgres镜像默认版本
Postgres_Default_Ver="latest"
# Postgres是否允许远程
Postgres_Enable_Remote='y'
# Postgres 默认远程端口
Postgres_Remote_port="5432"
# Postgres连接host地址
Postgres_Host="${Postgres_Service}"
# Postgres host 存放文件
Postgres_Host_File="${Postgres_Host}"
# Postgres 用户
Postgres_User="postgres"
# Postgres 用户密码
Postgres_Passwd="123456"
# Postgres 数据库
Postgres_Db="${Rails_Service}_${Rails_ENV}"
# Postgres 挂载镜像
Postgres_Data_Valume="${Rails_ENV}_postgres_db_data"

# MySQL 服务名
MySQL_Service="mysql"
# MySQL 镜像名
MySQL_Img="mysql"
# MySQL 镜像版本
MySQL_Default_Ver="latest"
# MySQL 允许远程
MySQL_Enable_Remote='y'
# MySQL 远程端口
MySQL_Remote_port=3306
# MySQL 存储引擎
MySQL_Default_Storage_Engine="INNODB"
# MySQL 字符编码
MySQL_Default_Character="utf8mb4"
# MySQL 连接host
MySQL_Host="${MySQL_Service}"
MySQL_Host_File="${MySQL_Host}"
# MySQL 用户
MySQL_User="lnppr"
# MySQL 用户密码
MySQL_Passwd="123456"
# MySQL root 密码
MySQL_Root_Passwd="123456"
# MySQL 挂载镜像
MySQL_Data_Valume="${Rails_ENV}_mysql_db_data"

# Redis 服务名
Redis_Service="redis"
# Redis 镜像名
Redis_Img="redis"
# Redis 镜像默认版本
Redis_Default_Ver="latest"
# Redis 是否允许编程
Redis_Enable_Remote='y'
# Redis 远程端口
Redis_Remote_port="6379"
# Redis 密码
Redis_Remote_Passwd="123456"
```

## * 配置文件 rails_new.conf 说明  *

```bash
# Rails_New_Options
# 可选：mysql/postgresql/sqlite3/oracle/sqlserver/jdbcmysql/jdbcsqlite3/jdbcpostgresql/jdbc
Rails_New_Option_Database="sqlite3"

# 运行端口 任意可用端口即可
Rails_New_Option_Port="3000"

# 可选：no-redis | redis
Rails_New_Option_Redis="redis"

# 可选：--api | --no-api
Rails_New_Option_Api="--no-api"

# 可选：--skip-bundle | --no-skip-bundle
Rails_New_Option_Skip_Bundle="--no-skip-bundle"

# 可选：--skip-test | --no-skip-test
Rails_New_Option_Skip_Test="--no-skip-test"

# 可选：--minimal | --no-minimal
Rails_New_Option_Minimal="--no-minimal"

# 可选：--webpack= WEBPACK, react, vue, angular, elm, stimulus
# Rails_New_Option_Webpacker="--webpack=WEBPACK"
Rails_New_Option_Webpacker="WEBPACK"

# 可选：--skip-gemfile | --no-skip-gemfile
Rails_New_Option_Skip_Gemfile="--no-skip-gemfile"

# 可选：--skip-git | --no-skip-git
Rails_New_Option_Skip_Git="--no-skip-git"

# 可选：--skip-action-mailer | --no-skip-action-mailer
Rails_New_Option_Skip_Action_Mailer="--no-skip-action-mailer"

# 可选：--skip-action-mailbox | --no-skip-action-mailbox
Rails_New_Option_Skip_Action_Mailbox="--no-skip-action-mailbox"

# 可选：--skip-action-text | --no-skip-action-text
Rails_New_Option_Skip_Action_Text="--no-skip-action-text"

# 可选：--skip-active-record | --no-skip-active-record
Rails_New_Option_Skip_Active_Record="--no-skip-active-record"

# 可选：--skip-active-job | --no-skip-active-job
Rails_New_Option_Skip_Active_Job="--no-skip-active-job"

# 可选：--skip-active-storage | --no-skip-active-storage
Rails_New_Option_Skip_Active_Storage="--no-skip-active-storage"

# 可选：--skip-puma | --no-skip-puma
Rails_New_Option_Skip_Puma="--no-skip-puma"

# 可选：--skip-action-cable | --no-skip-action-cable
Rails_New_Option_Skip_Action_Cable="--no-skip-action-cable"

# 可选：--skip-javascript | --no-skip-javascript
Rails_New_Option_Skip_Javascript="--no-skip-javascript"

# 可选：--skip-turbolinks | --no-skip-turbolinks
Rails_New_Option_Skip_Turbolinks="--no-skip-turbolinks"

# 可选：--skip-system-test | --no-skip-system-test
Rails_New_Option_Skip_System_Test="--no-skip-system-test"

# 可选：--skip-bootsnap | --no-skip-bootsnap
Rails_New_Option_Skip_Bootsnap="--no-skip-bootsnap"

# 可选：--skip-webpack-install | --no-skip-webpack-install
Rails_New_Option_Skip_Webpack_Install="--no-skip-webpack-install"

# 使用自定义模板
Rails_New_Option_Template=""
```

## * 内置默认指令集 说明 *

```bash
compose up: docker-compose up
compose down: docker-compose down
compose start: docker-compose start
compose stop: docker-compose stop
compose ps: docker-compose ps
compose build: docker-compose build
compose -v: docker-compose -v
rails console: docker-compose run web rails console
rails db:migrate: docker-compose run web rails db:migrate
rails webpacker:install: docker-compose run web rails webpacker:install
bundle: docker-compose run web bundle
mysql: docker-compose run mysql mysql
```