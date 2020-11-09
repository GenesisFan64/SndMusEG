; =================================================================
; ------------------------------------------------
; SH2
; 
; Master jobs:
; Graphics / 3D
;
; Slave jobs:
; PWM
; ------------------------------------------------

		include	"mars/sh2/include/sh2_map.asm"
		include	"mars/sh2/include/shared_map.asm"
		org CS3

; =================================================================
; ------------------------------------------------
; Master CPU
; ------------------------------------------------

		obj MasterEntry
SH2_Master:
		dc.l @Entry,M_STACK		; Cold PC,SP
		dc.l @Entry,M_STACK		; Manual PC,SP

		dc.l ErrorTrap			; Illegal instruction
		dc.l 0				; reserved
		dc.l ErrorTrap			; Invalid slot instruction
		dc.l $20100400			; reserved
		dc.l $20100420			; reserved
		dc.l ErrorTrap			; CPU address error
		dc.l ErrorTrap			; DMA address error
		dc.l ErrorTrap			; NMI vector
		dc.l ErrorTrap			; User break vector

		dcb.l 19,0			; reserved

		dcb.l 32,ErrorTrap		; Trap vectors

 		dc.l master_irq			; Level 1 IRQ
		dc.l master_irq			; Level 2 & 3 IRQ's
		dc.l master_irq			; Level 4 & 5 IRQ's
		dc.l master_irq			; PWM interupt
		dc.l master_irq			; Command interupt
		dc.l master_irq			; H Blank interupt
		dc.l master_irq			; V Blank interupt
		dc.l master_irq			; Reset Button

; =================================================================
; ------------------------------------------------
; Master entry
; ------------------------------------------------

@Entry:
		mov.l	#_sysreg,r14
		ldc	r14,gbr

; ----------------------------------

@wait_md:
		mov.l	@(comm0,gbr),r0
		cmp/eq	#0,r0
		bf	@wait_md

; ----------------------------------	

		mov.l	#"SLAV",r1
@wait_slave:
		mov.l	@(comm8,gbr),r0		; wait for the slave to finish booting
		cmp/eq	r1,r0
		bf	@wait_slave

; =================================================================
; ------------------------------------------------
; Hotstart
; ------------------------------------------------

m_hotstart:
		mov.l	#M_STACK,r15

		mov.l	#_sysreg,r14
		ldc	r14,gbr

;   		mov	#FM,r0			(moved to 68k)
;   		mov.b	r0,@(adapter,gbr)

 		mov	#VIRQ_ON|CMDIRQ_ON|PWMIRQ_ON,r0
    		mov.b	r0,@(intmask,gbr)
		mov.l	#$20,r0
		ldc	r0,sr
		nop
		
; ==================================================================
; ---------------------------------------------------
; Master start
; ---------------------------------------------------

master_start:
    		mov.l	#pwm_init,r0
    		jsr	@r0
    		nop

; =================================================================
; ---------------------------------------------------
; Master loop
; ---------------------------------------------------

master_loop:
		mov	#mars_features,r1
		mov	@r1,r0
		cmp/eq	#1,r0
		bf	@no_models
		
 		mov	#0,r0
 		mov.b	@(adapter,gbr),r0
 		and 	#FM,r0
 		tst 	#FM,r0
 		bt	@no_models
		
      		mov	#Vdp_WaitFrame,r0
      		jsr	@r0
      		nop
      		mov	#Vdp_ClearFrame,r0
      		jsr	@r0
      		nop
      		
      		mov	#models_run,r0
      		jsr	@r0
      		nop
		
      		mov	#Vdp_FlipFrame,r0
      		jsr	@r0
      		nop

@no_models:
		bra	master_loop
		nop

; -------------------------
; list
; -------------------------

		cnop 0,4
master_requests:
		dc.l 0
		dc.l @cmd_1		; Load picture
		dc.l @cmd_2		; Load pal 
		dc.l @cmd_3		; Load palfade
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_C		; Request fade
		dc.l @cmd_D		; Wait until it finishes
		dc.l @cmd_E		; Set video mode
		dc.l @cmd_F		; Display next frame
		
		dc.l @cmd_10		; Enable/Disable features
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0

		dc.l @cmd_20		;Model: NEW Model
		dc.l @cmd_0		;Model: DELETE Model
		dc.l @cmd_22		;Model: Modify X Y Z
		dc.l @cmd_23		;Model: Modify Xrot Yrot Zrot
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		
; ------------------------------------------------
; command ??
;
; nothing
; ------------------------------------------------

@cmd_0:
		rts
		nop
		cnop 0,4
		lits

; ------------------------------------------------
; command 01
;
; Load art
;
; comm4 | LONG - address
; comm8 | WORD - X start
; comm10| WORD - Y start
; comm12| WORD - X size
; comm14| WORD - Y size
; comm16| WORD - Target mode
; ------------------------------------------------

@cmd_1:
		mov.l	pr,@-r15
		
 		mov.l	@(comm4,gbr),r0
 		mov	r0,r1
 		mov 	#0,r0
 		mov.w	@(comm8,gbr),r0
 		mov	r0,r2
 		mov.w	@(comm10,gbr),r0
 		mov	r0,r3
  		mov.w	@(comm12,gbr),r0
 		mov	r0,r4	
 		mov.w	@(comm14,gbr),r0
 		mov	r0,r5
 		mov	#1,r6
 		bsr 	Vdp_LoadArt
 		nop

		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 02
;
; Load palette
; 
; comm4 | LONG - address
; comm8 | WORD - start from
; comm10| WORD - number of colors
; ------------------------------------------------

@cmd_2:
		mov.l	pr,@-r15
		
		mov.l	@(comm4,gbr),r0
		mov	r0,r1
		mov 	#0,r0
		mov.w	@(comm10,gbr),r0
		mov	r0,r3
 		mov.l	#pal_buffer,r4
		bsr 	Vdp_LoadPal_Raw
		nop
		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits

; ------------------------------------------------
; command 03
;
; Load palette for fade
; 
; comm4 | LONG - address
; comm8 | WORD - start from
; comm10| WORD - number of colors
; ------------------------------------------------

@cmd_3:
		mov.l	pr,@-r15
		
		mov.l	@(comm4,gbr),r0
		mov	r0,r1
		mov 	#0,r0
		mov.w	@(comm10,gbr),r0
		mov	r0,r3
		mov.l	#pal_fadebuff,r4
		mov 	#0,r0
		mov.w	@(comm8,gbr),r0
		extu	r0,r0
		shll	r0
		add 	r0,r4
		bsr 	Vdp_LoadPal_Raw
		nop
		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits

; ------------------------------------------------
; command 0C
;
; Request fade
;
; comm4 | WORD - request type
; comm6 | WORD - speed
; comm8 | WORD - start from
; comm10| WORD - number of colors
; ------------------------------------------------

@cmd_C:
		mov.l	pr,@-r15
		
 		mov 	#0,r0
 		mov.w	@(comm4,gbr),r0
 		mov	r0,r1
 		mov.w	@(comm6,gbr),r0
 		mov	r0,r2
 		mov.w	@(comm8,gbr),r0
 		mov	r0,r3
 		mov.w	@(comm10,gbr),r0
 		mov	r0,r4
     		bsr	palfade_set
      		nop
     		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 0D
;
; Wait fade
; ------------------------------------------------

@cmd_D:
		mov.l	pr,@-r15

		mov.l	#palfade_control,r1
@wait:
		mov	@(fade_request,r1),r0
		cmp/eq	#0,r0
		bf	@wait
     		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 0E
;
; Set video mode
;
; comm4| WORD - mode ID
; ------------------------------------------------

@cmd_E:
		mov.l	pr,@-r15
		
		mov 	#0,r0
		mov.w	@(comm4,gbr),r0
		mov	r0,r1
     		bsr	Vdp_SetMode
     		nop
     		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 0F
;
; Show next frame
; ------------------------------------------------

@cmd_F:
		mov.l	pr,@-r15
		
    		bsr	Vdp_FlipFrame
     		nop
     		bsr	Vdp_WaitFrame
     		nop
     		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 10
;
; Enable/Disable features
; 
; Input:
; comm4 | WORD Disable/Enable flags (0,1)
; ------------------------------------------------

@cmd_10:
		mov.l	pr,@-r15

 		mov	#0,r0
    		mov.w	@(comm4,gbr),r0
		mov	#mars_features,r1
		mov	r0,@r1
		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 20
;
; Model: Set NEW Model
;
; Input:
; comm4 | LONG - Model address
; comm8 | WORD - Slot
; ------------------------------------------------

@cmd_20:
		mov.l	pr,@-r15
		
 		mov	#0,r0
    		mov.w	@(comm8,gbr),r0
    		mov	r0,r2
    		mov.l	@(comm4,gbr),r0
    		mov	r0,r1
     		mov.l	#Mars3d_ModelSet,r0
     		jsr	@r0
     		nop
		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits

; ------------------------------------------------
; command 22
;
; Model: Modify X,Y,Z
;
; Input:
;  comm4 | WORD - Slot
;  comm6 | WORD - X
;  comm8 | WORD - Y
; comm10 | WORD - Z
; ------------------------------------------------

@cmd_22:
		mov.l	pr,@-r15
		
		mov.l	#models_buffer,r4
    		mov	#0,r0
    		mov.w	@(comm4,gbr),r0
    		extu	r0,r0
    		mov	r0,r2
		mov	#sizeof_model,r0
		mulu	r2,r0
		mov	macl,r0
		add 	r0,r4
		
     		mov	#0,r0
      		mov.w	@(comm6,gbr),r0
       		exts.w	r0,r0
     		mov	r0,@(model_x,r4)
     		mov	#0,r0
     		mov.w	@(comm8,gbr),r0
     		exts.w	r0,r0
     		mov	r0,@(model_y,r4)
     		mov	#0,r0
     		mov.w	@(comm10,gbr),r0
     		exts.w	r0,r0
     		mov	r0,@(model_z,r4)
   		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; ------------------------------------------------
; command 23
;
; Model: Modify X,Y,Z Rotation
;
; Input:
;  comm4 | WORD - Slot
;  comm6 | WORD - Xrot
;  comm8 | WORD - Yrot
; comm10 | WORD - Zrot
; ------------------------------------------------

@cmd_23:
		mov.l	pr,@-r15
		
		mov.l	#models_buffer,r4
    		mov	#0,r0
    		mov.w	@(comm4,gbr),r0
    		extu	r0,r0
    		mov	r0,r2
		mov	#sizeof_model,r0
		mulu	r2,r0
		mov	macl,r0
		add 	r0,r4
		
     		mov	#0,r0
      		mov.w	@(comm6,gbr),r0
       		exts	r0,r0
     		mov	r0,@(model_x_rot,r4)
     		mov	#0,r0
     		mov.w	@(comm8,gbr),r0
       		exts	r0,r0
     		mov	r0,@(model_y_rot,r4)
     		mov	#0,r0
     		mov.w	@(comm10,gbr),r0
       		exts	r0,r0
     		mov	r0,@(model_z_rot,r4)
   		
		mov.l	@r15+,pr
		rts
		nop
		cnop 0,4
		lits
		
; =================================================================
; ------------------------------------------------
; Error
; ------------------------------------------------

ErrorTrap:
		bra	ErrorTrap
		nop
		lits

; =================================================================
; ------------------------------------------------
; Subs 
; ------------------------------------------------

		include	"mars/sh2/subs/vdp.asm"
		include	"mars/sh2/subs/fade.asm"
 		include	"mars/sh2/subs/3d.asm"
 		cnop 0,4
 		
; =================================================================
; ------------------------------------------------
; irq
; 
; r0-r9 only
; ------------------------------------------------

master_irq:
		mov.l	r0,@-r15
		mov.l	r1,@-r15
		mov.l	r2,@-r15
		mov.l	r3,@-r15
		mov.l	r4,@-r15
		mov.l	r5,@-r15
		mov.l	r6,@-r15
		mov.l	r7,@-r15
		mov.l	r8,@-r15
		mov.l	r9,@-r15
		mov.l	macl,@-r15
		mov.l	mach,@-r15
		sts.l	pr,@-r15
		
		stc	sr,r0
		shlr2	r0
		and	#$3C,r0
		mov.l	#@list,r1
		add	r1,r0
		mov.l	@r0,r1
		jsr	@r1
		nop
		
		lds.l	@r15+,pr
		mov.l	@r15+,mach
		mov.l	@r15+,macl
		mov.l	@r15+,r9
		mov.l	@r15+,r8
		mov.l	@r15+,r7
		mov.l	@r15+,r6
		mov.l	@r15+,r5
		mov.l	@r15+,r4
		mov.l	@r15+,r3
		mov.l	@r15+,r2
		mov.l	@r15+,r1
		mov.l	@r15+,r0
		rte
		nop
		lits

; ------------------------------------------------
; irq list
; ------------------------------------------------

		align	4
@list:
		dc.l @invalid_irq,@invalid_irq
		dc.l @invalid_irq,@invalid_irq
		dc.l @invalid_irq,@invalid_irq
		dc.l @pwm_irq,@pwm_irq
		dc.l @cmd_irq,@cmd_irq
		dc.l @h_irq,@h_irq
		dc.l @v_irq,@v_irq
		dc.l @vres_irq,@vres_irq

; =================================================================
; ------------------------------------------------
; Unused
; ------------------------------------------------

@invalid_irq:
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Master | PWM Interrupt
; ------------------------------------------------

@pwm_irq:

; ----------------------------------
; Run PWM driver
; ----------------------------------

 		mov.w	@(monowidth,gbr),r0
 		shlr8	r0
		tst	#$80,r0
		bf	@exit

		mov.l	pr,@-r15
 		mov.l	#pwm_run,r0
		jsr	@r0
 		nop
  		mov.l	@r15+,pr
@exit:

; ----------------------------------

		mov	#1,r0
		mov.w	r0,@(pwmintclr,gbr)
		
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Master | CMD Interrupt
; ------------------------------------------------

@cmd_irq:	
		mov 	#0,r0
		mov.b	@(comm0,gbr),r0
		cmp/eq	#0,r0
		bt	@no_req
		
		shll2	r0
		mov.l	#master_requests,r1
		add	r1,r0
		mov.l	@r0,r1
		mov.l	pr,@-r15
		jsr	@r1
		nop
		mov.l	@r15+,pr
		
		mov 	#0,r0
		mov.b	r0,@(comm0,gbr)
@no_req:
		
; ----------------------------------

		mov	#1,r0
		mov.w	r0,@(cmdintclr,gbr)
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Master | VRES Interrupt
; ------------------------------------------------

@vres_irq:
		mov	#1,r0
		mov.w	r0,@(vresintclr,gbr)
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Master | HBlank
; ------------------------------------------------

@h_irq:
		mov	#1,r0
		mov.w	r0,@(hintclr,gbr)

; ----------------------------------

;  		mov.l	#@values+4,r1
;  		mov.l	@r1,r0
;  		add.l	#1,r0
;  		mov.l	r0,@r1
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Master | VBlank
; ------------------------------------------------

@v_irq:
		mov	#1,r0
		mov.w	r0,@(vintclr,gbr)

; ----------------------------------
; Fade colors
; ----------------------------------

		mov.l	pr,@-r15
 		mov.l	#pal_fade,r0
		jsr	@r0
 		nop
  		mov.l	@r15+,pr

; ----------------------------------
; Copy colors
; ----------------------------------

		mov.l	#0,r0
		mov.b	@(adapter,gbr),r0
		and 	#FM,r0
		tst 	#FM,r0
		bt	@genesis_side
		
		mov 	#0,r0
		mov 	#pal_buffer,r1
		mov	#_palette,r2
		mov 	#256/$10,r3
; 		mov 	#$8000,r4		;TEMPORAL
@next:
		rept $10
		mov.w	@r1+,r0
; 		or	r4,r0			;TEMPORAL
		mov.w	r0,@r2
		add 	#2,r2
		endr
		
		dt 	r3
		bf	@next

; 		mov	#_palette,r2		;TEMPORAL
; 		mov	@r2,r0			;TEMPORAL
; 		mov	#$7FFF,r1		;TEMPORAL
; 		and	r1,r0			;TEMPORAL
; 		mov 	r0,@r2			;TEMPORAL
		
@genesis_side:
 		mov.l	#vint_m_sync,r1
 		mov.l	#0,r0
 		mov.l	r0,@r1
		rts
		nop
		cnop 0,4
		lits

; =================================================================
		
		objend
		inform 0,"MARS SH2 MASTER SIZE: %h",*-SH2_Master;,(SlaveEntry-CS3)
		cnop 0,(SlaveEntry-CS3)
		
; =================================================================
; ------------------------------------------------
; Slave CPU
; ------------------------------------------------

		obj SlaveEntry
SH2_Slave:
		dc.l @Entry,S_STACK		; Cold PC,SP
		dc.l @Entry,S_STACK		; Manual PC,SP

		dc.l ErrorTrap			; Illegal instruction
		dc.l 0				; reserved
		dc.l ErrorTrap			; Invalid slot instruction
		dc.l $20100400			; reserved
		dc.l $20100420			; reserved
		dc.l ErrorTrap			; CPU address error
		dc.l ErrorTrap			; DMA address error
		dc.l ErrorTrap			; NMI vector
		dc.l ErrorTrap			; User break vector

		dcb.l 19,0			; reserved

		dcb.l 32,ErrorTrap		; Trap vectors

 		dc.l slave_irq			; Level 1 IRQ
		dc.l slave_irq			; Level 2 & 3 IRQ's
		dc.l slave_irq			; Level 4 & 5 IRQ's
		dc.l slave_irq			; PWM interupt
		dc.l slave_irq			; Command interupt
		dc.l slave_irq			; H Blank interupt
		dc.l slave_irq			; V Blank interupt
		dc.l slave_irq			; Reset Button

; =================================================================
; ------------------------------------------------
; Slave entry
; ------------------------------------------------

@Entry:
		mov.l	#_sysreg,r14
		ldc	r14,gbr
		
@wait_md:
		mov.l	@(comm0,gbr),r0
		cmp/eq	#0,r0
		bf	@wait_md
	
		mov.l	#"SLAV",r0
		mov.l	r0,@(comm8,gbr)

; =================================================================
; ------------------------------------------------
; Hotstart
; ------------------------------------------------

s_hotstart:	
		mov.l	#S_STACK,r15

		mov.l	#_sysreg,r14
		ldc	r14,gbr
	
 		mov	#CMDIRQ_ON,r0
    		mov.b	r0,@(intmask,gbr)
		mov.l	#$20,r0
		ldc	r0,sr
 		
 		mov.l	#slave_start,r0
		jmp	@r0
 		nop
		lits
 
; =================================================================
; ------------------------------------------------
; Subs 
; ------------------------------------------------

 		include	"mars/sh2/subs/pwm.asm"
 		cnop 0,4
 		
; ==================================================================
; ---------------------------------------------------
; Start
; ---------------------------------------------------

slave_start:
;        	mov	#$2033000,r1
;           	mov	#$21ED4DC,r2
;        	mov	r1,r3
;        	mov	#0,r4
;        	mov	#0,r5
;        	bsr	pwm_setentry
;        	nop
;       	mov.l	#$21ED4DC,r1
;        	mov.l	#$23A79B7,r2
;        	mov	r1,r3
;        	mov	#0,r4
;        	mov	#1,r5
;        	bsr	pwm_setentry
;        	nop
; 		mov	#0,r1
; 		mov	#$3C,r2
; 		mov	#2,r3
; 		bsr	pwm_play
; 		nop
; 		mov	#1,r1
; 		mov	#$3C,r2
; 		mov	#1,r3
; 		bsr	pwm_play
; 		nop
		
; =================================================================
; ---------------------------------------------------
; Slave loop
; ---------------------------------------------------

slave_loop:
 		mov	#taskfor_slave,r14
		mov	@r14,r0
		cmp/eq	#0,r0
		bt	@no_req
		
		shll2	r0
		mov.l	#@TRIDI_TASKS,r1
		add	r1,r0
		mov.l	@r0,r1
		mov.l	pr,@-r15
		jsr	@r1
		nop
		mov.l	@r15+,pr
		
 		mov	#0,r0
 		mov	r0,@r14
@no_req:
		bra	slave_loop
		nop

; ----------------------------------------

@TRIDI_TASKS:
		dc.l 0
		dc.l @task_1
		dc.l @task_2

; ----------------------------------------
; Task 1
; ----------------------------------------

@task_1:
		mov.l	pr,@-r15
		
		mov	#slve_faces,r12
@next_draw:
      		mov	@r12+,r11
      		mov	#-1,r0
      		cmp/eq	r0,r11
      		bt	@end_this
      		
       		mov	@(faces_srcaddr,r11),r1
      		mov	@(faces_type,r11),r3
           	mov	@(face_tex,r11),r4
           	mov	@(face_tex_width,r11),r5
           	mov	@(face_tex_add,r11),r6
      		add 	#face_points,r11
      		mov	r11,r2
           	mov 	#0,r7
            	mov 	#Draw_Face_Slave,r0
            	jsr	@r0
            	nop
              	bra	@next_draw
            	nop
            	
@end_this:

		mov.l	@r15+,pr
		rts
		nop

; ----------------------------------------
; Task 2
; ----------------------------------------

@task_2:
		mov.l	pr,@-r15

   		mov	#taskarg_slave,r7
           	mov	@r7,r13
      		mov	@(faces_srcaddr,r13),r1
      		mov	r13,r2
      		add 	#face_points,r2
      		mov	@(faces_type,r13),r3
           	mov	@(face_tex,r13),r4
           	mov	@(face_tex_width,r13),r5
           	mov 	#Draw_Face_Slave,r0
           	jsr	@r0
           	mov	@(face_tex_add,r13),r6
           	
		mov.l	@r15+,pr
		rts
		nop

; =================================================================
; -------------------------
; Slave CMD requests
; -------------------------

		cnop 0,4
slave_requests:
		dc.l 0
		dc.l @cmd_1			; Play
		dc.l @cmd_2			; Stop
		dc.l @cmd_3			; Set channel sample
		dc.l @cmd_4			; Set channel volume
		dc.l @cmd_5			; Set sample to the list
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		dc.l @cmd_0
		
; ------------------------------------------------
; command ??
;
; nothing
; ------------------------------------------------

@cmd_0:
		rts
		nop

; ------------------------------------------------
; command 01
;
; play sample + set pan
;
; comm2:
; $xx00 | pan+channel %LRCCCCCC
; $00xx | note
; ------------------------------------------------

@cmd_1:
		mov.l	pr,@-r15
 		
		mov.w	@(comm2,gbr),r0		;$00xx
		and	#$FF,r0
      		mov	r0,r2
		mov.w	@(comm2,gbr),r0		;$xx00
		shlr8	r0
		mov	r0,r3
		shlr2 	r3
		shlr2 	r3
		shlr2 	r3
		extu	r0,r0
		and	#%00111111,r0
      		mov	r0,r1
      		
           	bsr	pwm_play
          	nop
          	
		mov.l	@r15+,pr
		rts
		nop

; ------------------------------------------------
; command 02
;
; stop
; 
; Input:
; comm14 - channel
; ------------------------------------------------

@cmd_2:
		mov.l	pr,@-r15
 		
  		mov.l	#0,r0
		mov.b	@(comm2,gbr),r0
		and	#$FF,r0
		mov	r0,r1
   		bsr	pwm_stop
   		nop
  		
		mov.l	@r15+,pr
		rts
		nop
		
; ------------------------------------------------
; command 03
;
; comm2:
; $xx00 | channel
; $00xx | sample
; ------------------------------------------------

@cmd_3:
		mov.l	pr,@-r15

		mov.w	@(comm2,gbr),r0		;$00xx
		and	#$FF,r0
      		mov	r0,r2
		mov.w	@(comm2,gbr),r0		;$xx00
		shlr8	r0
		and	#$FF,r0
      		mov	r0,r1
      		bsr	pwm_setsmpl
      		nop
         	
		mov.l	@r15+,pr
		rts
		nop
		
; ------------------------------------------------
; command 04
;
; comm2:
; $xx00 | channel
; $00xx | volume
; ------------------------------------------------

@cmd_4:
		mov.l	pr,@-r15

		mov.w	@(comm2,gbr),r0		;$00xx
		and	#$FF,r0
      		mov	r0,r2
		mov.w	@(comm2,gbr),r0		;$xx00
		shlr8	r0
		and	#$FF,r0
      		mov	r0,r1
      		bsr	pwm_setvol
      		nop

  		mov.l	@r15+,pr
		rts
		nop
		
; ------------------------------------------------
; command 05
;
; set
;
; Input:
; comm12 | LONG - ROM address Start/End
; comm10 | WORD - Loop point (-1 = dont loop)
;  comm2 | WORD - slot | note transpose
; ------------------------------------------------

@cmd_5:
		mov.l	pr,@-r15
  		mov.l	#0,r0
		mov.l	@(comm12,gbr),r0
      		mov.l	@r0+,r2			;End
      		mov.l	r0,r1			;Start
  		mov.l	#0,r0
		mov.w	@(comm10,gbr),r0	;Loop (-1 dont loop)
		mov.l	#$FFFFFFFF,r3
		cmp/eq	r3,r0
		bt	@true
		extu	r0,r0
		mov.l	r1,r3
		add	r0,r3
@true:
		mov.b	@(comm2+1,gbr),r0	;$00xx
		exts	r0,r0
      		mov	r0,r4
		mov.b	@(comm2,gbr),r0		;$xx00
		and	#$FF,r0
      		mov	r0,r5
      		bsr	pwm_setentry
     		nop	
      		
  		mov.l	@r15+,pr
		rts
		nop
 		
; =================================================================
; ------------------------------------------------
; irq
; 
; r0-r9 only
; ------------------------------------------------

slave_irq:
		mov.l	r0,@-r15
		mov.l	r1,@-r15
		mov.l	r2,@-r15
		mov.l	r3,@-r15
		mov.l	r4,@-r15
		mov.l	r5,@-r15
		mov.l	r6,@-r15
		mov.l	r7,@-r15
		mov.l	r8,@-r15
		mov.l	r9,@-r15
		mov.l	macl,@-r15
		mov.l	mach,@-r15
		sts.l	pr,@-r15

		stc	sr,r0
		shlr2	r0
		and	#$3C,r0
		mov.l	#@inttable,r1
		add	r1,r0
		mov.l	@r0,r1
		jsr	@r1
		nop

		lds.l	@r15+,pr
		mov.l	@r15+,mach
		mov.l	@r15+,macl
		mov.l	@r15+,r9
		mov.l	@r15+,r8
		mov.l	@r15+,r7
		mov.l	@r15+,r6
		mov.l	@r15+,r5
		mov.l	@r15+,r4
		mov.l	@r15+,r3
		mov.l	@r15+,r2
		mov.l	@r15+,r1
		mov.l	@r15+,r0
	
		rte
		nop
		lits

; ------------------------------------------------
; irq list
; ------------------------------------------------

		align	4
@inttable:
		dc.l @invalid_irq,@invalid_irq
		dc.l @invalid_irq,@invalid_irq
		dc.l @invalid_irq,@invalid_irq
		dc.l @pwm_irq,@pwm_irq
		dc.l @cmd_irq,@cmd_irq
		dc.l @h_irq,@h_irq
		dc.l @v_irq,@v_irq
		dc.l @vres_irq,@vres_irq

; =================================================================
; ------------------------------------------------
; Unused
; ------------------------------------------------

@invalid_irq:
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Slave | PWM Interrupt
; ------------------------------------------------

@pwm_irq:
	
; ----------------------------------

		mov	#1,r0
		mov.w	r0,@(pwmintclr,gbr)
		
		rts
		nop
		cnop 0,4
		lits
		
; =================================================================
; ------------------------------------------------
; Slave | CMD Interrupt
; ------------------------------------------------

@cmd_irq:
		mov 	#0,r0
		mov.b	@(comm0+1,gbr),r0
		and	#%00001111,r0
		cmp/eq	#0,r0
		bt	@no_req
		
		shll2	r0
		mov.l	#slave_requests,r1
		add	r1,r0
		mov.l	@r0,r1
		mov.l	pr,@-r15
		jsr	@r1
		nop
		mov.l	@r15+,pr
		
		mov 	#0,r0
		mov.b	@(comm0+1,gbr),r0
		and 	#%11110000,r0
		mov.b	r0,@(comm0+1,gbr)
@no_req:
		
; ----------------------------------

		mov	#1,r0
		mov.w	r0,@(cmdintclr,gbr)
		rts
		nop
		cnop 0,4
		lits

; =================================================================
; ------------------------------------------------
; Slave | HBlank
; ------------------------------------------------

@h_irq:
		mov	#1,r0
		mov.w	r0,@(hintclr,gbr)

		rts
		nop
		cnop 0,4
		lits
	
; =================================================================
; ------------------------------------------------
; Slave | VBlank
; ------------------------------------------------

@v_irq:
		mov	#1,r0
		mov.w	r0,@(vintclr,gbr)

 		mov.l	#vint_s_sync,r1
 		mov.l	#0,r0
 		mov.l	r0,@r1
		rts
		nop
		cnop 0,4
		lits
		
; =================================================================
; ------------------------------------------------
; Slave | VRES Interrupt
; ------------------------------------------------

@vres_irq:
		mov	#1,r0
		mov.w	r0,@(vresintclr,gbr)
		rts
		nop
		cnop 0,4
		lits
		
; ====================================================================

		objend
		inform 0,"MARS SH2 SLAVE SIZE: %h",*-SH2_Slave;,(Sh2_CodeEnd-CS3)
 		
; ====================================================================
; ------------------------------------------------
; Data
; ------------------------------------------------
 	
;  		cnop 0,$8000
; tex_temporal:
; 		incbin "engine/misc/3dtest/cube/photo.data"
; 		cnop 0,4
		
; ====================================================================
; ------------------------------------------------
; RAM
; ------------------------------------------------

		cnop 0,4
		include	"mars/sh2/ram.asm"
		
