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
@inproceedings{10.1145/3837358.3837374,
author = {Keshtiarast, Navid and Lumbantobing, Ido M. and Renaldi, Oliver and Petrova, Marina},
title = {An ns-3 Implementation and Evaluation of Wi-Fi Distributed Multi-Link Operation},
year = {2026},
isbn = {9798400727405},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3837358.3837374},
doi = {10.1145/3837358.3837374},
abstract = {Distributed multi-link operation (D-MLO) allows a client device to simultaneously connect to multiple, different Access Points (APs) and frequency bands. It is one of the key mechanisms being investigated for future Wi-Fi 8 networks to improve reliability, mobility support, and service continuity. However, studying its performance requires system-level simulator support that goes beyond conventional multi-link operation, where clients maintain multiple links with one AP-Multi Link Device (AP-MLD). In this paper, we present a D-MLO MAC-layer implementation in ns-3.43. To the best of our knowledge, this is the first ns-3 implementation of D-MLO for Wi-Fi networks. Our implementation enables a non-AP MLD STA to establish and maintain simultaneous links with multiple distributed APs, perform per-link association and roaming decisions, and apply different packet-mapping policies over the selected links. We implement four D-MLO modes that differ in link-selection strategy and packet handling, namely diversity-based and SNR-based link selection, each combined with either throughput aggregation or reliability-oriented packet duplication. The implementation extends the ns-3 Wi-Fi module with multi-AP association, per-link beacon monitoring, per-link reassociation, duplicate packet transmission, and duplicate filtering at the receiver. Our simulation results obtained in an indoor roaming scenario with different wall-loss values, demonstrate that D-MLO can be effectively configured for different service objectives. Throughput-oriented modes improve aggregate rate when strong links are available, while reliability-oriented modes improve packet delivery during roaming by maintaining multiple active links and masking link degradation through redundant transmissions. The results further show that seamless roaming can also be realized in a user-centric way by activating redundancy modes only during the roaming scenario.},
booktitle = {Proceedings of the 2026 International Conference on Ns-3},
pages = {126–132},
numpages = {7},
keywords = {ns-3, IEEE 802.11 bn, Wi-Fi 8, MAC},
location = {Naples, Italy},
series = {ICNS3 2026}
}
```

</details>

## Future Work
The author of this repository is actively extending the implementation and developing new features, e.g., dynamic mode switching and traffic-aware link selection in our D-MLO implementation.

## License
This software is licensed under the terms of the GNU GPLv2, as like as ns-3. See the [LICENSE](/LICENSE) file for more details.
