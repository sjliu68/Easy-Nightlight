function subset, input_file, output_file, xmin, ymin, xmax, ymax
  ; subset the input_file and export it as ENVI-Standard
  ; both input/output_file supposed to be location(string)
  ; subset_range(begin with 0) supposed to be:
  ;           [min_column, min_row, max_column, max_row]
  compile_opt idl2
  
  ; if output_file exists, return
  if FILE_TEST(output_file) eq 1 then begin
    return, 'output file already exists'
  endif
  
  e = ENVI(/HEADLESS)
  Raster = e.OpenRaster(input_file)
  
  ; if out of range, return
  if xmin lt 0 then begin
    subRaster.close
    Raster.close
    return, 'incorrect boundary setting'
  endif
  
  if ymin lt 0 then begin
    subRaster.close
    Raster.close
    return, 'incorrect boundary setting'
  endif
  
  if xmax ge Raster.ncolumns then begin
    subRaster.close
    Raster.close
    return, 'incorrect boundary setting'
  endif
  
  if ymax ge Raster.nrows then begin
    subRaster.close
    Raster.close
    return, 'incorrect boundary setting'
  endif

  subRaster = ENVISubsetRaster(Raster,SUB_RECT=[xmin,ymin,xmax,ymax])
  subRaster.export, output_file, 'envi'
  subRaster.close
  Raster.close
  return, 'good'
end