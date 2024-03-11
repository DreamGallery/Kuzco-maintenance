# Kuzco-maintenance
Maintenance shell script for Kuzco running.  
The script will auto restart Kuzco worker when meeting `TimeoutError: The operation timed out` or `CUDA error`.  
In addition, it will also restart Kuzco worker after running continuously for one hour.

## Usage
### Run
```
git clone https://github.com/DreamGallery/Kuzco-maintenance.git
cd Kuzco-maintenance && chmod +x kz-maint.sh
nohup ./kz-maint.sh >> start-kz.log 2>&1 &
```
The output of the script is in the `start-kz.log` file, and the worker's is in `kz-worker.log`.  
Old log files will be moved to the `kzlog` folder.

### Stop
```
pkill -f "kz-maint.sh" && pkill -f "kuzco"
```
