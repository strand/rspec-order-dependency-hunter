#!/bin/bash

for file in $(find $1 -name '*_spec.rb'); do
  printf "running $file"

  rspec_output="$(bundle exec rspec $file --order defined       --fail-fast)"
  spec_retval=$?

  rspec_output="$(bundle exec rspec $file --require reverse.rb  --fail-fast)"
  reverse_spec_retval=$?

  if [ $spec_retval == "1" ] || [ $reverse_spec_retval == "1" ]; then

    if [ "$spec_retval" != "$reverse_spec_retval" ]; then
      echo ", which failed inconsistently and may be order-dependent."

      seeded_spec_retval=0
      until [ $seeded_spec_retval == "1" ]; do
        rspec_output="$(bundle exec rspec $file --order random --fail-fast)"
        seeded_spec_retval=$?
      done
      seed=$(echo $rspec_output | grep 'seed [0-9][0-9]*' | awk '{ print $NF }' | tail -1)

      rspec_output="$(bundle exec rspec $file --seed $seed --fail-fast)"
      second_seeded_spec_retval=$?

      if [ "$seeded_spec_retval" == "$second_seeded_spec_retval" ]; then
        rspec_output="$(bundle exec rspec $file --seed $seed --bisect)"
        echo $rspec_output | grep -o 'The minimal reproduction command is.*$'
        echo "^^^^ order-dependent ^^^^"
      else
        echo "^^^^ flickering      ^^^^"
      fi
    else
      echo ", which failed consistently."
    fi
  else
    echo ", which passed consistently."
  fi
done
