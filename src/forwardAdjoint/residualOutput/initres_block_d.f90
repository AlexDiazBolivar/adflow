   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of initres_block in forward (tangent) mode:
   !   variations   of useful results: *dw
   !   with respect to varying inputs: flowdoms.w *dw *w *vol *coeftime
   !                deltat
   !   Plus diff mem management of: flowdoms.vol:in flowdoms.w1:in
   !                volold:in wr:in dw:in w:in w1:in vol:in wold:in
   !                wn:in coeftime:in dscalar:in dvector:in (global)sendbuffer:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          initres.f90                                     *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-18-2003                                      *
   !      * Last modified: 06-28-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE INITRES_BLOCK_D(varstart, varend, nn, sps)
   USE FLOWVARREFSTATE
   USE INPUTITERATION
   USE BLOCKPOINTERS_D
   USE INPUTTIMESPECTRAL
   USE INPUTUNSTEADY
   USE INPUTPHYSICS
   USE ITERATION
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * initres initializes the given range of the residual. Either to *
   !      * zero, steady computation, or to an unsteady term for the time  *
   !      * spectral and unsteady modes. For the coarser grid levels the   *
   !      * residual forcing term is taken into account.                   *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Subroutine arguments.
   !
   INTEGER(kind=inttype), INTENT(IN) :: varstart, varend
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: sps, nn, mm, ll, ii, jj, i, j, k, l, m
   REAL(kind=realtype) :: oneoverdt, tmp
   REAL(kind=realtype) :: tmpd
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: ww, wsp, wsp1
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: wwd, wspd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: volsp
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Return immediately of no variables are in the range.
   IF (varend .LT. varstart) THEN
   RETURN
   ELSE
   ! Determine the equation mode and act accordingly.
   SELECT CASE  (equationmode) 
   CASE (steady) 
   ! Steady state computation.
   ! Determine the currently active multigrid level.
   IF (currentlevel .EQ. groundlevel) THEN
   ! Ground level of the multigrid cycle. Initialize the
   ! owned residuals to zero.
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = 0.0
   dw(i, j, k, l) = zero
   END DO
   END DO
   END DO
   END DO
   ELSE
   ! Coarse grid level. Initialize the owned cells to the
   ! residual forcing terms.
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = 0.0
   dw(i, j, k, l) = wr(i, j, k, l)
   END DO
   END DO
   END DO
   END DO
   END IF
   CASE (unsteady) 
   !===========================================================
   ! Unsteady computation.
   ! A further distinction must be made.
   SELECT CASE  (timeintegrationscheme) 
   CASE (explicitrk) 
   ! We are always on the finest grid.
   ! Initialize the residual to zero.
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = 0.0
   dw(i, j, k, l) = zero
   END DO
   END DO
   END DO
   END DO
   CASE (implicitrk) 
   !=======================================================
   CALL TERMINATE('initRes', 'Implicit RK not implemented yet')
   CASE (bdf) 
   !=======================================================
   ! Store the inverse of the physical nonDimensional
   ! time step a bit easier.
   oneoverdt = timeref/deltat
   ! Store the pointer for the variable to be used to compute
   ! the unsteady source term. For a runge-kutta smoother this
   ! is the solution of the zeroth runge-kutta stage. As for
   ! rkStage == 0 this variable is not yet set w is used.
   ! For other smoothers w is to be used as well.
   IF (smoother .EQ. rungekutta .AND. rkstage .GT. 0) THEN
   wwd => wnd
   ww => wn
   ELSE
   wwd => wd
   ww => w
   END IF
   ! Determine the currently active multigrid level.
   IF (currentlevel .EQ. groundlevel) THEN
   ! Ground level of the multigrid cycle. Initialize the
   ! owned cells to the unsteady source term. First the
   ! term for the current time level. Note that in w the
   ! velocities are stored and not the momentum variables.
   ! Therefore the if-statement is present to correct this.
   DO l=varstart,varend
   IF ((l .EQ. ivx .OR. l .EQ. ivy) .OR. l .EQ. ivz) THEN
   ! Momentum variables.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = coeftime(0)*((vold(i, j, k)*ww(i, &
   &                      j, k, l)+vol(i, j, k)*wwd(i, j, k, l))*ww(i, j, k&
   &                      , irho)+vol(i, j, k)*ww(i, j, k, l)*wwd(i, j, k, &
   &                      irho))
   dw(i, j, k, l) = coeftime(0)*vol(i, j, k)*ww(i, j, k&
   &                      , l)*ww(i, j, k, irho)
   END DO
   END DO
   END DO
   ELSE
   ! Non-momentum variables, for which the variable
   ! to be solved is stored; for the flow equations this
   ! is the conservative variable, for the turbulent
   ! equations the primitive variable.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = coeftime(0)*(vold(i, j, k)*ww(i, j&
   &                      , k, l)+vol(i, j, k)*wwd(i, j, k, l))
   dw(i, j, k, l) = coeftime(0)*vol(i, j, k)*ww(i, j, k&
   &                      , l)
   END DO
   END DO
   END DO
   END IF
   END DO
   ! The terms from the older time levels. Here the
   ! conservative variables are stored. In case of a
   ! deforming mesh, also the old volumes must be taken.
   IF (deforming_grid) THEN
   ! Mesh is deforming and thus the volumes can change.
   ! Use the old volumes as well.
   DO m=1,noldlevels
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dw(i, j, k, l) = dw(i, j, k, l) + coeftime(m)*&
   &                        volold(m, i, j, k)*wold(m, i, j, k, l)
   END DO
   END DO
   END DO
   END DO
   END DO
   ELSE
   ! Rigid mesh. The volumes remain constant.
   DO m=1,noldlevels
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = dwd(i, j, k, l) + coeftime(m)*&
   &                        wold(m, i, j, k, l)*vold(i, j, k)
   dw(i, j, k, l) = dw(i, j, k, l) + coeftime(m)*vol(&
   &                        i, j, k)*wold(m, i, j, k, l)
   END DO
   END DO
   END DO
   END DO
   END DO
   END IF
   ! Multiply the time derivative by the inverse of the
   ! time step to obtain the true time derivative.
   ! This is done after the summation has been done, because
   ! otherwise you run into finite accuracy problems for
   ! very small time steps.
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = oneoverdt*dwd(i, j, k, l)
   dw(i, j, k, l) = oneoverdt*dw(i, j, k, l)
   END DO
   END DO
   END DO
   END DO
   ELSE
   ! Coarse grid level. Initialize the owned cells to the
   ! residual forcing term plus a correction for the
   ! multigrid treatment of the time derivative term.
   ! As the velocities are stored instead of the momentum,
   ! these terms must be multiplied by the density.
   tmp = oneoverdt*coeftime(0)
   DO l=varstart,varend
   IF ((l .EQ. ivx .OR. l .EQ. ivy) .OR. l .EQ. ivz) THEN
   ! Momentum variables.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = tmp*(vold(i, j, k)*(ww(i, j, k, l)&
   &                      *ww(i, j, k, irho)-w1(i, j, k, l)*w1(i, j, k, irho&
   &                      ))+vol(i, j, k)*(wwd(i, j, k, l)*ww(i, j, k, irho)&
   &                      +ww(i, j, k, l)*wwd(i, j, k, irho)))
   dw(i, j, k, l) = tmp*vol(i, j, k)*(ww(i, j, k, l)*ww&
   &                      (i, j, k, irho)-w1(i, j, k, l)*w1(i, j, k, irho))
   dw(i, j, k, l) = dw(i, j, k, l) + wr(i, j, k, l)
   END DO
   END DO
   END DO
   ELSE
   ! Non-momentum variables.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = tmp*(vold(i, j, k)*(ww(i, j, k, l)&
   &                      -w1(i, j, k, l))+vol(i, j, k)*wwd(i, j, k, l))
   dw(i, j, k, l) = tmp*vol(i, j, k)*(ww(i, j, k, l)-w1&
   &                      (i, j, k, l))
   dw(i, j, k, l) = dw(i, j, k, l) + wr(i, j, k, l)
   END DO
   END DO
   END DO
   END IF
   END DO
   END IF
   END SELECT
   CASE (timespectral) 
   !===========================================================
   ! Time spectral computation. The time derivative of the
   ! current solution is given by a linear combination of
   ! all other solutions, i.e. a matrix vector product.
   ! First store the section to which this block belongs
   ! in jj.
   jj = sectionid
   ! Determine the currently active multigrid level.
   IF (currentlevel .EQ. groundlevel) THEN
   ! Finest multigrid level. The residual must be
   ! initialized to the time derivative.
   ! Initialize it to zero.
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = 0.0
   dw(i, j, k, l) = zero
   END DO
   END DO
   END DO
   END DO
   ! Loop over the number of terms which contribute
   ! to the time derivative.
   timeloopfine:DO mm=1,ntimeintervalsspectral
   ! Store the pointer for the variable to be used to
   ! compute the unsteady source term and the volume.
   ! Also store in ii the offset needed for vector
   ! quantities.
   wspd => flowdomsd(nn, currentlevel, mm)%w
   wsp => flowdoms(nn, currentlevel, mm)%w
   IF (mm .NE. sps) THEN
   volsp => flowdoms(nn, currentlevel, mm)%vol
   END IF
   !vol => flowDoms(nn,currentLevel,mm)%vol
   ii = 3*(mm-1)
   ! Loop over the number of variables to be set.
   varloopfine:DO l=varstart,varend
   ! Test for a momentum variable.
   IF ((l .EQ. ivx .OR. l .EQ. ivy) .OR. l .EQ. ivz) THEN
   ! Momentum variable. A special treatment is
   ! needed because it is a vector and the velocities
   ! are stored instead of the momentum. Set the
   ! coefficient ll, which defines the row of the
   ! matrix used later on.
   IF (l .EQ. ivx) ll = 3*sps - 2
   IF (l .EQ. ivy) ll = 3*sps - 1
   IF (l .EQ. ivz) ll = 3*sps
   ! Loop over the owned cell centers to add the
   ! contribution from wsp.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Store the matrix vector product with the
   ! velocity in tmp.
   tmpd = dvector(jj, ll, ii+1)*wspd(i, j, k, ivx) + &
   &                      dvector(jj, ll, ii+2)*wspd(i, j, k, ivy) + dvector&
   &                      (jj, ll, ii+3)*wspd(i, j, k, ivz)
   tmp = dvector(jj, ll, ii+1)*wsp(i, j, k, ivx) + &
   &                      dvector(jj, ll, ii+2)*wsp(i, j, k, ivy) + dvector(&
   &                      jj, ll, ii+3)*wsp(i, j, k, ivz)
   ! Update the residual. Note the
   ! multiplication with the density to obtain
   ! the correct time derivative for the
   ! momentum variable.
   IF (mm .EQ. sps) THEN
   dwd(i, j, k, l) = dwd(i, j, k, l) + (tmpd*vol(i, j&
   &                        , k)+tmp*vold(i, j, k))*wsp(i, j, k, irho) + tmp&
   &                        *vol(i, j, k)*wspd(i, j, k, irho)
   dw(i, j, k, l) = dw(i, j, k, l) + tmp*vol(i, j, k)&
   &                        *wsp(i, j, k, irho)
   ELSE
   dwd(i, j, k, l) = dwd(i, j, k, l) + volsp(i, j, k)&
   &                        *(tmpd*wsp(i, j, k, irho)+tmp*wspd(i, j, k, irho&
   &                        ))
   dw(i, j, k, l) = dw(i, j, k, l) + tmp*volsp(i, j, &
   &                        k)*wsp(i, j, k, irho)
   END IF
   END DO
   END DO
   END DO
   ELSE
   ! Scalar variable.  Loop over the owned cells to
   ! add the contribution of wsp to the time
   ! derivative.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   IF (mm .EQ. sps) THEN
   dwd(i, j, k, l) = dwd(i, j, k, l) + dscalar(jj, &
   &                        sps, mm)*(vold(i, j, k)*wsp(i, j, k, l)+vol(i, j&
   &                        , k)*wspd(i, j, k, l))
   dw(i, j, k, l) = dw(i, j, k, l) + dscalar(jj, sps&
   &                        , mm)*vol(i, j, k)*wsp(i, j, k, l)
   ELSE
   dwd(i, j, k, l) = dwd(i, j, k, l) + dscalar(jj, &
   &                        sps, mm)*volsp(i, j, k)*wspd(i, j, k, l)
   dw(i, j, k, l) = dw(i, j, k, l) + dscalar(jj, sps&
   &                        , mm)*volsp(i, j, k)*wsp(i, j, k, l)
   END IF
   END DO
   END DO
   END DO
   END IF
   END DO varloopfine
   END DO timeloopfine
   ELSE
   ! Coarse grid level. Initialize the owned cells to the
   ! residual forcing term plus a correction for the
   ! multigrid treatment of the time derivative term.
   ! Initialization to the residual forcing term.
   DO l=varstart,varend
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = 0.0
   dw(i, j, k, l) = wr(i, j, k, l)
   END DO
   END DO
   END DO
   END DO
   ! Loop over the number of terms which contribute
   ! to the time derivative.
   timeloopcoarse:DO mm=1,ntimeintervalsspectral
   ! Store the pointer for the variable to be used to
   ! compute the unsteady source term and the pointers
   ! for wsp1, the solution when entering this MG level
   ! and for the volume.
   ! Furthermore store in ii the offset needed for
   ! vector quantities.
   wspd => flowdomsd(nn, currentlevel, mm)%w
   wsp => flowdoms(nn, currentlevel, mm)%w
   wsp1 => flowdoms(nn, currentlevel, mm)%w1
   volsp => flowdoms(nn, currentlevel, mm)%vol
   ii = 3*(mm-1)
   ! Loop over the number of variables to be set.
   varloopcoarse:DO l=varstart,varend
   ! Test for a momentum variable.
   IF ((l .EQ. ivx .OR. l .EQ. ivy) .OR. l .EQ. ivz) THEN
   ! Momentum variable. A special treatment is
   ! needed because it is a vector and the velocities
   ! are stored instead of the momentum. Set the
   ! coefficient ll, which defines the row of the
   ! matrix used later on.
   IF (l .EQ. ivx) ll = 3*sps - 2
   IF (l .EQ. ivy) ll = 3*sps - 1
   IF (l .EQ. ivz) ll = 3*sps
   ! Add the contribution of wps to the correction
   ! of the time derivative. The difference between
   ! the current time derivative and the one when
   ! entering this grid level must be added, because
   ! the residual forcing term only takes the spatial
   ! part of the coarse grid residual into account.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Store the matrix vector product with the
   ! momentum in tmp.
   tmpd = dvector(jj, ll, ii+1)*(wspd(i, j, k, irho)*&
   &                      wsp(i, j, k, ivx)+wsp(i, j, k, irho)*wspd(i, j, k&
   &                      , ivx)) + dvector(jj, ll, ii+2)*(wspd(i, j, k, &
   &                      irho)*wsp(i, j, k, ivy)+wsp(i, j, k, irho)*wspd(i&
   &                      , j, k, ivy)) + dvector(jj, ll, ii+3)*(wspd(i, j, &
   &                      k, irho)*wsp(i, j, k, ivz)+wsp(i, j, k, irho)*wspd&
   &                      (i, j, k, ivz))
   tmp = dvector(jj, ll, ii+1)*(wsp(i, j, k, irho)*wsp(&
   &                      i, j, k, ivx)-wsp1(i, j, k, irho)*wsp1(i, j, k, &
   &                      ivx)) + dvector(jj, ll, ii+2)*(wsp(i, j, k, irho)*&
   &                      wsp(i, j, k, ivy)-wsp1(i, j, k, irho)*wsp1(i, j, k&
   &                      , ivy)) + dvector(jj, ll, ii+3)*(wsp(i, j, k, irho&
   &                      )*wsp(i, j, k, ivz)-wsp1(i, j, k, irho)*wsp1(i, j&
   &                      , k, ivz))
   ! Add tmp to the residual. Multiply it by
   ! the volume to obtain the finite volume
   ! formulation of the  derivative of the
   ! momentum.
   dwd(i, j, k, l) = dwd(i, j, k, l) + volsp(i, j, k)*&
   &                      tmpd
   dw(i, j, k, l) = dw(i, j, k, l) + tmp*volsp(i, j, k)
   END DO
   END DO
   END DO
   ELSE
   ! Scalar variable. Loop over the owned cells
   ! to add the contribution of wsp to the correction
   ! of the time derivative.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   dwd(i, j, k, l) = dwd(i, j, k, l) + dscalar(jj, sps&
   &                      , mm)*volsp(i, j, k)*wspd(i, j, k, l)
   dw(i, j, k, l) = dw(i, j, k, l) + dscalar(jj, sps, &
   &                      mm)*volsp(i, j, k)*(wsp(i, j, k, l)-wsp1(i, j, k, &
   &                      l))
   END DO
   END DO
   END DO
   END IF
   END DO varloopcoarse
   END DO timeloopcoarse
   END IF
   END SELECT
   ! Set the residual in the halo cells to zero. This is just
   ! to avoid possible problems. Their values do not matter.
   DO l=varstart,varend
   DO k=0,kb
   DO j=0,jb
   dwd(0, j, k, l) = 0.0
   dw(0, j, k, l) = zero
   dwd(1, j, k, l) = 0.0
   dw(1, j, k, l) = zero
   dwd(ie, j, k, l) = 0.0
   dw(ie, j, k, l) = zero
   dwd(ib, j, k, l) = 0.0
   dw(ib, j, k, l) = zero
   END DO
   END DO
   DO k=0,kb
   DO i=2,il
   dwd(i, 0, k, l) = 0.0
   dw(i, 0, k, l) = zero
   dwd(i, 1, k, l) = 0.0
   dw(i, 1, k, l) = zero
   dwd(i, je, k, l) = 0.0
   dw(i, je, k, l) = zero
   dwd(i, jb, k, l) = 0.0
   dw(i, jb, k, l) = zero
   END DO
   END DO
   DO j=2,jl
   DO i=2,il
   dwd(i, j, 0, l) = 0.0
   dw(i, j, 0, l) = zero
   dwd(i, j, 1, l) = 0.0
   dw(i, j, 1, l) = zero
   dwd(i, j, ke, l) = 0.0
   dw(i, j, ke, l) = zero
   dwd(i, j, kb, l) = 0.0
   dw(i, j, kb, l) = zero
   END DO
   END DO
   END DO
   END IF
   END SUBROUTINE INITRES_BLOCK_D
