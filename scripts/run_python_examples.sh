#!/bin/bash

echo "Running Python Examples & Tests"

image_dir=`pwd`

cd ..

export PATH=/home/ubuntu/.local/bin:$PATH

pipenv --version

./gt-installer --verbose --workspace ${image_dir} test --disable-deprecation-rewrites --packages 'PythonBridge' 'PythonBridge-Pharo'
