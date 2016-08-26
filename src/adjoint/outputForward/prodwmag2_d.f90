!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of prodwmag2 in forward (tangent) mode (with options i4 dr8 r8):
!   variations   of useful results: *scratch
!   with respect to varying inputs: timeref *w *vol *si *sj *sk
!   plus diff mem management of: w:in scratch:in vol:in si:in sj:in
!                sk:in
!
!       file:          prodwmag2.f90                                   
!       author:        georgi kalitzin, edwin van der weide            
!       starting date: 06-23-2003                                      
!       last modified: 06-12-2005                                      
!
subroutine prodwmag2_d()
!
!       prodwmag2 computes the term:                                   
!          2*oij*oij  with oij=0.5*(duidxj - dujdxi).                  
!       this is equal to the magnitude squared of the vorticity.       
!       it is assumed that the pointer vort, stored in turbmod, is     
!       already set to the correct entry.                              
!
  use constants
  use blockpointers
  use flowvarrefstate
  use section
  use turbmod
  implicit none
!
!      local variables.
!
  integer :: i, j, k, ii
  real(kind=realtype) :: uuy, uuz, vvx, vvz, wwx, wwy
  real(kind=realtype) :: uuyd, uuzd, vvxd, vvzd, wwxd, wwyd
  real(kind=realtype) :: fact, vortx, vorty, vortz
  real(kind=realtype) :: factd, vortxd, vortyd, vortzd
  real(kind=realtype) :: omegax, omegay, omegaz
  real(kind=realtype) :: omegaxd, omegayd, omegazd
!
!       begin execution                                                
!
! determine the non-dimensional wheel speed of this block.
  omegaxd = sections(sectionid)%rotrate(1)*timerefd
  omegax = timeref*sections(sectionid)%rotrate(1)
  omegayd = sections(sectionid)%rotrate(2)*timerefd
  omegay = timeref*sections(sectionid)%rotrate(2)
  omegazd = sections(sectionid)%rotrate(3)*timerefd
  omegaz = timeref*sections(sectionid)%rotrate(3)
  scratchd = 0.0_8
! loop over the cell centers of the given block. it may be more
! efficient to loop over the faces and to scatter the gradient,
! but in that case the gradients for u, v and w must be stored.
! in the current approach no extra memory is needed.
  do k=2,kl
    do j=2,jl
      do i=2,il
! compute the necessary derivatives of u in the cell center.
! use is made of the fact that the surrounding normals sum up
! to zero, such that the cell i,j,k does not give a
! contribution. the gradient is scaled by a factor 2*vol.
        uuyd = wd(i+1, j, k, ivx)*si(i, j, k, 2) + w(i+1, j, k, ivx)*sid&
&         (i, j, k, 2) - wd(i-1, j, k, ivx)*si(i-1, j, k, 2) - w(i-1, j&
&         , k, ivx)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivx)*sj(i, j, k, 2&
&         ) + w(i, j+1, k, ivx)*sjd(i, j, k, 2) - wd(i, j-1, k, ivx)*sj(&
&         i, j-1, k, 2) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 2) + wd(i, j&
&         , k+1, ivx)*sk(i, j, k, 2) + w(i, j, k+1, ivx)*skd(i, j, k, 2)&
&         - wd(i, j, k-1, ivx)*sk(i, j, k-1, 2) - w(i, j, k-1, ivx)*skd(&
&         i, j, k-1, 2)
        uuy = w(i+1, j, k, ivx)*si(i, j, k, 2) - w(i-1, j, k, ivx)*si(i-&
&         1, j, k, 2) + w(i, j+1, k, ivx)*sj(i, j, k, 2) - w(i, j-1, k, &
&         ivx)*sj(i, j-1, k, 2) + w(i, j, k+1, ivx)*sk(i, j, k, 2) - w(i&
&         , j, k-1, ivx)*sk(i, j, k-1, 2)
        uuzd = wd(i+1, j, k, ivx)*si(i, j, k, 3) + w(i+1, j, k, ivx)*sid&
&         (i, j, k, 3) - wd(i-1, j, k, ivx)*si(i-1, j, k, 3) - w(i-1, j&
&         , k, ivx)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivx)*sj(i, j, k, 3&
&         ) + w(i, j+1, k, ivx)*sjd(i, j, k, 3) - wd(i, j-1, k, ivx)*sj(&
&         i, j-1, k, 3) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 3) + wd(i, j&
&         , k+1, ivx)*sk(i, j, k, 3) + w(i, j, k+1, ivx)*skd(i, j, k, 3)&
&         - wd(i, j, k-1, ivx)*sk(i, j, k-1, 3) - w(i, j, k-1, ivx)*skd(&
&         i, j, k-1, 3)
        uuz = w(i+1, j, k, ivx)*si(i, j, k, 3) - w(i-1, j, k, ivx)*si(i-&
&         1, j, k, 3) + w(i, j+1, k, ivx)*sj(i, j, k, 3) - w(i, j-1, k, &
&         ivx)*sj(i, j-1, k, 3) + w(i, j, k+1, ivx)*sk(i, j, k, 3) - w(i&
&         , j, k-1, ivx)*sk(i, j, k-1, 3)
! idem for the gradient of v.
        vvxd = wd(i+1, j, k, ivy)*si(i, j, k, 1) + w(i+1, j, k, ivy)*sid&
&         (i, j, k, 1) - wd(i-1, j, k, ivy)*si(i-1, j, k, 1) - w(i-1, j&
&         , k, ivy)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivy)*sj(i, j, k, 1&
&         ) + w(i, j+1, k, ivy)*sjd(i, j, k, 1) - wd(i, j-1, k, ivy)*sj(&
&         i, j-1, k, 1) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 1) + wd(i, j&
&         , k+1, ivy)*sk(i, j, k, 1) + w(i, j, k+1, ivy)*skd(i, j, k, 1)&
&         - wd(i, j, k-1, ivy)*sk(i, j, k-1, 1) - w(i, j, k-1, ivy)*skd(&
&         i, j, k-1, 1)
        vvx = w(i+1, j, k, ivy)*si(i, j, k, 1) - w(i-1, j, k, ivy)*si(i-&
&         1, j, k, 1) + w(i, j+1, k, ivy)*sj(i, j, k, 1) - w(i, j-1, k, &
&         ivy)*sj(i, j-1, k, 1) + w(i, j, k+1, ivy)*sk(i, j, k, 1) - w(i&
&         , j, k-1, ivy)*sk(i, j, k-1, 1)
        vvzd = wd(i+1, j, k, ivy)*si(i, j, k, 3) + w(i+1, j, k, ivy)*sid&
&         (i, j, k, 3) - wd(i-1, j, k, ivy)*si(i-1, j, k, 3) - w(i-1, j&
&         , k, ivy)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivy)*sj(i, j, k, 3&
&         ) + w(i, j+1, k, ivy)*sjd(i, j, k, 3) - wd(i, j-1, k, ivy)*sj(&
&         i, j-1, k, 3) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 3) + wd(i, j&
&         , k+1, ivy)*sk(i, j, k, 3) + w(i, j, k+1, ivy)*skd(i, j, k, 3)&
&         - wd(i, j, k-1, ivy)*sk(i, j, k-1, 3) - w(i, j, k-1, ivy)*skd(&
&         i, j, k-1, 3)
        vvz = w(i+1, j, k, ivy)*si(i, j, k, 3) - w(i-1, j, k, ivy)*si(i-&
&         1, j, k, 3) + w(i, j+1, k, ivy)*sj(i, j, k, 3) - w(i, j-1, k, &
&         ivy)*sj(i, j-1, k, 3) + w(i, j, k+1, ivy)*sk(i, j, k, 3) - w(i&
&         , j, k-1, ivy)*sk(i, j, k-1, 3)
! and for the gradient of w.
        wwxd = wd(i+1, j, k, ivz)*si(i, j, k, 1) + w(i+1, j, k, ivz)*sid&
&         (i, j, k, 1) - wd(i-1, j, k, ivz)*si(i-1, j, k, 1) - w(i-1, j&
&         , k, ivz)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivz)*sj(i, j, k, 1&
&         ) + w(i, j+1, k, ivz)*sjd(i, j, k, 1) - wd(i, j-1, k, ivz)*sj(&
&         i, j-1, k, 1) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 1) + wd(i, j&
&         , k+1, ivz)*sk(i, j, k, 1) + w(i, j, k+1, ivz)*skd(i, j, k, 1)&
&         - wd(i, j, k-1, ivz)*sk(i, j, k-1, 1) - w(i, j, k-1, ivz)*skd(&
&         i, j, k-1, 1)
        wwx = w(i+1, j, k, ivz)*si(i, j, k, 1) - w(i-1, j, k, ivz)*si(i-&
&         1, j, k, 1) + w(i, j+1, k, ivz)*sj(i, j, k, 1) - w(i, j-1, k, &
&         ivz)*sj(i, j-1, k, 1) + w(i, j, k+1, ivz)*sk(i, j, k, 1) - w(i&
&         , j, k-1, ivz)*sk(i, j, k-1, 1)
        wwyd = wd(i+1, j, k, ivz)*si(i, j, k, 2) + w(i+1, j, k, ivz)*sid&
&         (i, j, k, 2) - wd(i-1, j, k, ivz)*si(i-1, j, k, 2) - w(i-1, j&
&         , k, ivz)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivz)*sj(i, j, k, 2&
&         ) + w(i, j+1, k, ivz)*sjd(i, j, k, 2) - wd(i, j-1, k, ivz)*sj(&
&         i, j-1, k, 2) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 2) + wd(i, j&
&         , k+1, ivz)*sk(i, j, k, 2) + w(i, j, k+1, ivz)*skd(i, j, k, 2)&
&         - wd(i, j, k-1, ivz)*sk(i, j, k-1, 2) - w(i, j, k-1, ivz)*skd(&
&         i, j, k-1, 2)
        wwy = w(i+1, j, k, ivz)*si(i, j, k, 2) - w(i-1, j, k, ivz)*si(i-&
&         1, j, k, 2) + w(i, j+1, k, ivz)*sj(i, j, k, 2) - w(i, j-1, k, &
&         ivz)*sj(i, j-1, k, 2) + w(i, j, k+1, ivz)*sk(i, j, k, 2) - w(i&
&         , j, k-1, ivz)*sk(i, j, k-1, 2)
! compute the three components of the vorticity vector.
! substract the part coming from the rotating frame.
        factd = -(half*vold(i, j, k)/vol(i, j, k)**2)
        fact = half/vol(i, j, k)
        vortxd = factd*(wwy-vvz) + fact*(wwyd-vvzd) - two*omegaxd
        vortx = fact*(wwy-vvz) - two*omegax
        vortyd = factd*(uuz-wwx) + fact*(uuzd-wwxd) - two*omegayd
        vorty = fact*(uuz-wwx) - two*omegay
        vortzd = factd*(vvx-uuy) + fact*(vvxd-uuyd) - two*omegazd
        vortz = fact*(vvx-uuy) - two*omegaz
! compute the magnitude squared of the vorticity.
        scratchd(i, j, k, ivort) = 2*vortx*vortxd + 2*vorty*vortyd + 2*&
&         vortz*vortzd
        scratch(i, j, k, ivort) = vortx**2 + vorty**2 + vortz**2
      end do
    end do
  end do
end subroutine prodwmag2_d
