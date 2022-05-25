/*TODO: Include the OpenMP header file */

#include <iostream>
#include <sstream>

int main(int argc, char *argv[])
{

    /* TODO: Make the following code block parallel */
    {
        std::stringstream ss;

        /*
         * TODO: Get the individual thread number in 'id'
         */
        int id = 0;

        /* Print Hello world from each thread */
        ss << "Hello World,  thread "<< id << std::endl;
        std::cout << ss.str();
        ss.str("");

        /*
         * TODO: How do we have every thread print before
         * executing the next line?
         */

        /* TODO: Now get the master thread to identify itself! */
        ss << "Master thread, id is always " << id << std::endl;
        std::cout << ss.str();
        ss.str("");

        /*
         * Print again from each thread
         */
        ss << "Hello OpenMP, thread " << id << std::endl;
        std::cout << ss.str();
    }

    return 0;
}
