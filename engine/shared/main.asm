; ====================================================================
; Shared Data
; ====================================================================

Art_TempFont:	incbin	"engine/shared/data/art_dbgfont.bin",0,($20*96)
Art_TempFont_End:
		even

; 		if SegaCD
; Pal_StampsTest:	incbin	"engine/misc/stamptest/pal.bin"
; 		even
; Map_StampsTest:	dc.w ((@End-Map_StampsTest)/2)-1
; 		incbin	"engine/misc/stamptest/map.bin"
; @End:
; 		even
; 		endif
