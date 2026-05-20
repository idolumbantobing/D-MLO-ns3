#!/bin/bash
export LOG_INFO="EhtFrameExchangeManager=level_info|prefix_time:WifiMac=level_info|prefix_time:ApWifiMac=level_info|prefix_time:StaWifiMac=level_info|prefix_time:FrameExchangeManager=level_info|prefix_time:QosFrameExchangeManager=level_info|prefix_time:HtFrameExchangeManager=level_info|prefix_time:WifiPhy=level_info|prefix_time:WifiAssocManager=level_info|prefix_time:WifiDefaultAssocManager=level_info"
export LOG_FUNCTION="EhtFrameExchangeManager=level_info|prefix_time:WifiMac=level_function|prefix_time:ApWifiMac=level_function|prefix_time:StaWifiMac=level_function|prefix_time:Txop=level_function|prefix_time:FrameExchangeManager=level_function|prefix_time:QosFrameExchangeManager=level_function|prefix_time:HtFrameExchangeManager=level_function|prefix_time:WifiPhy=level_info|prefix_time:WifiAssocManager=level_function|prefix_time:WifiDefaultAssocManager=level_function|prefix_time"

# Take the number of CPU cores available / manually change for the number of cores you want to use
core_num=$(( $(nproc --all) - 5 )) # Get the number of CPU cores available
if [ "$core_num" -lt 1 ]; then
    core_num=1 # Ensure at least one core is used
fi

option=$1

#################################################################################################
#
if [ "$option" == "build" ]; then
#
#################################################################################################
    build_mode=$2
    if [ "$build_mode" == "debug" ]; then
        ./ns3 clean
        ./ns3 configure --build-profile=debug --enable-examples --enable-tests --disable-werror
        ./ns3 build
    elif [ "$build_mode" == "optimized" ]; then
        ./ns3 clean
        ./ns3 configure --build-profile=optimized --enable-examples --enable-tests --disable-werror
        ./ns3 build
    fi
fi

#################################################################################################
#
if [ "$option" == "single" ]; then
#
#################################################################################################
    mode=$2

    if [ "$mode" == "dmlo12" ]; then
        
        reliabilityMode=false
        printOutput=true
        poissonLambda=500
        wallLoss=0
        seed=("23")
        maxMissedBeacons=4
        simulationTime=$((8*10)) # in seconds
        logging=$3
        simulation_file="scratch/wifi-dmlo12/wifi-ehr-roaming-scenario.cc"
        
        echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, reliabilityMode=$reliabilityMode, seed=$seed, wallLoss=$wallLoss, poissonLambda=$poissonLambda, printOutput=$printOutput, simulationTime=$simulationTime"
        pushd scratch/wifi-dmlo12/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd

        pushd scratch/wifi-dmlo12/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        if [ "$logging" == "no_log" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_plain.txt 2>&1 ) &
            ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime
        elif [ "$logging" == "log_info" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime ) &
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_plain.txt 2>&1 ) &
            NS_LOG=$LOG_INFO ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_info.txt 2>&1
            wait
        elif [ "$logging" == "log_function" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime ) &
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_plain.txt 2>&1 ) &
            (NS_LOG=$LOG_INFO ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_info.txt 2>&1) &
            NS_LOG=$LOG_FUNCTION ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_function.txt 2>&1
            wait
        elif [ "$logging" == "debug" ]; then
            ./ns3 run --gdb "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime
        fi

    elif [ "$mode" == "dmlo34" ]; then

        reliabilityMode=false
        printOutput=true
        poissonLambda=500
        wallLoss=12
        manualConnectionEnable=false
        manualReliabilityModeApp=false
        seed=("1")
        maxMissedBeacons=4
        enableMultiApCoordination=true
        enableMultiApRoaming=true
        simulationTime=$((8*10)) # in seconds
        logging=$3
        simulation_file="scratch/wifi-dmlo34/wifi-bn-jt-network.cc"

        echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, reliabilityMode=$reliabilityMode, seed=$seed, wallLoss=$wallLoss, poissonLambda=$poissonLambda, printOutput=$printOutput, simulationTime=$simulationTime"
        pushd scratch/wifi-dmlo34/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd

        pushd scratch/wifi-dmlo34/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        if [ "$logging" == "no_log" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp --enableMultiApCoordination=$enableMultiApCoordination --enableMultiApRoaming=$enableMultiApRoaming >log_plain.txt 2>&1 ) &
            ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp --enableMultiApCoordination=$enableMultiApCoordination --enableMultiApRoaming=$enableMultiApRoaming
            wait
        elif [ "$logging" == "log_info" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp) &
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp>log_plain.txt 2>&1 ) &
            NS_LOG=$LOG_INFO ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp >log_info.txt 2>&1
            wait
        elif [ "$logging" == "log_function" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp) &
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp>log_plain.txt 2>&1 ) &
            (NS_LOG=$LOG_INFO ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp>log_info.txt 2>&1) &
            NS_LOG=$LOG_FUNCTION ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp >log_function.txt 2>&1
            wait
        fi

    elif [ "$mode" == "mlo" ]; then
        
        printOutput=true
        poissonLambda=1500
        wallLoss=6
        seed=("23")
        maxMissedBeacons=4
        simulationTime=$((8*10)) # in seconds
        logging=$3
        simulation_file="scratch/wifi-mlo/wifi-eht-roaming-scenario.cc"
        echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, reliabilityMode=$reliabilityMode, seed=$seed, wallLoss=$wallLoss, poissonLambda=$poissonLambda, printOutput=$printOutput, simulationTime=$simulationTime"
        
        pushd scratch/wifi-mlo/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd
        
        pushd scratch/wifi-mlo/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons"
        if [ "$logging" == "no_log" ]; then
            ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime
        elif [ "$logging" == "log_info" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime) &
            NS_LOG=$LOG_INFO ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_info_original.txt 2>&1
            wait
        elif [ "$logging" == "log_function" ]; then
            (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput) &
            NS_LOG=$LOG_INFO ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_info_original.txt 2>&1
            NS_LOG=$LOG_FUNCTION ./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime >log_function_original.txt 2>&1
            wait
        elif [ "$logging" == "debug" ]; then
            ./ns3 run --gdb "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime
        fi

    fi

#################################################################################################
#
elif [ "$option" == "complete" ]; then
#
#################################################################################################
    mode=$2

    #################################################################################################
    if [ "$mode" == "dmlo1" ]; then # Simulation of complete seed D-MLO mode 1
    #################################################################################################
        maxMissedBeacons=4
        reliabilityMode=false
        printOutput=true
        poissonLambda=500
        simulationTime=$((8*10)) # in seconds
        simulation_file="scratch/wifi-dmlo12/wifi-ehr-roaming-scenario.cc"
        start=$(date +%s)

        MAX_PARALLEL=$core_num

        echo "Simulation started at: $(date)"

        pushd scratch/wifi-dmlo12/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd
        
        pushd scratch/wifi-dmlo12/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        for wallLoss in {0..13}; do
            for seed in {1..50}; do
                echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, seed=$seed, reliabilityMode=$reliabilityMode"
                
                (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime) &

                if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL ]]; then
                wait -n
                fi
            done
            # Wait for all background jobs for the current numBss to finish
            wait
        
        done

        dest_dir="scratch/Results_Complete/dmlo_mode1"
        old_dir="scratch/Results_Complete/old"

        timestamp=$(date +"%Y%m%d_%H%M%S")

        # If destination exists and is not empty, move it to old/
        if [ -d "$dest_dir" ] && [ "$(ls -A $dest_dir)" ]; then
            echo "Existing results found. Moving them to $old_dir/dmlo_mode1_$timestamp"
            mkdir -p "$old_dir"
            mv "$dest_dir" "$old_dir/dmlo_mode1_$timestamp"
        fi

        # Ensure destination exists
        mkdir -p "$dest_dir"

        echo "Copying new results to $dest_dir"

        cp -r scratch/wifi-dmlo12/assoc-rxpower-logs "$dest_dir/"
        cp -r scratch/wifi-dmlo12/result-logs "$dest_dir/"

        elapsedTime=$(($(date +"%s") - $start))
        echo "All simulations completed in $elapsedTime seconds ( $(($elapsedTime / 3600)) hours )."
    
    #################################################################################################
    elif [ "$mode" == "dmlo2" ]; then # Simulation of complete seed D-MLO mode 2
    #################################################################################################

        maxMissedBeacons=4
        reliabilityMode=true
        printOutput=true
        poissonLambda=500
        simulationTime=$((8*10)) # in seconds
        simulation_file="scratch/wifi-dmlo12/wifi-ehr-roaming-scenario.cc"
        start=$(date +%s)

        MAX_PARALLEL=$core_num

        echo "Simulation started at: $(date)"

        pushd scratch/wifi-dmlo12/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd
        
        pushd scratch/wifi-dmlo12/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        # Run simulations in parallel for numBss from 1 to 4
        for wallLoss in {0..13}; do
            for seed in {1..50}; do
                echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, seed=$seed, reliabilityMode=$reliabilityMode"
                
                (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime) &

                if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL ]]; then
                wait -n
                fi
            done
            # Wait for all background jobs for the current numBss to finish
            wait
        
        done

        dest_dir="scratch/Results_Complete/dmlo_mode2"
        old_dir="scratch/Results_Complete/old"

        timestamp=$(date +"%Y%m%d_%H%M%S")

        # If destination exists and is not empty, move it to old/
        if [ -d "$dest_dir" ] && [ "$(ls -A $dest_dir)" ]; then
            echo "Existing results found. Moving them to $old_dir/dmlo_mode2_$timestamp"
            mkdir -p "$old_dir"
            mv "$dest_dir" "$old_dir/dmlo_mode2_$timestamp"
        fi

        # Ensure destination exists
        mkdir -p "$dest_dir"

        echo "Copying new results to $dest_dir"

        cp -r scratch/wifi-dmlo12/assoc-rxpower-logs "$dest_dir/"
        cp -r scratch/wifi-dmlo12/result-logs "$dest_dir/"

        elapsedTime=$(($(date +"%s") - $start))
        echo "All simulations completed in $elapsedTime seconds ( $(($elapsedTime / 3600)) hours )."

    #################################################################################################
    elif [ "$mode" == "dmlo3" ]; then # Simulation of complete seed D-MLO mode 3
    #################################################################################################

        maxMissedBeacons=4
        reliabilityMode=false
        printOutput=true
        poissonLambda=500
        simulationTime=$((8*10)) 
        simulation_file="scratch/wifi-dmlo34/wifi-bn-jt-network.cc"
        start=$(date +%s)

        MAX_PARALLEL=$core_num
        echo "Simulation start time: $start"

        pushd scratch/wifi-dmlo34/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd

        pushd scratch/wifi-dmlo34/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        for wallLoss in {0..13}; do
            for seed in {1..50}; do
                echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, seed=$seed, reliabilityMode=$reliabilityMode"
                
                (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp) &

                if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL ]]; then
                wait -n
                fi
            done
            # Wait for all background jobs for the current numBss to finish
            wait
        done

        dest_dir="scratch/Results_Complete/dmlo_mode3"
        old_dir="scratch/Results_Complete/old"

        timestamp=$(date +"%Y%m%d_%H%M%S")

        # If destination exists and is not empty, move it to old/
        if [ -d "$dest_dir" ] && [ "$(ls -A $dest_dir)" ]; then
            echo "Existing results found. Moving them to $old_dir/dmlo_mode3_$timestamp"
            mkdir -p "$old_dir"
            mv "$dest_dir" "$old_dir/dmlo_mode3_$timestamp"
        fi

        # Ensure destination exists
        mkdir -p "$dest_dir"

        echo "Copying new results to $dest_dir"

        cp -r scratch/wifi-dmlo34/assoc-rxpower-logs "$dest_dir/"
        cp -r scratch/wifi-dmlo34/result-logs "$dest_dir/"

        elapsedTime=$(($(date +"%s") - $start))
        echo "All simulations completed in $elapsedTime seconds ( $(($elapsedTime / 3600)) hours )."

    #################################################################################################
    elif [ "$mode" == "dmlo4" ]; then # Simulation of complete seed D-MLO mode 4
    #################################################################################################

        maxMissedBeacons=4
        reliabilityMode=true
        printOutput=true
        poissonLambda=500
        simulationTime=$((8*10)) 
        simulation_file="scratch/wifi-dmlo34/wifi-bn-jt-network.cc"
        start=$(date +%s)

        MAX_PARALLEL=$core_num
        echo "Simulation start time: $start"

        pushd scratch/wifi-dmlo34/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd

        pushd scratch/wifi-dmlo34/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        for wallLoss in {0..13}; do
            for seed in {1..50}; do
                echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, seed=$seed, reliabilityMode=$reliabilityMode"
                
                (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --reliabilityMode=$reliabilityMode --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime --manualConnectionEnable=$manualConnectionEnable --manualReliabilityModeApp=$manualReliabilityModeApp) &

                if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL ]]; then
                wait -n
                fi
            done
            # Wait for all background jobs for the current numBss to finish
            wait
        done

        dest_dir="scratch/Results_Complete/dmlo_mode4"
        old_dir="scratch/Results_Complete/old"

        timestamp=$(date +"%Y%m%d_%H%M%S")

        # If destination exists and is not empty, move it to old/
        if [ -d "$dest_dir" ] && [ "$(ls -A $dest_dir)" ]; then
            echo "Existing results found. Moving them to $old_dir/dmlo_mode4_$timestamp"
            mkdir -p "$old_dir"
            mv "$dest_dir" "$old_dir/dmlo_mode4_$timestamp"
        fi

        # Ensure destination exists
        mkdir -p "$dest_dir"

        echo "Copying new results to $dest_dir"

        cp -r scratch/wifi-dmlo34/assoc-rxpower-logs "$dest_dir/"
        cp -r scratch/wifi-dmlo34/result-logs "$dest_dir/"

        elapsedTime=$(($(date +"%s") - $start))
        echo "All simulations completed in $elapsedTime seconds ( $(($elapsedTime / 3600)) hours )."
    
    #################################################################################################
    elif [ "$mode" == "mlo" ]; then # Simulation of complete seed MLO
    #################################################################################################

        maxMissedBeacons=4
        printOutput=true
        poissonLambda=1500
        simulationTime=$((8*10)) # in seconds
        simulation_file="scratch/wifi-mlo/wifi-eht-roaming-scenario.cc"
        start=$(date +%s)

        MAX_PARALLEL=$core_num

        echo "Simulation started at: $(date)"

        pushd scratch/wifi-mlo/assoc-rxpower-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'assoc-rxpower-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'assoc-rxpower-logs' folder is empty."
        fi
        popd
        
        pushd scratch/wifi-mlo/result-logs
        # Check if the directory is empty
        if [ "$(ls -A)" ]; then
            # If not empty, delete all files
            echo "The 'result-logs' folder is not empty. Deleting all files."
            rm -rf *
        else
            # If empty, print a message
            echo "The 'result-logs' folder is empty."
        fi
        popd

        for wallLoss in {0..13}; do
            for seed in {1..50}; do
                echo "Running simulation with file=$simulation_file, maxMissedBeacons=$maxMissedBeacons, seed=$seed"
                
                (./ns3 run "$simulation_file" -- --seed=$seed --maxMissedBeacons=$maxMissedBeacons --poissonLambda=$poissonLambda --wallLoss=$wallLoss --printOutput=$printOutput --simulationTime=$simulationTime) &

                if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL ]]; then
                wait -n
                fi
            done
            # Wait for all background jobs for the current numBss to finish
            wait
        
        done

        dest_dir="scratch/Results_Complete/mlo7"
        old_dir="scratch/Results_Complete/old"

        timestamp=$(date +"%Y%m%d_%H%M%S")

        # If destination exists and is not empty, move it to old/
        if [ -d "$dest_dir" ] && [ "$(ls -A $dest_dir)" ]; then
            echo "Existing results found. Moving them to $old_dir/mlo7$timestamp"
            mkdir -p "$old_dir"
            mv "$dest_dir" "$old_dir/mlo7$timestamp"
        fi

        # Ensure destination exists
        mkdir -p "$dest_dir"

        echo "Copying new results to $dest_dir"

        cp -r scratch/wifi-mlo/assoc-rxpower-logs "$dest_dir/"
        cp -r scratch/wifi-mlo/result-logs "$dest_dir/"


        elapsedTime=$(($(date +"%s") - $start))
        echo "All simulations completed in $elapsedTime seconds ( $(($elapsedTime / 3600)) hours )."

    fi
fi

