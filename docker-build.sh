#!/bin/bash

# param 1: env
# param 2: name
# param 3: tag
# EXAMPLE:
# ./docker-build.sh stage mysite 4.9.5-1.0

# param 1
if [ "$1" != "" ]; then

    env=$1
else
    echo "Enter the environment, e.g., s, stage, p, prod"
    read -p 'env: ' env
fi

# lcase using tr
env="$(echo $env | tr '[A-Z]' '[a-z]')"

# set env to prod or stage
case "$env" in
    "prod")
        env=$env
        ;;
    "stage")
        env=$env
        ;;
    "p")
        env=$env"rod"
        ;;
    "s")
        env=$env"tage"
        ;;
esac

# param 2
if [ "$2" != "" ]; then

    name=$2
else
    echo "Enter the name of the image, e.g., mysite"
    read -p 'name: ' name
fi

# param 3
if [ "$3" != "" ]; then

    tag=$3
else
    echo "Enter the image tag, e.g., 4.9.5-1.0"
    read -p 'tag: ' tag
fi

# image
image=$name":"$tag

function build {

    SRC="wordpress"
    BUILD="build"
    THEME="mytheme"

    # cleanup
    rm -rf $BUILD

    # create build root
    mkdir $BUILD

    # folders
    mkdir $BUILD/wp-content
    mkdir $BUILD/wp-content/themes

    cp -r $SRC/wp-content/plugins $BUILD/wp-content/plugins
    cp -r $SRC/wp-content/themes/$THEME $BUILD/wp-content/themes/$THEME
    cp -r $SRC/wp-content/uploads $BUILD/wp-content/uploads

    # files
    cp $SRC/.htaccess $BUILD/.htaccess
    for i in $SRC/*.html; do cp $i $BUILD; done
    for i in $SRC/*.txt; do cp $i $BUILD; done
    for i in $SRC/*.xml; do cp $i $BUILD; done

    ## files (prod)
    # if [ "$env" == "prod" ]; then
    #     cp $SRC/wp-content/themes/$THEME/footer_prod.php $BUILD/wp-content/themes/$THEME/footer.php
    #     echo "prod footer cp"
    # fi

    # build docker image
    docker build --squash -f Dockerfile -t $image .

    # replace colon with hyphen on $TAG for filename
    TAR=${image//:/-}

    # save image
    docker save -o docker/$env/$TAR.tar $image
}

# ucase using tr
envu="$(echo $env | tr '[a-z]' '[A-Z]')"

# confirm
read -p "Build $envu Docker image: $image ? [y/n] " CONT
case "$CONT" in
    y|Y )
        build
        ;;
    * )
        exit 0
        ;;
esac
