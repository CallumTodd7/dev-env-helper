dev-env-prepare-docker-files() {
    export COMPOSE_PROJECT_NAME=dv
    dockerfilelist=$(<./.docker-compose-file-list)
    export COMPOSE_FILE=$dockerfilelist
}

de() {
    if [ -e "./.dev-env-context" ]
    then
        local cmd=$1

        # Commands
        if [ $cmd = "up" ]; then source run.sh up
        elif [ $cmd = "reload" ]; then source run.sh reload
        elif [ $cmd = "halt" ] || [ $cmd = "down" ]; then source run.sh halt 
        elif [ $cmd = "repair" ]; then source run.sh repair 
        elif [ $cmd = "git" ] || [ $cmd = "g" ]; then bash ./scripts/git_list.sh
        fi
    elif [ -e "./../../.dev-env-context" ]; then
        local cmd=$1
        local x=2
        if [ ! -z $CONTAINER ]; then # if $CONTAINER env var not empty
            local container=$CONTAINER # Set container var to env var
        else
            local container=${PWD##*/} # Set container var to directory name
        fi

        if [ $1 = "-c" ]; then # if first arg is "-c"
            local container=$2 # Set container var to specified container name
            local cmd=$3 # Change the cmd arg number
            local x=4 # Change where the cmd args start
        fi

        # echo "$cmd $container ${@:${x}}"

        # Commands
        if [ $cmd = "start" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose start $container )
        elif [ $cmd = "stop" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose stop $container )
        elif [ $cmd = "reload" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose restart $container )
        elif [ $cmd = "restart" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose restart $container )
        elif [ $cmd = "rebuild" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose up --build -d $container )
        elif [ $cmd = "run" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose run --rm $container );
        elif [ $cmd = "bashin" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose exec $container bash )
        elif [ $cmd = "ex" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker exec $container ${@:${x}} )
        elif [ $cmd = "unittest" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose exec $container make unittest )
        elif [ $cmd = "manage" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose exec $container python3 manage.py ${@:${x}} )
        elif [ $cmd = "alembic" ]; then ( cd ../.. && dev-env-prepare-docker-files && docker-compose exec $container bash -c 'cd /src && export SQL_USE_ALEMBIC_USER=yes && export SQL_PASSWORD=superroot && python3 manage.py db '"${@:${x}}"'' )
        else echo "Command for 'de' not found"; fi
    else
        echo "Not in dev env app dir."
        return 1
    fi
}
