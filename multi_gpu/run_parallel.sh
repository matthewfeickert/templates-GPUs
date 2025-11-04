#!/usr/bin/env bash

set -e
# detailed logging to stderr
set -x

NUMGPUS=$1

echo "Number of GPUs requested: ${NUMGPUS}"
echo "GPUs assigned: ${CUDA_VISIBLE_DEVICES}"

echo -e "\n# Check to see if the NVIDIA drivers can correctly detect the GPU:\n"
nvidia-smi

echo -e "# Installing Pixi"
curl -fsSL https://pixi.sh/install.sh | bash
. ~/.bashrc

#wandb login <your api key>

pixi run python model_parallel.py -n "${NUMGPUS}"
