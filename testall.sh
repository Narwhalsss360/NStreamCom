#!/bin/bash

printf "Initializing virtual environment...\n"
python -m venv .venv
exit_code=$?

if [ ! $exit_code -eq 0 ]; then
    printf "Virtual environment creation failed!\n"
    exit $exit_code
fi

source .venv/bin/activate
exit_code=$?
if [ ! $exit_code -eq 0 ]; then
    printf "Virtual environment activation failed!\n"
    exit $exit_code
fi

printf "Initialized.\n"

printf "Installing package...\n"
output=$(python -m pip install .)
exit_code=$?
if [ ! $exit_code -eq 0 ]; then
    printf "Installation of package failed!\n"
    exit $exit_code
fi
printf "Installed!\n"

cd tests
for test in $(find *.py)
do
    printf "[Testing %s...]\n" $test
    output=$(python $test)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo $output
    else
        printf "Test %s failed with exit code %d.\n" $test $exit_code
        exit $exit_code
    fi
    printf "\n"

done

deactivate
cd ..

