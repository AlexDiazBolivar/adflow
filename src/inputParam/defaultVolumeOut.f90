       subroutine defaultVolumeOut
!
!       defaultVolumeOut sets the default set of additional            
!       variables to be written to the solution file; the primitive    
!       variables are always written. This additional set depends on   
!       the governing equations to be solved.                          
!
       use constants 
       use extraOutput
       use inputPhysics, only : equations
       implicit none

       ! First set the variables, which are independent from the
       ! governing equations to be solved.

       volWriteMx       = .false.
       volWriteMy       = .false.
       volWriteMz       = .false.
       volWriteRhoe     = .false.
       volWriteTemp     = .false.
       volWriteCp       = .false.
       volWriteMach     = .false.
       volWriteMachTurb = .false.
       volWriteDist     = .false.
       volWriteVort     = .false.
       volWriteVortx    = .false.
       volWriteVorty    = .false.
       volWriteVortz    = .false.
       volWritePtotloss = .true.
       volWriteResRho   = .true.
       volWriteResMom   = .false.
       volWriteResRhoe  = .false.

       ! Set the values which depend on the equations to be solved.

       select case (equations)
         case (EulerEquations)
           volWriteEddyVis      = .false.
           volWriteRatioEddyVis = .false.
           volWriteResTurb      = .false.

         case (NSEquations)
           volWriteEddyVis      = .false.
           volWriteRatioEddyVis = .false.
           volWriteResTurb      = .false.

         case (RANSEquations)
           volWriteEddyVis      = .true.
           volWriteRatioEddyVis = .true.
           volWriteResTurb      = .true.
       end select

       end subroutine defaultVolumeOut
