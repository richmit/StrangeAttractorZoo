#!/usr/bin/env -S ruby
# -*- Mode:ruby; Coding:us-ascii; fill-column:158 -*-

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
  pDat[atNam] = { 'NAME'  => atNam }
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
        if (variant != 'batch') then
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
  mk_file.puts("# Clean everything for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_clean")
  mk_file.puts( "#{tgroup}_clean :")
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.csv"       }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.f90"       }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.gplt"      }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.png"       }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.py"        }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_batch_#{atNam}.py"  }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.html"      }.join(' ')))
  mk_file.puts( "\trm -f " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.vtkjs"     }.join(' ')))

  mk_file.puts( "\trm -f #{tgroup}.mk")
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .csv files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_csv")
  mk_file.puts( "#{tgroup}_csv : " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.csv" }.join(' ')))
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .vtu files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_vtu")
  mk_file.puts( "#{tgroup}_vtu : " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.vtu" }.join(' ')))
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .png files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_gp_png")
  mk_file.puts( "#{tgroup}_gp_png : " + (fDat.keys.map { |atNam| "#{tgroup}_gp_#{atNam}.png" }.join(' ')))
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .png files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_pv_png")
  mk_file.puts( "#{tgroup}_pv_png : " + (fDat.keys.map { |atNam| "#{tgroup}_pv_#{atNam}.png" }.join(' ')))
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("# Build all .f90 files for #{tgroup}")
  mk_file.puts(".PHONY: #{tgroup}_f90")
  mk_file.puts( "#{tgroup}_f90 : " + (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.f90" }.join(' ')))
  mk_file.puts

  mk_file.puts('# ' + ('-' * 200))
  mk_file.puts("#All .f90 rules for #{tgroup}")
  mk_file.puts( (fDat.keys.map { |atNam| "#{tgroup}_#{atNam}.f90" }.join(' ')) + " &: #{tgroup}_template.py #{tgroup}_template.gplt #{tgroup}_template.f90 zoo.json json2fortran.rb")
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






