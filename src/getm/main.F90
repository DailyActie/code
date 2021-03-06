#include "cppdefs.h"
!!-----------------------------------------------------------------------
!!BOI
!!
!! !TITLE: Documentation of getm
!!
!! !AUTHORS: Hans Burchard and Karsten Bolding
!!
!! !DATE:
!!
!! !INTRODUCTION:
!!
!!EOI
!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: getm - main program
!
! !INTERFACE:
   program getm
!
! !DESCRIPTION:
!
! !USES:
   use initialise, only: init_model,runtype,dryrun
   use time, only: simtime
   use domain, only: calc_points
   use m2d, only: mem2d
   use getm_timers, only: write_getm_timers
#ifndef NO_3D
   use m3d, only: mem3d
#endif
   use integration
#ifdef GETM_PARALLEL
   use halo_mpi, only: all_2d_exchange, all_3d_exchange
#endif
   IMPLICIT NONE
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
! ! LOCAL VARIABLES
   character(len=8)          :: datestr
   character(len=10)         :: timestr
   real                      :: t1=-1,t2=-1,secs
   integer                   :: ierr
!EOP
!-----------------------------------------------------------------------
!BOC
   call cmdline
   call print_version()
   call compilation_options()

#ifdef FORTRAN95
   call CPU_Time(t1)
#endif
   call Date_And_Time(datestr,timestr)

   call init_model(datestr,timestr)
   if ( .not. dryrun ) then
      call time_loop(runtype)
   end if
   call clean_up(dryrun,runtype,MaxN)

#ifdef FORTRAN95
   call CPU_Time(t2)
#endif
   call Date_And_Time(datestr,timestr)
   secs = t2-t1
   STDERR LINE
   if( dryrun ) then
      LEVEL1 'getm just did a dry run'
      LEVEL1 'Number of calc-points: ',Calc_Points
      LEVEL1 'Space requirements (global 2D and 3D arrays):'
      LEVEL2 '2D: ',mem2d/1024,' kbytes'
#ifndef NO_3D
      if(runtype .ge. 2) then
         LEVEL2 '3D: ',mem3d/1024,' kbytes'
      end if
#endif
   else
      LEVEL1 'getm: Completed on ',datestr,' ',timestr
      LEVEL1 'Memory used (global 2D and 3D arrays):'
      LEVEL2 '2D: ',mem2d/1024,' kbytes'
#ifndef NO_3D
      if(runtype .ge. 2) then
         LEVEL2 '3D: ',mem3d/1024,' kbytes'
      end if
#endif
      LEVEL1 'Total CPU-time was:    ',secs,' seconds'
      LEVEL1 'Number of time steps:  ',MaxN-MinN+1
      LEVEL1 'Number of calc-points: ',Calc_Points
      if(MaxN-MinN+1 .gt. _ZERO_) then
         LEVEL1 'CPU-time/calc-point:   ',secs/(MaxN-MinN+1)/Calc_Points,' seconds'
         LEVEL1 'Sim-time/CPU-time:     ',simtime/secs
      end if
#ifndef NO_TIMERS
      STDERR LINE
      call write_getm_timers
#endif
   endif
   STDERR LINE
#ifdef GETM_PARALLEL
   LEVEL1 "Communication with other sub-domains:"
   LEVEL2 "2D data exchange: ",all_2d_exchange/(1024*1024)," MB"
   LEVEL2 "3D data exchange: ",all_3d_exchange/(1024*1024)," MB"
   STDERR LINE
#endif
   LEVEL1 'Copyright (C) Karsten Bolding and Hans Burchard.'
   LEVEL1 'under the General Public License (GPL) - http://www.gnu.org '
   STDERR LINE

   call compilation_options

   end program getm

!EOC

!-----------------------------------------------------------------------
   subroutine cmdline
   use initialise, only: dryrun
   IMPLICIT NONE
   character(len=64)    :: arg
   integer              :: i

   if (command_argument_count() .eq. 0) return

   do i = 1, command_argument_count()
      call get_command_argument(i, arg)

      select case (arg)
      case ('-v', '--version')
         LEVEL0 'GETM www.getm.eu'
         call print_version()
         stop
      case ('-c', '--compile')
         LEVEL0 'GETM www.getm.eu'
         call print_version()
         call compilation_options()
         LEVEL0
         stop
      case ('-h', '--help')
         call print_help()
         stop
!KB      case ('--dryrun')
!KB         dryrun=.true.
      case default
         LEVEL0
         LEVEL0 'Unrecognized command-line option: ', arg
         LEVEL0
         call print_help()
         stop
      end select
   end do
   return
   end

!-----------------------------------------------------------------------
   subroutine print_help()
     character(len=255) :: cmd
     call get_command_argument(0, cmd)

     print '(a)', ''
     print '(a,a,a)', 'usage: ',trim(cmd),' [OPTIONS]'
     print '(a)', ''
     print '(a)', 'Without any options, getm will continue execution.'
     print '(a)', ''
     print '(a)', 'cmdline options:'
     print '(a)', ''
     print '(a)', '  -v, --version     print version information and exit'
     print '(a)', '  -c, --compile     print compilation options'
     print '(a)', '  -h, --help        print usage information and exit'
     print '(a)', ''
     print '(a)', 'visit getm.eu for further info'
     print '(a)', 'consider subscribing to getm-users@googlegroups.com'
     print '(a)', ''
  end subroutine print_help

!-----------------------------------------------------------------------
   subroutine compilation_options
   IMPLICIT NONE
!
#ifdef GETM_PARALLEL
   LEVEL1 'Compiled for parallel execution'
#else
   LEVEL1 'Compiled for serial execution'
#endif

#ifdef GETM_OMP
   LEVEL1 '   with OpenMP thread capability'
#else
   LEVEL1 '   without OpenMP thread capability'
#endif

!
#ifdef SLICE_MODEL
   LEVEL1 'SLICE_MODEL'
#endif
#ifdef NO_3D
   LEVEL1 'NO_3D'
#endif
#ifdef NO_BAROCLINIC
   LEVEL1 'NO_BAROCLINIC'
#endif
!
#ifdef FORTRAN90
   LEVEL1 'Fortran 90 compilation'
#endif
!
#ifdef FORTRAN95
   LEVEL1 'Fortran 95 compilation'
#endif
!
#ifdef PRODUCTION
   LEVEL1 'Production compilation'
#endif
!
#ifdef PROFILING
   LEVEL1 'Profiling is enabled'
#endif
!
#ifdef DEBUG
   LEVEL1 'Debugging enabled'
#endif
!
#ifdef STATIC
   LEVEL1 'Using STATIC memory allocation'
#else
   LEVEL1 'Using DYNAMIC memory allocation'
#endif
!
#ifdef SINGLE
   LEVEL1 'Using single precision'
#else
   LEVEL1 'Using double precision'
#endif
!
! Various tests
#ifdef CARTESIAN
   LEVEL1 'CARTESIAN'
#endif
#ifdef SPHERICAL
   LEVEL1 'SPHERICAL'
#endif
#ifdef CURVILINEAR
   LEVEL1 'CURVILINEAR'
#endif
#ifdef TURB_ADV
   LEVEL1 'TURB_ADV'
#endif
#ifdef NO_BOTTFRIC
   LEVEL1 'NO_BOTTFRIC'
#endif
#ifdef NO_ADVECT
   LEVEL1 'NO_ADVECT'
#endif
#ifdef NO_SLR
   LEVEL1 'NO_SLR'
#endif
#ifdef CONSTANT_VISCOSITY
   LEVEL1 'CONSTANT_VISCOSITY'
#endif
#ifdef PARABOLIC_VISCOSITY
   LEVEL1 'PARABOLIC_VISCOSITY'
#endif
#ifdef MIN_VEL_DEPTH
   LEVEL1 'MIN_VEL_DEPTH'
#endif
#ifdef NEW_SS
   LEVEL1 'NEW_SS'
#endif
#ifdef SMOOTH_BVF_HORI
   LEVEL1 'SMOOTH_BVF_HORI'
#endif
#ifdef _SMOOTH_BVF_VERT_
   LEVEL1 '_SMOOTH_BVF_VERT_'
#endif
#ifdef NONNEGSALT
   LEVEL1 'NONNEGSALT'
#endif
#ifdef USE_BREAKS
   LEVEL1 'USE_BREAKS'
#endif
#ifdef PRESS_GRAD_Z
   LEVEL1 'PRESS_GRAD_Z'
#endif
#ifdef ITERATE_VERT_ADV
   LEVEL1 'ITERATE_VERT_ADV'
#endif
#ifdef SUBSTR_INI_PRESS
   LEVEL1 'SUBSTR_INI_PRESS'
#endif
#ifdef SONG_WRIGHT
   LEVEL1 'SONG_WRIGHT'
#endif
#ifdef NO_TIMERS
   LEVEL1 'NO_TIMERS'
#endif
#ifdef OLD_WRONG_FLUXES
   LEVEL1 'OLD_WRONG_FLUXES'
#endif
#ifdef _WRITE_HALOS_
   LEVEL1 '_WRITE_HALOS_'
#endif
#ifdef _WRITE_HOT_HALOS_
   LEVEL1 '_WRITE_HOT_HALOS_'
#endif
#ifdef _READ_HOT_HALOS_
   LEVEL1 '_READ_HOT_HALOS_'
#endif
#ifdef GETM_BIO
   LEVEL1 'GETM_BIO'
#endif
#ifdef _FABM_
   LEVEL1 '_FABM_'
#endif
#ifdef _POINTER_REMAP_
   LEVEL1 '_POINTER_REMAP_'
#endif
#ifdef _NCDF_SAVE_DOUBLE_
   LEVEL1 '_NCDF_SAVE_DOUBLE_'
#endif

   STDERR LINE

   return
   end

!-----------------------------------------------------------------------
! Copyright (C) 2001 - Hans Burchard and Karsten Bolding               !
!-----------------------------------------------------------------------

