#!/bin/bash -e 

#SBATCH --nodes=12
##SBATCH --exclude=cm01,cm02,c033,c016
##SBATCH --ntasks=2496
#SBATCH --ntasks-per-node=12
#SBATCH --mem-per-cpu 2G
#SBATCH --output=slog/container-ibonly_%j.out
#SBATCH --error=slog/%j.err

module purge >/dev/null 2>&1 

# Print diagnostic info
echo "=== UCX/OpenMPI Configuration ==="

# Explicitly disable OpenIB BTL to avoid warnings
export OMPI_MCA_btl="^openib"
export OMPI_MCA_btl_base_warn_component_unused="0"

# Force IB communication via UCX
export UCX_NET_DEVICES=mlx5_1:1
export UCX_IB_PORTS=mlx5_1:1
export UCX_TLS=rc,self
export UCX_IB_GID_INDEX=0
export UCX_IB_TRAFFIC_CLASS=106
export UCX_WARN_UNUSED_ENV_VARS=n
export OMPI_MCA_pml=ucx
export OMPI_MCA_osc=ucx

# Display configuration
env | grep -E 'UCX_|OMPI_'
echo ""

# Get and display unique hostnames where the job is running (short form)
echo "=== Nodes where job is running ==="
HOSTNAMES=$(srun hostname -s | sort | uniq | tr '\n' ',' | sed 's/,$//')
echo "Hostnames: $HOSTNAMES"
echo ""


# Run the test
echo "=== Running OSU All-to-All with forced IB transport ==="
srun apptainer exec \
  --env UCX_WARN_UNUSED_ENV_VARS=n \
  --env OMPI_MCA_btl="^openib" \
  --env OMPI_MCA_btl_base_warn_component_unused=0 \
  --env OMPI_MCA_mpi_show_mca_params=0 \
openmpi-4.1.5-ucx-1.18.aimg osu_alltoall -m 4096:1048576
