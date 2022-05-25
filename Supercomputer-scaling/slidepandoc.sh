#!/usr/bin/env bash

input="scaling_tests_demo.txt"
output="scaling_tests_demo.html"

# pseudo stand alone reveal.js that pandoc can access for self-contained html
# find user data diretory: pandoc --version
# put download of reveal.js in that directory as reveal.js
 
## vanilla html
#pandoc -s --mathjax -t revealjs  $input -V  theme=white -o tmp 

## pseudo stand alone html that doesn't need reveal.js in relative path (?)
#pandoc -s --mathjax -t revealjs --self-contained $input -V theme=white -V revealjs-url=https://unpkg.com/reveal.js@3.9.2/ -V fontsize=18 -o tmp 
pandoc -s --mathjax -t revealjs $input -V theme=white -V revealjs-url=https://unpkg.com/reveal.js@3.9.2/ -V fontsize=18 -o tmp 
sed  's/reveal.js\/js\/reveal.js/reveal.js\/js\/reveal-wide.js/g' tmp > $output
rm tmp

