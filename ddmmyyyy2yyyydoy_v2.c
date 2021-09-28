/*.. ....-.... ....-.... ....-.... ....-.... ....-.... ....-.... ....-*/
/*Compile com gcc ddmmyyyy2yyyydoy.c -o ddmmyyyy2yyyydoy.e*/
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
   if (argc < 4) { return 1; }

   short int mm, dd, yyyy, doy;
   short int c[12] = { 0, 0,-2,-2,-3,-3,-4,-4,-4,-5,-5,-6};

   dd  = atoi(argv[1]); yyyy = atoi(argv[3]);
   mm  = atoi(argv[2]); doy = (mm-1)*31 + dd;

   if( (mm>2) && (yyyy%4) ) doy--;
   doy+=c[mm-1];
   printf("\n%04d %03d\n", yyyy, doy);

   return 0;}
/*.. ....-.... ....-.... ....-.... ....-.... ....-.... ....-.... ....-*/
