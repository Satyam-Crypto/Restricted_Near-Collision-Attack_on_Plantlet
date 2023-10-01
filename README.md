This repository contains the source codes for the paper, '**Restricted Near Collision Attack on Plantlet**'.

## Software Used
1. [SageMath](https://www.sagemath.org/)
2. [CryptoMiniSat](https://github.com/msoos/cryptominisat)


## Setup

1. To install sagemath in conda environment, use the following command:
	* `conda config --add channels conda-forge`
	* `conda create -n sage sage python=3.8`
2. Activate the new environment: `conda activate sage`
3. Install the required package cryptominisat as follows:
	* `conda install -c conda-forge cryptominisat`
	* `conda install -c conda-forge libcryptominisat`



## File Structure

1. `1_Plantlet_fixed_0-1_type1_equ_type2_equ.sage`: Script for finding the positions where Keystream Difference (KSD) equation is either fixed to 0/1 or of Type I/II for a fixed difference in the LFSR of the internal state.

2. `2_Plantlet_Encryption.sage`: Script to measure the average time for 1 Plantlet encryption.

3. `3_Plantlet_UNSAT_time.sage`: Script to measure the average UNSAT time while solving a system of nonlinear equations.

3. `4_Plantlet_SAT_time.sage`: Script to measure the average SAT time while solving a system of nonlinear equations.



## Usage
1. Activate SageMath: `conda activate sage`
2. Compile the file: `sage file_name.sage`
