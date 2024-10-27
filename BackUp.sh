#!/bin/bash

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

compress_format() {
    while true;do
        echo "Choose from following formats: (tar, zip, rar):"
        read format
        if [ "$format" != "tar" ] && [ "$format" != "zip" ] &&
            [ "$format" != "rar" ]; then
                echo "Invalid format"
        else
            backupFormat="$format"
            return;
        fi
    done
}

# Check for the correct number of command line arguments
if [ $# -lt 2 ]; then
    echo "Please provide at least one <source_directory1> and <destination_directory>"
    exit 1
fi

# the destination directory 
backup_dir="${!#}"

# source directories
source_dirs=("${@:1:$(($#-1))}")

if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
    if [ $? -ne 0 ]; then
        log_message "Error: Failed to create backup directory $backup_dir"
        exit 1
    fi
fi

for dir in "${source_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        log_message "Error: Source directory '$dir' does not exist."
        exit 1
    fi
done

log_file="$backup_dir/backup.log"
if [ ! -d "$(dirname "$log_file")" ]; then
    mkdir -p "$(dirname "$log_file")"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create log directory $(dirname "$log_file")"
        exit 1
    fi
fi

log_message "Log file created at $log_file"

total_size=$(du -shc "${source_dirs[@]}" | grep total$ | awk '{print $1}')
log_message "Total size of the source directories to backup: $total_size"

startTime=$(date +%s)

read -p "Do you want to compress the backup file? (y/n): " user_confirmation

if [[ "$user_confirmation" == "y" ]]; then
    compress_format

      if ! command -v $1 > /dev/null 2>&1; then
        echo "Installing $1 package..."
        sudo apt-get update > /dev/null 2>&1
        sudo apt-get install $1 > /dev/null 2>&1
    fi

    case $backupFormat in
        tar)
            dest="$backup_dir/backup.tar.gz"
            log_message "Starting the backup with tar compression"
            tar -czf "$dest" "${source_dirs[@]}" > /dev/null 2>&1
            ;;
        zip)
            dest="$backup_dir/backup.zip"
            log_message "Starting the backup with zip compression"
            zip -r "$dest" "${source_dirs[@]}" > /dev/null 2>&1
            ;;
        rar)
            dest="$backup_dir/backup.rar"
            log_message "Starting the backup with rar compression"
            rar a "$dest" "${source_dirs[@]}" > /dev/null 2>&1
            ;;
        *)
            echo "The Chosen Format not exists!!"
            dest="$backup_dir/backup.tar.gz"
            log_message "Starting the backup with defualt (tar) compression"
            tar -czf "$dest" "${source_dirs[@]}" > /dev/null 2>&1
            ;;
    esac
else
    dest="$backup_dir/backup.tar"
    log_message "Starting the backup without compression"
    tar cf "$dest" "${source_dirs[@]}" 2>> "$log_file"
fi

endTime=$(date +%s)
duration=$((endTime - startTime))


echo "Backup Duration: $duration seconds"

tar_status=$?

if [ $tar_status -ne 0 ]; then
    log_message "Error: Tar command exited with status $tar_status."
fi

log_message "Backup script ended."
