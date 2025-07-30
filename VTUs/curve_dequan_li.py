# -*- Mode:Python; Coding:us-ascii-unix; fill-column:158 -*-
#########################################################################################################################################################.H.S.##
##
# @file      curve_template.py
# @author    Mitch Richling http://www.mitchr.me/
# @brief     Generated glimpse and paraview startup files.@EOL
# @std       Python
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

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
#import paraview
#paraview.compatibility.major = 5
#paraview.compatibility.minor = 13

# import the simple paraview module 
from paraview.simple import *
import math

# disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'XML Unstructured Grid Reader'
curveMJR = XMLUnstructuredGridReader(registrationName='curve_dequan_li.vtu', FileName=['C:\\Users\\richmit\\MJR\\world\\my_prog\\StrangeAttractorZoo\\src\\curve_dequan_li.vtu'])

# Properties modified on curveMJR
curveMJR.TimeArray = 'None'

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')

# show data in view
curveMJRDisplay = Show(curveMJR, renderView1, 'UnstructuredGridRepresentation')

# trace defaults for the display properties.
curveMJRDisplay.Representation = 'Wireframe'

# Properties modified on curveMJRDisplay
curveMJRDisplay.LineWidth = 4.0

# Properties modified on curveMJRDisplay
curveMJRDisplay.RenderLinesAsTubes = 1

# Remove orientation axis
renderView1.OrientationAxesVisibility = 1

# set scalar coloring
ColorBy(curveMJRDisplay, ('POINTS', 'time'))

# rescale color and/or opacity maps used to include current data range
curveMJRDisplay.RescaleTransferFunctionToDataRange(True, False)

# No color bar/color legend
curveMJRDisplay.SetScalarBarVisibility(renderView1, False)

# update the view to populate GetDataInformation()
renderView1.Update()

# Get the bounding box
bounds = curveMJR.GetDataInformation().GetBounds()

#-----------------------------------
# Setup camera placement for view
x = 2 * max(bounds[1]-bounds[0], bounds[3]-bounds[2], bounds[5]-bounds[4])
y = 0
z = 0
x, y = x*math.cos(math.pi*45/180)-y*math.sin(math.pi*45/180), x*math.sin(math.pi*45/180)+y*math.cos(math.pi*45/180)
x, z = x*math.cos(math.pi*45/180)-z*math.sin(math.pi*45/180), x*math.sin(math.pi*45/180)+z*math.cos(math.pi*45/180)
renderView1.CameraPosition = [x+(bounds[1]+bounds[0])/2, y, z+(bounds[5]+bounds[4])/2]
renderView1.CameraFocalPoint = [(bounds[1]+bounds[0])/2, (bounds[3]+bounds[2])/2, (bounds[5]+bounds[4])/2]
renderView1.CameraViewUp = [0, 0, 1]
renderView1.CameraParallelScale = 1

renderView1.ResetCamera(False, 0.9)

renderView1.Update()

RenderAllViews()

# Save a screenshot with ste resolution and background color


# Export to HTML for ParaView Glance

