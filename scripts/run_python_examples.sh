#!/bin/bash

echo "Running Python Example"

export PATH=/home/ubuntu/.local/bin:$PATH
xvfb-run -a ./gt-installer --verbose --workspace ${GlamorousToolkit.EXAMPLES_FOLDER} test --disable-deprecation-rewrites --packages 'PythonBridge' 'PythonBridge-Pharo' 
xvfb-run -a ./gt-installer --verbose --workspace ${GlamorousToolkit.EXAMPLES_FOLDER} test 'PythonBridge-Pharo'