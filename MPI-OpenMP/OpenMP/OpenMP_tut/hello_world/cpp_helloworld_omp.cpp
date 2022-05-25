/* Include the OpenMP header file */
#include <omp.h>

#include <iostream>
#include <sstream>


int main (int argc, char *argv[])
{
    /* Make the following code block parallel */
    #pragma omp parallel
    {
        std::stringstream ss;

        /*
         * Getting the individual thread number in 'id'
         */
        int id = omp_get_thread_num();

        /* Print Hello world from each thread */
        ss << "Hello World, thread "<< id << std::endl;
        std::cout << ss.str();
        ss.str("");


        /*
         * Every thread print before executing the next line
         */
        #pragma omp barrier

        /* Making the master thread to identify itself! */
        #pragma omp master
        {
            ss << "Master thread, id is always "<< id << std::endl;
            std::cout << ss.str();
            ss.str("");
        }

        /*
         * Print again from each thread
         */
        ss << "Hello OpenMP, thread "<< id << std::endl;
        std::cout << ss.str();
    }

    return 0;
}
