program red_black

    use omp_lib

    implicit none

    integer, parameter                  :: grid_x = 10, grid_y= 5000, numitr = 10000
    double precision, dimension(0:grid_x-1, 0:grid_y-1)   :: grid
    double precision                    :: tot = 0.0
    double precision                    :: start_time, final_time
    integer                             :: i, j, n

    ! start timer
    start_time = omp_get_wtime()
    final_time = 0.0

    ! Note: for Fortran, loops are more efficient
    !   if written with column major order array indexing

    !$omp parallel do private(i) schedule(static)
    !initialize the grid
    do j = 1, grid_y 
        do i = 1, grid_x 
            grid(i, j) = mod((i * j), 15)
        end do
    end do
    !$omp end parallel do


    ! Because each iteration dependends on previous iteration
    !   cannot parallelize over numiter
    ! Instead, parallelize over updating grid points

    do n = 1, numitr
    !$omp parallel private(i, j)
        ! >>>>>> Update red points <<<<

        !$omp do schedule(static)
        ! updates odd columns
        do j = 1, grid_y - 2, 2
            do i = 1, grid_x - 2, 2
                grid(i, j) = 0.2 * (grid(i-1, j) + grid(i+1, j) +&
                            grid(i, j-1) + grid(i, j+1))
            end do
        end do
        !$omp end do nowait


        !$omp do schedule(static)
        ! updates even columns
        do j = 2, grid_y - 2, 2
            do i = 2, grid_x - 2, 2
                grid(i, j) = 0.2 * (grid(i-1, j) + grid(i+1, j) +&
                            grid(i, j-1) + grid(i, j+1))
            end do
        end do
        !$omp end do

        ! ------------------------------------------------!
        ! >>>>> Update black points <<<<<

        !$omp do schedule(static)
        do j = 2, grid_y - 2, 2
            do i = 1, grid_x - 2, 2
                grid(i, j) = 0.2 * (grid(i-1, j) + grid(i+1, j) +&
                            grid(i, j-1) + grid(i, j+1))
            end do
        end do
        !$omp end do nowait

        !$omp do schedule(static)
        do j = 1, grid_y - 2, 2
            do i = 2, grid_x - 2, 2
                grid(i, j) = 0.2 * (grid(i-1, j) + grid(i+1, j) +&
                            grid(i, j-1) + grid(i, j+1))
            end do
        end do
        !$omp end do
    !$omp end parallel
    end do

    !$omp parallel do private(i) schedule(static) reduction(+:tot)
    do j = 1, grid_y 
        do i = 1, grid_x
            tot = tot + grid(i, j)
        end do
    end do
    !$omp end parallel do

    ! Get total run time
    final_time = omp_get_wtime() - start_time;
 
    write (*, '(a,f14.2)') 'Sum: ', tot
    write (*, '(a,f20.6)') 'Total time:  ', final_time
    write (*, *)
    stop
end program red_black
