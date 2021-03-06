#/bin/csh -f

cd ../src
set refin=../testing/ghost3d.inp
set refout=../testing/ghost3d.out
set rundir=../testing/3dg
set tmp=/tmp/temp.out

if ($#argv == 0 ) then
   echo "./test3d.sh [1,2,p]"
   echo " 1 = run dnsghost and dnsgrid with and without restart, simple 3D test case"
   echo " 2 = run lots of 3D test cases (different dimensions)"
   echo " p  = run several 3D test cases in parallel (2 and 4 cpus)"
   echo " pr = run several 3D test cases in parallel, with restart"
   echo " makeref  = generate new reference output, 3D"
   exit
endif

if ($1 == makeref) then

   ./gridsetup.py 1 1 1 32 32 32
   make dnsgrid; rm -f $refout 
   ./dnsgrid -d $rundir ghost3d  < $refin > $refout
  cat $refout
  cd $rundir
  mv ghost3d0000.0000.u restart.u
  mv ghost3d0000.0000.v restart.v
  mv ghost3d0000.0000.w restart.w
  

endif

if ($1 == 1) then
./gridsetup.py 1 1 1 32 32 32  2 2 2  2 2 2

echo "***********************************************************"
echo "without restart:"
make dnsghost >& /dev/null ;  rm -f $tmp ; ./dnsghost -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout

echo "***********************************************************"
echo "with restart:"
make dnsghost >& /dev/null ;  rm -f $tmp ; ./dnsghost -r -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout

echo "***********************************************************"
echo "dnsgrid with restart:"
./gridsetup.py 1 1 1 32 32 32 2 2 2 2 2 2
make dnsgrid >& /dev/null ;  rm -f $tmp ; ./dnsgrid -r -d $rundir ghost3d < $refin > $tmp 
../testing/check.sh $tmp $refout


endif




if ($1 == 2) then

./gridsetup.py 1 1 1 32 32 32   3 3 3 4 4 4
make dnsghost>& /dev/null ;  rm -f $tmp ; ./dnsghost -r -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout

endif



if ($1 == p || $1 == pr) then

if ($1 == pr) then
   set opt = "-r"
   echo USING RESTART
else
   set opt = ""
   echo NOT USING RESTART
endif

echo "***********************************************************"
./gridsetup.py 1 1 2 32 32 32 2 2 2 2 2 2
make dnsghost>& /dev/null ;  rm -f $tmp ; mpirun -np 2 ./dnsghost $opt -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout

echo "***********************************************************"
./gridsetup.py 1 2 1 32 32 32 2 2 2 2 2 2
make dnsghost>& /dev/null ;  rm -f $tmp ; mpirun -np 2 ./dnsghost $opt -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout

echo "***********************************************************"
./gridsetup.py 2 1 1 32 32 32 2 2 2 2 2 2
make dnsghost>& /dev/null ;  rm -f $tmp ; mpirun -np 2 ./dnsghost $opt -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout

echo "***********************************************************"
./gridsetup.py 2 1 2 32 32 32  2 3 4  4 3 2 
make dnsghost>& /dev/null ;  rm -f $tmp ; mpirun -np 4 ./dnsghost $opt -d $rundir ghost3d  < $refin > $tmp 
../testing/check.sh $tmp $refout


endif




