  GNU nano 2.9.3                                                     /home/gpsr/tools/ddmmyyyy2doy.c                                                               
/*.. ....-.... ....-.... ....-.... ....-.... ....-.... ....-.... ....-*/
/*Compile com gcc ddmmyyyy2yyyydoy.c -o ddmmyyyy2yyyydoy.e*/
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
   if (argc < 4) { return 1; }

   short int mm, dd, yyyy, doy;
   short int c[11] = {31,28,31,30,31,30,31,31,30,31,30};

   dd = atoi(argv[1]);  doy = dd;
   mm = atoi(argv[2]); yyyy = atoi(argv[3]);

   if(!(yyyy%4)) c[1]=29;
   for(int i=0; i<=(mm-2); i++) doy += c[i];
   printf("\n%04d %03d\n", yyyy, doy);

   return 0;}
/*.. ....-.... ....-.... ....-.... ....-.... ....-.... ....-.... ....-*/
