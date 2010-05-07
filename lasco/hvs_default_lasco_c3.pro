;
; Function which defines the LASCO-C3 JP2 encoding parameters for each type
; of measurement
;
; Minimum required Helioviewer Setup (HVS) structure tags.
;
; Let us assume there is a device commonly known by its "nickname",
; but is actually a "detector" which is part of an "instrument" on a
; space or ground based "observatory".  There are "N" different
; measurements possible from the device.  The tags below are the
; minimum required.
;
; a = {observatory: 'AAA',$
;      instrument: 'BBB',$
;      detector: 'CCC',$
;      nickname: 'DDD',$
;      hvs_details_filename: 'XXX',$
;      hvs_details_filename_version: 'Y.Z',$
;      details(N)}
;
; For each of the N measurements, there is a details structure.  The
; structure of the details structure is identical for every
; measurement, but the values can be different for each
; measurement. The tags below are the minimum required.
;
;
; details = {measurement: 'EEE',$
;            n_levels: F,$
;            n_laters: G,$
;            idl_bitdepth: H,$
;            bit_rate: [I,J]}
;
;

FUNCTION HVS_DEFAULT_LASCO_C3
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01]}
;
; In this case, each LASCO-C3 measurement requires the same type of details
;
  a = replicate( d , 1 )
;
; Full description
;
  b = {details:a,$  ; REQUIRED
       observatory:'SOHO',$ ; REQUIRED
       instrument:'LASCO',$ ; REQUIRED
       detector:'C3',$ ; REQUIRED
       nickname:'LASCO-C3',$ ; REQUIRED
       hvs_details_filename:'hvs_default_lasco_c3.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0',$  ; REQUIRED
       gamma_correction:1.00,$ ; 0.380 image gamma correction used in HV_LAS_C3_WRITE_HVS2.pro
       minim:0.87,$ ; BF = 0.8, KS = 0.87
       maxim:1.40,$ ; BF = 1.30, KS = 1.40
       local_quicklook:'/service/soho-archive/soho/private/data/lasco/quicklook/level_05/',$
       alternate_backgrounds:'~/hv/dat/LASCO/alternate_backgrounds/'} ; OPTIONAL - this is an alternate location for the LASCO C3 background.
;
; white-light
;
  b.details[0].measurement = 'white-light'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [4.0,0.01] ; REQUIRED

  return,b
end 
