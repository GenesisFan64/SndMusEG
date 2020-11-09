; ====================================================================
; -----------------------------------------------------------------
; Header
; -----------------------------------------------------------------

		dc.l 0
		dc.l MD_Entry

		cnop 0,$70
                dc.l MD_Hint
		cnop 0,$78
                dc.l MD_Vint

		cnop 0,$100
		dc.b "SEGA GENESIS    "
		cnop 0,$110
		dc.b "(C)GF64 2016.???"
                cnop 0,$120
		dc.b "????????????????                                "
                cnop 0,$150
                dc.b "???                                             "
                dc.b "GM HOMEBREW-00"
                cnop 0,$190
		dc.b "J               "

		dc.l 0
		dc.l MD_RomEnd
		dc.l $FF0000
		dc.l $FFFFFF
		dc.b "RA",%11111000,$20
		dc.l $200000
		dc.l $2003FF

		cnop 0,$1F0
		dc.b "U               "
		            
; -----------------------------------------------------------------
; Startup
; -----------------------------------------------------------------

                cnop 0,$200
MD_Entry:
		tst.l	($A10008).l		;Test Port A control
		bne.s	@PortA_Ok
		tst.w	($A1000C).l		;Test Port C control
@PortA_Ok:
		bne	@Skip

		move.b	($A10001).l,d0		;version
		andi.b	#$F,d0
		beq.s	@Older
		move.l	($100),($A14000).l
@Older:   
		tst.w	($C00004).l		;test if VDP works
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp			;set usp to $0

		move	#$2700,sr
		move.w	#$100,($A11100).l	;Stop the Z80
		move.w	#$100,($A11200).l	;Reset the Z80
		
		bclr	#bitHasTMSS,(RAM_VIntWait)
		tst.l	($FFFFC000)
		beq.s	@no_msg
		bset	#bitHasTMSS,(RAM_VIntWait)
@no_msg:
		lea	($FFFF0000).l,a0
		move.w	#$7FFF,d1
@ClearRAM:
		clr.w	(a0)+
		dbf	d1,@ClearRAM
		movem.l	($FF0000).l,d0-a6
		
		move.l	#$81648F02,($C00004).l
; 		move.l	#$00000020,($C00004).l
; 		lea	(RAM_PalFadeBuff),a1
; 		moveq	#64-1,d0
; @nextpal:
; 		move.w	($C00000),d1
; 		move.w	d1,(a1)+
; 		dbf	d0,@nextpal
		move.b	#$9F,($C00011).l
		move.b	#$BF,($C00011).l
		move.b	#$DF,($C00011).l
		move.b	#$FF,($C00011).l
		
		move.w	#0,($A11200).l
		
		move.l	#$40000003,($C00004).l
		move.l	#"i"<<16|"n",($C00000).l
		move.l	#"i"<<16|"t",($C00000).l
		
;-----------------------
; Here starts your code
;-----------------------

@Skip:
		tst.w	($C00004).l
		move.b	#0,(RAM_GameMode)
		bra 	MD_Main
		
; @lol:
; 		dc.b "asdionmtnsrontownrkosemronasderwerts",0
; 		even
		