   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.7 (r4786) - 21 Feb 2013 15:53
   !
   !  Differentiation of getdirvector in forward (tangent) mode (with options debugTangent i4 dr8 r8):
   !   variations   of useful results: winddirection
   !   with respect to varying inputs: alpha beta winddirection
   !
   !     ******************************************************************
   !     *                                                                *
   !     * File:          getDirVector.f90                                *
   !     * Author:        Andre C. Marta                                  *
   !     * Starting date: 10-25-2005                                      *
   !     * Last modified: 10-26-2006                                      *
   !     *                                                                *
   !     ******************************************************************
   !
   SUBROUTINE GETDIRVECTOR_T(refdirection, alpha, alphad, beta, betad, &
   &  winddirection, winddirectiond, liftindex)
   USE CONSTANTS
   IMPLICIT NONE
   !(xb,yb,zb,alpha,beta,xw,yw,zw)
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Convert the angle of attack and side slip angle to wind axes.  *
   !     * The components of the wind direction vector (xw,yw,zw) are     *
   !     * computed given the direction angles in radians and the body    *
   !     * direction by performing two rotations on the original          *
   !     * direction vector:                                              *
   !     *   1) Rotation about the zb or yb-axis: alpha clockwise (CW)    *
   !     *      (xb,yb,zb) -> (x1,y1,z1)                                  *
   !     *                                                                *
   !     *   2) Rotation about the yl or z1-axis: beta counter-clockwise  *
   !     *      (CCW)  (x1,y1,z1) -> (xw,yw,zw)                           *
   !     *                                                                *
   !     *    input arguments:                                            *
   !     *       alpha    = angle of attack in radians                    *
   !     *       beta     = side slip angle in radians                    *
   !     *       refDirection = reference direction vector                *
   !     *    output arguments:                                           *
   !     *       windDirection = unit wind vector in body axes            *
   !     *                                                                *
   !     ******************************************************************
   !
   !
   !     Subroutine arguments.
   !
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: refdirection
   REAL(kind=realtype) :: alpha, beta
   REAL(kind=realtype) :: alphad, betad
   REAL(kind=realtype), DIMENSION(3), INTENT(OUT) :: winddirection
   REAL(kind=realtype), DIMENSION(3), INTENT(OUT) :: winddirectiond
   INTEGER(kind=inttype) :: liftindex
   !
   !     Local variables.
   !
   REAL(kind=realtype) :: rnorm, x1, y1, z1, xbn, ybn, zbn, xw, yw, zw
   REAL(kind=realtype) :: x1d, y1d, z1d, xbnd, ybnd, zbnd, xwd, ywd, zwd
   REAL(kind=realtype), DIMENSION(3) :: refdirectionnorm
   REAL(kind=realtype) :: tmp
   REAL(kind=realtype) :: tmpd
   REAL(kind=realtype) :: arg1
   EXTERNAL DEBUG_TGT_HERE
   LOGICAL :: DEBUG_TGT_HERE
   INTRINSIC SQRT
   IF (.TRUE. .AND. DEBUG_TGT_HERE('entry', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8('alpha', alpha, alphad)
   CALL DEBUG_TGT_REAL8('beta', beta, betad)
   CALL DEBUG_TGT_DISPLAY('entry')
   END IF
   !     ******************************************************************
   !     *                                                                *
   !     * Begin execution.                                               *
   !     *                                                                *
   !     ******************************************************************
   !
   ! Normalize the input vector.
   arg1 = refdirection(1)**2 + refdirection(2)**2 + refdirection(3)**2
   rnorm = SQRT(arg1)
   xbn = refdirection(1)/rnorm
   ybn = refdirection(2)/rnorm
   zbn = refdirection(3)/rnorm
   !!$      ! Compute the wind direction vector.
   !!$
   !!$      ! 1) rotate alpha radians cw about y-axis
   !!$      !    ( <=> rotate y-axis alpha radians ccw)
   !!$
   !!$      call vectorRotation(x1, y1, z1, 2, alpha, xbn, ybn, zbn)
   !!$
   !!$      ! 2) rotate beta radians ccw about z-axis
   !!$      !    ( <=> rotate z-axis -beta radians ccw)
   !!$
   !!$      call vectorRotation(xw, yw, zw, 3, -beta, x1, y1, z1)
   IF (liftindex .EQ. 2) THEN
   ! Compute the wind direction vector.Aerosurf axes different!!
   ! 1) rotate alpha radians cw about z-axis
   !    ( <=> rotate z-axis alpha radians ccw)
   tmpd = -alphad
   tmp = -alpha
   zbnd = 0.0_8
   ybnd = 0.0_8
   xbnd = 0.0_8
   CALL DEBUG_TGT_CALL('VECTORROTATION', .TRUE., .FALSE.)
   CALL VECTORROTATION_T(x1, x1d, y1, y1d, z1, z1d, 3, tmp, tmpd, xbn, &
   &                    xbnd, ybn, ybnd, zbn, zbnd)
   CALL DEBUG_TGT_EXIT()
   ! 2) rotate beta radians ccw about y-axis
   !    ( <=> rotate z-axis -beta radians ccw)
   tmpd = -betad
   tmp = -beta
   CALL DEBUG_TGT_CALL('VECTORROTATION', .TRUE., .FALSE.)
   CALL VECTORROTATION_T(xw, xwd, yw, ywd, zw, zwd, 2, tmp, tmpd, x1, &
   &                    x1d, y1, y1d, z1, z1d)
   CALL DEBUG_TGT_EXIT()
   ELSE IF (liftindex .EQ. 3) THEN
   IF (.TRUE. .AND. DEBUG_TGT_HERE('middle', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8('alpha', alpha, alphad)
   CALL DEBUG_TGT_REAL8('beta', beta, betad)
   CALL DEBUG_TGT_REAL8ARRAY('winddirection', winddirection, &
   &                          winddirectiond, 3)
   CALL DEBUG_TGT_DISPLAY('middle')
   END IF
   ! Compute the wind direction vector.Aerosurf axes different!!
   ! 1) rotate alpha radians cw about z-axis
   !    ( <=> rotate z-axis alpha radians ccw)
   zbnd = 0.0_8
   ybnd = 0.0_8
   xbnd = 0.0_8
   CALL DEBUG_TGT_CALL('VECTORROTATION', .TRUE., .FALSE.)
   CALL VECTORROTATION_T(x1, x1d, y1, y1d, z1, z1d, 2, alpha, alphad, &
   &                    xbn, xbnd, ybn, ybnd, zbn, zbnd)
   CALL DEBUG_TGT_EXIT()
   CALL DEBUG_TGT_CALL('VECTORROTATION', .TRUE., .FALSE.)
   ! 2) rotate beta radians ccw about y-axis
   !    ( <=> rotate z-axis -beta radians ccw)
   CALL VECTORROTATION_T(xw, xwd, yw, ywd, zw, zwd, 3, beta, betad, x1&
   &                    , x1d, y1, y1d, z1, z1d)
   CALL DEBUG_TGT_EXIT()
   ELSE
   CALL TERMINATE('getDirVector', 'Invalid Lift Direction')
   zwd = 0.0_8
   xwd = 0.0_8
   ywd = 0.0_8
   END IF
   winddirectiond(1) = xwd
   winddirection(1) = xw
   winddirectiond(2) = ywd
   winddirection(2) = yw
   winddirectiond(3) = zwd
   winddirection(3) = zw
   IF (.TRUE. .AND. DEBUG_TGT_HERE('exit', .FALSE.)) THEN
   CALL DEBUG_TGT_REAL8ARRAY('winddirection', winddirection, &
   &                        winddirectiond, 3)
   CALL DEBUG_TGT_DISPLAY('exit')
   END IF
   END SUBROUTINE GETDIRVECTOR_T
