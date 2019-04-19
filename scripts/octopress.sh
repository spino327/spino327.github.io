#!/bin/bash

USAGE="USAGE: octopress.sh <title>. Assuming that you are located in the path where _post folder exists."

if [ "$#" -lt "1" ]; then
    echo $USAGE
    exit -1
fi

TITLE=$1

echo Creating md with title \'$TITLE\' at ./_posts/
bundle exec octopress new post "$TITLE"