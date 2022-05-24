program hello_world

    ! TODO: include OpenMP module

    implicit none


    ! TODO: Make the following code block parallel

    ! TODO: Get the individual thread number in 'id'
    integer :: thread_id = 0


    ! Print Hello world from each thread
    write ( *, * ) 'Hello World, thread ', thread_id

    ! TODO: How do we have every thread print before executing 
    ! the next line?

    ! TODO: Now get the master thread to identify itself!
    write ( *, * ) 'Master thread, id is always ', thread_id

    ! TODO: Print again from each thread
    write ( *, * ) 'Hello OpenMP, thread  ', thread_id

    stop

end program hello_world

