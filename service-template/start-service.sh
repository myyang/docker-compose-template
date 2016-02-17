#!/bin/bash

hm="\n
Usage:\n
   -u   update service \n
   -h   show this message\n
"

update=0
while getopts "uh" o; do
    case $o in
        u)      update=1
                ;;
        h)      echo -e $hm >&2
                exit 1
                ;;
        \?)     echo "invalid options -$OPTARG" >&2
                exit 1
                ;;
    esac
done

export `cat envs`

echo -e $hm
