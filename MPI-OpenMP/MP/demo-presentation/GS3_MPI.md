---
author: Jimmy-Xuan Shen
title: Using MPI on CNSI Clusters
date: Sep 06, 2017
---

### Message Passing Interface <br> (MPI)

<aside class="notes">

Practical aspects: 

- how to compile on the campus clusters 

- how to compile on the campus clusters 

This can *contain markdown*.

</aside>
---

### Main purpose:
communicating between processes

---

### Types of communication:
- synchronization
- movement of data

<img src="https://computing.llnl.gov/tutorials/mpi/images/hybrid_mem.gif">

<aside class="notes">

Quick start/stop signals

Hybrid process, OPENMP MPI

</aside>
---

## General philosophy

- Distribute or send/receive data between processes

- Like a email server for CPUs

---

### Example: sorting

<img src="http://img.sparknotes.com/figures/B/becc4efefde067dce51a326cca23c5f0/mergesort.gif">

---

###

<img src="http://img.sparknotes.com/figures/B/becc4efefde067dce51a326cca23c5f0/mergesort.gif">

  - Full list is  O(N logN)

  - Partial lists are O(N/2 log N/2)

  - Final sorting is O(N)


---

## Considerations while using MPI

* All parallelism is explicitly.

* The user must correctly identify and implement the parallelization.

##

The MPI construct only provides a few algorithms for passing data.  Each MPI process holds onto a single number *myid*.  Parallalization is implemented around these different numbers. 

---

## Approach to the tutorial

---

## Most basic usage senario

---

##

1) Read some input files on one process and distribute the data  
2) Compute $\pi$ by calculating $y=\sqrt{1-x^2}$ on many different points  
3) Collect the result from each MPI process to obtain $\int_{-1}^{1}\,\sqrt{1-x^2}\,dx=\pi/2$    


<img src="http://cercs-ed.gatech.edu/sites/default/files/u24/integrating_circle.jpg" style="width:400px">

<aside class="notes">

Control I/O is very important.

Data that is needed by the process themselves---one file per node

Global I/O, only use the first node.

</aside>
---

# Hello world

```c
#include "mpi.h"
#include <stdio.h>
int main(int argc, char *argv[]) {
    int numprocs, myid;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    printf ("Number of tasks= %d My rank= %d\n", numprocs, myid);
    MPI_Finalize();
    return 0;
}
```
* MPI_COMM_WORLD - Full grouping of processes that are allowed to communicate

---

# Run the code on a KNOT 

### We will compile the code with mpicc and run the code with mpirun

```sh
>>> which mpirun
/opt/intel/compilers_and_libraries_2016.1.150/...
linux/mpi/intel64/bin/mpirun
```
---

```sh
>>> which mpirun
/opt/intel/compilers_and_libraries_2016.1.150/...
linux/mpi/intel64/bin/mpirun
```
- Intel's version of mpirun is loaded by default

- But OPENMPI is much easier to link

```sh
export PATH=/opt/openmpi/bin:$PATH
```

The libarary path must also be availible **even during run time**

```sh
export LD_LIBRARY_PATH=/opt/openmpi/lib:$LD_LIBRARY_PATH
```
---

## Dependencies

### mpicc from OpenMPI has some very nice features that the INTEL version does not.

```sh
# Show the flags necessary to compile MPI C applications
shell$ mpicc --showme:compile
 
# Show the flags necessary to link MPI C applications
shell$ mpicc --showme:link
```
---

## Makefile


```
[jshen@knot hello]$ cat Makefile 
CC=/opt/openmpi/bin/mpicc
MPI_COMPILE_FLAGS = $(shell $(CC) --showme:compile)
MPI_LINK_FLAGS = $(shell $(CC) --showme:link)

hello: hello.c
	$(CC) $(MPI_COMPILE_FLAGS) hello.c \
	$(MPI_LINK_FLAGS) -o hello.x
    
[jshen@knot hello]$ make 
/opt/openmpi/bin/mpicc -I/opt/openmpi-1.6.4/include \
-pthread hello.c -pthread -L/opt/openmpi-1.6.4/lib -lmpi \
-ldl -lm -Wl,--export-dynamic -lrt -lnsl -lutil -o hello.x
```

---

```c
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&myid);
if (myid == 0) {
    printf("WORKING on NODE %d\n", myid);
    FILE *ifp;
    char param[20];
    int val;
    ifp = fopen("cal_pi.inp", "r");
    while (fscanf(ifp, "%s %d", param, &val) != EOF) {
         printf("%stt\n", &param);
        if ( strcmp(param,"div_min") == 0) {
            printf("div_min %d\n", val);
            div_min=val;
        }
        if ( strcmp(param,"div_max") == 0) {
            printf("div_min %d\n", val);
            div_max=val;
        }
    }
}
MPI_Bcast(&div_min, 1, MPI_INT, 0, MPI_COMM_WORLD);
    // variable count data_type, root, comm 
MPI_Bcast(&div_max, 1, MPI_INT, 0, MPI_COMM_WORLD);
MPI_Barrier( MPI_COMM_WORLD ) ;

for (n=div_min; n<div_max;n++) {
    if (n == 0) break;

    h   = 1.0 / (double) n;
    sum = 0.0;
	//increment by numprocs
    for (i = myid + 1; i <= n; i += numprocs) { 
        x = h * ((double)i - 0.5);
        sum += 4.0 / (1.0 + x*x);
    }

    mypi = h * sum;

    MPI_Barrier( MPI_COMM_WORLD ) ;
    MPI_Reduce(&mypi, &pi, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (myid == 0)
        printf("(n=%d) pi is approximately %.16f, Error is %.16f\n",
                n, pi, fabs(pi - PI25DT));
}
MPI_Finalize();
```
---

- MPI	Standard	:	http://www.mpi-forum.org/docs/docs.html 
- MPI	Forum	:	http://www.mpi-forum.org/ 

- MPI	implementations: 
    + MPICH	:	http://www.mpich.org 
    + MVAPICH	:	http://mvapich.cse.ohio-state.edu/ 
    + Intel	MPI:	http://software.intel.com/en-us/intel -mpi -library/ 
    + Open	MPI	:	http://www.open-mpi.org/ 
    + IBM	MPI,	Cray MPI
    + You will see some combination of these of the different computing cluster
