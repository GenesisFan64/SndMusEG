; =====================================================================
; Main CPU
; =====================================================================
; -------------------------------------------
; Variables
; -------------------------------------------

ThisCpu		equ $A12000
CD_PrgRamMode	= 0

; =====================================================================
; -------------------------------------------
; Include
; -------------------------------------------

		include "engine/ram.asm"
		include	"cd/incl/equs.asm"

; =====================================================================
; -------------------------------------------
; Init
; -------------------------------------------

		org $FFFF0600
		
; =====================================================================
; -------------------------------------------
; Main
; -------------------------------------------

		bset	#1,($A12003)			; Give WordRAM to Sub CPU
@initloop:		
		tst.b	($A1200F)			; Has sub CPU finished init?
		bne	@initloop			; if not, branch

		move.w	#$2700,sr

   		lea	(RAM_CdShared),a0
   		move.w	#($FFFFF000-RAM_CdShared),d0
@ClrWaitRam:
  		clr.b	(a0)+
   		dbf	d0,@ClrWaitRam
   		
 		move.l	#$00000020,($C00004)		;Copy CRAM to PalBuffer
 		lea	(RAM_PalBuffer),a1
 		move.w	#$3F,d0
@CopyPal:
 		move.w	($C00000),(a1)+
 		dbf	d0,@CopyPal
 		
 		move.l	#$40000010,($C00004).l
 		clr.l	($C00000).l
 		
; ---------------------------------------
; Copy the WAIT code to RAM
; ---------------------------------------

 		lea	WaitCode(pc),a0
 		lea	(RAM_Wait_Code),a1
 		move.w	#(WaitCode_End-WaitCode)-1,d0
@next:
		move.b	(a0)+,(a1)+
		dbf	d0,@next

		move.w	#$4EF9,d0
 		move.w	d0,(RAM_VIntJumpTo)
		move.w	d0,(RAM_HIntJumpTo)	
		move.w	d0,(RAM_GoToHint)
    		move.l	#VBlank,($FFFFFD08)
    		
		bsr	Pads_Init
		bsr	Vdp_Init
		moveq	#$40,d0
		bsr 	SubCpu_Task_Wait
		
; ---------------------------------------

 		move.b	#1,(RAM_VdpRegs+vdpReg_PlnSize)
 		
; ---------------------------------------

 		move.w	#$2000,sr
 
  		move.l	#ID_FadeOut,d0
  		move.l	#$003F0001,d1
  		bsr	PalFade_Set
  		bsr	PalFade_Wait
		
; ---------------------------------------
; Show the "Loading..." screen
; ---------------------------------------

  		move.w	#$2700,sr
 		
; 		move.l	#$8C819001,($C00004).l
;  		bsr	VDP_ClearPlanes
;    		lea	(Art_CdSplsh),a0
;    		move.w	#0,d0
;    		move.w	(a0)+,d1
;    		bsr	VDP_SendData_L
;   		clr.w	(RAM_PalFadeBuff)
;   		lea	(Pal_CdSplsh),a0
;   		lea	(RAM_PalFadeBuff+$60),a1
;  		move.w	#15,d0
;    		bsr	LoadData_Word 
;     		lea	(Map_CdSplsh),a0
;  		moveq	#0,d0
; 		move.l	#($0000<<16)|$0000,d1
;  		move.l	#((((320)/8)-1)<<16)|(((224)/8)-1),d2
; 		move.w	#$6000,d3
; 		bsr	VDP_LoadMaps

; ---------------------------------------

 		move.w	#$2000,sr
 
  		move.l	#ID_FadeIn,d0
  		move.l	#$003F0001,d1
  		bsr	PalFade_Set
  		bsr	PalFade_Wait

 		move.w	#$2700,sr
 		
; ---------------------------------------

		move.b	#0,(RAM_GameMode)
		lea 	(RAM_Wait_Buff),a0
 		move.l	#"PRG_",(a0)+
 		move.l	#"MAIN",(a0)+
 		move.l	#".BIN",(a0)+
		jmp	(RAM_Wait_Code)
		
; =====================================================================	
; -------------------------------------------
; Subs
; -------------------------------------------

 		include	"engine/subs/vdp.asm"
 		include	"engine/subs/fade.asm"
   		include	"engine/subs/pads.asm"
   		include	"engine/subs/misc.asm"
                
; -------------------------------------------------
; VBlank
; -------------------------------------------------
 
VBlank:
 		movem.l	d0-d7/a0-a6,-(sp)
 		bsr	PalFade
  
 		lea	(RAM_PalBuffer),a0
 		move.l	#$C0000000,($C00004).l
 		move.w	#$3F,d0
@PalBuf:
 		move.w	(a0)+,($C00000).l
 		dbf	d0,@PalBuf
 
 		movem.l	(sp)+,d0-d7/a0-a6
 		bset	#1,(RAM_VIntWait)
 		bclr	#bitFrameWait,(RAM_VIntWait)
 		rte
 		
; =====================================================================
; -------------------------------------------
; Temporal data
; -------------------------------------------
 
; Pal_CdSplsh:	incbin	"engine/misc/cdsplash/pal_cdsplsh.bin"
;  		even
; Map_CdSplsh:	incbin	"engine/misc/cdsplash/map_cdsplsh.bin"
;   		even
; Art_CdSplsh:	dc.w ((@End-Art_CdSplsh)/4)-1
;    		incbin	"engine/misc/cdsplash/art_cdsplsh.bin"
; @End:		even

; =====================================================================
; -------------------------------------------
; Wait code
; -------------------------------------------

WaitCode:
		obj RAM_Wait_Code
		
		move.w	#$2700,sr
		lea 	(RAM_Wait_Buff),a0
 		move.l	(a0)+,d0
 		move.l	(a0)+,d1
 		move.l	(a0)+,d2
 		bsr	Load_PrgRam

		jmp	($FFFF0000)
		
; -------------------------------------------------
; Subs
; -------------------------------------------------

                include	"cd/incl/subtask.asm"

		objend
WaitCode_End:

; ====================================================================

		inform 0,"MAIN IPL SIZE: %h",*-$FFFF0600
		inform 0,"WAIT IPL SIZE: %h",WaitCode_End-WaitCode

		
