#!/bin/bash

# set -x
# Command echoing on.

#old walltime was 00:09:59
#PBS -lnodes=1 -lwalltime=00:04:59

### Set the simulation-specific parameters
#--------------------------------------------------------------------------------------------------#
workdir=${HOME}/monee-master
roborobodir=${HOME}/monee-master
mytmpdir=monee-master #Subdirectory used in nodes' scratch space
#--------------------------------------------------------------------------------------------------#

#echo "$(date)"
#echo "Script running on `hostname`"

#echo "Nodes reserved:"
NODES="$(sort $PBS_NODEFILE | uniq)"
#echo "$NODES"

#
# Re-creating tempdir
#
cd ${HOME}/;
rm -rf test
mkdir test

#TODO: only copy necessary files...
#
# Copying roborobo simulator to scratch dir
#
echo Copying ${roborobodir} to test ...
cp -rf ${roborobodir} test/
cd ${test}

# check which folders copied
echo 1 >> ${HOME}/monee-master/out.txt
ls -l >> ${HOME}/monee-master/out.txt
cd ${test}/scripts
echo 2 >> ${HOME}/monee-master/out.txt
ls -l >> ${HOME}/monee-master/out.txt
cd ..
# check which folders copied

BASEDIR=${test}
SCRIPTDIR=scripts
TEMPLATEDIR=${BASEDIR}/template/
cd $BASEDIR

# check which folders copied
echo 3 >> ${HOME}/monee-master/out.txt
ls -l >> ${HOME}/monee-master/out.txt
cd $BASEDIR/scripts
echo 4 >> ${HOME}/monee-master/out.txt
ls -l >> ${HOME}/monee-master/out.txt
cd ..

# check which folders copied
#
# How many cores does this node have?
#
module load stopos
ncores=`sara-get-num-cores`

#
# Start simulation for each available core on this node.
#
for ((i=1; i<=ncores; i++)) ; do
(
    # read job parameters from stopos string pool
    stopos next -p monee.pool

    if [ "$STOPOS_RC" != "OK" ]; then # Parameter pool exhausted: we're done
        break
    fi

    ### Run the simulation
    SEED=$RANDOM
    echo "Running experiment with parameters: --seed ${SEED} --basedir ${BASEDIR}/ --templatedir ${TEMPLATEDIR} ${STOPOS_VALUE}"
    ${BASEDIR}/scripts/monee.sh --seed ${SEED} --basedir ${BASEDIR} --templatedir ${TEMPLATEDIR} ${STOPOS_VALUE}

    stopos remove -p monee.pool
) & # The whole loop contents executed in parallel in the background
done

wait # for the simulations to finish...
