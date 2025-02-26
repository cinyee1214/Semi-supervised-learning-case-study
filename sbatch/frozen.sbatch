#!/bin/bash

#SBATCH --gres=gpu:1
#SBATCH --partition=n1s8-t4-1
#SBATCH --account=dl05
#SBATCH --time=24:00:00
#SBATCH --output=frozen_%j.out
#SBATCH --error=frozen_%j.err
#SBATCH --exclusive
#SBATCH --requeue

/share/apps/local/bin/p2pBandwidthLatencyTest > /dev/null 2>&1

set -x

mkdir /tmp/$USER
export SINGULARITY_CACHEDIR=/tmp/$USER

cp -rp /scratch/DL21SP/student_dataset.sqsh /tmp
echo "Dataset is copied to /tmp"

LATEST_CP=$(ls -1r $SCRATCH/frozen/ | head -1)
echo "Latest checkpont: ${LATEST_CP}"

singularity exec --nv \
--bind /scratch \
--overlay /scratch/DL21SP/conda_fixed.sqsh:ro \
--overlay /tmp/student_dataset.sqsh:ro \
/share/apps/images/cuda11.1-cudnn8-devel-ubuntu18.04.sif \
/bin/bash -c "
source /ext3/env.sh
conda activate dev
python $HOME/dl05/frozen.py -a resnet152 --pretrained $SCRATCH/resnet152/checkpoint_0249.pth.tar --checkpoint $SCRATCH/frozen/ --cos
"
