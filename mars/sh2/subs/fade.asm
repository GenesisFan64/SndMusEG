; ==================================================================
; ---------------------------------------------------
; FadeIn / FadeOut
; ---------------------------------------------------

; ---------------------------------------
; Variables
; ---------------------------------------

ID_FadeOut		equ	$01
ID_FadeIn		equ	$02
ID_ToWhite		equ	$03
ID_FadeWhite		equ	$04

; ---------------------------------------

			rsreset
fade_request		rs.l	1
fade_flags		rs.l	1
fade_start		rs.l	1
fade_end		rs.l	1
fade_timer		rs.l	1
fade_timerset		rs.l	1

; ---------------------------------------

bitFinished		equ 	7
		
; ==================================================================
; ---------------------------------------------------
; pal_fade
; ---------------------------------------------------
	
pal_fade:
		mov.l	#palfade_control,r9
		mov.l	@(fade_flags,r9),r0
		cmp/eq	#0,r0
		bt	@NotFinished
		mov.l	@(fade_timer,r9),r0
		sub 	#1,r0
		mov.l	r0,@(fade_timer,r9)
		cmp/pz	r0
		bf	@Finished
		rts
		nop
@NotFinished:
		mov.l	@(fade_request,r9),r0
		shll2	r0
		mov.l	#@DoList,r1
		add	r1,r0
		mov.l	@r0,r1
		jmp	@r1
		nop
@Finished:
		mov.l	@(fade_timerset,r9),r0
		mov.l	r0,@(fade_timer,r9)
		mov 	#0,r0
		mov 	r0,@(fade_request,r9)
		mov 	r0,@(fade_flags,r9)
		
		mov.b	@(comm0+1,gbr),r0
		and 	#%11101111,r0				;PalFade flag RESET
		mov.b	r0,@(comm0+1,gbr)
		
		rts
		nop
		align 4
		lits
		
; =====================================================

@DoList:
		dc.l	@Return
		dc.l	@FadeOut
		dc.l	@FadeIn
		dc.l	@Return
		dc.l	@Return
		even

; =====================================================
; ---------------------------------------------------
; FadeOut
; ---------------------------------------------------
	
@FadeOut:
		mov.l	@(fade_timer,r9),r0
		sub 	#1,r0
		mov.l	r0,@(fade_timer,r9)
		cmp/pz	r0
		bt	@Return_Out
		mov	@(fade_timerset,r9),r0
		mov 	r0,@(fade_timer,r9)
	
		mov.l	#pal_buffer,r7
		mov.l	@(fade_start,r9),r0
		shll 	r0
		add 	r0,r7

		mov.l	@(fade_end,r9),r6
		add 	#1,r6	
 		mov	#0,r5
 		mov 	#0,r2
@Next_ColorOut:
 		move.w	#%11111,r4		;MAX color
 		mov 	#0,r0
 		mov.w	@r7,r0
   		mov	r0,r1
   		and	r4,r1
   		cmp/eq	r2,r1
   		bt	@RedFirstOut
  		mov 	#1,r1
 		sub	r1,r0
@RedFirstOut:
 		shll2 	r4
 		shll2 	r4
 		shll 	r4
  		mov	r0,r1
  		and	r4,r1
  		cmp/eq	r2,r1
  		bt	@GreenFirstOut
  		mov 	#$20,r1
 		sub	r1,r0
@GreenFirstOut:
 		shll2 	r4
 		shll2 	r4
 		shll 	r4
  		mov	r0,r1
  		and	r4,r1
  		cmp/eq	r2,r1
  		bt	@BlueFirstOut
  		mov 	#$400,r1
  		sub 	r1,r0
@BlueFirstOut:
 		mov 	#$7FFF,r3
 		mov	r0,r1
 		and	r3,r1
 		cmp/eq	r2,r1
 		bf	@NotBlackOut
 		add	#1,r5
@NotBlackOut:
		and 	r3,r0
		mov.w	r0,@r7
		add 	#2,r7
		dt	r6
		bf	@Next_ColorOut
		
 		mov.l	@(fade_end,r9),r0
 		cmp/ge	r0,r5
 		bf	@Return_Out
 		
		mov	#1,r0
		mov.l	r0,@(fade_flags,r9)
 	
@Return_Out:
		rts
		nop
		align 4
		lits
		
; =====================================================
; ---------------------------------------------------
; FadeIn
; ---------------------------------------------------

@FadeIn:
		mov.l	@(fade_timer,r9),r0
		sub 	#1,r0
		mov.l	r0,@(fade_timer,r9)
		cmp/pz	r0
		bt	@Return
		mov	@(fade_timerset,r9),r0
		mov 	r0,@(fade_timer,r9)
	
		mov.l	#pal_buffer,r7
		mov.l	#pal_fadebuff,r8
		
		mov.l	@(fade_start,r9),r0
		shll 	r0
		add 	r0,r7
		add 	r0,r8

		mov.l	@(fade_end,r9),r6
; 		mov 	#0,r0
; 		cmp/eq	r0,r6
; 		bt	@zero
		add 	#1,r6	
; @zero:
		mov	#0,r5
		
@Next_Color:
		move.w	#%11111,r4		;MAX color
		mov 	#0,r0
		mov 	#0,r1
 		mov.w	@r7,r0
 		mov.w	@r8,r1
 		mov	r0,r2
 		mov	r1,r3
 		and	r4,r2
 		and	r4,r3
 		cmp/ge	r3,r2
 		bt	@RedFirst
 		mov 	#1,r2
		add	r2,r0
@RedFirst:
		shll2 	r4
		shll2 	r4
		shll 	r4
 		mov	r0,r2
 		mov	r1,r3
 		and	r4,r2
 		and	r4,r3
 		cmp/ge	r3,r2
 		bt	@GreenFirst
 		mov 	#$20,r2
		add	r2,r0
@GreenFirst:
		shll2 	r4
		shll2 	r4
		shll 	r4
 		mov	r0,r2
 		mov	r1,r3
 		and	r4,r2
 		and	r4,r3
 		cmp/ge	r3,r2
 		bt	@BlueFirst
 		mov 	#$400,r2
		add	r2,r0
@BlueFirst:
  		cmp/eq	r0,r1
  		bf	@NotEqual
  		add	#1,r5
@NotEqual:
 		mov.w	r0,@r7
 		add 	#2,r7
 		add	#2,r8
 		dt 	r6
 		bf	@Next_Color

 		mov.l	@(fade_end,r9),r0
 		cmp/ge	r0,r5
 		bf	@Return
 		
		mov	#1,r0
		mov.l	r0,@(fade_flags,r9)
 		
		rts
		nop
		align 4
		lits
		
; =====================================================
; ---------------------------------------------------
; Nothing
; ---------------------------------------------------

@Return:
		rts
		nop
		align 4
		lits

; ==================================================================
; ---------------------------------------------------
; pal_fade
;
; r1 - request type
; r2 - speed
; r3 - start from
; r4 - number of colors
; ---------------------------------------------------

palfade_set:
		mov.l	#palfade_control,r5
	
		mov	r2,@(fade_timerset,r5)
		mov 	r3,@(fade_start,r5)
		mov 	r4,@(fade_end,r5)
		mov	r1,@(fade_request,r5)
		
		mov.b	@(comm0+1,gbr),r0
		or	#%00010000,r0		;PalFade flag SET
		mov.b	r0,@(comm0+1,gbr)
		
		rts
		nop
		align 4
		lits
		