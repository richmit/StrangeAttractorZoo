#!/usr/bin/env -S ruby
# -*- Mode:ruby; Coding:us-ascii; fill-column:158 -*-
#########################################################################################################################################################.H.S.##
##
# @file      json2fortran.rb
# @author    Mitch Richling http://www.mitchr.me/
# @brief     Read zoo.json+templaes and create code. @EOL
# @std       Ruby 3
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
require 'json'

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
verbose = 0

if (verbose > 1) then
  STDERR.puts("verbose: #{verbose.inspect}")
end

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
zStr = open("zoo.json", "r").read()
zDat = JSON.parse(zStr)

if (verbose > 1) then
  STDERR.puts("zDat: #{zDat.inspect}")
end

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
tgroup = 'curve'

if (verbose > 1) then
  STDERR.puts("tgroup: #{tgroup.inspect}")
end

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
fDat = Hash.new
zDat.each do |atNam, atDat|
  fDat[atNam] = { 'NAME'        => atNam,
                  'MAX_POINTS'  => "100000",
                  'T_MIN'       => "50.0_rk",
                  'T_DELTA_INI' => "0.01_rk"
                }
  ['y_iv', 'param_value'].each do |tag|
    fDat[atNam][tag.upcase] = atDat[tag].map(&:to_f).inspect.gsub(/([\],])/, '_rk\1')
  end
  deq = '[' + atDat['deq'].join(', ') + ']'
  atDat['param_names'].each_with_index do |par, idx|
    deq.gsub!(/\b#{par}\b/, "param(#{idx+1})")
  end
  [['y', 2], ['x', 1], ['z', 3]].each do |var, idx|
    deq.gsub!(/\b#{var}\b/, "y(#{idx})")
  end
  fDat[atNam]['DEQ'] = deq
  fDat[atNam]['PVD'] = atDat['param_names'].length.to_s
  ['t_delta_ini', 't_iv', 't_min', 't_max'].each do |tag|
    if (atDat.member?(tag)) then
      fDat[atNam][tag.upcase] = atDat[tag].to_f.inspect + '_rk'
    end
  end
  ['max_points'].each do |tag|
    if (atDat.member?(tag)) then
      fDat[atNam][tag.upcase] = atDat[tag].to_i.inspect
    end
  end
end

if (verbose > 1) then
  STDERR.puts("fDat: #{fDat.inspect}")
end

flines = open("#{tgroup}_template.f90", "rb").readlines()

fDat.each do |atNam, atDat|
  open("#{tgroup}_#{atNam}.f90", "wb") do |src_file|
    flines.each do |line|
      new_line = line.clone
      atDat.each do |tag, val|
        new_line.gsub!(tag, val.to_s)
      end
      src_file.puts(new_line)
    end
  end
end

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
gDat = Hash.new
zDat.each do |atNam, atDat|
  gDat[atNam] = { 'NAME'  => atNam,
                  'VROT'  => 45,
                  'VTILT' => 45 }
  ['vrot', 'vtilt'].each do |tag|
    if (atDat.member?(tag)) then
      gDat[atNam][tag.upcase] = atDat[tag]
    end
  end
end

if (verbose > 1) then
  STDERR.puts("gDat: #{gDat.inspect}")
end

glines = open("#{tgroup}_template.gplt", "rb").readlines()

gDat.each do |atNam, atDat|
  open("#{tgroup}_#{atNam}.gplt", "wb") do |src_file|
    glines.each do |line|
      new_line = line.clone
      atDat.each do |tag, val|
        new_line.gsub!(tag, val.to_s)
      end
      src_file.puts(new_line)
    end
  end
end

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
pDat = Hash.new
zDat.each do |atNam, atDat|
  pDat[atNam] = { 'NAME'  => atNam,
                  'VROT'  => 45,
                  'VTILT' => 45 }
  ['vrot', 'vtilt'].each do |tag|
    if (atDat.member?(tag)) then
      pDat[atNam][tag.upcase] = atDat[tag].to_f
    end
  end
end

if (verbose > 1) then
  STDERR.puts("pDat: #{pDat.inspect}")
end

glines = open("#{tgroup}_template.py", "rb").readlines()

pDat.each do |atNam, atDat|
  ["batch", "interactive"].each do |variant|
    ofname = ( variant == 'batch' ? "#{tgroup}_batch_#{atNam}.py" : "#{tgroup}_#{atNam}.py")
    open(ofname, "wb") do |src_file|
      glines.each do |line|
        new_line = line.clone
        if (variant == 'batch') then
          new_line.gsub(/TWIDTH/, '5.0')
        else
          new_line.gsub(/TWIDTH/, '10.0')
          new_line.gsub!(/^SaveScreenshot.*$/, '')
          new_line.gsub!(/^ExportView.*$/, '')
        end
        atDat.each do |tag, val|
          new_line.gsub!(tag, val.to_s)
        end
        src_file.puts(new_line)
      end
    end
  end
end

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
open("#{tgroup}.mk", "wb") do |mk_file|

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts( "#{tgroup}_csv=".upcase        + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.csv"       }.join(' ')))
  mk_file.puts( "#{tgroup}_f90=".upcase        + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.f90"       }.join(' ')))
  mk_file.puts( "#{tgroup}_gplt=".upcase       + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.gplt"      }.join(' ')))
  mk_file.puts( "#{tgroup}_vtu=".upcase        + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.vtu"       }.join(' ')))
  mk_file.puts( "#{tgroup}_gp_png=".upcase     + (fDat.keys.map { |atNam| "#{tgroup}_gp_#{atNam}.png"    }.join(' ')))
  mk_file.puts( "#{tgroup}_pv_png=".upcase     + (fDat.keys.map { |atNam| "#{tgroup}_pv_#{atNam}.png"    }.join(' ')))
  mk_file.puts( "#{tgroup}_py=".upcase         + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.py"        }.join(' ')))
  mk_file.puts( "#{tgroup}_batch_py=".upcase   + (fDat.keys.map { |atNam| "#{tgroup}_batch_#{atNam}.py"  }.join(' ')))
  mk_file.puts( "#{tgroup}_html=".upcase       + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.html"      }.join(' ')))
  mk_file.puts( "#{tgroup}_vtkjs=".upcase      + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.vtkjs"     }.join(' ')))
  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Clean everything for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_clean")
  mk_file.puts( "#{tgroup}_clean :")
  mk_file.puts( "\trm -f " + "$(#{tgroup}_csv)".upcase      )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_f90)".upcase      )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_gplt)".upcase     )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_gp_png)".upcase   )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_pv_png)".upcase   )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_py)".upcase       )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_batch_py)".upcase )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_html)".upcase     )
  mk_file.puts( "\trm -f " + "$(#{tgroup}_vtkjs)".upcase    )

  mk_file.puts( "\trm -f #{tgroup}.mk")
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .csv files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_csv")
  mk_file.puts( "#{tgroup}_csv : " + "$(#{tgroup}_csv)".upcase)
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .vtu files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_vtu")
  mk_file.puts( "#{tgroup}_vtu : " + "$(#{tgroup}_vtu)".upcase)
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .png files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_gp_png")
  mk_file.puts( "#{tgroup}_gp_png : " + "$(#{tgroup}_gp_png)".upcase)
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .png files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_pv_png")
  mk_file.puts( "#{tgroup}_pv_png : " + "$(#{tgroup}_pv_png)".upcase)
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .f90 files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_f90")
  mk_file.puts( "#{tgroup}_f90 : " + "$(#{tgroup}_f90)".upcase)
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("#All .f90 rules for #{tgroup}")
  mk_file.puts( "$(#{tgroup}_f90)".upcase + " &: #{tgroup}_template.py #{tgroup}_template.gplt #{tgroup}_template.f90 zoo.json json2fortran.rb")
  mk_file.puts("\truby json2fortran.rb")
  mk_file.puts

  fDat.keys.each do |atNam|
    mk_file.puts('# ' + ('-' * 200))
    mk_file.puts("#{tgroup}_#{atNam} : #{tgroup}_#{atNam}.f90 $(MRKISS_MOD_FILES) $(MRKISS_OBJ_FILES)")
    mk_file.puts("\t$(FC) $(FFLAGS) #{tgroup}_#{atNam}.f90 $(MRKISS_OBJ_FILES) -o $@")
    mk_file.puts
    mk_file.puts("#{tgroup}_#{atNam}.csv : #{tgroup}_#{atNam}")
    mk_file.puts("\t./#{tgroup}_#{atNam}$(EXE_SUFFIX)")
    mk_file.puts
    mk_file.puts("#{tgroup}_#{atNam}.vtu : #{tgroup}_#{atNam}.csv")
    mk_file.puts("\t$(CSV_2_VTU) #{tgroup}_#{atNam}.csv points:3:4:5 time:2 > #{tgroup}_#{atNam}.vtu")
    mk_file.puts
    mk_file.puts("#{tgroup}_gp_#{atNam}.png : #{tgroup}_#{atNam}.csv")
    mk_file.puts("\tgnuplot -p #{tgroup}_#{atNam}.gplt")
    mk_file.puts
    mk_file.puts("#{tgroup}_pv_#{atNam}.png : #{tgroup}_#{atNam}.vtu")
    mk_file.puts("\t$(PVP)  #{tgroup}_batch_#{atNam}.py")
    mk_file.puts
  end
end






