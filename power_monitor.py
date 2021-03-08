import sys
import time
from experiment_impact_tracker.compute_tracker import ImpactTracker

tracker = ImpactTracker(sys.argv[1])
tracker.launch_impact_monitor()

while(True):
    tracker.get_latest_info_and_check_for_errors()
    time.sleep(1) # sleep for 1 second to unify with nvidia-smi monitor
