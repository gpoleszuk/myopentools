#!/bin/bash
# Valido apenas para anos entre 1901 e 2099, inclusive

if [ $# -lt 3 ]; then
  echo "Informe uma data valida, no formato"
  echo -ne "\x0a Exemplo: \x0a     $(basename ${0}) dd mm yyyy\x0a\x0a"; exit 1; fi

echo "$1 $2 $3" | awk '{
   dd =$1; mm =$2; yyyy=$3; doy=(mm-1)*31 + dd;
   if( ( (mm>2) && ((yyyy%4)!=0 )) ) {doy=doy - 1};

   if( (mm < 3)             ) {doy=doy  } else {
   if( (mm > 2) && (mm < 5) ) {doy=doy-2} else {
   if( (mm > 4) && (mm < 7) ) {doy=doy-3} else {
   if( (mm > 6) && (mm <10) ) {doy=doy-4} else {
   if( (mm > 9) && (mm <12) ) {doy=doy-5} else {
   if( (mm >11) )             {doy=doy-6}  }}}}}
   printf("%04d %03d\n", yyyy, doy);
}'
