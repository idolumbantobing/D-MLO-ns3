# A ns-3 Implementation of Distributed Multi-Link Operation #
## Introduction

  This repository contains an ns-3 implementation and module extension of D-MLO (Distributed Multi-Link Operation) ns-3.43. 
  
## Main Features
The main contribution of this Repository is an ns-3 realization of D-MLO for future Wi-Fi generation. The main features of the current implementation are as follows:
- Support reliability enhancement via Distributed MLO 
- Facilitates seamless roaming (make-before-break handover) between APs via Distributed MLO

To demonstrate the implementation, please refer to this [folder](/scratch). The definition of each mode in the implementation, including variable parameters, is as follows:

| Name | Description |
| --- | --- |
| D-MLO Mode 1 | Throughput booster mode with maximum diversity |
| D-MLO Mode 2 | Reliability mode with maximum diversity | 
| D-MLO Mode 3 | Throughput booster mode with best-SNR link selection |
| D-MLO Mode 4 | Reliability mode with best-SNR link selection |
| D-MLO Parameters | enable reliability, maximum missed beacons, poisson lambda |

## Keywords 
- ns-3, IEEE 802.11 bn, Wi-Fi 8, MAC
  
## Related Work
This repository is an extension of the original ns-3 WiFi roaming framework developed in:
- **Original project:** https://github.com/oliverenaldi/Wi-Fi8-Joint-Transmission.git
- **Authors:** Oliver Renaldi

## Usage example 
There is a [shell script](/simulation.sh) defined by the author to automate the simulation for different scenarios. Please refer to this file for understanding how to run the simulation efficiently. These are a few tips for running the program:
- ⚙️ Build the ns3: ./simulation.sh build (type: debug, optimized)
  - example: ./output_run_info.sh build optimized
- 📈 Run the roaming scenario for single seed: ./simulation.sh single <Mode: dmlo12, dmlo34, mlo> <Log: no_log, log_info, log_function, debug>
  - example: ./simulation.sh single dmlo12 no_log
- 📊 Run the roaming scenario for complete seed: ./simulation.sh complete <Mode: dmlo1, dmlo2, dmlo3, dmlo4, mlo>
  - example: ./simulation.sh complete dmlo1, ./simulation.sh complete dmlo3

To plot the association figure of STA, navigate to this [folder](/scratch/Graphs) and run:
 - 🗺️ Run roaming association plot: python3 plot_assoc.py <scenario:dmlo12, dmlo34, mlo> <wall_loss: 0-12>
   - example: python3 plot_assoc.py dmlo12 2

To plot the comparison reliability and throughput metrics between each mode, navigate to this [folder](/scratch/Results_Complete). (!) Make sure that all scenarios have been simulated and run:
 - 🗺️ Run graph plot: python3 plotting_paper.py 

(!) Ensure all Python scripts are run in the appropriate environment with necessary dependencies.

(!) Use `chmod +x <script>.sh` to make shell scripts executable.

## References
If you use this module in your research, please cite the following:
<details>
<summary>Bibtex</summary>


```bibtex8

```

</details>

## Future Work
The author of this repository is actively extending the implementation and developing new features, e.g., dynamic mode switching and traffic-aware link selection in our D-MLO implementation.

## License
This software is licensed under the terms of the GNU GPLv2, as like as ns-3. See the [LICENSE](/LICENSE) file for more details.
