#!/bin/bash

proc=(144 160 320)
npool=(2 4 6 8)

for i in "${proc[@]}"; do
   for j in "${npool[@]}"; do
       mkdir p${i}n${j}; cd p${i}n${j}
       # copy template input files
       cp -r ../input.in ../*UPF ../phrun.sh .
       # substitute parallelization into run command 
       # of a template job submission script called phrun.sh
       sed -i "s/REPL1/${i}/g" phrun.sh; sed -i "s/REPL2/${j}/g" phrun.sh
       cd ../
   done
done
