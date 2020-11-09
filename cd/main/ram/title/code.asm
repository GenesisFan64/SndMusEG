; =====================================================================
; PRG-RAM Program
;
; Title
; ==========================================================

; ---------------------------------------------
; Variables
; ---------------------------------------------

ThisCpu		equ $A12000
CD_PrgRamMode	= 0

; =====================================================================
; ---------------------------------------------
; Custom header
; ---------------------------------------------
		
		dc.b "RAM "
		dc.l 0
		dc.l PrgCode,PrgCode_End
		dc.l PrgData,PrgData_End
		
; =====================================================================
; ---------------------------------------------
; Include
; ---------------------------------------------

		include "engine/ram.asm"
		include	"cd/incl/equs.asm"

; =====================================================================
; ---------------------------------------------
; Init
; ---------------------------------------------

PrgCode:
		obj $FFFF0000
		move.l	#MD_Hint,(RAM_GoToHint+2)
		move.w	#((RAM_GoToHint)&$FFFF),($A12006).l
  		move.l	#MD_Vint,($FFFFFD08)
 		move.l	#MD_Hint,($FFFFFD0E)
 		
; ====================================================================
; -------------------------------------------------
; Program data
; -------------------------------------------------
		
		move.l	#VInt_Default,(RAM_VIntAddr)
		move.l	#Hint_Default,(RAM_HIntAddr)
		clr.b	(RAM_VIntWait)
		clr.l	(RAM_DMA_Buffer)
		
		bsr	SMEG_Init
		move.w	#$2000,sr
		
; -------------------------------------------------
; Modes
; -------------------------------------------------

@RunMode:
                moveq	#0,d0
                move.b	(RAM_GameMode),d0
                lsl.w	#4,d0
                lea	GameModes(pc,d0.w),a0
                tst.w	(a0)
                bne.s	@FileName
                movea.l	4(a0),a0
                jsr	(a0)
                bra.s	@RunMode
@FileName:
		lea 	(RAM_Wait_Buff),a1
		adda	#4,a0
 		move.l	(a0)+,(a1)+
 		move.l	(a0)+,(a1)+
 		move.l	(a0)+,(a1)+
 		
		bsr	Mode_FadeOut
 		bsr	SMEG_StopSnd
		jmp	(RAM_Wait_Code)
		
; -------------------------------------------------
; Mode list
; -------------------------------------------------

GameModes:
		dc.w 0,0
 		dc.l mode_Title,0,0
 		dc.w 1,0
 		dc.b "PRG_LEVL.BIN"
 		even

; ---------------------------------------------
; Subs
; ---------------------------------------------

		include	"engine/subs/vdp.asm"
		include	"engine/subs/fade.asm"
		include	"engine/subs/misc.asm"
		include	"engine/subs/pads.asm"
		include	"engine/subs/dma.asm"
                include	"engine/ints.asm"
                include	"cd/incl/subtask.asm"
                
; ====================================================================
; ---------------------------------------------
; Code | Modes
; ---------------------------------------------

		include	"engine/modes/title/code.asm"
		
; ---------------------------------------------
; Code | Sound
; ---------------------------------------------

		include	"engine/sound/code.asm"
	
; ====================================================================

 		objend
PrgCode_End:
 		
; ====================================================================

PrgData:
		obj $200000
		
; ---------------------------------------------
; Data | Sound
; ---------------------------------------------

		include	"engine/sound/data/main.asm"
		
; ---------------------------------------------
; Data | Shared
; ---------------------------------------------

		include	"engine/shared/main.asm"
		
; ---------------------------------------------
; Data | Modes
; ---------------------------------------------

		include	"engine/modes/title/data/main.asm"
		
; ---------------------------------------------

		objend	
PrgData_End:

; =====================================================================

		inform 0,"THIS PRG-RAM CODE/DATA USES: %h of %h | %h of 3FFFF",PrgCode_End,sizeof_prg,((PrgData_End-PrgData)-1)
		
; =====================================================================

		cnop 0,$40000
		