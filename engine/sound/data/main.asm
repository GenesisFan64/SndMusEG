; ================================================================
; User data
; ================================================================
 		
; ================================================================	
; ***************************************************
; FM Voices
; ***************************************************

; ins_piano_casino:
;    		incbin	"engine/sound/data/instruments/old/piano/piano_real.bin"
;    		even

; ins_piano_80s:
;   		incbin	"engine/sound/data/instruments/old/piano/piano_80s.bin"
;   		even
ins_piano_generic:
   		incbin	"engine/sound/data/instruments/old/piano/piano_generic.bin"
    		even
ins_piano_real:
    		incbin	"engine/sound/data/instruments/old/piano/piano_real.bin"
    		even
ins_piano_small:
   		incbin	"engine/sound/data/instruments/old/piano/piano_small.bin"
   		even
ins_piano_rave:
  		incbin	"engine/sound/data/instruments/old/piano/piano_rave.bin"
    		even
; ; 
; ; ; ----------------------------------------
; ; 
ins_bass_techno:
    		incbin	"engine/sound/data/instruments/old/bass/bass_techno.bin"
    		even
ins_brass_funny:
   		incbin	"engine/sound/data/instruments/old/brass/brass_funny.bin"
   		even
ins_brass_2:
   		incbin	"engine/sound/data/instruments/old/brass/brass_2.bin"
   		even
; ; ins_fmdrum_kick:
; ;  		incbin	"engine/sound/data/instruments/old/drums/fm_kick.bin"
; ;  		even
ins_fmdrum_closedhat:
   		incbin	"engine/sound/data/instruments/old/drums/fm_openhat.bin"
   		even
; ;  		

; ; ; ----------------------------------------
; ; 
; ; ins_bell_test:
; ;  		incbin	"engine/sound/data/instruments/old/bell/bell_xmas.bin"
; ;  		even
; ; 
; ; ; ----------------------------------------
; ; 
ins_fx_echo:
  		incbin	"engine/sound/data/instruments/old/fx/ecco_thelagoon.bin"
  		even
	
ins_kid_1:  	incbin	"engine/sound/data/instruments/old/old/kid/patch_01.smps"
   		even
ins_kid_2:  	incbin	"engine/sound/data/instruments/old/old/kid/patch_02.smps"
   		even
  	
  	
ins_trumpet:
		incbin	"engine/sound/data/instruments/old/old/trumpet_generic.bin"
   		even
 
ins_bass_heavy:
		incbin	"engine/sound/data/instruments/old/bass/bass_heavy_1.bin"
   		even
   		
inspack_socket:
		incbin	"engine/sound/data/instruments/old/old/socket_voiceset.bin"
   		even
   		
; ================================================================	
; ***************************************************
; Music
; ***************************************************
 	
; MainTheme:
;   		dc.l @Voices,@Samples,0
;    		dc.b 33,6
;   		dc.b  FM_1, FM_2, FM_3, FM_4, FM_5, FM_6
;   		dc.b PSG_1,PSG_2,PSG_3,NOISE
;   		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
;   		dcb.b $12,$00
;    		incbin "engine/sound/data/music/song1.it",$50+$2E63
;    		even
; @Voices:
;   		dc.w 4,0
;     		dc.l ins_fmdrum_closedhat
;     		dc.w 6,0
;     		dc.l ins_bass_techno
;     		dc.w 7,0
;    		dc.l ins_brass_funny
;      		dc.w 9,0
;      		dc.l ins_fx_echo 
;   		dc.w $FFFF
;   		even
; @Samples:
;    		dc.w 1,0
;    		dc.l samp_Kick
;    		dc.l samp_Kick_end
;    		dc.l samp_Kick
;    		dc.w 2,0
;    		dc.l samp_Snare
;    		dc.l samp_Snare_end
;    		dc.l samp_Snare
;    		dc.w 3,0
;    		dc.l samp_Tom
;    		dc.l samp_Tom_end
;    		dc.l samp_Tom
;   		dc.w $FFFF
;   		even
;  
; @ExSampl:
;      		dc.w -1
;      		dc.w -1
;    		even

; -------------------------------------

song_Lyle:
  		dc.l @Voices,@Samples,0
   		dc.b 18,3
  		dc.b  FM_1, FM_2, FM_3, FM_4, FM_5, FM_6
  		dc.b PSG_1,PSG_2,PSG_3,NOISE
  		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
  		dcb.b $12,$00
   		incbin "engine/sound/data/music/something.it",$50+$1150+$10
   		even
@Voices:
;     		dc.w 8,0
;      		dc.l ins_fmdrum_closedhat
    		dc.w 1,0
     		dc.l ins_bass_heavy
      		dc.w 3,0
     		dc.l ins_trumpet
;      		dc.w 9,0
;      		dc.l ins_fx_echo 
  		dc.w $FFFF
  		even
@Samples:
   		dc.w 5,0
    		dc.l samp_Kick
    		dc.l samp_Kick_end
    		dc.l samp_Kick
    		dc.w 6,0
    		dc.l samp_Snare
    		dc.l samp_Snare_end
    		dc.l samp_Snare
  		dc.w $FFFF
  		even
 
@ExSampl:
 		PCM_Entry "CHOR.WAV",pcm_brass_1,0,-11
 		PCM_Entry "PIANO__1.WAV",pcm_piano,-1,0
     		dc.w -1
       		dc.b 12,1
       		dc.b 2,2	
     		dc.w -1
   		even
   		
; ---------------------------------------------------
 
; Tempo: 7

TestSong:
  		dc.l @Voices,@Samples,@ExSampl
   		dc.b 10,0
  		dc.b FM_1, FM_2, FM_3, FM_4, FM_5, FM_6
  		dc.b PSG_1,PSG_2,PSG_3,NOISE
  		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
  		dcb.b $12,$00
   		incbin "engine/sound/data/music/sound-beim-laden.it",$50+$2C28+$18
   		even
@Voices:
      		dc.w 2,0
     		dc.l ins_bass_heavy
      		dc.w 5,0
    		dc.l ins_fmdrum_closedhat
      		dc.w 6,$12
     		dc.l inspack_socket
  		dc.w $FFFF
  		even
@Samples:
   		dc.w 1,0
    		dc.l samp_TechnoKick
    		dc.l samp_TechnoKick_end
    		dc.l samp_TechnoKick
   		dc.w 7,0
    		dc.l samp_TechnoKick
    		dc.l samp_TechnoKick_end
    		dc.l samp_TechnoKick
   		dc.w 3,0
    		dc.l samp_TechnoSnare
    		dc.l samp_TechnoSnare_end
    		dc.l samp_TechnoSnare
  		dc.w $FFFF
  		even
 
@ExSampl:
   		PCM_Entry "MCLSTRNG.WAV",pcm_mcl_string,-1,-11
    		PCM_Entry "SPHEAVY1.WAV",pcm_sp_heavy1,-1,-11
      		dc.w -1
      		dc.b 10,2
       		dc.b 11,1
      		dc.w -1
    		even
   	
; ---------------------------------------------------

; Tempo: 12

TestSong_2:
  		dc.l @Voices,@Samples,@ExSampl
   		dc.b 21,0
  		dc.b FM_1,FM_2,FM_3,FM_4,FM_5,FM_6
  		dc.b PSG_1,PSG_2,PSG_3,-1
  		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
  		dcb.b $12,$00
   		incbin "engine/sound/data/music/klu_pian.it",$50+$383+8
   		even
@Voices:
    		dc.w 1,0
      		dc.l ins_piano_real
  		dc.w -1
  		even
  		
@Samples:
  		dc.w -1
  		even
 
@ExSampl:
		PCM_Entry "PIANO.WAV",pcm_piano,19200,-12
  		dc.w -1
  		dc.w -1
  		even
  		
; ---------------------------------------------------

; Tempo: 12

TestSong_3:
  		dc.l @Voices,@Samples,@ExSampl
   		dc.b 11,0
  		dc.b FM_1, FM_2, FM_3, FM_4, FM_5, FM_6
  		dc.b PSG_1,PSG_2,PSG_3,NOISE
  		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
  		dcb.b $12,$00
;    		incbin "engine/sound/data/music/doremifa.it",$184F+$50
    		incbin "engine/sound/data/music/light.it",$1E71+$50+$10
   		even
@Voices:
      		dc.w 1,0
     		dc.l ins_piano_rave
      		dc.w 2,0
     		dc.l ins_bass_techno
      		dc.w 12,0
     		dc.l ins_brass_funny
  		dc.w $FFFF
  		even
@Samples:
   		dc.w 1,0
    		dc.l samp_Snare
    		dc.l samp_Snare_end
    		dc.l samp_Snare
  		dc.w $FFFF
  		even
 
@ExSampl:
    		PCM_Entry "CHOR.WAV",pcm_brass_1,0,-11
     		dc.w -1
     		dc.b 3,1
     		dc.b 4,1
     		dc.b 13,1
     		dc.w -1
   		even


; ---------------------------------------------------

TestSong_4:
 		dc.l @Voices,@Samples,@ExSampl
  		dc.b 13,1
 		dc.b FM_1,FM_2,FM_3,FM_4,FM_5,FM_6
 		dc.b PSG_1,PSG_2,PSG_3,NOISE
 		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
 		dcb.b $12,$00
  		incbin "engine/sound/data/music/yuki.it",$50+$39E9+$18
  		even
@Voices:
   		dc.w 8,0
    		dc.l ins_fmdrum_closedhat
   		dc.w 3,0
    		dc.l ins_bass_techno
    		dc.w 6,0
   		dc.l ins_piano_real
;     		dc.w 9,0
;     		dc.l ins_fx_echo 
 		dc.w $FFFF
 		even
@Samples:
  		dc.w 4,0
   		dc.l samp_Kick
   		dc.l samp_Kick_end
   		dc.l samp_Kick
   		dc.w 1,0
   		dc.l samp_Snare
   		dc.l samp_Snare_end
   		dc.l samp_Snare
   		dc.w 16,0
   		dc.l samp_Tom
   		dc.l samp_Tom_end
   		dc.l samp_Tom
   		dc.w 18,0
   		dc.l samp_Tom
   		dc.l samp_Tom_end
   		dc.l samp_Tom
 		dc.w $FFFF
 		even

@ExSampl:
   		PCM_Entry "PIANO.WAV",pcm_piano,-1,0
   		PCM_Entry "CHOR.WAV",pcm_brass_1,0,-11
  		dc.w -1
     		dc.b 2,1
     		dc.b 12,2		
  		dc.w -1
  		even
;  		
; ---------------------------------------------------

SmegSong_Title:
  		dc.l @Voices,0,@ExSampl
    		dc.b 1,1
   		dc.b FM_1,FM_2,FM_3,FM_4,FM_5,FM_6
   		dc.b PSG_1,PSG_2,PSG_3,NOISE	
    		dc.b PCM_1,PCM_2,PCM_3,PCM_4,PCM_5,PCM_6,PCM_7,PCM_8
   		dcb.b $12,$00
    		incbin "engine/sound/data/music/title.it",$50+$1677+$10
    		even
@Voices:
; ;     		dc.w 8,0
; ;      		dc.l ins_fmdrum_closedhat
; ;     		dc.w 3,0
; ;      		dc.l ins_bass_techno
; ;      		dc.w 1,0
; ;     		dc.l ins_piano_real
      		dc.w 1,0
       		dc.l ins_fx_echo 
   		dc.w $FFFF
   		even
; @Samples:
;    		dc.w 4,0
;     		dc.l samp_Kick
;     		dc.l samp_Kick_end
;     		dc.l samp_Kick
;     		dc.w 1,0
;     		dc.l samp_Snare
;     		dc.l samp_Snare_end
;     		dc.l samp_Snare
;     		dc.w 16,0
;     		dc.l samp_Tom
;     		dc.l samp_Tom_end
;     		dc.l samp_Tom
;     		dc.w 18,0
;     		dc.l samp_Tom
;     		dc.l samp_Tom_end
;     		dc.l samp_Tom
;   		dc.w $FFFF
;   		even
;  
@ExSampl:
 		PCM_Entry "CHOR.WAV",pcm_brass_1,0,-11
     		dc.w -1
       		dc.b 1,1		
     		dc.w -1
   		even
 		
; ================================================================
; ***************************************************
; SFX
; ***************************************************

sfx_CharJump:
		dc.l 0,0,0
 		dc.b 1,1
   		dc.b -1,-1,-1,-1,-1,-1
   		dc.b -1,-1,-1,NOISE	
    		dc.b -1,-1,-1,-1,-1,-1,-1,-1
		dcb.b $12,$00

		incbin	"engine/sound/data/sfx/char_jump.it",0x34F+0x50+8
		even
		
; ---------------------------

sfx_PrizeToing:
		dc.l 0,0,0
 		dc.b 1,1
   		dc.b -1,-1,-1,-1,-1,-1
   		dc.b -1,PSG_2,-1,NOISE	
    		dc.b -1,-1,-1,-1,-1,-1,-1,-1
		dcb.b $12,$00

		incbin	"engine/sound/data/sfx/prize_blup.it",0x347+0x50
		even

; ---------------------------

sfx_ArrowPlup:
		dc.l 0,@Samples,0
 		dc.b 1,1
   		dc.b -1,-1,-1,-1,-1,FM_6
   		dc.b -1,-1,-1,-1	
    		dc.b -1,-1,-1,-1,-1,-1,-1,-1
		dcb.b $12,$00

		incbin	"engine/sound/data/sfx/arrow_plup.it",0xE1+0x50
		even
@Samples:
     		dc.w 1,0
     		dc.l samp_Kick
     		dc.l samp_Kick_end
     		dc.l samp_Kick
   		dc.w -1
   		even
 		
; ***************************************************
; Z80 Samples
; ***************************************************

;  		if MARS
 		cnop 0,$10000
;   		endif
		
; ----------------------------------------

samp_Kick:	incbin	"engine/sound/data/samples/dac/sauron_kick.wav",$2C
samp_Kick_end:
 		even
samp_Snare:	incbin	"engine/sound/data/samples/dac/snare.wav",$2C
samp_Snare_end:
 		even
samp_TechnoKick:
		incbin	"engine/sound/data/samples/dac/ST-72_techno-bassd3.wav",$2C
samp_TechnoKick_end:
 		even
samp_TechnoSnare:
		incbin	"engine/sound/data/samples/dac/ST-79_whodini-snare.wav",$2C
samp_TechnoSnare_end:
 		even

samp_Tom:	incbin	"engine/sound/data/samples/dac/sauron_tom.wav",$2C
samp_Tom_end:
 		even
 		