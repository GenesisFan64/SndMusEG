; ==================================================================
; ---------------------------------------------------
; Super VDP
; ---------------------------------------------------

Vdp_NextFrame:
		mov	#_vdpreg,r1
		mov 	#0,r0
		mov.b	@(framectl,r1),r0
		xor	#1,r0
		mov.b	r0,@(framectl,r1)
		mov 	r0,r2
@wait3:
		mov 	#0,r0
		mov.b	@(framectl,r1),r0
		cmp/eq	r0,r2
		bf	@wait3
		rts
		nop
		cnop 0,4
		lits

; ---------------------------------------------------
; Vdp_FlipFrame
;
; Flips the framebuffer
;
; Uses:
; r0-r2
; ---------------------------------------------------

Vdp_FlipFrame:	
		mov	#_vdpreg,r1
		mov	#curr_frame,r2
		mov.b	@(framectl,r1),r0
		xor	#1,r0
		mov.b	r0,@(framectl,r1)
		mov	r0,@r2
		rts
		nop
		cnop 0,4
		lits
		
; ----------------------------------------------------
; Wait frame swap
;
; Make sure frame buffer has swapped
;
; Uses:
; r0-r2
; ----------------------------------------------------

Vdp_WaitFrame:
		mov	#_vdpreg,r1
		mov	#curr_frame,r2
		mov	@r2,r0
		mov	r0,r2
@wait3:
		mov 	#0,r0
		mov.b	@(framectl,r1),r0
		cmp/eq	r0,r2
		bf	@wait3
		rts
		nop
		cnop 0,4
		lits
		
; ----------------------------------------------------
; Clear frame buffer
;
; Uses:
; r0-r6
; ----------------------------------------------------

		align	4
Vdp_ClearFrame:
		mov	#_vdpreg,r1
		mov	#255,r2		; 256 words per pass
		mov	#$100,r3	; Starting address
		mov	#0,r4		; Clear to zero
		mov	#256,r5		; Increment address by 256
		mov	#140,r6		; 140 passes ((320 * 224) / 256)
@loop
		mov.w	@(10,r1),r0	; Wait for FEN to clear
		shlr	r0
		shlr	r0
		bt	@loop
 
		mov	r2,r0
		mov.w	r0,@(4,r1)	; Set length
		mov	r3,r0
		mov.w	r0,@(6,r1)	; Set address
		mov	r4,r0
		mov.w	r0,@(8,r1)	; Set data
 
		add	r5,r3
 
		dt	r6
		bf	@loop
 
@wait
		mov.w	@(10,r1),r0	; Wait for FEN to clear
		shlr	r0
		shlr	r0
		bt	@wait
		rts
		nop

; ---------------------------------------------------
; VDP_SetMode
;
; Set video mode
; 
; Input:
; r1 - mode id
; 
; Uses:
; r1
; ---------------------------------------------------

Vdp_SetMode:
		mov	r1,r0
		mov.l	#_vdpreg,r1
		mov.b	r0,@(bitmapmd,r1)
		
		mov.l	#_framebuffer,r8
		mov.l	#$100,r6
		mov.l	#(320/2),r5
		mov.l	#224,r7
@mapset1:
		mov.w	r6,@r8
		add	#2,r8
		add	r5,r6
		dt	r7
		bf	@mapset1

		mov	#$80,r2
@wait:
		mov.b	@(vdpsts,r1),r0		; Wait V Blank
		tst	r2,r0
		bt	@wait
		mov.b	@(framectl,r1),r0	; Frame Buffer Swap
		not	r0,r0
		mov.b	r0,@(framectl,r1)
	
; ------------------------
; next framebuffer page
; ------------------------

		mov.l	#_framebuffer,r8
		mov.l	#$100,r6
		mov.l	#(320/2),r5
		mov.l	#224,r7
@mapset2:
		mov.w	r6,@r8
		add	#2,r8
		add	r5,r6
		dt	r7
		bf	@mapset2
		
		mov	#$80,r2
@wait2:
		mov.b	@(vdpsts,r1),r0		; Wait V Blank
		tst	r2,r0
		bt	@wait2
		mov.b	@(framectl,r1),r0	; Frame Buffer Swap
		not	r0,r0
		mov.b	r0,@(framectl,r1)
		
		rts
		nop
		cnop 0,4
		lits

; ---------------------------------------------------
; Vsync_M
; 
; Wait for VBlank, Master CPU
; ---------------------------------------------------

Vsync_M:
		mov.l	#vint_m_sync,r1
		mov.l	#1,r0
		mov.l	r0,@r1

@wait:
		mov.l	@r1,r0
		cmp/eq	#0,r0
		bf	@wait
		rts
		nop
		cnop 0,4
		lits

; ---------------------------------------------------
; Vsync_S
; 
; Wait for VBlank, Slave CPU
; ---------------------------------------------------

Vsync_S:
		mov.l	#vint_s_sync,r1
		mov.l	#1,r0
		mov.l	r0,@r1

@wait:
		mov.l	@r1,r0
		cmp/eq	#0,r0
		bf	@wait
		rts
		nop
		cnop 0,4
		lits
		
; ---------------------------------------------------
; Vdp_LoadPal_Raw
;
; Loads RAW palette, modes 1 and 3 only.
; 
; Input:
; r1 - input
; r2 - start from
; r3 - number of colors
; r4 - output
;
; Uses:
; r4-r5
; ---------------------------------------------------

Vdp_LoadPal_Raw:
; 		mov.l	#pal_buffer,r4
 		mov.l	#pal_priobuff,r6
 		add 	#1,r3
; 		mov.l	#256,r3
@next:
		mov.l	#$0000,r7		;prio

 		mov.b	@r1+,r0			;R
  		and	#$FF,r0
  		shlr2	r0
 		shlr 	r0
 		add	r0,r7
  		mov.b	@r1+,r0			;G
  		and	#$FF,r0
  		shlr2	r0
  		shlr 	r0
  		shll2	r0
  		shll2	r0
  		shll	r0
  		add	r0,r7
  		mov.b	@r1+,r0			;B
  		and	#$FF,r0
  		shlr2	r0
  		shlr 	r0
  		shll8	r0
  		shll2	r0
  		add	r0,r7
 		
 		mov.w	r7,@r4	
 		dt	r3
 		bf/s	@next
 		add	#2,r4	

 		rts
 		nop
 		cnop 0,4
 		lits
 		
; ; ---------------------------------------------------
; ; Vdp_LoadPal_Fade
; ;
; ; Loads RAW palette, fadein/fadeout
; ; modes 1 and 3 only.
; ; 
; ; Input:
; ; r1 - input
; ; r2 - start from
; ; r3 - number of colors
; ; r4 - output
; ;
; ; Uses:
; ; r4-r5
; ; ---------------------------------------------------
; 
; Vdp_LoadPal_Fade:
; 		mov.l	#pal_fadebuff,r4
;  		mov.l	#pal_priobuff,r6
; 		mov.l	#256,r5
; @next:
; 		mov.l	#$0000,r7		;prio
; 
;  		mov.b	@r1+,r0			;R
;   		and	#$FF,r0
;   		shlr2	r0
;  		shlr 	r0
;  		add	r0,r7
;   		mov.b	@r1+,r0			;G
;   		and	#$FF,r0
;   		shlr2	r0
;   		shlr 	r0
;   		shll2	r0
;   		shll2	r0
;   		shll	r0
;   		add	r0,r7
;   		mov.b	@r1+,r0			;B
;   		and	#$FF,r0
;   		shlr2	r0
;   		shlr 	r0
;   		shll8	r0
;   		shll2	r0
;   		add	r0,r7
;  		
;  		mov.w	r7,@r4	
;  		dt	r5
;  		bf/s	@next
;  		add	#2,r4	
; 
;  		rts
;  		nop
;  		cnop 0,4
;  		lits
		
; ---------------------------------------------------
; Vdp_LoadArt
;
; Loads graphics
; 
; Input:
; r1 - Data
; r2 - Xpos
; r3 - Ypos
; r4 - Width
; r5 - Height
; r6 - Mode
;
; Uses:
; r7-r9
; ---------------------------------------------------

Vdp_LoadArt:
		mov.l	r6,r0
 		cmp/eq	#3,r0
		bt	@rle_art
 		cmp/eq	#2,r0
		bt	@hicolor_art

		mov.l	#_framebuffer+$200,r6
  		add	r2,r6			; X-pos
 
    		mov	#320,r0			; Y-pos
    		mulu	r3,r0
    		mov	macl,r0
    		add 	r0,r6
    		
    		mov.l	#224,r0
    		cmp/gt	r0,r5
    		bf	@loop_Y
    		mov.l	#224,r5
@loop_Y:
		mov.l	r6,r7			; Save framebuffer address
		mov.l	r1,r8			; Save art address
		mov.l	r4,r9			; Save width
@loop_X:
		mov.b	@r1+,r0
 		mov.b	r0,@r6
 		add 	#1,r6
		
 		dt	r4
 		bf	@loop_X

		mov.l	r9,r4			; Restore width
		mov.l	r8,r1			; Restore art address
		mov.l	r7,r6			; Restore framebuffer address
		add	r4,r1			; art + width = new addr
		add	r4,r6			; framebuffer + width = new addr

		dt	r5
		bf	@loop_Y
		rts
		nop
		cnop 0,4
		lits

; -------------------------
; mode 2
; -------------------------

@hicolor_art:
		mov.l	#_framebuffer+$200,r6
  		;Xadd here
  		;Yadd here

    		mov.l	#204,r0
    		cmp/gt	r0,r5
    		bf	@hloop_Y
    		mov.l	#204,r5
@hloop_Y:
		mov.l	r6,r7			; Save framebuffer address
		mov.l	r1,r8			; Save art address
		mov.l	r4,r9			; Save width
		
@hloop_X:
		mov.l	#$0000,r2		; priority

		mov.b	@r1+,r0			; R
		and	#$FF,r0
 		shlr2	r0
		shlr 	r0
		add	r0,r2

 		mov.b	@r1+,r0			; G
		and	#$FF,r0
 		shlr2	r0
 		shlr 	r0
 		shll2	r0
 		shll2	r0
 		shll	r0
 		add	r0,r2
 
 		mov.b	@r1+,r0			; B
		and	#$FF,r0
 		shlr2	r0
 		shlr 	r0
 		shll8	r0
 		shll2	r0
 		add	r0,r2
		
		mov.w	r2,@r6
		add.l	#2,r6
		
 		dt	r4
 		bf	@hloop_X
 		
		mov.l	r9,r4			; Restore width
		mov.l	r8,r1			; Restore art address
		mov.l	r7,r6			; Restore framebuffer address
		
		mov.l	#2,r0
		mulu	r0,r4
		mov	macl,r0
		add	r0,r6
		
		mov.l	#3,r0
		mulu	r0,r4
		mov	macl,r0
     		add 	r0,r1
		
 		dt	r5
 		bf	@hloop_Y
 		
		rts
		nop
		cnop 0,4
		lits
	
; -------------------------
; mode 3
; -------------------------

@rle_art:
		mov.l	#_framebuffer+$200,r6
  		add	r2,r6			;X-pos
 
    		mov	#320,r0			;Y-pos
    		mulu	r3,r0
    		mov	macl,r0
    		add 	r0,r6

@rleloop_Y:
		mov.l	r6,r7			; Save framebuffer address
		mov.l	r1,r8			; Save art address
		mov.l	r4,r9			; Save width

@rleloop_X:
		mov.b	@r1+,r0
		mov.b	r0,@r6
 		add 	#1,r6
		
 		dt	r4
 		bf	@rleloop_X

		mov.l	r9,r4			; Restore width
		mov.l	r8,r1			; Restore art address
		mov.l	r7,r6			; Restore framebuffer address
		add	r4,r1			; art + width = new addr
		add	r4,r6			; framebuffer + width = new addr

		dt	r5
		bf	@loop_Y
		rts
		nop
		cnop 0,4
		lits
		