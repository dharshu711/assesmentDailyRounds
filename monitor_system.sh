#!/bin/bash

MEMORY_THRESHOLD=75
CPU_THRESHOLD=80
DISK_THRESHOLD=90
OUTPUT_FILE="system_report.txt"
INTERVAL=60
OUTPUT_FORMAT="txt"

usage() {
    echo "Usage: $0 [--interval <interval>] [--format <format>]"
    exit 1
}

check_dependencies() {
    for cmd in ps top awk df free bc; do
        command -v $cmd &>/dev/null || { echo "$cmd not found."; exit 1; }
    done
}

check_os() {
    [[ $(uname -s) =~ (Linux|Darwin) ]] || { echo "Unsupported OS"; exit 1; }
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --interval) INTERVAL=$2; shift 2 ;;
        --format) OUTPUT_FORMAT=$2; shift 2 ;;
        *) usage ;;
    esac
done

output_json() {
    echo "{" | tee -a $OUTPUT_FILE
    echo "  \"timestamp\": \"$(date)\"," | tee -a $OUTPUT_FILE
    echo "  \"memory_usage\": \"$1\"," | tee -a $OUTPUT_FILE
    echo "  \"cpu_usage\": \"$2\"," | tee -a $OUTPUT_FILE
    echo "  \"disk_usage\": \"$3\"," | tee -a $OUTPUT_FILE
    ps aux --sort=-%cpu | head -n 6 | awk 'NR>1 {print "    {\"process\": \"" $11 "\", \"cpu\": \"" $3 "\"},"}' | tee -a $OUTPUT_FILE
    ps aux --sort=-%mem | head -n 6 | awk 'NR>1 {print "    {\"process\": \"" $11 "\", \"mem\": \"" $4 "\"},"}' | tee -a $OUTPUT_FILE
    echo "}" | tee -a $OUTPUT_FILE
}

output_csv() {
    echo "timestamp,memory_usage,cpu_usage,disk_usage,top_cpu_processes,top_mem_processes" | tee -a $OUTPUT_FILE
    CPU_PROCESSES=$(ps aux --sort=-%cpu | head -n 6 | awk 'NR>1 {print $11 ":" $3}' | tr '\n' ' ')
    MEM_PROCESSES=$(ps aux --sort=-%mem | head -n 6 | awk 'NR>1 {print $11 ":" $4}' | tr '\n' ' ')
    echo "$(date),$1,$2,$3,\"$CPU_PROCESSES\",\"$MEM_PROCESSES\"" | tee -a $OUTPUT_FILE
}

output_txt() {
    echo -e "Memory Usage: $1%\nCPU Usage: $2%\nDisk Usage: $3%" | tee -a $OUTPUT_FILE
    if (( $(echo "$1 > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "Warning: Memory usage exceeds threshold!" | tee -a $OUTPUT_FILE
    fi
    if (( $(echo "$2 > $CPU_THRESHOLD" | bc -l) )); then
        echo "Warning: CPU usage exceeds threshold!" | tee -a $OUTPUT_FILE
    fi
    if (( $3 > $DISK_THRESHOLD )); then
        echo "Warning: Disk usage exceeds threshold!" | tee -a $OUTPUT_FILE
    fi
    ps aux --sort=-%cpu | head -n 6 | tee -a $OUTPUT_FILE
    ps aux --sort=-%mem | head -n 6 | tee -a $OUTPUT_FILE
}

check_dependencies
check_os

while true; do
    MEMORY_USAGE=$(free -m | awk '/Mem:/ {print $3/$2 * 100.0}')
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/., *\([0-9.]\)%* id.*/\1/" | awk '{print 100 - $1}')
    DISK_USAGE=$(df -h | awk '$NF=="/" {gsub(/%/,""); print $5}')

    case $OUTPUT_FORMAT in
        json) output_json "$MEMORY_USAGE" "$CPU_USAGE" "$DISK_USAGE" ;;
        csv) output_csv "$MEMORY_USAGE" "$CPU_USAGE" "$DISK_USAGE" ;;
        *) output_txt "$MEMORY_USAGE" "$CPU_USAGE" "$DISK_USAGE" ;;
    esac

    sleep $INTERVAL
done
