# System Monitoring Script

This script monitors various system resources such as CPU usage, memory usage, and disk usage. It can also track the top processes that are consuming the most CPU. The script can generate reports in three formats: **text**, **JSON**, and **CSV**. It runs in a continuous loop, collecting system data at specified intervals, and saves the results in the desired format.

## Features

- Monitors CPU usage, memory usage, and disk usage.
- Tracks the top processes based on CPU usage.
- Supports three report formats: text, JSON, and CSV.
- Allows for customizable reporting intervals.
- Provides alerts if any monitored resource exceeds predefined thresholds:
  - CPU usage > 80%
  - Memory usage > 75%
  - Disk usage > 90%

## Requirements

The following commands must be installed on your system for the script to work properly:
- `top`
- `ps`
- `free`
- `df`
- `jq` (for JSON formatting)

You can install missing commands depending on your operating system. For example, on Linux, you can use `apt-get install <command>`.

## How to Use

### Running the Script

To run the script, use the following command:

```bash
./monitor_system.sh <interval> <output_file> <format>
```

Where:
- `<interval>` is the time interval (in seconds) between each system check. For example, `10` will check every 10 seconds.
- `<output_file>` is the name of the file where the report will be saved. For example, `system_report.json` for a JSON report.
- `<format>` is the report format: `text`, `json`, or `csv`.

### Example Usage

1. To run the script and generate a JSON report every 10 seconds:

   ```bash
   ./monitor_system.sh 10 system_report.json json
   ```

2. To generate a text report every 30 seconds:

   ```bash
   ./monitor_system.sh 30 system_report.txt text
   ```

3. To generate a CSV report every minute:

   ```bash
   ./monitor_system.sh 60 system_report.csv csv
   ```

### Alerts

- **CPU Usage Alert**: Triggered if CPU usage exceeds 80%.
- **Memory Usage Alert**: Triggered if memory usage exceeds 75%.
- **Disk Usage Alert**: Triggered if disk usage exceeds 90%.

## How It Works

- **System Information**: The script collects data on CPU, memory, disk usage, and the top processes by CPU consumption using `top`, `free`, `df`, and `ps`.
- **Check Alerts**: It checks if any of the resource usage values exceed the thresholds for CPU, memory, or disk, and prints an alert if necessary.
- **Report Generation**: Based on the chosen format (text, JSON, or CSV), the script saves the collected data into the specified output file.
- **Continuous Monitoring**: The script runs in a loop, checking the system at regular intervals until it is manually stopped.

## Error Handling

- The script checks if all required commands (`top`, `ps`, `free`, `df`) are available before running.
- If the interval is not a positive integer or if the format is invalid, the script will exit with an error message.
- Alerts will be triggered if any monitored resource exceeds the set thresholds.

## Contributing

Feel free to fork this repository and contribute to improving the script. You can open issues for bugs or enhancements, and pull requests are always welcome.

---

### Notes

- Make sure to give the script executable permissions:

  ```bash
  chmod +x monitor_system.sh
  ```

- If you encounter any issues, ensure that the required commands are installed on your system.
