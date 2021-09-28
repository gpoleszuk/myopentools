/*.. ....-.... ....-.... ....-.... ....-.... ....-.... ....-.... ....-*/
/*Compile com gcc yyyydoy2ddmmyyyy.c -o yyyydoy2ddmmyyyy.e            */
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
   if (argc < 2) { return 1; }

   short int dd, yyyy, doy, mm=0, sum=0;
   short int c[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

   yyyy = atoi(argv[1]); doy = atoi(argv[2]);

   if(!(yyyy%4)) c[1]=29;
   while(sum < doy) {sum += c[mm++];} dd = doy-sum+c[--mm]; mm++;

   printf("\n%02d %02d %04d\n", dd, mm, yyyy);
   return 0;}
/*.. ....-.... ....-.... ....-.... ....-.... ....-.... ....-.... ....-*/
