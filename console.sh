#!/bin/bash
# description     : dockerization console for development setup of adshares.net components
# author		      : github.com/yodahack
# version         : 0.1-dev
# requirements    : Docker version 1.13.1, build 092cba3
# requirements    : docker-compose version 1.8.0
# notes           : developped & tested with Bash 4.3.48(1)-release on Bodhi Linux 16.04


# GLOBAL SETTINGS
if [ -z "$DOCKER_CONSOLE_INITIAL_DIR" ]
then
  readonly DOCKER_CONSOLE_INITIAL_DIR="$( pwd )"
  readonly DOCKER_CONSOLE_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  readonly DOCKER_CONSOLE_SCRIPT_NAME=$(basename $0)
  readonly DOCKER_CONSOLE_ARGS=($@)
  readonly DOCKER_CONSOLE_ARGNUM=$#
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
    echo " * [link] (PROJECT-NAME) (REPO-PATH) - link your project with project repository DEV_REPO"
    echo " * [unlink] (PROJECT-NAME) - unlink your project with project repository DEV_REPO"
    # echo " * [link] (PROJECT-NAME) (REPO-PATH) (REPO_SYMBOL) - link your project with selected project repository REPO_SYMBOL"
    echo " * [proxy] (PROJECT-NAME) (PATH) - link your project host NGINX proxy configuration to your sites-enabled (requires sudo access and NGINX)"
    echo
    echo " * [build] (PROJECT-NAME)"
    echo " * [rebuild] (PROJECT-NAME)"
    echo " * [up] (PROJECT-NAME)"
    echo " * [down] (PROJECT-NAME)"
    echo " * [start] (PROJECT-NAME)"
    echo " * [stop] (PROJECT-NAME)"
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
  dev_repo_link="$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/DEV_REPO
  link_path=$(realpath $2)
  if [ -e $dev_repo_link ]; then
    dev_repo_link_target=$(cat $dev_repo_link)
	echo
    echo "Already linked repository $1 with $dev_repo_link_target"
	echo "Unlinking..."
    console_repo_unlink $1
  fi
  if [ ! -e "$link_path/.git" ]; then
    echo
    echo "Error: not a valid git repository path: $link_path"
    echo
    exit 1
  fi
  echo $link_path > $dev_repo_link
  cp "$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/docker-compose.yml.tpl "$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/docker-compose.yml
  SED_VAR=$(sed 's/\//\\\//g' <<< "$link_path")
  sed -i "s/DEV_REPO/$SED_VAR/g" "$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/docker-compose.yml
  echo
  echo "Project linked with repository directory as requested"
  echo
}

function console_repo_unlink {
  dev_repo_link="$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/DEV_REPO
  if [ -e $dev_repo_link ]; then
    rm $dev_repo_link
    if [ $? -eq 0 ]; then
        echo
        echo "Project unlinked as requested"
        echo
    fi
  else
    console_repo_link_check $1
  fi
}

function console_repo_link_check {
  dev_repo_link="$DOCKER_CONSOLE_SCRIPT_DIR"/"$1"/DEV_REPO
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

# DOCKER PROJECT

function console_docker_project_var_set {

  if [ -e $DOCKER_CONSOLE_SCRIPT_DIR/$1/docker-project ]
  then
    readonly DOCKER_CONSOLE_DOCKER_PROJECT=`head -n 1 $DOCKER_CONSOLE_SCRIPT_DIR/$1/docker-project`
    return 0;
  fi

  # fallback
  readonly DOCKER_CONSOLE_DOCKER_PROJECT="adshares-$1"
}

# BUILD

function console_docker_compose_build {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-build.sh ]
  then
    ./pre-build.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKER_PROJECT" build
  if [ -e ./post-build.sh ]
  then
    ./post-build.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# TODO (yodahack) : func build all selected(/ALL) repo(s) containers

# REBUILD

function console_docker_compose_rebuild {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-build.sh ]
  then
    ./pre-build.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKER_PROJECT" build --no-cache
  if [ -e ./post-build.sh ]
  then
    ./post-build.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# UP

function console_docker_compose_up {

  cd $DOCKER_CONSOLE_SCRIPT_DIR/$1
  if [ -e ./pre-up.sh ]
  then
    ./pre-up.sh
  fi
  docker-compose -p "$DOCKER_CONSOLE_DOCKER_PROJECT" up -d
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
  docker-compose -p "$DOCKER_CONSOLE_DOCKER_PROJECT" down
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
  docker-compose -p "$DOCKER_CONSOLE_DOCKER_PROJECT" start
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
  docker-compose -p "$DOCKER_CONSOLE_DOCKER_PROJECT" stop
  if [ -e ./post-stop.sh ]
  then
    ./post-stop.sh
  fi
  cd $DOCKER_CONSOLE_SCRIPT_DIR
}

# MAIN LOOP

cd $DOCKER_CONSOLE_SCRIPT_DIR

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
    unlink)
      console_repo_unlink $2
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
      console_docker_project_var_set $2
      console_docker_compose_build $2
      exit 0
      ;;
    rebuild)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_project_var_set $2
      console_docker_compose_rebuild $2
      exit 0
      ;;
    up)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_project_var_set $2
      console_docker_compose_up $2
      exit 0
      ;;
    down)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_project_var_set $2
      console_docker_compose_down $2
      exit 0
      ;;
    start)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_project_var_set $2
      console_docker_compose_start $2
      exit 0
      ;;
    stop)
      console_repo_exist $2
      console_repo_link_check $2
      console_docker_project_var_set $2
      console_docker_compose_stop $2
      exit 0
      ;;
    *);;
  esac
  shift
done

echo
echo "What's up ???"
echo "Do you need [help|-h|--help] ?"
echo
