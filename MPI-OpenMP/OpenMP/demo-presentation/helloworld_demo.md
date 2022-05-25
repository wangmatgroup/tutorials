
<h1><center><font size="+4"> OpenMP Demo 1: Hello World</font></center></h1>
=============================

<font size="+2"> Basic demonstration of OpenMP <br/></font>
<br/>
<font size="+2"><p>Concepts we will learn </p></font>
<font size="+2"><ul>
  <li>How threads work</li>
  <li>Master v worker threads</li>
  <li>Synchronization</li>
</ul></font>



<h2><center><font size="+2"> Parallelizing the code </font></center></h2>
<br/>
<font size="+2">We will use `C++` in the following example.</font><br/>
<font size="+2">Let's look at the code in serial.</font>
<br/>


```cpp
/*@TODO: Include the OpenMP header file */

#include <iostream>
#include <sstream>

int main(int argc, char *argv[])
{

    /* @TODO: Insert OpenMP pragma to make the following code block parallel */
    {
        std::stringstream ss;

        /*
         * @TODO: Get the individual thread number in 'id'
         * using a runtime routine
         */
        int id = 0;

        /* Print Hello world from each thread */
        ss << "Hello World from thread "<< id << std::endl;
        std::cout << ss.str();
        ss.str("");

        /*
         * @TODO: Make absolutely sure each thread has printed "Hello World",
         * before we move forward
         */

        /* @TODO: Now get the master thread to identify itself! */
        ss << "Hi, I am MASTER, my id is always " << id << std::endl;
        std::cout << ss.str();
        ss.str("");

        /*
         * Now print Hello OpenMP from each thread
         * (after all everybody needs to learn OpenMP!)
         */
        ss << "Hello OpenMP from thread " << id << std::endl;
        std::cout << ss.str();
    }

    return 0;
}

```


<font size="+2">Let's look at the same code with OpenMP directives.</font>

```cpp
/* Including the OpenMP header file */
#include <omp.h>

#include <iostream>
#include <sstream>


int main (int argc, char *argv[])
{
    /* Inserting OpenMP pragma to make the following code block parallel */
    #pragma omp parallel
    {
        std::stringstream ss;

        /*
         * Getting the individual thread number in 'id'
         * using a runtime routine
         */
        int id = omp_get_thread_num();

        /* Print Hello world from each thread */
        ss << "Hello World from thread "<< id << std::endl;
        std::cout << ss.str();
        ss.str("");

        /*
         * Making sure each thread has printed "Hello World",
         * before we move forward
         */

        #pragma omp barrier

        /* Making the master thread to identify itself! */
        #pragma omp master
        {
            ss << "Hi, I am MASTER, my id is always "<< id << std::endl;
            std::cout << ss.str();
            ss.str("");
        }

        /*
         * Now print Hello OpenMP from each thread
         * (after all everybody needs to learn OpenMP!)
         */
        ss << "Hello OpenMP from thread "<< id << std::endl;
        std::cout << ss.str();
    }

    return 0;
}

```

<h2><center><font size="+2"> Compiling </font></center></h2>
<br/>

```
-> wwwennie@knot:~ cd OpenMP_tut/hello_world
-> wwwennie@knot:~/OpenMP_tut/hello_world make
g++ -fopenmp -Wall -o cpp_exercise_hello_world.x cpp_exercise_hello_world.cpp
g++ -fopenmp -Wall -o cpp_solution_hello_world.x cpp_solution_hello_world.cpp
```



```cpp
#
# Choose compiler with "make compiler=NAME" or just "make" to use
# default of GNU compilers.
#

ifeq ($(compiler), intel)	# begin compiler check

CC              = icc
CFLAGS          = -qopenmp -Wall

CXX             = icpc
CXXFLAGS        = -qopenmp -Wall

FC              = ifort
FFLAGS          = -qopenmp

else ifeq ($(compiler), cray)

...

end if				# end compiler check

C_SOURCES       = $(wildcard *.c)
CPP_SOURCES     = $(wildcard *.cpp)
FORTRAN_SOURCES = $(wildcard *.f90)
SOURCES         = $(C_SOURCES) $(CPP_SOURCES) $(FORTRAN_SOURCES)

C_TARGETS       = $(C_SOURCES:.c=.x)
CPP_TARGETS     = $(CPP_SOURCES:.cpp=.x)
FORTRAN_TARGETS = $(FORTRAN_SOURCES:.f90=.x)
TARGETS         = $(C_TARGETS) $(CPP_TARGETS) $(FORTRAN_TARGETS)

.PHONY: all     clean

all:    $(TARGETS)

clean: 
	rm -f $(TARGETS)

.SUFFIXES: .x 

%.x: %.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^

%.x: %.c
	$(CC) $(CFLAGS) -o $@ $^

%.x: %.f90
	$(FC) $(FFLAGS) -o $@ $^


```


<h2><center><font size="+2"> Running and Output </font></center></h2>


```
wwwennie@knot:~/OpenMP_tut/hello_world$ cat job.hello
```

```bash
#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:10:00
#PBS -j oe
#PBS -V
cd $PBS_O_WORKDIR
export OMP_NUM_THREADS = 12
mpirun ./c_solution_hello_world.x 
```

```
wwwennie@knot:~/OpenMP_tut/hello_world$ qsub job.hello
```

```
Hello World from thread 4
Hello World from thread 8
Hello World from thread 9
Hello World from thread 11
Hello World from thread 10
Hello World from thread 5
Hello World from thread 3
Hello World from thread 7
Hello World from thread 0
Hello World from thread 6
Hello World from thread 1
Hello World from thread 2
Hello OpenMP from thread 1
Hello OpenMP from thread 6
Hello OpenMP from thread 2
Hello OpenMP from thread 4
Hello OpenMP from thread 8
Hello OpenMP from thread 9
Hello OpenMP from thread 11
Hello OpenMP from thread 5
Hello OpenMP from thread 3
Hello OpenMP from thread 7
Hello OpenMP from thread 10
Hi, I am MASTER, my id is always 0
Hello OpenMP from thread 0
```
