#!/bin/bash

# Grab versions from txt file
. ./version.txt

# Build panel
function BuildPanel() {
    echo "[BuildPanel]: Building mrflutters/pterodactyl-panel:$PANEL_VERSION"
    if [ "$noCache" = true ]; then
        DOCKER_BUILDKIT=1 docker build --no-cache --build-arg VERSION=$PANEL_VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION -t mrflutters/pterodactyl-panel:$PANEL_VERSION ./panel 2>&1 | tee ./logs/panel.log
    else
        DOCKER_BUILDKIT=1 docker build --build-arg VERSION=$PANEL_VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION -t mrflutters/pterodactyl-panel:$PANEL_VERSION ./panel 2>&1 | tee ./logs/panel.log
    fi
    echo "[BuildPanel]: Finished building mrflutters/pterodactyl-panel:$PANEL_VERSION"
}

# Build Daemon
function BuildDaemon() {
    echo "[BuildDaemon]: Building mrflutters/pterodactyl-daemon:$DAEMON_VERSION"
    if [ "$noCache" = true ]; then
        DOCKER_BUILDKIT=1 docker build --no-cache --build-arg VERSION=$DAEMON_VERSION --build-arg=$ALPINE_VERSION -t mrflutters/pterodactyl-daemon:$DAEMON_VERSION ./daemon 2>&1 | tee ./logs/daemon.log
    else
        DOCKER_BUILDKIT=1 docker build --build-arg VERSION=$DAEMON_VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION -t mrflutters/pterodactyl-daemon:$DAEMON_VERSION ./daemon 2>&1 | tee ./logs/daemon.log
    fi
    echo "[BuildDaemon]: Finished building mrflutters/pterodactyl-daemon:$DAEMON_VERSION"
}

# Build Dedicated SFTP Server
function BuildSFTP() {
    echo "[BuildSFTP]: Building mrflutters/pterodactyl-sftp:$SFTP_VERSION"
    if [ "$noCache" = true ]; then
        DOCKER_BUILDKIT=1 docker build --no-cache --build-arg VERSION=$SFTP_VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION -t mrflutters/pterodactyl-sftp:$SFTP_VERSION ./sftp 2>&1 | tee ./logs/sftp.log
    else
        DOCKER_BUILDKIT=1 docker build --build-arg VERSION=$SFTP_VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION -t mrflutters/pterodactyl-sftp:$SFTP_VERSION ./sftp 2>&1 | tee ./logs/sftp.log
    fi
    echo "[BuildSFTP]: Finished building mrflutters/pterodactyl-sftp:$SFTP_VERSION"
}

function PushImages() {
    # Temp variables
    panelPush=false
    daemonPush=false
    sftpPush=false

    if [ "$buildPanel" = true ]; then
        docker push mrflutters/pterodactyl-panel:$PANEL_VERSION
        panelPush=true
    fi
    if [ "$buildDaemon" = true ]; then
        docker push mrflutters/pterodactyl-daemon:$DAEMON_VERSION
        daemonPush=true
    fi
    if [ "$buildSFTP" = true ]; then
        docker push mrflutters/pterodactyl-sftp:$SFTP_VERSION
        sftpPush=true
    fi
    echo "---------------------"
    echo "-- Pushing Images --"
    echo "---------------------"
    if [ "$panelPush" = true ]; then
        echo "Build Panel Image : mrflutters/pterodactyl-panel:$PANEL_VERSION"
    fi
    if [ "$daemonPush" = true ]; then
        echo "Build Daemon Image : mrflutters/pterodactyl-daemon:$DAEMON_VERSION"
    fi
    if [ "$sftpPush" = true ]; then
        echo "Build SFTP Image : mrflutters/pterodactyl-sftp:$SFTP_VERSION"
    fi
}

function cleanLogs() {
    rm ./logs/*.log 2>&1 | tee /dev/null
}

function Main() {
    # Help Message
    headerText="\
---------------------------------
Hotaru's Pterodactyl build script
---------------------------------"

    helpText="\
-p,  --autoPush           Automaticly push images to hub.docker.com after building
-c,  --noCache            Disable docker cache for builds
-bp, --buildPanel         Build Pterodactyl Panel (https://github.com/MrFlutters/pterodactyl-panel)
-bd, --buildDaemon        Build Pterodactyl Daemon (https://github.com/MrFlutters/pterodactyl-daemon)
-bs, --buildSFTP          Build Pterodactyl Standalone SFTP (https://github.com/MrFlutters/pterodactyl-sftp)
-ba, --buildAll           Build all Docker Images
-h,  --help               This help text"

    # Make sure their false by default
    buildPanel=$false
    buildDaemon=$false
    buildSFTP=$false
    autoPush=$false
    noCache=$false
    showHelp=$false

    # Process Arguements
    SCRIPT_ARGS="$@"
    while [ $# -ne 0 ]; do
        case $1 in
        -p | --push)
            autoPush=true
            ;;
        -c | --noCache)
            noCache=true
            ;;
        -bp | --buildPanel)
            buildPanel=true
            ;;
        -bd | --buildDaemon)
            buildDaemon=true
            ;;
        -bs | --buildSFTP)
            buildSFTP=true
            ;;
        -ba | --buildAll)
            buildPanel=true
            buildDaemon=true
            buildSFTP=true
            ;;
        -h | --help)
            showHelp=true
            ;;
        esac
        shift
    done
    if [ "$showHelp" = true ]; then
        echo -e "$headerText"
        echo -e "$helpText"
    else
        cleanLogs
        if [ "$buildPanel" = true ]; then
            BuildPanel buildPanel=$buildPanel buildDaemon=$buildDaemon buildSFTP=$buildSFTP autoPush=$autoPush noCache=$noCache
        fi

        if [ "$buildDaemon" = true ]; then
            BuildDaemon buildPanel=$buildPanel buildDaemon=$buildDaemon buildSFTP=$buildSFTP autoPush=$autoPush noCache=$noCache
        fi

        if [ "$buildSFTP" = true ]; then
            BuildSFTP buildPanel=$buildPanel buildDaemon=$buildDaemon buildSFTP=$buildSFTP autoPush=$autoPush noCache=$noCache
        fi

        if [ "$autoPush" = true ]; then
            PushImages buildPanel=$buildPanel buildDaemon=$buildDaemon buildSFTP=$buildSFTP autoPush=$autoPush
        fi
    fi
}
Main $@
