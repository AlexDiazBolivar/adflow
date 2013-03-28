   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.7 (r4786) - 21 Feb 2013 15:53
   !
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          block.f90                                       *
   !      * Author:        Edwin van der Weide, Steve Repsher,             *
   !      *                Seonghyeon Hahn                                 *
   !      * Starting date: 12-19-2002                                      *
   !      * Last modified: 11-21-2007                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   MODULE BLOCK_T
   USE CONSTANTS
   IMPLICIT NONE
   SAVE 
   !
   !      ******************************************************************
   !      *                                                                *
   !      * This module contains the definition of the derived data type   *
   !      * for block, which is the basic building block for this code.    *
   !      *                                                                *
   !      * Apart from the derived data type for block, this module also   *
   !      * contains the actual array for storing the blocks and the       *
   !      * number of blocks stored on this processor.                     *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Parameters used for coarsening definition.
   INTEGER(kind=portype), PARAMETER :: leftstarted=-1
   INTEGER(kind=portype), PARAMETER :: regular=0
   INTEGER(kind=portype), PARAMETER :: rightstarted=1
   ! Parameters used for subsonic inlet bc treatment.
   INTEGER(kind=inttype), PARAMETER :: nosubinlet=0
   INTEGER(kind=inttype), PARAMETER :: totalconditions=1
   INTEGER(kind=inttype), PARAMETER :: massflow=2
   ! tau(:,:,6): The 6 components of the viscous stress tensor.
   !             The first 2 dimensions of these arrays are equal
   !             to the dimenions of the cell subface without any
   !             halo cell. Consequently the starting index is
   !             arbitrary, such that no offset computation is
   !             needed when the arrays are accessed.
   ! q(:,:,3):   Same story for the heat flux vector.
   ! uTau(:,:):  And for the friction velocity.
   !
   !      ******************************************************************
   !      *                                                                *
   !      * The definition of the derived data type visc_subface_type,     *
   !      * which stores the viscous stress tensor and heat flux vector.   *
   !      * In this way it is avoided that these quantities must be        *
   !      * recomputed for the viscous forces and postprocessing. This     *
   !      * saves both time and a considerable amount of code.             *
   !      *                                                                *
   !      ******************************************************************
   !
   TYPE VISCSUBFACETYPE
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: tau, q
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: utau
   END TYPE VISCSUBFACETYPE
   TYPE VISCSUBFACETYPE_T
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: tau
   END TYPE VISCSUBFACETYPE_T
   ! inBeg, inEnd: Node range in the first direction of the subface
   ! jnBeg, jnEnd: Idem in the second direction.
   ! icBeg, icEnd: Cell range in the first direction of the subface
   ! jcBeg, jcEnd: Idem in the second direction.
   ! norm(:,:,3):  The unit normal; it points out of the domain.
   ! rface(:,:):   Velocity of the face in the direction of the
   !               outward pointing normal. only allocated for
   !               the boundary conditions that need this info.
   ! subsonicInletTreatment: which boundary condition treatment
   !                         to use for subsonic inlets; either
   !                         totalConditions or massFlow.
   ! uSlip(:,:,3):  the 3 components of the velocity vector on
   !                a viscous wall. 
   ! TNS_Wall(:,:): Wall temperature for isothermal walls.
   ! ptInlet(:,:):       Total pressure at subsonic inlets.
   ! ttInlet(:,:):       Total temperature at subsonic inlets.
   ! htInlet(:,:):       Total enthalpy at subsonic inlets.
   ! flowXDirInlet(:,:): X-direction of the flow for subsonic
   !                     inlets.
   ! flowYDirInlet(:,:): Idem in y-direction.
   ! flowZDirInlet(:,:): Idem in z-direction.
   ! turbInlet(:,:,nt1:nt2): Turbulence variables at inlets,
   !                         either subsonic or supersonic.
   ! rho(:,:):  density; used for multiple bc's.
   ! velX(:,:): x-velocity; used for multiple bc's.
   ! velY(:,:): y-velocity; used for multiple bc's.
   ! velZ(:,:): z-velocity; used for multiple bc's.
   ! ps(:,:):   static pressure; used for multiple bc's.
   !
   !      ******************************************************************
   !      *                                                                *
   !      * The definition of the derived data type BCDataType, which      *
   !      * stores the prescribed data of boundary faces as well as unit   *
   !      * normals. For all the arrays the first two dimensions equal the *
   !      * dimensions of the subface, possibly extended with halo cells.  *
   !      * Consequently the starting index is arbitrary, such that no     *
   !      * offset computation is needed when the array is accessed.       *
   !      *                                                                *
   !      ******************************************************************
   !
   TYPE BCDATATYPE
   INTEGER(kind=inttype) :: inbeg, inend, jnbeg, jnend
   INTEGER(kind=inttype) :: icbeg, icend, jcbeg, jcend
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: norm
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rface
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: f, m
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: fmnodeindex, &
   &      fmcellindex
   INTEGER(kind=inttype) :: subsonicinlettreatment
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: uslip
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: tns_wall
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: ptinlet, ttinlet&
   &      , htinlet
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: flowxdirinlet
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: flowydirinlet
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: flowzdirinlet
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: turbinlet
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rho
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: velx
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: vely
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: velz
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: ps
   END TYPE BCDATATYPE
   TYPE BCDATATYPE_T
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: norm
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rface
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: f
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: m
   END TYPE BCDATATYPE_T
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Block dimensions and orientation.                            *
   !        *                                                              *
   !        ****************************************************************
   !
   !  nx, ny, nz - Block integer dimensions for no halo cell based
   !               quantities.
   !  il, jl, kl - Block integer dimensions for no halo node based
   !               quantities.
   !  ie, je, ke - Block integer dimensions for single halo
   !               cell-centered quantities.
   !  ib, jb, kb - Block integer dimensions for double halo
   !               cell-centered quantities.
   ! rightHanded - Whether or not the block is a right handed.
   !               If not right handed it is left handed of course.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Block boundary conditions.                                   *
   !        *                                                              *
   !        ****************************************************************
   !
   !  nSubface             - Number of subfaces on this block.
   !  n1to1                - Number of 1 to 1 block boundaries.
   !  nBocos               - Number of physical boundary subfaces.
   !  nViscBocos           - Number of viscous boundary subfaces.
   !  BCType(:)            - Boundary condition type for each
   !                         subface. See the module BCTypes for
   !                         the possibilities.
   !  BCFaceID(:)          - Block face location of each subface.
   !                         possible values are: iMin, iMax, jMin,
   !                         jMax, kMin, kMax. see also module
   !                         BCTypes.
   !  nNodesSubface        - Total nuber of nodes on this subface.
   !                         Added for the integrated warping
   !                         algorithm(used in synchronizeFaces)
   !  cgnsSubface(:)       - The subface in the corresponding cgns
   !                         block. As cgns distinguishes between
   !                         boundary and internal boundaries, the
   !                         BCType of the subface is needed to
   !                         know which one to take.
   !  inBeg(:), inEnd(:)   - Lower and upper limits for the nodes
   !  jnBeg(:), jnEnd(:)     in each of the index directions on a
   !  knBeg(:), knEnd(:)     given subface. Note that one of these
   !                         indices will not change since we will
   !                         be moving on a face.
   !  dinBeg(:), dinEnd(:) - Lower and upper limits for the nodes
   !  djnBeg(:), djnEnd(:)   in the each of the index directions
   !  dknBeg(:), dknEnd(:)   of the donor subface for this
   !                         particular subface. Note that one of
   !                         these indices will not change since we
   !                         will be moving on a face.
   !  icBeg(:), icEnd(:)   - Lower and upper limits for the cells
   !  jcBeg(:), jcEnd(:)     in each of the index directions for
   !  kcBeg(:), kcEnd(:)     the subface. The cells indicated by
   !                         this range are halo cells (the 
   !                         constant index) adjacent to the face.
   !                         a possible overlap outside the block
   !                         is stored.
   !  neighBlock(:)        - Local block number to which this
   !                         subface connects. This value is set to
   !                         zero if this subface is not connected
   !                         to another block.
   !  neighProc(:)         - Processor number where the neighbor
   !                         block is stored. This value is set to
   !                         -1 if this subface is not connected
   !                         to another block.
   !  l1(:), l2(:),        - Short hand for the transformation
   !  l3(:)                  matrix between this subface and the
   !                         neighbor block. These values are set
   !                         to zero if this subface is not
   !                         connected to another block.
   !  groupNum(:)          - Group number to which this subface
   !                         belongs. If this subface does not
   !                         belong to any group, the corresponding
   !                         entry in this array is zeroed out. If
   !                         the subface belongs to a sliding mesh
   !                         interface the absolute value of 
   !                         groupNum contains the number of the
   !                         sliding mesh interface. One side of
   !                         the interface gets a positive number,
   !                         the other side a negative one.
   !
   !-- eran-CBD start
   !
   ! idWBC(:)                Wall family locator for components
   !                         forces/moment contribution break-down
   !  contributeToForce      Defines if a certain surfac family contributes to forces
   !                         and moments
   !
   !-- eran-CBD ends
   !
   !-- eran-CBD
   ! eran-cbd
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Overset boundary (fringe) cells and blanked cells.           *
   !        *                                                              *
   !        ****************************************************************
   !
   !  iblank(0:Ib,0:jb,0:kb) - stores an integer for every cell of
   !                           this block, including halos. The
   !                           following convention is used:
   !                           + field = 1
   !                           + hole = 0
   !                           + fringe >= 9 preprocessing
   !                                     = 0 solver
   !                           + oversetOuterBound boco = -1
   !                           + any other boco halos = 2
   !  nHoles                 - number of owned hole cells.
   !  nCellsOverset          - number of owned overset cells with
   !                           donors.
   !  nCellsOversetAll       - total number of overset cells
   !                           including fringe from 1-to-1 halos
   !                           and orphans.
   !  nOrphans               - number of orphans (boundary cells
   !                           without donors).
   !  ibndry(3,..)           - indices for each overset cell.
   !  idonor(3,..)           - donor indices for each overset cell.
   !  overint(3,..)          - interpolants for the donor stencil.
   !  neighBlockOver(..)     - local block number to which donor
   !                           cell belongs.
   !  neighProcOver(..)      - processor number where the neighbor
   !                           block is stored.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Boundary data for the boundary subfaces.                     *
   !        *                                                              *
   !        ****************************************************************
   !
   ! BCData(nBocos): The boundary data for each of the boundary
   !                 subfaces.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * The stress tensor and heat flux vector at viscous wall faces *
   !        * as well as the face pointers to these viscous wall faces.    *
   !        *                                                              *
   !        ****************************************************************
   !
   ! viscSubface(nViscBocos):    Storage for the viscous stress
   !                             tensor and heat flux vector for
   !                             the viscous subfaces.
   ! viscIMinPointer(2:jl,2:kl): Pointer to viscous subface for 
   !                             the iMin block face. If the face
   !                             is not part of a viscous subface
   !                             this value is set to 0.
   ! viscIMaxPointer(2:jl,2:kl): Idem for iMax block face.
   ! viscJMinPointer(2:il,2:kl): Idem for jMin block face.
   ! viscJMaxPointer(2:il,2:kl): Idem for jmax block face.
   ! viscKMinPointer(2:il,2:jl): Idem for kMin block face.
   ! viscKMaxPointer(2:il,2:jl): Idem for kMax block face.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Mesh related variables.                                      *
   !        *                                                              *
   !        ****************************************************************
   !
   !  x(0:ie,0:je,0:ke,3)  - xyz locations of grid points in block.
   !  xInit(0:ie,0:je,0:ke,3) - initial xyz locations of grid points
   !                         in block. Used in mesh warping.
   !  xOld(nOld,:,:,:,:)   - Coordinates on older time levels;
   !                         only needed for unsteady problems on
   !                         deforming grids. Only allocated on
   !                         the finest grid level. The blank
   !                         dimensions are equal to the dimensions
   !                         of x.
   !  sI(0:ie,1:je,1:ke,3) - Projected areas in the i-coordinate
   !                         direction. Normals point in the
   !                         direction of increasing i.
   !  sJ(1:ie,0:je,1:ke,3) - Projected areas in the j-coordinate
   !                         direction. Normals point in the
   !                         direction of increasing j.
   !  sK(1:ie,1:je,0:ke,3) - Projected areas in the k-coordinate
   !                         direction. Normals point in the
   !                         direction of increasing k.
   !  vol(0:ib,0:jb,0:kb)  - Cell volumes. The second level halo
   !                         is present for a multigrid option.
   !  volOld(nold,2:il,..) - Volumes on older time levels; only
   !                         needed for unsteady problems on
   !                         deforming grids. Only allocated on
   !                         the finest grid level.
   !  uv(2,2:il,2:jl,2:kl) - Parametric location on elemID for each cell. 
   !                         Only used for fast wall distance calcs. 
   ! elemID(2:il,2:jl,2:kl)- Element ID each face is attached it
   !  porI(1:il,2:jl,2:kl) - Porosity in the i direction.
   !  porJ(2:il,1:jl,2:kl) - Porosity in the j direction.
   !  porK(2:il,2:jl,1:kl) - Porosity in the k direction.
   !
   !  indFamilyI(:,:,:)  - Index of the i-face in the arrays
   !                       to compute the local mass flow
   !                       for a family or sliding mesh interface.
   !                       Dimension is (1:il,2:jl,2:kl).
   !  indFamilyJ(:,:,:)  - Idem for the j-faces.
   !                       Dimension is (2:il,1:jl,2:kl).
   !  indFamilyK(:,:,:)  - Idem for the k-faces.
   !                       Dimension is (2:il,2:jl,1:kl)
   !  factFamilyI(:,:,:) - Corresponding factor to make sure
   !                       that the massflow is defined positive
   !                       when it enters the block and to define
   !                       the mass flow of the entire wheel
   !                       instead of a sector. Hence the possible
   !                       values or -nSlices and nSlices, where
   !                       nSlices or the number of sections to
   !                       obtain the full wheel.
   !  factFamilyJ(:,:,:) - Idem for the j-faces.
   !  factFamilyK(:,:,:) - Idem for the k-faces.
   !
   !  rotMatrixI(:,:,:,:,:) - Rotation matrix of the i-faces to
   !                          transform the velocity components
   !                          from Cartesian to local cylindrical.
   !                          This is needed only for problems with
   !                          rotational periodicity in combination
   !                          with an upwind scheme.
   !                          Dimension is (1:il,2:jl,2:kl,3,3).
   !  rotMatrixJ(:,:,:,:,:) - Idem for the j-faces.
   !                          Dimension is (2:il,1:jl,2:kl,3,3).
   !  rotMatrixK(:,:,:,:,:) - Idem for the k-faces.
   !                          Dimension is (2:il,2:jl,1:kl,3,3).
   !
   !  blockIsMoving      - Whether or not the block is moving.
   !  addGridVelocities  - Whether or not the face velocities
   !                       are allocated and set.
   !  sFaceI(0:ie,je,ke) - Dot product of the face velocity and
   !                       the normal in i-direction.
   !  sFaceJ(ie,0:je,ke) - Idem in j-direction.
   !  sFaceK(ie,je,0:ke) - Idem in k-direction.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Flow variables.                                              *
   !        *                                                              *
   !        ****************************************************************
   !
   ! w(0:ib,0:jb,0:kb,1:nw)       - The set of independent variables
   !                                w(i,j,k,1:nwf) flow field
   !                                variables, which are rho, u, 
   !                                v, w and rhoE. In other words
   !                                the velocities  are stored and
   !                                not the momentum!!!!
   !                                w(i,j,k,nt1:nt2) turbulent 
   !                                variables; also the primitive
   !                                variables are stored.
   ! wOld(nOld,2:il,2:jl,2:kl,nw) - Solution on older time levels,
   !                                needed for the time integration
   !                                for unsteady problems. In
   !                                constrast to w, the conservative
   !                                variables are stored in wOld for
   !                                the flow variables; the turbulent
   !                                variables are always the
   !                                primitive ones.
   !                                Only allocated on the finest
   !                                mesh.
   ! p(0:ib,0:jb,0:kb)            - Static pressure.
   ! gamma(0:ib,0:jb,0:kb)        - Specific heat ratio; only
   !                                allocated on the finest grid.
   ! rlv(0:ib,0:jb,0:kb)          - Laminar viscosity; only
   !                                allocated on the finest mesh
   !                                and only for viscous problems.
   ! rev(0:ib,0:jb,0:kb)          - Eddy viscosity; only
   !                                allocated rans problems with
   !                                eddy viscosity models.
   ! s(1:ie,1:je,1:ke,3)          - Mesh velocities of the cell
   !                                centers; only for moving mesh
   !                                problems.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Residual and multigrid variables.                            *
   !        *                                                              *
   !        ****************************************************************
   !
   ! dw(0:ib,0:jb,0:kb,1:nw)   - Values of convective and combined
   !                             flow residuals. Only allocated on
   !                             the finest mesh.
   ! fw(0:ib,0:jb,0:kb,1:nwf)  - values of artificial dissipation
   !                             and viscous residuals.
   !                             Only allocated on the finest mesh.
   ! dwOldRK(:,2:il,2:jl,2:kl,nw) - Old residuals for the time
   !                                accurate Runge-Kutta schemes.
   !                                The first dimension is
   !                                nRKStagesUnsteady - 1.Only
   !                                allocated on the finest level
   !                                and only in unsteady mode for
   !                                Runge-Kutta schemes.
   ! w1(1:ie,1:je,1:ke,1:nMGVar) - Values of the mg variables
   !                               upon first entry to a coarser
   !                               mesh; only allocated on the
   !                               coarser grids. The variables
   !                               used to compute the multigrid
   !                               corrections are rho, u, v, w
   !                               and p; the rhoE value is used
   !                               for unsteady problems only.
   ! p1(1:ie,1:je,1:ke)          - Value of the pressure upon
   !                               first entry to a coarser grid;
   !                               only allocated on the coarser
   !                               grids.
   ! wr(2:il,2:jl,2:kl,1:nMGVar) - Multigrid forcing terms; only 
   !                               allocated on the coarser grids.
   !                               The forcing term of course
   !                               contains conservative residuals,
   !                               at least for the flow variables.
   ! mgIFine(2:il,2) - The two fine grid i-cells used for the
   !                   restriction of the solution and residual to
   !                   the coarse grid. Only on the coarser grids.
   ! mgJFine(2:jl,2) - Idem for j-cells.
   ! mgKFine(2:kl,2) - Idem for k-cells.
   ! mgIWeight(2:il) - Weight for the residual restriction in
   !                   in i-direction. Value is either 0.5 or 1.0,
   !                   depending whether mgIFine(,1) is equal to
   !                   or differs from mgIFine(,2).
   ! mgJWeight(2:jl) - Idem for weights in j-direction.
   ! mgKWeight(2:kl) - Idem for weights in k-direction.
   ! mgICoarse(2:il,2) - The two coarse grid i-cells used for the
   !                     interpolation of the correction to the
   !                     fine grid. Not on the coarsest grid.
   ! mgJCoarse(2:jl,2) - Idem for j-cells.
   ! mgKCoarse(2:kl,2) - Idem for k-cells.
   ! iCoarsened - How this block was coarsened in i-direction.
   ! jCoarsened - How this block was coarsened in j-direction.
   ! kCoarsened - How this block was coarsened in k-direction.
   ! iCo: Indicates whether or not i grid lines are present on the
   !      coarse grid; not allocated for the coarsest grid.
   ! jCo: Idem in j-direction.
   ! kCo: Idem in k-direction.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Time-stepping and spectral radii variables.                  *
   !        * only allocated on the finest grid.                           *
   !        *                                                              *
   !        ****************************************************************
   !
   ! wn(2:il,2:jl,2:kl,1:nMGVar) - Values of the update variables
   !                               at the beginning of the RungeKutta
   !                               iteration. Only allocated for
   !                               RungeKutta smoother.
   ! pn(2:il,2:jl,2:kl)          - The pressure for the RungeKutta
   !                               smoother.
   ! dtl(1:ie,1:je,1:ke)         - Time step
   ! radI(1:ie,1:je,1:ke)        - Spectral radius in i-direction.
   ! radJ(1:ie,1:je,1:ke)        - Spectral radius in j-direction.
   ! radK(1:ie,1:je,1:ke)        - Spectral radius in k-direction.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Turbulence model variables.                                  *
   !        *                                                              *
   !        ****************************************************************
   !
   ! d2Wall(2:il,2:jl,2:kl) - Distance from the center of the cell
   !                          to the nearest viscous wall.
   ! bmti1(je,ke,nt1:nt2,nt1:nt2): Matrix used for the implicit
   !                               boundary condition treatment of
   !                               the turbulence equations at the
   !                               iMin boundary. Only allocated on
   !                               the finest level and for the 1st
   !                               spectral solution.
   ! bmti2(je,ke,nt1:nt2,nt1:nt2): Idem for the iMax boundary.
   ! bmtj1(ie,ke,nt1:nt2,nt1:nt2): Idem for the jMin boundary.
   ! bmtj2(ie,ke,nt1:nt2,nt1:nt2): Idem for the jMax boundary.
   ! bmtk1(ie,je,nt1:nt2,nt1:nt2): Idem for the kMin boundary.
   ! bmtk2(ie,je,nt1:nt2,nt1:nt2): Idem for the kMax boundary.
   ! bvti1(je,ke,nt1:nt2): RHS vector used for the implicit
   !                       boundary condition treatment of the
   !                       turbulence equations at the iMin
   !                       boundary. Only allocated on the finest
   !                       level and for the 1st spectral solution.
   ! bvti2(je,ke,nt1:nt2): Idem for the iMax boundary.
   ! bvtj1(ie,ke,nt1:nt2): Idem for the jMin boundary.
   ! bvtj2(ie,ke,nt1:nt2): Idem for the jMax boundary.
   ! bvti2(je,ke,nt1:nt2): Idem for the iMax boundary.
   ! bvtk1(ie,ke,nt1:nt2): Idem for the kMin boundary.
   ! bvtk2(ie,ke,nt1:nt2): idem for the kMax boundary.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Relation to the original cgns grid.                          *
   !        *                                                              *
   !        ****************************************************************
   !
   ! sectionID      - The section of the grid this block belongs to.
   ! cgnsBlockID    - Block/zone number of the cgns grid to which
   !                  this block is related.
   ! iBegOr, iEndOr - Range of points of this block in the
   ! jBegOr, jEndOr   corresponding cgns block, i.e. for this block
   ! kBegOr, kEndOr   iBegOr <= i <= iEndOr, jBegOr <= j <= jEndOr, 
   !                  kBegOr <= k <= kEndOr.
   !                  It is of course possible that the entire
   !                  block is stored.
   !
   !        ****************************************************************
   !        *                                                              *
   !        * Adjoint solver variables.                                    *
   !        *                                                              *
   !        ****************************************************************
   !
   ! globalNode(ib:ie,jb:je,kb:ke):  Global node numbering.
   ! globalCell(0:ib,0:jb,0:kb):     Global cell numbering.
   ! color(0:ib,0:jb,0:kb)     :     Temporary coloring array used for 
   !                                 forward mode AD/FD calculations
   !      ******************************************************************
   !      *                                                                *
   !      * The definition of the derived data type block_type, which      *
   !      * stores dimensions, coordinates, solution, etc.                 *
   !      *                                                                *
   !      ******************************************************************
   !
   TYPE BLOCKTYPE
   INTEGER(kind=inttype) :: nx, ny, nz
   INTEGER(kind=inttype) :: il, jl, kl
   INTEGER(kind=inttype) :: ie, je, ke
   INTEGER(kind=inttype) :: ib, jb, kb
   LOGICAL :: righthanded
   INTEGER(kind=inttype) :: nsubface, n1to1, nbocos, nviscbocos
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: bctype
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: bcfaceid
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: nnodessubface
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: cgnssubface
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: inbeg, inend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: jnbeg, jnend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: knbeg, knend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: dinbeg, dinend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: djnbeg, djnend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: dknbeg, dknend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: icbeg, icend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: jcbeg, jcend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: kcbeg, kcend
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighblock
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighproc
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: l1, l2, l3
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: groupnum
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: idwbc
   LOGICAL, DIMENSION(:), POINTER :: contributetoforce
   INTEGER(kind=inttype) :: ncellsoverset, ncellsoversetall
   INTEGER(kind=inttype) :: nholes, norphans
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: iblank
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: ibndry
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: idonor
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: overint
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighblockover
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: neighprocover
   TYPE(BCDATATYPE), DIMENSION(:), POINTER :: bcdata
   TYPE(VISCSUBFACETYPE), DIMENSION(:), POINTER :: viscsubface
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visciminpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscimaxpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscjminpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: viscjmaxpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visckminpointer
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: visckmaxpointer
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: x, xtmp
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: xold
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: si, sj, sk
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: vol
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: volold
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: uv
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: elemid
   INTEGER(kind=portype), DIMENSION(:, :, :), POINTER :: pori, porj, &
   &      pork
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: indfamilyi, &
   &      indfamilyj, indfamilyk
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: factfamilyi&
   &      , factfamilyj, factfamilyk
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: &
   &      rotmatrixi, rotmatrixj, rotmatrixk
   LOGICAL :: blockismoving, addgridvelocities
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: sfacei, sfacej&
   &      , sfacek
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: w, wtmp
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: dw_deriv
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: wold
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: p, ptmp, gamma
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: rlv, rev
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: s
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: p1
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: dw, fw
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: dwtmp, &
   &      dwtmp2
   REAL(kind=realtype), DIMENSION(:, :, :, :, :), POINTER :: dwoldrk
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: w1, wr
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgifine
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgjfine
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgkfine
   REAL(kind=realtype), DIMENSION(:), POINTER :: mgiweight
   REAL(kind=realtype), DIMENSION(:), POINTER :: mgjweight
   REAL(kind=realtype), DIMENSION(:), POINTER :: mgkweight
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgicoarse
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgjcoarse
   INTEGER(kind=inttype), DIMENSION(:, :), POINTER :: mgkcoarse
   INTEGER(kind=portype) :: icoarsened, jcoarsened, kcoarsened
   LOGICAL, DIMENSION(:), POINTER :: ico, jco, kco
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: wn
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: pn
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: dtl
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: radi, radj, &
   &      radk
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: d2wall, &
   &      filterdes
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmti1, &
   &      bmti2
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtj1, &
   &      bmtj2
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: bmtk1, &
   &      bmtk2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvti1, bvti2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvtj1, bvtj2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: bvtk1, bvtk2
   INTEGER(kind=inttype) :: cgnsblockid, sectionid
   INTEGER(kind=inttype) :: ibegor, iendor, jbegor, jendor
   INTEGER(kind=inttype) :: kbegor, kendor
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: globalnode
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: globalcell
   INTEGER(kind=inttype), DIMENSION(:, :, :), POINTER :: color
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: ifaceptb
   INTEGER(kind=inttype), DIMENSION(:), POINTER :: iedgeptb
   END TYPE BLOCKTYPE
   TYPE BLOCKTYPE_T
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: x
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: vol
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: w
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: dw
   END TYPE BLOCKTYPE_T
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Array of all blocks at all multigrid levels and spectral sols. *
   !      *                                                                *
   !      ******************************************************************
   !
   ! nDom:            total number of computational blocks.
   ! flowDoms(:,:,:): array of blocks. Dimensions are
   !                  (nDom,nLevels,nTimeIntervalsSpectral)
   INTEGER(kind=inttype) :: ndom
   ! This is never actually compiled...just make tapenade think it
   ! isn't allocatable
   TYPE(BLOCKTYPE), DIMENSION(nn:nn, 1, ntimeintervalsspectral) :: &
   &  flowdoms
   TYPE(BLOCKTYPE_T), DIMENSION(nn:nn, 1, ntimeintervalsspectral) :: &
   &  flowdomsd
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Additional info needed in the flow solver.                     *
   !      *                                                                *
   !      ******************************************************************
   !
   ! nCellGlobal(nLev) - Global number of cells on every mg level.
   INTEGER(kind=inttype), DIMENSION(:), ALLOCATABLE :: ncellglobal
   UNKNOWNTYPE :: nn
   UNKNOWNTYPE :: ntimeintervalsspectral
   END MODULE BLOCK_T
