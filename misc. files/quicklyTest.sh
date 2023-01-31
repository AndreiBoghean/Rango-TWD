#!/bin/bash

testspace=$PWD
echo $testspace
###########THE ONLY VARIABLES YOU SHOULD CONCERN YOURSELF WITH#################
testableRepoName="Rango-TWD"
testingRepoName="tango_with_django_2_code"
workspace="/home/andrei/Desktop/fakeUSB/WAD2/Rango-TWD"
###############################################################################

testsRepoLocation="$testspace/$testingRepoName"
testsFolderLocation="$testsRepoLocation/progress_tests"

djangoProjDir="$workspace/tango_with_django_project"
djangoAppDir="$djangoProjDir/tango_with_django_project" # this is currently unused
rangoAppDir="$djangoProjDir/rango"

echo ""

cd $workspace

testNum=$1

testFileName="tests_chapter$testNum.py"

testFileSourceAddress="$testsFolderLocation/$testFileName"
testFileDestinationAddress="$rangoAppDir/$testFileName"

mkdir -p $testOutFolderpath

# echo "<start testing commit $i test $testNum>"

##################restore database from init script############################
if test -f "$djangoProjDir/populate_rango.py"
then
    echo "restoring database from init script||||||||||||||||||||||||||||||||||||||||||||||||"
    rm -f "$djangoProjDir/db.sqlite3"

    printf '1\n\"huh\"' | python "$djangoProjDir/manage.py" makemigrations rango
    python "$djangoProjDir/manage.py" migrate

    python "$djangoProjDir/populate_rango.py"
    echo "restoring database from init script||||||||||||||||||||||||||||||||||||||||||||||||"
fi
###############################################################################

echo "test source address: $testFileSourceAddress"
echo "test dest address: $testFileDestinationAddress"
cp $testFileSourceAddress $testFileDestinationAddress

cd "$djangoProjDir"
echo "actual test for $testNum||||||||||||||||||||||||||||||||"
python "manage.py" test "rango.tests_chapter$testNum"
echo "actual test for $testNum||||||||||||||||||||||||||||||||"
rm $testFileDestinationAddress

# echo "<stop testing commit $i test $testNum>"