#!/bin/bash

BASEPATH=$(dirname "$0")
export PATH=$PATH:$BASEPATH/USD:$PATH:$BASEPATH/usdzconvert;
export PYTHONPATH=$PYTHONPATH:$BASEPATH/USD/lib/python

TEMPDIR=$(mktemp -d)
assimp export "$1" $TEMPDIR/model.obj
usdzconvert $TEMPDIR/model.obj $TEMPDIR/model_orig.usdz
usdcat $TEMPDIR/model_orig.usdz -o $TEMPDIR/model.usda

sed -i.bak "17i\\
    custom double3 xformOp:scale = (0.1, 0.1, 0.1)\\
    uniform token[] xformOpOrder = [\"xformOp:scale\"]
" $TEMPDIR/model.usda

sed -i.bak2 's/Y/Z/g' $TEMPDIR/model.usda

usdzip "$2" --arkitAsset $TEMPDIR/model.usda 
