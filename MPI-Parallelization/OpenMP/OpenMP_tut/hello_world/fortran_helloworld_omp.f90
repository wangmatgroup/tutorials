program hello_world

    ! include OpenMP module
    use omp_lib

    implicit none

    integer :: thread_id

    ! Make the following code block parallel
    !$omp parallel private(thread_id)

        ! Getting the individual thread number in 'id'
        thread_id = omp_get_thread_num()

        ! Print Hello world from each thread
        write ( *, * ) 'Hello World, thread ', thread_id

        ! make sure every thread prints before executing 
        ! the next line?
        !$omp barrier

        ! Only the master thread prints
        !$omp master
            write ( *, * ) 'Master thread, id is always ', thread_id
        !$omp end master

        ! Print again from each thread
        write ( *, * ) 'Hello OpenMP, thread  ', thread_id

    !$omp end parallel   
    ! implicit barrier at end of parallel block

    stop

  end program hello_world

