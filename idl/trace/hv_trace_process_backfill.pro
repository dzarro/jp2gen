;
; Written:  2013?, Ireland (NASA/GSFC)
; Modified: Feb 2022, Zarro (ADNET/GSFC) - added 2-argument input option and use of TRACE object
;
; Process large amounts of TRACE data
;
; Pass in an array with dates [earlier_date, later_date] or earlier_date, later_date
;
;
PRO HV_TRACE_PROCESS_BACKFILL, date1,date2,_extra=extra
  progname = 'hv_trace_process_backfill'
;
;-- check if input is 2-element date array or two input arguments 

  case 1 of
   n_elements(date1) eq 2: begin
    sdate=date1[0] & edate=date1[1]
   end
   n_params(0) eq 2: begin
    sdate=date1 & edate=date2
   end
   else: begin
    mprint,'Input DATE must be 2-element array or two arguments.'
    return
   end  
  endcase

  if ~valid_time(sdate,/scalar) || ~valid_time(edate,/scalar) then begin
   mprint,'Input DATE must have two valid time elements'
   return
  endif

;
; Get the day components
;

  int_dates=anytim2utc([sdate,edate],/int)
  mjd_start=int_dates[0].mjd
  mjd_end=int_dates[1].mjd
  
  if mjd_start gt mjd_end then begin
     print,progname + ': start date must be earlier than end date since this program works backwards from earlier times'
     print,progname + ': stopping.'
     stop
  endif
;
; Hour list
;
  hourlist = strarr(25)
  for i = 0, 24 do begin
     if i le 9 then begin
        hr = '0' + trim(i)
     endif else begin
        hr = trim(i)
     endelse
     hourlist[i] = hr + ':00:00'
  endfor
  hourlist[24] = '23:59:59'

;
; Main loop
;
  mjd = mjd_end + 1
  repeat begin
     ; go backwards one day
     mjd = mjd - 1

     ; calculate the year / month / date
     mjd2date,mjd,y,m,d

     yyyy = trim(y)
     if m le 9 then mm = '0'+trim(m) else mm = trim(m)
     if d le 9 then dd = '0'+trim(d) else dd = trim(d)

     this_date = yyyy+'-'+mm+'-'+dd
;
; Start
;
;     timestart = systime()
;     print,' '
;     print,systime() + ': ' + progname + ': Processing all files on '+this_date
;
; Get the data for this day
;
; Query the TRACE catalog on an hourly basis so we don't have
; too much data in memory at any one time
     for i = 0, 23 do begin
        
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,' '
;        print,'You must run hv_trace_prep_adapted_from_sswidl.pro BEFORE running this program'
;        print,'in order to use the version of trace_prep.pro defined in there'
;        print,' '
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'
;        print,'WARNING!'


        ; Start and the end times
        start_time = this_date + ' ' + hourlist[i]
        end_time = this_date + ' ' + hourlist[i+1]
	print, start_time,' ',end_time

;-- use TRACE object to search for files
        
        common stash,tobj
        if ~obj_valid(tobj) then tobj=obj_new('trace')
        files=tobj->cat_search(start_time,end_time,count=count,/verbose)
        if count eq 0 then continue                                             ;-- skip to next block if no files found  
        
; Send the files list, then prep the data and write a JP2 file for
; each of the files
        
        HV_TRACE_PREP,files,object=tobj,_extra=extra
        
     endfor
  endrep until mjd lt mjd_start


  return
END

