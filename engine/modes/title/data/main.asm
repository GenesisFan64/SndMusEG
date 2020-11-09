; =================================================================
; ------------------------------------------------
; Data
; ------------------------------------------------

Art_Title_BG:	dc.w ((@End-Art_Title_BG)/4)-1
		incbin	"engine/modes/Title/data/bg_art.bin"
@End:
		even
Art_Title:	dc.w ((@End-Art_Title)/4)-1
		incbin	"engine/modes/Title/data/art.bin"
@End:
		even
		
		
Pal_Title_BG:	incbin	"engine/modes/Title/data/bg_pal.bin"
@End:
		even
Map_Title_BG:	incbin	"engine/modes/Title/data/bg_map.bin"
		even
		


Pal_Title:	incbin	"engine/modes/Title/data/pal.bin"
@End:
		even
Map_Title:	incbin	"engine/modes/Title/data/map.bin"
		even