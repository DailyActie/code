#include "cppdefs.h"
!-----------------------------------------------------------------------
!BOP
!
! !MODULE: exceptions - handling of GETM errors and warnings
!
! !INTERFACE:
   module exceptions
!
! !DESCRIPTION:
! This module contains routines to report \emph{warnings} and \emph{errors}
! to the FORTRAN error channel (i.e.\ normally to the screen). A
! \emph{warning} implies that the code tries to fix the problem (or simply
! does nothing) and continues to run. An \emph{error} means that the problem
! is fatal and the code exits.
!
! !USES:
   use netcdf
   IMPLICIT NONE
!
   private
!
! !PUBLIC MEMBER FUNCTIONS:
   public          getm_error,getm_warning
   public          netcdf_error,netcdf_warning
!
! !REVISION HISTORY:
!  Original author(s): Lars Umlauf
!
!EOP
!-----------------------------------------------------------------------

   contains

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: getm_error()
!
! !INTERFACE:
   subroutine getm_error(routine,whatsup)
!
! !DESCRIPTION:
!  Reports a fatal \emph{error} concerning a certain {\tt routine} in
!  GETM and exits.
!  The argument {\tt whatsup} is short (!) error message.
!
! !USES:
#ifdef GETM_PARALLEL
    use mpi
#endif
    IMPLICIT NONE
!
! !INPUT PARAMETERS:
    character(len=*), intent(in)       :: routine
    character(len=*), intent(in)       :: whatsup
!
! !REVISION HISTORY:
!  Original author(s): Lars Umlauf
!
! !LOCAL VARIABLES:
   integer                   :: ierr
!EOP
!-----------------------------------------------------------------------
!BOC
   STDERR " "
   STDERR "FATAL GETM ERROR: Called from "//trim(routine)
   STDERR "FATAL GETM ERROR: "//trim(whatsup)
   STDERR " "

#ifdef GETM_PARALLEL
   call MPI_Abort(MPI_COMM_WORLD,1,ierr)
#else
   stop
#endif

   return
   end subroutine getm_error
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: getm_warning()
!
! !INTERFACE:
   subroutine getm_warning(routine,whatsup)
!
! !DESCRIPTION:
! Reports a \emph{warning} concerning a certain {\tt routine} in GETM.
! The argument {\tt whatsup} is short (!) error message.
!
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   character(len=*), intent(in)        :: routine
   character(len=*), intent(in)        :: whatsup
!
! !REVISION HISTORY:
!  Original author(s): Lars Umlauf
!
!EOP
!-----------------------------------------------------------------------
!BOC
   STDERR " "
   STDERR "GETM WARNING: Called from "//trim(routine)
   STDERR "GETM WARNING: "//trim(whatsup)
   STDERR "GETM WARNING:  This might cause problems later..."
   STDERR " "

   return
   end subroutine getm_warning
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: netcdf_error()
!
! !INTERFACE:
   subroutine netcdf_error(status,routine,whatsup)
!
! !USES:
#ifdef GETM_PARALLEL
    use mpi
#endif
   IMPLICIT NONE
!
! !DESCRIPTION:
!  Reports an \emph{error} concerning a certain netCDF {\tt routine}
!  in GETM and exits. The argument {\tt whatsup} is short (!) error
!  message. An additional message is appended according to the netCDF
!  library's {\tt status} argument.

! !INPUT PARAMETERS:
   integer,          intent(in)        :: status
   character(len=*), intent(in)        :: routine
   character(len=*), intent(in)        :: whatsup
!
! !BUGS:
!  Exit status for parallel runs is not yet clean.
!
! !REVISION HISTORY:
!  Original author(s): Lars Umlauf
!
! !LOCAL VARIABLES:
   integer                   :: ierr
!EOP
!-------------------------------------------------------------------------
!BOC
   STDERR " "
   STDERR "FATAL NETCDF ERROR: Called from "//trim(routine)
   STDERR "FATAL NETCDF ERROR: "//trim(whatsup)
   STDERR "NETCDF MESSAGE    : "//trim(nf90_strerror(status))
   STDERR " "

#ifdef GETM_PARALLEL
   call MPI_Abort(MPI_COMM_WORLD,1,ierr)
#else
   stop
#endif

   return
   end subroutine netcdf_error
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: netcdf_warning
!
! !INTERFACE:
   subroutine netcdf_warning(status,routine,whatsup)
!
! !USES:
   IMPLICIT NONE
!
! !DESCRIPTION:
! Reports a \emph{warning} concerning a certain netCDF {\tt routine} in GETM.
! The argument {\tt whatsup} is short (!) error message. An additional
! message is appended according to the netCDF library's {\tt status} argument.
!
! !INPUT PARAMETERS:
   integer,          intent(in)        :: status
   character(len=*), intent(in)        :: routine
   character(len=*), intent(in)        :: whatsup
!
! !REVISION HISTORY:
!  Original author(s): Lars Umlauf
!
!EOP
!-------------------------------------------------------------------------
!BOC
   STDERR " "
   STDERR "NETCDF WARNING: Called from "//trim(routine)
   STDERR "NETCDF WARNING: "//trim(whatsup)
   STDERR "NETCDF MESSAGE: "//trim(nf90_strerror(status))
   STDERR " "

   return
   end subroutine netcdf_warning
!EOC
!-----------------------------------------------------------------------

   end module exceptions

!-----------------------------------------------------------------------
! Copyright (C) 2005 - Lars Umlauf, Hans Burchard and Karsten Bolding
!-----------------------------------------------------------------------
