CC=/opt/openmpi/bin/mpicc
MPI_COMPILE_FLAGS = $(shell $(CC) --showme:compile)
MPI_LINK_FLAGS = $(shell $(CC) --showme:link)

hello: hello.c
	$(CC) $(MPI_COMPILE_FLAGS) hello.c $(MPI_LINK_FLAGS) -o hello.x
