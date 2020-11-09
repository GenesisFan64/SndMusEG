; ====================================================================
; MD Side
; ====================================================================

		include	"engine/ram.asm"

; ====================================================================
; -------------------------------------------------
; Header / Init
; -------------------------------------------------

		include "md/init.asm"
		include	"md/error.asm"
		     
; -------------------------------------------------
; Program data
; -------------------------------------------------

		include	"engine/main.asm"

; -------------------------------------------------
; Mode list
; -------------------------------------------------

GameModes:
 		dc.l mode_Title
;  		dc.l mode_Level
 		even

; ====================================================================
; ---------------------------------------------
; Subs
; ---------------------------------------------

		include	"engine/subs/vdp.asm"
		include	"engine/subs/fade.asm"
		include	"engine/subs/misc.asm"
		include	"engine/subs/pads.asm"
		include	"engine/subs/dma.asm"
                include	"engine/ints.asm"
                
; ====================================================================
; ---------------------------------------------
; Code | Modes
; ---------------------------------------------

; 		include	"engine/modes/level/code.asm"
		include	"engine/modes/title/code.asm"
		
; ---------------------------------------------
; Code | Sound
; ---------------------------------------------

		include	"engine/sound/code.asm"
		
; ====================================================================
; ---------------------------------------------
; Data | Shared
; ---------------------------------------------

		include	"engine/shared/main.asm"
		
; ---------------------------------------------
; Data | Modes
; ---------------------------------------------

; 		include	"engine/modes/level/data/main.asm"
		include	"engine/modes/title/data/main.asm"
		
; ---------------------------------------------
; Data | Sound
; ---------------------------------------------

		include	"engine/sound/data/main.asm"

; ---------------------------------------------
; Data | Misc
; ---------------------------------------------
		
; ====================================================================

		inform 0,"*** ROM SIZE: %h ***",*
		cnop 0,$100000
MD_RomEnd:
		END
