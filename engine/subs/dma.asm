; =====================================================================================
; DMA
; =====================================================================================

; -----------------------------------
; Read
; -----------------------------------

; ROM data
; Size
; VRAM Destiantion

DMA_Read:
		move.w	#$100,($A11100).l
@WaitZ80:
		btst	#0,($A11100).l
		bne.s	@WaitZ80
		
 		lea	(RAM_DMA_Buffer),a6
 		
  		move.w	(a6)+,d4
  		tst.w	d4
  		beq	@FinishList
  		sub.w	#1,d4
@NextEntry:
 		move.l	(a6)+,d6			;ROM address
     		if MARS
		and.l	#$FFFFF,d6
     		endif
  		lsr.l	#1,d6
 		if SegaCD
 		add.b	#1,d6
 		endif
  		move.w	#$9500,d5
 		move.b	d6,d5
 		move.w	d5,($C00004).l
  		move.l	#$97009600,d5			;ROM Address (XXXX00)
 		lsr.l	#8,d6
 		move.b	d6,d5
 		swap	d5
 		lsr.l	#8,d6
 		move.b	d6,d5
 		move.l	d5,($C00004).l
 		
 		move.l	#$94009300,d5			;Size
 		move.w	(a6)+,d6
 		move.b	d6,d5
 		swap	d5
 		lsr.w	#8,d6
 		move.b	d6,d5
 		move.l	d5,($C00004).l
 		
 		move.w	(a6)+,d6			;VRAM Destiantion
 		and.w	#$7FF,d6
 		lsl.w	#5,d6				;x20
 		and.l	#$FFE0,d6
 		lsl.l	#2,d6
 		lsr.w	#2,d6
 		swap	d6
 		or.l	#$40000080,d6
 		move.l	d6,($C00004)
 		dbf	d4,@NextEntry
@FinishList:
		clr.w	(RAM_DMA_Buffer)
		move.w	#0,($A11100).l
 		rts

; -----------------------------------
; Set new entry to the list
; 
; Input:
; d0 - ROM Address
; d1 - Size
; d2 - VRAM
; 
; Uses:
; a2/d3
; -----------------------------------

DMA_Set:
		lea	(RAM_DMA_Buffer),a2
		cmp.w	#64,(a2)
		bge.s	@Return
		move.w	(a2),d3
		lsl.w	#3,d3			;Size: 8
		adda 	d3,a2
		adda	#2,a2

		move.l	d0,(a2)+		;ROM Address
		move.w	d1,(a2)+
		move.w	d2,(a2)+
		add.w	#1,(RAM_DMA_Buffer)
@Return:
		rts

; -----------------------------------
; Quick set
; 
; External
; 
; d0 - Destiantion
; d1 - Source
; d2 - Size
; -----------------------------------

DMA_QuickSet:
		movem.l	a1-a2,-(sp)
		move.l	d1,a1
		addq.l	#2,d1
		asr.l	#1,d1
		lea	($C00004).l,a2
		move.w	#$8F02,(a2)
; 		move.w	#$8164,d3
; 		bset	#4,d3
; 		move.w	d3,(a2)
		move.l	#$940000,d3
		move.w	d2,d3
		lsl.l	#8,d3
		move.w	#$9300,d3
		move.b	d2,d3
		move.l	d3,(a2)
		move.l	#$960000,d3
		move.w	d1,d3
		lsl.l	#8,d3
		move.w	#$9500,d3
		move.b	d1,d3
		move.l	d3,(a2)
		swap	d1
		move.w	#$9700,d3
		move.b	d1,d3
		move.w	d3,(a2)
		or.l	#$40000080,d0
		swap	d0
		move.w	d0,(a2)
		swap	d0
		move.w	d0,-(sp)
		move.w	(sp)+,(a2)
; 		move.w	#$8164,(a2)
		and.w	#$FF7F,d0
		move.l	d0,(a2)
		move.l	(a1),-4(a2)
		move.w	#$8F02,(a2)
		movem.l	(sp)+,a1-a2
		rts
		