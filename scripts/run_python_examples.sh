#!/usr/bin/env bash
set -e

echo "Running Python Examples & Tests"

image_dir=`pwd`

cd ..

export PATH=/home/ubuntu/.local/bin:$PATH

pipenv --version

#./gt-installer --verbose --workspace ${image_dir} test --disable-deprecation-rewrites --packages 'PythonBridge' 'PythonBridge-Pharo'

cd $image_dir

./bin/GlamorousToolkit-cli GlamorousToolkit.image examples PythonBridge PythonBridge-Pharo --junit-xml-output --verbose --disable-deprecation-rewrites

./bin/GlamorousToolkit-cli GlamorousToolkit.image test PythonBridge PythonBridge-Pharo --junit-xml-output --verbose --disable-deprecation-rewrites
