in=$1
out=$2
convert -define icon:auto-resize=128,64,48,32,16 -gravity center  $in   $out