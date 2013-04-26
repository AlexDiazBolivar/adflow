   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of saeddyviscosity in reverse (adjoint) mode:
   !   gradient     of useful results: *rev *w *rlv
   !   with respect to varying inputs: *w *rlv
   !   Plus diff mem management of: rev:in w:in rlv:in
   !      ==================================================================
   !      ==================================================================
   SUBROUTINE SAEDDYVISCOSITY_B()
   USE BLOCKPOINTERS_B
   USE PARAMTURB
   USE CONSTANTS
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * saEddyViscosity computes the eddy-viscosity according to the   *
   !      * Spalart-Allmaras model for the block given in blockPointers.   *
   !      * This routine for both the original version as well as the      *
   !      * modified version according to Edwards.                         *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, k
   REAL(kind=realtype) :: chi, chi3, fv1, rnusa, cv13
   REAL(kind=realtype) :: chib, chi3b, fv1b, rnusab
   REAL(kind=realtype) :: tempb0
   REAL(kind=realtype) :: tempb
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Store the cv1^3; cv1 is a constant of the Spalart-Allmaras model.
   cv13 = rsacv1**3
   DO k=kl,2,-1
   DO j=jl,2,-1
   DO i=il,2,-1
   rnusa = w(i, j, k, itu1)*w(i, j, k, irho)
   chi = rnusa/rlv(i, j, k)
   chi3 = chi**3
   fv1 = chi3/(chi3+cv13)
   fv1b = rnusa*revb(i, j, k)
   tempb0 = fv1b/(cv13+chi3)
   chi3b = (1.0_8-chi3/(cv13+chi3))*tempb0
   chib = 3*chi**2*chi3b
   tempb = chib/rlv(i, j, k)
   rnusab = tempb + fv1*revb(i, j, k)
   revb(i, j, k) = 0.0_8
   rlvb(i, j, k) = rlvb(i, j, k) - rnusa*tempb/rlv(i, j, k)
   wb(i, j, k, itu1) = wb(i, j, k, itu1) + w(i, j, k, irho)*rnusab
   wb(i, j, k, irho) = wb(i, j, k, irho) + w(i, j, k, itu1)*rnusab
   END DO
   END DO
   END DO
   END SUBROUTINE SAEDDYVISCOSITY_B