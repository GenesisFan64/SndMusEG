; ; ====================================================================
; ; MARS Shared Data
; ; ====================================================================
; 
; ; --------------------------------------------
; ; 3D Models
; ; --------------------------------------------
; 
; test_model:
; 		dc.l @faces
; 		dc.l @points
; 		dc.l @material
; 		dc.l -100
; @faces:
; 		incbin "engine/misc/3dtest/cube/face.bin"
; 		cnop 0,4
; @points:
; 		incbin "engine/misc/3dtest/cube/vert.bin"
; 		cnop 0,4
; @material:
; 		;tex_00
;        		dc.l 0
;   		dc.l tex_temporal+(64*64),64,1
;   		dc.l 64,  0
;   		dc.l  0,  0
;   		dc.l  0,64-1
;        		dc.l 64,64-1
;        		
;        		;tex_01
;        		dc.l 1
;   		dc.l tex_temporal,64,1
;   		dc.l 64,  0
;   		dc.l  0,  0
;   		dc.l  0,64-1
;        		dc.l 64,64-1
;        		
; 		dc.l -1
; 		cnop 0,4
; 		
; ; --------------------------------------------
; ; Models data
; ; --------------------------------------------
; 
; tex_temporal:
; 		incbin "engine/misc/3dtest/cube/photo.data"
; 		cnop 0,4
; mars_pal_title:
;  		dc.b 0,0,0
; 		incbin "engine/misc/3dtest/cube/photo.data.pal"
; 		cnop 0,4
; 		
; ; ----------------------------------------------
