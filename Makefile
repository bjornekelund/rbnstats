cc		= gcc
gcc		= ${cc} -Wall
lint		= cppcheck

all:		cunique

cunique:	cunique.c Makefile
		$(gcc) -o cunique cunique.c -lm

clean:
		rm -f *.o *~ cunique

lint:
		${lint} cunique.c
