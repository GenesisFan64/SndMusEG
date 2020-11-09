; ====================================================================
; -------------------------------------------------
; VBlank
; -------------------------------------------------

MD_Vint:
		tst.l	(RAM_VIntAddr)
		beq.s	@NoVIntEx
		
		movem.l	a0-a6/d0-d7,-(sp)
		jsr	(RAM_VIntJumpTo)
		movem.l	(sp)+,a0-a6/d0-d7
@NoVIntEx:
		addq.l	#1,(RAM_FrameCount)
		bset	#1,(RAM_VIntWait)
		bclr	#bitFrameWait,(RAM_VIntWait)
		rte

; ====================================================================
; -------------------------------------------------
; HBlank
; -------------------------------------------------

MD_Hint:		
		jsr	(RAM_HIntJumpTo)
		rte
		
; ====================================================================
; -------------------------------------------------
; Separate routines
; -------------------------------------------------

VInt_Default:
		bsr	PalFade
		bsr	SMEG_Upd
		bsr	Pads_Read
;  		bsr	DMA_Read
 	
; -------------------------------------------------

Dma_Visual:
; 		move.w	#$100,($A11100)
; @WaitZ80:
; 		btst	#0,($A11100)
;  		bne.s	@WaitZ80
 		
; -----------
 
		lea	($C00004),a6
		
; -----------
; Palette
; -----------
 		move.l	#$9400+((($80)&$FF00)>>9)|(($9300+((($80)&$FF)>>1))<<16),(a6)
 		move.l	#$9600+(((RAM_PalBuffer>>1)&$FF00)>>8)|(($9500+((RAM_PalBuffer>>1)&$FF))<<16),(a6)
		move.w	#$9700+((((RAM_PalBuffer>>1)&$FF0000)>>16)&$7F),(a6)
		move.w	#$C000,(a6)
		move.w	#$0000|$80,-(sp)
		move.w	(sp)+,(a6)
; -----------
; Sprites
; -----------
 		move.l	#(($9400|(((($280)>>1)&$FF00)>>8))<<16)|($9300|((($280)>>1)&$FF)),(a6)
 		move.l	#$9600+(((RAM_SprBuffer>>1)&$FF00)>>8)|(($9500+((RAM_SprBuffer>>1)&$FF))<<16),(a6)
		move.w	#$9700+((((RAM_SprBuffer>>1)&$FF0000)>>16)&$7F),(a6)
		move.w	#$7800,(a6)
		move.w	#$0003|$80,-(sp)
		move.w	(sp)+,(a6)
; -----------	
; Horizontal
; -----------
 		move.l	#(($9400|(((((240*4))>>1)&$FF00)>>8))<<16)|($9300|((((240*4))>>1)&$FF)),(a6)
 		move.l	#$9600+(((RAM_HorBuffer>>1)&$FF00)>>8)|(($9500+((RAM_HorBuffer>>1)&$FF))<<16),(a6)
		move.w	#$9700+((((RAM_HorBuffer>>1)&$FF0000)>>16)&$7F),(a6)
		move.w	#$7C00,(a6)
		move.w	#$0003|$80,-(sp)
		move.w	(sp)+,(a6)
	
; -----------
; Vertical
; -----------

; TODO checar bien esto

 		move.l	#(($9400|((((($50))>>1)&$FF00)>>8))<<16)|($9300|(((($50))>>1)&$FF)),(a6)
 		move.l	#$9600+(((RAM_VerBuffer>>1)&$FF00)>>8)|(($9500+((RAM_VerBuffer>>1)&$FF))<<16),(a6)
		move.w	#$9700+((((RAM_VerBuffer>>1)&$FF0000)>>16)&$7F),(a6)
		move.w	#$4000,(a6)
		move.w	#$0010|$80,-(sp)
		move.w	(sp)+,(a6)

; 		move.w	#0,($A11100).l
		
; 		lea	(RAM_PalBuffer),a0
;  		move.l	#$C0000000,($C00004).l
;  		move.w	#$3F,d0
; @PalBuf:
; 		move.w	(a0)+,($C00000).l
;  		dbf	d0,@PalBuf
; 
; 		lea	(RAM_SprBuffer),a0
; 		move.l	#$78000003,($C00004).l
; 		move.w	#$9F,d0
; @SprBuf:
; 		move.l	(a0)+,($C00000).l
; 		dbf	d0,@SprBuf
; 		
; 		lea	(RAM_VerBuffer),a0
; 		move.l	#$40000010,($C00004).l
; 		move.w	#$F,d0
; @VerBuf:
; 		move.l	(a0)+,($C00000).l
; 		dbf	d0,@VerBuf
; 
; 		lea	(RAM_HorBuffer),a0
; 		move.l	#$7C000003,($C00004).l
; 		move.w	#224-1,d0
; @HorBuf:
; 		move.l	(a0)+,($C00000).l
; 		dbf	d0,@HorBuf

		rts

; -------------------------------------------------

Hint_Default:
		rts
