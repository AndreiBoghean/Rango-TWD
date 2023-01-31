#!/bin/bash

if test -f "$djangoProjDir/populate_rango.py"
then
    echo "restoring database from init script||||||||||||||||||||||||||||||||||||||||||||||||"
    rm -f "$djangoProjDir/db.sqlite3"

    printf '1\n\"huh\"' | python "$djangoProjDir/manage.py" makemigrations rango
    python "$djangoProjDir/manage.py" migrate

    python "$djangoProjDir/populate_rango.py"
    echo "restoring database from init script||||||||||||||||||||||||||||||||||||||||||||||||"
fi