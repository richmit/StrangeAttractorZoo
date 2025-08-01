! -*- Mode:F90; Coding:us-ascii-unix; fill-column:129 -*-
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.H.S.!!
!>
!! @file      curve_template.f90
!! @author    Mitch Richling http://www.mitchr.me/
!! @brief     Template to solve Strange Attractor ODEs.@EOL
!! @std       F2023
!! @see       https://github.com/richmit/StrangeAttractorZoo/
!! @copyright 
!!  @parblock
!!  Copyright (c) 2025, Mitchell Jay Richling <http://www.mitchr.me/> All rights reserved.
!!  
!!  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following
!!  conditions are met:
!!  
!!  1. Redistributions of source code must retain the above copyright notice, this list of conditions, and the following
!!     disclaimer.
!!  
!!  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions, and the following
!!     disclaimer in the documentation and/or other materials provided with the distribution.
!!  
!!  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
!!     derived from this software without specific prior written permission.
!!  
!!  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
!!  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
!!  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
!!  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
!!  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
!!  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
!!  OF THE POSSIBILITY OF SUCH DAMAGE.
!!  @endparblock
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.H.E.!!

!----------------------------------------------------------------------------------------------------------------------------------
program curve_NAME
  use, intrinsic :: iso_fortran_env,          only: output_unit, error_unit
  use            :: mrkiss_config,            only: rk, ik, t_delta_tiny
  use            :: mrkiss_solvers_nt,        only: steps_fixed_stab_nt
  use            :: mrkiss_utils,             only: print_solution
  use            :: mrkiss_eerk_fehlberg_7_8, only: a, b=>b2, c

  implicit none

  integer,        parameter :: deq_dim       = 3
  integer,        parameter :: num_points    = MAX_POINTS
  real(kind=rk),  parameter :: y_iv(deq_dim) = Y_IV
  real(kind=rk),  parameter :: param(PVD)    = PARAM_VALUE
  real(kind=rk),  parameter :: t_delta       = T_DELTA_INI
  real(kind=rk),  parameter :: t_max         = T_MAX
  real(kind=rk),  parameter :: t_min         = T_MIN

  real(kind=rk)             :: solution(1+2*deq_dim, num_points)
  integer(kind=ik)          :: status, istats(16)
  integer                   :: c_beg, c_end, c_rate

  call system_clock(count_rate=c_rate)
  call system_clock(c_beg)
  call steps_fixed_stab_nt(status, istats, solution, eq, y_iv, param, a, b, c, t_delta_o=t_delta, t_max_o=t_max)
  call system_clock(c_end)
  print '(a,i10)',   "                   Status: ", status
  print '(a,f10.3)', "             Milliseconds: ", 1000*(c_end-c_beg)/DBLE(c_rate)
  print '(a,i10)',   "          Solution Points: ", istats(1)
  print '(a,i10)',   "   Regular one_step calls: ", istats(2)
  print '(a,i10)',   "Adjustment one_step calls: ", istats(3)
  call print_solution(status, solution, filename_o="curve_NAME.csv", end_o=istats(1), t_min_o=t_min)

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
