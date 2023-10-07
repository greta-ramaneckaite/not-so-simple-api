#!/usr/bin/env bash

for dir in $(find python -mindepth 1 -maxdepth 1 -type d) ; do
    cd ${dir}

    zip -r ${dir##*/}.zip *.py
    aws s3 cp ${dir##*/}.zip s3://scripts-544794004724/${dir##*/}.zip

    cd ../../
done
