#!/bin/bash
# description     : dockerization console for development setup of adshares.net components
# author		      : github.com/yodahack
# version         : 0.1-dev
# requirements    : Docker version 1.13.1, build 092cba3
# requirements    : docker-compose version 1.8.0
# notes           : developped & tested with Bash 4.3.48(1)-release on Bodhi Linux 16.04


# GLOBAL SETTINGS
readonly DOCKER_CONSOLE_INITIAL_DIR="$( pwd )"
readonly DOCKER_CONSOLE_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

readonly DOCKER_CONSOLE_SCRIPT_NAME=$(basename $0)
readonly DOCKER_CONSOLE_ARGS=($@)
readonly DOCKER_CONSOLE_ARGNUM=$#

if [ -z ${CUSTOM_DOCKERS_PROJECTS_PREFIX} ]
then
  readonly DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX=$CUSTOM_DOCKERS_PROJECTS_PREFIX
else
  readonly DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX="adshares"
fi

# CONSOLE general help

function console_help {

    echo
    echo Usage: $DOCKER_CONSOLE_SCRIPT_NAME COMMAND ARGUMENTS OPTIONS
    echo
    echo "Available commands (order of usage):"
    echo
    echo " * [help] - displays this output"
    echo " * [list] - list available PROJECTS"
    echo
    echo " * [link] (PROJECT-NAME) (PATH) - link your project with your workspace repository dir"
    echo " * [proxy] (PROJECT-NAME) (PATH) - link your project host NGINX proxy configuration to your sites-enabled (requires sudo access and NGINX)"
    echo
    echo " * [build] (PROJECT-NAME) - TODO (build ALL)"
    echo " * [up] (PROJECT-NAME) - TODO (up ALL)"
    echo " * [down] (PROJECT-NAME) - TODO (down ALL)"
    echo " * [start] (PROJECT-NAME) - TODO (start ALL)"
    echo " * [stop] (PROJECT-NAME) - TODO (stop ALL)"
    echo
    echo
}

# REPO FUNCTIONS (order of usage, general to detail)

function console_repo_list {
  echo
  echo List of available projects to setup:
  echo
  for i in `find . -maxdepth 1 -type d | sed 's/\.\///g' | grep -v '^\.$'`; do echo "   $i"; done
  echo
}

function console_repo_exist {
  for i in `find . -maxdepth 1 -type d | sed 's/\.\///g' | grep -v '^\.$'`
  do
    if [ "$i" == "$1" ]
    then
      return 0;
    fi
  done
  echo
  echo "ERROR!!"
  echo
  echo "   Project directory does not exist : $1"
  echo
  console_repo_list
  exit 1
}

function console_repo_link {
  dev_repo_link="$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/dev_repo
  if [ -e $dev_repo_link ]; then
    dev_repo_link_target=$(readlink -f $dev_repo_link)
    echo
    echo "Error: Already linked repository $1 with $dev_repo_link_target"
    echo
    exit 1
  fi
  if [ ! -e "$2/.git" ]; then
    echo
    echo "Error: not a valid git repository path: $2"
    echo
    exit 1
  fi
  ln -s $2 $dev_repo_link
  cp "$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/docker-compose.yml.tpl "$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/docker-compose.yml
  SED_VAR=$(sed 's/\//\\\//g' <<< "$2")
  sed -i "s/DEV_REPO/$SED_VAR/g" "$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/docker-compose.yml
  echo
  echo "Project linked with repository directory as requested"
  echo
}

function console_repo_link_check {
  dev_repo_link="$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/dev_repo
  if [ ! -e $dev_repo_link ]; then
    echo
    echo "Error: Project $1 has no dev repo linked"
    echo
    exit 1
  fi
}

# HOST PROXY

function console_repo_host_proxy {
  proxy_file="$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/local.host-proxy.site.nginx.conf
  if [ ! -e "$proxy_file" ]
  then
    echo
    echo "Error: Missing $proxy_file for nginx proxy auto configuration"
    echo
    exit 1
  fi
  proxy_link_target="$(echo "$(head -n 1 $proxy_file | cut -d '#' -f2)" | sed 's/ //g')"
  nginx_path=${2%/}
  if [ ! -d "$nginx_path" ]
  then
    echo
    echo "Error: Path $nginx_path is not a directory"
    echo
    exit 1
  fi
  proxy_link_target="$nginx_path"/"$proxy_link_target"
  if [ -e "$proxy_link_target" ]
  then
    echo
    echo "Error: Proxy link target $proxy_link_target already exists"
    echo
    exit 1
  fi
  echo "Linking $1 proxy configuration file to $proxy_link_target"
  sudo ln -s $proxy_file $proxy_link_target
  if [ ! -e "$proxy_link_target" ]
  then
    echo
    echo "Error: Linking failed"
    echo
    exit 1
  fi
  echo "DONE!"
  echo
  echo -e "\e[31mIMPORTANT: Please RESTART your NGINX server for the changes to be applied\e[39m"
  echo
}

# TODO (yodahack) : prepare base configuration file (LATER?)

# CONFIGURATION

# TODO (yodahack) : func configure repo directory for dev dockerization
# TODO (yodahack) : func configure repo settings for dev dockerization
# TODO (yodahack) : func check if (ALL) repo(s) is configured

# BUILD

function console_docker_compose_build {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  docker-compose -p "$DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX-$1" build
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# TODO (yodahack) : func build all selected(/ALL) repo(s) containers

# UP

function console_docker_compose_up {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-up.sh ]
  then
    ./pre-up.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX-$1" up -d
  if [ -e ./post-up.sh ]
  then
    ./post-up.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# DOWN

function console_docker_compose_down {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-down.sh ]
  then
    ./pre-down.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX-$1" down
  if [ -e ./post-down.sh ]
  then
    ./post-down.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# START

function console_docker_compose_start {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-start.sh ]
  then
    ./pre-start.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX-$1" start
  if [ -e ./post-start.sh ]
  then
    ./post-start.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# STOP

function console_docker_compose_stop {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-stop.sh ]
  then
    ./pre-stop.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKERS_PROJECTS_PREFIX-$1" stop
  if [ -e ./post-stop.sh ]
  then
    ./post-stop.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# MAIN LOOP

cd $DOCKER_CONSOLE_SCRIPT_DIR

if [ "$#" -eq 0 ]
then
  echo
  echo "Do you need [help|-h|--help] ?"
  echo
  exit 0
fi

while [ "$#" -gt 0 ]
do
  case "$1" in
    -h|--help|help)
      console_help
      exit 0
      ;;
    list)
      console_repo_list
      exit 0
      ;;
    link)
      console_repo_exist $2
      console_repo_link $2 $3
      exit 0
      ;;
    proxy)
      console_repo_exist $2
      console_repo_host_proxy $2 $3
      exit 0
      ;;
    build)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_compose_build $2
      exit 0
      ;;
    up)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_compose_up $2
      exit 0
      ;;
    down)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_compose_down $2
      exit 0
      ;;
    start)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_compose_start $2
      exit 0
      ;;
    stop)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_compose_stop $2
      exit 0
      ;;
    *);;
  esac
  shift
done
