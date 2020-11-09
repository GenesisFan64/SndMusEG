; ====================================================================
; -------------------------------------------------
; Start
; -------------------------------------------------

MD_Main:
		move.w	#$2700,sr

		move.w	#$4EF9,(RAM_VIntJumpTo)
		move.w	#$4EF9,(RAM_HIntJumpTo)	
		move.l	#VInt_Default,(RAM_VIntAddr)
		move.l	#Hint_Default,(RAM_HIntAddr)
		
		clr.l	(RAM_DMA_Buffer)
		bsr	SRAM_Init
		bsr	Vdp_Init
		bsr	SMEG_Init
		bsr	Pads_Init
 		move.w	#$2000,sr
		
; -------------------------------------------------
; Modes
; -------------------------------------------------

@RunMode:
                moveq	#0,d0
                move.b	(RAM_GameMode),d0
                lsl.w	#2,d0
                and.w	#%11111100,d0
                lea	GameModes(pc),a0
                movea.l	(a0,d0.w),a0
                jsr	(a0)
                bra.s	@RunMode
		
; ====================================================================
