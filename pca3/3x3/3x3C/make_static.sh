#!/bin/sh

rm *.o
gcc -fPIC -Wall -O3 -std=c99 *.c -lm -c 
ar rcs 3x3.a *.o
