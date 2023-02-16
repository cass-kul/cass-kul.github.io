.data
song: .string "CCisCCesC CCGGAAG FFEEDDC" #The song string itself. 
# Any note (A-G) can be raised half a pitch (sharpened) with suffix is (e.g. Ais -> A sharp)
# Any note (A-G) can be lowered half a pitch (flattened) with suffix es (e.g. Des -> D flat)
# A space equals a rest

scale_base: .word 57 #leave this value unless you want to transpose the base scale
bpm: .word 100 # Beats per minute of the song
duration: .space 4 # Calculated in main (from bpm)
instrument: .word 1 # Change to whatever instrument you like
volume: .word 127 # Choose value between 0 and 127
.globl main
.text

#next_tone_from_string - begin
# Reads the first tone from a string of music letters
# a0 should contain the address of the string
# In a0 the tone number (which can be provided to play_tone) is returned
# In a1 the amount of bytes used from the input string is returned
#    e.g. C -> 1 byte, Cis -> 3 bytes
next_tone_from_string:
	li  t0, 0x41  #A
	mv  t2, a0    #t2 now holds address of string
	lb  t1, 0(t2)
	beq t1, t0, ret_A
	li  t0, 0x42
	beq t1, t0, ret_B
	li  t0, 0x43
	beq t1, t0, ret_C
	li  t0, 0x44
	beq t1, t0, ret_D
	li  t0, 0x45
	beq t1, t0, ret_E
	li  t0, 0x46
	beq t1, t0, ret_F
	li  t0, 0x47
	beq t1, t0, ret_G
	li  a0, 0
	li  a1, 1
	ret
ret_A: 
	li a0, 12
	j adjust
ret_B: 
	li a0, 13
	j adjust
ret_C: 
	li a0, 3
	j adjust
ret_D: 
	li a0, 5
	j adjust
ret_E: 
	li a0, 7
	j adjust
ret_F: 
	li a0, 8
	j adjust
ret_G: 
	li a0, 10
	j adjust
adjust:
	lb t1, 1(t2) #See if we encounted sharp or flat
	li t0, 0x65 #e
	beq t0, t1, flat
	li t0, 0x69 #i
	beq t0, t1, sharp
	li a1, 1
	ret
sharp:
	addi a0, a0, 1
	li a1, 3
	ret
flat:
	addi a0, a0, -1
	li a1, 3
	ret
#next_tone_from_string end


#Plays the song given in a0
#  a0 contains a pointer to the song string
#  tip: Use the functions next_tone_from_string and play_tone to play all tones in the input string
play_song:
	addi sp, sp, -12
	sw ra, 0(sp)
	
_ps_loop:
	lb t0, 0(a0)
	beqz t0, _end_song
	sw a0, 4(sp)
	jal next_tone_from_string
	sw a1, 8(sp)
	jal play_tone
	lw a0, 4(sp)
	lw t0, 8(sp)
	add a0, t0, a0
	j _ps_loop
	
_end_song:
	lw ra, 0(sp)
	addi sp, sp, 12
	ret

#Plays the tone given in a0
#if a0 is zero, a pause is expected (of duration "duration")
#otherwise, play the tone with pitch $a0 + scale_base (also with duration "duration")
play_tone:
	beqz a0, pause
	lw  t0, scale_base
	add a0, a0, t0
	lw a1, duration
	lw a2, instrument
	lw a3, volume 
	li a7, 33
	ecall
	ret
pause:
	li a7, 32
	lw a0, duration
	ecall
	ret
	
main:
	li t0, 60000
	lw t1, bpm
	div t2, t0, t1  #60000/bpm = ms delay
	sw t2, duration, t3 #t2: duration of note/delay

	la a0, song
	jal play_song
	
	li a7, 10
	ecall
