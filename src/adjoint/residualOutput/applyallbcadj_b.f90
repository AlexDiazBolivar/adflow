!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of applyallbcadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: winfadj padj pinfcorradj
!                wadj rfaceadj skadj sjadj sadj siadj normadj
!   of linear combination of output variables: winfadj padj pinfcorradj
!                wadj rfaceadj skadj sjadj sadj siadj normadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          applyAllBCAdj.f90                               *
!      * Author:        Edwin van der Weide, Seonghyeon Hahn            *
!      *                C.A.(Sandy) Mader                               *
!      * Starting date: 04-16-2008                                      *
!      * Last modified: 04-17-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE APPLYALLBCADJ_B(winfadj, winfadjb, pinfcorradj, pinfcorradjb&
&  , wadj, wadjb, padj, padjb, sadj, sadjb, siadj, siadjb, sjadj, sjadjb&
&  , skadj, skadjb, voladj, normadj, normadjb, rfaceadj, rfaceadjb, &
&  icell, jcell, kcell, secondhalo, nn, level, sps, sps2)
  USE bctypes
  USE blockpointers
  USE flowvarrefstate
  USE inputdiscretization
  USE inputtimespectral
  IMPLICIT NONE
!!$       ! Domain-interface boundary conditions,
!!$       ! when coupled with other solvers.
!!$       
!!$       call bcDomainInterface(secondHalo, correctForK)
!!$       
!!$       ! Supersonic inflow boundary conditions.
!!$       
!!$       call bcSupersonicInflow(secondHalo, correctForK)
!!$         enddo domains
!!$       enddo spectralLoop
!print *,'bcend',nn,secondhalo
  INTEGER(KIND=INTTYPE) :: icell, jcell, kcell
  INTEGER(KIND=INTTYPE) :: level, nn, sps, sps2
  REAL(KIND=REALTYPE), DIMENSION(nbocos, -2:2, -2:2, 3, &
&  ntimeintervalsspectral), INTENT(IN) :: normadj
  REAL(KIND=REALTYPE) :: normadjb(nbocos, -2:2, -2:2, 3, &
&  ntimeintervalsspectral)
  REAL(KIND=REALTYPE) :: padj(-2:2, -2:2, -2:2, ntimeintervalsspectral)&
&  , padjb(-2:2, -2:2, -2:2, ntimeintervalsspectral)
  REAL(KIND=REALTYPE), INTENT(IN) :: pinfcorradj
  REAL(KIND=REALTYPE) :: pinfcorradjb
  REAL(KIND=REALTYPE), DIMENSION(nbocos, -2:2, -2:2, &
&  ntimeintervalsspectral), INTENT(IN) :: rfaceadj
  REAL(KIND=REALTYPE) :: rfaceadjb(nbocos, -2:2, -2:2, &
&  ntimeintervalsspectral)
  REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, 3, &
&  ntimeintervalsspectral), INTENT(IN) :: sadj
  REAL(KIND=REALTYPE) :: sadjb(-2:2, -2:2, -2:2, 3, &
&  ntimeintervalsspectral)
  LOGICAL, INTENT(IN) :: secondhalo
  REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3, &
&  ntimeintervalsspectral), INTENT(IN) :: siadj
  REAL(KIND=REALTYPE) :: siadjb(-3:2, -3:2, -3:2, 3, &
&  ntimeintervalsspectral), sjadjb(-3:2, -3:2, -3:2, 3, &
&  ntimeintervalsspectral), skadjb(-3:2, -3:2, -3:2, 3, &
&  ntimeintervalsspectral)
  REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3, &
&  ntimeintervalsspectral), INTENT(IN) :: sjadj
  REAL(KIND=REALTYPE), DIMENSION(-3:2, -3:2, -3:2, 3, &
&  ntimeintervalsspectral), INTENT(IN) :: skadj
  REAL(KIND=REALTYPE), DIMENSION(ntimeintervalsspectral), INTENT(IN) :: &
&  voladj
  REAL(KIND=REALTYPE) :: wadj(-2:2, -2:2, -2:2, nw, &
&  ntimeintervalsspectral), wadjb(-2:2, -2:2, -2:2, nw, &
&  ntimeintervalsspectral)
  REAL(KIND=REALTYPE), DIMENSION(nw), INTENT(IN) :: winfadj
  REAL(KIND=REALTYPE) :: winfadjb(nw)
  INTEGER :: branch
  LOGICAL :: correctfork
  INTEGER(KIND=INTTYPE) :: i, ii, j, jj, k, kk, l
  INTEGER(KIND=INTTYPE) :: iend, istart, jend, jstart, kend, kstart
  EXTERNAL TERMINATE
  CALL PUSHBOOLEAN(secondhalo)
  CALL PUSHREAL8ARRAY(wadj, 5**3*nw*ntimeintervalsspectral)
!
!      ******************************************************************
!      *                                                                *
!      * applyAllBCAdj applies the possible boundary conditions for the *
!      * halo cells adjacent to the cell for which the residual needs   *
!      * to be computed.                                                *
!      *                                                                *
!      ******************************************************************
!
!, only : ie, ib, je, jb, ke, kb, nBocos, &
!         BCFaceID, BCType, BCData,p,w
!precond,choimerkle, etc...
!nIntervalTimespectral
!!$       use blockPointers
!!$       use flowVarRefState
!!$       use inputDiscretization
!!$       use inputTimeSpectral
!!$       use iteration
!!$       implicit none
!
!      Subroutine arguments.
!
!       real(kind=realType), dimension(-2:2,-2:2,-2:2,3), &
!                                                   intent(in) :: siAdj, sjAdj, skAdj
!real(kind=realType), dimension(0:0,0:0,0:0), intent(in) :: volAdj
!
!      Local variables.
!
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
!moved outside
!!$       ! Determine whether or not the total energy must be corrected
!!$       ! for the presence of the turbulent kinetic energy.
!!$
!!$       if( kPresent ) then
!!$         if((currentLevel <= groundLevel) .or. turbCoupled) then
!!$           correctForK = .true.
!!$         else
!!$           correctForK = .false.
!!$         endif
!!$       else
!!$         correctForK = .false.
!!$       endif
!!$       ! Loop over the number of spectral solutions.
!!$
!!$       spectralLoop: do sps=1,nTimeIntervalsSpectral
!!$
!!$         ! Loop over the number of blocks.
!!$
!!$         domains: do nn=1,nDom
!!$
!!$           ! Set the pointers for this block.
!!$
!!$           call setPointers(nn, currentLevel, sps)
!!$
!!$           ! Apply all the boundary conditions. The order is important.
! The symmetry boundary conditions.
!print *,'bcSymm',nn,secondhalo
!*************************
  CALL BCSYMMADJ(wadj, padj, normadj, icell, jcell, kcell, secondhalo, &
&           nn, level, sps, sps2)
!print *,'bcSymm2',nn,secondhalo
!**************************
!###       call bcSymmPolar(secondHalo)
!!$       ! call bcEulerWall(secondHalo, correctForK)
!!$
!!$       ! The viscous wall boundary conditions.
!!$
!!$       call bcNSWallAdiabatic( secondHalo, correctForK)
!!$       call bcNSWallIsothermal(secondHalo, correctForK)
!!$
!!$       ! The farfield is a special case, because the treatment
!!$       ! differs when preconditioning is used. Make that distinction
!!$       ! and call the appropriate routine.
!!$       
!*******************************
  SELECT CASE  (precond) 
  CASE (noprecond) 
    CALL PUSHREAL8ARRAY(padj, 5**3*ntimeintervalsspectral)
    CALL PUSHREAL8ARRAY(wadj, 5**3*nw*ntimeintervalsspectral)
    CALL PUSHBOOLEAN(secondhalo)
!print *,'bcFarfield',nn,secondhalo
    CALL BCFARFIELDADJ(secondhalo, winfadj, pinfcorradj, wadj, padj, &
&                 siadj, sjadj, skadj, normadj, rfaceadj, icell, jcell, &
&                 kcell, nn, level, sps, sps2)
    CALL PUSHINTEGER4(3)
  CASE (turkel) 
    CALL PUSHINTEGER4(1)
  CASE (choimerkle) 
    CALL PUSHINTEGER4(0)
  CASE DEFAULT
    CALL PUSHINTEGER4(2)
  END SELECT
  CALL BCEULERWALLADJ_B(secondhalo, wadj, wadjb, padj, padjb, sadj, &
&                  sadjb, siadj, siadjb, sjadj, sjadjb, skadj, skadjb, &
&                  normadj, normadjb, rfaceadj, rfaceadjb, icell, jcell&
&                  , kcell, nn, level, sps, sps2)
  CALL POPINTEGER4(branch)
  IF (.NOT.branch .LT. 2) THEN
    IF (.NOT.branch .LT. 3) THEN
      CALL POPBOOLEAN(secondhalo)
      CALL POPREAL8ARRAY(wadj, 5**3*nw*ntimeintervalsspectral)
      CALL POPREAL8ARRAY(padj, 5**3*ntimeintervalsspectral)
      CALL BCFARFIELDADJ_B(secondhalo, winfadj, winfadjb, pinfcorradj, &
&                     pinfcorradjb, wadj, wadjb, padj, padjb, siadj, &
&                     sjadj, skadj, normadj, normadjb, rfaceadj, icell, &
&                     jcell, kcell, nn, level, sps, sps2)
    END IF
  END IF
  CALL POPREAL8ARRAY(wadj, 5**3*nw*ntimeintervalsspectral)
  CALL POPBOOLEAN(secondhalo)
  CALL BCSYMMADJ_B(wadj, wadjb, padj, padjb, normadj, normadjb, icell, &
&             jcell, kcell, secondhalo, nn, level, sps, sps2)
END SUBROUTINE APPLYALLBCADJ_B
