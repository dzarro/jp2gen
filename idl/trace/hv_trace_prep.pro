;
; October 8 2013
; 11-Feb-2022, Zarro - optimized memory and added error checking
;
; hv_trace_prep.pro
;
; prepares TRACE data for use with the Helioviewer project.
;
; Cribbed from the TRACE Analysis Guide
;
; http://www.mssl.ucl.ac.uk/surf/guides/tag/tag_top.html
;
;
PRO HV_TRACE_PREP,filename, copy2outgoing=copy2outgoing,verbose=verbose,object=tobj,_ref_extra=extra

 verbose=keyword_set(verbose)
  
 ; HVS information
 info = HVS_TRACE()
 
 if ~obj_valid(tobj) then tobj=obj_new('trace')
 
 ;
 ; Get the measurements as defined in the FITS headers
 ;
 measurement = info.details[*].measurement_in_fits
 nmeasurement = n_elements(measurement)

 nfiles=n_elements(filename)
 if nfiles eq 0 then begin
  if is_blank(files) then err='No files to process.'
  mprint,err  
  return
 endif

 ; read in index from file
 for i=0,nfiles-1 do begin
  if verbose then mprint,'Processing '+filename[i]
  tobj->read,filename[i],-1,index=index,/nodata

  ; split up by measurement
  for j = 0, nmeasurement-1 do begin

     ; filter out the very small images
     ss = where(index.naxis1 gt 128 and index.naxis2 gt 128 and index.wave_len eq measurement[j],count)

     ; if data didn't survive the filtering process then continue to next
     if count eq 0 then begin
      if verbose then mprint,'No matching measurements. Skipping.'
      continue
     endif

     for k=0,count-1 do begin
      tobj->read,filename[i],image_no=ss[k],/wave2point,/unspike,/destreak,/deripple,err=err    
      if is_string(err) then begin
       mprint,err
       continue
      endif
      
      outindex=tobj.index
      outdata=tobj.data

      ; Use log byte scaling to get nice images
      sdata = tobj->scale(outindex,outdata, /log)

      ; for each image, call the JPEG2000 writing code

      hv_trace_prep2jp2,outindex,sdata,jp2_filename=jp2_filename, fitsroot=file_basename(filename[i]),_extra=extra
      
      if keyword_set(copy2outgoing) then HV_COPY2OUTGOING,jp2_filename,_extra=extra
      
     endfor    ;-- end k-loop
  endfor       ;-- end j-loop
endfor         ;-- end i-loop

return
END
