#!/bin/bash

# set -x
# Command echoing on.

#walltime for quicktest 00:04:59
#walltime for halfeselection 2.000.0000 00:24:59
#walltime for iterations 2.000.0000 00:14:59
#walltime for iterations 1.000.0000 00:09:59
#PBS -lnodes=1 -lwalltime=00:24:59

### Set the simulation-specific parameters
#--------------------------------------------------------------------------------------------------#
workdir=${HOME}/monee/monee-master
roborobodir=${HOME}/monee/monee-master
mytmpdir=monee #Subdirectory used in nodes' scratch space
#--------------------------------------------------------------------------------------------------#

#echo "$(date)"
#echo "Script running on `hostname`"

#echo "Nodes reserved:"
NODES="$(sort $PBS_NODEFILE | uniq)"
#echo "$NODES"

#
# Re-creating tempdir
#
cd $TMPDIR;
rm -rf $mytmpdir
mkdir $mytmpdir

#TODO: only copy necessary files...
#
# Copying roborobo simulator to scratch dir
#
echo Copying ${roborobodir} to $mytmpdir ...
cp -rf ${roborobodir} $mytmpdir/
cd ${mytmpdir}/monee-master

# check which folders copied
#echo 1 >> ${HOME}/monee-master/out.txt
#ls -l >> ${HOME}/monee-master/out.txt
#cd ${mytmpdir}/scripts
#echo 2 >> ${HOME}/monee-master/out.txt
#ls -l >> ${HOME}/monee-master/out.txt
#cd ..
# check which folders copied

BASEDIR=`pwd`
SCRIPTDIR=scripts
TEMPLATEDIR=${BASEDIR}/template/
cd $BASEDIR

# check which folders copied
#echo 3 >> ${HOME}/monee-master/out.txt
#ls -l >> ${HOME}/monee-master/out.txt
#cd $BASEDIR/scripts
#echo 4 >> ${HOME}/monee-master/out.txt
#ls -l >> ${HOME}/monee-master/out.txt
#cd ..

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
    echo "Running experiment with parameters: --seed ${SEED} --basedir ${BASEDIR}/ --templatedir ${TEMPLATEDIR} ${STOPOS_VALUE}" >> ${HOME}/monee/monee-master/run_monee_out.txt
    ${BASEDIR}/scripts/monee.sh --seed ${SEED} --basedir ${BASEDIR} --templatedir ${TEMPLATEDIR} ${STOPOS_VALUE}

    stopos remove -p monee.pool
) & # The whole loop contents executed in parallel in the background
done

wait # for the simulations to finish...
