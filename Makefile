CC=gcc
CFLAGS=-I.

codeline: codeline.o
	$(CC) -o codeline codeline.o