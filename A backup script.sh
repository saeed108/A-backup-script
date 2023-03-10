#!/bin/bash

if [ "$#" -ne 2 ]; then
   echo "Fel: 2 argument krävs - Mappen som ska säkerhetskopieras, remotas IP och destinationsmappen för säkerhetskopieringsarkivet."
   exit 1
fi

# Source directory and target directory.
src_dir=$1
target_dir=$2

if [[ $target_dir == *":"* ]]; then

# To remote targets, use rsync over ssh
  server_dir=$target_dir
  server=$(echo $server_dir | awk -F':' '{print $1}')
  remote_dir=$(echo $server_dir | awk -F':' '{print $2}')
 
  timestamp=$(date +%Y-%m-%d_%H-%M-%S)
  backup_dir="$remote_dir/$timestamp"
  ssh $server "mkdir $backup_dir"

  rsync -avz -e "ssh -T" --link-dest=$server:$remote_dir/latest $src_dir $server:$backup_dir

# The latest backup, will be updated the symlink
  ssh $server "ln -snf $backup_dir $remote_dir/latest"

else
  # To local targets will use local rsync  

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
 backup_dir="$target_dir/$timestamp"

 mkdir $backup_dir

 rsync -avz --link-dest=$target_dir/latest $src_dir $backup_dir

# Update the symlink for the latest backup
 ln -snf $backup_dir $target_dir/latest

fi