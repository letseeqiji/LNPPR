LNPPR-Docker | Make work fater and easier 😀
### LNPPR-Docker = Docker ( Linux + Nginx + Puma + PosrgreSQL + Rails )
From install docker and docker-compose to Rails-app control, LNPPR-Docker give you everything that you need !!!
## A Big Surprise!
### An instruction system is provided by KNPPR-Docker !
To achieve the feel of native development, we try to made them! As a result, we provide better feelings !!!
Below is a list of instruction sets:

- lnppr --help: show helps
- lnppr --version: show lnppr version
- lnppr unistall: delete lnppr
- server: alias server="docker-compose"
    - server up: docker-compose up
    - server down: docker-compose down
    - server start: docker-compose start
    - server stop: docker-compose stop
    - server ps: docker-compose ps
    - server build: docker-compose build
    - server -v: docker-compose -v
- rails: alias rails="[ -f docker-compose.yml ] && docker-compose run web rails || rails"
- rails: alias rails="[ -f docker-compose.yml ] && 'docker-compose run web rails' || rails"
- rails: alias rails="if [ -f docker-compose.yml ]; then docker-compose run web rails; else rails; fi"
- rails: alias rails="[ -f docker-compose.yml ] && docker-compose run web rails"
上面的都不行 最后一个一定会执行
用这个
- rails: alias rails="[ ! -f docker-compose.yml ] && rails || docker-compose run web rails"
    - rails console: docker-compose run web rails console
    - rails db:migrate: docker-compose run web rails db:migrate
    - rails webpacker:install: docker-compose run web rails webpacker:install

- bundle: docker-compose run web bundle
-


