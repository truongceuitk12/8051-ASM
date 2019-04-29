ORG 0000H
BUTTON BIT P3.4
LJMP MAIN
MAIN:
	
	MOV TMOD,#03       ; TIMER 0 MOD 3
	CALL SETBUZZER     ;BAT COI 500HZ TRONG 189MS
	CALL DELAYBITLOW   ;GOI TIMER
	JB BUTTON,MAIN  ; KIEM TRA NUT NHAN 
	CALL DELAY      ;CHONG DOI
	JNB BUTTON,$     
	CALL UART
	JMP MAIN
;********************************************
DELAYBITLOW:           ;DELAY 740*256US ~ 189 MS
	MOV R1,#740
LOOP1:
	MOV TL0, #0         ;DELAY 256US 8BIT LOW 
	SETB TR0            ;KHOI DONG TIMER
    JNB TF0, $          ;CHO TRAN
	CLR TF0 
	CLR TR0
	DJNZ R1, LOOP1
	RET
;********************************************* CAI DAT THOI GIAN BAT CHO BUZZER
SETBUZZER:           
    SETB P1.1        ;BAT COI
	MOV R2,#1000     ;DELAY TIME : 8*256US ~ 2MS 
	
LOOP2:
	NOP
	NOP              ; 2 US 2 NOP
	DJNZ R2,LOOP2    ;2*1000 = 2MS
	CLR P1.1         ;TURN OFF
	RET

;*********************************************
L1:
    MOV R3,250
	MOV R4,250
DELAY: ;250*250*2US
    NOP
	NOP
	DJNZ R3,DELAY
	DJNZ R4,DELAY
RET
	
;********************************************* GUI TEN
UART:
	MOV TMOD,#00010000B ; 
	MOV TH1,#0F3H  ; BOUD 4800 12MHZ
	MOV SCON,#50H  
	;TR1 CHUYEN SANG TIMER 0 MOD 3 NEN KO CAN BAT 
	

AGAIN:
    MOV A,#"T"
	ACALL TRUYEN
	MOV A,#"R"
	ACALL TRUYEN
	MOV A,#"U"
	ACALL TRUYEN
	MOV A,#"O"
	ACALL TRUYEN
	MOV A,#"N"
	ACALL TRUYEN
	MOV A,#"G"
	ACALL TRUYEN
	CALL AGAIN
TRUYEN: 
	MOV SBUF,A       
	JNB TI,$    
	CLR TI
	RET

END
	
