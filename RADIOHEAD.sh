#!/usr/bin/env bash

# Path to the urls.txt file. Is used as input for downloading with axel
URLS="$HOME/urls.txt"
PROJECTPATH="$HOME/$project_NAME"

function _jim() {
  "$@" || { echo "he's dead jim: $@" && exit 1; }
}

function _polly() {
  whiptail --title "YOU SHALL NOT PASS" \
  --msgbox Exiting 10 60
  clear
  curl -s parrot.live
}

function _ProjectNameInput() {
  local TITLE="Project Name Input Box"
  local PROMPT="What is your project name?"
  project_NAME=$(whiptail --title "$TITLE" --inputbox "$PROMPT" 10 60 3>&1 1>&2 2>&3)

  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    local exitTITLE="Confirmation"
    local exitMSG="Your project path is: $HOME/$project_NAME"
    whiptail --title "$exitTITLE" --msgbox "$exitMSG" 10 60
    echo
    mkdir -p "$PROJECTPATH"
  else
    _polly
  fi
}

function _gdriveInput() {
  local TITLE="Gsuite Name Input Box"
  local PROMPT="Rclone Gdrive account name for uploading?"
  GDRIVE=$(
    whiptail --title "$TITLE" --inputbox "$PROMPT" 10 60 3>&1 1>&2 2>&3
  )

  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    local exitTITLE="Confirmation"
    local exitMSG="Gdrive account for uploading will be $GDRIVE:"
    whiptail --title "$exitTITLE" --msgbox "$exitMSG" 10 60
  else
    _polly
  fi
}

function _PickTime() {
  local TITLE="Time Length Menu Dialog"
  local PROMPT="Choose the duration of the radio stream to be saved"
  PICKTIME=$(
    whiptail --title "$TITLE" --menu "$PROMPT" 15 60 4 \
    "1" "5m" \
    "2" "1h" \
    "3" "12h" \
    "4" "24h" 3>&1 1>&2 2>&3
  )

  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    local exitTITLE="Confirmation"
    local exitMSG="Your chosen option: $PICKTIME"
    whiptail --title "$exitTITLE" --msgbox "$exitMSG" 10 60
  else
    _polly
  fi
}

function _parallelize() {
  local NOW="date +'%d-%m-%Y-%H-%M-%S'"
  local THREADS=$(cat urls.txt | wc -l)
  local parallelARGS=(
    "--delay=3"
    "--joblog=$PROJECTPATH/_RADIOHEAD-parallel.log"
    "--jobs=$THREADS"
    "--link"
    "--progress"
    #"--shuf"
    #'--load=50%'
    #'--memfree=128M'
    '--delay'
    #'--noswap'
    '--resume-failed'
    '--retries=3'
    '--pipepart'
  )

  local wgetARGS=(
    '--random-wait'
    '--no-clobber'
    "--append-output=$PROJECTPATH/_Wget.log"
    "--rejected-log=$PROJECTPATH/_WgetRejects.log"
    "--directory-prefix=$PROJECTPATH"
    "--timeout=0"
  )
  local WGET=$(timeout "$PICKTIME" wget "${wgetARGS[@]}" {})
  cat $URLS | parallel "${parallelARGS[@]}" "$WGET"
}

_ProjectNameInput && _gdriveInput && _PickTime && _parallelize
