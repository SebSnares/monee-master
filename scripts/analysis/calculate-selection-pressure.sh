#/bin/bash

# Run selection pressure analysis on monee logs
#
# selection pressure calculations are done by 'selection_pressure.sh' from ECJ paper
#
#set +x #for debugging
FULLCOMMAND="$0 $@"
. ${HOME}/lib/shflags

#define the flags
DEFINE_integer 'puckTypes' 2 'Number of types of puck' 'p'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"
#set -x
SCRIPT_DIR=$HOME/monee/monee-master/scripts/analysis
BASEDIR=$HOME/monee/monee-master/scripts/analysis/pressure

rm -f *.FET

TEMP=`mktemp -t MONEEFETXXX`

for run in *.pressure-stats
do
	experiment=`basename $run .pressure-stats`

	# Convert MONEE .descendants file to same format as SelectionPressure files
	#
	# MONEE format
	# Time, Id, green puck count, red puck count, distance travelled, offspring
	#
	# NOTE: number of puck count columns depends on the experiment. For now, edit awk statement below to handle this. Also, some runs have AGE as an extra column after distance
	#
	# Convert to:
	# Gen Id Offspring Fitnesses
	#
	# Gen: Time  (rounded at 1000)
	# ID, offspring: same
	# First fitness figure: Distance
	# Second fitness figure: total puck count

	# for two puck types:
	#cat $run | awk 'BEGIN{print "#time Id offspring distance puck_count"} {print 2000*int($1/2000), $2, $6, $5, $3+$4}' $run | sed '/^1000000/d' | sort -n > ${experiment}.tmp
	# for 1000000 iterations sed '/^1000000/d', change accordingly
	#METRICS='dist pucks'
	if [ "$FLAGS_puckTypes" -eq "2" ]
	then
		# for two puck types with age column :
		echo $experiment
		cat $run | awk 'BEGIN{print "#time Id offspring distance puck_count age"} {print 2000*int($1/2000), $2, $7, $5/$6, $3+$4, $6}' $run | sed '/^2000000/d' | sort -n > ${experiment}.tmp
	fi

	if [ "$FLAGS_puckTypes" -eq "1" ]
	then
		# for one puck type, with age column (now use avg. speed rather than distance covered):
		cat $run | awk 'BEGIN{print "#time Id offspring distance puck_count age"} {print 2000*int($1/2000), $2, $6, $4/$5, $3, $5}' $run | sed '/^2000000/d' | sort -n > ${experiment}.tmp
	fi
	METRICS='speed pucks age'
	bash  ${SCRIPT_DIR}/selection_pressure.sh ${experiment}.tmp --method fisher --optimisation max
	rm ${experiment}.tmp

	index=1
	for metric in $METRICS
	do
		echo renaming $index to $metric
		awk '{print $1, -(log($2)/log(10))}' ${experiment}.tmp.${index}.FET.txt > ${experiment}.${metric}.FET
		rm ${experiment}.tmp.${index}.FET.txt

		if [ -e ${metric}.FET ]
		then
			awk '{print $2}' ${experiment}.${metric}.FET | paste ${metric}.FET - > $TEMP
			mv $TEMP ${metric}.FET
		else
			cp  ${experiment}.${metric}.FET ${metric}.FET
		fi

		let index=index+1
	done
done

for metric in $METRICS
do
	gawk -v skip=1 -v prepend=true -f $BASEDIR/moments-per-line.awk ${metric}.FET > ${metric}.FET.stats
done

rm -f $TEMP