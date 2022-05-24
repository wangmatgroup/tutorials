CC=/opt/openmpi/bin/mpicc
MPI_COMPILE_FLAGS = $(shell $(CC) --showme:compile)
MPI_LINK_FLAGS = $(shell $(CC) --showme:link)

cal_pi: cal_pi.c
	$(CC) $(MPI_COMPILE_FLAGS) cal_pi.c $(MPI_LINK_FLAGS) -o cal_pi.x
