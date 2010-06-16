!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade 3.3 (r3163) - 09/25/2009 09:03
!
!  Differentiation of delq3dm_solid in forward (tangent) mode:
!   variations  of output variables: dfacei dfacej dfacek
!   with respect to input variables: s0 xyz0 dfacei dfacej dfacek
!                xyz
SUBROUTINE DELQ3DM_SOLID_D(il, jl, kl, i1, i2, j1, j2, k1, k2, xyz0, &
&  xyz0d, s0, s0d, dfacei, dfaceid, dfacej, dfacejd, dfacek, dfacekd, xyz&
&  , xyzd)
  USE PRECISION
  IMPLICIT NONE
!     ******************************************************************
!     *   DELQ3DM performs stage 1 of the WARPQ3DM 3-space surface     *
!     *   grid perturbation in a form which is reusable by WARP-BLK    *
!     *   It returns face perturbations rather than perturbed face     *
!     *   coordinates.  The three cases of a block face are handled    *
!     *   here by three similar code sections.  Special handling of    *
!     *   fixed corners is avoided to keep the bulk down.              *
!     *                                                                *
!     *   11/29/95  D.Saunders  Adaptation of DELQ3D for specialized   *
!     *                         WARP-BLK and WARPQ3DM used by          *
!     *                         FLO107-MB.                             *
!     *   04/04/96      "       DELQ3DM does only stage 1 now.         *
!     *   12/11/08  C.A.Mader   Converted to *.f90                     *
!     *                                                                *
!     *   David Saunders/James Reuther, NASA Ames Research Center, CA. *
!     ******************************************************************
!IMPLICIT REAL*8 (A-H,O-Z) ! Take out when all compilers have a switch
!     Arguments.
! I Grid array dimensions.
  INTEGER(kind=inttype) :: il, jl, kl
! I Define active face,
  INTEGER(kind=inttype) :: i1, i2, j1, j2, k1, k2
!   one pair being equal.
! I Base face coordinates in
  REAL(kind=realtype) :: xyz0(3, 0:il+1, 0:jl+1, 0:kl+1)
  REAL(kind=realtype) :: xyz0d(3, 0:il+1, 0:jl+1, 0:kl+1)
!   appropriate places
! I Base normalized arc-lengths
  REAL(kind=realtype) :: s0(3, 0:il+1, 0:jl+1, 0:kl+1)
  REAL(kind=realtype) :: s0d(3, 0:il+1, 0:jl+1, 0:kl+1)
! O Reqd. face perturbations:
  REAL(kind=realtype) :: dfacei(3, jl, kl)
  REAL(kind=realtype) :: dfaceid(3, jl, kl)
!   DFACEI(1:3,1:JL,1:KL) =
  REAL(kind=realtype) :: dfacej(3, il, kl)
  REAL(kind=realtype) :: dfacejd(3, il, kl)
!   dX, dY, dZ for an I face, etc.
  REAL(kind=realtype) :: dfacek(3, il, jl)
  REAL(kind=realtype) :: dfacekd(3, il, jl)
! I Grid coordinates: new edges
  REAL(kind=realtype) :: xyz(3, 0:il+1, 0:jl+1, 0:kl+1)
  REAL(kind=realtype) :: xyzd(3, 0:il+1, 0:jl+1, 0:kl+1)
!   of a face input; unchanged
!   on output
!     Local constants.
  REAL(kind=realtype) :: eps, one
  PARAMETER (eps=1.e-14, one=1.e+0)
! EPS safeguards a divide by zero -
! presumably only if result is zero.
!     Local variables.
  INTEGER(kind=inttype) :: i, j, k
  REAL(kind=realtype) :: deli, delj, delk, wti1, wti2, wtj1, wtj2, wtk1&
&  , wtk2
  REAL(kind=realtype) :: delid, deljd, delkd, wti1d, wti2d, wtj1d, wtj2d&
&  , wtk1d, wtk2d
  REAL(kind=realtype) :: abs30
  REAL(kind=realtype) :: abs18d
  REAL(kind=realtype) :: abs26d
  REAL(kind=realtype) :: abs34d
  REAL(kind=realtype) :: x6d
  REAL(kind=realtype) :: abs29d
  REAL(kind=realtype) :: abs1d
  REAL(kind=realtype) :: x9d
  REAL(kind=realtype) :: max2d
  REAL(kind=realtype) :: abs11d
  REAL(kind=realtype) :: abs4d
  REAL(kind=realtype) :: max5d
  REAL(kind=realtype) :: x9
  REAL(kind=realtype) :: abs29
  INTRINSIC MAX
  REAL(kind=realtype) :: x8
  REAL(kind=realtype) :: abs28
  REAL(kind=realtype) :: x7
  REAL(kind=realtype) :: abs27
  REAL(kind=realtype) :: abs14d
  REAL(kind=realtype) :: abs7d
  REAL(kind=realtype) :: x6
  REAL(kind=realtype) :: abs26
  REAL(kind=realtype) :: abs22d
  REAL(kind=realtype) :: x5
  REAL(kind=realtype) :: abs25
  REAL(kind=realtype) :: abs30d
  REAL(kind=realtype) :: x4
  REAL(kind=realtype) :: abs24
  REAL(kind=realtype) :: max8d
  REAL(kind=realtype) :: x3
  REAL(kind=realtype) :: abs23
  INTRINSIC ABS
  REAL(kind=realtype) :: x2
  REAL(kind=realtype) :: abs22
  REAL(kind=realtype) :: x2d
  REAL(kind=realtype) :: x1
  REAL(kind=realtype) :: abs21
  REAL(kind=realtype) :: abs20
  REAL(kind=realtype) :: abs17d
  REAL(kind=realtype) :: abs25d
  REAL(kind=realtype) :: abs33d
  REAL(kind=realtype) :: x5d
  REAL(kind=realtype) :: abs28d
  REAL(kind=realtype) :: abs36d
  REAL(kind=realtype) :: x8d
  REAL(kind=realtype) :: max1d
  REAL(kind=realtype) :: abs10d
  REAL(kind=realtype) :: abs3d
  REAL(kind=realtype) :: max4d
  REAL(kind=realtype) :: abs19
  REAL(kind=realtype) :: abs18
  REAL(kind=realtype) :: abs17
  REAL(kind=realtype) :: abs13d
  REAL(kind=realtype) :: abs6d
  REAL(kind=realtype) :: abs16
  REAL(kind=realtype) :: abs21d
  REAL(kind=realtype) :: abs15
  REAL(kind=realtype) :: abs14
  REAL(kind=realtype) :: max7d
  REAL(kind=realtype) :: abs13
  REAL(kind=realtype) :: abs12
  REAL(kind=realtype) :: x1d
  REAL(kind=realtype) :: abs11
  REAL(kind=realtype) :: abs10
  REAL(kind=realtype) :: abs16d
  REAL(kind=realtype) :: abs9d
  REAL(kind=realtype) :: abs24d
  REAL(kind=realtype) :: abs32d
  REAL(kind=realtype) :: x4d
  REAL(kind=realtype) :: abs19d
  REAL(kind=realtype) :: abs27d
  REAL(kind=realtype) :: abs35d
  REAL(kind=realtype) :: abs9
  REAL(kind=realtype) :: abs8
  REAL(kind=realtype) :: abs7
  REAL(kind=realtype) :: x7d
  REAL(kind=realtype) :: abs6
  REAL(kind=realtype) :: abs5
  REAL(kind=realtype) :: abs4
  REAL(kind=realtype) :: abs3
  REAL(kind=realtype) :: abs2
  REAL(kind=realtype) :: abs2d
  REAL(kind=realtype) :: abs1
  REAL(kind=realtype) :: max3d
  REAL(kind=realtype) :: max9
  REAL(kind=realtype) :: abs12d
  REAL(kind=realtype) :: abs5d
  REAL(kind=realtype) :: max8
  REAL(kind=realtype) :: abs20d
  REAL(kind=realtype) :: max7
  REAL(kind=realtype) :: max6
  REAL(kind=realtype) :: max6d
  REAL(kind=realtype) :: max5
  REAL(kind=realtype) :: max4
  REAL(kind=realtype) :: max3
  REAL(kind=realtype) :: max2
  REAL(kind=realtype) :: abs15d
  REAL(kind=realtype) :: abs8d
  REAL(kind=realtype) :: max1
  REAL(kind=realtype) :: abs36
  REAL(kind=realtype) :: abs23d
  REAL(kind=realtype) :: abs35
  REAL(kind=realtype) :: abs31d
  REAL(kind=realtype) :: abs34
  REAL(kind=realtype) :: max9d
  REAL(kind=realtype) :: abs33
  REAL(kind=realtype) :: abs32
  REAL(kind=realtype) :: x3d
  REAL(kind=realtype) :: abs31
!     Execution.
!     ----------
  IF (i1 .EQ. i2) THEN
!        I plane case:
!        -------------
    i = i1
!        Set up the corner perturbations:
    DO k=1,kl,kl-1
      DO j=1,jl,jl-1
        dfaceid(1, j, k) = xyzd(1, i, j, k) - xyz0d(1, i, j, k)
        dfacei(1, j, k) = xyz(1, i, j, k) - xyz0(1, i, j, k)
        dfaceid(2, j, k) = xyzd(2, i, j, k) - xyz0d(2, i, j, k)
        dfacei(2, j, k) = xyz(2, i, j, k) - xyz0(2, i, j, k)
        dfaceid(3, j, k) = xyzd(3, i, j, k) - xyz0d(3, i, j, k)
        dfacei(3, j, k) = xyz(3, i, j, k) - xyz0(3, i, j, k)
      END DO
    END DO
!        Set up intermediate edge perturbations corresponding to the
!        final corners but otherwise derived from the original edges.
    DO j=1,jl,jl-1
      DO k=2,kl-1
        wtk2d = s0d(3, i, j, k)
        wtk2 = s0(3, i, j, k)
        wtk1d = -wtk2d
        wtk1 = one - wtk2
        dfaceid(1, j, k) = wtk1d*dfacei(1, j, 1) + wtk1*dfaceid(1, j, 1)&
&          + wtk2d*dfacei(1, j, kl) + wtk2*dfaceid(1, j, kl)
        dfacei(1, j, k) = wtk1*dfacei(1, j, 1) + wtk2*dfacei(1, j, kl)
        dfaceid(2, j, k) = wtk1d*dfacei(2, j, 1) + wtk1*dfaceid(2, j, 1)&
&          + wtk2d*dfacei(2, j, kl) + wtk2*dfaceid(2, j, kl)
        dfacei(2, j, k) = wtk1*dfacei(2, j, 1) + wtk2*dfacei(2, j, kl)
        dfaceid(3, j, k) = wtk1d*dfacei(3, j, 1) + wtk1*dfaceid(3, j, 1)&
&          + wtk2d*dfacei(3, j, kl) + wtk2*dfaceid(3, j, kl)
        dfacei(3, j, k) = wtk1*dfacei(3, j, 1) + wtk2*dfacei(3, j, kl)
      END DO
    END DO
    DO k=1,kl,kl-1
      DO j=2,jl-1
        wtj2d = s0d(2, i, j, k)
        wtj2 = s0(2, i, j, k)
        wtj1d = -wtj2d
        wtj1 = one - wtj2
        dfaceid(1, j, k) = wtj1d*dfacei(1, 1, k) + wtj1*dfaceid(1, 1, k)&
&          + wtj2d*dfacei(1, jl, k) + wtj2*dfaceid(1, jl, k)
        dfacei(1, j, k) = wtj1*dfacei(1, 1, k) + wtj2*dfacei(1, jl, k)
        dfaceid(2, j, k) = wtj1d*dfacei(2, 1, k) + wtj1*dfaceid(2, 1, k)&
&          + wtj2d*dfacei(2, jl, k) + wtj2*dfaceid(2, jl, k)
        dfacei(2, j, k) = wtj1*dfacei(2, 1, k) + wtj2*dfacei(2, jl, k)
        dfaceid(3, j, k) = wtj1d*dfacei(3, 1, k) + wtj1*dfaceid(3, 1, k)&
&          + wtj2d*dfacei(3, jl, k) + wtj2*dfaceid(3, jl, k)
        dfacei(3, j, k) = wtj1*dfacei(3, 1, k) + wtj2*dfacei(3, jl, k)
      END DO
    END DO
!        Interpolate the intermediate perturbations of interior points.
!        The contributions from each pair of edges are not independent.
    DO k=2,kl-1
      DO j=2,jl-1
        wtj2d = s0d(2, i, j, k)
        wtj2 = s0(2, i, j, k)
        wtj1d = -wtj2d
        wtj1 = one - wtj2
        wtk2d = s0d(3, i, j, k)
        wtk2 = s0(3, i, j, k)
        wtk1d = -wtk2d
        wtk1 = one - wtk2
        deljd = wtj1d*dfacei(1, 1, k) + wtj1*dfaceid(1, 1, k) + wtj2d*&
&          dfacei(1, jl, k) + wtj2*dfaceid(1, jl, k)
        delj = wtj1*dfacei(1, 1, k) + wtj2*dfacei(1, jl, k)
        delkd = wtk1d*dfacei(1, j, 1) + wtk1*dfaceid(1, j, 1) + wtk2d*&
&          dfacei(1, j, kl) + wtk2*dfaceid(1, j, kl)
        delk = wtk1*dfacei(1, j, 1) + wtk2*dfacei(1, j, kl)
        IF (delj .GE. 0.) THEN
          abs1d = deljd
          abs1 = delj
        ELSE
          abs1d = -deljd
          abs1 = -delj
        END IF
        IF (delk .GE. 0.) THEN
          abs10d = delkd
          abs10 = delk
        ELSE
          abs10d = -delkd
          abs10 = -delk
        END IF
        IF (delj .GE. 0.) THEN
          abs19d = deljd
          abs19 = delj
        ELSE
          abs19d = -deljd
          abs19 = -delj
        END IF
        IF (delk .GE. 0.) THEN
          abs28d = delkd
          abs28 = delk
        ELSE
          abs28d = -delkd
          abs28 = -delk
        END IF
        x1d = abs19d + abs28d
        x1 = abs19 + abs28
        IF (x1 .LT. eps) THEN
          max1 = eps
          max1d = 0.0
        ELSE
          max1d = x1d
          max1 = x1
        END IF
        dfaceid(1, j, k) = ((abs1d*delj+abs1*deljd+abs10d*delk+abs10*&
&          delkd)*max1-(abs1*delj+abs10*delk)*max1d)/max1**2
        dfacei(1, j, k) = (abs1*delj+abs10*delk)/max1
        deljd = wtj1d*dfacei(2, 1, k) + wtj1*dfaceid(2, 1, k) + wtj2d*&
&          dfacei(2, jl, k) + wtj2*dfaceid(2, jl, k)
        delj = wtj1*dfacei(2, 1, k) + wtj2*dfacei(2, jl, k)
        delkd = wtk1d*dfacei(2, j, 1) + wtk1*dfaceid(2, j, 1) + wtk2d*&
&          dfacei(2, j, kl) + wtk2*dfaceid(2, j, kl)
        delk = wtk1*dfacei(2, j, 1) + wtk2*dfacei(2, j, kl)
        IF (delj .GE. 0.) THEN
          abs2d = deljd
          abs2 = delj
        ELSE
          abs2d = -deljd
          abs2 = -delj
        END IF
        IF (delk .GE. 0.) THEN
          abs11d = delkd
          abs11 = delk
        ELSE
          abs11d = -delkd
          abs11 = -delk
        END IF
        IF (delj .GE. 0.) THEN
          abs20d = deljd
          abs20 = delj
        ELSE
          abs20d = -deljd
          abs20 = -delj
        END IF
        IF (delk .GE. 0.) THEN
          abs29d = delkd
          abs29 = delk
        ELSE
          abs29d = -delkd
          abs29 = -delk
        END IF
        x2d = abs20d + abs29d
        x2 = abs20 + abs29
        IF (x2 .LT. eps) THEN
          max2 = eps
          max2d = 0.0
        ELSE
          max2d = x2d
          max2 = x2
        END IF
        dfaceid(2, j, k) = ((abs2d*delj+abs2*deljd+abs11d*delk+abs11*&
&          delkd)*max2-(abs2*delj+abs11*delk)*max2d)/max2**2
        dfacei(2, j, k) = (abs2*delj+abs11*delk)/max2
        deljd = wtj1d*dfacei(3, 1, k) + wtj1*dfaceid(3, 1, k) + wtj2d*&
&          dfacei(3, jl, k) + wtj2*dfaceid(3, jl, k)
        delj = wtj1*dfacei(3, 1, k) + wtj2*dfacei(3, jl, k)
        delkd = wtk1d*dfacei(3, j, 1) + wtk1*dfaceid(3, j, 1) + wtk2d*&
&          dfacei(3, j, kl) + wtk2*dfaceid(3, j, kl)
        delk = wtk1*dfacei(3, j, 1) + wtk2*dfacei(3, j, kl)
        IF (delj .GE. 0.) THEN
          abs3d = deljd
          abs3 = delj
        ELSE
          abs3d = -deljd
          abs3 = -delj
        END IF
        IF (delk .GE. 0.) THEN
          abs12d = delkd
          abs12 = delk
        ELSE
          abs12d = -delkd
          abs12 = -delk
        END IF
        IF (delj .GE. 0.) THEN
          abs21d = deljd
          abs21 = delj
        ELSE
          abs21d = -deljd
          abs21 = -delj
        END IF
        IF (delk .GE. 0.) THEN
          abs30d = delkd
          abs30 = delk
        ELSE
          abs30d = -delkd
          abs30 = -delk
        END IF
        x3d = abs21d + abs30d
        x3 = abs21 + abs30
        IF (x3 .LT. eps) THEN
          max3 = eps
          max3d = 0.0
        ELSE
          max3d = x3d
          max3 = x3
        END IF
        dfaceid(3, j, k) = ((abs3d*delj+abs3*deljd+abs12d*delk+abs12*&
&          delkd)*max3-(abs3*delj+abs12*delk)*max3d)/max3**2
        dfacei(3, j, k) = (abs3*delj+abs12*delk)/max3
      END DO
    END DO
  ELSE IF (j1 .EQ. j2) THEN
!        J plane case:
!        -------------
    j = j1
!        Corner perturbations:
    DO k=1,kl,kl-1
      DO i=1,il,il-1
        dfacejd(1, i, k) = xyzd(1, i, j, k) - xyz0d(1, i, j, k)
        dfacej(1, i, k) = xyz(1, i, j, k) - xyz0(1, i, j, k)
        dfacejd(2, i, k) = xyzd(2, i, j, k) - xyz0d(2, i, j, k)
        dfacej(2, i, k) = xyz(2, i, j, k) - xyz0(2, i, j, k)
        dfacejd(3, i, k) = xyzd(3, i, j, k) - xyz0d(3, i, j, k)
        dfacej(3, i, k) = xyz(3, i, j, k) - xyz0(3, i, j, k)
      END DO
    END DO
!        Intermediate edge perturbations:
    DO i=1,il,il-1
      DO k=2,kl-1
        wtk2d = s0d(3, i, j, k)
        wtk2 = s0(3, i, j, k)
        wtk1d = -wtk2d
        wtk1 = one - wtk2
        dfacejd(1, i, k) = wtk1d*dfacej(1, i, 1) + wtk1*dfacejd(1, i, 1)&
&          + wtk2d*dfacej(1, i, kl) + wtk2*dfacejd(1, i, kl)
        dfacej(1, i, k) = wtk1*dfacej(1, i, 1) + wtk2*dfacej(1, i, kl)
        dfacejd(2, i, k) = wtk1d*dfacej(2, i, 1) + wtk1*dfacejd(2, i, 1)&
&          + wtk2d*dfacej(2, i, kl) + wtk2*dfacejd(2, i, kl)
        dfacej(2, i, k) = wtk1*dfacej(2, i, 1) + wtk2*dfacej(2, i, kl)
        dfacejd(3, i, k) = wtk1d*dfacej(3, i, 1) + wtk1*dfacejd(3, i, 1)&
&          + wtk2d*dfacej(3, i, kl) + wtk2*dfacejd(3, i, kl)
        dfacej(3, i, k) = wtk1*dfacej(3, i, 1) + wtk2*dfacej(3, i, kl)
      END DO
    END DO
    DO k=1,kl,kl-1
      DO i=2,il-1
        wti2d = s0d(1, i, j, k)
        wti2 = s0(1, i, j, k)
        wti1d = -wti2d
        wti1 = one - wti2
        dfacejd(1, i, k) = wti1d*dfacej(1, 1, k) + wti1*dfacejd(1, 1, k)&
&          + wti2d*dfacej(1, il, k) + wti2*dfacejd(1, il, k)
        dfacej(1, i, k) = wti1*dfacej(1, 1, k) + wti2*dfacej(1, il, k)
        dfacejd(2, i, k) = wti1d*dfacej(2, 1, k) + wti1*dfacejd(2, 1, k)&
&          + wti2d*dfacej(2, il, k) + wti2*dfacejd(2, il, k)
        dfacej(2, i, k) = wti1*dfacej(2, 1, k) + wti2*dfacej(2, il, k)
        dfacejd(3, i, k) = wti1d*dfacej(3, 1, k) + wti1*dfacejd(3, 1, k)&
&          + wti2d*dfacej(3, il, k) + wti2*dfacejd(3, il, k)
        dfacej(3, i, k) = wti1*dfacej(3, 1, k) + wti2*dfacej(3, il, k)
      END DO
    END DO
!        Intermediate perturbations of interior points:
    DO k=2,kl-1
      DO i=2,il-1
        wti2d = s0d(1, i, j, k)
        wti2 = s0(1, i, j, k)
        wti1d = -wti2d
        wti1 = one - wti2
        wtk2d = s0d(3, i, j, k)
        wtk2 = s0(3, i, j, k)
        wtk1d = -wtk2d
        wtk1 = one - wtk2
        delid = wti1d*dfacej(1, 1, k) + wti1*dfacejd(1, 1, k) + wti2d*&
&          dfacej(1, il, k) + wti2*dfacejd(1, il, k)
        deli = wti1*dfacej(1, 1, k) + wti2*dfacej(1, il, k)
        delkd = wtk1d*dfacej(1, i, 1) + wtk1*dfacejd(1, i, 1) + wtk2d*&
&          dfacej(1, i, kl) + wtk2*dfacejd(1, i, kl)
        delk = wtk1*dfacej(1, i, 1) + wtk2*dfacej(1, i, kl)
        IF (deli .GE. 0.) THEN
          abs4d = delid
          abs4 = deli
        ELSE
          abs4d = -delid
          abs4 = -deli
        END IF
        IF (delk .GE. 0.) THEN
          abs13d = delkd
          abs13 = delk
        ELSE
          abs13d = -delkd
          abs13 = -delk
        END IF
        IF (deli .GE. 0.) THEN
          abs22d = delid
          abs22 = deli
        ELSE
          abs22d = -delid
          abs22 = -deli
        END IF
        IF (delk .GE. 0.) THEN
          abs31d = delkd
          abs31 = delk
        ELSE
          abs31d = -delkd
          abs31 = -delk
        END IF
        x4d = abs22d + abs31d
        x4 = abs22 + abs31
        IF (x4 .LT. eps) THEN
          max4 = eps
          max4d = 0.0
        ELSE
          max4d = x4d
          max4 = x4
        END IF
        dfacejd(1, i, k) = ((abs4d*deli+abs4*delid+abs13d*delk+abs13*&
&          delkd)*max4-(abs4*deli+abs13*delk)*max4d)/max4**2
        dfacej(1, i, k) = (abs4*deli+abs13*delk)/max4
        delid = wti1d*dfacej(2, 1, k) + wti1*dfacejd(2, 1, k) + wti2d*&
&          dfacej(2, il, k) + wti2*dfacejd(2, il, k)
        deli = wti1*dfacej(2, 1, k) + wti2*dfacej(2, il, k)
        delkd = wtk1d*dfacej(2, i, 1) + wtk1*dfacejd(2, i, 1) + wtk2d*&
&          dfacej(2, i, kl) + wtk2*dfacejd(2, i, kl)
        delk = wtk1*dfacej(2, i, 1) + wtk2*dfacej(2, i, kl)
        IF (deli .GE. 0.) THEN
          abs5d = delid
          abs5 = deli
        ELSE
          abs5d = -delid
          abs5 = -deli
        END IF
        IF (delk .GE. 0.) THEN
          abs14d = delkd
          abs14 = delk
        ELSE
          abs14d = -delkd
          abs14 = -delk
        END IF
        IF (deli .GE. 0.) THEN
          abs23d = delid
          abs23 = deli
        ELSE
          abs23d = -delid
          abs23 = -deli
        END IF
        IF (delk .GE. 0.) THEN
          abs32d = delkd
          abs32 = delk
        ELSE
          abs32d = -delkd
          abs32 = -delk
        END IF
        x5d = abs23d + abs32d
        x5 = abs23 + abs32
        IF (x5 .LT. eps) THEN
          max5 = eps
          max5d = 0.0
        ELSE
          max5d = x5d
          max5 = x5
        END IF
        dfacejd(2, i, k) = ((abs5d*deli+abs5*delid+abs14d*delk+abs14*&
&          delkd)*max5-(abs5*deli+abs14*delk)*max5d)/max5**2
        dfacej(2, i, k) = (abs5*deli+abs14*delk)/max5
        delid = wti1d*dfacej(3, 1, k) + wti1*dfacejd(3, 1, k) + wti2d*&
&          dfacej(3, il, k) + wti2*dfacejd(3, il, k)
        deli = wti1*dfacej(3, 1, k) + wti2*dfacej(3, il, k)
        delkd = wtk1d*dfacej(3, i, 1) + wtk1*dfacejd(3, i, 1) + wtk2d*&
&          dfacej(3, i, kl) + wtk2*dfacejd(3, i, kl)
        delk = wtk1*dfacej(3, i, 1) + wtk2*dfacej(3, i, kl)
        IF (deli .GE. 0.) THEN
          abs6d = delid
          abs6 = deli
        ELSE
          abs6d = -delid
          abs6 = -deli
        END IF
        IF (delk .GE. 0.) THEN
          abs15d = delkd
          abs15 = delk
        ELSE
          abs15d = -delkd
          abs15 = -delk
        END IF
        IF (deli .GE. 0.) THEN
          abs24d = delid
          abs24 = deli
        ELSE
          abs24d = -delid
          abs24 = -deli
        END IF
        IF (delk .GE. 0.) THEN
          abs33d = delkd
          abs33 = delk
        ELSE
          abs33d = -delkd
          abs33 = -delk
        END IF
        x6d = abs24d + abs33d
        x6 = abs24 + abs33
        IF (x6 .LT. eps) THEN
          max6 = eps
          max6d = 0.0
        ELSE
          max6d = x6d
          max6 = x6
        END IF
        dfacejd(3, i, k) = ((abs6d*deli+abs6*delid+abs15d*delk+abs15*&
&          delkd)*max6-(abs6*deli+abs15*delk)*max6d)/max6**2
        dfacej(3, i, k) = (abs6*deli+abs15*delk)/max6
      END DO
    END DO
  ELSE IF (k1 .EQ. k2) THEN
!        K plane case:
!        -------------
    k = k1
!        Corner perturbations:
    DO j=1,jl,jl-1
      DO i=1,il,il-1
        dfacekd(1, i, j) = xyzd(1, i, j, k) - xyz0d(1, i, j, k)
        dfacek(1, i, j) = xyz(1, i, j, k) - xyz0(1, i, j, k)
        dfacekd(2, i, j) = xyzd(2, i, j, k) - xyz0d(2, i, j, k)
        dfacek(2, i, j) = xyz(2, i, j, k) - xyz0(2, i, j, k)
        dfacekd(3, i, j) = xyzd(3, i, j, k) - xyz0d(3, i, j, k)
        dfacek(3, i, j) = xyz(3, i, j, k) - xyz0(3, i, j, k)
      END DO
    END DO
!        Intermediate edge perturbations:
    DO i=1,il,il-1
      DO j=2,jl-1
        wtj2d = s0d(2, i, j, k)
        wtj2 = s0(2, i, j, k)
        wtj1d = -wtj2d
        wtj1 = one - wtj2
        dfacekd(1, i, j) = wtj1d*dfacek(1, i, 1) + wtj1*dfacekd(1, i, 1)&
&          + wtj2d*dfacek(1, i, jl) + wtj2*dfacekd(1, i, jl)
        dfacek(1, i, j) = wtj1*dfacek(1, i, 1) + wtj2*dfacek(1, i, jl)
        dfacekd(2, i, j) = wtj1d*dfacek(2, i, 1) + wtj1*dfacekd(2, i, 1)&
&          + wtj2d*dfacek(2, i, jl) + wtj2*dfacekd(2, i, jl)
        dfacek(2, i, j) = wtj1*dfacek(2, i, 1) + wtj2*dfacek(2, i, jl)
        dfacekd(3, i, j) = wtj1d*dfacek(3, i, 1) + wtj1*dfacekd(3, i, 1)&
&          + wtj2d*dfacek(3, i, jl) + wtj2*dfacekd(3, i, jl)
        dfacek(3, i, j) = wtj1*dfacek(3, i, 1) + wtj2*dfacek(3, i, jl)
      END DO
    END DO
    DO j=1,jl,jl-1
      DO i=2,il-1
        wti2d = s0d(1, i, j, k)
        wti2 = s0(1, i, j, k)
        wti1d = -wti2d
        wti1 = one - wti2
        dfacekd(1, i, j) = wti1d*dfacek(1, 1, j) + wti1*dfacekd(1, 1, j)&
&          + wti2d*dfacek(1, il, j) + wti2*dfacekd(1, il, j)
        dfacek(1, i, j) = wti1*dfacek(1, 1, j) + wti2*dfacek(1, il, j)
        dfacekd(2, i, j) = wti1d*dfacek(2, 1, j) + wti1*dfacekd(2, 1, j)&
&          + wti2d*dfacek(2, il, j) + wti2*dfacekd(2, il, j)
        dfacek(2, i, j) = wti1*dfacek(2, 1, j) + wti2*dfacek(2, il, j)
        dfacekd(3, i, j) = wti1d*dfacek(3, 1, j) + wti1*dfacekd(3, 1, j)&
&          + wti2d*dfacek(3, il, j) + wti2*dfacekd(3, il, j)
        dfacek(3, i, j) = wti1*dfacek(3, 1, j) + wti2*dfacek(3, il, j)
      END DO
    END DO
!        Intermediate perturbations of interior points:
    DO j=2,jl-1
      DO i=2,il-1
        wti2d = s0d(1, i, j, k)
        wti2 = s0(1, i, j, k)
        wti1d = -wti2d
        wti1 = one - wti2
        wtj2d = s0d(2, i, j, k)
        wtj2 = s0(2, i, j, k)
        wtj1d = -wtj2d
        wtj1 = one - wtj2
        delid = wti1d*dfacek(1, 1, j) + wti1*dfacekd(1, 1, j) + wti2d*&
&          dfacek(1, il, j) + wti2*dfacekd(1, il, j)
        deli = wti1*dfacek(1, 1, j) + wti2*dfacek(1, il, j)
        deljd = wtj1d*dfacek(1, i, 1) + wtj1*dfacekd(1, i, 1) + wtj2d*&
&          dfacek(1, i, jl) + wtj2*dfacekd(1, i, jl)
        delj = wtj1*dfacek(1, i, 1) + wtj2*dfacek(1, i, jl)
        IF (deli .GE. 0.) THEN
          abs7d = delid
          abs7 = deli
        ELSE
          abs7d = -delid
          abs7 = -deli
        END IF
        IF (delj .GE. 0.) THEN
          abs16d = deljd
          abs16 = delj
        ELSE
          abs16d = -deljd
          abs16 = -delj
        END IF
        IF (deli .GE. 0.) THEN
          abs25d = delid
          abs25 = deli
        ELSE
          abs25d = -delid
          abs25 = -deli
        END IF
        IF (delj .GE. 0.) THEN
          abs34d = deljd
          abs34 = delj
        ELSE
          abs34d = -deljd
          abs34 = -delj
        END IF
        x7d = abs25d + abs34d
        x7 = abs25 + abs34
        IF (x7 .LT. eps) THEN
          max7 = eps
          max7d = 0.0
        ELSE
          max7d = x7d
          max7 = x7
        END IF
        dfacekd(1, i, j) = ((abs7d*deli+abs7*delid+abs16d*delj+abs16*&
&          deljd)*max7-(abs7*deli+abs16*delj)*max7d)/max7**2
        dfacek(1, i, j) = (abs7*deli+abs16*delj)/max7
        delid = wti1d*dfacek(2, 1, j) + wti1*dfacekd(2, 1, j) + wti2d*&
&          dfacek(2, il, j) + wti2*dfacekd(2, il, j)
        deli = wti1*dfacek(2, 1, j) + wti2*dfacek(2, il, j)
        deljd = wtj1d*dfacek(2, i, 1) + wtj1*dfacekd(2, i, 1) + wtj2d*&
&          dfacek(2, i, jl) + wtj2*dfacekd(2, i, jl)
        delj = wtj1*dfacek(2, i, 1) + wtj2*dfacek(2, i, jl)
        IF (deli .GE. 0.) THEN
          abs8d = delid
          abs8 = deli
        ELSE
          abs8d = -delid
          abs8 = -deli
        END IF
        IF (delj .GE. 0.) THEN
          abs17d = deljd
          abs17 = delj
        ELSE
          abs17d = -deljd
          abs17 = -delj
        END IF
        IF (deli .GE. 0.) THEN
          abs26d = delid
          abs26 = deli
        ELSE
          abs26d = -delid
          abs26 = -deli
        END IF
        IF (delj .GE. 0.) THEN
          abs35d = deljd
          abs35 = delj
        ELSE
          abs35d = -deljd
          abs35 = -delj
        END IF
        x8d = abs26d + abs35d
        x8 = abs26 + abs35
        IF (x8 .LT. eps) THEN
          max8 = eps
          max8d = 0.0
        ELSE
          max8d = x8d
          max8 = x8
        END IF
        dfacekd(2, i, j) = ((abs8d*deli+abs8*delid+abs17d*delj+abs17*&
&          deljd)*max8-(abs8*deli+abs17*delj)*max8d)/max8**2
        dfacek(2, i, j) = (abs8*deli+abs17*delj)/max8
        delid = wti1d*dfacek(3, 1, j) + wti1*dfacekd(3, 1, j) + wti2d*&
&          dfacek(3, il, j) + wti2*dfacekd(3, il, j)
        deli = wti1*dfacek(3, 1, j) + wti2*dfacek(3, il, j)
        deljd = wtj1d*dfacek(3, i, 1) + wtj1*dfacekd(3, i, 1) + wtj2d*&
&          dfacek(3, i, jl) + wtj2*dfacekd(3, i, jl)
        delj = wtj1*dfacek(3, i, 1) + wtj2*dfacek(3, i, jl)
        IF (deli .GE. 0.) THEN
          abs9d = delid
          abs9 = deli
        ELSE
          abs9d = -delid
          abs9 = -deli
        END IF
        IF (delj .GE. 0.) THEN
          abs18d = deljd
          abs18 = delj
        ELSE
          abs18d = -deljd
          abs18 = -delj
        END IF
        IF (deli .GE. 0.) THEN
          abs27d = delid
          abs27 = deli
        ELSE
          abs27d = -delid
          abs27 = -deli
        END IF
        IF (delj .GE. 0.) THEN
          abs36d = deljd
          abs36 = delj
        ELSE
          abs36d = -deljd
          abs36 = -delj
        END IF
        x9d = abs27d + abs36d
        x9 = abs27 + abs36
        IF (x9 .LT. eps) THEN
          max9 = eps
          max9d = 0.0
        ELSE
          max9d = x9d
          max9 = x9
        END IF
        dfacekd(3, i, j) = ((abs9d*deli+abs9*delid+abs18d*delj+abs18*&
&          deljd)*max9-(abs9*deli+abs18*delj)*max9d)/max9**2
        dfacek(3, i, j) = (abs9*deli+abs18*delj)/max9
      END DO
    END DO
  END IF
END SUBROUTINE DELQ3DM_SOLID_D
