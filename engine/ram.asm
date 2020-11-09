; =====================================================
; RAM
; =====================================================

; ----------------
; Sega CD RAM
; ----------------

	if SegaCD
	if CD_PrgRamMode
		rsset $200000+$36800
	else
		rsset $FFFF6800
 	endif
 
; ----------------
; MD/MARS RAM
; ----------------

	else
		rsset $FFFF6800
 	endif
		
; =====================================================
; ----------------------------------------
; Variables
; ----------------------------------------

bitFrameWait		equ	0
bitVBlankWait		equ	1
bitHBlankWait		equ	2
bitDontWaitHInt		equ	3
bitLockPads		equ	4
bitHotStart		equ	5
bitWaitHint		equ	6
bitHasTMSS		equ	7

; ----------------------------------------
; Game vars
; ----------------------------------------

; =====================================================
; ----------------------------------------
; Mode buffer
; ----------------------------------------

RAM_SharedBuffer	rs.b	$80
RAM_ModeBuffer		rs.b	$7000

; ----------------------------------------
; Work stuff
; ----------------------------------------

RAM_VIntJumpTo		rs.w	1		;DONT SEPARATE
RAM_VIntAddr		rs.l	1		;*
RAM_HIntJumpTo		rs.w	1		;DONT SEPARATE
RAM_HIntAddr		rs.l	1		;*

RAM_FrameCount		rs.l	1
RAM_VIntWait		rs.b 	1
RAM_GameMode		rs.b 	1
RAM_Joypads		rs.b	$40
RAM_SprControl		rs.b	$10

; ----------------------------------------
; Sound
; ----------------------------------------

RAM_SndDriver		rs.b	$400

; ----------------------------------------
; DMA
; ----------------------------------------

RAM_DMA_Buffer		rs.b	$400

; ----------------------------------------
; PalFade
; ----------------------------------------

			if MARS
RAM_PalFadeControl	rs.b	$10*2
			else
RAM_PalFadeControl	rs.b	$10
			endif
			
RAM_PalFadeBuff		rs.w	64
RAM_PalFadeBuffHint	rs.w	64

; ----------------------------------------
; Visual stuff
; ----------------------------------------

RAM_HorBuffer		rs.l	240;224
RAM_VerBuffer		rs.l	(320/16)
RAM_SprBuffer		rs.b	(8*80)
RAM_PalBuffer		rs.w	64
RAM_VdpRegs		rs.b	$18

RAM_VerBufferHint	rs.l	(320/16)
RAM_SprBufferHint	rs.l	(8*80)
RAM_PalBufferHint	rs.w	64

; =====================================================
; ----------------------------------------
; Last RAM
; ----------------------------------------

RAM_End			rs.b	0
;                                 inform 0,"RAM ENDS AT: %h",RAM_End
;                         inform 0,"%h",RAM_FrameCount