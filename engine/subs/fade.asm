; =====================================================
; FadeIn/FadeOut
; =====================================================

; ---------------------------------------
; Variables
; ---------------------------------------

; PalFadeHint		equ	$50

ID_FadeOut		equ	$01
ID_FadeIn		equ	$02
ID_ToWhite		equ	$03
ID_FadeWhite		equ	$04

; ---------------------------------------

PalFadeFlags		equ	1
PalFadeStart		equ	2  ;START(byte)|END(byte)|TIMER(word)
PalFadeEnd		equ	3
PalFadeTmr		equ	4
PalFadeSource		equ	8

; ---------------------------------------

bitFinished		equ 	7

; =====================================================
; Genesis palette
; =====================================================

PalFade:
; 		if MARS
; 		bsr	PalFade_Mars
; 		endif

		lea	(RAM_PalFadeControl),a6
		btst	#bitFinished,(a6)
		beq.s	@NotFinished
		sub.w	#1,PalFadeTmr+2(a6)
		bmi	@Finished
		rts
@NotFinished:
		moveq	#0,d0
		move.b	(a6),d0
		add.w	d0,d0
		move.w	@DoList(pc,d0.w),d1
		jmp	@DoList(pc,d1.w)

@Finished:
 		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
		clr.b	(a6)
@Return:
		if MARS
		bsr	MARS_PalFadeUpd
		endif
		rts
		
; =====================================================

@DoList:
		dc.w	@Return-@DoList
		dc.w	@FadeOut-@DoList
		dc.w	@FadeIn-@DoList
		dc.w	@ToWhite-@DoList
		dc.w	@FromWhite-@DoList
		even

; =====================================================
; ---------------------------------------------------
; FadeOut
; ---------------------------------------------------

@FadeOut:
		sub.w	#1,PalFadeTmr+2(a6)
		bpl	@Return
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)

		lea	(RAM_PalBuffer),a5
		lea	(RAM_PalBufferHint),a4

		move.w	PalFadeStart(a6),d3
		move.w	d3,d4
		lsr.w	#8,d4
		adda	d4,a5
		adda	d4,a4

		moveq	#0,d6
		move.b	PalFadeStart+1(a6),d6
		moveq	#0,d2
@Next:
		move.w	(a5),d0
		move.w	d0,d1
		and.w	#$E,d1
		tst.w	d1
		beq.s	@RedLast
		sub.b	#2,d0
@RedLast:
		move.w	d0,d1
		lsr.w	#4,d1
		and.w	#$E,d1
		tst.w	d1
		beq.s	@GreenLast
		sub.w	#$20,d0
@GreenLast:
		move.w	d0,d1
		lsr.w	#8,d1
		and.w	#$E,d1
		tst.w	d1
		beq.s	@BlueLast
		sub.w	#$200,d0
@BlueLast:
		tst.w	d0
		bne.w	@NotBlack
		add.w	#1,d2
@NotBlack:
		move.w	d0,(a5)+
		move.w	d0,(a4)+
		dbf	d6,@Next

		moveq	#0,d4
		move.b	d3,d4
		cmp.w	d4,d2
		blt	@Return

		bset	#bitFinished,(a6)
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
		rts

; =====================================================
; ---------------------------------------------------
; FadeIn
; ---------------------------------------------------

@FadeIn:
		sub.w	#1,PalFadeTmr+2(a6)
		bpl	@Return
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)

		lea	(RAM_PalBuffer),a5
		lea	(RAM_PalBufferHint),a3
		lea	(RAM_PalFadeBuff),a4

		move.w	PalFadeStart(a6),d0
		move.w	d0,d4
		lsr.w	#8,d4
		adda	d4,a5
		adda	d4,a3

		moveq	#0,d6
		move.b	PalFadeStart+1(a6),d6
		moveq	#0,d5
@Next_2:
		move.w	(a5),d0
		move.w	(a4),d1
		move.w	d0,d2
		move.w	d1,d3
		and.w	#$E,d2
		and.w	#$E,d3
		cmp.w	d3,d2
		bge.s	@RedFirst
		add.w	#2,d0
@RedFirst:

		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#4,d2
		lsr.w	#4,d3
		and.w	#$E,d2
		and.w	#$E,d3
		cmp.w	d3,d2
		bge.s	@GreenFirst
		add.w	#$20,d0
@GreenFirst:

		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#8,d2
		lsr.w	#8,d3
		and.w	#$E,d2
		and.w	#$E,d3
		cmp.w	d3,d2
		bge.s	@BlueFirst
		add.w	#$200,d0
@BlueFirst:	
		move.w	d0,d2
		move.w	(a4),d1
		cmp.w	d2,d1
		bne.s	@NotEqual
		add.w	#1,d5
@NotEqual:
		adda	#2,a4
		move.w	d0,(a5)+
		move.w	d0,(a3)+
		dbf	d6,@Next_2

		sub.w	#1,d5
		move.w	d5,PalFadeSource(a6)

		moveq	#0,d4
		moveq	#0,d2
		move.b	PalFadeStart+1(a6),d2
		move.b	d5,d4
		cmp.w	d4,d2
		bgt	@Return
		
		bset	#bitFinished,(a6)
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
		rts

; =====================================================
; ---------------------------------------------------
; ToWhite
; ---------------------------------------------------

@ToWhite:
		lea	(RAM_PalBuffer),a5
		sub.w	#1,PalFadeTmr+2(a6)
		bpl	@Return
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)

		move.w	PalFadeStart(a6),d3

		move.w	#$3F,d6
		moveq	#0,d2
@NextW:
		move.w	(a5),d0
		move.w	d0,d1
		and.w	#$E,d1
		cmp.w	#$E,d1
		beq.s	@RedLastW
		add.b	#2,d0
@RedLastW:
		move.w	d0,d1
		lsr.w	#4,d1
		and.w	#$E,d1
		cmp.w	#$E,d1
		beq.s	@GreenLastW
		add.w	#$20,d0
@GreenLastW:
		move.w	d0,d1
		lsr.w	#8,d1
		and.w	#$E,d1
		cmp.w	#$E,d1
		beq.s	@BlueLastW
		add.w	#$200,d0
@BlueLastW:
		cmp.w	#$EEE,d0
		blt.w	@NotWhite
		add.w	#1,d2
@NotWhite:
		move.w	d0,(a5)+
		dbf	d6,@NextW

		moveq	#0,d4
		move.b	d3,d4
		cmp.w	d4,d2
		blt	@Return
		
		bset	#bitFinished,(a6)
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
		rts

; =====================================================
; ---------------------------------------------------
; FromWhite
; ---------------------------------------------------

@FromWhite:
		bset	#bitFinished,(a6)
; 		clr.b	(a6)
		rts

; =====================================================
; ---------------------------------------------------
; Subs
; ---------------------------------------------------

; =====================================================
; MARS palette
; =====================================================
		
		if MARS
PalFade_Mars:
		lea	(RAM_PalFadeControl+$10),a6
		btst	#bitFinished,(a6)
		beq.s	@NotFinished
		sub.w	#1,PalFadeTmr+2(a6)
		bmi	@Finished
		rts
@NotFinished:
		moveq	#0,d0
		move.b	(a6),d0
		add.w	d0,d0
		move.w	@MarsDoList(pc,d0.w),d1
		jmp	@MarsDoList(pc,d1.w)
@Return:
		rts
@Finished:
 		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
		clr.b	(a6)
		rts
		
; =====================================================

@MarsDoList:
		dc.w	@Return-@MarsDoList
		dc.w	@FadeOut-@MarsDoList
		dc.w	@FadeIn-@MarsDoList
		dc.w	@Return-@MarsDoList
		dc.w	@Return-@MarsDoList
		even
		
; =====================================================
; ---------------------------------------------------
; FadeIn
; ---------------------------------------------------

@FadeIn:
		sub.w	#1,PalFadeTmr+2(a6)
		bpl	@Return
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)

		lea	(RAM_MarsPalette),a5
		lea	(RAM_MarsPalFade),a4

		move.w	PalFadeStart(a6),d0
		move.w	d0,d4
		lsr.w	#8,d4
		lsl.w	#1,d4
		adda	d4,a5
		
		moveq	#0,d5
		moveq	#0,d6
		move.b	PalFadeStart+1(a6),d6
@Next_Color:
		move.w	#%11111,d4
		move.w	(a5),d0
		move.w	(a4),d1
 		move.w	d0,d2
 		move.w	d1,d3
 		and.w	d4,d2
 		and.w	d4,d3
 		cmp.w	d3,d2
 		bge.s	@RedFirst
 		move.w	#1,d2
		add.w	d2,d0
@RedFirst:
		lsl.w	#5,d4
 		move.w	d0,d2
 		move.w	d1,d3
 		and.w	d4,d2
 		and.w	d4,d3
 		cmp.w	d3,d2
 		bge.s	@GreenFirst
 		move.w	#$20,d2
		add.w	d2,d0
@GreenFirst:
		lsl.w	#5,d4
 		move.w	d0,d2
 		move.w	d1,d3
 		and.w	d4,d2
 		and.w	d4,d3
 		cmp.w	d3,d2
 		bge.s	@BlueFirst
 		move.w	#$400,d2
		add.w	d2,d0
@BlueFirst:	
 		cmp.w	d0,d1
 		bne.s	@NotEqual
 		add.w	#1,d5
@NotEqual:
		adda	#2,a4
		move.w	d0,(a5)+
		dbf	d6,@Next_Color

 		sub.w	#1,d5
 		move.w	d5,PalFadeSource(a6)

		moveq	#0,d0
		move.b	PalFadeStart+1(a6),d0
		cmp.w	d5,d0
		bne.s	@Return_In
		
   		bset	#bitFinished,(a6)
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
@Return_In:
		rts

; ---------------------------------------------------
; FadeOut
; ---------------------------------------------------

@FadeOut:
		sub.w	#1,PalFadeTmr+2(a6)
		bpl	@Return
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)

		lea	(RAM_MarsPalette),a5
		lea	(RAM_MarsPalFade),a4

		move.w	PalFadeStart(a6),d3
		move.w	d3,d4
		lsr.w	#8,d4
		adda	d4,a5
		adda	d4,a4

		moveq	#0,d6
		move.b	PalFadeStart+1(a6),d6
		moveq	#0,d2
@NextOut:
		move.w	#%11111,d4		;MAX color
		move.w	(a5),d0
		move.w	d0,d1
		and.w	d4,d1
		tst.w	d1
		beq.s	@RedLastOut
 		move.w	#1,d1
		sub.w	d1,d0
@RedLastOut:
		lsl.w	#5,d4
		move.w	d0,d1
		and.w	d4,d1
		tst.w	d1
		beq.s	@GreenLastOut
 		move.w	#$20,d1
		sub.w	d1,d0
@GreenLastOut:
		lsl.w	#5,d4
 		move.w	d0,d1
 		and.w	d4,d1
 		tst.w	d1
 		beq.s	@BlueLastOut
  		move.w	#$400,d1
 		sub.w	d1,d0
@BlueLastOut:
		move.w	d0,d1
		and.w	#$7FFF,d1
		tst.w	d1
		bne.w	@NotBlackOut
		add.w	#1,d2
@NotBlackOut:
		move.w	d0,(a5)+
		move.w	d0,(a4)+
		dbf	d6,@NextOut

		moveq	#0,d4
		move.b	d3,d4
		cmp.w	d4,d2
		blt	@Return

		bset	#bitFinished,(a6)
		move.w	PalFadeTmr(a6),PalFadeTmr+2(a6)
		rts
		
; ---------------------------------------------------

MARS_PalFadeUpd:
		btst 	#7,(marsreg+access)
		bne.s	@sh2_prio
		lea	(RAM_MarsPalette),a5
		lea	(palette),a6
		move.w	#255,d0
@MarsPalBuf:
		move.w	(a5)+,(a6)+
		dbf	d0,@MarsPalBuf
@sh2_prio:
		rts
		
; ---------------------------------------------------

  		endif
		
; =====================================================
; ---------------------------------------
; Subs
; ---------------------------------------

; ---------------------------------------
; PalFade_Set
; 
; Input:
; d0 - Request type
; d1 - Settings:
;      $SSEETTTT   SS StartFrom
;                  EE NumOfColors
;                TTTT Timer
; ---------------------------------------

PalFade_Set:
		lea	(RAM_PalFadeControl),a0

		move.l	d1,PalFadeStart(a0)
		move.w	PalFadeTmr(a0),PalFadeTmr+2(a0)
		move.b	d0,(a0)
		rts

; ---------------------------------------
; PalFadeMars_Set
; 
; Input:
; d0 - Request type
; d1 - Settings:
;      $SSEETTTT   SS StartFrom
;                  EE NumOfColors
;                TTTT Timer
; ---------------------------------------

PalFadeMars_Set:
		if MARS
		btst 	#FM,(marsreg+access)
		bne.s	@Sh2
		
		lea	(RAM_PalFadeControl+$10),a5
		move.l	d1,PalFadeStart(a5)
		move.w	PalFadeTmr(a5),PalFadeTmr+2(a5)
		move.b	d0,(a5)
		rts
@Sh2:

		move.w	d0,(marsreg+comm4)
		move.w	d1,(marsreg+comm6)
		swap	d1
		move.w	d1,d0
		and.w	#$FF,d0
		lsr.w	#8,d1
		and.w	#$FF,d1
		move.w	d1,(marsreg+comm8)
		move.w	d0,(marsreg+comm10)

 		moveq	#$C,d0
 		bsr 	Mars_Task_Master
  		bra 	Mars_Wait_Master
		endif
		rts
		
; ---------------------------------------
; PalFade_Wait
; 
; Wait until fade finishes
; ---------------------------------------

;TODO: its broken, temporal solution

PalFade_Wait:
  		if MARS
  
  		;MARS
   		btst	#FM,(marsreg+access)
   		beq.s	@MD_Mode
  		move.b	(marsreg+comm0+1),d0
  		and.w	#%00010000,d0
  		bne.s	PalFade_Wait
  		bra.s	@MARS_Mode
@MD_Mode:
   		tst.b	(RAM_PalFadeControl)
   		bne.s	@MD_Mode
@MARS_Mode:
  		else
		
		;MD only
  		tst.b	(RAM_PalFadeControl)
  		bne.s	PalFade_Wait
 		
  		endif

		rts

; ---------------------------------------
; PalFade_Wait_Flag
; 
; Wait until fade finishes
; 
; Output:
; bmi - Busy
; beq - Finished
; ---------------------------------------

PalFade_Wait_Flag:
 		moveq	#-1,d6
		tst.b	(RAM_PalFadeControl)
		bne.s	@no
		moveq	#0,d6
@no:
		tst.w	d6
		rts	