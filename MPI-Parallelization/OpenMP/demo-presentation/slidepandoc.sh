#!/usr/bin/env bash

## Hello World Demo
input="helloworld_demo.txt"
output="helloworld.html"

## Red-Black Demo
#input="checker_demo.txt"
#output="checker.html"


## Unpack Loop Demo
#input="unpackloop_demo.txt"
#output="unpackloop.html"

pandoc -s --mathjax -t revealjs $input -V theme=white -o tmp
sed  's/reveal.js\/js\/reveal.js/reveal.js\/js\/reveal-wide.js/g' tmp > $output
rm tmp
#pandoc -f markdown -t html helloworld.md

open $output
