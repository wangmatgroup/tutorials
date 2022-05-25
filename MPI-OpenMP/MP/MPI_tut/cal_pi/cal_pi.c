#include "mpi.h"
#include <math.h>
#include <stdio.h>

int main(argc,argv)
    int argc;
    char *argv[];
{
    int done = 0, n, myid, numprocs, i;
    int div_min, div_max;
    double PI25DT = 3.141592653589793238462643;
    double mypi, pi, h, sum, x;



    char * trim(char *c) {
        char * e = c + strlen(c) - 1;
        while(*c && isspace(*c)) c++;
        while(e > c && isspace(*e)) *e-- = '\0';
        return c;
    }

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    while (!done)
    {
        if (myid == 0) {
            printf("WORKING on NODE %d\n", myid);
            FILE *ifp;
            char param[20];
            int val;
            ifp = fopen("cal_pi.inp", "r");
            while (fscanf(ifp, "%s %d", param, &val) != EOF) {
                 printf("%s\n", &param);
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
        MPI_Bcast(&div_max, 1, MPI_INT, 0, MPI_COMM_WORLD);
        MPI_Barrier( MPI_COMM_WORLD ) ;

        for (n=div_min; n<div_max;n++) {
            if (n == 0) break;

            h   = 1.0 / (double) n;
            sum = 0.0;
            for (i = myid + 1; i <= n; i += numprocs) {
                x = h * ((double)i - 0.5);
                sum += 4.0 / (1.0 + x*x);
            }

            mypi = h * sum;

            MPI_Barrier( MPI_COMM_WORLD ) ;
            MPI_Reduce(&mypi, &pi, 1, MPI_DOUBLE, MPI_SUM, 0,
                    MPI_COMM_WORLD);

            if (myid == 0)
                printf("(n=%d) pi is approximately %.16f, Error is %.16f\n",
                        n, pi, fabs(pi - PI25DT));
        }
        done=1;
    }
    MPI_Finalize();
    return 0;
}
