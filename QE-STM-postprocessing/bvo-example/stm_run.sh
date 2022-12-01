#!/usr/bin/env bash

# Adapted from PP/Example03, wwwennie
# Simulated STM image 
# Generates STM image @ +/- bias
#                     @ +/- bias, constant current
#           Plot script for LDOS boxes
#           Plot script for LDOS spectra

# see below for environment variables: QEDIR, BIN_DIR, etc.
#   and change accordingly 

# example usage
#    ./stm_run.sh
#    ./stm_run.sh stm_input.dat (default input file name)
#    ./stm_run.sh stm_AlAs.dat

### import input parameters
if [[ "$#" -eq 1 ]]; then
  input_file=$1
else
  input_file="stm_input.dat"
fi

# run from directory where this script is
cd `echo $0 | sed 's/\(.*\)\/.*/\1/'` # extract pathname
EXAMPLE_DIR=`pwd`

# check whether echo has the -e option
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

$ECHO
$ECHO "$EXAMPLE_DIR : starting"
$ECHO
$ECHO "Calculation of STM maps."


### ----- USER INPUT -------
# these are default values, can be overridden
# adapted from environment_variables
QEDIR="/home/wwwennie/bin2/qe-6.3/"
BIN_DIR=$QEDIR/bin
PSEUDO_DIR=$QEDIR/pseudo
TMP_DIR=`pwd`
PARA_PREFIX=" "
PARA_PREFIX="mpirun -np 4"
PARA_POSTFIX=" -nk 1 -nd 1 -nb 1 -nt 1 "
# function to test the exit status of a job
check_failure () {
    # usage: check_failure $?
    if test $1 != 0
    then
        echo "Error condition encountered during test: exit status = $1"
        echo "Aborting"
        exit 1
    fi
}

prefix="pwscf"
source ./${input_file}

# required executables and pseudopotentials
BIN_LIST="pw.x pp.x plotrho.x projwfc.x sumpdos.x"

$ECHO
$ECHO "  executables directory: $BIN_DIR"
$ECHO "  pseudo directory:      $PSEUDO_DIR"
$ECHO "  temporary directory:   $TMP_DIR"
$ECHO "  checking that needed directories and files exist...\c"

# check for directories
for DIR in "$BIN_DIR" "$PSEUDO_DIR" ; do
    if test ! -d $DIR ; then
        $ECHO
        $ECHO "ERROR: $DIR not existent or not a directory"
        $ECHO "Aborting"
        exit 1
    fi
done
for DIR in "$TMP_DIR" "$EXAMPLE_DIR/stm_results" ; do
    if test ! -d $DIR ; then
        mkdir $DIR
    fi
done
cd $EXAMPLE_DIR/stm_results

# check for executables
for FILE in $BIN_LIST ; do
    if test ! -x $BIN_DIR/$FILE ; then
        $ECHO
        $ECHO "ERROR: $BIN_DIR/$FILE not existent or not executable"
        $ECHO "Aborting"
        exit 1
    fi
done

# check for gnuplot
GP_COMMAND=`which gnuplot 2>/dev/null`
if [ "$GP_COMMAND" = "" ]; then
        $ECHO
        $ECHO "gnuplot not in PATH"
        $ECHO "Results will not be plotted"
fi

$ECHO " done"

# how to run executables
PW_COMMAND="$PARA_PREFIX $BIN_DIR/pw.x $PARA_POSTFIX"
PP_COMMAND="$PARA_PREFIX $BIN_DIR/pp.x $PARA_POSTFIX"
PLOTRHO_COMMAND="$BIN_DIR/plotrho.x"
PROJWFC_COMMAND="$PARA_PREFIX $BIN_DIR/projwfc.x $PARA_POSTFIX"
SUMPDOS_COMMAND="$BIN_DIR/sumpdos.x"
$ECHO
$ECHO "  running pw.x as:      $PW_COMMAND"
$ECHO "  running pp.x as:      $PP_COMMAND"
$ECHO "  running plotrho.x as: $PLOTRHO_COMMAND"
$ECHO "  running projwfc.x as: $PROJWFC_COMMAND"
$ECHO "  running sumpdos.x as: $SUMPDOS_COMMAND"
$ECHO "  running gnuplot as:   $GP_COMMAND"
$ECHO


# post-processing for stm images (sample bias given in Ry!)
cat > ${prefix}.pp_stm-.in << EOF
 &inputpp
    prefix  = '${prefix}'
    outdir='$TMP_DIR/',
    filplot = '${prefix}resm-neg'
    sample_bias=-${sample_bias_neg},
    plot_num= 5
 /
 &plot
   nfile=1
   filepp(1)='${prefix}resm-neg'
   weight(1)=1.0
   iflag=2
   output_format=2
   e1(1)=${e1[0]}, e1(2)=${e1[1]},     e1(3)=${e1[2]}
   e2(1)=${e2[0]}, e2(2)=${e2[1]},     e2(3)=${e2[2]}
   x0(1)=${x0[0]}, x0(2)=${x0[1]},   x0(3)=${x0[2]}
   nx=$nx ,ny=$ny
   fileout='${prefix}-neg'
 /
EOF
$ECHO
$ECHO "  running the post-processing phase, negative bias...\c"
$PP_COMMAND < ${prefix}.pp_stm-.in > ${prefix}.pp_stm-.out
check_failure $?
$ECHO " done"

# run plotrho to do the figure
cat > ${prefix}.plotrho-.in << EOF
${prefix}-neg
${prefix}-neg.ps
n
${rhomin_neg} ${rhomax_neg}  ${nlevels}
EOF
$ECHO "  running plotrho on negative bias data...\c"
$PLOTRHO_COMMAND < ${prefix}.plotrho-.in > ${prefix}.plotrho-.out
check_failure $?
$ECHO " done"

# post-processing for stm images (negative bias, constant current)
cat > ${prefix}.pp_isostm-.in << EOF
 &inputpp
 /
 &plot
    nfile=1
    filepp(1)='${prefix}resm-neg'
    weight(1)=1.0
    iflag=2
    output_format=7    
    fileout='${prefix}.pp_isostm-.dat'
    e1(1)=${e1[0]}, e1(2)=${e1[1]},     e1(3)=${e1[2]}
    e2(1)=${e2[0]}, e2(2)=${e2[1]},     e2(3)=${e2[2]}
    nx=${nx_c}, ny=${ny_c}
    isostm_flag=.true.
    isovalue=${isovalue}
    heightmin=${heightmin}
    heightmax=${heightmax}
    direction=${direction}
 /
EOF
$ECHO
$ECHO "  STM image, negative bias and constant current...\c"
$PP_COMMAND < ${prefix}.pp_isostm-.in > ${prefix}.pp_isostm-.out
check_failure $?
$ECHO " done"

# run gnuplot to do the figure
if [ "$GP_COMMAND" = "" ]; then
    break
else
cat > gnuplot.tmp <<EOF
set term postscript enhanced color solid lw 3 24
set output '${prefix}-neg.isoplot.ps'
set xlabel "x (bohr)"
set ylabel "y (bohr)"
set pm3d map
set size ratio -1
set palette rgb 21,22,23
set tics out
unset key
splot [0:51.972][0:52.500] '${prefix}.pp_isostm-.dat'
EOF
$ECHO
$ECHO "  plotting results ...\c"
$GP_COMMAND < gnuplot.tmp
$ECHO " done"
rm gnuplot.tmp
fi

# post-processing for stm images (as before, but positive bias)
cat > ${prefix}.pp_stm+.in << EOF
 &inputpp
    prefix  = '${prefix}'
    outdir='$TMP_DIR/',
    filplot = '${prefix}resm-pos'
    sample_bias=${sample_bias_pos},
    plot_num= 5
 /
 &plot
   nfile=1
   filepp(1)='${prefix}resm-pos'
   weight(1)=1.0
   iflag=2
   output_format=2
   e1(1)=${e1[0]}, e1(2)=${e1[1]},     e1(3)=${e1[2]}
   e2(1)=${e2[0]}, e2(2)=${e2[1]},     e2(3)=${e2[2]}
   x0(1)=${x0[0]}, x0(2)=${x0[1]},   x0(3)=${x0[2]}
   nx=$nx ,ny=$ny
   fileout='${prefix}-pos'
 /
EOF
$ECHO "  running the post-processing phase, positive bias...\c"
$PP_COMMAND < ${prefix}.pp_stm+.in > ${prefix}.pp_stm+.out
check_failure $?
$ECHO " done"

# plotrho
cat > ${prefix}.plotrho+.in << EOF
${prefix}-pos
${prefix}-pos.ps
n
${rhomin_pos} ${rhomax_pos} ${nlevels}
EOF
$ECHO "  running plotrho on positive bias data...\c"
$PLOTRHO_COMMAND < ${prefix}.plotrho+.in > ${prefix}.plotrho+.out
check_failure $?
$ECHO " done"

# post-processing for stm images (positive bias, constant current)
cat > ${prefix}.pp_isostm+.in << EOF
 &inputpp
 /
 &plot
    nfile=1
    filepp(1)='${prefix}resm-pos'
    weight(1)=1.0
    iflag=2
    output_format=7    
    fileout='${prefix}.pp_isostm+.dat'
    e1(1)=${e1[0]}, e1(2)=${e1[1]},     e1(3)=${e1[2]}
    e2(1)=${e2[0]}, e2(2)=${e2[1]},     e2(3)=${e2[2]}
    nx=${nx_c} ,ny=${ny_c}
    isostm_flag=.true.
    isovalue=${isovalue}
    heightmin=${heightmin}
    heightmax=${heightmax}
    direction=${direction}
 /
EOF
$ECHO
$ECHO "  STM image, positive bias and constant current...\c"
$PP_COMMAND < ${prefix}.pp_isostm+.in > ${prefix}.pp_isostm+.out
check_failure $?
$ECHO " done"

# run gnuplot to do the figure
if [ "$GP_COMMAND" = "" ]; then
    break
else
cat > gnuplot.tmp <<EOF
set term postscript enhanced color solid lw 3 24
set output '${prefix}-pos.isoplot.ps'
set xlabel "x (bohr)"
set ylabel "y (bohr)"
set pm3d map
set size ratio -1
set palette rgb 21,22,23
set tics out
unset key
splot [0:51.972][0:52.500] '${prefix}.pp_isostm+.dat'
EOF
$ECHO
$ECHO "  plotting results ...\c"
$GP_COMMAND < gnuplot.tmp
$ECHO " done"
rm gnuplot.tmp
fi

# Projection of the DOS on volumes (boxes)
cat > tmp.box.projwfc.in << EOF
 &projwfc
    prefix  = '${prefix}'
    outdir='$TMP_DIR/',
    ngauss=0
    degauss=${degauss}
    DeltaE=${DeltaE}
    tdosinboxes=.true.
    plotboxes=.true.
    n_proj_boxes=${n_proj_boxes}

 /
EOF
$ECHO
cat tmp.box.projwfc.in $TMP_DIR/tmp_box > ${prefix}.box.projwfc.in
$ECHO "  running local DOS calculation...\c"
$PROJWFC_COMMAND < ${prefix}.box.projwfc.in > ${prefix}.box.projwfc.out
check_failure $?
$ECHO " done"

# Projection of the DOS on atomic wavefunctions
cat > ${prefix}.projwfc.in << EOF
 &projwfc
    prefix  = '${prefix}'
    outdir='$TMP_DIR/',
    ngauss=0
    degauss=${degauss}
    DeltaE=${DeltaE}
    tdosinboxes=.false.
 /
EOF
$ECHO
$ECHO "  running projected DOS calculation...\c"
$PROJWFC_COMMAND < ${prefix}.projwfc.in > ${prefix}.projwfc.out
check_failure $?
$ECHO " done"

$ECHO
$ECHO "  summing the atomic PDOS...\c"
for atom in ${pdos_atoms[@]}; do
$SUMPDOS_COMMAND "${prefix}.pdos_atm\#10\(${atom}\)_wfc*" > "${prefix}.pdos_atm\#10(${atom})" 2> /dev/null
done
$ECHO " done"

#
#  if gnuplot was found, the results are plotted
#
if [ "$GP_COMMAND" = "" ]; then
    break
else
cat > gnuplot.tmp <<EOF
set term postscript enhanced color solid lw 3 24
set output '${prefix}.box.projwfc.ps'
ef=$eFermi
set xlabel "Energy - E_F (eV)"
set ylabel "Local DOS (states/eV)"
set style data lines
set key top left Left reverse
set border 31 lw 0.2
set title "Projected DOS"
plot \\
EOF
for atom in ${pdos_atoms[@]}; do
echo "./${prefix}.pdos_atm#10(${atom})" u (\$1-ef):2 t "Surface ${atom}"  >> gnuplot.tmp
done
# './${prefix}.pdos_atm#11(As)' u (\$1-ef):2 t "Surface As"
cat >> gnuplot.tmp << EOF
set title "Local DOS centered in the first vacuum layer"
plot \\
EOF
 './${prefix}.ldos_boxes' u (\$1-ef):4 t "Above Al" ,\\
 './${prefix}.ldos_boxes' u (\$1-ef):5 t "Above As" ,\\
 './${prefix}.ldos_boxes' u (\$1-ef):(\$7/54) t "Surface average"
cat >> gnuplot.tmp << EOF
set title "Local DOS centered in the second vacuum layer"
plot \\
 './${prefix}.ldos_boxes' u (\$1-ef):8 t "Above Al" ,\\
 './${prefix}.ldos_boxes' u (\$1-ef):9 t "Above As" ,\\
 './${prefix}.ldos_boxes' u (\$1-ef):(\$11/54) t "Surface average"
EOF
$ECHO
$ECHO "  plotting DOS results ...\c"
$GP_COMMAND < gnuplot.tmp
$ECHO " done"
rm gnuplot.tmp
fi

$ECHO
$ECHO "  To visualize a volume in which the DOS is integrated, execute:"
$ECHO "    xcrysden --xsf results/${prefix}.box#1.xsf"
$ECHO "  and plot the isosurface corresponding to isovalue 0.5"

$ECHO
 clean TMP_DIR
$ECHO "  cleaning $TMP_DIR...\c"
rm -rf $TMP_DIR/${prefix}.*
rm tmp* $TMP_DIR/tmp*
$ECHO
$ECHO " $EXAMPLE_DIR: done"
