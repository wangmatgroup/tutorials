#include <iostream>
#include <vector>
#include <stdlib.h>
#include <omp.h>

#define iter 10000
#define grid_x 10
#define grid_y 5000

int main(int argc, char *argv[])
{
    int i, j, n;
    std::vector <std::vector <double> >grid(grid_x, std::vector <double>(grid_y, 0));
    double tot = 0.0;

    double start_time, final_time;

    /* starting timer */
    start_time = omp_get_wtime();

    /*
     * Note: with collapse, running with over more threads
     * than outer num. iterations would be inefficient
     * i.e., now have 10 outer iterations
     */
    #pragma omp parallel for private(j) collapse(2) schedule(static)
    for (i = 0; i < grid_x; i++) {
        for (j = 0; j < grid_y; j++)
            grid[i][j] = (i * j) % 15;
    }

    /*
     * Parallelizing the outer loop is not possible.
     * Each iteration depends on the value of previous iteration
     * so we will parallelize one level below
     */
    for (n = 0; n < iter; n++) {
        #pragma omp parallel private(i, j)
        {
            /* Update red points */
            #pragma omp for collapse(2) schedule(static) nowait
            for (i = 1; i < grid_x - 1; i += 2)
                for (j = 1; j < grid_y - 1; j += 2)
                    grid[i][j] =
                        0.2 * (grid[i - 1][j] + grid[i + 1][j] +
                                grid[i][j - 1] + grid[i][j + 1]);

            #pragma omp for collapse(2) schedule(static)
            for (i = 2; i < grid_x - 1; i += 2)
                for (j = 2; j < grid_y - 1; j += 2)
                    grid[i][j] =
                        0.2 * (grid[i - 1][j] + grid[i + 1][j] +
                                grid[i][j - 1] + grid[i][j + 1]);

            /* Update black points */
            #pragma omp for collapse(2) schedule(static) nowait
            for (i = 1; i < grid_x - 1; i += 2)
                for (j = 2; j < grid_y - 1; j += 2)
                    grid[i][j] =
                        0.2 * (grid[i - 1][j] + grid[i + 1][j] +
                                grid[i][j - 1] + grid[i][j + 1]);

            #pragma omp for collapse(2) schedule(static)
            for (i = 2; i < grid_x - 1; i += 2)
                for (j = 1; j < grid_y - 1; j += 2)
                    grid[i][j] =
                        0.2 * (grid[i - 1][j] + grid[i + 1][j] +
                                grid[i][j - 1] + grid[i][j + 1]);
        }
    }


    #pragma omp parallel for private(j) collapse(2) schedule(static) reduction(+:tot)
    for (i = 0; i < grid_x; i++)
        for (j = 0; j < grid_y; j++)
            tot += grid[i][j];


    final_time = omp_get_wtime() - start_time;

    std::cout.precision(2);
    std::cout << "Sum: " << std::fixed << tot << std::endl;
    std::cout.precision(6);
    std::cout << "Total Time: " << final_time << std::endl;

    return 0;
}
