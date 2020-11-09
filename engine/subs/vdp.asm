; ====================================================================
; ---------------------------------------------
; VDP
; ---------------------------------------------

bit_vdpHint	equ	4

vdp_H40		equ	$81
vdp_H32		equ	$00
vdp_Double	equ	%00000110

vdpReg_PattFG	equ	2			;00???000 = ???00000 00000000
vdpReg_PattWD	equ	3			;
vdpReg_PattBG	equ	4			;00000??? = ???00000 00000000
vdpReg_HVal	equ	$A
vdpReg_Scroll	equ	$B
vdpReg_HMode	equ	$C
vdpReg_PlnSize	equ	$10
vdpReg_WindowX	equ	$11
vdpReg_WindowY	equ	$12

; --------------------------------------------
; Clear planes
; --------------------------------------------

VDP_ClearPlanes:
		bsr.s	VDP_ClrPlane_FG

VDP_ClrPlane_BG:
		moveq	#0,d0
		move.b	(RAM_VdpRegs+vdpReg_PattFG),d0
		lsl.w	#8,d0
		lsl.w	#2,d0
		bsr	VDP_VramToCmd
		move.l	d0,($C00004).l
		move.w	#$7FF,d0
@ClrBG:
		clr.l	($C00000).l
		dbf	d0,@ClrBG
		rts

VDP_ClrPlane_FG:
		moveq	#0,d0
		move.b	(RAM_VdpRegs+vdpReg_PattBG),d0
		lsl.w	#8,d0
		lsl.w	#5,d0
		bsr	VDP_VramToCmd
		move.l	d0,($C00004).l
		move.w	#$7FF,d0
@ClrFG:
		clr.l	($C00000).l
		dbf	d0,@ClrFG
		rts

; --------------------------------------------
; VDP_ClearScroll
;
; Set both scrollings to $0000
; --------------------------------------------

VDP_ClearScroll:
		lea	(RAM_HorBuffer),a0
		move.w	#(240)-1,d0
@ClrScrl:
		clr.l	(a0)+
		dbf	d0,@ClrScrl
		
		lea	(RAM_VerBuffer),a0
		move.w	#(320/16)-1,d0
@ClrVScrl:
		clr.l	(a0)+
		dbf	d0,@ClrVScrl
		rts

; --------------------------------------------
; VDP_SendData_W, VDP_SendData_L
;
; Input:
; a0 - Data address
;
; d0 | VRAM Address
; d1 | Data size
; --------------------------------------------

VDP_SendData_W:
		lsl.w	#5,d0
		bsr	VDP_VramToCmd
		move.l	d0,($C00004)
@Loop:
		move.w	(a0)+,($C00000).l
		dbf	d1,@Loop
		rts

VDP_SendData_L:
		lsl.w	#5,d0
		bsr	VDP_VramToCmd
		move.l	d0,($C00004)
@Loop:
		move.l	(a0)+,($C00000).l
		dbf	d1,@Loop
		rts

; --------------------------------------------
; VDP_VramToCmd
;
; Input:
; d0 | WORD - VRAM to convert
;
; Output:
; d0 | LONG - VDP Command (Write mode)
; --------------------------------------------

VDP_VramToCmd:
		cmp.w	#$4000,d0
		bcs.s	@NoBank
		swap	d0
		move.w	#1,d0
		swap	d0
		cmp.w	#$8000,d0
		bcs.s	@NoBank	
		swap	d0
		move.w	#2,d0
		swap	d0
		cmp.w	#$C000,d0
		bcs.s	@NoBank	
		swap	d0
		move.w	#3,d0
		swap	d0
@NoBank:
  		and.w	#$3FFF,d0
  		or.w	#$4000,d0
   		swap	d0
		rts
		
; --------------------------------------------
; VDP_ShowVal (variants)
; 
; Input:
; d0 | WORD - Plane type: 0-FG 1-BG 2-Window
; d1 | LONG - XPos (WORD) | YPos (WORD)
; d2 | WORD - VRAM
; d3 | LONG - Value
; 
; Uses:
; d4-d5
; --------------------------------------------

; HEX 

VDP_ShowVal_Nibl:
		bsr	vdpshv_findvdppos
		lsl.w	#8,d3
		lsl.w	#4,d3
		swap	d3
		moveq	#(1)-1,d4
		bra	vdpshv_showval
VDP_ShowVal_B:
		bsr	vdpshv_findvdppos
		lsl.w	#8,d3
		swap	d3
		moveq	#(1*2)-1,d4
		bra	vdpshv_showval
VDP_ShowVal_W:
		bsr	vdpshv_findvdppos
		swap	d3
		moveq	#(2*2)-1,d4
		bra	vdpshv_showval
VDP_ShowVal_L:
		bsr	vdpshv_findvdppos
		moveq	#(4*2)-1,d4
		bra	vdpshv_showval
	
; DEC
; WARNING: semi-slow

VDP_ShowValDec_Nibl:
		bsr	vdpshv_findvdppos
; 		bsr	vdpshv_hextobcd
		lsl.w	#8,d3
		lsl.w	#4,d3
		swap	d3
		moveq	#(1)-1,d4
		bra	vdpshv_showval
		
VDP_ShowValDec_B:
		bsr	vdpshv_findvdppos
; 		bsr	vdpshv_hextobcd
		lsl.w	#8,d3
		swap	d3
		moveq	#(1*2)-1,d4
		bra	vdpshv_showval
VDP_ShowValDec_W:
		bsr	vdpshv_findvdppos
; 		bsr	vdpshv_hextobcd
		swap	d3
		moveq	#(2*2)-1,d4
		bra	vdpshv_showval
VDP_ShowValDec_L:
		bsr	vdpshv_findvdppos
; 		bsr	vdpshv_hextobcd
		moveq	#(4*2)-1,d4
		bra	vdpshv_showval
		
; -----------------------
; Uses: d4-d5
; -----------------------

vdpshv_findvdppos:
		;Check plane to use
		move.w	d0,d5
		moveq	#0,d0
		move.b	(RAM_VdpRegs+vdpReg_PattFG),d0
		btst	#1,d5				;%10? (WD)
		beq.s	@FG
		move.b	(RAM_VdpRegs+vdpReg_PattWD),d0
@FG:
		lsl.w	#8,d0
		lsl.w	#2,d0
		btst	#0,d5				;%01? (BG)
		beq.s	@FGWD
		moveq	#0,d0
		move.b	(RAM_VdpRegs+vdpReg_PattBG),d0
		lsl.w	#8,d0
		lsl.w	#5,d0
@FGWD:

		;Start Y
		moveq	#0,d4
   		move.w	d1,d4
  		lsl.l	#6,d4
 		btst	#1,d5
 		beq.s	@def_fgbg
 		
 		;TODO: WD resolution check
;    		move.b	(RAM_VdpRegs+vdpReg_HMode),d5
;    		and.w	#%10000001,d5
;    		bne.s	@Not128
    		lsl.l	#1,d4
		bra.s	@Not128
@def_fgbg:
 		btst	#0,(RAM_VdpRegs+vdpReg_PlnSize)
 		beq.s	@Not40
  		lsl.l	#1,d4
@Not40:
 		btst	#1,(RAM_VdpRegs+vdpReg_PlnSize)
 		beq.s	@Not128
    		lsl.l	#1,d4
@Not128:
 		add.w	d4,d0			;+Y Start
		swap	d1
		lsl.w	#1,d1
		add.w	d1,d0			;+X Start
		bra	VDP_VramToCmd
	
; -----------------------

vdpshv_showval:
		moveq	#0,d1
		move.l	d0,($C00004)
@next:
		rol.l	#4,d3
		move.b	d3,d1
		and.w	#$F,d1
		cmp.w	#$A,d1
		bcs	@lessF
		add.w	#7,d1
@lessF
		add.w	d2,d1
		move.w	d1,($C00000)
		dbf	d4,@next
		rts
	
; ; -----------------------
; ; Input:
; ; d3 - HEX
; ; 
; ; Output:
; ; d3 - BCD
; ; 
; ; Uses:
; ; d4-d5
; ; -----------------------
; 
; vdpshv_hextobcd:
; 		move.l	d3,d5
; 		moveq	#0,d3
; 		move.l	d5,d4
; 	
; 		move.w	d4,d1
; 		lsr.w	#8,d1
; 		and.w	#$FF,d1
; 		tst.w	d1
; 		beq	@part2
; 		sub.w	#1,d1
; 		add.w	d1,d1
; 		add.w	d1,d1
; 		move.l	@hideclist(pc,d1.w),d3
; 		bra	@part2
; 	
; ; -----------------------
; ; $X00+ array
; ; -----------------------
; 
; @hideclist:
; 		dc.l $256, $512, $768, $1024, $1280, $1536, $1792, $2048
; 		dc.l $2304, $2560, $2816, $3072, $3328, $3584, $3840, $4096
; 		dc.l $4352, $4608, $4864, $5120, $5376, $5632, $5888, $6144
; 		dc.l $6400, $6656, $6912, $7168, $7424, $7680, $7936, $8192
; 		dc.l $8448, $8704, $8960, $9216, $9472, $9728, $9984, $10240
; 		dc.l $10496, $10752, $11008, $11264, $11520, $11776, $12032, $12288
; 		dc.l $12544, $12800, $13056, $13312, $13568, $13824, $14080, $14336
; 		dc.l $14592, $14848, $15104, $15360, $15616, $15872, $16128, $16384
; 		dc.l $16640, $16896, $17152, $17408, $17664, $17920, $18176, $18432
; 		dc.l $18688, $18944, $19200, $19456, $19712, $19968, $20224, $20480
; 		dc.l $20736, $20992, $21248, $21504, $21760, $22016, $22272, $22528
; 		dc.l $22784, $23040, $23296, $23552, $23808, $24064, $24320, $24576
; 		dc.l $24832, $25088, $25344, $25600, $25856, $26112, $26368, $26624
; 		dc.l $26880, $27136, $27392, $27648, $27904, $28160, $28416, $28672
; 		dc.l $28928, $29184, $29440, $29696, $29952, $30208, $30464, $30720
; 		dc.l $30976, $31232, $31488, $31744, $32000, $32256, $32512, $32768
; 		dc.l $33024, $33280, $33536, $33792, $34048, $34304, $34560, $34816
; 		dc.l $35072, $35328, $35584, $35840, $36096, $36352, $36608, $36864
; 		dc.l $37120, $37376, $37632, $37888, $38144, $38400, $38656, $38912
; 		dc.l $39168, $39424, $39680, $39936, $40192, $40448, $40704, $40960
; 		dc.l $41216, $41472, $41728, $41984, $42240, $42496, $42752, $43008
; 		dc.l $43264, $43520, $43776, $44032, $44288, $44544, $44800, $45056
; 		dc.l $45312, $45568, $45824, $46080, $46336, $46592, $46848, $47104
; 		dc.l $47360, $47616, $47872, $48128, $48384, $48640, $48896, $49152
; 		dc.l $49408, $49664, $49920, $50176, $50432, $50688, $50944, $51200
; 		dc.l $51456, $51712, $51968, $52224, $52480, $52736, $52992, $53248
; 		dc.l $53504, $53760, $54016, $54272, $54528, $54784, $55040, $55296
; 		dc.l $55552, $55808, $56064, $56320, $56576, $56832, $57088, $57344
; 		dc.l $57600, $57856, $58112, $58368, $58624, $58880, $59136, $59392
; 		dc.l $59648, $59904, $60160, $60416, $60672, $60928, $61184, $61440
; 		dc.l $61696, $61952, $62208, $62464, $62720, $62976, $63232, $63488
; 		dc.l $63744, $64000, $64256, $64512, $64768, $65024, $65280, $65536
; 		
; @part2:
; 		and.l	#$FF,d4
; 		tst.w	d4
; 		beq.s	@final
; @lownibloop:
; 		sub.l	#1,d4
; 		bcs	@final
; 		add.l	#1,d3
; 		move.w	d3,d1
; 		and.w	#$F,d1
; 		cmp.w	#$A,d1
; 		blt.s	@nohex1
; 		add.l	#6,d3
; @nohex1:
; 		move.w	d3,d1
; 		and.w	#$F0,d1
; 		beq.s	@lownibloop
; 		cmp.w	#$A0,d1
; 		bcs.s	@nohex2
; 		add.l	#$60,d3
; @nohex2:
; 		move.l	d3,d1
; 		and.w	#$F00,d1
; 		beq.s	@lownibloop
; 		cmp.w	#$A00,d1
; 		bcs.s	@nohex3
; 		add.l	#$600,d3
; @nohex3:
; 		move.l	d3,d1
;  		and.l	#$F000,d1
;  		beq.s	@lownibloop
;  		cmp.l	#$A000,d1
;  		bcs.s	@nohex4
;  		add.l	#$6000,d3
; @nohex4:
; 		move.l	d3,d1
;  		and.l	#$F0000,d1
;  		beq.s	@lownibloop
;  		cmp.l	#$A0000,d1
;  		bcs.s	@nohex5
;  		add.l	#$60000,d3
; @nohex5:
; 
;  		bra	@lownibloop
; @final:
; 		rts
; 		
; ; -----------------------
; ; $X0 array
; ; -----------------------
; 
; @middeclist:
; 		dc.l $16
; 		dc.l $32
; 		dc.l $64
; 		dc.l $128
		
; --------------------------------------------
; VDP_LoadMaps
; 
; Input:
; a0 - Pattern data
; d0 | WORD - Plane type: 0-FG 1-BG 2-Window
; d1 | LONG - XPos  (WORD) | YPos  (WORD)
; d2 | LONG - XSize (WORD) | YSize (WORD)
; d3 | WORD - VRAM
; 
; Uses:
; d4-d6
; --------------------------------------------

VDP_LoadMaps:
		;Check plane to use
		bsr	vdpshv_findvdppos
		
		move.l	#$400000,d4
		btst	#0,(RAM_VdpRegs+vdpReg_PlnSize)
		beq.s	@JpNot40
 		lsl.l	#1,d4
@JpNot40:
		btst	#1,(RAM_VdpRegs+vdpReg_PlnSize)
		beq.s	@Y_Loop
     		lsl.l	#1,d4
     		
@Y_Loop:
		move.l	d0,($C00004).l		; Set VDP location from d0
		swap	d2
		move.w	d2,d5	  		; Move X-pos value to d3
		swap	d2
@X_Loop:
		move.w	(a0)+,d6
                add.w	d3,d6
                move.w	d6,($C00000)		; Put data
		dbf	d5,@X_Loop		; X-pos loop (from d1 to d3)
		add.l	d4,d0                   ; Next line
		dbf	d2,@Y_Loop		; Y-pos loop
		rts

; --------------------------------------------
; VDP_LoadAsc
;
; Input:
; a0 - String
; d0 | WORD - Plane type: 0-FG 1-BG 2-Window
; d1 | LONG - XPos  (WORD) | YPos  (WORD)
; d2 | VRAM
; 
; Uses:
; d3-d4
; --------------------------------------------

VDP_LoadAsc:
		;Check plane to use
		bsr	vdpshv_findvdppos
		
		move.l	#$400000,d4
		btst	#0,(RAM_VdpRegs+vdpReg_PlnSize)
		beq.s	@JpNot40
 		lsl.l	#1,d4
@JpNot40:
		btst	#1,(RAM_VdpRegs+vdpReg_PlnSize)
		beq.s	@Space
     		lsl.l	#1,d4
     		
@Reset:
		move.l	d0,($C00004).l
@Next:
		moveq	#0,d3
		move.b	(a0)+,d3
		cmp.b	#$A,d3
		beq.s	@Space
		tst.b	d3
		bne.s	@Char
		rts
@Char:
		add.w	d2,d3
		move.w	d3,($C00000).l
		bra.s	@Next
@Space:
		add.l	d4,d0                   ; Next line
		bra.s	@Reset
@Exit:
		rts

; --------------------------------------------
; Vdp_Init
;
; Set the default registers
; --------------------------------------------

Vdp_Init:
		lea	Vdp_RegData(pc),a0
		lea	(RAM_VdpRegs),a1
		move.w	#$8000,d1
		moveq	#$17-1,d0
@Loop:
		move.b	(a0)+,(a1)+
		dbf	d0,@Loop
		rts

; --------------------------------------------
; Vdp_Update
;
; Refresh VDP
; --------------------------------------------

Vdp_Update:
		lea	(RAM_VdpRegs),a0
		move.w	#$8000,d1
		moveq	#$17-1,d0
@Loop:
		move.b	(a0)+,d1
		move.w	d1,($C00004).l
		move.b	#0,d1
		add.w	#$100,d1
		dbf	d0,@Loop
		rts
		
; --------------------------------------------
; VSync
; --------------------------------------------

VSync:
		bset	#bitFrameWait,(RAM_VIntWait)
@StillOn:
		btst	#bitFrameWait,(RAM_VIntWait)
		bne.s	@StillOn
		rts
		
; 		move.b	($C00005),d0
; 		btst	#3,d0
; 		beq.s	@StillOn

; -----------------------------------------

Vdp_RegData:
		dc.b $04
		dc.b $74
		dc.b $30
		dc.b $34
		dc.b $07
		dc.b $7C
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $03
		dc.b $81
		dc.b $3F
		dc.b $00
		dc.b $02
		dc.b $01
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $00
		dc.b $00
		even

; --------------------------------------------
; Vdp_RawAutoMap
;
; Input:
; d0 | LONG - VDP Address
; d1 | WORD - Width
; d2 | WORD - Height
; d3 | WORD - Start from this value
; d4 | WORD - Horizontal size type (32,40,128)
;
; Output:
; none
;
; Breaks:
; d5
; --------------------------------------------
		
Vdp_RawAutoMap:
		moveq	#0,d5
		add.w	d3,d5
		move.w	d5,d3

		move.b	(RAM_VdpRegs+vdpReg_PlnSize),d4
		and.w	#%00000011,d4
		lsl.w	#2,d4
		lea	VDP_LineAddr(pc),a5
		move.l	(a5,d4.w),d4		;Space

@Loop_2:
		move.l	d0,($C00004)		;Set VDP location from d0
		move.w	d1,d5	  		;Move X-pos value to d3
@Loop:
		move.w	d3,($C00000)		;Put data
                add.w	#1,d3
		dbf	d5,@Loop		;X-pos loop (from d1 to d3)
		add.l	d4,d0                   ;Next line
		dbf	d2,@Loop_2		;Y-pos loop
		rts
		
VDP_LineAddr:
		dc.l $400000
		dc.l $800000
		dc.l $800000
		dc.l $1000000
		even
		
		