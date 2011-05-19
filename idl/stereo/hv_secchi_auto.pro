;
;
;
PRO HV_SECCHI_AUTO,ndaysBack = ndaysBack, $                      ; date to end automated processing starts
                   details_file = details_file,$                 ; call to an explicit details file
                   copy2outgoing = copy2outgoing,$               ; copy to the outgoing directory
                   once_only = once_only,$                       ;  if set, the time range is passed through once only
                   writtenby = writtenby,$
                   euvi = euvi,$
                   cor1 = cor1,$
                   cor2 = cor2
;
  progname = 'hv_secchi_auto'
  count = 0
  timestart = systime()
;
  repeat begin
;
; Get today's date in UT
;
     get_utc,date_start
;
     for i = 0,ndaysback do begin

        this_date = date_start
        this_date.mjd = this_date.mjd - i
        date = utc2str(this_date,/date_only,/ecs)

        print,' '
        print,progname + ': Processing all files on ' + date

        if keyword_set(cor1) then begin
           HV_COR1_BY_DATE,date, copy2outgoing = copy2outgoing
        endif
        if keyword_set(cor2) then begin
           HV_COR2_BY_DATE,date, copy2outgoing = copy2outgoing
        endif
        if keyword_set(euvi) then begin
           HV_EUVI_BY_DATE,date, copy2outgoing = copy2outgoing
        endif
     endfor
;
; Wait 15 minutes before looking for more data
;
     count = count + 1
     HV_REPEAT_MESSAGE,progname,count,timestart, more = ['examined ' + date + '.',''],/web
     HV_WAIT,progname,15,/minutes,/web

  endrep until  1 eq keyword_set(once_only)

     return
end
