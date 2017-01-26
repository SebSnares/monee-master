#/bin/bash

# remove ppn, less than 5 min time: test node
# Settings of PBS (do NOT uncomment these lines)
#--------------------------------------------------------------------------------------------------#
#PBS -lnodes=1
#PBS -lwalltime=00:04:59
#--------------------------------------------------------------------------------------------------#

FULLCOMMAND="$0 $@"
. ${HOME}/lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"
#set -x
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`
#BASEDIR=$HOME/monee/results

for i in $@
do
  pushd $i
  (
   bash ${BASEDIR}/calculate-selection-pressure.sh
  )&
  popd
done

wait