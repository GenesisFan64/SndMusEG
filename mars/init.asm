; ====================================================================
; -----------------------------------------------------------------
; Header
; -----------------------------------------------------------------

		include	"mars/sh2/include/shared_map.asm"
		
		org 0
		dc.l 0
		dcb.l $B,$3F0
		cnop 0,$70
                dc.l MD_Hint&$7FFFF
		cnop 0,$78
                dc.l MD_Vint&$7FFFF

		cnop 0,$100
		dc.b "SEGA 32X        "
		cnop 0,$110
		dc.b "(C)GF64 2016.???"
                cnop 0,$120
		dc.b "?????????????????????                           "
                cnop 0,$150
                dc.b "Lack of ideas: the videogame MARS               "
                dc.b "GM HOMEBREW-00"
                cnop 0,$190
		dc.b "J               "

		dc.l 0
		dc.l MD_RomEnd
		dc.l $FF0000
		dc.l $FFFFFF
		dc.b "RA",$E8,$20
		dc.l $200000
		dc.l $203FFF

		cnop 0,$1F0
		dc.b "U               "

; ----------------------------------------
; MARS vector
; ----------------------------------------

                cnop 0,$200
		jmp	MD_Entry
		cnop 0,$2A2
		jmp	MD_Hint
		cnop 0,$2AE
		jmp	MD_Vint
		
; ----------------------------------------
; MARS User Header
; ----------------------------------------

		cnop 0,$3C0
		dc.b "*32x Check Mode*"				; module name
		dc.l 0						; version
		dc.l SH2_Start					; SH2 Program start address
		dc.l 0						; SH2 Program write address
		dc.l SH2_End-SH2_Start				; SH2 Program length
		dc.l MasterEntry+$120				; Master SH2 initial PC
		dc.l SlaveEntry+$120				; Slave SH2 initial PC
		dc.l MasterEntry				; Master SH2 initial VBR address
		dc.l SlaveEntry					; Slave SH2 intitial VBR address
	
		incbin	"mars/incl/security.bin"
		
; ----------------------------------------
; Finished checking
; ----------------------------------------

 		bcs	@NoMars
 
; ----------------------------------------
; Init already...
; ----------------------------------------

@init:
		move	#$2700,sr
		lea	(marsreg),a5
		
@M_OK:		cmp.l	#'M_OK',$20(a5)
		bne	@M_OK
@S_OK:		cmp.l	#'S_OK',$24(a5)
		bne	@S_OK

		moveq	#0,d0
		move.l	d0,$20(a5)
		move.l	d0,$24(a5)
		
 		jmp	MD_Entry
 		
; ===========================================================================
; ----------------------------------------
; 32x not inserted
; ----------------------------------------

@NoMars:
		move.w	#$2700,sr
		
		jsr	(Vdp_Init)&$7FFFF
		jsr	(Vdp_Update)&$7FFFF	
		move.w	#$4EF9,(RAM_VIntJumpTo)
		move.l	#MiniVint,(RAM_VIntAddr)

; 		lea	NoMars_Pal(pc),a0
; 		lea	(RAM_PalFadeBuff),a1
; 		move.w	#$F,d0
; @loadpal:
; 		move.w	(a0)+,(a1)+
; 		dbf	d0,@loadpal
; 		
; 		lea	NoMars_Art(pc),a0
; 		move.l	#$40200000,($C00004)
; 		move.w	#(NoMars_Art_End-NoMars_Art)/4,d0
; @loadart:
; 		move.l	(a0)+,($C00000)
; 		dbf	d0,@loadart
; 
; 		lea	NoMars_Map(pc),a0
;  		moveq	#0,d0
; 		move.l	#($000A<<16)|$0009,d1
;  		move.l	#((((160)/8)-1)<<16)|(((72)/8)-1),d2
; 		move.w	#1,d3
; 		jsr	(VDP_LoadMaps)&$7FFFF
; 		
; 		move.w	#$2000,sr
; 		
; 		moveq	#ID_FadeIn,d0
; 		move.l	#$000F0008,d1
;  		jsr	(PalFade_Set)&$7FFFF
;  		jsr	(PalFade_Wait)&$7FFFF
		
@loop:
; 		jsr	(VSync)&$7FFFF
		
		nop
		nop
		bra	@loop

; -----------------------------------------------------------------

MiniVint:
		jsr	(PalFade)&$7FFFF
		
		lea	(RAM_PalBuffer),a6
		move.l	#$C0000000,($C00004).l
		move.w	#$3F,d0
@PalBuf:
		move.w	(a6)+,($C00000).l
		dbf	d0,@PalBuf
		rts

; -----------------------------------------------------------------

; NoMars_Art:	incbin "engine/misc/nomars/art.bin"
; NoMars_Art_End:
; 		even
; NoMars_Pal:	incbin "engine/misc/nomars/pal.bin"
; 		even
; NoMars_Map:	incbin "engine/misc/nomars/map.bin"
; 		even
; 		
; ===========================================================================
; -----------------------------------------------------------------
; Startup code
; -----------------------------------------------------------------

 		obj *+marsipl
MD_Entry:	
		bclr 	#FM,(marsreg+access)
;  		bsr	Mars_InitVdpFrame
		
		bsr	Vdp_Init
		bsr	Vdp_Update

		move.b	#0,(RAM_GameMode)
		bra 	MD_Main
		
