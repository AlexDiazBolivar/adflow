   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4512) -  3 Aug 2012 15:11
   !
   !  Differentiation of turbadvection in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *dvt qq
   !   with respect to varying inputs: *sfacei *sfacej *sfacek *bmtk1
   !                *w *bmtk2 *vol *bmti1 *bmti2 *si *sj *sk *bmtj1
   !                *bmtj2 *dvt qq
   !   Plus diff mem management of: sfacei:in sfacej:in sfacek:in
   !                bmtk1:in w:in bmtk2:in vol:in bmti1:in bmti2:in
   !                si:in sj:in sk:in bmtj1:in bmtj2:in dvt:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          turbAdvection.f90                               *
   !      * Author:        Georgi Kalitzin, Edwin van der Weide            *
   !      * Starting date: 09-01-2003                                      *
   !      * Last modified: 04-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE TURBADVECTION_D(madv, nadv, offset, qq, qqd)
   USE BLOCKPOINTERS_D
   USE TURBMOD
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * turbAdvection discretizes the advection part of the turbulent  *
   !      * transport equations. As the advection part is the same for all *
   !      * models, this generic routine can be used. Both the             *
   !      * discretization and the central jacobian are computed in this   *
   !      * subroutine. The former can either be 1st or 2nd order          *
   !      * accurate; the latter is always based on the 1st order upwind   *
   !      * discretization. When the discretization must be second order   *
   !      * accurate, the fully upwind (kappa = -1) scheme in combination  *
   !      * with the minmod limiter is used.                               *
   !      *                                                                *
   !      * Only nAdv equations are treated, while the actual system has   *
   !      * size mAdv. The reason is that some equations for some          *
   !      * turbulence equations do not have an advection part, e.g. the   *
   !      * f equation in the v2-f model. The argument offset indicates    *
   !      * the offset in the w vector where this subsystem starts. As a   *
   !      * consequence it is assumed that the indices of the current      *
   !      * subsystem are contiguous, e.g. if a 2*2 system is solved the   *
   !      * Last index in w is offset+1 and offset+2 respectively.         *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Subroutine arguments.
   !
   INTEGER(kind=inttype), INTENT(IN) :: nadv, madv, offset
   REAL(kind=realtype), DIMENSION(2:il, 2:jl, 2:kl, madv, madv), INTENT(&
   &  INOUT) :: qq
   REAL(kind=realtype), DIMENSION(2:il, 2:jl, 2:kl, madv, madv), INTENT(&
   &  INOUT) :: qqd
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, k, ii, jj, kk
   REAL(kind=realtype) :: qs, voli, xa, ya, za
   REAL(kind=realtype) :: qsd, volid, xad, yad, zad
   REAL(kind=realtype) :: uu, dwt, dwtm1, dwtp1, dwti, dwtj, dwtk
   REAL(kind=realtype) :: uud, dwtd, dwtm1d, dwtp1d, dwtid, dwtjd, dwtkd
   REAL(kind=realtype), DIMENSION(madv) :: impl
   REAL(kind=realtype), DIMENSION(madv) :: impld
   INTRINSIC MAX
   REAL(kind=realtype) :: abs23
   INTRINSIC ABS
   REAL(kind=realtype) :: abs22
   REAL(kind=realtype) :: abs21
   REAL(kind=realtype) :: abs20
   REAL(kind=realtype) :: abs19
   REAL(kind=realtype) :: abs18
   REAL(kind=realtype) :: abs17
   REAL(kind=realtype) :: abs16
   REAL(kind=realtype) :: abs15
   REAL(kind=realtype) :: abs14
   REAL(kind=realtype) :: abs13
   REAL(kind=realtype) :: abs12
   REAL(kind=realtype) :: abs11
   REAL(kind=realtype) :: abs10
   REAL(kind=realtype) :: abs9
   REAL(kind=realtype) :: abs8
   REAL(kind=realtype) :: abs7
   REAL(kind=realtype) :: abs6
   REAL(kind=realtype) :: abs5
   REAL(kind=realtype) :: abs4
   REAL(kind=realtype) :: abs3
   REAL(kind=realtype) :: abs2
   REAL(kind=realtype) :: abs1
   REAL(kind=realtype) :: abs0
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Initialize the grid velocity to zero. This value will be used
   ! if the block is not moving.
   qs = zero
   qsd = 0.0_8
   impld = 0.0_8
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Upwind discretization of the convective term in k (zeta)       *
   !      * direction. Either the 1st order upwind or the second order     *
   !      * fully upwind interpolation scheme, kappa = -1, is used in      *
   !      * combination with the minmod limiter.                           *
   !      * The possible grid velocity must be taken into account.         *
   !      *                                                                *
   !      ******************************************************************
   !
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Compute the grid velocity if present.
   ! It is taken as the average of k and k-1,
   volid = -(half*vold(i, j, k)/vol(i, j, k)**2)
   voli = half/vol(i, j, k)
   IF (addgridvelocities) THEN
   qsd = (sfacekd(i, j, k)+sfacekd(i, j, k-1))*voli + (sfacek(i, &
   &            j, k)+sfacek(i, j, k-1))*volid
   qs = (sfacek(i, j, k)+sfacek(i, j, k-1))*voli
   END IF
   ! Compute the normal velocity, where the normal direction
   ! is taken as the average of faces k and k-1.
   xad = (skd(i, j, k, 1)+skd(i, j, k-1, 1))*voli + (sk(i, j, k, 1)&
   &          +sk(i, j, k-1, 1))*volid
   xa = (sk(i, j, k, 1)+sk(i, j, k-1, 1))*voli
   yad = (skd(i, j, k, 2)+skd(i, j, k-1, 2))*voli + (sk(i, j, k, 2)&
   &          +sk(i, j, k-1, 2))*volid
   ya = (sk(i, j, k, 2)+sk(i, j, k-1, 2))*voli
   zad = (skd(i, j, k, 3)+skd(i, j, k-1, 3))*voli + (sk(i, j, k, 3)&
   &          +sk(i, j, k-1, 3))*volid
   za = (sk(i, j, k, 3)+sk(i, j, k-1, 3))*voli
   uud = xad*w(i, j, k, ivx) + xa*wd(i, j, k, ivx) + yad*w(i, j, k&
   &          , ivy) + ya*wd(i, j, k, ivy) + zad*w(i, j, k, ivz) + za*wd(i, &
   &          j, k, ivz) - qsd
   uu = xa*w(i, j, k, ivx) + ya*w(i, j, k, ivy) + za*w(i, j, k, ivz&
   &          ) - qs
   ! Determine the situation we are having here, i.e. positive
   ! or negative normal velocity.
   IF (uu .GT. zero) THEN
   ! Velocity has a component in positive k-direction.
   ! Loop over the number of advection equations.
   DO ii=1,nadv
   ! Set the value of jj such that it corresponds to the
   ! turbulent entry in w.
   jj = ii + offset
   ! Check whether a first or a second order discretization
   ! must be used.
   IF (secondord) THEN
   ! Second order; store the three differences for the
   ! discretization of the derivative in k-direction.
   dwtm1d = wd(i, j, k-1, jj) - wd(i, j, k-2, jj)
   dwtm1 = w(i, j, k-1, jj) - w(i, j, k-2, jj)
   dwtd = wd(i, j, k, jj) - wd(i, j, k-1, jj)
   dwt = w(i, j, k, jj) - w(i, j, k-1, jj)
   dwtp1d = wd(i, j, k+1, jj) - wd(i, j, k, jj)
   dwtp1 = w(i, j, k+1, jj) - w(i, j, k, jj)
   ! Construct the derivative in this cell center. This
   ! is the first order upwind derivative with two
   ! nonlinear corrections.
   dwtkd = dwtd
   dwtk = dwt
   IF (dwt*dwtp1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs0 = dwt
   ELSE
   abs0 = -dwt
   END IF
   IF (dwtp1 .GE. 0.) THEN
   abs12 = dwtp1
   ELSE
   abs12 = -dwtp1
   END IF
   IF (abs0 .LT. abs12) THEN
   dwtkd = dwtkd + half*dwtd
   dwtk = dwtk + half*dwt
   ELSE
   dwtkd = dwtkd + half*dwtp1d
   dwtk = dwtk + half*dwtp1
   END IF
   END IF
   IF (dwt*dwtm1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs1 = dwt
   ELSE
   abs1 = -dwt
   END IF
   IF (dwtm1 .GE. 0.) THEN
   abs13 = dwtm1
   ELSE
   abs13 = -dwtm1
   END IF
   IF (abs1 .LT. abs13) THEN
   dwtkd = dwtkd - half*dwtd
   dwtk = dwtk - half*dwt
   ELSE
   dwtkd = dwtkd - half*dwtm1d
   dwtk = dwtk - half*dwtm1
   END IF
   END IF
   ELSE
   ! 1st order upwind scheme.
   dwtkd = wd(i, j, k, jj) - wd(i, j, k-1, jj)
   dwtk = w(i, j, k, jj) - w(i, j, k-1, jj)
   END IF
   ! Update the residual. The convective term must be
   ! substracted, because it appears on the other side of
   ! the equation as the source and viscous terms.
   dvtd(i, j, k, ii) = dvtd(i, j, k, ii) - uud*dwtk - uu*dwtkd
   dvt(i, j, k, ii) = dvt(i, j, k, ii) - uu*dwtk
   ! Update the central jacobian. First the term which is
   ! always present, i.e. uu.
   qqd(i, j, k, ii, ii) = qqd(i, j, k, ii, ii) + uud
   qq(i, j, k, ii, ii) = qq(i, j, k, ii, ii) + uu
   ! For boundary cells k == 2, the implicit treatment must
   ! be taken into account. Note that the implicit part
   ! is only based on the 1st order discretization.
   ! To improve stability the diagonal term is only taken
   ! into account when it improves stability, i.e. when
   ! it is positive.
   IF (k .EQ. 2) THEN
   DO kk=1,madv
   impld(kk) = bmtk1d(i, j, jj, kk+offset)
   impl(kk) = bmtk1(i, j, jj, kk+offset)
   END DO
   IF (impl(ii) .LT. zero) THEN
   impld(ii) = 0.0_8
   impl(ii) = zero
   ELSE
   impl(ii) = impl(ii)
   END IF
   DO kk=1,madv
   qqd(i, j, k, ii, kk) = qqd(i, j, k, ii, kk) + uud*impl(&
   &                  kk) + uu*impld(kk)
   qq(i, j, k, ii, kk) = qq(i, j, k, ii, kk) + uu*impl(kk)
   END DO
   END IF
   END DO
   ELSE
   ! Velocity has a component in negative k-direction.
   ! Loop over the number of advection equations.
   DO ii=1,nadv
   ! Set the value of jj such that it corresponds to the
   ! turbulent entry in w.
   jj = ii + offset
   ! Check whether a first or a second order discretization
   ! must be used.
   IF (secondord) THEN
   ! Store the three differences for the discretization of
   ! the derivative in k-direction.
   dwtm1d = wd(i, j, k, jj) - wd(i, j, k-1, jj)
   dwtm1 = w(i, j, k, jj) - w(i, j, k-1, jj)
   dwtd = wd(i, j, k+1, jj) - wd(i, j, k, jj)
   dwt = w(i, j, k+1, jj) - w(i, j, k, jj)
   dwtp1d = wd(i, j, k+2, jj) - wd(i, j, k+1, jj)
   dwtp1 = w(i, j, k+2, jj) - w(i, j, k+1, jj)
   ! Construct the derivative in this cell center. This is
   ! the first order upwind derivative with two nonlinear
   ! corrections.
   dwtkd = dwtd
   dwtk = dwt
   IF (dwt*dwtp1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs2 = dwt
   ELSE
   abs2 = -dwt
   END IF
   IF (dwtp1 .GE. 0.) THEN
   abs14 = dwtp1
   ELSE
   abs14 = -dwtp1
   END IF
   IF (abs2 .LT. abs14) THEN
   dwtkd = dwtkd - half*dwtd
   dwtk = dwtk - half*dwt
   ELSE
   dwtkd = dwtkd - half*dwtp1d
   dwtk = dwtk - half*dwtp1
   END IF
   END IF
   IF (dwt*dwtm1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs3 = dwt
   ELSE
   abs3 = -dwt
   END IF
   IF (dwtm1 .GE. 0.) THEN
   abs15 = dwtm1
   ELSE
   abs15 = -dwtm1
   END IF
   IF (abs3 .LT. abs15) THEN
   dwtkd = dwtkd + half*dwtd
   dwtk = dwtk + half*dwt
   ELSE
   dwtkd = dwtkd + half*dwtm1d
   dwtk = dwtk + half*dwtm1
   END IF
   END IF
   ELSE
   ! 1st order upwind scheme.
   dwtkd = wd(i, j, k+1, jj) - wd(i, j, k, jj)
   dwtk = w(i, j, k+1, jj) - w(i, j, k, jj)
   END IF
   ! Update the residual. The convective term must be
   ! substracted, because it appears on the other side
   ! of the equation as the source and viscous terms.
   dvtd(i, j, k, ii) = dvtd(i, j, k, ii) - uud*dwtk - uu*dwtkd
   dvt(i, j, k, ii) = dvt(i, j, k, ii) - uu*dwtk
   ! Update the central jacobian. First the term which is
   ! always present, i.e. -uu.
   qqd(i, j, k, ii, ii) = qqd(i, j, k, ii, ii) - uud
   qq(i, j, k, ii, ii) = qq(i, j, k, ii, ii) - uu
   ! For boundary cells k == kl, the implicit treatment must
   ! be taken into account. Note that the implicit part
   ! is only based on the 1st order discretization.
   ! To improve stability the diagonal term is only taken
   ! into account when it improves stability, i.e. when
   ! it is positive.
   IF (k .EQ. kl) THEN
   DO kk=1,madv
   impld(kk) = bmtk2d(i, j, jj, kk+offset)
   impl(kk) = bmtk2(i, j, jj, kk+offset)
   END DO
   IF (impl(ii) .LT. zero) THEN
   impld(ii) = 0.0_8
   impl(ii) = zero
   ELSE
   impl(ii) = impl(ii)
   END IF
   DO kk=1,madv
   qqd(i, j, k, ii, kk) = qqd(i, j, k, ii, kk) - uud*impl(&
   &                  kk) - uu*impld(kk)
   qq(i, j, k, ii, kk) = qq(i, j, k, ii, kk) - uu*impl(kk)
   END DO
   END IF
   END DO
   END IF
   END DO
   END DO
   END DO
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Upwind discretization of the convective term in j (eta)        *
   !      * direction. Either the 1st order upwind or the second order     *
   !      * fully upwind interpolation scheme, kappa = -1, is used in      *
   !      * combination with the minmod limiter.                           *
   !      * The possible grid velocity must be taken into account.         *
   !      *                                                                *
   !      ******************************************************************
   !
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Compute the grid velocity if present.
   ! It is taken as the average of j and j-1,
   volid = -(half*vold(i, j, k)/vol(i, j, k)**2)
   voli = half/vol(i, j, k)
   IF (addgridvelocities) THEN
   qsd = (sfacejd(i, j, k)+sfacejd(i, j-1, k))*voli + (sfacej(i, &
   &            j, k)+sfacej(i, j-1, k))*volid
   qs = (sfacej(i, j, k)+sfacej(i, j-1, k))*voli
   END IF
   ! Compute the normal velocity, where the normal direction
   ! is taken as the average of faces j and j-1.
   xad = (sjd(i, j, k, 1)+sjd(i, j-1, k, 1))*voli + (sj(i, j, k, 1)&
   &          +sj(i, j-1, k, 1))*volid
   xa = (sj(i, j, k, 1)+sj(i, j-1, k, 1))*voli
   yad = (sjd(i, j, k, 2)+sjd(i, j-1, k, 2))*voli + (sj(i, j, k, 2)&
   &          +sj(i, j-1, k, 2))*volid
   ya = (sj(i, j, k, 2)+sj(i, j-1, k, 2))*voli
   zad = (sjd(i, j, k, 3)+sjd(i, j-1, k, 3))*voli + (sj(i, j, k, 3)&
   &          +sj(i, j-1, k, 3))*volid
   za = (sj(i, j, k, 3)+sj(i, j-1, k, 3))*voli
   uud = xad*w(i, j, k, ivx) + xa*wd(i, j, k, ivx) + yad*w(i, j, k&
   &          , ivy) + ya*wd(i, j, k, ivy) + zad*w(i, j, k, ivz) + za*wd(i, &
   &          j, k, ivz) - qsd
   uu = xa*w(i, j, k, ivx) + ya*w(i, j, k, ivy) + za*w(i, j, k, ivz&
   &          ) - qs
   ! Determine the situation we are having here, i.e. positive
   ! or negative normal velocity.
   IF (uu .GT. zero) THEN
   ! Velocity has a component in positive j-direction.
   ! Loop over the number of advection equations.
   DO ii=1,nadv
   ! Set the value of jj such that it corresponds to the
   ! turbulent entry in w.
   jj = ii + offset
   ! Check whether a first or a second order discretization
   ! must be used.
   IF (secondord) THEN
   ! Second order; store the three differences for the
   ! discretization of the derivative in j-direction.
   dwtm1d = wd(i, j-1, k, jj) - wd(i, j-2, k, jj)
   dwtm1 = w(i, j-1, k, jj) - w(i, j-2, k, jj)
   dwtd = wd(i, j, k, jj) - wd(i, j-1, k, jj)
   dwt = w(i, j, k, jj) - w(i, j-1, k, jj)
   dwtp1d = wd(i, j+1, k, jj) - wd(i, j, k, jj)
   dwtp1 = w(i, j+1, k, jj) - w(i, j, k, jj)
   ! Construct the derivative in this cell center. This is
   ! the first order upwind derivative with two nonlinear
   ! corrections.
   dwtjd = dwtd
   dwtj = dwt
   IF (dwt*dwtp1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs4 = dwt
   ELSE
   abs4 = -dwt
   END IF
   IF (dwtp1 .GE. 0.) THEN
   abs16 = dwtp1
   ELSE
   abs16 = -dwtp1
   END IF
   IF (abs4 .LT. abs16) THEN
   dwtjd = dwtjd + half*dwtd
   dwtj = dwtj + half*dwt
   ELSE
   dwtjd = dwtjd + half*dwtp1d
   dwtj = dwtj + half*dwtp1
   END IF
   END IF
   IF (dwt*dwtm1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs5 = dwt
   ELSE
   abs5 = -dwt
   END IF
   IF (dwtm1 .GE. 0.) THEN
   abs17 = dwtm1
   ELSE
   abs17 = -dwtm1
   END IF
   IF (abs5 .LT. abs17) THEN
   dwtjd = dwtjd - half*dwtd
   dwtj = dwtj - half*dwt
   ELSE
   dwtjd = dwtjd - half*dwtm1d
   dwtj = dwtj - half*dwtm1
   END IF
   END IF
   ELSE
   ! 1st order upwind scheme.
   dwtjd = wd(i, j, k, jj) - wd(i, j-1, k, jj)
   dwtj = w(i, j, k, jj) - w(i, j-1, k, jj)
   END IF
   ! Update the residual. The convective term must be
   ! substracted, because it appears on the other side of
   ! the equation as the source and viscous terms.
   dvtd(i, j, k, ii) = dvtd(i, j, k, ii) - uud*dwtj - uu*dwtjd
   dvt(i, j, k, ii) = dvt(i, j, k, ii) - uu*dwtj
   ! Update the central jacobian. First the term which is
   ! always present, i.e. uu.
   qqd(i, j, k, ii, ii) = qqd(i, j, k, ii, ii) + uud
   qq(i, j, k, ii, ii) = qq(i, j, k, ii, ii) + uu
   ! For boundary cells j == 2, the implicit treatment must
   ! be taken into account. Note that the implicit part
   ! is only based on the 1st order discretization.
   ! To improve stability the diagonal term is only taken
   ! into account when it improves stability, i.e. when
   ! it is positive.
   IF (j .EQ. 2) THEN
   DO kk=1,madv
   impld(kk) = bmtj1d(i, k, jj, kk+offset)
   impl(kk) = bmtj1(i, k, jj, kk+offset)
   END DO
   IF (impl(ii) .LT. zero) THEN
   impld(ii) = 0.0_8
   impl(ii) = zero
   ELSE
   impl(ii) = impl(ii)
   END IF
   DO kk=1,madv
   qqd(i, j, k, ii, kk) = qqd(i, j, k, ii, kk) + uud*impl(&
   &                  kk) + uu*impld(kk)
   qq(i, j, k, ii, kk) = qq(i, j, k, ii, kk) + uu*impl(kk)
   END DO
   END IF
   END DO
   ELSE
   ! Velocity has a component in negative j-direction.
   ! Loop over the number of advection equations.
   DO ii=1,nadv
   ! Set the value of jj such that it corresponds to the
   ! turbulent entry in w.
   jj = ii + offset
   ! Check whether a first or a second order discretization
   ! must be used.
   IF (secondord) THEN
   ! Store the three differences for the discretization of
   ! the derivative in j-direction.
   dwtm1d = wd(i, j, k, jj) - wd(i, j-1, k, jj)
   dwtm1 = w(i, j, k, jj) - w(i, j-1, k, jj)
   dwtd = wd(i, j+1, k, jj) - wd(i, j, k, jj)
   dwt = w(i, j+1, k, jj) - w(i, j, k, jj)
   dwtp1d = wd(i, j+2, k, jj) - wd(i, j+1, k, jj)
   dwtp1 = w(i, j+2, k, jj) - w(i, j+1, k, jj)
   ! Construct the derivative in this cell center. This is
   ! the first order upwind derivative with two nonlinear
   ! corrections.
   dwtjd = dwtd
   dwtj = dwt
   IF (dwt*dwtp1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs6 = dwt
   ELSE
   abs6 = -dwt
   END IF
   IF (dwtp1 .GE. 0.) THEN
   abs18 = dwtp1
   ELSE
   abs18 = -dwtp1
   END IF
   IF (abs6 .LT. abs18) THEN
   dwtjd = dwtjd - half*dwtd
   dwtj = dwtj - half*dwt
   ELSE
   dwtjd = dwtjd - half*dwtp1d
   dwtj = dwtj - half*dwtp1
   END IF
   END IF
   IF (dwt*dwtm1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs7 = dwt
   ELSE
   abs7 = -dwt
   END IF
   IF (dwtm1 .GE. 0.) THEN
   abs19 = dwtm1
   ELSE
   abs19 = -dwtm1
   END IF
   IF (abs7 .LT. abs19) THEN
   dwtjd = dwtjd + half*dwtd
   dwtj = dwtj + half*dwt
   ELSE
   dwtjd = dwtjd + half*dwtm1d
   dwtj = dwtj + half*dwtm1
   END IF
   END IF
   ELSE
   ! 1st order upwind scheme.
   dwtjd = wd(i, j+1, k, jj) - wd(i, j, k, jj)
   dwtj = w(i, j+1, k, jj) - w(i, j, k, jj)
   END IF
   ! Update the residual. The convective term must be
   ! substracted, because it appears on the other side
   ! of the equation as the source and viscous terms.
   dvtd(i, j, k, ii) = dvtd(i, j, k, ii) - uud*dwtj - uu*dwtjd
   dvt(i, j, k, ii) = dvt(i, j, k, ii) - uu*dwtj
   ! Update the central jacobian. First the term which is
   ! always present, i.e. -uu.
   qqd(i, j, k, ii, ii) = qqd(i, j, k, ii, ii) - uud
   qq(i, j, k, ii, ii) = qq(i, j, k, ii, ii) - uu
   ! For boundary cells j == jl, the implicit treatment must
   ! be taken into account. Note that the implicit part
   ! is only based on the 1st order discretization.
   ! To improve stability the diagonal term is only taken
   ! into account when it improves stability, i.e. when
   ! it is positive.
   IF (j .EQ. jl) THEN
   DO kk=1,madv
   impld(kk) = bmtj2d(i, k, jj, kk+offset)
   impl(kk) = bmtj2(i, k, jj, kk+offset)
   END DO
   IF (impl(ii) .LT. zero) THEN
   impld(ii) = 0.0_8
   impl(ii) = zero
   ELSE
   impl(ii) = impl(ii)
   END IF
   DO kk=1,madv
   qqd(i, j, k, ii, kk) = qqd(i, j, k, ii, kk) - uud*impl(&
   &                  kk) - uu*impld(kk)
   qq(i, j, k, ii, kk) = qq(i, j, k, ii, kk) - uu*impl(kk)
   END DO
   END IF
   END DO
   END IF
   END DO
   END DO
   END DO
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Upwind discretization of the convective term in i (xi)         *
   !      * direction. Either the 1st order upwind or the second order     *
   !      * fully upwind interpolation scheme, kappa = -1, is used in      *
   !      * combination with the minmod limiter.                           *
   !      * The possible grid velocity must be taken into account.         *
   !      *                                                                *
   !      ******************************************************************
   !
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Compute the grid velocity if present.
   ! It is taken as the average of i and i-1,
   volid = -(half*vold(i, j, k)/vol(i, j, k)**2)
   voli = half/vol(i, j, k)
   IF (addgridvelocities) THEN
   qsd = (sfaceid(i, j, k)+sfaceid(i-1, j, k))*voli + (sfacei(i, &
   &            j, k)+sfacei(i-1, j, k))*volid
   qs = (sfacei(i, j, k)+sfacei(i-1, j, k))*voli
   END IF
   ! Compute the normal velocity, where the normal direction
   ! is taken as the average of faces i and i-1.
   xad = (sid(i, j, k, 1)+sid(i-1, j, k, 1))*voli + (si(i, j, k, 1)&
   &          +si(i-1, j, k, 1))*volid
   xa = (si(i, j, k, 1)+si(i-1, j, k, 1))*voli
   yad = (sid(i, j, k, 2)+sid(i-1, j, k, 2))*voli + (si(i, j, k, 2)&
   &          +si(i-1, j, k, 2))*volid
   ya = (si(i, j, k, 2)+si(i-1, j, k, 2))*voli
   zad = (sid(i, j, k, 3)+sid(i-1, j, k, 3))*voli + (si(i, j, k, 3)&
   &          +si(i-1, j, k, 3))*volid
   za = (si(i, j, k, 3)+si(i-1, j, k, 3))*voli
   uud = xad*w(i, j, k, ivx) + xa*wd(i, j, k, ivx) + yad*w(i, j, k&
   &          , ivy) + ya*wd(i, j, k, ivy) + zad*w(i, j, k, ivz) + za*wd(i, &
   &          j, k, ivz) - qsd
   uu = xa*w(i, j, k, ivx) + ya*w(i, j, k, ivy) + za*w(i, j, k, ivz&
   &          ) - qs
   ! Determine the situation we are having here, i.e. positive
   ! or negative normal velocity.
   IF (uu .GT. zero) THEN
   ! Velocity has a component in positive i-direction.
   ! Loop over the number of advection equations.
   DO ii=1,nadv
   ! Set the value of jj such that it corresponds to the
   ! turbulent entry in w.
   jj = ii + offset
   ! Check whether a first or a second order discretization
   ! must be used.
   IF (secondord) THEN
   ! Second order; store the three differences for the
   ! discretization of the derivative in i-direction.
   dwtm1d = wd(i-1, j, k, jj) - wd(i-2, j, k, jj)
   dwtm1 = w(i-1, j, k, jj) - w(i-2, j, k, jj)
   dwtd = wd(i, j, k, jj) - wd(i-1, j, k, jj)
   dwt = w(i, j, k, jj) - w(i-1, j, k, jj)
   dwtp1d = wd(i+1, j, k, jj) - wd(i, j, k, jj)
   dwtp1 = w(i+1, j, k, jj) - w(i, j, k, jj)
   ! Construct the derivative in this cell center. This is
   ! the first order upwind derivative with two nonlinear
   ! corrections.
   dwtid = dwtd
   dwti = dwt
   IF (dwt*dwtp1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs8 = dwt
   ELSE
   abs8 = -dwt
   END IF
   IF (dwtp1 .GE. 0.) THEN
   abs20 = dwtp1
   ELSE
   abs20 = -dwtp1
   END IF
   IF (abs8 .LT. abs20) THEN
   dwtid = dwtid + half*dwtd
   dwti = dwti + half*dwt
   ELSE
   dwtid = dwtid + half*dwtp1d
   dwti = dwti + half*dwtp1
   END IF
   END IF
   IF (dwt*dwtm1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs9 = dwt
   ELSE
   abs9 = -dwt
   END IF
   IF (dwtm1 .GE. 0.) THEN
   abs21 = dwtm1
   ELSE
   abs21 = -dwtm1
   END IF
   IF (abs9 .LT. abs21) THEN
   dwtid = dwtid - half*dwtd
   dwti = dwti - half*dwt
   ELSE
   dwtid = dwtid - half*dwtm1d
   dwti = dwti - half*dwtm1
   END IF
   END IF
   ELSE
   ! 1st order upwind scheme.
   dwtid = wd(i, j, k, jj) - wd(i-1, j, k, jj)
   dwti = w(i, j, k, jj) - w(i-1, j, k, jj)
   END IF
   ! Update the residual. The convective term must be
   ! substracted, because it appears on the other side of
   ! the equation as the source and viscous terms.
   dvtd(i, j, k, ii) = dvtd(i, j, k, ii) - uud*dwti - uu*dwtid
   dvt(i, j, k, ii) = dvt(i, j, k, ii) - uu*dwti
   ! Update the central jacobian. First the term which is
   ! always present, i.e. uu.
   qqd(i, j, k, ii, ii) = qqd(i, j, k, ii, ii) + uud
   qq(i, j, k, ii, ii) = qq(i, j, k, ii, ii) + uu
   ! For boundary cells i == 2, the implicit treatment must
   ! be taken into account. Note that the implicit part
   ! is only based on the 1st order discretization.
   ! To improve stability the diagonal term is only taken
   ! into account when it improves stability, i.e. when
   ! it is positive.
   IF (i .EQ. 2) THEN
   DO kk=1,madv
   impld(kk) = bmti1d(j, k, jj, kk+offset)
   impl(kk) = bmti1(j, k, jj, kk+offset)
   END DO
   IF (impl(ii) .LT. zero) THEN
   impld(ii) = 0.0_8
   impl(ii) = zero
   ELSE
   impl(ii) = impl(ii)
   END IF
   DO kk=1,madv
   qqd(i, j, k, ii, kk) = qqd(i, j, k, ii, kk) + uud*impl(&
   &                  kk) + uu*impld(kk)
   qq(i, j, k, ii, kk) = qq(i, j, k, ii, kk) + uu*impl(kk)
   END DO
   END IF
   END DO
   ELSE
   ! Velocity has a component in negative i-direction.
   ! Loop over the number of advection equations.
   DO ii=1,nadv
   ! Set the value of jj such that it corresponds to the
   ! turbulent entry in w.
   jj = ii + offset
   ! Check whether a first or a second order discretization
   ! must be used.
   IF (secondord) THEN
   ! Second order; store the three differences for the
   ! discretization of the derivative in i-direction.
   dwtm1d = wd(i, j, k, jj) - wd(i-1, j, k, jj)
   dwtm1 = w(i, j, k, jj) - w(i-1, j, k, jj)
   dwtd = wd(i+1, j, k, jj) - wd(i, j, k, jj)
   dwt = w(i+1, j, k, jj) - w(i, j, k, jj)
   dwtp1d = wd(i+2, j, k, jj) - wd(i+1, j, k, jj)
   dwtp1 = w(i+2, j, k, jj) - w(i+1, j, k, jj)
   ! Construct the derivative in this cell center. This is
   ! the first order upwind derivative with two nonlinear
   ! corrections.
   dwtid = dwtd
   dwti = dwt
   IF (dwt*dwtp1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs10 = dwt
   ELSE
   abs10 = -dwt
   END IF
   IF (dwtp1 .GE. 0.) THEN
   abs22 = dwtp1
   ELSE
   abs22 = -dwtp1
   END IF
   IF (abs10 .LT. abs22) THEN
   dwtid = dwtid - half*dwtd
   dwti = dwti - half*dwt
   ELSE
   dwtid = dwtid - half*dwtp1d
   dwti = dwti - half*dwtp1
   END IF
   END IF
   IF (dwt*dwtm1 .GT. zero) THEN
   IF (dwt .GE. 0.) THEN
   abs11 = dwt
   ELSE
   abs11 = -dwt
   END IF
   IF (dwtm1 .GE. 0.) THEN
   abs23 = dwtm1
   ELSE
   abs23 = -dwtm1
   END IF
   IF (abs11 .LT. abs23) THEN
   dwtid = dwtid + half*dwtd
   dwti = dwti + half*dwt
   ELSE
   dwtid = dwtid + half*dwtm1d
   dwti = dwti + half*dwtm1
   END IF
   END IF
   ELSE
   ! 1st order upwind scheme.
   dwtid = wd(i+1, j, k, jj) - wd(i, j, k, jj)
   dwti = w(i+1, j, k, jj) - w(i, j, k, jj)
   END IF
   ! Update the residual. The convective term must be
   ! substracted, because it appears on the other side
   ! of the equation as the source and viscous terms.
   dvtd(i, j, k, ii) = dvtd(i, j, k, ii) - uud*dwti - uu*dwtid
   dvt(i, j, k, ii) = dvt(i, j, k, ii) - uu*dwti
   ! Update the central jacobian. First the term which is
   ! always present, i.e. -uu.
   qqd(i, j, k, ii, ii) = qqd(i, j, k, ii, ii) - uud
   qq(i, j, k, ii, ii) = qq(i, j, k, ii, ii) - uu
   ! For boundary cells i == il, the implicit treatment must
   ! be taken into account. Note that the implicit part
   ! is only based on the 1st order discretization.
   ! To improve stability the diagonal term is only taken
   ! into account when it improves stability, i.e. when
   ! it is positive.
   IF (i .EQ. il) THEN
   DO kk=1,madv
   impld(kk) = bmti2d(j, k, jj, kk+offset)
   impl(kk) = bmti2(j, k, jj, kk+offset)
   END DO
   IF (impl(ii) .LT. zero) THEN
   impld(ii) = 0.0_8
   impl(ii) = zero
   ELSE
   impl(ii) = impl(ii)
   END IF
   DO kk=1,madv
   qqd(i, j, k, ii, kk) = qqd(i, j, k, ii, kk) - uud*impl(&
   &                  kk) - uu*impld(kk)
   qq(i, j, k, ii, kk) = qq(i, j, k, ii, kk) - uu*impl(kk)
   END DO
   END IF
   END DO
   END IF
   END DO
   END DO
   END DO
   END SUBROUTINE TURBADVECTION_D
