; ====================================================================
; ---------------------------------------------
; Variables
; ---------------------------------------------

RAM_MarsPalette equ	$FFFF7800
RAM_MarsPalFade equ	$FFFF7A00

; ---------------------------------------------
; Variables
; ---------------------------------------------

MARSVDP_SwapFB	equ	$F
MARS3D_Run	equ	$10
MARS3D_New	equ	$20
MARS3D_SetXYZ	equ	$22
MARS3D_RotXYZ	equ	$23

; ---------------------------------------------
; Communications
; ---------------------------------------------

Mars_Task_Master:
		move.b	d0,(marsreg+comm0)
  		bset 	#0,(marsreg+intctl)
		rts

Mars_Wait_Master:
 		tst.b	(marsreg+comm0)
 		bne.s	Mars_Wait_Master		
;   		btst 	#0,(marsreg+intctl)
;  		bne.s	Mars_Wait_Master
 		rts

Mars_Wait_Master_Flag:
 		moveq	#-1,d0
   		tst.b	(marsreg+comm0)
 		bne.s	@Working 		
;   		btst 	#0,(marsreg+intctl)
;  		bne.s	@Working
		moveq	#0,d0
@Working:
		tst.w	d0
 		rts
 		
; ---------------------------------------------

Mars_Task_Slave:
		and.w	#%00001111,d0
		or.b	d0,(marsreg+comm0+1)
 		bset 	#1,(marsreg+intctl)
		rts

Mars_Wait_Slave:
		movem.l	d1,-(sp)
@Wait:
		move.b	(marsreg+comm0+1),d1
		and.w	#$F,d1
   		tst.b	d1
;  		btst	#1,(marsreg+intctl)
 		bne.s	@Wait
 		movem.l	(sp)+,d1
 		rts

Mars_Wait_Slave_Flag:
		movem.l	d1,-(sp)
		moveq	#-1,d0
		move.b	(marsreg+comm0+1),d1
		and.w	#$F,d1
   		tst.b	d1
; 		btst	#1,(marsreg+intctl)
 		bne.s	@Working
		moveq	#0,d0
@Working:
 		movem.l	(sp)+,d1
 		rts
 		
; ====================================================================	
; ---------------------------------------------------
; MarsVdp_LoadPic
;
; Loads graphics
; 
; Input:
; a0 - Data
; d1 - Xpos
; d2 - Ypos
; d3 - Width
; d4 - Height
; d5 - Mode
; ---------------------------------------------------

MarsVdp_LoadPic:
		movea.l	d0,a0
; 		mov	r6,r0
;  		cmp/eq	#3,r0
; 		bt	@rle_art
;  		cmp/eq	#2,r0
; 		bt	@hicolor_art
; 
		lea	(framebuffer+$200),a1
		adda	d1,a1
		tst.w	d2
		beq.s	@zero_y
		sub.w	#1,d2
@next_y:
		adda 	#320,a1
		dbf	d2,@next_y
@zero_y:
		move.w	d3,d5
		
		cmp.w	#224,d4
		ble.s	@loop_y
		move.w	#224,d4
@loop_y:
		movea.l	a0,a2
		movea.l	a1,a3
@loop_x:
		move.b	(a0)+,(a1)+
		dbf	d3,@loop_x
		movea.l	a2,a0
		movea.l	a3,a1
		adda 	d5,a0
		adda 	d5,a1
		move.w	d5,d3
		dbf	d4,@loop_y
		rts

; ; -------------------------
; ; mode 2
; ; -------------------------
; 
; @hicolor_art:
; 		mov.l	#_framebuffer+$200,r6
;   		;Xadd here
;   		;Yadd here
; 
;     		mov.l	#204,r0
;     		cmp/gt	r0,r5
;     		bf	@hloop_Y
;     		mov.l	#204,r5
; @hloop_Y:
; 		mov.l	r6,r7			; Save framebuffer address
; 		mov.l	r1,r8			; Save art address
; 		mov.l	r4,r9			; Save width
; 		
; @hloop_X:
; 		mov.l	#$0000,r2		; priority
; 
; 		mov.b	@r1+,r0			; R
; 		and	#$FF,r0
;  		shlr2	r0
; 		shlr 	r0
; 		add	r0,r2
; 
;  		mov.b	@r1+,r0			; G
; 		and	#$FF,r0
;  		shlr2	r0
;  		shlr 	r0
;  		shll2	r0
;  		shll2	r0
;  		shll	r0
;  		add	r0,r2
;  
;  		mov.b	@r1+,r0			; B
; 		and	#$FF,r0
;  		shlr2	r0
;  		shlr 	r0
;  		shll8	r0
;  		shll2	r0
;  		add	r0,r2
; 		
; 		mov.w	r2,@r6
; 		add.l	#2,r6
; 		
;  		dt	r4
;  		bf	@hloop_X
;  		
; 		mov.l	r9,r4			; Restore width
; 		mov.l	r8,r1			; Restore art address
; 		mov.l	r7,r6			; Restore framebuffer address
; 		
; 		mov.l	#2,r0
; 		mulu	r0,r4
; 		mov	macl,r0
; 		add	r0,r6
; 		
; 		mov.l	#3,r0
; 		mulu	r0,r4
; 		mov	macl,r0
;      		add 	r0,r1
; 		
;  		dt	r5
;  		bf	@hloop_Y
;  		
; 		rts
; 		nop
; 		cnop 0,4
; 		lits
; 	
; ; -------------------------
; ; mode 3
; ; -------------------------
; 
; @rle_art:
; 		mov.l	#_framebuffer+$200,r6
;   		add	r2,r6			;X-pos
;  
;     		mov	#320,r0			;Y-pos
;     		mulu	r3,r0
;     		mov	macl,r0
;     		add 	r0,r6
; 
; @rleloop_Y:
; 		mov.l	r6,r7			; Save framebuffer address
; 		mov.l	r1,r8			; Save art address
; 		mov.l	r4,r9			; Save width
; 
; @rleloop_X:
; 		mov.b	@r1+,r0
; 		mov.b	r0,@r6
;  		add 	#1,r6
; 		
;  		dt	r4
;  		bf	@rleloop_X
; 
; 		mov.l	r9,r4			; Restore width
; 		mov.l	r8,r1			; Restore art address
; 		mov.l	r7,r6			; Restore framebuffer address
; 		add	r4,r1			; art + width = new addr
; 		add	r4,r6			; framebuffer + width = new addr
; 
; 		dt	r5
; 		bf	@loop_Y
; 		rts
; 		nop
; 		cnop 0,4
; 		lits
		
		
; 		mov.l	#_framebuffer,r8
; 		mov.l	#$100,r6
; 		mov.l	#(320/2),r5
; 		mov.l	#224,r7
; @mapset1:
; 		mov.w	r6,@r8
; 		add	#2,r8
; 		add	r5,r6
; 		dt	r7
; 		bf	@mapset1


		
; 		mov	#_vdpreg,r1
; 		mov	#curr_frame,r2
; 		mov.b	@(framectl,r1),r0
; 		xor	#1,r0
; 		mov.b	r0,@(framectl,r1)
; 		mov.b	r0,@r2
; 		mov	#_vdpreg,r1
; 		mov	#curr_frame,r2
; 		mov.b	@r2,r0
; 		mov	r0,r2
; @wait1:
; 		mov.b	@(framectl,r1),r0
; 		cmp/eq	r0,r2
; 		bf	@wait1
		
; 		rts
	
; ---------------------------------------------------
; MarsVdp_LoadPal_Raw | MarsVdp_LoadPalFade_Raw
;
; Loads RAW palette, modes 1 and 3 only.
; 
; Input:
; a0 - input
; a1 - output result
; ---------------------------------------------------

MarsVdp_LoadPal_Raw_Fade:
		and.l	#$7FFFF,d0
		movea.l	d0,a0
		lea	(RAM_MarsPalFade),a1
		bra.s	LoadPal_RawCont
		
MarsVdp_LoadPal_Raw:
		and.l	#$7FFFF,d0
		movea.l	d0,a0
		lea	(RAM_MarsPalette),a1
		
LoadPal_RawCont:
		move.w	#256-1,d2
@Next:
		move.w	#$0000,d1		;prio

		moveq	#0,d0
 		move.b	(a0)+,d0		;R
   		and.w	#$FF,d0
   		lsr.w	#3,d0
   		and.w	#%0000000000011111,d0
  		or.w	d0,d1
 		move.b	(a0)+,d0		;G
    		and.w	#$FF,d0
    		lsr.w	#3,d0
    		lsl.w	#5,d0
   		and.w	#%0000001111100000,d0
  		or.w	d0,d1
  		move.b	(a0)+,d0		;B
    		and.w	#$FF,d0
    		lsr.w	#3,d0
    		lsl.w	#8,d0
    		lsl.w	#2,d0
   		and.w	#%0111110000000000,d0
  		add.w	d0,d1
 		
 		move.w	d1,(a1)+
 		dbf	d2,@Next
 		rts
 		
; ---------------------------------------------
; Tasks
; 
; 68k side
; ---------------------------------------------

Mars_InitVdpFrame:
; 		move.b	d0,(marsreg+bitmapmode)

		lea	(framebuffer),a0
		move.w	#$100,d0
		move.w	#(320/2),d1
		move.w	#224-1,d2
@mapset1:
		move.w	d0,(a0)+
		add.w	d1,d0
		dbf	d2,@mapset1
		bchg	#0,(marsreg+framectl)
		
		lea	(framebuffer),a0
		move.w	#$100,d0
		move.w	#(320/2),d1
		move.w	#224-1,d2
@mapset2:
		move.w	d0,(a0)+
		add.w	d1,d0
		dbf	d2,@mapset2
		bchg	#0,(marsreg+framectl)
		rts
		
; ---------------------------------------------
; Tasks
; 
; Requesting from MD to SH2
; 
; Uses:
; d7
; ---------------------------------------------

Mars_DoTask_Master:
		moveq	#0,d7
		move.w	d0,d7
		tst.w	d7
		beq.s	@No_Args
		add.w	d7,d7
		swap	d0
		move.w	@Tasks(pc,d7.w),d0
		jsr	@Tasks(pc,d0.w)
		swap	d0
@No_Args:
		and.w	#$FF,d0
		bsr 	Mars_Task_Master
 		bra 	Mars_Wait_Master
 		
; ---------------------------------------------

@Tasks:
		dc.w 0
		dc.w @cmd_1-@Tasks
		dc.w @cmd_2_3-@Tasks
		dc.w @cmd_2_3-@Tasks
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w @cmd_E-@Tasks
		dc.w 0				;NO ARGS for $F
		
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		
		dc.w @cmd_20-@Tasks
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		even
		
; ---------------------------------------------------
; Command 01
; 
; Loads a bitmap to the framebuffer
; (must swap framebuffer to show it)
; 
; Input:
; d1 | LONG - Bitmap data (MARS SIDE Only)
; d2 | LONG - Xstart|Ystart
; d3 | LONG - Xsize|Ysize
; ---------------------------------------------------

@cmd_1:
		move.l	d1,(marsreg+comm4)
		move.w	d2,(marsreg+comm10)
		swap	d2
		move.w	d2,(marsreg+comm8)
		move.w	d3,(marsreg+comm14)
		swap	d3
		move.w	d3,(marsreg+comm12)
		rts
 		
; ------------------------------------------------
; Command 02/03
;
; Load palette for fade
; 
; d1 | LONG - Address
; d2 | LONG - StartFrom|NumOfColors
; ------------------------------------------------

@cmd_2_3:
		move.l	d1,(marsreg+comm4)
		move.w	d2,(marsreg+comm10)
		swap	d2
		move.w	d2,(marsreg+comm8)
		rts
	
; ---------------------------------------------------
; Command 0E
; 
; Sets the MARS Video mode
; 
; Input:
; d1 | WORD - Mode ID
; ---------------------------------------------------

@cmd_E:
		and.w	#%11,d1
    		move.w	d1,(marsreg+comm4)
    		rts
    
; ---------------------------------------------------
; Command 20
; 
; Set a 3D model
; 
; Input:
; d1 | LONG - Model data (MARS SIDE Only)
; d2 | WORD - Slot
; ---------------------------------------------------

@cmd_20:
		move.l	d1,(marsreg+comm4)
		move.w	d2,(marsreg+comm8)
		rts
 		
; ---------------------------------------------------
; MARS3D_Run
; ---------------------------------------------------

MarsSh2_3D_Run:
      		bsr	Mars_Wait_Master
      		moveq	#$10,d0
      		bsr	Mars_Task_Master
      		bra	Mars_Wait_Master

; ---------------------------------------------------
; MARS3D_RunDrop
; ---------------------------------------------------

MarsSh2_3D_RunDrop:
      		bsr	Mars_Wait_Master_Flag
      		bne.s	@Wait
      		moveq	#$10,d0
      		bsr	Mars_Task_Master
@Wait:
		rts
		
