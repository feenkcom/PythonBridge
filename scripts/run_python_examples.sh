#!/bin/bash

echo "Running Python Examples & Tests"

image_dir=`pwd`

cd ..

export PATH=/home/ubuntu/.local/bin:$PATH

pipenv --version

xvfb-run -a ./gt-installer --verbose --workspace ${image_dir} test --disable-deprecation-rewrites --packages 'PythonBridge' 'PythonBridge-Pharo' 

# xvfb-run -a ./gt-installer --verbose --workspace ${image_dir} test 'PythonBridge-Pharo'

