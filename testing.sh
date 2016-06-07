#!/bin/sh

CURRENT=$(pwd)

output() {
  color="32"
  if [ "$2" = 1 ]; then
    color="31"
  fi
  printf "\033[${color}m"
  echo $1
  printf "\033[0m"
}

git clone https://github.com/bcit-ci/CodeIgniter.git ci
sed -i.bak -e "s/\.\.\//\.\/ci/g" docker-compose.yml
output "Start container."
docker-compose -p ci build --no-cache
docker-compose -p ci up -d
output "Testing CodeIgniter Web Site."
curl -L http://127.0.0.1 > /dev/null
cd ${CURRENT}/ci && composer require phpunit/phpunit@~4.0 --dev
cd ${CURRENT}/ci && git clone https://github.com/kenjis/ci-phpunit-test.git
cd ${CURRENT}/ci && php ci-phpunit-test/install.php

[ $? -eq 0 ] && output "✨ ✨ ✨ OK - Test done."
[ $? -eq 0 ] || (output "✨ ✨ ✨ Error - Test fail." 1 && exit 1)

# stop all container
docker-compose -p ci down
