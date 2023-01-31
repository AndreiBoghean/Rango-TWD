#!/bin/bash

testspace=$PWD
echo $testspace
###########THE ONLY VARIABLES YOU SHOULD CONCERN YOURSELF WITH#################
testsRepoURL="https://github.com/tangowithcode/tango_with_django_2_code.git"
testableRepoURL="https://github.com/AndreiBoghean/Rango-TWD.git"
testableRepoName="Rango-TWD"
testingRepoName="tango_with_django_2_code"
###############################################################################

testsRepoLocation="$testspace/tango_with_django_2_code"
testsFolderLocation="$testsRepoLocation/progress_tests"

workspace="$testspace/$testableRepoName"
djangoProjDir="$workspace/tango_with_django_project"
djangoAppDir="$djangoProjDir/tango_with_django_project" # this is currently unused
rangoAppDir="$djangoProjDir/rango"

git clone $testableRepoURL $testableRepoName
git clone $testsRepoURL $testingRepoName

echo ""

cd $workspace

succ=("true" "true" "true" "false" "false" "false" "false" "false" "false" "false" "false")

# turn off informative output, in advance for when we eventaully checkout branches
git config --local advice.detachedHead false

i=-1
for git_hash in $(git log --pretty=format:"%H" --reverse)
do
    ((i+=1))
    if [ $i -eq 0 ]
    then
        continue
    fi

    git checkout "$git_hash" # switch to the commit we're currently iterating over
    for testNum in {0..10}
    do
        if [ ${succ[$testNum]} = "true" ]
        then
            continue
        fi
        # <start recording output>
        testFileName="tests_chapter$testNum.py"

        testFileSourceAddress="$testsFolderLocation/$testFileName"
        testFileDestinationAddress="$rangoAppDir/$testFileName"

        testOutFolderpath="$testspace/testOut"
        testOutFilepath="$testOutFolderpath/commit $i test $testNum.txt"

        mkdir -p $testOutFolderpath

        # echo "<start testing commit $i test $testNum>"
        {
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

        echo $testFileSourceAddress
        echo $testFileDestinationAddress
        cp $testFileSourceAddress $testFileDestinationAddress

        cd "$djangoProjDir"
        echo "actual test for $testNum on $(git log -1 --oneline)||||||||||||||||||||||||||||||||"
        python "manage.py" test "rango.tests_chapter$testNum"
        echo "actual test for $testNum on $(git log -1 --oneline)||||||||||||||||||||||||||||||||"
        rm $testFileDestinationAddress
        } &> "$testOutFilepath"
        # echo "<stop testing commit $i test $testNum>"
        if $(grep -q "^OK$" "$testspace/testOut/commit $i test $testNum.txt")
        then
            echo "success: commit $i test $testNum"
            # succ[$testNum]="true"
        fi
    done
done

#rm -rf $workspace
#rm -rf $testsRepoLocation
#rm -rf $testOutFolderpath