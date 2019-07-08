pro button1_event, event
  widget_control, event.top, get_uvalue = ptr_base
  file_input = DIALOG_PICKFILE(/READ, title='Select Input Images: Could be better if images are named in order...', /MULTIPLE_FILES)
  widget_control, (*ptr_base).file_input1, set_value=file_input
  IF(file_input[0] EQ '') THEN begin
    widget_control, (*ptr_base).file_input1, set_value=(*ptr_base).tips
    result = dialog_message(title='Select Images','Select Some Image...', /information)
    return
  endif
end

pro button2_event, event
  widget_control, event.top, get_uvalue = ptr_base

  widget_control, (*ptr_base).file_output1, get_value=file_output
  widget_control, (*ptr_base).file_input1, get_value=file_input
  
  widget_control, (*ptr_base).left, get_value=left
  widget_control, (*ptr_base).up, get_value=up
  widget_control, (*ptr_base).right, get_value=right
  widget_control, (*ptr_base).down, get_value=down
  
  if file_input[0] eq (*ptr_base).tips[0] then begin
    result = dialog_message(title='Select Images','Select Some Image...', /information)
    return
  endif
  if file_output eq '' then begin
    result = dialog_message(title='Select Output Directory','Select Output Directory...', /information)
    return
  endif
  if uint(left) ge uint(right) then begin
    result = dialog_message(title='Incorrect Boundary Setting','Left should be smaller than Right', /error)
    return
  endif
  if uint(up) ge uint(down) then begin
    result = dialog_message(title='Incorrect Boundary Setting','Up should be smaller than Down', /error)
    return
  endif
  
  record = strarr(file_input.length)
  for i=0, (file_input.length-1) do begin
    temp = strsplit(file_basename(file_input[i]),'.',/extract)
    is_dot = strsplit(file_basename(file_input[i]),'.')
    if is_dot.length eq 1 then temp=file_basename(file_input[i])
    ;temp = strsplit(file_basename(file_input[i]),'.',/extract)
    record[i] = file_basename(file_input[i]) + ': ' + subset(file_input[i], strcompress(file_output + temp[0] + '_subset',/remove_all), uint(left), uint(up), uint(right), uint(down))
  ENDFOR
  
  record_base = widget_base(title='Record', xsize=480, ysize=320, /column)
  record_info = widget_text(record_base, value=['This records the status of each file:', record], ysize=30, /scroll, /sensitive)
  widget_control, record_base, /realize
end

pro button3_event, event
  widget_control, event.top, get_uvalue = ptr_base
  file_output = DIALOG_PICKFILE(/write,title='Select Output Directory',/directory)
  widget_control, (*ptr_base).file_output1, set_value=file_output,/sensitive
end

pro button4_event, event
  ;help_info = dialog_message('Help',title='Help',/question)
  widget_control, event.top, get_uvalue = ptr_base
  base_help = widget_base(title='User Guide', xsize=640, ysize=320, /column)
  help_info = widget_text(base_help, value=(*ptr_base).guide, ysize=20, /scroll, /sensitive)
  widget_control, base_help, /realize
end

pro SUBSET_UI_EVENT, event
  widget_control, event.top, get_uvalue = ptr_base
  tagname = tag_names(event, /structure_name)
  print, tagname
  if tagname eq 'WIDGET_KILL_REQUEST' then begin
    quit_info = dialog_message('Quit Easy Subset?',title='Quit?',/question)
    if quit_info eq 'No' then return
    ptr_free, ptr_base
    widget_control, event.top, /destroy
    return
  endif
end

pro ui
  compile_opt idl2
  
  base = widget_base(title='Easy Subset',/tlb_kill_request_events, MBAR=bar, xsize=300, ysize=480, /column)
  
  base2 = widget_base(base, title='base2', /row)
  button_input1 = widget_button(base2, value='im1.bmp',/BITMAP, uvalue='button_input1', event_pro='button1_event', tooltip='Input Files')
  button_input3 = widget_button(base2, value='im3.bmp',/BITMAP, uvalue='button_input3', event_pro='button3_event', tooltip='Output Directory')
  button_input2 = widget_button(base2, value='im2.bmp',/BITMAP, uvalue='button_input2', event_pro='button2_event', tooltip='Run!')
  button_input4 = widget_button(base2, value='im4.bmp',/BITMAP, uvalue='button_input4', event_pro='button4_event', tooltip='Help')
  
  label_input1 = widget_label(base,value='Input Files(*):                                  ')
  tips = ['-> Input Files...','-> Select Output Directory...','-> Set Boundary Settings' ,'-> Run!','','All the output files will be renamed as:','     xxx_subset...','','Boundary/Size of images begin with zero(0)']
  file_input1 = widget_text(base, value=tips, ysize=12, /scroll, /sensitive)
  guide = ['For more information, please contact SJ: stop68@foxmail.com','','1. Click the 1st button to input images', '2. Click the 2nd button to locate output directory',$
    '3. Set boundary (left,up,right,down) in Boundary Setting, boundary begin with zero(0)','4. Click the 3rd button to subset images!','', 'Notice:','1. All the images should be geometrically corrected and be in same size',$
    '2. Output Files will be named as: xxx_subset','3. Boundary/Size of images begin with zero(0)']
  
  base3 = widget_base(base,title='base3',TAB_MODE=1,/column)
  base3_label = widget_label(base3, value='Boundary Setting(*):             ')
  left = cw_field(base3,title='Left(*)  :',value='')
  up = cw_field(base3,title='Up(*)    :',value='')
  right = cw_field(base3,title='Right(*) :',value='')
  down = cw_field(base3,title='Down(*)  :',value='')
  
  base4 = widget_base(base,title='base4',/column)
  label_ouput1 = widget_label(base4, value='Output Directory(*):')
  file_output1 = widget_text(base, value='', TAB_MODE=1)
  
  member = {file_input1:file_input1,file_output1:file_output1,tips:tips,guide:guide,left:left,up:up,right:right,down:down}
  ptr_member = ptr_new(member, /no_copy)
  widget_control, base, set_uvalue = ptr_member
  
  widget_control, base, /realize
  XMANAGER, 'subset_ui', base
end