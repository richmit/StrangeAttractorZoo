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

# disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'XML Unstructured Grid Reader'
curveMJR = XMLUnstructuredGridReader(registrationName='curve_NAME.vtu', FileName=['C:\\Users\\richmit\\MJR\\world\\my_prog\\strange_zoo\\src\\curve_NAME.vtu'])

# Properties modified on curveMJR
curveMJR.TimeArray = 'None'

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')

# show data in view
curveMJRDisplay = Show(curveMJR, renderView1, 'UnstructuredGridRepresentation')

# trace defaults for the display properties.
curveMJRDisplay.Representation = 'Surface'

# reset view to fit data
renderView1.ResetCamera(False, 0.9)

# get the material library
materialLibrary1 = GetMaterialLibrary()

# update the view to ensure updated data information
renderView1.Update()

# set scalar coloring
ColorBy(curveMJRDisplay, ('POINTS', 'time'))

# rescale color and/or opacity maps used to include current data range
curveMJRDisplay.RescaleTransferFunctionToDataRange(True, False)

# show color bar/color legend
curveMJRDisplay.SetScalarBarVisibility(renderView1, True)

# get color transfer function/color map for 'time'
timeLUT = GetColorTransferFunction('time')

# get opacity transfer function/opacity map for 'time'
timePWF = GetOpacityTransferFunction('time')

# get 2D transfer function for 'time'
timeTF2D = GetTransferFunction2D('time')

# change representation type
curveMJRDisplay.SetRepresentationType('Wireframe')

# Properties modified on curveMJRDisplay
curveMJRDisplay.LineWidth = 10.0

# Properties modified on curveMJRDisplay
curveMJRDisplay.RenderLinesAsTubes = 1

# reset view to fit data
renderView1.ResetCamera(False, 0.9)

# get layout
layout1 = GetLayout()

#--------------------------------
# save layout/tab size in pixels
layout1.SetSize(2092, 1354)

#-----------------------------------
# Setup camera placement for view
renderView1.CameraPosition = [1, 1, 1]
renderView1.CameraFocalPoint = [0, 0, 0]
renderView1.CameraViewUp = [0, 0, 1]
renderView1.CameraParallelScale = 10

renderView1.ResetCamera()

# Render all views just to make sure they appear on screen
# RenderAllViews()

# Save a screenshot with ste resolution and background color
SaveScreenshot("C:/Users/richmit/MJR/world/my_prog/strange_zoo/src/curve_pv_NAME.png", renderView1, ImageResolution=[600, 600])

# Export to HTML for ParaView Glance
ExportView('C:/Users/richmit/MJR/world/my_prog/strange_zoo/src/curve_NAME.vtkjs', view=renderView1, ParaViewGlanceHTML='C:\\Users\\richmit\\MJR\\world\\my_prog\\strange_zoo\\src\\ParaViewGlance.html')
