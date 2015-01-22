   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of residual_block in reverse (adjoint) mode (with options i4 dr8 r8 noISIZE):
   !   gradient     of useful results: *p *dw *w *x *vol *si *sj *sk
   !                *(*viscsubface.tau) gammainf
   !   with respect to varying inputs: *rev *p *gamma *dw *w *rlv
   !                *x *vol *si *sj *sk *radi *radj *radk gammainf
   !                timeref rhoinf tref winf pinfcorr rgas
   !   Plus diff mem management of: rev:in aa:in wx:in wy:in wz:in
   !                p:in gamma:in dw:in w:in rlv:in x:in qx:in qy:in
   !                qz:in ux:in vol:in uy:in uz:in si:in sj:in sk:in
   !                vx:in vy:in vz:in fw:in viscsubface:in *viscsubface.tau:in
   !                radi:in radj:in radk:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          residual.f90                                    *
   !      * Author:        Edwin van der Weide, Steve Repsher (blanking)   *
   !      * Starting date: 03-15-2003                                      *
   !      * Last modified: 10-29-2007                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE RESIDUAL_BLOCK_B()
   !
   !      ******************************************************************
   !      *                                                                *
   !      * residual computes the residual of the mean flow equations on   *
   !      * the current MG level.                                          *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS
   USE CGNSGRID
   USE FLOWVARREFSTATE
   USE INPUTITERATION
   USE INPUTDISCRETIZATION
   USE INPUTTIMESPECTRAL
   USE ITERATION
   USE INPUTADJOINT
   IMPLICIT NONE
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: discr
   INTEGER(kind=inttype) :: i, j, k, l
   REAL(kind=realtype), PARAMETER :: k1=1.05_realType
   ! Random given number
   REAL(kind=realtype), PARAMETER :: k2=0.6_realType
   ! Mach number preconditioner activation
   REAL(kind=realtype), PARAMETER :: m0=0.2_realType
   REAL(kind=realtype), PARAMETER :: alpha=0_realType
   REAL(kind=realtype), PARAMETER :: delta=0_realType
   !real(kind=realType), parameter :: hinf = 2_realType ! Test phase 
   ! Test phase
   REAL(kind=realtype), PARAMETER :: cpres=4.18_realType
   REAL(kind=realtype), PARAMETER :: temp=297.15_realType
   !
   !     Local variables
   !
   REAL(kind=realtype) :: k3, h, velxrho, velyrho, velzrho, sos, hinf, &
   & resm, a11, a12, a13, a14, a15, a21, a22, a23, a24, a25, a31, a32, a33&
   & , a34, a35
   REAL(kind=realtype) :: k3d, velxrhod, velyrhod, velzrhod, sosd, resmd&
   & , a11d, a15d, a21d, a22d, a25d, a31d, a33d, a35d
   REAL(kind=realtype) :: a41, a42, a43, a44, a45, a51, a52, a53, a54, &
   & a55, b11, b12, b13, b14, b15, b21, b22, b23, b24, b25, b31, b32, b33, &
   & b34, b35
   REAL(kind=realtype) :: a41d, a44d, a45d, a51d, a52d, a53d, a54d, a55d&
   & , b11d, b12d, b13d, b14d, b15d, b21d, b22d, b23d, b24d, b25d, b31d, &
   & b32d, b33d, b34d, b35d
   REAL(kind=realtype) :: b41, b42, b43, b44, b45, b51, b52, b53, b54, &
   & b55
   REAL(kind=realtype) :: b41d, b42d, b43d, b44d, b45d, b51d, b52d, b53d&
   & , b54d, b55d
   REAL(kind=realtype) :: rhohdash, betamr2
   REAL(kind=realtype) :: betamr2d
   REAL(kind=realtype) :: g, q
   REAL(kind=realtype) :: qd
   REAL(kind=realtype) :: b1, b2, b3, b4, b5
   REAL(kind=realtype) :: dwo(nwf)
   REAL(kind=realtype) :: dwod(nwf)
   LOGICAL :: finegrid
   INTRINSIC ABS
   INTRINSIC SQRT
   INTRINSIC MAX
   INTRINSIC MIN
   INTRINSIC REAL
   INTEGER :: branch
   REAL(kind=realtype) :: temp3
   REAL(kind=realtype) :: temp29
   REAL(kind=realtype) :: tempd14
   REAL(kind=realtype) :: temp2
   REAL(kind=realtype) :: temp28
   REAL(kind=realtype) :: tempd13
   REAL(kind=realtype) :: temp1
   REAL(kind=realtype) :: temp27
   REAL(kind=realtype) :: tempd12
   REAL(kind=realtype) :: tempd49
   REAL(kind=realtype) :: temp0
   REAL(kind=realtype) :: temp26
   REAL(kind=realtype) :: tempd11
   REAL(kind=realtype) :: tempd48
   REAL(kind=realtype) :: temp25
   REAL(kind=realtype) :: tempd10
   REAL(kind=realtype) :: tempd47
   REAL(kind=realtype) :: temp24
   REAL(kind=realtype) :: tempd46
   REAL(kind=realtype) :: temp23
   REAL(kind=realtype) :: tempd45
   REAL(kind=realtype) :: temp22
   REAL(kind=realtype) :: tempd44
   REAL(kind=realtype) :: temp21
   REAL(kind=realtype) :: tempd43
   REAL(kind=realtype) :: temp20
   REAL(kind=realtype) :: tempd42
   REAL(kind=realtype) :: tempd41
   REAL(kind=realtype) :: tempd40
   REAL(kind=realtype) :: x1
   REAL(kind=realtype) :: temp19
   REAL(kind=realtype) :: temp18
   REAL(kind=realtype) :: temp17
   REAL(kind=realtype) :: tempd39
   REAL(kind=realtype) :: temp16
   REAL(kind=realtype) :: tempd38
   REAL(kind=realtype) :: temp15
   REAL(kind=realtype) :: tempd37
   REAL(kind=realtype) :: temp14
   REAL(kind=realtype) :: tempd36
   REAL(kind=realtype) :: temp13
   REAL(kind=realtype) :: tempd35
   REAL(kind=realtype) :: temp12
   REAL(kind=realtype) :: tempd34
   REAL(kind=realtype) :: temp11
   REAL(kind=realtype) :: tempd33
   REAL(kind=realtype) :: temp10
   REAL(kind=realtype) :: tempd32
   REAL(kind=realtype) :: tempd31
   REAL(kind=realtype) :: tempd30
   REAL(kind=realtype) :: tempd64
   REAL(kind=realtype) :: temp41
   REAL(kind=realtype) :: tempd63
   REAL(kind=realtype) :: temp40
   REAL(kind=realtype) :: tempd62
   REAL(kind=realtype) :: tempd61
   REAL(kind=realtype) :: tempd60
   REAL(kind=realtype) :: tempd9
   REAL(kind=realtype) :: tempd
   REAL(kind=realtype) :: tempd8
   REAL(kind=realtype) :: tempd7
   REAL(kind=realtype) :: tempd6
   REAL(kind=realtype) :: tempd5
   REAL(kind=realtype) :: tempd4
   REAL(kind=realtype) :: tempd3
   REAL(kind=realtype) :: tempd2
   REAL(kind=realtype) :: tempd1
   REAL(kind=realtype) :: tempd0
   REAL(kind=realtype) :: x1d
   REAL(kind=realtype) :: tempd29
   REAL(kind=realtype) :: tempd28
   REAL(kind=realtype) :: tempd27
   REAL(kind=realtype) :: tempd26
   REAL(kind=realtype) :: tempd25
   REAL(kind=realtype) :: temp39
   REAL(kind=realtype) :: tempd24
   REAL(kind=realtype) :: temp38
   REAL(kind=realtype) :: tempd23
   REAL(kind=realtype) :: temp37
   REAL(kind=realtype) :: tempd22
   REAL(kind=realtype) :: tempd59
   REAL(kind=realtype) :: temp36
   REAL(kind=realtype) :: tempd21
   REAL(kind=realtype) :: tempd58
   REAL(kind=realtype) :: temp35
   REAL(kind=realtype) :: tempd20
   REAL(kind=realtype) :: tempd57
   REAL(kind=realtype) :: temp34
   REAL(kind=realtype) :: tempd56
   REAL(kind=realtype) :: temp33
   REAL(kind=realtype) :: tempd55
   REAL(kind=realtype) :: temp32
   REAL(kind=realtype) :: tempd54
   REAL(kind=realtype) :: temp31
   REAL(kind=realtype) :: tempd53
   REAL(kind=realtype) :: temp30
   REAL(kind=realtype) :: tempd52
   REAL(kind=realtype) :: tempd51
   REAL(kind=realtype) :: tempd50
   REAL(kind=realtype) :: abs0
   REAL(kind=realtype) :: temp9
   REAL(kind=realtype) :: temp8
   REAL(kind=realtype) :: tempd19
   REAL(kind=realtype) :: temp7
   REAL(kind=realtype) :: tempd18
   REAL(kind=realtype) :: temp6
   REAL(kind=realtype) :: tempd17
   REAL(kind=realtype) :: temp5
   REAL(kind=realtype) :: tempd16
   REAL(kind=realtype) :: temp4
   REAL(kind=realtype) :: tempd15
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Add the source terms from the level 0 cooling model.
   ! Set the value of rFil, which controls the fraction of the old
   ! dissipation residual to be used. This is only for the runge-kutta
   ! schemes; for other smoothers rFil is simply set to 1.0.
   ! Note the index rkStage+1 for cdisRK. The reason is that the
   ! residual computation is performed before rkStage is incremented.
   IF (smoother .EQ. rungekutta) THEN
   rfil = cdisrk(rkstage+1)
   ELSE
   rfil = one
   END IF
   ! Initialize the local arrays to monitor the massflows to zero.
   ! Set the value of the discretization, depending on the grid level,
   ! and the logical fineGrid, which indicates whether or not this
   ! is the finest grid level of the current mg cycle.
   discr = spacediscrcoarse
   IF (currentlevel .EQ. 1) discr = spacediscr
   finegrid = .false.
   IF (currentlevel .EQ. groundlevel) finegrid = .true.
   CALL INVISCIDCENTRALFLUX()
   ! Compute the artificial dissipation fluxes.
   ! This depends on the parameter discr.
   SELECT CASE  (discr) 
   CASE (dissscalar) 
   ! Standard scalar dissipation scheme.
   IF (finegrid) THEN
   IF (.NOT.lumpeddiss) THEN
   CALL INVISCIDDISSFLUXSCALAR()
   CALL PUSHCONTROL3B(0)
   ELSE
   CALL PUSHREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(w, 3)*SIZE(w, &
   &                     4))
   CALL INVISCIDDISSFLUXSCALARAPPROX()
   CALL PUSHCONTROL3B(1)
   END IF
   ELSE
   CALL PUSHCONTROL3B(2)
   END IF
   CASE (dissmatrix) 
   !===========================================================
   ! Matrix dissipation scheme.
   IF (finegrid) THEN
   IF (.NOT.lumpeddiss) THEN
   CALL INVISCIDDISSFLUXMATRIX()
   CALL PUSHCONTROL3B(3)
   ELSE
   CALL INVISCIDDISSFLUXMATRIXAPPROX()
   CALL PUSHCONTROL3B(4)
   END IF
   ELSE
   CALL PUSHCONTROL3B(5)
   END IF
   CASE (disscusp) 
   CALL PUSHCONTROL3B(6)
   CASE (upwind) 
   !===========================================================
   ! Cusp dissipation scheme.
   !===========================================================
   ! Dissipation via an upwind scheme.
   CALL INVISCIDUPWINDFLUX(finegrid)
   CALL PUSHCONTROL3B(7)
   CASE DEFAULT
   CALL PUSHCONTROL3B(6)
   END SELECT
   ! Compute the viscous flux in case of a viscous computation.
   IF (viscous) THEN
   IF (rfil .GE. 0.) THEN
   abs0 = rfil
   ELSE
   abs0 = -rfil
   END IF
   ! Only compute viscous fluxes if rFil > 0
   IF (abs0 .GT. thresholdreal) THEN
   ! not lumpedDiss means it isn't the PC...call the vicousFlux
   IF (.NOT.lumpeddiss) THEN
   CALL COMPUTESPEEDOFSOUNDSQUARED()
   CALL ALLNODALGRADIENTS()
   CALL VISCOUSFLUX()
   CALL PUSHCONTROL3B(0)
   ELSE IF (viscpc) THEN
   ! This is a PC calc...only include viscous fluxes if viscPC
   ! is used
   CALL COMPUTESPEEDOFSOUNDSQUARED()
   CALL ALLNODALGRADIENTS()
   CALL VISCOUSFLUX()
   CALL PUSHCONTROL3B(1)
   ELSE
   CALL PUSHREAL8ARRAY(p, SIZE(p, 1)*SIZE(p, 2)*SIZE(p, 3))
   CALL VISCOUSFLUXAPPROX()
   CALL PUSHCONTROL3B(2)
   END IF
   ELSE
   CALL PUSHCONTROL3B(3)
   END IF
   ELSE
   CALL PUSHCONTROL3B(4)
   END IF
   ! Add the dissipative and possibly viscous fluxes to the
   ! Euler fluxes. Loop over the owned cells and add fw to dw.
   ! Also multiply by iblank so that no updates occur in holes
   ! or on the overset boundary.
   IF (lowspeedpreconditioner) THEN
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   !    Compute speed of sound
   CALL PUSHREAL8(sos)
   sos = SQRT(gamma(i, j, k)*p(i, j, k)/w(i, j, k, irho))
   ! Coompute velocities without rho from state vector
   velxrho = w(i, j, k, ivx)
   velyrho = w(i, j, k, ivy)
   velzrho = w(i, j, k, ivz)
   q = velxrho**2 + velyrho**2 + velzrho**2
   CALL PUSHREAL8(resm)
   resm = SQRT(q)/sos
   !
   !    Compute K3
   CALL PUSHREAL8(k3)
   k3 = k1*(1+(1-k1*m0**2)*resm**2/(k1*m0**4))
   IF (k3*(velxrho**2+velyrho**2+velzrho**2) .LT. k2*(winf(ivx)**&
   &             2+winf(ivy)**2+winf(ivz)**2)) THEN
   x1 = k2*(winf(ivx)**2+winf(ivy)**2+winf(ivz)**2)
   CALL PUSHCONTROL1B(0)
   ELSE
   x1 = k3*(velxrho**2+velyrho**2+velzrho**2)
   CALL PUSHCONTROL1B(1)
   END IF
   IF (x1 .GT. sos**2) THEN
   CALL PUSHREAL8(betamr2)
   betamr2 = sos**2
   CALL PUSHCONTROL1B(0)
   ELSE
   CALL PUSHREAL8(betamr2)
   betamr2 = x1
   CALL PUSHCONTROL1B(1)
   END IF
   a11 = betamr2*(1/sos**4)
   a12 = zero
   a13 = zero
   a14 = zero
   a15 = (-betamr2)/sos**4
   a21 = one*velxrho/sos**2
   a22 = one*w(i, j, k, irho)
   a23 = zero
   a24 = zero
   a25 = one*(-velxrho)/sos**2
   a31 = one*velyrho/sos**2
   a32 = zero
   a33 = one*w(i, j, k, irho)
   a34 = zero
   a35 = one*(-velyrho)/sos**2
   a41 = one*velzrho/sos**2
   a42 = zero
   a43 = zero
   a44 = one*w(i, j, k, irho)
   a45 = zero + one*(-velzrho)/sos**2
   a51 = one*(1/(gamma(i, j, k)-1)+resm**2/2)
   a52 = one*w(i, j, k, irho)*velxrho
   a53 = one*w(i, j, k, irho)*velyrho
   a54 = one*w(i, j, k, irho)*velzrho
   a55 = one*((-(resm**2))/2)
   CALL PUSHREAL8(b11)
   b11 = a11*(gamma(i, j, k)-1)*q/2 + a12*(-velxrho)/w(i, j, k, &
   &           irho) + a13*(-velyrho)/w(i, j, k, irho) + a14*(-velzrho)/w(i&
   &           , j, k, irho) + a15*((gamma(i, j, k)-1)*q/2-sos**2)
   CALL PUSHREAL8(b12)
   b12 = a11*(1-gamma(i, j, k))*velxrho + a12*1/w(i, j, k, irho) &
   &           + a15*(1-gamma(i, j, k))*velxrho
   CALL PUSHREAL8(b13)
   b13 = a11*(1-gamma(i, j, k))*velyrho + a13/w(i, j, k, irho) + &
   &           a15*(1-gamma(i, j, k))*velyrho
   CALL PUSHREAL8(b14)
   b14 = a11*(1-gamma(i, j, k))*velzrho + a14/w(i, j, k, irho) + &
   &           a15*(1-gamma(i, j, k))*velzrho
   b15 = a11*(gamma(i, j, k)-1) + a15*(gamma(i, j, k)-1)
   CALL PUSHREAL8(b21)
   b21 = a21*(gamma(i, j, k)-1)*q/2 + a22*(-velxrho)/w(i, j, k, &
   &           irho) + a23*(-velyrho)/w(i, j, k, irho) + a24*(-velzrho)/w(i&
   &           , j, k, irho) + a25*((gamma(i, j, k)-1)*q/2-sos**2)
   CALL PUSHREAL8(b22)
   b22 = a21*(1-gamma(i, j, k))*velxrho + a22/w(i, j, k, irho) + &
   &           a25*(1-gamma(i, j, k))*velxrho
   CALL PUSHREAL8(b23)
   b23 = a21*(1-gamma(i, j, k))*velyrho + a23*1/w(i, j, k, irho) &
   &           + a25*(1-gamma(i, j, k))*velyrho
   CALL PUSHREAL8(b24)
   b24 = a21*(1-gamma(i, j, k))*velzrho + a24*1/w(i, j, k, irho) &
   &           + a25*(1-gamma(i, j, k))*velzrho
   b25 = a21*(gamma(i, j, k)-1) + a25*(gamma(i, j, k)-1)
   CALL PUSHREAL8(b31)
   b31 = a31*(gamma(i, j, k)-1)*q/2 + a32*(-velxrho)/w(i, j, k, &
   &           irho) + a33*(-velyrho)/w(i, j, k, irho) + a34*(-velzrho)/w(i&
   &           , j, k, irho) + a35*((gamma(i, j, k)-1)*q/2-sos**2)
   CALL PUSHREAL8(b32)
   b32 = a31*(1-gamma(i, j, k))*velxrho + a32/w(i, j, k, irho) + &
   &           a35*(1-gamma(i, j, k))*velxrho
   CALL PUSHREAL8(b33)
   b33 = a31*(1-gamma(i, j, k))*velyrho + a33*1/w(i, j, k, irho) &
   &           + a35*(1-gamma(i, j, k))*velyrho
   CALL PUSHREAL8(b34)
   b34 = a31*(1-gamma(i, j, k))*velzrho + a34*1/w(i, j, k, irho) &
   &           + a35*(1-gamma(i, j, k))*velzrho
   b35 = a31*(gamma(i, j, k)-1) + a35*(gamma(i, j, k)-1)
   CALL PUSHREAL8(b41)
   b41 = a41*(gamma(i, j, k)-1)*q/2 + a42*(-velxrho)/w(i, j, k, &
   &           irho) + a43*(-velyrho)/w(i, j, k, irho) + a44*(-velzrho)/w(i&
   &           , j, k, irho) + a45*((gamma(i, j, k)-1)*q/2-sos**2)
   CALL PUSHREAL8(b42)
   b42 = a41*(1-gamma(i, j, k))*velxrho + a42/w(i, j, k, irho) + &
   &           a45*(1-gamma(i, j, k))*velxrho
   CALL PUSHREAL8(b43)
   b43 = a41*(1-gamma(i, j, k))*velyrho + a43*1/w(i, j, k, irho) &
   &           + a45*(1-gamma(i, j, k))*velyrho
   CALL PUSHREAL8(b44)
   b44 = a41*(1-gamma(i, j, k))*velzrho + a44*1/w(i, j, k, irho) &
   &           + a45*(1-gamma(i, j, k))*velzrho
   b45 = a41*(gamma(i, j, k)-1) + a45*(gamma(i, j, k)-1)
   CALL PUSHREAL8(b51)
   b51 = a51*(gamma(i, j, k)-1)*q/2 + a52*(-velxrho)/w(i, j, k, &
   &           irho) + a53*(-velyrho)/w(i, j, k, irho) + a54*(-velzrho)/w(i&
   &           , j, k, irho) + a55*((gamma(i, j, k)-1)*q/2-sos**2)
   CALL PUSHREAL8(b52)
   b52 = a51*(1-gamma(i, j, k))*velxrho + a52/w(i, j, k, irho) + &
   &           a55*(1-gamma(i, j, k))*velxrho
   CALL PUSHREAL8(b53)
   b53 = a51*(1-gamma(i, j, k))*velyrho + a53*1/w(i, j, k, irho) &
   &           + a55*(1-gamma(i, j, k))*velyrho
   CALL PUSHREAL8(b54)
   b54 = a51*(1-gamma(i, j, k))*velzrho + a54*1/w(i, j, k, irho) &
   &           + a55*(1-gamma(i, j, k))*velzrho
   b55 = a51*(gamma(i, j, k)-1) + a55*(gamma(i, j, k)-1)
   ! dwo is the orginal redisual
   DO l=1,nwf
   CALL PUSHREAL8(dwo(l))
   dwo(l) = (dw(i, j, k, l)+fw(i, j, k, l))*REAL(iblank(i, j, k&
   &             ), realtype)
   END DO
   dw(i, j, k, 1) = b11*dwo(1) + b12*dwo(2) + b13*dwo(3) + b14*&
   &           dwo(4) + b15*dwo(5)
   dw(i, j, k, 2) = b21*dwo(1) + b22*dwo(2) + b23*dwo(3) + b24*&
   &           dwo(4) + b25*dwo(5)
   dw(i, j, k, 3) = b31*dwo(1) + b32*dwo(2) + b33*dwo(3) + b34*&
   &           dwo(4) + b35*dwo(5)
   dw(i, j, k, 4) = b41*dwo(1) + b42*dwo(2) + b43*dwo(3) + b44*&
   &           dwo(4) + b45*dwo(5)
   dw(i, j, k, 5) = b51*dwo(1) + b52*dwo(2) + b53*dwo(3) + b54*&
   &           dwo(4) + b55*dwo(5)
   END DO
   END DO
   END DO
   gammad = 0.0_8
   fwd = 0.0_8
   winfd = 0.0_8
   dwod = 0.0_8
   DO k=kl,2,-1
   DO j=jl,2,-1
   DO i=il,2,-1
   a51 = one*(1/(gamma(i, j, k)-1)+resm**2/2)
   a55 = one*((-(resm**2))/2)
   b55 = a51*(gamma(i, j, k)-1) + a55*(gamma(i, j, k)-1)
   b51d = dwo(1)*dwd(i, j, k, 5)
   dwod(1) = dwod(1) + b51*dwd(i, j, k, 5)
   b52d = dwo(2)*dwd(i, j, k, 5)
   dwod(2) = dwod(2) + b52*dwd(i, j, k, 5)
   b53d = dwo(3)*dwd(i, j, k, 5)
   dwod(3) = dwod(3) + b53*dwd(i, j, k, 5)
   b54d = dwo(4)*dwd(i, j, k, 5)
   dwod(4) = dwod(4) + b54*dwd(i, j, k, 5)
   b55d = dwo(5)*dwd(i, j, k, 5)
   dwod(5) = dwod(5) + b55*dwd(i, j, k, 5)
   dwd(i, j, k, 5) = 0.0_8
   velzrho = w(i, j, k, ivz)
   a41 = one*velzrho/sos**2
   a45 = zero + one*(-velzrho)/sos**2
   b45 = a41*(gamma(i, j, k)-1) + a45*(gamma(i, j, k)-1)
   b41d = dwo(1)*dwd(i, j, k, 4)
   dwod(1) = dwod(1) + b41*dwd(i, j, k, 4)
   b42d = dwo(2)*dwd(i, j, k, 4)
   dwod(2) = dwod(2) + b42*dwd(i, j, k, 4)
   b43d = dwo(3)*dwd(i, j, k, 4)
   dwod(3) = dwod(3) + b43*dwd(i, j, k, 4)
   b44d = dwo(4)*dwd(i, j, k, 4)
   dwod(4) = dwod(4) + b44*dwd(i, j, k, 4)
   b45d = dwo(5)*dwd(i, j, k, 4)
   dwod(5) = dwod(5) + b45*dwd(i, j, k, 4)
   dwd(i, j, k, 4) = 0.0_8
   velyrho = w(i, j, k, ivy)
   a31 = one*velyrho/sos**2
   a35 = one*(-velyrho)/sos**2
   b35 = a31*(gamma(i, j, k)-1) + a35*(gamma(i, j, k)-1)
   b31d = dwo(1)*dwd(i, j, k, 3)
   dwod(1) = dwod(1) + b31*dwd(i, j, k, 3)
   b32d = dwo(2)*dwd(i, j, k, 3)
   dwod(2) = dwod(2) + b32*dwd(i, j, k, 3)
   b33d = dwo(3)*dwd(i, j, k, 3)
   dwod(3) = dwod(3) + b33*dwd(i, j, k, 3)
   b34d = dwo(4)*dwd(i, j, k, 3)
   dwod(4) = dwod(4) + b34*dwd(i, j, k, 3)
   b35d = dwo(5)*dwd(i, j, k, 3)
   dwod(5) = dwod(5) + b35*dwd(i, j, k, 3)
   dwd(i, j, k, 3) = 0.0_8
   velxrho = w(i, j, k, ivx)
   a21 = one*velxrho/sos**2
   a25 = one*(-velxrho)/sos**2
   b25 = a21*(gamma(i, j, k)-1) + a25*(gamma(i, j, k)-1)
   b21d = dwo(1)*dwd(i, j, k, 2)
   dwod(1) = dwod(1) + b21*dwd(i, j, k, 2)
   b22d = dwo(2)*dwd(i, j, k, 2)
   dwod(2) = dwod(2) + b22*dwd(i, j, k, 2)
   b23d = dwo(3)*dwd(i, j, k, 2)
   dwod(3) = dwod(3) + b23*dwd(i, j, k, 2)
   b24d = dwo(4)*dwd(i, j, k, 2)
   dwod(4) = dwod(4) + b24*dwd(i, j, k, 2)
   b25d = dwo(5)*dwd(i, j, k, 2)
   dwod(5) = dwod(5) + b25*dwd(i, j, k, 2)
   dwd(i, j, k, 2) = 0.0_8
   a11 = betamr2*(1/sos**4)
   a15 = (-betamr2)/sos**4
   b15 = a11*(gamma(i, j, k)-1) + a15*(gamma(i, j, k)-1)
   b11d = dwo(1)*dwd(i, j, k, 1)
   dwod(1) = dwod(1) + b11*dwd(i, j, k, 1)
   b12d = dwo(2)*dwd(i, j, k, 1)
   dwod(2) = dwod(2) + b12*dwd(i, j, k, 1)
   b13d = dwo(3)*dwd(i, j, k, 1)
   dwod(3) = dwod(3) + b13*dwd(i, j, k, 1)
   b14d = dwo(4)*dwd(i, j, k, 1)
   dwod(4) = dwod(4) + b14*dwd(i, j, k, 1)
   b15d = dwo(5)*dwd(i, j, k, 1)
   dwod(5) = dwod(5) + b15*dwd(i, j, k, 1)
   dwd(i, j, k, 1) = 0.0_8
   DO l=nwf,1,-1
   CALL POPREAL8(dwo(l))
   tempd63 = REAL(iblank(i, j, k), realtype)*dwod(l)
   dwd(i, j, k, l) = dwd(i, j, k, l) + tempd63
   fwd(i, j, k, l) = fwd(i, j, k, l) + tempd63
   dwod(l) = 0.0_8
   END DO
   temp4 = sos**4
   temp5 = sos**4
   temp8 = gamma(i, j, k) - 1
   tempd60 = (gamma(i, j, k)-1)*b11d
   tempd46 = (1-gamma(i, j, k))*b12d
   tempd47 = (1-gamma(i, j, k))*b12d
   tempd31 = (1-gamma(i, j, k))*b13d
   tempd32 = (1-gamma(i, j, k))*b13d
   tempd16 = (1-gamma(i, j, k))*b14d
   tempd17 = (1-gamma(i, j, k))*b14d
   temp15 = gamma(i, j, k) - 1
   tempd57 = (gamma(i, j, k)-1)*b21d
   tempd48 = (1-gamma(i, j, k))*b22d
   tempd49 = (1-gamma(i, j, k))*b22d
   tempd33 = (1-gamma(i, j, k))*b23d
   tempd34 = (1-gamma(i, j, k))*b23d
   tempd18 = (1-gamma(i, j, k))*b24d
   tempd19 = (1-gamma(i, j, k))*b24d
   temp22 = gamma(i, j, k) - 1
   tempd62 = (gamma(i, j, k)-1)*b31d
   tempd50 = (1-gamma(i, j, k))*b32d
   tempd51 = (1-gamma(i, j, k))*b32d
   tempd35 = (1-gamma(i, j, k))*b33d
   tempd36 = (1-gamma(i, j, k))*b33d
   tempd20 = (1-gamma(i, j, k))*b34d
   tempd21 = (1-gamma(i, j, k))*b34d
   temp29 = gamma(i, j, k) - 1
   tempd55 = (gamma(i, j, k)-1)*b41d
   tempd52 = (1-gamma(i, j, k))*b42d
   tempd53 = (1-gamma(i, j, k))*b42d
   tempd37 = (1-gamma(i, j, k))*b43d
   tempd38 = (1-gamma(i, j, k))*b43d
   tempd22 = (1-gamma(i, j, k))*b44d
   tempd23 = (1-gamma(i, j, k))*b44d
   q = velxrho**2 + velyrho**2 + velzrho**2
   tempd4 = (gamma(i, j, k)-1)*b51d
   temp38 = w(i, j, k, irho)
   tempd39 = -(b51d/temp38)
   temp37 = w(i, j, k, irho)
   tempd24 = -(b51d/temp37)
   temp36 = gamma(i, j, k) - 1
   temp35 = w(i, j, k, irho)
   tempd9 = -(b51d/temp35)
   a41d = velzrho*tempd23 + velxrho*tempd53 + q*tempd55/2 + &
   &           velyrho*tempd38 + (gamma(i, j, k)-1)*b45d
   a45d = velzrho*tempd22 + velxrho*tempd52 + (temp29*(q/2)-sos**&
   &           2)*b41d + velyrho*tempd37 + (gamma(i, j, k)-1)*b45d
   a44 = one*w(i, j, k, irho)
   a43 = zero
   a42 = zero
   temp31 = w(i, j, k, irho)
   tempd40 = -(a42*b41d/temp31)
   temp30 = w(i, j, k, irho)
   tempd25 = -(a43*b41d/temp30)
   tempd56 = a45*b41d
   temp28 = w(i, j, k, irho)
   tempd10 = -(b41d/temp28)
   a31d = velzrho*tempd21 + velxrho*tempd51 + q*tempd62/2 + &
   &           velyrho*tempd36 + (gamma(i, j, k)-1)*b35d
   a35d = velzrho*tempd20 + velxrho*tempd50 + (temp22*(q/2)-sos**&
   &           2)*b31d + velyrho*tempd35 + (gamma(i, j, k)-1)*b35d
   a34 = zero
   a33 = one*w(i, j, k, irho)
   a32 = zero
   temp24 = w(i, j, k, irho)
   tempd41 = -(a32*b31d/temp24)
   temp23 = w(i, j, k, irho)
   tempd26 = -(b31d/temp23)
   tempd61 = a35*b31d
   temp21 = w(i, j, k, irho)
   tempd11 = -(a34*b31d/temp21)
   a21d = velzrho*tempd19 + velxrho*tempd49 + q*tempd57/2 + &
   &           velyrho*tempd34 + (gamma(i, j, k)-1)*b25d
   a25d = velzrho*tempd18 + velxrho*tempd48 + (temp15*(q/2)-sos**&
   &           2)*b21d + velyrho*tempd33 + (gamma(i, j, k)-1)*b25d
   a24 = zero
   a23 = zero
   a22 = one*w(i, j, k, irho)
   temp17 = w(i, j, k, irho)
   tempd42 = -(b21d/temp17)
   temp16 = w(i, j, k, irho)
   tempd27 = -(a23*b21d/temp16)
   tempd58 = a25*b21d
   temp14 = w(i, j, k, irho)
   tempd12 = -(a24*b21d/temp14)
   a11d = velzrho*tempd17 + velxrho*tempd47 + q*tempd60/2 + &
   &           velyrho*tempd32 + (gamma(i, j, k)-1)*b15d
   a15d = velzrho*tempd16 + velxrho*tempd46 + (temp8*(q/2)-sos**2&
   &           )*b11d + velyrho*tempd31 + (gamma(i, j, k)-1)*b15d
   a14 = zero
   a13 = zero
   a12 = zero
   temp10 = w(i, j, k, irho)
   tempd43 = -(a12*b11d/temp10)
   temp9 = w(i, j, k, irho)
   tempd28 = -(a13*b11d/temp9)
   tempd59 = a15*b11d
   temp7 = w(i, j, k, irho)
   tempd13 = -(a14*b11d/temp7)
   tempd14 = -(one*a45d/sos**2)
   tempd15 = one*a41d/sos**2
   tempd29 = -(one*a35d/sos**2)
   tempd30 = one*a31d/sos**2
   tempd44 = -(one*a25d/sos**2)
   tempd45 = one*a21d/sos**2
   tempd7 = (1-gamma(i, j, k))*b52d
   tempd3 = (1-gamma(i, j, k))*b52d
   tempd8 = (1-gamma(i, j, k))*b53d
   tempd5 = (1-gamma(i, j, k))*b53d
   tempd6 = (1-gamma(i, j, k))*b54d
   tempd2 = (1-gamma(i, j, k))*b54d
   a51d = velzrho*tempd2 + velxrho*tempd3 + q*tempd4/2 + velyrho*&
   &           tempd5 + (gamma(i, j, k)-1)*b55d
   gammad(i, j, k) = gammad(i, j, k) + (a55+a51)*b55d
   a55d = velzrho*tempd6 + velxrho*tempd7 + (temp36*(q/2)-sos**2)&
   &           *b51d + velyrho*tempd8 + (gamma(i, j, k)-1)*b55d
   a54 = one*w(i, j, k, irho)*velzrho
   CALL POPREAL8(b54)
   temp41 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a55*velzrho)-a51*&
   &           velzrho)*b54d
   a54d = velzrho*tempd9 + b54d/temp41
   velzrhod = a54*tempd9 + a44*tempd10 + tempd11 + tempd12 + &
   &           tempd13 + tempd14 + tempd15 + one*w(i, j, k, irho)*a54d + &
   &           a15*tempd16 + a11*tempd17 + a25*tempd18 + a21*tempd19 + a35*&
   &           tempd20 + a31*tempd21 + a45*tempd22 + a41*tempd23 + a55*&
   &           tempd6 + a51*tempd2
   wd(i, j, k, irho) = wd(i, j, k, irho) - a54*b54d/temp41**2
   a53 = one*w(i, j, k, irho)*velyrho
   CALL POPREAL8(b53)
   temp40 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a55*velyrho)-a51*&
   &           velyrho)*b53d
   a53d = velyrho*tempd24 + b53d/temp40
   velyrhod = a53*tempd24 + tempd25 + a33*tempd26 + tempd27 + &
   &           tempd28 + tempd29 + tempd30 + one*w(i, j, k, irho)*a53d + &
   &           a15*tempd31 + a11*tempd32 + a25*tempd33 + a21*tempd34 + a35*&
   &           tempd35 + a31*tempd36 + a45*tempd37 + a41*tempd38 + a55*&
   &           tempd8 + a51*tempd5
   wd(i, j, k, irho) = wd(i, j, k, irho) - a53*b53d/temp40**2
   a52 = one*w(i, j, k, irho)*velxrho
   CALL POPREAL8(b52)
   temp39 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a55*velxrho)-a51*&
   &           velxrho)*b52d
   a52d = velxrho*tempd39 + b52d/temp39
   velxrhod = a52*tempd39 + tempd40 + tempd41 + a22*tempd42 + &
   &           tempd43 + tempd44 + tempd45 + one*w(i, j, k, irho)*a52d + &
   &           a15*tempd46 + a11*tempd47 + a25*tempd48 + a21*tempd49 + a35*&
   &           tempd50 + a31*tempd51 + a45*tempd52 + a41*tempd53 + a55*&
   &           tempd7 + a51*tempd3
   wd(i, j, k, irho) = wd(i, j, k, irho) - a52*b52d/temp39**2
   CALL POPREAL8(b51)
   tempd54 = a55*b51d
   qd = a41*tempd55/2 + temp29*tempd56/2 + a21*tempd57/2 + temp15&
   &           *tempd58/2 + temp8*tempd59/2 + a11*tempd60/2 + temp22*&
   &           tempd61/2 + a31*tempd62/2 + temp36*tempd54/2 + a51*tempd4/2
   gammad(i, j, k) = gammad(i, j, k) + q*tempd54/2 + a51*q*b51d/2
   wd(i, j, k, irho) = wd(i, j, k, irho) - a54*velzrho*tempd9/&
   &           temp35 - a53*velyrho*tempd24/temp37 - a52*velxrho*tempd39/&
   &           temp38
   sosd = betamr2*4*sos**3*a15d/temp5**2 - 2*sos*tempd58 - &
   &           velzrho*2*tempd14/sos - velyrho*2*tempd29/sos - velxrho*2*&
   &           tempd44/sos - 2*sos*tempd56 - betamr2*4*sos**3*a11d/temp4**2&
   &           - velxrho*2*tempd45/sos - velyrho*2*tempd30/sos - velzrho*2*&
   &           tempd15/sos - 2*sos*tempd59 - 2*sos*tempd61 - 2*sos*tempd54
   gammad(i, j, k) = gammad(i, j, k) + (a45+a41)*b45d
   CALL POPREAL8(b44)
   temp34 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a45*velzrho)-a41*&
   &           velzrho)*b44d
   a44d = velzrho*tempd10 + b44d/temp34
   wd(i, j, k, irho) = wd(i, j, k, irho) - a44*b44d/temp34**2
   CALL POPREAL8(b43)
   temp33 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a45*velyrho)-a41*&
   &           velyrho)*b43d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a43*b43d/temp33**2
   CALL POPREAL8(b42)
   temp32 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a45*velxrho)-a41*&
   &           velxrho)*b42d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a42*b42d/temp32**2
   CALL POPREAL8(b41)
   gammad(i, j, k) = gammad(i, j, k) + q*tempd56/2 + a41*q*b41d/2
   wd(i, j, k, irho) = wd(i, j, k, irho) - a44*velzrho*tempd10/&
   &           temp28 - velyrho*tempd25/temp30 - velxrho*tempd40/temp31
   gammad(i, j, k) = gammad(i, j, k) + (a35+a31)*b35d
   CALL POPREAL8(b34)
   temp27 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a35*velzrho)-a31*&
   &           velzrho)*b34d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a34*b34d/temp27**2
   CALL POPREAL8(b33)
   temp26 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a35*velyrho)-a31*&
   &           velyrho)*b33d
   a33d = velyrho*tempd26 + b33d/temp26
   wd(i, j, k, irho) = wd(i, j, k, irho) - a33*b33d/temp26**2
   CALL POPREAL8(b32)
   temp25 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a35*velxrho)-a31*&
   &           velxrho)*b32d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a32*b32d/temp25**2
   CALL POPREAL8(b31)
   gammad(i, j, k) = gammad(i, j, k) + q*tempd61/2 + a31*q*b31d/2
   wd(i, j, k, irho) = wd(i, j, k, irho) - velzrho*tempd11/temp21&
   &           - a33*velyrho*tempd26/temp23 - velxrho*tempd41/temp24
   gammad(i, j, k) = gammad(i, j, k) + (a25+a21)*b25d
   CALL POPREAL8(b24)
   temp20 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a25*velzrho)-a21*&
   &           velzrho)*b24d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a24*b24d/temp20**2
   CALL POPREAL8(b23)
   temp19 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a25*velyrho)-a21*&
   &           velyrho)*b23d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a23*b23d/temp19**2
   CALL POPREAL8(b22)
   temp18 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a25*velxrho)-a21*&
   &           velxrho)*b22d
   a22d = velxrho*tempd42 + b22d/temp18
   wd(i, j, k, irho) = wd(i, j, k, irho) - a22*b22d/temp18**2
   CALL POPREAL8(b21)
   gammad(i, j, k) = gammad(i, j, k) + q*tempd58/2 + a21*q*b21d/2
   wd(i, j, k, irho) = wd(i, j, k, irho) - velzrho*tempd12/temp14&
   &           - velyrho*tempd27/temp16 - a22*velxrho*tempd42/temp17
   gammad(i, j, k) = gammad(i, j, k) + (a15+a11)*b15d
   CALL POPREAL8(b14)
   temp13 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a15*velzrho)-a11*&
   &           velzrho)*b14d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a14*b14d/temp13**2
   CALL POPREAL8(b13)
   temp12 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a15*velyrho)-a11*&
   &           velyrho)*b13d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a13*b13d/temp12**2
   CALL POPREAL8(b12)
   temp11 = w(i, j, k, irho)
   gammad(i, j, k) = gammad(i, j, k) + (-(a15*velxrho)-a11*&
   &           velxrho)*b12d
   wd(i, j, k, irho) = wd(i, j, k, irho) - a12*b12d/temp11**2
   CALL POPREAL8(b11)
   gammad(i, j, k) = gammad(i, j, k) + q*tempd59/2 + a11*q*b11d/2
   wd(i, j, k, irho) = wd(i, j, k, irho) - velzrho*tempd13/temp7 &
   &           - velyrho*tempd28/temp9 - velxrho*tempd43/temp10
   resmd = one*resm*a51d - one*resm*a55d
   wd(i, j, k, irho) = wd(i, j, k, irho) + one*velzrho*a54d
   wd(i, j, k, irho) = wd(i, j, k, irho) + one*velyrho*a53d
   wd(i, j, k, irho) = wd(i, j, k, irho) + one*velxrho*a52d
   temp6 = gamma(i, j, k) - 1
   gammad(i, j, k) = gammad(i, j, k) - one*a51d/temp6**2
   wd(i, j, k, irho) = wd(i, j, k, irho) + one*a44d
   wd(i, j, k, irho) = wd(i, j, k, irho) + one*a33d
   wd(i, j, k, irho) = wd(i, j, k, irho) + one*a22d
   betamr2d = a11d/temp4 - a15d/temp5
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   CALL POPREAL8(betamr2)
   sosd = sosd + 2*sos*betamr2d
   x1d = 0.0_8
   ELSE
   CALL POPREAL8(betamr2)
   x1d = betamr2d
   END IF
   CALL POPCONTROL1B(branch)
   IF (branch .EQ. 0) THEN
   tempd0 = k2*x1d
   winfd(ivx) = winfd(ivx) + 2*winf(ivx)*tempd0
   winfd(ivy) = winfd(ivy) + 2*winf(ivy)*tempd0
   winfd(ivz) = winfd(ivz) + 2*winf(ivz)*tempd0
   k3d = 0.0_8
   ELSE
   tempd1 = k3*x1d
   k3d = (velxrho**2+velyrho**2+velzrho**2)*x1d
   velxrhod = velxrhod + 2*velxrho*tempd1
   velyrhod = velyrhod + 2*velyrho*tempd1
   velzrhod = velzrhod + 2*velzrho*tempd1
   END IF
   CALL POPREAL8(k3)
   resmd = resmd + (1-k1*m0**2)*2*resm*k3d/m0**4
   CALL POPREAL8(resm)
   temp3 = SQRT(q)
   IF (.NOT.q .EQ. 0.0_8) qd = qd + resmd/(sos*2.0*temp3)
   sosd = sosd - temp3*resmd/sos**2
   velxrhod = velxrhod + 2*velxrho*qd
   velyrhod = velyrhod + 2*velyrho*qd
   velzrhod = velzrhod + 2*velzrho*qd
   wd(i, j, k, ivz) = wd(i, j, k, ivz) + velzrhod
   wd(i, j, k, ivy) = wd(i, j, k, ivy) + velyrhod
   wd(i, j, k, ivx) = wd(i, j, k, ivx) + velxrhod
   CALL POPREAL8(sos)
   temp2 = w(i, j, k, irho)
   temp1 = gamma(i, j, k)*p(i, j, k)
   temp0 = temp1/temp2
   IF (temp0 .EQ. 0.0_8) THEN
   tempd = 0.0
   ELSE
   tempd = sosd/(2.0*SQRT(temp0)*temp2)
   END IF
   gammad(i, j, k) = gammad(i, j, k) + p(i, j, k)*tempd
   pd(i, j, k) = pd(i, j, k) + gamma(i, j, k)*tempd
   wd(i, j, k, irho) = wd(i, j, k, irho) - temp0*tempd
   END DO
   END DO
   END DO
   ELSE
   fwd = 0.0_8
   DO l=nwf,1,-1
   DO k=kl,2,-1
   DO j=jl,2,-1
   DO i=il,2,-1
   tempd64 = REAL(iblank(i, j, k), realtype)*dwd(i, j, k, l)
   fwd(i, j, k, l) = fwd(i, j, k, l) + tempd64
   dwd(i, j, k, l) = tempd64
   END DO
   END DO
   END DO
   END DO
   gammad = 0.0_8
   winfd = 0.0_8
   END IF
   CALL POPCONTROL3B(branch)
   IF (branch .LT. 2) THEN
   IF (branch .EQ. 0) THEN
   CALL VISCOUSFLUX_B()
   CALL ALLNODALGRADIENTS_B()
   CALL COMPUTESPEEDOFSOUNDSQUARED_B()
   ELSE
   CALL VISCOUSFLUX_B()
   CALL ALLNODALGRADIENTS_B()
   CALL COMPUTESPEEDOFSOUNDSQUARED_B()
   END IF
   ELSE IF (branch .EQ. 2) THEN
   CALL POPREAL8ARRAY(p, SIZE(p, 1)*SIZE(p, 2)*SIZE(p, 3))
   CALL VISCOUSFLUXAPPROX_B()
   ELSE IF (branch .EQ. 3) THEN
   revd = 0.0_8
   rlvd = 0.0_8
   ELSE
   revd = 0.0_8
   rlvd = 0.0_8
   END IF
   CALL POPCONTROL3B(branch)
   IF (branch .LT. 4) THEN
   IF (branch .LT. 2) THEN
   IF (branch .EQ. 0) THEN
   CALL INVISCIDDISSFLUXSCALAR_B()
   ELSE
   CALL POPREAL8ARRAY(w, SIZE(w, 1)*SIZE(w, 2)*SIZE(w, 3)*SIZE(w, 4&
   &                    ))
   CALL INVISCIDDISSFLUXSCALARAPPROX_B()
   END IF
   ELSE IF (branch .EQ. 2) THEN
   radid = 0.0_8
   radjd = 0.0_8
   radkd = 0.0_8
   rhoinfd = 0.0_8
   pinfcorrd = 0.0_8
   ELSE
   CALL INVISCIDDISSFLUXMATRIX_B()
   GOTO 100
   END IF
   trefd = 0.0_8
   rgasd = 0.0_8
   GOTO 110
   ELSE IF (branch .LT. 6) THEN
   IF (branch .EQ. 4) THEN
   CALL INVISCIDDISSFLUXMATRIXAPPROX_B()
   ELSE
   pinfcorrd = 0.0_8
   END IF
   ELSE
   IF (branch .EQ. 6) THEN
   radid = 0.0_8
   radjd = 0.0_8
   radkd = 0.0_8
   rhoinfd = 0.0_8
   trefd = 0.0_8
   pinfcorrd = 0.0_8
   rgasd = 0.0_8
   ELSE
   CALL INVISCIDUPWINDFLUX_B(finegrid)
   radid = 0.0_8
   radjd = 0.0_8
   radkd = 0.0_8
   rhoinfd = 0.0_8
   pinfcorrd = 0.0_8
   END IF
   GOTO 110
   END IF
   100 radid = 0.0_8
   radjd = 0.0_8
   radkd = 0.0_8
   rhoinfd = 0.0_8
   trefd = 0.0_8
   rgasd = 0.0_8
   110 CALL INVISCIDCENTRALFLUX_B()
   END SUBROUTINE RESIDUAL_BLOCK_B
