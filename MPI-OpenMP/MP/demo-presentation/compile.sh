#!/bin/bash
ipn_name=$1
h_name=${ipn_name%.ipynb}
rm $h_name
jupyter-nbconvert --to slides $ipn_name --reveal-prefix=./reveal.js \
  --SlidesExporter.reveal_theme='simple' 
  #--SlidesExporter.reveal_transition='fade' 
google-chrome $h_name.slides.html
