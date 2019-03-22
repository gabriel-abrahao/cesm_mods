#!/bin/bash
modsfolder="/prj/desmclima/gabriel.abrahao/transicao/doutorado/cesm_mods/"
nlfolder=$modsfolder"/lists/namelists/"
pefolder=$modsfolder"/setup_scripts/pe_layouts/"
queue="cpu"

RESUBMIT=1
STOP_OPTION="nyears"
STOP_N=24
REST_OPTION="nyears"
REST_N=2

rcp=$(basename $PWD | sed 's/.*_\(rcp.\..\)_.*/\1/')
member=$(basename $PWD | sed 's/.*_\([0-9]\{3\}\)$/\1/')
scenario=$(basename $PWD | sed 's/.*_\([a-z]\{3\}\)_[0-9]\{3\}$/\1/')

echo "Queue to submit is "$queue
if [ $queue == "cpu" ]; then
	timelim="47:59:59"
	pelim=1200
elif [ $queue == "cpu_small" ]; then
	timelim="01:59:59"
	pelim=480
elif [ $queue == "cpu_dev" ]; then
	timelim="00:19:59"
	pelim=96
else
	echo "Queue "$queue" is not supported"
	exit
fi
echo "Time limit will be "$timelim


echo "#######################   MAKE SURE TO RUN ME TWICE  ##########################"
echo "####################### BEFORE AND AFTER ./configure ##########################"

echo "RCP is "$rcp
echo "scenario is "$scenario
echo "Ensemble member "$member

refcase='b40.20th.track1.1deg.'$member

echo "Setting RUN_REFCASE in env_conf.xml to "$refcase
./xmlchange -file env_conf.xml -id RUN_REFCASE -val $refcase

echo "Copying user_nl_clm and setting an appropriate value for fpftdyn"
cat $nlfolder/user_nl_clm| sed "s/_\(rcp[0-9]\.[0-9]\)_/_"$rcp"_/" | sed "s/_rochedo_\([a-z]\{3\}\)_/_rochedo_"$scenario"_/" >user_nl_clm
cat user_nl_clm | grep 'fpftdyn'

echo "Copying user_nl_cam"
cp $nlfolder/user_nl_cam .

echo "Copying env_mach_pes.xml for "$queue
cp $pefolder"/env_mach_pes_"$queue".xml" env_mach_pes.xml
npes=$(cat env_mach_pes.xml | grep '"TOTALPES"' | grep -o '[0-9][0-9]*')

echo "TOTALPES is "$npes
if [ $npes -le $pelim ]; then
	echo "which is fine for "$queue
else
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!!!!!!!!!!!!!!!!                                                                         !!!!!!!!!!!!!!"
	echo "!!!!!!!!!!!!!!!!             REQUESTED TOO MANY PEs FOR THIS QUEUE!!!!                   !!!!!!!!!!!!!!"
	echo "!!!!!!!!!!!!!!!!                                                                         !!!!!!!!!!!!!!"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "                        QUEUE "$queue" ONLY TAKES "$pelim" PEs, requested "$npes
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

runfname=$(basename $PWD).sdumont.run
if [ -e $runfname ]; then
	echo "Setting "$runfname" to queue "$queue" with time limit "$timelim
	tempfname=$(mktemp $temp.XXXXX)
	cp $runfname bkp.$runfname
	rm $runfname
	cat bkp.$runfname | sed "s/\(SBATCH[ ][ ]*-p[ ][ ]*\).*/\1"$queue"/" |  sed "s/\(^#SBATCH --time=\).*/\1"$timelim"/"  >$runfname
else
	echo "-------------- "$runfname" not found             ---------------"
	echo "-------------- RUN ME AGAIN AFTER ./configure!!! ---------------"
fi

echo " "
echo "Setting run length and restart frequency in env_run.xml"

./xmlchange -file env_run.xml -id "RESUBMIT"    -val $RESUBMIT
./xmlchange -file env_run.xml -id "STOP_OPTION" -val $STOP_OPTION
./xmlchange -file env_run.xml -id "STOP_N"      -val $STOP_N    
./xmlchange -file env_run.xml -id "REST_OPTION" -val $REST_OPTION
./xmlchange -file env_run.xml -id "REST_N"      -val $REST_N     

echo "----------------------------------------------------------------------------------------------"
echo "Model will run for	"$(expr $STOP_N \* $(($RESUBMIT+1)) ) " "$STOP_OPTION
echo "In steps of		"$STOP_N" "$STOP_OPTION
echo "Writing restarts every	"$REST_N" "$REST_OPTION
echo "This has to take		"$timelim
echo "Running in		"$npes" PEs"	

echo "----------------------------------------------------------------------------------------------"
#if [ -x $(command -v bc) ]; then
#	echo "Er got bc"
#	echo $
#fi


