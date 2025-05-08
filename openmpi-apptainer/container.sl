#!/bin/bash -e 

#SBATCH --nodes=50
##SBATCH --exclude=cm01,cm02,c033,c016
#SBATCH --ntasks=100
#SBATCH --ntasks-per-node=2
#SBATCH --output=slog/container-ibonly_%j.out

module purge >/dev/null 2>&1 
#module load OSU-Micro-Benchmarks/6.2-gompi-2023a

# Force IB over RoCE and increase reliability settings
#export UCX_TLS=dc_x,rc_x,ud_x,shm
#export UCX_NET_DEVICES=mlx5_1:1
#export UCX_IB_TX_RETRY_COUNT=20
#export UCX_IB_TRAFFIC_CLASS=0
#export UCX_IB_TX_MIN_CQE=128
#export OMPI_MCA_pml=ucx
#export OMPI_MCA_btl=^openib
#export OMPI_MCA_osc=ucx

# Print diagnostic info
echo "=== UCX/OpenMPI Configuration ==="
env | grep -E 'UCX_|OMPI_'
echo ""

#tells UCX use only  IB reliable connection transport and the loopback transport, while explicitly 
#avoiding shared memory transport whichcan cause the permissions error 
export UCX_TLS=rc,self 

# Print debug information about transport selection
#export UCX_LOG_LEVEL=info

# Run the test
echo "=== Running OSU All-to-All with forced IB transport ==="
srun apptainer exec --env UCX_WARN_UNUSED_ENV_VARS=n openmpi-4.1.5-ucx-1.18.aimg osu_alltoall -m 4096:1048576
