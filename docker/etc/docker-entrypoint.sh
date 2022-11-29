#!/bin/sh

#String Colors
NC='\033[0;m'      # Default Color
GRN='\033[32;1m'
RED='\033[31;1m'
BLK='\033[30;1m'

# Set the number of cpu cores
export NUM_CPUS=`nproc`

# Run custom script before the main docker process gets started
for f in /docker-entrypoint.init.d/*; do
    case "$f" in
        *.sh) # this should match the set of files we check for below
            echo "⚙	 Executing entrypoint.init file: ${f}"
            . $f
            break
            ;;
    esac
done

if [ "$1" = 'supervisor' ]; then
    EXEC="/usr/bin/supervisord -c /etc/supervisord.conf"

    printf "\n${GRN}--->${NC} 🚀️️	 Starting ${GRN}Gearman UI${NC} container..."
    printf "\n${GRN}--->${NC} Build date: ${GRN}${BUILD_DATE}${NC}, Build version: ${GRN}${BUILD_VER}${NC}"
    printf "\n${GRN}--->${NC} Exec command: ${EXEC}\n\n"

    exec ${EXEC}
fi

exec "$@"
