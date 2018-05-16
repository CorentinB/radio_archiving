#!/usr/bin/env bash

# Path to the urls.txt file. Is used as input for downloading with axel
URLS="$HOME/urls.txt"

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
    mkdir -p "$HOME/$project_NAME"
    local exitTITLE="Confirmation"
    local exitMSG="Your project path is: $HOME/$project_NAME"
    whiptail --title "$exitTITLE" --msgbox "$exitMSG" 10 60

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

function _THREADS() {
  wc -l <"$URLS"
}

function _parallelize() {
  local NOW="date +'%d-%m-%Y-%H-%M-%S'"
  #"--shuf"
  #'--load=50%'
  #'--memfree=128M'
  #'--noswap'
  parallelARGS=(
    #  "--delay=3"
    "--joblog=$HOME/$project_NAME/_RADIOHEAD-parallel.log"
    "--jobs=$(_THREADS)"
    "--link"
    "--progress"
    '--delay'
    '-x'
  )
  wgetARGS=(
    '--random-wait'
    '--no-clobber'
    "--append-output=$HOME/$project_NAME/_Wget.log"
    "--rejected-log=$HOME/$project_NAME/_WgetRejects.log"
    "--directory-prefix=$HOME/$project_NAME/{/}"
    '--timeout=0'
  )

  echo "Printing Job file for downloading"
  local JOBS="$HOME/$project_NAME/_RADIOHEAD-jobs.txt"
  parallel --link -x echo "timeout $PICKTIME wget ${wgetARGS[*]} {}" :::: $URLS | tee "$JOBS"

  echo "starting $(_THREADS) threads from $URLS to $HOME/$project_NAME"
  parallel "${parallelARGS[@]}" :::: $JOBS
}

_ProjectNameInput && _gdriveInput && _PickTime && _parallelize
