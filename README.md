# Kuzco-maintenance
Maintenance shell script for Kuzco running.  
The script will auto restart Kuzco worker when meeting `TimeoutError: The operation timed out` or `CUDA error`.  
In addition, it will also restart Kuzco worker after running continuously for one hour.

## Usage
### Run
```
git clone https://github.com/DreamGallery/Kuzco-maintenance.git
cp Kuzco-maintenance/kz-maint.sh kz-maint.sh && chmod +x kz-maint.sh
nohup ./kz-maint.sh >> start-kz.log 2>&1 &
```
The output of the script is in the `start-kz.log` file, and the worker's is in `kz-worker.log`.  
Old log files will be moved to the `kzlog` folder.

### Stop
```
pkill -f "kz-maint.sh" && pkill -f "kuzco"
```

### Discord alert
If you want to receive alert messages in your discord, please create a `.env` file in the same path as the script,  
and add your discord webhook link like this
```
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/
```
