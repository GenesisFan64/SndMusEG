; ========================================================
; CD Side
; ========================================================

		dc.b "SEGADISCSYSTEM  "		; Disc Type (Must be SEGADISCSYSTEM)
		dc.b "YACOPU-CD  ",0		; Disc ID
		dc.w $100,1			; System ID, Type
		dc.b "YACOPU-SYS ",0		; System Name
		dc.w 0,0			; System Version, Type
		dc.l IP_Start
		dc.l IP_End
		dc.l 0
		dc.l 0
		dc.l SP_Start
		dc.l SP_End
		dc.l 0
		dc.l 0

		cnop 0,$100			; Pad to $100
		dc.b "SEGA MEGA DRIVE "
		dc.b "(C)GF64 2016.???"
		dc.b "???????????????????                             "
                dc.b "Lack of ideas: the videogame CD                 "
		dc.b "GM HOMEBREW-00  "
		dc.b "J               "
		cnop 0,$1F0
		dc.b "U               "

; ========================================================
; -------------------------------------------------
; IP
; -------------------------------------------------

		incbin "cd/region/usa.bin"

		bra	IP_Start
		cnop 0,$800
IP_Start:
		incbin "cd/main.bin"
		cnop 0,$800
IP_End:
		even
		
; ========================================================
; -------------------------------------------------
; SP
; -------------------------------------------------

		cnop 0,$800
SP_Start:
		incbin "cd/sub.bin"
		cnop 0,$800
SP_End:
		even
		
; ========================================================
; -------------------------------------------------
; CD Filesystem
; -------------------------------------------------

		cnop 0,$8000
		incbin	"cd/fs.bin",$8000
 		
; ========================================================

		inform 0,"CD SIZE: %h",*		;MAX: $CDFE2E0
		cnop 0,$100000
