; Simple test for the NeoPixel peripheral

ORG 0

		LOADI 0 ;; clear all the pixels at the start
		OUT SET_ALL_PXLS
		CALL wait1
		
checkx:	IN Switches
		AND ONE
		JZERO checkb
		CALL xmas
		
		
checkb: IN Switches
		AND TWO
		JZERO checkc
		CALL smile

checkc: IN Switches
		AND THREE
		JZERO checkd
		CALL set24
		
checkd: IN Switches
        AND FOUR
		JZERO checke
		CALL flag
		
checke: IN Switches
		AND FIVE
		JZERO checkf
		CALL Set_All_F

checkf: IN Switches
		AND SIX
		JZERO checkg
		CALL auto	
		
checkg: IN Switches
		AND SEVEN
		JZERO end
		CALL flr
		
end: 	JUMP checkx

smile: LOADI 5
	   OUT PXL_M
	   OUT REFRESH
	   LOAD BLUE
	   OUT SET_ALL_PXLS
	   CALL wait1
	   
	   ;; set bottom part of smile
	   LOADI 45
	   OUT PXL_A
	   
	   LOAD WHITE
	   OUT PXL_D
	   LOAD WHITE
	   OUT PXL_D
	   LOAD WHITE
	   OUT PXL_D
	   LOAD WHITE
	   OUT PXL_D
	   
	   LOADI 78
	   OUT PXL_A
	   
	   LOAD WHITE
	   OUT PXL_D
	   
	   LOADI 83
	   OUT PXL_A
	   
	   LOAD WHITE
	   OUT PXL_D
	   
	   LOADI 143
	   OUT PXL_A
	   
	   LOAD WHITE
	   OUT PXL_D
	   
	   LOADI 146
	   OUT PXL_A
	   
	   LOAD WHITE
	   OUT PXL_D
	   
	   LOADI 2
	   OUT PXL_M
	   
	   LOADI 0
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 31
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 32
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 63
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 64
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 95
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 96
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 127
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 128
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 159
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 160
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D
	   
	   LOADI 191
	   OUT PXL_A
	   LOAD WHITE
	   OUT PXL_D
	   OUT PXL_D   
	  
	   
	   
	   OUT REFRESH
	   
	   CALL wait10
	   CALL wait10
	   CALL wait10
	   
	   LOADI 8
	   OUT PXL_M
	   
	   CALL wait10
	   CALL wait10
	   OUT REFRESH
	   CALL wait10
	   CALL wait10
	   CALL wait10
	   OUT REFRESH
	   
	   
	   
	   
	   
	   
		CALL check0 ;; wait for all switches to be down before being done
		CALL clear ;; clear pixels
		CALL wait1 ;; wait a little longer for set all to be done
		RETURN


xmas:   LOADI 7 ; turn on xmas lights mode
		OUT PXL_M
		CALL check0 ;; wait for all switches to be down before being done
		CALL clear ;; clear pixels
		CALL wait1 ;; wait a little longer for set all to be done
		RETURN
		
flag:  LOADI 4
       OUT PXL_M
	   LOAD RED
	   OUT SET_ALL_PXLS ;; set everything to red
	   CALL wait1
	   
	   LOADI 0 ;; set white line
	   OUT PXL_A
	   
	   LOADI 32
	   OUT PXL_C
	   
	   LOAD WHITE 
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 64 ;; set white line
	   OUT PXL_A
	   
	   LOADI 32
	   OUT PXL_C
	   
	   LOAD WHITE 
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 128 ;; set white line
	   OUT PXL_A
	   
	   LOADI 32
	   OUT PXL_C
	   
	   LOAD WHITE 
	   OUT PXL_D
	   
	   CALL wait1
	   
	   ;; now set blue part of the flag
	   
	   LOAD BLUE
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 96
	   OUT PXL_A
	   
	   LOADI 15
	   OUT PXL_C
	   
	   LOAD BLUE
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 145
	   OUT PXL_A
	   
	   LOADI 30
	   OUT PXL_C
	   
	   LOAD BLUE
	   OUT PXL_D
	   
	   CALL wait1
	   
	   CALL check0 ;; wait for all switches to be down before being done
	   CALL clear ;; clear pixels
	   CALL wait1 ;; wait a little longer for set all to be done
	   RETURN



check0: IN Switches
		JNEG check0
		JPOS check0
		RETURN
		
clear: LOADI 0
       OUT PXL_M
	   OUT SET_ALL_PXLS
	   RETURN
	   
wait1: OUT TIMER
wait1j: IN  TIMER
	   SUB ONE
	   JNEG wait1j
	   RETURN
	   
	   
wait10: OUT TIMER
wait10j: IN  TIMER
	   SUB Ten
	   JNEG wait10j
	   RETURN
	   
set24: LOADI 2 ; set mode
	   OUT PXL_M
	   
set24Loop1:	   ; Set Address to 0
	   LOAD set24A
	   OUT PXL_A
	   LOAD set24A
	   ADDI 1
	   STORE set24A
	   
	   ; ; Set Faint 24 bit Blues
	   ; LOADI 0
	   ; OUT PXL_D
	   ; LOADI 1
	   ; OUT PXL_D
	   
	   ; Set Faint 24 bit Green
	   LOADI 1
	   OUT PXL_D
	   LOADI 0
	   OUT PXL_D
	   
	   LOAD set24A
	   ADDI -96
	   JNEG set24Loop1
	   LOADI 0
	   STORE set24A
	   
	   ; Set Faint 16 bit BLue
	   ; Set 16 bit mode
	   LOADI 4
	   OUT PXL_M
	   
	   ; Set Address to 1
	   LOADI 97
	   OUT PXL_A
	   
	   ; Set Faint 16 bit Blue
	   LOADI 96
	   OUT PXL_C
	   
	   ; ; Set Color
	   ; LOADI 1
	   ; OUT PXL_D
	   
	    ; Set Color
	   LOADI 32
	   OUT PXL_D
	   
	   CALL wait10
	   CALL wait10
	   CALL wait10
	   
	   CALL clear
	   CALL wait1
	   CALL wait10
	   
	   LOADI 2 ; set mode
	   OUT PXL_M

set24Loop2:	   ; Set Address to 0
	   LOAD set24A
	   OUT PXL_A
	   LOAD set24A
	   ADDI 1
	   STORE set24A
	   
	   ; Set Faint 24 bit Blues
	   LOADI 0
	   OUT PXL_D
	   LOADI 1
	   OUT PXL_D
	   
	   ; ; Set Faint 24 bit Green
	   ; LOADI 256
	   ; OUT PXL_D
	   ; LOADI 0
	   ; OUT PXL_D
	   
	   LOAD set24A
	   ADDI -96
	   JNEG set24Loop2
	   LOADI 0
	   STORE set24A
	   
	   ; Set Faint 16 bit BLue
	   ; Set 16 bit mode
	   LOADI 4
	   OUT PXL_M
	   
	   ; Set Address to 1
	   LOADI 97
	   OUT PXL_A
	   
	   ; ; Set Faint 16 bit Blue
	   ; LOADI 96
	   ; OUT PXL_C
	   
	   ; Set Color
	   LOADI 1
	   OUT PXL_D
	   
	   
	   CALL wait10
	   CALL wait10
	   CALL wait10
	   
	   CALL clear
	   CALL wait1
	   CALL wait10

	   LOADI 2 ; set mode
	   OUT PXL_M

set24Loop3:	   ; Set Address to 0
	   LOAD set24A
	   OUT PXL_A
	   LOAD set24A
	   ADDI 1
	   STORE set24A
	   
	   ; Set Faint 24 bit Blues
	   LOADI 256
	   OUT PXL_D
	   LOADI 0
	   OUT PXL_D
	   
	   ; ; Set Faint 24 bit Green
	   ; LOADI 256
	   ; OUT PXL_D
	   ; LOADI 0
	   ; OUT PXL_D
	   
	   LOAD set24A
	   ADDI -96
	   JNEG set24Loop3
	   LOADI 0
	   STORE set24A
	   
	   ; Set Faint 16 bit BLue
	   ; Set 16 bit mode
	   LOADI 4
	   OUT PXL_M
	   
	   ; Set Address to 1
	   LOADI 97
	   OUT PXL_A
	   
	   ; ; Set Faint 16 bit Blue
	   ; LOADI 96
	   ; OUT PXL_C
	   
	   ; Set Color
	   LOAD Light_RED
	   OUT PXL_D
	   
	   
	   CALL wait10
	   CALL wait10
	   CALL wait10
	
	   CALL check0
	   CALL clear
	   CALL wait1
	   RETURN
	   
auto: LOADI 5
	  OUT PXL_M
	  
	  LOADI 0
	  OUT PXL_A
	  
	  autoloop:
			LOAD autoc
			JZERO autodone
			
			LOAD BOW1
			OUT PXL_D
			CALL wait1
			LOAD BOW2
			OUT PXL_D
			CALL wait1
			LOAD BOW3
			OUT PXL_D
			CALL wait1
			LOAD BOW4
			OUT PXL_D
			CALL wait1
			LOAD BOW5
			OUT PXL_D
			CALL wait1
			LOAD BOW6
			OUT PXL_D
			CALL wait1
			LOAD BOW7
			OUT PXL_D
			CALL wait1
			LOAD BOW8
			OUT PXL_D
			CALL wait1
			
			LOAD autoc
			ADDI -1
			STORE autoc
			JUMP autoloop

	   autodone:
	   LOADI 8
	   STORE autoc
	   CALL check0
	   CALL clear
	   CALL wait1
	   RETURN
	
	autoc:  DW 32

Set_All_F:
		LOAD BLUE
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		LOAD WHITE
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		LOAD RED
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		LOAD BOW1
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		LOAD BOW2
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		LOAD BOW3
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		LOAD BOW4
		OUT  SET_ALL_PXLS
		CALL wait10
		CALL wait10
		
		CALL check0
	    CALL clear
	    CALL wait1
		RETURN
		
flr:    OUT REFRESH ;; pause screen updates
		CALL wait1
		CALL wait1

	   LOADI 4 ;; draw flag
       OUT PXL_M
	   LOAD RED
	   OUT SET_ALL_PXLS ;; set everything to red
	   CALL wait1
	   
	   LOADI 0 ;; set white line
	   OUT PXL_A
	   
	   LOADI 32
	   OUT PXL_C
	   
	   LOAD WHITE 
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 64 ;; set white line
	   OUT PXL_A
	   
	   LOADI 32
	   OUT PXL_C
	   
	   LOAD WHITE 
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 128 ;; set white line
	   OUT PXL_A
	   
	   LOADI 32
	   OUT PXL_C
	   
	   LOAD WHITE 
	   OUT PXL_D
	   
	   CALL wait1
	   
	   ;; now set blue part of the flag
	   
	   LOAD BLUE
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 96
	   OUT PXL_A
	   
	   LOADI 15
	   OUT PXL_C
	   
	   LOAD BLUE
	   OUT PXL_D
	   
	   CALL wait1
	   
	   LOADI 145
	   OUT PXL_A
	   
	   LOADI 30
	   OUT PXL_C
	   
	   LOAD BLUE
	   OUT PXL_D
	   
	   CALL wait10
	   CALL wait10
	   CALL wait10 
		
		OUT REFRESH ;; being updating screen again
		

		CALL check0
	    CALL clear
	    CALL wait1
		RETURN
		

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
PXL_M: 	   EQU &H0B2
REFRESH:   EQU &H0B4
Twenty:    DW 20
Ten:       DW 10
SET_ALL_PXLS: EQU &H0B3
PXL_C: EQU &H0B8
ZERO: 	   DW &H0000
ONE:       DW &H0001
TWO:       DW &H0002
THREE:	   DW &H0004
FOUR:      DW &H0008
FIVE:	   DW &H0010
SIX: 	   DW &H0020
SEVEN:     DW &H0040
set24A:    DW &H0000

BLUE:      DW &H000F
WHITE:	   DW &HFFFF
RED: 	   DW &HF000
Light_RED: DW &H0800
BOW1:      DW &HE1C7
BOW2:      DW &HE6A7
BOW3:	   DW &H3F07
BOW4:	   DW &H3F18
BOW5:	   DW &H3D3C
BOW6:	   DW &H3A5C
BOW7:	   DW &H1DC
BOW8:	   DW &HE1CB