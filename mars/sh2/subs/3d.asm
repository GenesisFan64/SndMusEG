; =================================================================
; ----------------------------------------
; MARS 3D
;
;
; @model:
;		dc.l @faces
;		dc.l @nodes
;		dc.l @material
;		dc.l -32		; Farest Z to start	
;		
; @nodes:
; 		dc.w 64,64,64		; X Y Z
;
; face options:
;		3 - triangle
;		4 - square
;		other value: end-of-list
; @faces:
;		dc.w 3			; triangle or quad
;		dc.w 0			; texture ID from @material
; 		dc.w 0,12,14		; connect to these @nodes
;
; @material:
; 		dc.l 1			; ID
; 		dc.l 255,0		; Solid color, unused
;        	dc.l 0
;  		dc.l texture,0,0	; texture, width, $xx add
;  		dc.l 128,  0		; texture setup
;  		dc.l   0,  0
;  		dc.l   0,128
;        	dc.l   0,  0		; unused if triangle
;		dc.l -1			; end of list

; SOURCE data format:
; 
; dc.l 3, points_num

; ----------------------------------------
; Variables
; ----------------------------------------

max_width	equ	320
max_height	equ	224
numof_faces	equ	1024
numof_models	equ	32

; ------------------------------------
; TML
; ------------------------------------

		rsreset
tml_dst_y	rs.l	1
tml_bottom_y	rs.l	1

tml_texture	rs.l	1
tml_texwidth	rs.l	1
tml_texadd	rs.l	1
tml_flags	rs.l	1
tml_left	rs.l	1
tml_right	rs.l	1
sizeof_tml	rs.l	0

; ------------------------------------
; DDA
; ------------------------------------

		rsreset
dda_src_point	rs.l	1
dda_src_low	rs.l	1
dda_src_high	rs.l	1
dda_src_x	rs.l	1
dda_src_dx	rs.l	1
dda_src_y	rs.l	1
dda_src_dy	rs.l	1

dda_dst_point	rs.l	1
dda_dst_low	rs.l	1
dda_dst_high	rs.l	1
dda_dst_x	rs.l	1
dda_dst_dx	rs.l	1
dda_dst_h	rs.l	1
sizeof_dda	rs.l	0

; ------------------------------------
; Points
; for both source and destination
; ------------------------------------

		rsreset
point_x		rs.l	1
point_y		rs.l	1
sizeof_point	rs.l	0

; ------------------------------------
; Playfield buffer
; ------------------------------------

		rsreset
world_x		rs.l	1
world_y		rs.l	1
world_z		rs.l	1
world_x_rot	rs.l	1
world_y_rot	rs.l	1
world_z_rot	rs.l	1

; ------------------------------------
; Models buffer
; ------------------------------------

		rsreset
model_addr	rs.l	1
model_x		rs.l	1
model_y		rs.l	1
model_z		rs.l	1
model_x_rot	rs.l	1
model_y_rot	rs.l	1
model_z_rot	rs.l	1				; NOT DONE
; model_z_start	rs.l	1				; MAX Z back to check
model_flags	rs.l	1				; 0 - normal, 1 - world algorithm NOT DONE
sizeof_model	rs.l	0
;     		inform 0,"%h",sizeof_model

; ------------------------------------
; Faces buffer
; ------------------------------------

		rsreset
faces_used	rs.l	1
faces_data	rs.l	1

		rsreset
face_flags	rs.l	1
face_tex	rs.l	1
face_tex_add	rs.l	1
face_tex_width	rs.l	1
faces_type	rs.l	1
faces_srcaddr	rs.l	1
face_points	rs.l	3*4
sizeof_face	rs.l	0

; =================================================================
; ----------------------------------------
; Data
; ----------------------------------------

sin_table	dc.l $00000000,$000000c9,$00000192,$0000025b
		dc.l $00000324,$000003ed,$000004b6,$0000057f
		dc.l $00000648,$00000711,$000007da,$000008a3
		dc.l $0000096c,$00000a35,$00000afe,$00000bc6
		dc.l $00000c8f,$00000d58,$00000e21,$00000eea
		dc.l $00000fb2,$0000107b,$00001144,$0000120c
		dc.l $000012d5,$0000139d,$00001466,$0000152e
		dc.l $000015f6,$000016bf,$00001787,$0000184f
		dc.l $00001917,$000019df,$00001aa7,$00001b6f
		dc.l $00001c37,$00001cff,$00001dc7,$00001e8e
		dc.l $00001f56,$0000201d,$000020e5,$000021ac
		dc.l $00002273,$0000233b,$00002402,$000024c9
		dc.l $00002590,$00002656,$0000271d,$000027e4
		dc.l $000028aa,$00002971,$00002a37,$00002afe
		dc.l $00002bc4,$00002c8a,$00002d50,$00002e15
		dc.l $00002edb,$00002fa1,$00003066,$0000312c
		dc.l $000031f1,$000032b6,$0000337b,$00003440
		dc.l $00003505,$000035c9,$0000368e,$00003752
		dc.l $00003817,$000038db,$0000399f,$00003a62
		dc.l $00003b26,$00003bea,$00003cad,$00003d70
		dc.l $00003e33,$00003ef6,$00003fb9,$0000407c
		dc.l $0000413e,$00004201,$000042c3,$00004385
		dc.l $00004447,$00004508,$000045ca,$0000468b
		dc.l $0000474d,$0000480e,$000048ce,$0000498f
		dc.l $00004a50,$00004b10,$00004bd0,$00004c90
		dc.l $00004d50,$00004e0f,$00004ecf,$00004f8e
		dc.l $0000504d,$0000510c,$000051ca,$00005289
		dc.l $00005347,$00005405,$000054c3,$00005581
		dc.l $0000563e,$000056fb,$000057b8,$00005875
		dc.l $00005931,$000059ee,$00005aaa,$00005b66
		dc.l $00005c22,$00005cdd,$00005d98,$00005e53
		dc.l $00005f0e,$00005fc9,$00006083,$0000613d
		dc.l $000061f7,$000062b1,$0000636a,$00006423
		dc.l $000064dc,$00006595,$0000664d,$00006705
		dc.l $000067bd,$00006875,$0000692d,$000069e4
		dc.l $00006a9b,$00006b51,$00006c08,$00006cbe
		dc.l $00006d74,$00006e29,$00006edf,$00006f94
		dc.l $00007049,$000070fd,$000071b1,$00007265
		dc.l $00007319,$000073cd,$00007480,$00007533
		dc.l $000075e5,$00007698,$0000774a,$000077fb
		dc.l $000078ad,$0000795e,$00007a0f,$00007ac0
		dc.l $00007b70,$00007c20,$00007cd0,$00007d7f
		dc.l $00007e2e,$00007edd,$00007f8b,$0000803a
		dc.l $000080e7,$00008195,$00008242,$000082ef
		dc.l $0000839c,$00008448,$000084f4,$000085a0
		dc.l $0000864b,$000086f6,$000087a1,$0000884b
		dc.l $000088f5,$0000899f,$00008a48,$00008af1
		dc.l $00008b9a,$00008c42,$00008cea,$00008d92
		dc.l $00008e39,$00008ee0,$00008f87,$0000902d
		dc.l $000090d3,$00009179,$0000921e,$000092c3
		dc.l $00009368,$0000940c,$000094b0,$00009553
		dc.l $000095f6,$00009699,$0000973c,$000097de
		dc.l $0000987f,$00009921,$000099c2,$00009a62
		dc.l $00009b02,$00009ba2,$00009c42,$00009ce1
		dc.l $00009d7f,$00009e1e,$00009ebc,$00009f59
		dc.l $00009ff6,$0000a093,$0000a12f,$0000a1cb
		dc.l $0000a267,$0000a302,$0000a39d,$0000a438
		dc.l $0000a4d2,$0000a56b,$0000a605,$0000a69d
		dc.l $0000a736,$0000a7ce,$0000a866,$0000a8fd
		dc.l $0000a994,$0000aa2a,$0000aac0,$0000ab56
		dc.l $0000abeb,$0000ac80,$0000ad14,$0000ada8
		dc.l $0000ae3b,$0000aece,$0000af61,$0000aff3
		dc.l $0000b085,$0000b117,$0000b1a8,$0000b238
		dc.l $0000b2c8,$0000b358,$0000b3e7,$0000b476
		dc.l $0000b504,$0000b592,$0000b620,$0000b6ad
		dc.l $0000b73a,$0000b7c6,$0000b852,$0000b8dd
		dc.l $0000b968,$0000b9f2,$0000ba7c,$0000bb06
		dc.l $0000bb8f,$0000bc17,$0000bca0,$0000bd27
		dc.l $0000bdae,$0000be35,$0000bebc,$0000bf41
		dc.l $0000bfc7,$0000c04c,$0000c0d0,$0000c154
		dc.l $0000c1d8,$0000c25b,$0000c2de,$0000c360
		dc.l $0000c3e2,$0000c463,$0000c4e3,$0000c564
		dc.l $0000c5e4,$0000c663,$0000c6e2,$0000c760
		dc.l $0000c7de,$0000c85b,$0000c8d8,$0000c955
		dc.l $0000c9d1,$0000ca4c,$0000cac7,$0000cb41
		dc.l $0000cbbb,$0000cc35,$0000ccae,$0000cd26
		dc.l $0000cd9f,$0000ce16,$0000ce8d,$0000cf04
		dc.l $0000cf7a,$0000cfef,$0000d064,$0000d0d9
		dc.l $0000d14d,$0000d1c0,$0000d233,$0000d2a6
		dc.l $0000d318,$0000d389,$0000d3fa,$0000d46b
		dc.l $0000d4db,$0000d54a,$0000d5b9,$0000d627
		dc.l $0000d695,$0000d703,$0000d770,$0000d7dc
		dc.l $0000d848,$0000d8b3,$0000d91e,$0000d988
		dc.l $0000d9f2,$0000da5b,$0000dac4,$0000db2c
		dc.l $0000db94,$0000dbfb,$0000dc61,$0000dcc7
		dc.l $0000dd2d,$0000dd92,$0000ddf6,$0000de5a
		dc.l $0000debe,$0000df20,$0000df83,$0000dfe4
		dc.l $0000e046,$0000e0a6,$0000e106,$0000e166
		dc.l $0000e1c5,$0000e224,$0000e282,$0000e2df
		dc.l $0000e33c,$0000e398,$0000e3f4,$0000e44f
		dc.l $0000e4aa,$0000e504,$0000e55e,$0000e5b7
		dc.l $0000e60f,$0000e667,$0000e6be,$0000e715
		dc.l $0000e76b,$0000e7c1,$0000e816,$0000e86b
		dc.l $0000e8bf,$0000e912,$0000e965,$0000e9b7
		dc.l $0000ea09,$0000ea5a,$0000eaab,$0000eafb
		dc.l $0000eb4b,$0000eb99,$0000ebe8,$0000ec36
		dc.l $0000ec83,$0000ecd0,$0000ed1c,$0000ed67
		dc.l $0000edb2,$0000edfc,$0000ee46,$0000ee8f
		dc.l $0000eed8,$0000ef20,$0000ef68,$0000efaf
		dc.l $0000eff5,$0000f03b,$0000f080,$0000f0c5
		dc.l $0000f109,$0000f14c,$0000f18f,$0000f1d1
		dc.l $0000f213,$0000f254,$0000f294,$0000f2d4
		dc.l $0000f314,$0000f353,$0000f391,$0000f3ce
		dc.l $0000f40b,$0000f448,$0000f484,$0000f4bf
		dc.l $0000f4fa,$0000f534,$0000f56d,$0000f5a6
		dc.l $0000f5de,$0000f616,$0000f64d,$0000f684
		dc.l $0000f6ba,$0000f6ef,$0000f724,$0000f758
		dc.l $0000f78b,$0000f7be,$0000f7f1,$0000f822
		dc.l $0000f853,$0000f884,$0000f8b4,$0000f8e3
		dc.l $0000f912,$0000f940,$0000f96e,$0000f99b
		dc.l $0000f9c7,$0000f9f3,$0000fa1e,$0000fa49
		dc.l $0000fa73,$0000fa9c,$0000fac5,$0000faed
		dc.l $0000fb14,$0000fb3b,$0000fb61,$0000fb87
		dc.l $0000fbac,$0000fbd1,$0000fbf5,$0000fc18
		dc.l $0000fc3b,$0000fc5d,$0000fc7e,$0000fc9f
		dc.l $0000fcbf,$0000fcdf,$0000fcfe,$0000fd1c
		dc.l $0000fd3a,$0000fd57,$0000fd74,$0000fd90
		dc.l $0000fdab,$0000fdc6,$0000fde0,$0000fdfa
		dc.l $0000fe13,$0000fe2b,$0000fe43,$0000fe5a
		dc.l $0000fe70,$0000fe86,$0000fe9b,$0000feb0
		dc.l $0000fec4,$0000fed7,$0000feea,$0000fefc
		dc.l $0000ff0e,$0000ff1f,$0000ff2f,$0000ff3f
		dc.l $0000ff4e,$0000ff5c,$0000ff6a,$0000ff78
		dc.l $0000ff84,$0000ff90,$0000ff9c,$0000ffa6
		dc.l $0000ffb1,$0000ffba,$0000ffc3,$0000ffcb
		dc.l $0000ffd3,$0000ffda,$0000ffe1,$0000ffe7
		dc.l $0000ffec,$0000fff0,$0000fff4,$0000fff8
		dc.l $0000fffb,$0000fffd,$0000fffe,$0000ffff
		
cos_table	dc.l $00010000,$0000ffff,$0000fffe,$0000fffd
		dc.l $0000fffb,$0000fff8,$0000fff4,$0000fff0
		dc.l $0000ffec,$0000ffe7,$0000ffe1,$0000ffda
		dc.l $0000ffd3,$0000ffcb,$0000ffc3,$0000ffba
		dc.l $0000ffb1,$0000ffa6,$0000ff9c,$0000ff90
		dc.l $0000ff84,$0000ff78,$0000ff6a,$0000ff5c
		dc.l $0000ff4e,$0000ff3f,$0000ff2f,$0000ff1f
		dc.l $0000ff0e,$0000fefc,$0000feea,$0000fed7
		dc.l $0000fec4,$0000feb0,$0000fe9b,$0000fe86
		dc.l $0000fe70,$0000fe5a,$0000fe43,$0000fe2b
		dc.l $0000fe13,$0000fdfa,$0000fde0,$0000fdc6
		dc.l $0000fdab,$0000fd90,$0000fd74,$0000fd57
		dc.l $0000fd3a,$0000fd1c,$0000fcfe,$0000fcdf
		dc.l $0000fcbf,$0000fc9f,$0000fc7e,$0000fc5d
		dc.l $0000fc3b,$0000fc18,$0000fbf5,$0000fbd1
		dc.l $0000fbac,$0000fb87,$0000fb61,$0000fb3b
		dc.l $0000fb14,$0000faed,$0000fac5,$0000fa9c
		dc.l $0000fa73,$0000fa49,$0000fa1e,$0000f9f3
		dc.l $0000f9c7,$0000f99b,$0000f96e,$0000f940
		dc.l $0000f912,$0000f8e3,$0000f8b4,$0000f884
		dc.l $0000f853,$0000f822,$0000f7f1,$0000f7be
		dc.l $0000f78b,$0000f758,$0000f724,$0000f6ef
		dc.l $0000f6ba,$0000f684,$0000f64d,$0000f616
		dc.l $0000f5de,$0000f5a6,$0000f56d,$0000f534
		dc.l $0000f4fa,$0000f4bf,$0000f484,$0000f448
		dc.l $0000f40b,$0000f3ce,$0000f391,$0000f353
		dc.l $0000f314,$0000f2d4,$0000f294,$0000f254
		dc.l $0000f213,$0000f1d1,$0000f18f,$0000f14c
		dc.l $0000f109,$0000f0c5,$0000f080,$0000f03b
		dc.l $0000eff5,$0000efaf,$0000ef68,$0000ef20
		dc.l $0000eed8,$0000ee8f,$0000ee46,$0000edfc
		dc.l $0000edb2,$0000ed67,$0000ed1c,$0000ecd0
		dc.l $0000ec83,$0000ec36,$0000ebe8,$0000eb99
		dc.l $0000eb4b,$0000eafb,$0000eaab,$0000ea5a
		dc.l $0000ea09,$0000e9b7,$0000e965,$0000e912
		dc.l $0000e8bf,$0000e86b,$0000e816,$0000e7c1
		dc.l $0000e76b,$0000e715,$0000e6be,$0000e667
		dc.l $0000e60f,$0000e5b7,$0000e55e,$0000e504
		dc.l $0000e4aa,$0000e44f,$0000e3f4,$0000e398
		dc.l $0000e33c,$0000e2df,$0000e282,$0000e224
		dc.l $0000e1c5,$0000e166,$0000e106,$0000e0a6
		dc.l $0000e046,$0000dfe4,$0000df83,$0000df20
		dc.l $0000debe,$0000de5a,$0000ddf6,$0000dd92
		dc.l $0000dd2d,$0000dcc7,$0000dc61,$0000dbfb
		dc.l $0000db94,$0000db2c,$0000dac4,$0000da5b
		dc.l $0000d9f2,$0000d988,$0000d91e,$0000d8b3
		dc.l $0000d848,$0000d7dc,$0000d770,$0000d703
		dc.l $0000d695,$0000d627,$0000d5b9,$0000d54a
		dc.l $0000d4db,$0000d46b,$0000d3fa,$0000d389
		dc.l $0000d318,$0000d2a6,$0000d233,$0000d1c0
		dc.l $0000d14d,$0000d0d9,$0000d064,$0000cfef
		dc.l $0000cf7a,$0000cf04,$0000ce8d,$0000ce16
		dc.l $0000cd9f,$0000cd26,$0000ccae,$0000cc35
		dc.l $0000cbbb,$0000cb41,$0000cac7,$0000ca4c
		dc.l $0000c9d1,$0000c955,$0000c8d8,$0000c85b
		dc.l $0000c7de,$0000c760,$0000c6e2,$0000c663
		dc.l $0000c5e4,$0000c564,$0000c4e3,$0000c463
		dc.l $0000c3e2,$0000c360,$0000c2de,$0000c25b
		dc.l $0000c1d8,$0000c154,$0000c0d0,$0000c04c
		dc.l $0000bfc7,$0000bf41,$0000bebc,$0000be35
		dc.l $0000bdae,$0000bd27,$0000bca0,$0000bc17
		dc.l $0000bb8f,$0000bb06,$0000ba7c,$0000b9f2
		dc.l $0000b968,$0000b8dd,$0000b852,$0000b7c6
		dc.l $0000b73a,$0000b6ad,$0000b620,$0000b592
		dc.l $0000b504,$0000b476,$0000b3e7,$0000b358
		dc.l $0000b2c8,$0000b238,$0000b1a8,$0000b117
		dc.l $0000b085,$0000aff3,$0000af61,$0000aece
		dc.l $0000ae3b,$0000ada8,$0000ad14,$0000ac80
		dc.l $0000abeb,$0000ab56,$0000aac0,$0000aa2a
		dc.l $0000a994,$0000a8fd,$0000a866,$0000a7ce
		dc.l $0000a736,$0000a69d,$0000a605,$0000a56b
		dc.l $0000a4d2,$0000a438,$0000a39d,$0000a302
		dc.l $0000a267,$0000a1cb,$0000a12f,$0000a093
		dc.l $00009ff6,$00009f59,$00009ebc,$00009e1e
		dc.l $00009d7f,$00009ce1,$00009c42,$00009ba2
		dc.l $00009b02,$00009a62,$000099c2,$00009921
		dc.l $0000987f,$000097de,$0000973c,$00009699
		dc.l $000095f6,$00009553,$000094b0,$0000940c
		dc.l $00009368,$000092c3,$0000921e,$00009179
		dc.l $000090d3,$0000902d,$00008f87,$00008ee0
		dc.l $00008e39,$00008d92,$00008cea,$00008c42
		dc.l $00008b9a,$00008af1,$00008a48,$0000899f
		dc.l $000088f5,$0000884b,$000087a1,$000086f6
		dc.l $0000864b,$000085a0,$000084f4,$00008448
		dc.l $0000839c,$000082ef,$00008242,$00008195
		dc.l $000080e7,$0000803a,$00007f8b,$00007edd
		dc.l $00007e2e,$00007d7f,$00007cd0,$00007c20
		dc.l $00007b70,$00007ac0,$00007a0f,$0000795e
		dc.l $000078ad,$000077fb,$0000774a,$00007698
		dc.l $000075e5,$00007533,$00007480,$000073cd
		dc.l $00007319,$00007265,$000071b1,$000070fd
		dc.l $00007049,$00006f94,$00006edf,$00006e29
		dc.l $00006d74,$00006cbe,$00006c08,$00006b51
		dc.l $00006a9b,$000069e4,$0000692d,$00006875
		dc.l $000067bd,$00006705,$0000664d,$00006595
		dc.l $000064dc,$00006423,$0000636a,$000062b1
		dc.l $000061f7,$0000613d,$00006083,$00005fc9
		dc.l $00005f0e,$00005e53,$00005d98,$00005cdd
		dc.l $00005c22,$00005b66,$00005aaa,$000059ee
		dc.l $00005931,$00005875,$000057b8,$000056fb
		dc.l $0000563e,$00005581,$000054c3,$00005405
		dc.l $00005347,$00005289,$000051ca,$0000510c
		dc.l $0000504d,$00004f8e,$00004ecf,$00004e0f
		dc.l $00004d50,$00004c90,$00004bd0,$00004b10
		dc.l $00004a50,$0000498f,$000048ce,$0000480e
		dc.l $0000474d,$0000468b,$000045ca,$00004508
		dc.l $00004447,$00004385,$000042c3,$00004201
		dc.l $0000413e,$0000407c,$00003fb9,$00003ef6
		dc.l $00003e33,$00003d70,$00003cad,$00003bea
		dc.l $00003b26,$00003a62,$0000399f,$000038db
		dc.l $00003817,$00003752,$0000368e,$000035c9
		dc.l $00003505,$00003440,$0000337b,$000032b6
		dc.l $000031f1,$0000312c,$00003066,$00002fa1
		dc.l $00002edb,$00002e15,$00002d50,$00002c8a
		dc.l $00002bc4,$00002afe,$00002a37,$00002971
		dc.l $000028aa,$000027e4,$0000271d,$00002656
		dc.l $00002590,$000024c9,$00002402,$0000233b
		dc.l $00002273,$000021ac,$000020e5,$0000201d
		dc.l $00001f56,$00001e8e,$00001dc7,$00001cff
		dc.l $00001c37,$00001b6f,$00001aa7,$000019df
		dc.l $00001917,$0000184f,$00001787,$000016bf
		dc.l $000015f6,$0000152e,$00001466,$0000139d
		dc.l $000012d5,$0000120c,$00001144,$0000107b
		dc.l $00000fb2,$00000eea,$00000e21,$00000d58
		dc.l $00000c8f,$00000bc6,$00000afe,$00000a35
		dc.l $0000096c,$000008a3,$000007da,$00000711
		dc.l $00000648,$0000057f,$000004b6,$000003ed
		dc.l $00000324,$0000025b,$00000192,$000000c9
		dc.l $00000000,$ffffff37,$fffffe6e,$fffffda5
		dc.l $fffffcdc,$fffffc13,$fffffb4a,$fffffa81
		dc.l $fffff9b8,$fffff8ef,$fffff826,$fffff75d
		dc.l $fffff694,$fffff5cb,$fffff502,$fffff43a
		dc.l $fffff371,$fffff2a8,$fffff1df,$fffff116
		dc.l $fffff04e,$ffffef85,$ffffeebc,$ffffedf4
		dc.l $ffffed2b,$ffffec63,$ffffeb9a,$ffffead2
		dc.l $ffffea0a,$ffffe941,$ffffe879,$ffffe7b1
		dc.l $ffffe6e9,$ffffe621,$ffffe559,$ffffe491
		dc.l $ffffe3c9,$ffffe301,$ffffe239,$ffffe172
		dc.l $ffffe0aa,$ffffdfe3,$ffffdf1b,$ffffde54
		dc.l $ffffdd8d,$ffffdcc5,$ffffdbfe,$ffffdb37
		dc.l $ffffda70,$ffffd9aa,$ffffd8e3,$ffffd81c
		dc.l $ffffd756,$ffffd68f,$ffffd5c9,$ffffd502
		dc.l $ffffd43c,$ffffd376,$ffffd2b0,$ffffd1eb
		dc.l $ffffd125,$ffffd05f,$ffffcf9a,$ffffced4
		dc.l $ffffce0f,$ffffcd4a,$ffffcc85,$ffffcbc0
		dc.l $ffffcafb,$ffffca37,$ffffc972,$ffffc8ae
		dc.l $ffffc7e9,$ffffc725,$ffffc661,$ffffc59e
		dc.l $ffffc4da,$ffffc416,$ffffc353,$ffffc290
		dc.l $ffffc1cd,$ffffc10a,$ffffc047,$ffffbf84
		dc.l $ffffbec2,$ffffbdff,$ffffbd3d,$ffffbc7b
		dc.l $ffffbbb9,$ffffbaf8,$ffffba36,$ffffb975
		dc.l $ffffb8b3,$ffffb7f2,$ffffb732,$ffffb671
		dc.l $ffffb5b0,$ffffb4f0,$ffffb430,$ffffb370
		dc.l $ffffb2b0,$ffffb1f1,$ffffb131,$ffffb072
		dc.l $ffffafb3,$ffffaef4,$ffffae36,$ffffad77
		dc.l $ffffacb9,$ffffabfb,$ffffab3d,$ffffaa7f
		dc.l $ffffa9c2,$ffffa905,$ffffa848,$ffffa78b
		dc.l $ffffa6cf,$ffffa612,$ffffa556,$ffffa49a
		dc.l $ffffa3de,$ffffa323,$ffffa268,$ffffa1ad
		dc.l $ffffa0f2,$ffffa037,$ffff9f7d,$ffff9ec3
		dc.l $ffff9e09,$ffff9d4f,$ffff9c96,$ffff9bdd
		dc.l $ffff9b24,$ffff9a6b,$ffff99b3,$ffff98fb
		dc.l $ffff9843,$ffff978b,$ffff96d3,$ffff961c
		dc.l $ffff9565,$ffff94af,$ffff93f8,$ffff9342
		dc.l $ffff928c,$ffff91d7,$ffff9121,$ffff906c
		dc.l $ffff8fb7,$ffff8f03,$ffff8e4f,$ffff8d9b
		dc.l $ffff8ce7,$ffff8c33,$ffff8b80,$ffff8acd
		dc.l $ffff8a1b,$ffff8968,$ffff88b6,$ffff8805
		dc.l $ffff8753,$ffff86a2,$ffff85f1,$ffff8540
		dc.l $ffff8490,$ffff83e0,$ffff8330,$ffff8281
		dc.l $ffff81d2,$ffff8123,$ffff8075,$ffff7fc6
		dc.l $ffff7f19,$ffff7e6b,$ffff7dbe,$ffff7d11
		dc.l $ffff7c64,$ffff7bb8,$ffff7b0c,$ffff7a60
		dc.l $ffff79b5,$ffff790a,$ffff785f,$ffff77b5
		dc.l $ffff770b,$ffff7661,$ffff75b8,$ffff750f
		dc.l $ffff7466,$ffff73be,$ffff7316,$ffff726e
		dc.l $ffff71c7,$ffff7120,$ffff7079,$ffff6fd3
		dc.l $ffff6f2d,$ffff6e87,$ffff6de2,$ffff6d3d
		dc.l $ffff6c98,$ffff6bf4,$ffff6b50,$ffff6aad
		dc.l $ffff6a0a,$ffff6967,$ffff68c4,$ffff6822
		dc.l $ffff6781,$ffff66df,$ffff663e,$ffff659e
		dc.l $ffff64fe,$ffff645e,$ffff63be,$ffff631f
		dc.l $ffff6281,$ffff61e2,$ffff6144,$ffff60a7
		dc.l $ffff600a,$ffff5f6d,$ffff5ed1,$ffff5e35
		dc.l $ffff5d99,$ffff5cfe,$ffff5c63,$ffff5bc8
		dc.l $ffff5b2e,$ffff5a95,$ffff59fb,$ffff5963
		dc.l $ffff58ca,$ffff5832,$ffff579a,$ffff5703
		dc.l $ffff566c,$ffff55d6,$ffff5540,$ffff54aa
		dc.l $ffff5415,$ffff5380,$ffff52ec,$ffff5258
		dc.l $ffff51c5,$ffff5132,$ffff509f,$ffff500d
		dc.l $ffff4f7b,$ffff4ee9,$ffff4e58,$ffff4dc8
		dc.l $ffff4d38,$ffff4ca8,$ffff4c19,$ffff4b8a
		dc.l $ffff4afc,$ffff4a6e,$ffff49e0,$ffff4953
		dc.l $ffff48c6,$ffff483a,$ffff47ae,$ffff4723
		dc.l $ffff4698,$ffff460e,$ffff4584,$ffff44fa
		dc.l $ffff4471,$ffff43e9,$ffff4360,$ffff42d9
		dc.l $ffff4252,$ffff41cb,$ffff4144,$ffff40bf
		dc.l $ffff4039,$ffff3fb4,$ffff3f30,$ffff3eac
		dc.l $ffff3e28,$ffff3da5,$ffff3d22,$ffff3ca0
		dc.l $ffff3c1e,$ffff3b9d,$ffff3b1d,$ffff3a9c
		dc.l $ffff3a1c,$ffff399d,$ffff391e,$ffff38a0
		dc.l $ffff3822,$ffff37a5,$ffff3728,$ffff36ab
		dc.l $ffff362f,$ffff35b4,$ffff3539,$ffff34bf
		dc.l $ffff3445,$ffff33cb,$ffff3352,$ffff32da
		dc.l $ffff3261,$ffff31ea,$ffff3173,$ffff30fc
		dc.l $ffff3086,$ffff3011,$ffff2f9c,$ffff2f27
		dc.l $ffff2eb3,$ffff2e40,$ffff2dcd,$ffff2d5a
		dc.l $ffff2ce8,$ffff2c77,$ffff2c06,$ffff2b95
		dc.l $ffff2b25,$ffff2ab6,$ffff2a47,$ffff29d9
		dc.l $ffff296b,$ffff28fd,$ffff2890,$ffff2824
		dc.l $ffff27b8,$ffff274d,$ffff26e2,$ffff2678
		dc.l $ffff260e,$ffff25a5,$ffff253c,$ffff24d4
		dc.l $ffff246c,$ffff2405,$ffff239f,$ffff2339
		dc.l $ffff22d3,$ffff226e,$ffff220a,$ffff21a6
		dc.l $ffff2142,$ffff20e0,$ffff207d,$ffff201c
		dc.l $ffff1fba,$ffff1f5a,$ffff1efa,$ffff1e9a
		dc.l $ffff1e3b,$ffff1ddc,$ffff1d7e,$ffff1d21
		dc.l $ffff1cc4,$ffff1c68,$ffff1c0c,$ffff1bb1
		dc.l $ffff1b56,$ffff1afc,$ffff1aa2,$ffff1a49
		dc.l $ffff19f1,$ffff1999,$ffff1942,$ffff18eb
		dc.l $ffff1895,$ffff183f,$ffff17ea,$ffff1795
		dc.l $ffff1741,$ffff16ee,$ffff169b,$ffff1649
		dc.l $ffff15f7,$ffff15a6,$ffff1555,$ffff1505
		dc.l $ffff14b5,$ffff1467,$ffff1418,$ffff13ca
		dc.l $ffff137d,$ffff1330,$ffff12e4,$ffff1299
		dc.l $ffff124e,$ffff1204,$ffff11ba,$ffff1171
		dc.l $ffff1128,$ffff10e0,$ffff1098,$ffff1051
		dc.l $ffff100b,$ffff0fc5,$ffff0f80,$ffff0f3b
		dc.l $ffff0ef7,$ffff0eb4,$ffff0e71,$ffff0e2f
		dc.l $ffff0ded,$ffff0dac,$ffff0d6c,$ffff0d2c
		dc.l $ffff0cec,$ffff0cad,$ffff0c6f,$ffff0c32
		dc.l $ffff0bf5,$ffff0bb8,$ffff0b7c,$ffff0b41
		dc.l $ffff0b06,$ffff0acc,$ffff0a93,$ffff0a5a
		dc.l $ffff0a22,$ffff09ea,$ffff09b3,$ffff097c
		dc.l $ffff0946,$ffff0911,$ffff08dc,$ffff08a8
		dc.l $ffff0875,$ffff0842,$ffff080f,$ffff07de
		dc.l $ffff07ad,$ffff077c,$ffff074c,$ffff071d
		dc.l $ffff06ee,$ffff06c0,$ffff0692,$ffff0665
		dc.l $ffff0639,$ffff060d,$ffff05e2,$ffff05b7
		dc.l $ffff058d,$ffff0564,$ffff053b,$ffff0513
		dc.l $ffff04ec,$ffff04c5,$ffff049f,$ffff0479
		dc.l $ffff0454,$ffff042f,$ffff040b,$ffff03e8
		dc.l $ffff03c5,$ffff03a3,$ffff0382,$ffff0361
		dc.l $ffff0341,$ffff0321,$ffff0302,$ffff02e4
		dc.l $ffff02c6,$ffff02a9,$ffff028c,$ffff0270
		dc.l $ffff0255,$ffff023a,$ffff0220,$ffff0206
		dc.l $ffff01ed,$ffff01d5,$ffff01bd,$ffff01a6
		dc.l $ffff0190,$ffff017a,$ffff0165,$ffff0150
		dc.l $ffff013c,$ffff0129,$ffff0116,$ffff0104
		dc.l $ffff00f2,$ffff00e1,$ffff00d1,$ffff00c1
		dc.l $ffff00b2,$ffff00a4,$ffff0096,$ffff0088
		dc.l $ffff007c,$ffff0070,$ffff0064,$ffff005a
		dc.l $ffff004f,$ffff0046,$ffff003d,$ffff0035
		dc.l $ffff002d,$ffff0026,$ffff001f,$ffff0019
		dc.l $ffff0014,$ffff0010,$ffff000c,$ffff0008
		dc.l $ffff0005,$ffff0003,$ffff0002,$ffff0001
		dc.l $ffff0000,$ffff0001,$ffff0002,$ffff0003
		dc.l $ffff0005,$ffff0008,$ffff000c,$ffff0010
		dc.l $ffff0014,$ffff0019,$ffff001f,$ffff0026
		dc.l $ffff002d,$ffff0035,$ffff003d,$ffff0046
		dc.l $ffff004f,$ffff005a,$ffff0064,$ffff0070
		dc.l $ffff007c,$ffff0088,$ffff0096,$ffff00a4
		dc.l $ffff00b2,$ffff00c1,$ffff00d1,$ffff00e1
		dc.l $ffff00f2,$ffff0104,$ffff0116,$ffff0129
		dc.l $ffff013c,$ffff0150,$ffff0165,$ffff017a
		dc.l $ffff0190,$ffff01a6,$ffff01bd,$ffff01d5
		dc.l $ffff01ed,$ffff0206,$ffff0220,$ffff023a
		dc.l $ffff0255,$ffff0270,$ffff028c,$ffff02a9
		dc.l $ffff02c6,$ffff02e4,$ffff0302,$ffff0321
		dc.l $ffff0341,$ffff0361,$ffff0382,$ffff03a3
		dc.l $ffff03c5,$ffff03e8,$ffff040b,$ffff042f
		dc.l $ffff0454,$ffff0479,$ffff049f,$ffff04c5
		dc.l $ffff04ec,$ffff0513,$ffff053b,$ffff0564
		dc.l $ffff058d,$ffff05b7,$ffff05e2,$ffff060d
		dc.l $ffff0639,$ffff0665,$ffff0692,$ffff06c0
		dc.l $ffff06ee,$ffff071d,$ffff074c,$ffff077c
		dc.l $ffff07ad,$ffff07de,$ffff080f,$ffff0842
		dc.l $ffff0875,$ffff08a8,$ffff08dc,$ffff0911
		dc.l $ffff0946,$ffff097c,$ffff09b3,$ffff09ea
		dc.l $ffff0a22,$ffff0a5a,$ffff0a93,$ffff0acc
		dc.l $ffff0b06,$ffff0b41,$ffff0b7c,$ffff0bb8
		dc.l $ffff0bf5,$ffff0c32,$ffff0c6f,$ffff0cad
		dc.l $ffff0cec,$ffff0d2c,$ffff0d6c,$ffff0dac
		dc.l $ffff0ded,$ffff0e2f,$ffff0e71,$ffff0eb4
		dc.l $ffff0ef7,$ffff0f3b,$ffff0f80,$ffff0fc5
		dc.l $ffff100b,$ffff1051,$ffff1098,$ffff10e0
		dc.l $ffff1128,$ffff1171,$ffff11ba,$ffff1204
		dc.l $ffff124e,$ffff1299,$ffff12e4,$ffff1330
		dc.l $ffff137d,$ffff13ca,$ffff1418,$ffff1467
		dc.l $ffff14b5,$ffff1505,$ffff1555,$ffff15a6
		dc.l $ffff15f7,$ffff1649,$ffff169b,$ffff16ee
		dc.l $ffff1741,$ffff1795,$ffff17ea,$ffff183f
		dc.l $ffff1895,$ffff18eb,$ffff1942,$ffff1999
		dc.l $ffff19f1,$ffff1a49,$ffff1aa2,$ffff1afc
		dc.l $ffff1b56,$ffff1bb1,$ffff1c0c,$ffff1c68
		dc.l $ffff1cc4,$ffff1d21,$ffff1d7e,$ffff1ddc
		dc.l $ffff1e3b,$ffff1e9a,$ffff1efa,$ffff1f5a
		dc.l $ffff1fba,$ffff201c,$ffff207d,$ffff20e0
		dc.l $ffff2142,$ffff21a6,$ffff220a,$ffff226e
		dc.l $ffff22d3,$ffff2339,$ffff239f,$ffff2405
		dc.l $ffff246c,$ffff24d4,$ffff253c,$ffff25a5
		dc.l $ffff260e,$ffff2678,$ffff26e2,$ffff274d
		dc.l $ffff27b8,$ffff2824,$ffff2890,$ffff28fd
		dc.l $ffff296b,$ffff29d9,$ffff2a47,$ffff2ab6
		dc.l $ffff2b25,$ffff2b95,$ffff2c06,$ffff2c77
		dc.l $ffff2ce8,$ffff2d5a,$ffff2dcd,$ffff2e40
		dc.l $ffff2eb3,$ffff2f27,$ffff2f9c,$ffff3011
		dc.l $ffff3086,$ffff30fc,$ffff3173,$ffff31ea
		dc.l $ffff3261,$ffff32da,$ffff3352,$ffff33cb
		dc.l $ffff3445,$ffff34bf,$ffff3539,$ffff35b4
		dc.l $ffff362f,$ffff36ab,$ffff3728,$ffff37a5
		dc.l $ffff3822,$ffff38a0,$ffff391e,$ffff399d
		dc.l $ffff3a1c,$ffff3a9c,$ffff3b1d,$ffff3b9d
		dc.l $ffff3c1e,$ffff3ca0,$ffff3d22,$ffff3da5
		dc.l $ffff3e28,$ffff3eac,$ffff3f30,$ffff3fb4
		dc.l $ffff4039,$ffff40bf,$ffff4144,$ffff41cb
		dc.l $ffff4252,$ffff42d9,$ffff4360,$ffff43e9
		dc.l $ffff4471,$ffff44fa,$ffff4584,$ffff460e
		dc.l $ffff4698,$ffff4723,$ffff47ae,$ffff483a
		dc.l $ffff48c6,$ffff4953,$ffff49e0,$ffff4a6e
		dc.l $ffff4afc,$ffff4b8a,$ffff4c19,$ffff4ca8
		dc.l $ffff4d38,$ffff4dc8,$ffff4e58,$ffff4ee9
		dc.l $ffff4f7b,$ffff500d,$ffff509f,$ffff5132
		dc.l $ffff51c5,$ffff5258,$ffff52ec,$ffff5380
		dc.l $ffff5415,$ffff54aa,$ffff5540,$ffff55d6
		dc.l $ffff566c,$ffff5703,$ffff579a,$ffff5832
		dc.l $ffff58ca,$ffff5963,$ffff59fb,$ffff5a95
		dc.l $ffff5b2e,$ffff5bc8,$ffff5c63,$ffff5cfe
		dc.l $ffff5d99,$ffff5e35,$ffff5ed1,$ffff5f6d
		dc.l $ffff600a,$ffff60a7,$ffff6144,$ffff61e2
		dc.l $ffff6281,$ffff631f,$ffff63be,$ffff645e
		dc.l $ffff64fe,$ffff659e,$ffff663e,$ffff66df
		dc.l $ffff6781,$ffff6822,$ffff68c4,$ffff6967
		dc.l $ffff6a0a,$ffff6aad,$ffff6b50,$ffff6bf4
		dc.l $ffff6c98,$ffff6d3d,$ffff6de2,$ffff6e87
		dc.l $ffff6f2d,$ffff6fd3,$ffff7079,$ffff7120
		dc.l $ffff71c7,$ffff726e,$ffff7316,$ffff73be
		dc.l $ffff7466,$ffff750f,$ffff75b8,$ffff7661
		dc.l $ffff770b,$ffff77b5,$ffff785f,$ffff790a
		dc.l $ffff79b5,$ffff7a60,$ffff7b0c,$ffff7bb8
		dc.l $ffff7c64,$ffff7d11,$ffff7dbe,$ffff7e6b
		dc.l $ffff7f19,$ffff7fc6,$ffff8075,$ffff8123
		dc.l $ffff81d2,$ffff8281,$ffff8330,$ffff83e0
		dc.l $ffff8490,$ffff8540,$ffff85f1,$ffff86a2
		dc.l $ffff8753,$ffff8805,$ffff88b6,$ffff8968
		dc.l $ffff8a1b,$ffff8acd,$ffff8b80,$ffff8c33
		dc.l $ffff8ce7,$ffff8d9b,$ffff8e4f,$ffff8f03
		dc.l $ffff8fb7,$ffff906c,$ffff9121,$ffff91d7
		dc.l $ffff928c,$ffff9342,$ffff93f8,$ffff94af
		dc.l $ffff9565,$ffff961c,$ffff96d3,$ffff978b
		dc.l $ffff9843,$ffff98fb,$ffff99b3,$ffff9a6b
		dc.l $ffff9b24,$ffff9bdd,$ffff9c96,$ffff9d4f
		dc.l $ffff9e09,$ffff9ec3,$ffff9f7d,$ffffa037
		dc.l $ffffa0f2,$ffffa1ad,$ffffa268,$ffffa323
		dc.l $ffffa3de,$ffffa49a,$ffffa556,$ffffa612
		dc.l $ffffa6cf,$ffffa78b,$ffffa848,$ffffa905
		dc.l $ffffa9c2,$ffffaa7f,$ffffab3d,$ffffabfb
		dc.l $ffffacb9,$ffffad77,$ffffae36,$ffffaef4
		dc.l $ffffafb3,$ffffb072,$ffffb131,$ffffb1f1
		dc.l $ffffb2b0,$ffffb370,$ffffb430,$ffffb4f0
		dc.l $ffffb5b0,$ffffb671,$ffffb732,$ffffb7f2
		dc.l $ffffb8b3,$ffffb975,$ffffba36,$ffffbaf8
		dc.l $ffffbbb9,$ffffbc7b,$ffffbd3d,$ffffbdff
		dc.l $ffffbec2,$ffffbf84,$ffffc047,$ffffc10a
		dc.l $ffffc1cd,$ffffc290,$ffffc353,$ffffc416
		dc.l $ffffc4da,$ffffc59e,$ffffc661,$ffffc725
		dc.l $ffffc7e9,$ffffc8ae,$ffffc972,$ffffca37
		dc.l $ffffcafb,$ffffcbc0,$ffffcc85,$ffffcd4a
		dc.l $ffffce0f,$ffffced4,$ffffcf9a,$ffffd05f
		dc.l $ffffd125,$ffffd1eb,$ffffd2b0,$ffffd376
		dc.l $ffffd43c,$ffffd502,$ffffd5c9,$ffffd68f
		dc.l $ffffd756,$ffffd81c,$ffffd8e3,$ffffd9aa
		dc.l $ffffda70,$ffffdb37,$ffffdbfe,$ffffdcc5
		dc.l $ffffdd8d,$ffffde54,$ffffdf1b,$ffffdfe3
		dc.l $ffffe0aa,$ffffe172,$ffffe239,$ffffe301
		dc.l $ffffe3c9,$ffffe491,$ffffe559,$ffffe621
		dc.l $ffffe6e9,$ffffe7b1,$ffffe879,$ffffe941
		dc.l $ffffea0a,$ffffead2,$ffffeb9a,$ffffec63
		dc.l $ffffed2b,$ffffedf4,$ffffeebc,$ffffef85
		dc.l $fffff04e,$fffff116,$fffff1df,$fffff2a8
		dc.l $fffff371,$fffff43a,$fffff502,$fffff5cb
		dc.l $fffff694,$fffff75d,$fffff826,$fffff8ef
		dc.l $fffff9b8,$fffffa81,$fffffb4a,$fffffc13
		dc.l $fffffcdc,$fffffda5,$fffffe6e,$ffffff37
		
		dc.l $00000000,$000000c9,$00000192,$0000025b
		dc.l $00000324,$000003ed,$000004b6,$0000057f
		dc.l $00000648,$00000711,$000007da,$000008a3
		dc.l $0000096c,$00000a35,$00000afe,$00000bc6
		dc.l $00000c8f,$00000d58,$00000e21,$00000eea
		dc.l $00000fb2,$0000107b,$00001144,$0000120c
		dc.l $000012d5,$0000139d,$00001466,$0000152e
		dc.l $000015f6,$000016bf,$00001787,$0000184f
		dc.l $00001917,$000019df,$00001aa7,$00001b6f
		dc.l $00001c37,$00001cff,$00001dc7,$00001e8e
		dc.l $00001f56,$0000201d,$000020e5,$000021ac
		dc.l $00002273,$0000233b,$00002402,$000024c9
		dc.l $00002590,$00002656,$0000271d,$000027e4
		dc.l $000028aa,$00002971,$00002a37,$00002afe
		dc.l $00002bc4,$00002c8a,$00002d50,$00002e15
		dc.l $00002edb,$00002fa1,$00003066,$0000312c
		dc.l $000031f1,$000032b6,$0000337b,$00003440
		dc.l $00003505,$000035c9,$0000368e,$00003752
		dc.l $00003817,$000038db,$0000399f,$00003a62
		dc.l $00003b26,$00003bea,$00003cad,$00003d70
		dc.l $00003e33,$00003ef6,$00003fb9,$0000407c
		dc.l $0000413e,$00004201,$000042c3,$00004385
		dc.l $00004447,$00004508,$000045ca,$0000468b
		dc.l $0000474d,$0000480e,$000048ce,$0000498f
		dc.l $00004a50,$00004b10,$00004bd0,$00004c90
		dc.l $00004d50,$00004e0f,$00004ecf,$00004f8e
		dc.l $0000504d,$0000510c,$000051ca,$00005289
		dc.l $00005347,$00005405,$000054c3,$00005581
		dc.l $0000563e,$000056fb,$000057b8,$00005875
		dc.l $00005931,$000059ee,$00005aaa,$00005b66
		dc.l $00005c22,$00005cdd,$00005d98,$00005e53
		dc.l $00005f0e,$00005fc9,$00006083,$0000613d
		dc.l $000061f7,$000062b1,$0000636a,$00006423
		dc.l $000064dc,$00006595,$0000664d,$00006705
		dc.l $000067bd,$00006875,$0000692d,$000069e4
		dc.l $00006a9b,$00006b51,$00006c08,$00006cbe
		dc.l $00006d74,$00006e29,$00006edf,$00006f94
		dc.l $00007049,$000070fd,$000071b1,$00007265
		dc.l $00007319,$000073cd,$00007480,$00007533
		dc.l $000075e5,$00007698,$0000774a,$000077fb
		dc.l $000078ad,$0000795e,$00007a0f,$00007ac0
		dc.l $00007b70,$00007c20,$00007cd0,$00007d7f
		dc.l $00007e2e,$00007edd,$00007f8b,$0000803a
		dc.l $000080e7,$00008195,$00008242,$000082ef
		dc.l $0000839c,$00008448,$000084f4,$000085a0
		dc.l $0000864b,$000086f6,$000087a1,$0000884b
		dc.l $000088f5,$0000899f,$00008a48,$00008af1
		dc.l $00008b9a,$00008c42,$00008cea,$00008d92
		dc.l $00008e39,$00008ee0,$00008f87,$0000902d
		dc.l $000090d3,$00009179,$0000921e,$000092c3
		dc.l $00009368,$0000940c,$000094b0,$00009553
		dc.l $000095f6,$00009699,$0000973c,$000097de
		dc.l $0000987f,$00009921,$000099c2,$00009a62
		dc.l $00009b02,$00009ba2,$00009c42,$00009ce1
		dc.l $00009d7f,$00009e1e,$00009ebc,$00009f59
		dc.l $00009ff6,$0000a093,$0000a12f,$0000a1cb
		dc.l $0000a267,$0000a302,$0000a39d,$0000a438
		dc.l $0000a4d2,$0000a56b,$0000a605,$0000a69d
		dc.l $0000a736,$0000a7ce,$0000a866,$0000a8fd
		dc.l $0000a994,$0000aa2a,$0000aac0,$0000ab56
		dc.l $0000abeb,$0000ac80,$0000ad14,$0000ada8
		dc.l $0000ae3b,$0000aece,$0000af61,$0000aff3
		dc.l $0000b085,$0000b117,$0000b1a8,$0000b238
		dc.l $0000b2c8,$0000b358,$0000b3e7,$0000b476
		dc.l $0000b504,$0000b592,$0000b620,$0000b6ad
		dc.l $0000b73a,$0000b7c6,$0000b852,$0000b8dd
		dc.l $0000b968,$0000b9f2,$0000ba7c,$0000bb06
		dc.l $0000bb8f,$0000bc17,$0000bca0,$0000bd27
		dc.l $0000bdae,$0000be35,$0000bebc,$0000bf41
		dc.l $0000bfc7,$0000c04c,$0000c0d0,$0000c154
		dc.l $0000c1d8,$0000c25b,$0000c2de,$0000c360
		dc.l $0000c3e2,$0000c463,$0000c4e3,$0000c564
		dc.l $0000c5e4,$0000c663,$0000c6e2,$0000c760
		dc.l $0000c7de,$0000c85b,$0000c8d8,$0000c955
		dc.l $0000c9d1,$0000ca4c,$0000cac7,$0000cb41
		dc.l $0000cbbb,$0000cc35,$0000ccae,$0000cd26
		dc.l $0000cd9f,$0000ce16,$0000ce8d,$0000cf04
		dc.l $0000cf7a,$0000cfef,$0000d064,$0000d0d9
		dc.l $0000d14d,$0000d1c0,$0000d233,$0000d2a6
		dc.l $0000d318,$0000d389,$0000d3fa,$0000d46b
		dc.l $0000d4db,$0000d54a,$0000d5b9,$0000d627
		dc.l $0000d695,$0000d703,$0000d770,$0000d7dc
		dc.l $0000d848,$0000d8b3,$0000d91e,$0000d988
		dc.l $0000d9f2,$0000da5b,$0000dac4,$0000db2c
		dc.l $0000db94,$0000dbfb,$0000dc61,$0000dcc7
		dc.l $0000dd2d,$0000dd92,$0000ddf6,$0000de5a
		dc.l $0000debe,$0000df20,$0000df83,$0000dfe4
		dc.l $0000e046,$0000e0a6,$0000e106,$0000e166
		dc.l $0000e1c5,$0000e224,$0000e282,$0000e2df
		dc.l $0000e33c,$0000e398,$0000e3f4,$0000e44f
		dc.l $0000e4aa,$0000e504,$0000e55e,$0000e5b7
		dc.l $0000e60f,$0000e667,$0000e6be,$0000e715
		dc.l $0000e76b,$0000e7c1,$0000e816,$0000e86b
		dc.l $0000e8bf,$0000e912,$0000e965,$0000e9b7
		dc.l $0000ea09,$0000ea5a,$0000eaab,$0000eafb
		dc.l $0000eb4b,$0000eb99,$0000ebe8,$0000ec36
		dc.l $0000ec83,$0000ecd0,$0000ed1c,$0000ed67
		dc.l $0000edb2,$0000edfc,$0000ee46,$0000ee8f
		dc.l $0000eed8,$0000ef20,$0000ef68,$0000efaf
		dc.l $0000eff5,$0000f03b,$0000f080,$0000f0c5
		dc.l $0000f109,$0000f14c,$0000f18f,$0000f1d1
		dc.l $0000f213,$0000f254,$0000f294,$0000f2d4
		dc.l $0000f314,$0000f353,$0000f391,$0000f3ce
		dc.l $0000f40b,$0000f448,$0000f484,$0000f4bf
		dc.l $0000f4fa,$0000f534,$0000f56d,$0000f5a6
		dc.l $0000f5de,$0000f616,$0000f64d,$0000f684
		dc.l $0000f6ba,$0000f6ef,$0000f724,$0000f758
		dc.l $0000f78b,$0000f7be,$0000f7f1,$0000f822
		dc.l $0000f853,$0000f884,$0000f8b4,$0000f8e3
		dc.l $0000f912,$0000f940,$0000f96e,$0000f99b
		dc.l $0000f9c7,$0000f9f3,$0000fa1e,$0000fa49
		dc.l $0000fa73,$0000fa9c,$0000fac5,$0000faed
		dc.l $0000fb14,$0000fb3b,$0000fb61,$0000fb87
		dc.l $0000fbac,$0000fbd1,$0000fbf5,$0000fc18
		dc.l $0000fc3b,$0000fc5d,$0000fc7e,$0000fc9f
		dc.l $0000fcbf,$0000fcdf,$0000fcfe,$0000fd1c
		dc.l $0000fd3a,$0000fd57,$0000fd74,$0000fd90
		dc.l $0000fdab,$0000fdc6,$0000fde0,$0000fdfa
		dc.l $0000fe13,$0000fe2b,$0000fe43,$0000fe5a
		dc.l $0000fe70,$0000fe86,$0000fe9b,$0000feb0
		dc.l $0000fec4,$0000fed7,$0000feea,$0000fefc
		dc.l $0000ff0e,$0000ff1f,$0000ff2f,$0000ff3f
		dc.l $0000ff4e,$0000ff5c,$0000ff6a,$0000ff78
		dc.l $0000ff84,$0000ff90,$0000ff9c,$0000ffa6
		dc.l $0000ffb1,$0000ffba,$0000ffc3,$0000ffcb
		dc.l $0000ffd3,$0000ffda,$0000ffe1,$0000ffe7
		dc.l $0000ffec,$0000fff0,$0000fff4,$0000fff8
		dc.l $0000fffb,$0000fffd,$0000fffe,$0000ffff

; ----------------------------------------
; This table is "off by one" - to get 1/n you must fetch the (n-1)th entry.
; ----------------------------------------

		align	4
div_table
		incbin "mars/sh2/subs/data/divtable.bin"
		align 4
		
; =================================================================
; ----------------------------------------
; Subs
; ----------------------------------------

; ------------------------------
; Rotate point around Z axis
;
; Entry:
;
; r5: x
; r6: y
; r0: theta
;
; Returns:
;
; r0: (x  cos @) + (y sin @)
; r1: (x -sin @) + (y cos @)
; ------------------------------

Rotate_Point:
		mov	#sin_table,r1
		mov	#cos_table,r2
		mov	@(r0,r1),r3
		mov	@(r0,r2),r4

		dmuls	r5,r4		; x cos @
		mov	macl,r0
		mov	mach,r1
		xtrct	r1,r0
		dmuls	r6,r3		; y sin @
		mov	macl,r1
		mov	mach,r2
		xtrct	r2,r1
		add	r1,r0

		neg	r3,r3
		dmuls	r5,r3		; x -sin @
		mov	macl,r1
		mov	mach,r2
		xtrct	r2,r1
		dmuls	r6,r4		; y cos @
		mov	macl,r2
		mov	mach,r3
		xtrct	r3,r2
		add	r2,r1
 		rts
		nop
		lits
		cnop 0,4
		
; ----------------------------------------
; Texture map line
; 
; Input:
; r1  - left_dda
; r2  - right_dda
; r10 - tml_data
;
; Uses:
; r0-r9
; ----------------------------------------

		align	4
Texture_Map_Line:

; --------------------------
; Setup the destinations
; --------------------------

		mov	@(dda_dst_x,r2),r9		; Line start/end
		mov	@(dda_dst_x,r1),r8
		
 		mov	@(tml_texture,r10),r4
 		mov	#256,r3
 		cmp/ge	r3,r4
 		bt	@texture_setup
 		
; --------------------------
; Solid color
; --------------------------

 		mov	r9,r0
 		sub 	r8,r0
 		cmp/pz	r0				; Line rotated?
 		bt	@no_texture
		mov	@(dda_dst_x,r2),r8		; Line start/end
		bra	@no_texture
		mov	@(dda_dst_x,r1),r9
 
; --------------------------
; Has texture
; --------------------------

@texture_setup:
		mov	@(dda_src_x,r2),r4		; Texture points
  		mov	@(dda_src_x,r1),r5
 		mov	@(dda_src_y,r2),r6
		mov	@(dda_src_y,r1),r7

 		mov	r9,r0
 		sub 	r8,r0
 		cmp/pz	r0				; Line rotated?
 		bt	@plus
  		
		mov	@(dda_src_x,r2),r5		; Texture points
  		mov	@(dda_src_x,r1),r4
 		mov	@(dda_src_y,r2),r7
		mov	@(dda_src_y,r1),r6
  		
		mov	@(dda_dst_x,r2),r8		; Line start/end
		mov	@(dda_dst_x,r1),r9
 	
; ------------------------------------

@plus:
  		mov	r9,r0
    		shlr16	r0
    		mov	r0,r1
    		mov	r8,r0
     		shlr16	r0
    		sub	r0,r1
     		exts	r1,r1
    		mov	#div_table,r0
    		shll2	r1				; Calculate width divisor
   		mov	@(r0,r1),r0
   		sub	r4,r5
   		dmuls	r5,r0
   		mov	mach,r5
   		rotcl	r5
    		sub	r6,r7
    		dmuls	r7,r0
    		mov	mach,r7
   		rotcl	r7
   	
; ------------------------------------

@no_texture:
 		mov	@(tml_texture,r10),r2
 		
; ------------------------------------
; Set Framebuffer Y pos
; ------------------------------------

  		mov	@(tml_dst_y,r10),r1
  		cmp/pz	r1				; Negative Y?
  		bf	@s_end
 		mov	#max_height,r0			; Reached bottom?
 		cmp/ge	r0,r1
 		bt	@s_end
 		
 		mov	#320,r0				; Next Framebuffer line
 		mulu	r1,r0
 		mov	macl,r0
 		mov	#_framebuffer+$200,r3		; Framebuffer address
 		add	r0,r3				; FB YPos
 		
; ------------------------------------
; Set line length
; ------------------------------------

    		shlr16	r9
       		exts	r9,r9
           	cmp/pz	r9
         	bf	@s_end
         	add 	r9,r3				;FB Xpos
    		shlr16	r8
     		exts	r8,r8
          	cmp/pz	r8
        	bt	@check_type
        	mov	#0,r8
 		
; ------------------------------------
; Check drawing mode
; ------------------------------------

@check_type:
 		mov	#256,r0				; Texture address $0-$FF?
 		cmp/gt	r0,r2
 		bt	@tex_write
 		
; ------------------------------------
; Write solid color
; ------------------------------------

@solid_write:
   		mov	#max_width,r0			; Maximum X position?
   		cmp/ge	r0,r9
   		bt	@s_cont
   		mov 	@(tml_flags,r10),r0
   		tst	#%01,r0
   		bt	@not_under_s
   		mov	#0,r0				; nothing written?
   		mov.b	@r3,r0
   		cmp/eq	#0,r0
   		bf	@s_cont
@not_under_s:

    		mov	r2,r0				; Solid color
 		and	#$FF,r0
   		mov.b	r0,@r3	   			; Write pixel
@s_cont:
		sub 	#1,r3
   		cmp/gt	r8,r9
   		bt/s	@solid_write
 		sub 	#1,r9
@s_end:
 		rts
 		nop
 		lits
 		align 4
 		
; ------------------------------------
; Write texture pixel
; ------------------------------------
 
@tex_write:
    		mov	#max_width,r0			; Maximum X position?
    		cmp/ge	r0,r9
    		bt	@max
   		mov 	@(tml_flags,r10),r0
   		tst	#%01,r0
   		bt	@not_under
   		mov	#0,r0				; nothing written?
   		mov.b	@r3,r0
   		cmp/eq	#0,r0
   		bf	@max
@not_under:
 		; r6 - Y
 		; r4 - X
     		swap	r6,r1				; r6 - yyyy0000 -> r1 - 0000yyyy
 		mov	@(tml_texwidth,r10),r0
    		mulu	r1,r0				; macl = width * current Y
    		mov	r4,r1	   			; xxxx0000 to r1
    		shlr16	r1				; r1 = X (0000xxxx)
    		mov	macl,r0				; r0 = Y (0000yyyy)
    		add	r1,r0				; y + x
    		mov 	r2,r1				; Texture address
    		add 	r0,r1				; + line position
    		mov.b	@r1,r0
 		mov 	@(tml_texadd,r10),r1
     		add 	r1,r0
 		and	#$FF,r0
   		mov.b	r0,@r3	   			; Write pixel
   		
@max:
   		add	r5,r4				; Update X
 		add	r7,r6				; Update Y

@cont:
; 		mov	#$1FF,r0
; @TESTLOOP:	dt	r0
; 		bf	@TESTLOOP
		
		sub 	#1,r3
   		cmp/gt	r8,r9
   		bt/s	@tex_write
 		sub 	#1,r9
@end:
 		rts
 		nop
 		lits
 		align 4

; ----------------------------------------
; Find top point
;
; Entry:
;    r1: Source data
;    r2: Destionation data
;    r3: Num of points
;
; Returns:
;
;    r3: Start Y position
;    r4: End Y position
;    r5: Start dest point
;    r6: Start source point
;    r7: First dest point
;    r8: Last  dest point
;    r9: First source point
; ----------------------------------------

Preinit_DDA:
 		mov	r2,r7			; (DESTINATION address) -> r7
		mov	r3,r2			; r2 - Number of points to read (3 or 4)
		mov	r2,r8			; r2 -> r8
		sub	#1,r8			; -1
		mov	#sizeof_point,r0	; number of points (3 or 4) -1s
		mulu	r0,r8			; * sizeof_point
		mov	macl,r8			; r8 - result
		add	r7,r8			; RETURN: r8 + (DESTINATION address) =  (last point address)

		mov	r7,r9			; (DESTINATION address) to r9, Search for dest start point
		mov	#$7FFFFFFF,r3		; r3 - Default Start Y
		mov	#$FFFFFFFF,r4		; r4 - Default End Y
@loop
		mov	@(point_y,r9),r0	; r0 - Y point to check
		
		cmp/ge	r3,r0			; This Y < $7FFFFFFF?
		bt	@not_start
		mov	r9,r5			; RETURN: r5 - New START destination points
		mov	r0,r3			; RETURN: r3 - Update Start Y with this new position
@not_start:
		cmp/ge	r0,r4			; This Y < $FFFFFFFF?
		bt	@not_end
		mov	r0,r4			; RETURN: r4 - Update End Y with this new position
@not_end:
		add	#sizeof_point,r9	; Check next point
		dt	r2			;
		bf	@loop			;

		mov	r5,r6			; r6 - (DESTINATION Address) "Set source start point"
		sub	r7,r6			; r6 - (DESTINATION Target) - (DESTINATION Start)
		add	r1,r6			; r6 - (DESTINATION Target) + (SOURCE points)
						; RETURN: r6 - Start SOURCE point
		rts
		mov 	r1,r9			; RETURN: r9 - First SOURCE point
		lits
		cnop 0,4

; ----------------------------------------
; Init DDA
;
; Entry:
;
;    r2: DDA pointer
;    r5: Start dest point
;    r6: Start source point
;    r7: First dest point
;    r8: Last  dest point
;    r9: First source point
; ----------------------------------------

		cnop 0,4
Init_DDA:
 		mov	r8,r0
 		sub	r7,r0
 		add	r9,r0
 		mov	r5,@(dda_dst_point,r2)	; Set destination points
 		mov	r6,@(dda_src_point,r2)  ; Set source point
 		mov	r7,@(dda_dst_low,r2)
 		mov	r8,@(dda_dst_high,r2)
 		mov	r9,@(dda_src_low,r2)
 		mov	r0,@(dda_src_high,r2)

		mov	#0,r0			; Set height to zero
 		rts
 		mov	r0,@(dda_dst_h,r2)

; ----------------------------------------
; Update left DDA
;
; r8: DDA pointer
; ----------------------------------------

Update_Left_DDA:

; Start critical section

		mov	@(dda_dst_h,r8),r0	; Decrement height
		cmp/eq	#0,r0
		bt	@next_point
		sub	#1,r0
		mov	r0,@(dda_dst_h,r8)

		mov	@(dda_dst_x,r8),r1
		mov	@(dda_dst_dx,r8),r0
		add 	r0,r1
		mov	r1,@(dda_dst_x,r8)
		mov	@(dda_src_x,r8),r1
		mov	@(dda_src_dx,r8),r0
		add 	r0,r1
		mov	r1,@(dda_src_x,r8)
		mov	@(dda_src_y,r8),r1
		mov	@(dda_src_dy,r8),r0
		add 	r0,r1
		rts
		mov	r1,@(dda_src_y,r8)

; End critical section

@next_point:
		mov	#$80000000,r5

		mov	@(dda_dst_point,r8),r6	; Set dest to target point
		mov	@(point_x,r6),r1
		mov	r5,r0
		xtrct	r1,r0
		mov	r0,@(dda_dst_x,r8)
		mov	@(point_y,r6),r2

		mov	@(dda_src_point,r8),r7	; Set source to target point
		mov	@(point_x,r7),r3
		mov	r5,r0
		xtrct	r3,r0
		mov	r0,@(dda_src_x,r8)
		mov	@(point_y,r7),r4
		mov	r5,r0
		xtrct	r4,r0
		mov	r0,@(dda_src_y,r8)

		mov	@(dda_dst_high,r8),r5	; Calculate next target point
		add	#SIZEOF_POINT,r6
		add	#SIZEOF_POINT,r7
		cmp/gt	r5,r6
		bf	@save_new_target
		mov	@(dda_dst_low,r8),r6
		mov	@(dda_src_low,r8),r7

@save_new_target
		mov	r6,@(dda_dst_point,r8)
		mov	r7,@(dda_src_point,r8)

		mov	@(point_x,r6),r5	; Calculate dest dx and dy
		sub	r1,r5
		mov	@(point_y,r6),r6
		sub	r2,r6

		mov	r6,r0
		cmp/eq	#0,r0
		bt	@next_point
		cmp/pz	r0
		bf	@exit

		bra	dda_upd_divide
		mov	r6,@(dda_dst_h,r8)
		
@exit:
		rts
		nop

; ----------------------------------------
; Update right DDA
;
; r8: DDA pointer
; ----------------------------------------

Update_Right_DDA:	
		mov	@(dda_dst_h,r8),r0	; Decrement height
		cmp/eq	#0,r0
		bt	@next_point
		sub	#1,r0
		mov	r0,@(dda_dst_h,r8)

		mov	@(dda_dst_x,r8),r1
		mov	@(dda_dst_dx,r8),r0
		add 	r0,r1
		mov	r1,@(dda_dst_x,r8)
		mov	@(dda_src_x,r8),r1
		mov	@(dda_src_dx,r8),r0
		add 	r0,r1
		mov	r1,@(dda_src_x,r8)
		mov	@(dda_src_y,r8),r1
		mov	@(dda_src_dy,r8),r0
		add 	r0,r1
		rts
		mov	r1,@(dda_src_y,r8)

; End critical section

@next_point:
		mov	#$80000000,r5

		mov	@(dda_dst_point,r8),r6	; Set dest to target point
		mov	@(point_x,r6),r1
		mov	r5,r0
		xtrct	r1,r0
		mov	r0,@(dda_dst_x,r8)
		mov	@(point_y,r6),r2

		mov	@(dda_src_point,r8),r7	; Set source to target point
		mov	@(point_x,r7),r3
		mov	r5,r0
		xtrct	r3,r0
		mov	r0,@(dda_src_x,r8)
		mov	@(point_y,r7),r4
		mov	r5,r0
		xtrct	r4,r0
		mov	r0,@(dda_src_y,r8)

		mov	@(dda_dst_low,r8),r5	; Calculate next target point
		sub	#SIZEOF_POINT,r6
		cmp/ge	r5,r6
		bt/s	@save_new_target
		sub	#SIZEOF_POINT,r7
		mov	@(dda_dst_high,r8),r6
		mov	@(dda_src_high,r8),r7

@save_new_target
		mov	r6,@(dda_dst_point,r8)
		mov	r7,@(dda_src_point,r8)

		mov	@(point_x,r6),r5	; Calculate dest dx and dy
		sub	r1,r5
		mov	@(point_y,r6),r6
		sub	r2,r6

		mov	r6,r0
		cmp/eq	#0,r0
		bt	@next_point
		cmp/pz	r0
		bf	@exit

		bra	dda_upd_divide
		mov	r6,@(dda_dst_h,r8)
		
@exit:
		rts
		nop
		
; ----------------------------------------
; Shared DDA things
; 
; r3 - Src X point
; r6 - Dest Y point
; r7 - source points
; r8 - current dda
; ----------------------------------------

dda_upd_divide:
		mov	#div_table,r0		; Calculate divisor
		shll2	r6
		mov	@(r0,r6),r0
		shll16	r5			; Calculate dest dx
		dmuls	r5,r0
		mov	mach,r1
		rotcl	r1
		mov	r1,@(dda_dst_dx,r8)

		mov	@(point_x,r7),r5	; Calculate source dx and dy
		sub	r3,r5
		mov	@(point_y,r7),r6
		sub	r4,r6
		shll16	r5
		dmuls	r5,r0			; Calculate source dx
		mov	mach,r1
		rotcl	r1
		mov	r1,@(dda_src_dx,r8)
		shll16	r6
		dmuls	r6,r0			; Calculate source dy
		mov	mach,r1
		rotcl	r1
		rts
		mov	r1,@(dda_src_dy,r8)
		lits
		cnop 0,4
		
; ----------------------------------------
; Clone DDA
;
; r8: DDA pointer
; ----------------------------------------

Clone_DDA:
		mov 	#left_dda,r1
		mov	#left_dda_sl,r2
		mov	#right_dda,r3
		mov	#right_dda_sl,r4
		mov	#sizeof_dda,r5
@loop:
		mov	@r1+,r0
		mov	r0,@r2
		add 	#4,r2
		mov	@r3+,r0
		mov	r0,@r4
		add 	#4,r4
		dt	r5
		bf	@loop
		
		rts
		nop
		lits
		cnop 0,4
		
; =================================================================
; ----------------------------------------
; Start
; ----------------------------------------

; ----------------------------------------
; Draw_Face
;
; Input:
; r1 - points source
; r2 - points destination
; r3 - number of points ($03 or $04)
; r4 - bitmap pointer/solid color $01-$FF(255)
; r5 - texture width (ignored if solid color)
; r6 - add $xx to indexed texture
; r7 - flags
; Uses:
; r0-r10
; ----------------------------------------

Draw_Face_Slave:
		mov	#tml_data_sl,r10
		mov	#left_dda_sl,r0
		mov	r0,@(tml_left,r10)
		mov	#right_dda_sl,r0
		mov	r0,@(tml_right,r10)
		bra	DrwTex_Go
		mov	#1,r7			;FLAG: Underwrite
		
Draw_Face:
		mov	#tml_data,r10
		mov	#left_dda,r0
		mov	r0,@(tml_left,r10)
		mov	#right_dda,r0
		mov	r0,@(tml_right,r10)
		mov	#1,r7			;FLAG: Underwrite

; --------------------
; Start drawing
; --------------------

DrwTex_Go:
		mov	pr,@-r15
		
 		mov	r4,@(tml_texture,r10)
 		mov 	r5,@(tml_texwidth,r10)
  		mov 	r6,@(tml_texadd,r10)
		bsr	Preinit_DDA
		mov	r7,@(tml_flags,r10)
 		
; --------------------
; Init DDA
; --------------------

		cmp/eq	r3,r4
		bt	@end
		mov	@(tml_left,r10),r2
		bsr	Init_DDA
		nop
		mov	@(tml_right,r10),r2
		bsr	Init_DDA
		nop
		
; --------------------
; Fix Y
; 
; r3 - Start Y
; r4 - End Y
; --------------------

		cmp/pl	r4
		bt	@not_top
		mov	#-1,r3	
@not_top:
		mov	r3,@(tml_dst_y,r10)
		cmp/gt	r3,r4
		bf	@end
		add	#1,r4
		mov	r4,@(tml_bottom_y,r10)
 		
; --------------------
; CPU save flag
; --------------------

;  		mov 	#0,r1
;      		sub 	r3,r4
;      		mov 	#$58,r0
;      		cmp/ge	r0,r4
;      		bf	@fullv
;      		mov 	#1,r1
; @fullv:
;   		mov 	r1,@(tml_flags,r10)
 		
 		
; --------------------
; Draw lines
; --------------------

@loop:
		mov	@(tml_left,r10),r8
		bsr	Update_Left_DDA
		nop
		mov	@(tml_right,r10),r8
 		bsr	Update_Right_DDA
 		nop
		mov	@(tml_left,r10),r1
 		mov	@(tml_right,r10),r2
 		bsr	Texture_Map_Line
 		nop
 		
		mov	@(tml_dst_y,r10),r2			; Next texture line
		add 	#1,r2
		mov	r2,@(tml_dst_y,r10)
		mov	@(tml_bottom_y,r10),r1			; Reached end?
		cmp/gt	r1,r2
		bf	@loop
		
@end:
		mov	@r15+,pr
		rts
		nop
		lits
		cnop 0,4
		
; =================================================================
; ----------------------------------------
; Set new model
;
; r1 - Model
; r2 - Slot
; ----------------------------------------

Mars3d_ModelSet:
		mov	#models_buffer,r14
		mov	#sizeof_model,r0
		mulu	r2,r0
		mov	macl,r0
		add 	r0,r14

		mov.l	r1,@(model_addr,r14)
 		rts
		nop
		lits
		cnop 0,4

; =================================================================
; ----------------------------------
; Build model
; 
; r13 - model address
; ----------------------------------

mars3d_makemdl:
		mov.l	pr,@-r15
		
; 		mov.l	@(model_addr,r14),r13
		mov.l	@r13,r8			; r8 - Faces
		mov.l	@(4,r13),r9		; r9 - Points
		mov.l	@(8,r13),r10		; r10 - Material
		mov.l	@($C,r13),r0		; Painter Z start
; 		mov.l	r0,@(model_z_start,r14)
		
		mov	#faces_buffer,r13
 		mov	#0,r0
 		mov	r0,@r13
 		add 	#faces_data,r13

; ----------------------------------

@next:
		mov	#0,r0
		mov.w	@r8+,r0
		mov	r0,r11
		mov	#3,r0			;triangle?
		cmp/eq	r0,r11
		bt	@valid
		add 	#1,r0
		cmp/eq	r0,r11			;quad?
		bt	@valid
		bra	@end
		nop
		
; ----------------------------------
; Valid model
; ----------------------------------

@valid:
		mov	r11,@(faces_type,r13)
		
; ----------------------------------
; find texture
; ----------------------------------

		mov	#255,r2			; Undefined
		mov	#0,r3			; Default $XX add
		mov	#0,r0
		mov.w	@r8+,r0
		mov	#256,r1
		cmp/ge	r1,r0
		bf	@solid_color
		sub 	r1,r0
		mov	r0,r1			; ID
		mov	r10,r4			; materials
@nexttex:
		mov.l	@r4+,r0			; ID
		cmp/pz	r0
		bf	@notfound
		cmp/eq	r0,r1
		bt	@found
		
		;TODO: creo que tengo que deshacerme de esto
 		mov	#255,r5
 		cmp/ge	r5,r0
 		bf	@solid_only
		add	#$20,r4			; skip texture setting (8 LONGS)
@solid_only:

		bra	@nexttex
		add	#$C,r4
		
@solid_color:
; 		mov	r0,r2
		bra	@notfound
 		mov	r0,r2

@found:
 		mov.l	@r4+,r2			; Texture/SolidColor
  		mov.l	@r4+,r5			; Texture width
  		mov.l	@r4+,r3			; $xx Add
  		
@notfound:
		mov.l	r2,@(face_tex,r13)
		mov.l	r3,@(face_tex_add,r13)		
		mov.l	r5,@(face_tex_width,r13)	
		
@solid_tex:
		
; ----------------------------------
; Set texture source
; ----------------------------------

		mov 	r4,@(faces_srcaddr,r13)
		
; ----------------------------------
; Send target points to buffer
; ----------------------------------
	
		mov	r13,r7
		add	#face_points,r7
		
 		mov	#0,r1
@nextpoints:
		mov	r9,r12
		mov	#0,r0
		mov.w	@r8+,r0
		mov	#6,r1
		mulu	r0,r1
		mov	macl,r0
		add 	r0,r12

; ----------------------------------

 		mov	#0,r0
 		mov.w	@(4,r12),r0
 		exts.w	r0,r0
     		mov	@(model_z,r14),r1
     		add 	r1,r0	
  		mov	r0,r6
  		
		mov	#0,r0
		mov.w	@r12,r0
 		exts.w	r0,r0
      		mov 	@(model_x,r14),r1
       		add 	r1,r0
      		bsr 	@mdl_setresize_alt
  		mov	r0,r5
      		add 	r0,r5
      		
 		;r5 - X
 		;r6 - Z
 		
 		shll16	r5
 		shll16	r6
   		mov	@(model_y_rot,r14),r0
    		mov	#$7FF,r1
    		and	r1,r0
;    		shll2	r0  
 		bsr	Rotate_Point
   		shll2	r0 
 		shlr16	r0
 		exts.w	r0,r0
   		mov	r0,@r7
   		
 		;r1 = Z
 		mov	r1,r6
 		mov	#0,r0
		mov.w	@(2,r12),r0
 		exts.w	r0,r0
      		mov 	@(model_y,r14),r1
       		add 	r1,r0
     		bsr 	@mdl_setresize_alt
      		mov 	r0,r5
         	add 	r0,r5
  		shll16	r5
   		mov	@(model_x_rot,r14),r0
    		mov	#$7FF,r2
    		and	r2,r0
;    		shll2	r0
 		bsr	Rotate_Point
   		shll2	r0
   		
 		shlr16	r0
 		exts.w	r0,r0
    		shlr16	r1
    		exts.w	r1,r1
      		mov	r1,@(8,r7)
      		mov	r0,@(4,r7)
      		
   		add	#$C,r7
  		dt	r11
  		bf	@nextpoints

; ----------------------------------
; Check if Z near or far
; 
; Also X
; ----------------------------------

  		mov	r13,r7
  		add	#face_points,r7

  		mov	#-384,r1		; Z far  best: -256
  		mov	#1024,r2		; Z near best: 1024
  		mov 	#-384,r3		; X left best: -384
   		mov	#384,r4			; X right best: 384
  		
 		mov	@(faces_type,r13),r5
@next2:
  		mov	@(8,r7),r0
   		cmp/ge	r1,r0
   		bf	@is_bad
  		cmp/ge	r2,r0
  		bt	@is_bad

   		mov	@r7,r0
    		cmp/ge	r3,r0
    		bf	@is_bad
   		cmp/ge	r4,r0
   		bt	@is_bad
  		
     		add	#$C,r7
     		dt 	r5
     		bf	@next2
 
; -----------------------------

		mov	#1,r2	
		cmp/pl	r0
		bf	@set_it
		mov	#2,r2
@set_it:
		mov	r2,@(face_flags,r13)
		
; ----------------------------------

  		mov 	#faces_buffer,r1
   		mov	@(faces_used,r1),r0
   		add 	#1,r0
   		mov 	r0,@(faces_used,r1)
   		mov 	#numof_faces-1,r1
   		cmp/ge	r1,r0
   		bt	@end
 		add 	#sizeof_face,r13
@is_bad:
     		bra	@next
     		nop
 	
; ----------------------------------
; end
; ----------------------------------

@end:
		mov	#0,r0
		mov	r0,@(face_flags,r13)		; set end of list
		
; ----------------------------------
; draw faces
; 
; r12 - faces used
; r11 - Z counter
; ----------------------------------

      		mov	#faces_buffer,r13
      		mov 	@(faces_used,r13),r12
      		add 	#faces_data,r13
     		mov 	#32,r11			; lower = faster
     		mov	@(model_z,r14),r0
     		add 	r0,r11
     		
     		mov	#mstr_faces,r9
     		mov	#slve_faces,r10
     		
; -----------------------------

@num_next:
  		mov	@(face_flags,r13),r0
  		cmp/eq	#-1,r0
  		bt	@face_off

; -----------------------------
; Z Check Painters algorithm
; -----------------------------

      		mov	r13,r4
       		add 	#face_points,r4
         	mov 	@(8,r4),r1		;point 1
         	add 	#$C,r4
         	
         	mov	@(8,r4),r0		;point 2
         	add 	#$C,r4
         	cmp/ge	r0,r1
         	bf	@same_1
         	mov	r0,r1
@same_1:
         	mov	@(8,r4),r0		;point 3
         	add 	#$C,r4
         	cmp/ge	r0,r1
         	bf	@same_2
         	mov	r0,r1
@same_2:
		mov	@(faces_type,r13),r0
		cmp/eq	#3,r0
		bt	@same_3
         	mov	@(8,r4),r0		;point 4
         	add 	#$C,r4
         	cmp/ge	r0,r1
         	bf	@same_3
         	mov	r0,r1
@same_3:
         	cmp/gt	r1,r11
         	bt	@face_off
       
; -----------------------------
; Convert model points to
; texture points
; -----------------------------

  		mov	@(face_flags,r13),r0
  		cmp/eq	#1,r0
  		bt	@master_side
  		
		mov 	r13,@r10
  		bra	@also_convert
		add	#4,r10
  		
@master_side:
		mov 	r13,@r9
		add	#4,r9
           
@also_convert:
      		mov	r13,r1
      		add 	#face_points,r1			; r1 - XYZ points
      		mov 	r1,r2
      		mov 	@(faces_type,r13),r3
@next_master:
    		mov	@r1,r0
       		mov	#(max_width/2),r4
             	add 	r4,r0
       		mov	r0,@r2
    		mov	@(4,r1),r0
       		mov	#(max_height/2),r4
            	add 	r4,r0
      		mov	r0,@(4,r2)
   		add 	#$C,r1
    		add 	#8,r2
    		dt	r3
    		bf	@next_master
            	
; -----------------------------

@force_done:
		mov	#-1,r0
   		mov 	r0,@(face_flags,r13)
   		sub 	#1,r12				; Decrement number of faces

@face_off:
 		cmp/pl	r12				; Still doing faces?
 		bf	@finished			; Finish if $00 or minus
 		add 	#sizeof_face,r13
 		
 		mov	@(face_flags,r13),r0		; Reached end of list?
 		cmp/eq	#0,r0
 		bf	@num_next
 		
       		mov	#faces_buffer+faces_data,r13	; Return to first face
     		bra	@num_next
       		sub 	#1,r11
     		
@finished:
		mov	#-1,r0
		mov	r0,@r9
		mov	r0,@r10	
     		
; ----------------------------------
	
  		mov	#taskfor_slave,r1
@wait_slv:
 		mov	@r1,r0
 		cmp/eq	#0,r0
 		bf	@wait_slv
   		mov	#1,r0
   		mov	r0,@r1
		
		mov	#mstr_faces,r12
@next_draw:
      		mov	@r12+,r11
      		mov	#-1,r0
      		cmp/eq	r0,r11
      		bt	@end_this

       		mov	@(faces_srcaddr,r11),r1
      		mov	@(faces_type,r11),r3
           	mov	@(face_tex,r11),r4
           	mov	@(face_tex_width,r11),r5
           	mov	@(face_tex_add,r11),r6
      		add 	#face_points,r11
      		mov	r11,r2
           	mov 	#0,r7
           	
            	bsr	Draw_Face
            	nop
              	bra	@next_draw
            	nop
            	
@end_this:
  		mov	#taskfor_slave,r1
@wait_slvfinish:
  		mov	@r1,r0
  		cmp/eq	#0,r0
  		bf	@wait_slvfinish

 		mov.l	@r15+,pr
  		rts
 		nop
 		lits
 		cnop 0,4

; ----------------------------------------
; Fix point for resize (X and Y)
; 
; Input:
; r0 - tan
; r5 - point
;
; Output:
; r0 - resized point (realpoint+r0)
; ----------------------------------------

@mdl_setresize:
		mov 	r0,r4
		mov 	#0,r0
 		mov.w	@(4,r12),r0
 		exts.w	r0,r3
     		mov	@(model_z,r14),r1
     		add 	r1,r3

         	mov	r4,r0
  		cmp/pz	r5
          	bf	@plus_2
 		neg 	r3,r3
@plus_2:
       		mov	#$7FF,r1
  		and	r1,r0
  		shll2 	r0
         	mov	#sin_table,r1 
         	mov	@(r0,r1),r0
   		dmuls	r3,r0
   		mov	macl,r0
  		shlr16	r0
  		exts	r0,r0
  		
  		cmp/pz	r5
          	bf	@plus_3
 		neg 	r0,r0
@plus_3:
  		rts
 		nop
 		lits
 		cnop 0,4
	
; ----------------------------------------
; Fix point for resize (X and Y)
; 
; Input:
; r0 - tan
; r5 - point
;
; Output:
; r0 - resized point (realpoint+r0)
; ----------------------------------------

@mdl_setresize_alt:
		mov 	r0,r4
		mov 	#0,r0
 		mov.w	@(4,r12),r0
 		exts.w	r0,r3
     		mov	@(model_z,r14),r1
     		add 	r1,r3

     		shlr	r3
     		exts	r3,r3
         	mov	r4,r0
  		cmp/pz	r5
          	bf	@plus_4
 		neg 	r3,r3
@plus_4:
       		mov	#$7FF,r1
  		and	r1,r0
  		shll2 	r0
         	mov	#sin_table,r1 
         	mov	@(r0,r1),r0
   		dmuls	r3,r0
   		mov	macl,r0
  		shlr16	r0
  		exts	r0,r0
  		
  		cmp/pz	r5
          	bf	@plus_5
 		neg 	r0,r0
@plus_5:
  		rts
 		nop
 		lits
 		cnop 0,4
 		
; =================================================================
; ; ----------------------------------------
; ; *** SLAVE SIDE ***
; ; ----------------------------------------
; 
; Mars3D_Slave:
; 		mov.l	pr,@-r15
; 		
;  		mov	#taskfor_slave,r14
; 		mov	@r14,r0
; 		cmp/eq	#0,r0
; 		bt	@no_req
; 		
; 		shll2	r0
; 		mov.l	#@TRIDI_TASKS,r1
; 		add	r1,r0
; 		mov.l	@r0,r1
; 		mov.l	pr,@-r15
; 		jsr	@r1
; 		nop
; 		mov.l	@r15+,pr
; 		
;  		mov	#0,r0
;  		mov	r0,@r14
; @no_req:
; 		mov.l	@r15+,pr
; 		rts
; 		nop
; 
; ; ----------------------------------------
; 
; @TRIDI_TASKS:
; 		dc.l 0
; 		dc.l @task_1
; 		dc.l @task_2
; 		
; ; ----------------------------------------
; ; Task 1
; ; ----------------------------------------
; 
; @task_1:
; 		mov.l	pr,@-r15
; 
;  		mov	#face_num_sl,r0
;  		mov	@r0,r13
;     		mov	@(faces_srcaddr,r13),r1
;      		mov	r13,r2
;       		add 	#face_points,r2
;     		mov	@(faces_type,r13),r3
;          	mov	@(face_tex,r13),r4
;          	mov	@(face_tex_width,r13),r5
;          	mov	@(face_tex_add,r13),r6
;           	bsr	Draw_Face
;           	nop
;           	
; 		mov.l	@r15+,pr
; 		rts
; 		nop
; 		
; ; ----------------------------------------
; ; Task 2
; ; ----------------------------------------
; 
; @task_2:
; 		mov.l	pr,@-r15
; 		
; 		mov.l	@r15+,pr
; 		rts
; 		nop
		
; =================================================================
; ----------------------------------------
; Init
; ----------------------------------------

; models_init:
; 		mov.l	pr,@-r15
;     		
; 		mov.l	@r15+,pr
;  		rts
; 		nop
; 		lits
; 		cnop 0,4
		
; =================================================================
; ----------------------------------------
; Run
; ----------------------------------------

models_run:
		mov.l	pr,@-r15
    		
; -------------------------
; Draw models
; -------------------------

 		mov.l	#models_buffer,r14
   		mov	#numof_models-1,r1
@next_model:
		mov.l	@(model_addr,r14),r13
 		cmp/pl	r13
 		bf	@no_model

   		mov.l	r1,@-r15
 		bsr	mars3d_makemdl
 		nop
    		mov.l	@r15+,r1
@no_model:
      		add	#sizeof_model,r14
   		dt	r1
    		bf	@next_model
    		
; -------------------------

		mov.l	@r15+,pr
 		rts
		nop
		lits
		cnop 0,4	
		
; =================================================================