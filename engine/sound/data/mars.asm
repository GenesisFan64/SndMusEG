; ---------------------------------------------
; PWM Samples for SMEG
; 
; MARS Samples MUST be here
; ---------------------------------------------

		cnop 0,$8000
pcm_piano:	dc.l @End
  		incbin "engine/sound/data/samples/pcm/piano.wav",$2C
@End:
 		cnop 0,4
 		
		cnop 0,$8000
pcm_brass_1:	dc.l (pcm_brass_1+$23E6)
  		incbin "engine/sound/data/samples/pcm/chor.wav",$2C
@End:
 		cnop 0,4
 	
		cnop 0,$8000
pcm_piano_rave:	dc.l (pcm_piano_rave+$49D8)
  		incbin "engine/sound/data/samples/pcm/pianorav.wav",$2C
@End:
 		cnop 0,4
 		
; ---------------------------------------------

pcm_sp_heavy1:	dc.l @End
  		incbin "engine/sound/data/samples/pcm/SPHEAVY1.wav",$2C
@End:
 		cnop 0,4
pcm_mcl_string:	dc.l (pcm_mcl_string+$0DA8)
  		incbin "engine/sound/data/samples/pcm/MCLSTRNG.WAV",$2C
@End:
 		cnop 0,4
 		
; ---------------------------------------------
		
; 		MARS_Sample  pcm_arena1_1, A1_1.wav,-1
; 		MARS_Sample  pcm_arena1_2, A1_2.wav,-1
; 		MARS_Sample  pcm_arena1_3, A1_3.wav,-1
; 		MARS_Sample  pcm_arena1_4, A1_4.wav,-1
; 		MARS_Sample  pcm_arena1_5, A1_5.wav,-1
; 		MARS_Sample  pcm_arena1_6, A1_6.wav,-1
; 		MARS_Sample  pcm_arena1_7, A1_7.wav,-1
; 		MARS_Sample  pcm_arena1_8, A1_8.wav,-1
; 		MARS_Sample  pcm_arena1_9, A1_9.wav,-1
; 		MARS_Sample pcm_arena1_10,A1_10.wav,-1
; 		MARS_Sample pcm_arena1_11, A1_11.wav,-1
; 		MARS_Sample pcm_arena1_12, A1_12.wav,-1
; 		MARS_Sample pcm_arena1_13, A1_13.wav,-1
; 		MARS_Sample pcm_arena1_14, A1_14.wav,-1		
 		