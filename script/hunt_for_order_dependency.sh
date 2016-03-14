#!/bin/bash

function filter_seed {
  seed=$(echo "$1" | grep 'seed [0-9][0-9]*' | awk '{ print $NF }' | tail -1)
  return $seed
}

# data structure = [retval, seed, counter]
function hunt_for_order_dependency {
  printf " $4"
  file=$1
  if [ $# == 4 ]; then
    counter=$4
    seed=$3
    previous_retval=$2

    if [ $previous_retval != 0 ]; then
      rspec_output=$(bundle exec rspec $file --seed $seed --only-failures 2>/dev/null)
    else
      rspec_output=$(bundle exec rspec $file --seed $seed --fail-fast 2>/dev/null)
    fi

    spec_retval=$?
    seed=$(echo $rspec_output | grep 'seed [0-9][0-9]*' | awk '{ print $NF }' | tail -1)

    if [ $spec_retval != $previous_retval ]; then
      echo "bundle exec rspec $file --seed $seed --only-failures"
      return 1
    fi
    if [ $counter == "100" ]; then
      return 0
    fi

    let "counter += 1"
    hunt_for_order_dependency $file $spec_retval $seed $counter
  else
    counter=1
    # Run the bundle for a given file and fail fast
    rspec_output=$(bundle exec rspec $file --fail-fast 2>/dev/null)
    spec_retval=$?
    seed=$(echo $rspec_output | grep 'seed [0-9][0-9]*' | awk '{ print $NF }' | tail -1)
    echo "file:$file spec_retval:$spec_retval seed:$seed counter:$counter"
    hunt_for_order_dependency $file $spec_retval $seed $counter
  fi

  return 0
}

for file in $(find ./spec/order_dependent_spec.rb -name '*_spec.rb'); do
  printf "running $file"
  hunt_for_order_dependency $file
  printf "\n"
  if [ "$order_dependent" != 0 ]; then
    echo $file
  fi
done
