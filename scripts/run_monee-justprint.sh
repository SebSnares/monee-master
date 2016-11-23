#!/bin/bash

#PBS -lnodes=1 -lwalltime=00:09:59

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
   
    stopos remove -p monee.pool
) & # The whole loop contents executed in parallel in the background
done

wait # for the simulations to finish...
