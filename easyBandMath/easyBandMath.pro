pro button1_event, event
  widget_control, event.top, get_uvalue = ptr_base
  file_input = DIALOG_PICKFILE(/READ, title='Select Input Images: Could be better if images are named in order...', /MULTIPLE_FILES)
  widget_control, (*ptr_base).file_input, set_value=file_input
  IF(file_input[0] EQ '') THEN begin
    result = dialog_message(title='Select Images','Select Some Image...', /information)
    return
  endif
end

pro button2_event, event
  widget_control, event.top, get_uvalue = ptr_base

  widget_control, (*ptr_base).file_output, get_value=file_output
  widget_control, (*ptr_base).file_input, get_value=file_input
  widget_control, (*ptr_base).formula_input, get_value=formula_input
  widget_control, (*ptr_base).min1, get_value=min1
  widget_control, (*ptr_base).max1, get_value=max1
  widget_control, (*ptr_base).resetmin, get_value=resetmin
  widget_control, (*ptr_base).resetmax, get_value=resetmax
  
  if file_output eq '' or file_input eq '' then begin
    result = dialog_message(title='ERROR','please select output directory or input files', /information)
    return 
  endif
  
  if formula_input.length ne file_input.length then begin
    result = dialog_message(title='ERROR','images & formula should match each other', /information)
    return
  endif
  
    
  e = envi(/headless)
  for i=0, (file_input.length-1) do begin
    temp = strsplit(formula_input[i],',',/extract)
    if temp.length ne 3 then begin
      ;help, temp
      result = dialog_message(title='ERROR','formula illegal', /information)
      continue
    endif
    
    ; Version 2.0
    temp2 = strsplit(file_basename(file_input[i]),'.',/extract)
    is_dot = strsplit(file_basename(file_input[i]),'.')
    if is_dot.length eq 1 then temp2=file_basename(file_input[i])
    
    raster = e.openraster(file_input[i])
    ;newMetaData = raster.metadata
    ;newSpa = raster.spatialref
    data = raster.getdata(bands=[0])
    ;raster.close
    result = domath(data,float(temp[0]),float(temp[1]),float(temp[2]))
    
    ; optional
    if min1 ne max1 then begin
      result = (result lt min1)*resetmin + (result gt max1)*resetmax + ((result ge min1) and (result le max1))*result
    endif

      new_raster = e.CreateRaster(strcompress(file_output + temp2[0] + '_cali.dat', /remove_all), inherits_from=raster, result)
    ;new_raster = e.CreateRaster(strcompress(file_output+string(i+1)+'.dat',/remove_all), inherits_from=raster, result)
    raster.close
    new_raster.save
    new_raster.close
  endfor
end

pro button3_event, event
  widget_control, event.top, get_uvalue = ptr_base
  file_output = DIALOG_PICKFILE(/write,title='Select Output Directory', /directory)
  widget_control, (*ptr_base).file_output, set_value=file_output,/sensitive
end

pro button4_event, event
  widget_control, event.top, get_uvalue = ptr_base
  base_help = widget_base(title='User Guide', xsize=640, ysize=480, /column)
  help_info = widget_text(base_help, value=(*ptr_base).guide, ysize=25, font='Calibri',/scroll, /sensitive)
  widget_control, base_help, /realize
end

pro easyBandMath_EVENT, event
  widget_control, event.top, get_uvalue = ptr_base
  tagname = tag_names(event, /structure_name)
  print, tagname
  if tagname eq 'WIDGET_KILL_REQUEST' then begin
    quit_info = dialog_message('Quit?',title='Quit?',/question)
    if quit_info eq 'No' then return
    ptr_free, ptr_base
    widget_control, event.top, /destroy
    return
  endif
end

pro easyBandMath
  compile_opt idl2

  base = widget_base(title='Easy Band Math',/tlb_kill_request_events, xsize=480, ysize=700, /column)

  base2 = widget_base(base, title='base2', /row)
  button_input1 = widget_button(base2, value='im1.bmp',/BITMAP, uvalue='button_input1', event_pro='button1_event', tooltip='Input Files')
  button_input3 = widget_button(base2, value='im3.bmp',/BITMAP, uvalue='button_input3', event_pro='button3_event', tooltip='Output Files')
  button_input2 = widget_button(base2, value='im2.bmp',/BITMAP, uvalue='button_input2', event_pro='button2_event', tooltip='Run!')
  button_input4 = widget_button(base2, value='im4.bmp',/BITMAP, uvalue='button_input4', event_pro='button4_event', tooltip='Help')
  button_input5 = widget_button(base2, value='im6.bmp',/BITMAP, uvalue='button_input5', event_pro='button4_event', xsize=180, tooltip='Happy Mooncakes Day!')

  base3 = widget_base(base,title='base3',/row)
  file_input = widget_text(base3, value='', xsize=35, ysize=32, /scroll, /sensitive)
  formula_input = widget_text(base3, value='', xsize=35, ysize=32, /scroll, /editable)

  base45 = widget_base(base,title='base45',/row,tab_mode=1)
  base4 = widget_base(base45,title='base4',/column, tab_mode=1)
  base5 = widget_base(base45,title='base5',/column, tab_mode=1)
  min1 = cw_field(base4,title='Min(optional): ',/integer,tab_mode=1,xsize=13)
  max1 = cw_field(base4,title='Max(optional): ',/integer,tab_mode=1,xsize=13)
  resetmin = cw_field(base5,title='     Reset Min(optional): ',/integer,tab_mode=1,xsize=13)
  resetmax = cw_field(base5,title='     Reset Max(optional): ',/integer,tab_mode=1,xsize=13)
  file_output = cw_field(base,title=' Output Directory(*): ',tab_mode=1,xsize=58)

  guide = ['For more information, please contact SJ: stop68@foxmail.com','',' Tested on windows 7 64bit with IDL 8.5, [Oct 17, 2017]','',$
    'Version 2.0 [Oct 17, 2017]: ',' * Change output type as [*.dat] for better compalibility with Arcpy/ArcGIS. ',$
     ' * Change output filename as [xxx_cali.dat].',' * Enlarge input window to get a better view of formula&file. ', $
    ' * Improve stability.', '',$
    'Version 1.2 [Oct 5, 2017]: ',' * Improve performance.','','Version 1.1 [Oct 4, 2017]: ',$
    ' * Now you can control max/min of the result.',$
    ' DN<min will be reassigned to ResetMin',' DN>max will be reassigned to ResetMax',' * All the number input must be integer in max/min setting.',$
    ' If min==max or remain blank, the max/min setting will NOT do anything.','','Version 1.0 [Oct 3, 2017]: ',' Since this is a personal tool and was produced during vacation, there is NO error check.', $
    ' Please do NOT make any stupid and/or tricky move for your PCs sake.','',' This tool is originally designed for multitemporal night-time lights calibration.',' Only band[0] will be put into calculation.',$
    ' Easy Band Math is designed to do math with formula like:', '', '             y = a + bx + cx^2','','If there are 3 images input on the left as:',$
    'C:\image1.tif','C:\image2.tif','C:\image3.tif','', 'then the parameters should be put on the right as:', 'a1,b1,c1','a2,b2,c2','a3,b3,c3']
  member = {file_input:file_input,file_output:file_output,formula_input:formula_input,guide:guide,min1:min1,max1:max1,resetmin:resetmin,resetmax:resetmax}
  ptr_member = ptr_new(member, /no_copy)
  widget_control, base, set_uvalue = ptr_member

  widget_control, base, /realize
  XMANAGER, 'easyBandMath', base
end