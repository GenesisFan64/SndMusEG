; =================================================================
; Title
; =================================================================

; =================================================================
; ------------------------------------------------
; Includes
; ------------------------------------------------

; =================================================================
; ------------------------------------------------
; Variables
; ------------------------------------------------

; =================================================================
; ------------------------------------------------
; RAM (for RAM_ModeBuffer)
; ------------------------------------------------

		rsreset
TanValue	rs.w	1
SpeedVal	rs.w	1
StrchVal	rs.w	1
WaveVal		rs.w	1
Timer1		rs.w	1
TmpVal_Rot	rs.w	1
TmpVal_Zoom	rs.w	1
PickSong	rs.w	1
PickLevel	rs.w	1
StrchVer	rs.w	1
WavePitch	rs.w	1

StampX		rs.w	1
StampY		rs.w	1
StampXD		rs.w	1
StampYD		rs.w	1
ModelZ		rs.w	1

; =================================================================
; ------------------------------------------------
; Init
; ------------------------------------------------

mode_Title:
		bsr	Mode_FadeOut

		move.w	#$2700,sr
		
; -----------------------------------
; Cleanup
; -----------------------------------

		bsr	Vdp_ClearPlanes
		bsr	Mode_Cleanup
		
		move.l	#VInt_Default,(RAM_VIntAddr)
		move.l	#Hint_Default,(RAM_HIntAddr)
		lea	(RAM_VdpRegs),a0
    		move.b	#0,vdpReg_HVal(a0)
		move.b	#vdp_H40,vdpReg_HMode(a0)
		move.b	#1,vdpReg_PlnSize(a0)
		move.b	#3,vdpReg_Scroll(a0)
		clr.b	vdpReg_WindowY(a0)
; 		if SEGACD=0
; 		if MARS=0
;        		bset	#bit_vdpHint,(a0)
; 		endif
; 		endif
 		bsr	Vdp_Update

; -----------------------------------
; MD ONLY: show sample picture
; -----------------------------------

 		lea	(Map_Title),a0
 		moveq	#1,d0
 		move.l	#($0000<<16)|$0000,d1
  		move.l	#((((320)/8)-1)<<16)|(((224)/8)-1),d2
 		move.w	#1,d3
 		bsr	VDP_LoadMaps
		lea	(Art_Title),a0
		move.w	#1,d0
		move.w	(a0)+,d1
		bsr	VDP_SendData_L
  		lea	(RAM_PalFadeBuff),a1
		lea	(Pal_Title),a0
  		move.w	#$F,d0
  		bsr	LoadData_Word

; -----------------------------------
; Init features	
; -----------------------------------
  		
  		lea	(Art_TempFont),a0
   		move.w	#$580,d0
   		move.w	#((Art_TempFont_End-Art_TempFont)/4)-1,d1
   		bsr	VDP_SendData_L
   		
		lea	(RAM_ModeBuffer),a1
		move.w	#3,SpeedVal(a1)
		move.w	#4,StrchVal(a1)
		move.w	#6,WaveVal(a1)
		clr.w	PickLevel(a1)
		
 		move.w	#$0EE,(RAM_PalFadeBuff+$44)
 		move.w	#$E00,(RAM_PalFadeBuff+$64)
; 		bsr	ScrewBG
		
		move.l	#TestSong_4,d0
		move.w	#2-1,d1
		bsr	SMEG_LoadSong
		
 		bsr	LevelNames
 		
; -----------------------------------

		move.w	#$FF00,(RAM_ModeBuffer+StrchVer)
   		clr.b	(RAM_ModeBuffer+PickSong)
		move.w	#$2000,sr
 		bsr	Mode_FadeIn
		
; =================================================================
; ------------------------------------------------
; Loop
; ------------------------------------------------

Title_Loop:
		bsr	VSync
; 		bsr	ScrewBG
		
		lea	(RAM_ModeBuffer),a1
		
; ------------------------------------------
; MD Controls
; ------------------------------------------

; 		else
		
;    		btst	#bitJoyDown,(RAM_Joypads+OnPress)
;    		beq.s	@dontscrl_down2
; 		cmp.w	#$3C-12,WavePitch(a1)
; 		beq.s	@dontscrl_up2
; 		sub.w 	#1,WavePitch(a1)
; 		move.w	WavePitch(a1),d0
; 		bsr	Z80_SetSmplNote
;  		bsr	LevelNames
; @dontscrl_down2:
; 		btst	#bitJoyUp,(RAM_Joypads+OnPress)
; 		beq.s	@dontscrl_up2
; 		cmp.w	#$3C+10,WavePitch(a1)
; 		beq.s	@dontscrl_up2
; 		add.w 	#1,WavePitch(a1)
; 		move.w	WavePitch(a1),d0
; 		bsr	Z80_SetSmplNote
  		bsr	LevelNames
; @dontscrl_up2:

		btst	#bitJoyB,(RAM_Joypads+OnPress)
		beq.s	@NotVdpHor
		bchg	#0,(RAM_VdpRegs+vdpReg_HMode)
		bchg	#7,(RAM_VdpRegs+vdpReg_HMode)
		bsr	Vdp_Update
@NotVdpHor:

;  		moveq	#0,d0
;  		move.l	#($0000<<16)|$0000,d1
;   		move.l	#$560+"0",d2
;  		move.w	StrchVer(a1),d3
;  		bsr	Vdp_ShowVal_W
		
; ------------------------------------------

; 		endif
		
; 		btst	#bitJoyStart,(RAM_Joypads+OnPress)
; 		beq.s	@NotStart
; 		
; ; 		if MARS=0
; ; 		if SegaCD=0
; ; 		jmp	MD_AddrError
; ; 		endif
; ; 		endif
; 		
; 		bra	Title_LoadLevel
; @NotStart:
		bra	Title_Loop
                
; =================================================================
; ------------------------------------------------
; Hblank
; ------------------------------------------------
	
HInt_Title:
		movem.l	d0-d1,-(sp)
		
		move.l	#$40000010,($C00004).l
		move.w	#0,($C00000).l
		move.l	(RAM_VerBuffer),d0
		swap	d0
		ext.w	d0
  		move.w	(RAM_ModeBuffer+StrchVer),d1
   		lsr.w	#1,d1
 		sub.w	d1,d0
		move.w	d0,($C00000).l
		
 		moveq	#0,d1
  		move.w	(RAM_ModeBuffer+StrchVer),d1
  		lsl.l	#8,d1
 		add.l	d1,(RAM_VerBuffer)
		
		movem.l	(sp)+,d0-d1
@holdon:
		rts
		
; =================================================================
; ------------------------------------------------
; VBlank
; ------------------------------------------------

Vint_Title:
		move.l	#$40000010,($C00004).l
		move.l	#0,($C00000).l
		move.l	(RAM_VerBuffer),d0
		swap	d0
		ext.w	d0
  		move.w	(RAM_ModeBuffer+StrchVer),d1
   		lsr.w	#1,d1
 		sub.w	d1,d0
		move.w	d0,($C00000).l
		clr.l	(RAM_VerBuffer)

		bsr	SMEG_Upd
		bsr	PalFade
		move.w	#$100,($A11100).l
@WaitZ80:
		btst	#0,($A11100).l
		bne.s	@WaitZ80
		bsr	Pads_Read
 		bsr	DMA_Read
 		move.w	#0,($A11100).l

 		bra	Dma_Visual
		rts
		
; =================================================================
; ------------------------------------------------
; Subs
; ------------------------------------------------

; ---------------------------
; Screw the bg
; ---------------------------

ScrewBG:
		if SegaCD=0
		moveq	#0,d0
		move.w	TanValue(a1),d0
		bsr	CalcSine
		move.w	WaveVal(a1),d1
  		asr.w	d1,d0
 		
		lea	(RAM_HorBuffer),a0
		move.w	#(224)-1,d6
		
		move.w	TanValue(a1),d3
		move.w	d3,d4
		add.w	#$80,d4
		moveq	#0,d5
		
@next_line:
; 		move.w	d0,d2
; 		
; 		move.w	d5,(a0)
; 		move.w	d4,d0
; 		bsr	CalcSine
; 		move.w	d0,d5
;  		asr.w	#5,d5
;  		
;  		move.w	d2,d0
 		
		move.w	d0,2(a0)
		move.w	d3,d0
		bsr	CalcSine
		move.w	WaveVal(a1),d1
 		asr.w	d1,d0

		add.w	StrchVal(a1),d3
		add.w	#1,d4
		
		adda	#4,a0
		dbf	d6,@next_line
		
		move.w	SpeedVal(a1),d0
		add.w	d0,TanValue(a1)
		
; 		lea	(RAM_VerBuffer),a0
; 		moveq	#0,d1
; 		move.w	Timer1(a1),d1
; ; 		swap	d1
; 		clr.l	(a0)+
; 		move.w	d1,d0
; 		lsr.w	#2,d0
; 		move.l	d0,(a0)+
;  		move.l	d0,(a0)+		
;  		move.l	d0,(a0)+
;  		
; 		move.w	d1,d0
; 		lsr.w	#3,d0	
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		
; 		move.w	d1,d0
; 		lsr.w	#2,d0	
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		
; 		move.w	d1,d0
; 		lsr.w	#4,d0	
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  	
; 		move.w	d1,d0
; 		lsr.w	#3,d0	
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  	
; 		move.w	d1,d0
; 		lsr.w	#2,d0	
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
;  		move.l	d0,(a0)+
 		
		add.w	#1,Timer1(a1)
		endif
		rts

; ---------------------------
; Show the level names
; ---------------------------

LevelNames:
		lea	(RAM_SMEG_Chnls_BGM),a4
		move.w	#$C000+($80*2)+($02*9),d4
 		moveq	#6-1,d3
		bsr	@channels

		move.w	#$C000+($80*12)+($02*9),d4
 		moveq	#4-1,d3
		bsr	@channels

		move.w	#$C000+($80*21)+($02*9),d4
 		moveq	#4-1,d3
		bsr	@channels
		move.w	#$C000+($80*21)+($02*23),d4
 		moveq	#4-1,d3
		bsr	@channels
		
		rts
		
@channels:

@next_y:
		move.w	d4,d0
		bsr	VDP_VramToCmd
		move.l	d0,($C00004).l
		lea	LevelNamesAsc(pc),a2
		
		moveq	#0,d5
  		move.b	chn_note(a4),d5
  		tst.b	d5
  		bmi.s	@next_x
  		and.w	#$7F,d5
  		lsl.w	#2,d5
		lea	LevelNamesAsc+4(pc),a2
   		adda	d5,a2
@next_x:
 		move.w	#$4000,d0
 		cmp.b	#FM_6,chn_id(a4)
 		beq.s	@same
 		cmp.b	#NOISE,chn_id(a4)
 		beq.s	@same
 		move.w	#$6000,d0
@same:
		moveq	#0,d2
		move.b	(a2)+,d2
		beq.s	@jump
		add.w	#$560,d2
		add.w	d0,d2
		move.w	d2,($C00000).l
		bra.s	@next_x
@jump:
		move.b	Chn_Inst(a4),d2
		bsr	@MiniVal
		move.b	Chn_Vol(a4),d2
		bsr	@MiniVal
		move.b	Chn_Panning(a4),d2
		bsr	@MiniVal		
		
		add.w	#1,d5
		add.w	#($80*1),d4
		adda	#sizeof_chn,a4
 		dbf	d3,@next_y
		rts

@MiniVal:
		and.w	#$FF,d2
		move.w	#0,($C00000).l
		move.w	d2,d1
		lsr.w	#4,d1
		and.w	#$F,d1
		cmp.w	#$A,d1
		blt.s	@lowAl
		add.w	#7,d1
@lowAl:
		add.w	#$560+"0",d1
		add.w	d0,d1
		move.w	d1,($C00000).l

		move.w	d2,d1
		and.w	#$F,d1
		cmp.w	#$A,d1
		blt.s	@lowAr
		add.w	#7,d1
@lowAr:
		add.w	#$560+"0",d1
		add.w	d0,d1
		move.w	d1,($C00000).l
		rts
		
; ---------------------------
; Load level
; ---------------------------

Title_LoadLevel:
		move.w	PickLevel(a1),(RAM_SharedBuffer)
		
 		if MARS
		bsr	Mars_Wait_Master
      		move.w	#0,(marsreg+comm4)
   		moveq	#$10,d0
  		bsr	Mars_Task_Master
  		bsr	Mars_Wait_Master
		elseif SegaCD
		moveq	#$14,d0
		bsr	SubCpu_Task_Wait
		endif
		
		bsr	Mode_FadeOut
 		move.b	#1,(RAM_GameMode)
		rts
	
; ---------------------------
; SEGA CD: transfer stamp
; data
; ---------------------------

ShowStamps:
		if SegaCD
		lea	(ThisCpu+CommDataM),a0
		move.w	#0,(a0)+
		move.w	StampX(a1),d0
		move.w	d0,(a0)+
		move.w	StampY(a1),d0
		move.w	d0,(a0)+
		move.w	StampXD(a1),d0
		move.w	d0,(a0)+
		move.w	StampYD(a1),d0
		move.w	d0,(a0)+
		moveq	#$31,d0
		bsr	SubCpu_Task_Wait
		
		moveq	#$38,d0
		bsr	SubCpu_Task_Wait

		move.w	#$100,($A11100).l
@WaitZ80:
		btst	#0,($A11100).l
		bne.s	@WaitZ80
		
 		move.l	#$40200000,d0
 		move.l	#$200000+$38E00,d1
 		move.w	#((256*224)>>2),d2
 		bsr	DMA_QuickSet
 		
		move.w	#0,($A11100).l
		endif
		rts
	
; -------------------

Stamps_AutoMap:
		moveq	#$1F,d2
@NextLine:
		move.l	d0,d4
		move.w	d1,d5
		move.w	#((256*224)>>$B)-1,d3
@Next:
		move.l	d4,($C00004).l
		move.w	d5,($C00000).l
		add.l	#$800000,d4
		add.w	#$0001,d5
		dbf	d3,@Next
		
		add.w	#((256*224)>>$B),d1
		add.l	#$20000,d0
		dbf	d2,@NextLine
		rts
		
; ------------------------------------------------
; Render MARS Stuff
; ------------------------------------------------

MARS_ModelRender:

; -----------------------------------

		if MARS
		
 		bsr	Mars_Wait_Master_Flag
 		bne.s	Mars_RenderReturn
 		
MARS_ModelInit:
  		move.w	#0,(marsreg+comm4)
  		move.w	StampXD(a1),(marsreg+comm6)
  		move.w	StampYD(a1),(marsreg+comm8)
  		move.w	#0,(marsreg+comm10)
  		moveq	#$23,d0
  		bsr	Mars_Task_Master
  		bsr	Mars_Wait_Master
 		
      		move.w	#0,(marsreg+comm4)
      		move.w	StampX(a1),(marsreg+comm6)		;d1	X
      		move.w	StampY(a1),(marsreg+comm8)		;	Y
        	move.w	ModelZ(a1),(marsreg+comm10) 		;d0	Z
      		moveq	#$22,d0
      		bsr	Mars_Task_Master
      		bsr	Mars_Wait_Master			
 		
Mars_RenderReturn:

; -----------------------------------
      		
 		endif
		rts
		
; =================================================================
; ------------------------------------------------
; Data
; ------------------------------------------------
		
LevelNamesAsc:
		dc.b "===",0
		
		dc.b "===",0
		dc.b "C#0",0
		dc.b "D-0",0
		dc.b "D#0",0
		dc.b "E-0",0
		dc.b "F-0",0
		dc.b "F#0",0
		dc.b "G-0",0
		dc.b "G#0",0
		dc.b "A-0",0
		dc.b "A#0",0		
		dc.b "B-0",0
		
		dc.b "C-1",0
		dc.b "C#1",0
		dc.b "D-1",0
		dc.b "D#1",0
		dc.b "E-1",0
		dc.b "F-1",0
		dc.b "F#1",0
		dc.b "G-1",0
		dc.b "G#1",0
		dc.b "A-1",0
		dc.b "A#1",0		
		dc.b "B-1",0
		
		dc.b "C-2",0
		dc.b "C#2",0
		dc.b "D-2",0
		dc.b "D#2",0
		dc.b "E-2",0
		dc.b "F-2",0
		dc.b "F#2",0
		dc.b "G-2",0
		dc.b "G#2",0
		dc.b "A-2",0
		dc.b "A#2",0		
		dc.b "B-2",0
		
		dc.b "C-3",0
		dc.b "C#3",0
		dc.b "D-3",0
		dc.b "D#3",0
		dc.b "E-3",0
		dc.b "F-3",0
		dc.b "F#3",0
		dc.b "G-3",0
		dc.b "G#3",0
		dc.b "A-3",0
		dc.b "A#3",0		
		dc.b "B-3",0
		
		dc.b "C-4",0
		dc.b "C#4",0
		dc.b "D-4",0
		dc.b "D#4",0
		dc.b "E-4",0
		dc.b "F-4",0
		dc.b "F#4",0
		dc.b "G-4",0
		dc.b "G#4",0
		dc.b "A-4",0
		dc.b "A#4",0		
		dc.b "B-4",0
		
		dc.b "C-5",0
		dc.b "C#5",0
		dc.b "D-5",0
		dc.b "D#5",0
		dc.b "E-5",0
		dc.b "F-5",0
		dc.b "F#5",0
		dc.b "G-5",0
		dc.b "G#5",0
		dc.b "A-5",0
		dc.b "A#5",0		
		dc.b "B-5",0

		dc.b "C-6",0
		dc.b "C#6",0
		dc.b "D-6",0
		dc.b "D#6",0
		dc.b "E-6",0
		dc.b "F-6",0
		dc.b "F#6",0
		dc.b "G-6",0
		dc.b "G#6",0
		dc.b "A-6",0
		dc.b "A#6",0		
		dc.b "B-6",0

		dc.b "C-7",0
		dc.b "C#7",0
		dc.b "D-7",0
		dc.b "D#7",0
		dc.b "E-7",0
		dc.b "F-7",0
		dc.b "F#7",0
		dc.b "G-7",0
		dc.b "G#7",0
		dc.b "A-7",0
		dc.b "A#7",0		
		dc.b "B-7",0

		dc.b "C-8",0
		dc.b "C#8",0
		dc.b "D-8",0
		dc.b "D#8",0
		dc.b "E-8",0
		dc.b "F-8",0
		dc.b "F#8",0
		dc.b "G-8",0
		dc.b "G#8",0
		dc.b "A-8",0
		dc.b "A#8",0		
		dc.b "B-8",0
		
		even
		
