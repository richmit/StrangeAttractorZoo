! -*- Mode:F90; Coding:us-ascii-unix; fill-column:129 -*-

!----------------------------------------------------------------------------------------------------------------------------------
program curve_NAME
  use, intrinsic :: iso_fortran_env,    only: output_unit, error_unit
  use            :: mrkiss_config,      only: rk, ik, t_delta_tiny
  use            :: mrkiss_solvers_nt,  only: steps_fixed_stab_nt
  use            :: mrkiss_utils,       only: print_t_y_sol
!  use            :: mrkiss_erk_kutta_4, only: a, b, c
  use            :: mrkiss_eerk_fehlberg_7_8, only: a, b=>b2, c

  implicit none

  integer,        parameter :: deq_dim       = 3
  integer,        parameter :: num_points    = MAX_POINTS
  real(kind=rk),  parameter :: y_iv(deq_dim) = Y_IV
  real(kind=rk),  parameter :: param(PVD)      = PARAM_VALUE
  real(kind=rk),  parameter :: t_delta       = T_DELTA_INI
  real(kind=rk),  parameter :: t_max         = T_MAX
  real(kind=rk),  parameter :: t_min         = T_MIN

  real(kind=rk)             :: t_y_sol(1+deq_dim, num_points)
  integer(kind=ik)          :: status, istats(16)
  integer                   :: c_beg, c_end, c_rate

  call system_clock(count_rate=c_rate)
  call system_clock(c_beg)
  call steps_fixed_stab_nt(status, istats, t_y_sol, eq, y_iv, param, a, b, c, t_delta_o=t_delta, t_max_o=t_max)
  call system_clock(c_end)
  print '(a,i10)',   "                   Status: ", status
  print '(a,f10.3)', "             Milliseconds: ", 1000*(c_end-c_beg)/DBLE(c_rate)
  print '(a,i10)',   "          Solution Points: ", istats(1)
  print '(a,i10)',   "   Regular one_step calls: ", istats(2)
  print '(a,i10)',   "Adjustment one_step calls: ", istats(3)
  call print_t_y_sol(status, t_y_sol, filename_o="curve_NAME.csv", end_o=istats(1), t_min_o=t_min)

contains
  
  subroutine eq(status, dydt, y, param)
    integer(kind=ik), intent(out) :: status
    real(kind=rk),    intent(out) :: dydt(:)
    real(kind=rk),    intent(in)  :: y(:)
    real(kind=rk),    intent(in)  :: param(:)
    dydt = DEQ
    status = 0
  end subroutine eq

end program curve_NAME
