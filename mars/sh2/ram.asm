; ====================================================================
; -----------------------------------------------------------------
; RAM for both CPUs
; -----------------------------------------------------------------

		rsset *

; ----------------------------------------
; CPU communication
; ----------------------------------------

vint_m_sync	rs.l 1
vint_s_sync	rs.l 1
taskfor_master	rs.l 1
taskfor_slave	rs.l 1
taskarg_master	rs.l 14
taskarg_slave	rs.l 14
mars_features	rs.l 1			;bits: 0-3D

; ----------------------------------------
; VDP
; ----------------------------------------

curr_frame	rs.l 1

; ----------------------------------------
; Colors
; ----------------------------------------

pal_buffer	rs.w 256
pal_fadebuff	rs.w 256
pal_priobuff	rs.b 256
palfade_control	rs.l $10

; ----------------------------------------
; PWM
; ----------------------------------------

pwm_samplelist	rs.b sizeof_list*maxsmpl	;64 samples
pwm_channels	rs.b sizeof_chn*maxchnls	;8 channels

; ----------------------------------------
; 3D
; ----------------------------------------

faces_buffer	rs.b sizeof_face*numof_faces
models_buffer	rs.b sizeof_model*numof_models
mstr_faces	rs.l numof_faces		;5 long settings + output dda
slve_faces	rs.l numof_faces		;5 long settings + output dda

left_dda	rs.b sizeof_dda
right_dda	rs.b sizeof_dda
tml_data	rs.b sizeof_tml

left_dda_sl	rs.b sizeof_dda
right_dda_sl	rs.b sizeof_dda
tml_data_sl	rs.b sizeof_tml

temporal_dest	rs.b 3*4

; ====================================================================
; ----------------------------------------
; End
; ----------------------------------------

ram_end		rs.l 0

; ====================================================================

;                     inform 0,"ADDRESS: %h",mstr_faces
;      		inform 0,"%h",sizeof_model+faces_buffer
     		
 		inform 0,"MARS SH2 RAM START/END: %h-%h",(*-CS3),(ram_end-CS3)
		