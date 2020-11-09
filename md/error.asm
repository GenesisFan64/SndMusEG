; ===========================================================================
; Error screen
; ===========================================================================

vdp_Xpos	equ	$20000
vdp_Ypos_32	equ	$400000
Plane_WD	equ	$50000003

MD_BusError:
		bsr	ErrorScr_Init
		lea	Asc_ErrBus(pc),a0
		bsr	ErrorScr_ShowMsg
		bra	ErrorScr_Loop

MD_AddrError:
		bsr	ErrorScr_Init
		lea	Asc_ErrAddr(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_IllegalError:
		bsr	ErrorScr_Init
		lea	Asc_ErrIlle(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_ZeroDivError:
		bsr	ErrorScr_Init
		lea	Asc_ErrZerDiv(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_ChkError:
		bsr	ErrorScr_Init
		lea	Asc_ErrChk(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_TrapVError:
		bsr	ErrorScr_Init
		lea	Asc_ErrTrapV(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_PrivilegeError:
		bsr	ErrorScr_Init
		lea	Asc_ErrPriv(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_TraceError:
		bsr	ErrorScr_Init
		lea	Asc_ErrTrace(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_LineA_Error:
		bsr	ErrorScr_Init
		lea	Asc_ErrLineA(pc),a0
		bsr	ErrorScr_ShowMsg
		bra.s	ErrorScr_Loop

MD_LineF_Error:
		bsr	ErrorScr_Init
		lea	Asc_ErrLineF(pc),a0
		bsr	ErrorScr_ShowMsg

; ----------------------------------------------
; Loop
; ----------------------------------------------

ErrorScr_Loop:
		bsr	Pads_Read

		tst.b	(RAM_Joypads+OnPress)
		bne.s	@View
		bra.s	ErrorScr_Loop

; ----------------------------------------------

@View:
		move.w	#$8124,($C00004)
		move.w	#$8C00,($C00004)
		move.l	#$9000927C,($C00004)
		move.w	#$927C,($C00004)
		move.w	#$8164,($C00004)
		bchg	#0,($FFFF4000)
		beq.s	ErrorScr_Loop

		move.w	#$8124,($C00004)
		move.l	#$8C019081,($C00004)
		move.w	#$9200,($C00004)
		move.w	#$8164,($C00004)
		bra.s	ErrorScr_Loop

; ===========================================================================
; ----------------------------------------------
; Init
; ----------------------------------------------

ErrorScr_Init:	
 		move.w	#$2700,sr
 		movem.l	d0-d7/a0-a7,($FFFF4000)
 		move.b	#0,(RAM_VdpRegs+vdpReg_PlnSize)
 		
 		move.l	#$81248C00,($C00004)
 		move.l	#$9000927C,($C00004)
		move.b	#$9F,($C00011)
 		move.b	#$BF,($C00011)
 		move.b	#$DF,($C00011)
 		move.b	#$FF,($C00011)

   		move.l	#$50000003,($C00004)
   		move.w	#$37F,d0
@ClrWinScr:
   		move.w	#($8560|$6000)+" ",($C00000)
   		dbf	d0,@ClrWinScr
  		lea	Art_DbgFont(pc),a0
		move.l	#$70000002,($C00004)
   		move.w	#((Art_DbgFont_End-Art_DbgFont)/4)-1,d1
@Loop:
		move.l	(a0)+,($C00000).l
		dbf	d1,@Loop
 
  		lea	($FFFF4000),a1
  		move.l	#Plane_WD+(vdp_Ypos_32*8)+(vdp_Xpos*7),d3
  		moveq	#7,d5
@ShowDdata:
  		movem.l	d3,-(sp)
		moveq	#0,d0
		move.l	(a1),d0
		move.l	d3,d1
		move.w	#$8560+$6000+"0",d2
; 		bsr	VDP_ShowVal_Long
		movem.l	(sp)+,d3
  
		add.l	#$400000,d3
		adda	#4,a1
  		dbf	d5,@ShowDdata
 
  		lea	($FFFF7020),a1
  		move.l	#Plane_WD+(vdp_Ypos_32*8)+(vdp_Xpos*20),d3
  		moveq	#7,d5
@ShowAdata:
  		movem.l	d3,-(sp)
                 moveq	#0,d0
                 move.l	(a1),d0
                 move.l	d3,d1
                 move.w	#$8560+$6000+"0",d2
;                  bsr	VDP_ShowVal_Long
                 movem.l	(sp)+,d3
 
                 add.l	#$400000,d3
                 adda	#4,a1
 		dbf	d5,@ShowAdata
  
   		clr.b	($FFFF4000)

 		move.w	#$8164,($C00004)
		rts

; ----------------------------------------------
; Show error text
; ----------------------------------------------

ErrorScr_ShowMsg:
		move.l	#$51060003,($C00004).l
@LoopStr:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	@end
		add.w	#$8560+$6000,d0
		move.w	d0,($C00000).l
		bra.s 	@LoopStr
@end:
		rts

; ===========================================================================

Asc_ErrBus:	dc.b "BUS ERROR                ",0
		even		
Asc_ErrAddr:	dc.b "ADDRESS ERROR            ",0
		even		
Asc_ErrIlle:	dc.b "ILLEGAL Instruction      ",0
		even		
Asc_ErrZerDiv:	dc.b "ZERO DIVIDE              ",0
		even		
Asc_ErrChk:	dc.b "CHK INSTRUCTION          ",0
		even		
Asc_ErrTrapV:	dc.b "TRAPV ERROR              ",0
		even		
Asc_ErrPriv:	dc.b "PRIVILEGE ERROR          ",0
		even	
Asc_ErrTrace:	dc.b "TRACE                    ",0
		even
Asc_ErrLineA:	dc.b "LINEA ERROR              ",0
		even
Asc_ErrLineF:	dc.b "LINEF ERROR              ",0
		even
		
Art_DbgFont:	incbin	"engine/shared/data/art_dbgfont.bin",0,($20*96)
Art_DbgFont_End:

 		even