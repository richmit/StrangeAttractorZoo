# -*- Mode:makefile; Coding:us-ascii-unix; fill-column:158 -*-
#########################################################################################################################################################.H.S.##
##
# @file      makefile
# @author    Mitch Richling http://www.mitchr.me/
# @std       GNUmake
# @see       https://github.com/richmit/StrangeAttractorZoo/
# @copyright 
#  @parblock
#  Copyright (c) 2025, Mitchell Jay Richling <http://www.mitchr.me/> All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this list of conditions, and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  
#  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
#  DAMAGE.
#  @endparblock
#########################################################################################################################################################.H.E.##

################################################################################################################################################################
MRKISS_PATH = ../../MRKISS/

 include $(MRKISS_PATH)/make_includes/tools_gfortran.mk
# include $(MRKISS_PATH)/make_includes/tools_flang.mk
# include $(MRKISS_PATH)/make_includes/tools_ifx.mk
# include $(MRKISS_PATH)/make_includes/tools_lfortran.mk
# include $(MRKISS_PATH)/make_includes/tools_nvfortran.mk

include $(MRKISS_PATH)/make_includes/include.mk
################################################################################################################################################################

IMG_VIEWER = nomacs
CSV_2_VTU  = ~/world/my_prog/learn/ex-VTK/xml_files/spaceCurveCSVtoVTU.rb
PVP        = ~/bin/pvpython

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
include curve.mk

curve.mk : json2fortran.rb makefile zoo.json
	ruby json2fortran.rb

docs : curve_pv_png curve_gp_png
	cp curve_*.vtkjs curve_*.html ../docs/pv/
	cp curve_pv_*.png ../docs/pics/pv/
    cp curve_gp_*.png ../docs/pics/gp/	

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
clean : clean_multi_mrkiss
	rm -f *.exe *.csv *.png *~ a.out a.exe *.svg *.vtu

clean_clean : curve_clean clean
