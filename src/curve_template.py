
#import paraview
#paraview.compatibility.major = 5
#paraview.compatibility.minor = 13

#### import the simple module from the paraview
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

renderView1.ApplyIsometricView()

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
