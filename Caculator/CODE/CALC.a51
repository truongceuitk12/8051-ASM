
N1		EQU 	30H								;Toan hang 1 (+ - * / )
N2		EQU		31H								;Toan hang 2 (=)
OP		EQU		32H								;Luu ASCII 
R		EQU		33H								;Result
SIGN	EQU		34H								;Dau cua kq (-)
TEMP	EQU		35H								
DIF		BIT		0AH								;Co tin hieu vao hang
OIF		BIT		0BH								;Co tin hieu vao toan tu
AIF		BIT		0CH								;Co tin hieu dau =
		ORG 	0H										
		AJMP	MAIN							
;--------------------------------------------------------------------------------------------------
;------------------------  KHOI TAO CHUONG TRINH   ------------------------------------------------
		ORG 	30H								
MAIN:	ACALL 	memoryInit						
		ACALL 	lcdInit							
		ACALL 	readInput						
		ACALL	calculateResult					
		ACAll 	printOutput						
		AJMP 	MAIN							
;-----------------------------------------------------------------------------------------
;----------------------- XOA CAC O NHO ---------------------------------------------------
memoryInit:										
		CLR		A													
		MOV		N1,A							
		MOV		N2,A							
		MOV		OP,A							
		MOV		R,A								
		MOV		SIGN,A							
		MOV		TEMP,A							
		CLR		C								
		MOV		DIF,C								
		MOV		OIF,C							
		MOV		AIF,C							
		RET										
;-------------------------KHOI TAO DPTR ---------------------------------------------
lcdInit:										
		MOV 	DPTR,#COMM				
C1: 	CLR 	A								
		MOVC 	A,@A+DPTR						
		ACALL 	COMMWRT		 ; command write					
		INC 	DPTR		 ; cong 1 dprt cho ma tiep theo				
		JZ 		C2			  ; ACC bang 0 thi dung 				
		SJMP 	C1							
C2:		RET					  ; return main				
;---------------------------------TOAN HANG SO 1--------------------------------------------#!
readInput:
		ACALL 	readKey							;# Goi keypad
		ACALL 	validateInput					;#Xac nhan so hop le
		JB		OIF,ERROR						;#Co toan hoang bat len 1 thi bao loi
		JB		AIF,ERROR						
		ACALL	DATAWRT							;#write data -> truyen du lieu toi LCD
		ANL		A,#0FH							;#Tao bien tam de doi ASC sang he BCD
		MOV		N1,A							;#Luu vao ram chua toan tu thu 1
		ACALL 	readKey							;#Goi toan hang
		ACALL 	validateInput					;#Kiem tra toan hang
		JB		DIF,ERROR						;#Bao loi neu xay ra
		JB		AIF,ERROR						;#Bao loi neu xay ra
		ACALL	DATAWRT							;#truyen du lieu toi LCD
		MOV		OP,A							;#Luu vao o nho chua toan hang
		
;----------------------------- TOAN HANG SO 2 --------------------------------------------------
		ACALL 	readKey							
		ACALL 	validateInput					
		JB		OIF,ERROR						
		JB		AIF,ERROR						
		ACALL	DATAWRT							
		ANL		A,#0FH							
		MOV		N2,A							
		ACALL 	readKey							;#Goi ham de gan toan hang =
		ACALL 	validateInput					;#Xac nhan hop le
		JB		DIF,ERROR						
		JB		OIF,ERROR						
		ACALL	DATAWRT							; in ra man hinh kq
		AJMP	NOERROR							;#Ko co loi 
ERROR:	ACALL	ERRFUN							;# Goi chuong trinh bao loi
		LJMP	MAIN							;#Nhay ve main
NOERROR:RET										;#return main
;-----------------KET QUA TINH TOAN-------------------------------------------#!
calculateResult:
		MOV		A,N1							;#CHUYEN TOAN HANG THU NHAT VAO ACC , THU 2 VAO B
		MOV		B,N2							
		MOV		R7,OP							;#CHUYEN TOAN TU VAO R7
		CJNE 	R7,#"+",NEXT11					;#KHAC CONG THI NHAY
		ADD		A,B								
		MOV		R,A								;#LUU KET QUA VAO RESULT
		MOV		SIGN,#"+"						;# DAU CUA KQ
		RET										;#RETURN MAIN
NEXT11:	CJNE	R7,#"-",NEXT22					;#KHAC TRU THI NHAY
		SUBB	A,B								
		JC		NIGATIV							;#AM THI NHAY
		MOV		R,A								;#RESULT 
		MOV		SIGN,#"+"						;#DAU KQ
		RET										;#!RETURN  MAIN
NIGATIV:CPL		A								
		INC 	A								
		MOV		R,A								;#RESULT
		MOV		SIGN,#"-"						;#DAU KQ
		RET										
NEXT22:	CJNE	R7,#"*",NEXT33					;#KHAC NHAN THI NHAY
		MUL		AB								
		MOV		R,A								
		MOV		SIGN,#"+"						
		RET										
NEXT33:	CJNE	R7,#"/",NEXT44					;#KHAC CHIA THI NHAY
		MOV		TEMP,B							;#LUU B VAO THANH GHI TEMP
		DIV		AB								;#CHIA LAY DU
		MOV		R,A								
		MOV		A,#0AH							
		MUL		AB								
		MOV		B,TEMP							;# LAY LAI SO THU 2
		DIV		AB								
		MOV		TEMP,A							
		MOV		SIGN,#"+"						
NEXT44:	RET										
;--------------------------- IN RA LCD ----------------------------------------------#!
printOutput:
		MOV		R7,TEMP							
		CJNE	R7,#0,POINTED					;#KIEM TRA SO THAP PHAN
		MOV		R6,SIGN							;#LUU DAU VAO R6
		CJNE	R6,#"+",SIGNED					;#KIEM TRA CO PHAI DUONG KHONG
RETURN:	MOV		A,R								;#LUU KQ VAO ACC
		MOV		B,#0AH							;#GAN B = 10
		DIV		AB								;#CHIA LAY DU
		JZ		LESSTEN							;#NHAY NEU NHO HON 10(DIV AB 0)
		ORL		A,#30H							;#CONVERT QUA ASCII
		ACALL	DATAWRT							;#CHUYEN QUA MAN HINH LCD
		MOV		A,B								;#LAY  	SO THU 2
		ORL		A,#30H							;#CHUYEN QUA ASCII
		ACALL	DATAWRT							;#CHUYEN QUA MAN HINH LCD
		AJMP	DONE							;#NHAY DE KET THUC 
LESSTEN:MOV		A,B								;#NEU KQ CHI CO 1 SO
		ORL		A,#30H							;#CHUYEN QUA ASCII
		ACALL	DATAWRT							;#HIEN THI LCD
		AJMP	DONE							
POINTED:MOV		A,R								;#SO THAP PHAN
		ORL		A,#30H							;#CHUYEN QUA ASC II
		ACALL	DATAWRT							;#IN LCD
		MOV		A,#"."							;#CHUEN DAU . TU MA ASC VAO ACC 
		ACALL	DATAWRT							;#IN LCD
		MOV		A,TEMP							;#CHUYEN SO SAU DAU PHAY VAO ACC 
		ORL		A,#30H							;#CHUYEN QUA ASC II
		ACALL	DATAWRT							
		AJMP	DONE							
SIGNED:	MOV		A,#"-"							;# SO AM
		ACALL	DATAWRT							;#IN LCD
		AJMP	RETURN							;#NHAY VE RETURN 
DONE:	ACALL	LDELAY							;#THOI GIAN HIEN THI DU LIEU SAU KHI TINH TAON XONG
		ACALL	LDELAY							
		RET											
;-------------------------- XAC THUC TINH DUNG SAI CUA TOAN TU  -------------------------------------------#!	
validateInput:									
		CJNE	A,#"+", next1					;#KIEM TRA TU TAON TU CONG TRO DI
		AJMP	found							;#NHAY NEU TRUNG
next1:	CJNE	A,#"-", next2					
		AJMP	found							
next2:	CJNE	A,#"*", next3					
		AJMP	found							
next3:	CJNE 	A,#"/", next4					
		AJMP	found							
next4:	CJNE	A,#"=", next5					;#KIEM TRA TOAN TU =
		CLR		DIF								;#XOA BIT VAO TOAN HANG
		CLR		OIF								;#XAO BIT VAO TAON TU
		SETB	AIF								;#BAT CO VAO 
		RET										
next5:	SETB	DIF								;#BAT CO VAO TAN TU (NHAP TAON TU)
		CLR		OIF								;#XOA CO TOAN HANG
		CLR		AIF								;#KHONG PHAI DAU =
		RET										
found:	CLR		DIF								
		SETB	OIF								;#BAT CO TOAN TU
		CLR		AIF								
		RET										
;---------------------------DOC BAN PHIM-----------------------------------------#!		
readKey:
		MOV 	P1,#0FFH						;#P1 LAM PORT INPUT
K1: 	MOV 	P3,#0                           ;#CHO CA HANG SET = 0(NOI DAT)
		MOV 	A,P1							;#DOC TAT CA COT
		ANL 	A,#00001111B					
		CJNE 	A,#00001111B,K1                 ;#DOC
K2: 	LCALL 	SDELAY                          ;#!CHONG DOI
		MOV 	A,P1                            ;#XEM CO PHIM NAO DC NHAN KO
		ANL 	A,#00001111B                   
		CJNE 	A,#00001111B,OVER               ;#BAT DAU NHAN PHIM 
		SJMP 	K2                              ;#KIEM TRA CO BI DOI KHONG
OVER: 	LCALL 	SDELAY                          
		MOV 	A,P1                           
		ANL 	A,#00001111B                    
		CJNE 	A,#00001111B,OVER1              ;#BAT DAU NHAN
		SJMP 	K2                            	;#KIEM TRA
OVER1: 	MOV 	P3,#11111110B                 	;#ROW 0
		MOV 	A,P1                            
		ANL 	A,#00001111B                    
		CJNE 	A,#00001111B,ROW_0              
		MOV 	P3,#11111101B                   ;#ROW 1
		MOV 	A,P1                            
		ANL 	A,#00001111B                   
		CJNE 	A,#00001111B,ROW_1              
		MOV 	P3,#11111011B                   ;#ROW 2
		MOV 	A,P1                           
		ANL 	A,#00001111B                    
		CJNE 	A,#00001111B,ROW_2             
		MOV 	P3,#11110111B                   ;#ROW 3
		MOV 	A,P1                            
		ANL 	A,#00001111B                   
		CJNE 	A,#00001111B,ROW_3              
		LJMP 	K2                              ;#KIEM TRA LAN CUOI
ROW_0: 	MOV 	DPTR,#KCODE0                    ;#LAY MA TU ROW 0
		SJMP 	FIND                            
ROW_1: 	MOV 	DPTR,#KCODE1                    ;#LAY MA TU HANG 1
		SJMP 	FIND                           
ROW_2: 	MOV 	DPTR,#KCODE2                   
		SJMP 	FIND                            
ROW_3: 	MOV 	DPTR,#KCODE3                    ;#ROW 3
FIND: 	RRC 	A                               ;#LAY NEY BIT CY LA BIT THAP
		JNC 	MATCH                           ;#NEU BANG  0 THI LAY MA
		INC 	DPTR                            ;#TANG CHP LAN TIEP
		SJMP 	FIND                            ;#TIM	
MATCH: 	CLR 	A                               ;#A=0
		MOVC 	A,@A+DPTR                       ;#LAY MA ASC II
		RET										
;--------------------------------------------------------------------------------------------------#!
ERRFUN:	ACALL 	CLS								;#XOA MAN HINH
		MOV 	DPTR,#ERRMSG					;# GUI MA VAO DPTR
E1: 	CLR 	A								;# XOA ACC
		MOVC 	A,@A+DPTR						;#LAY MA 
		ACALL 	DATAWRT							;#IN RA MAN HINH					
		ACALL 	SDELAY												
		INC 	DPTR							;#TANG DPTR CHO LAN LAY TIEP THEO
		JZ 		E2								;#NHAY KHI ACC = 0
		SJMP 	E1								
E2:		ACALL	LDELAY							
		ACALL	CLS								
		RET										
;--------------------------------------------------------------------------------------------------#!
COMMWRT:										;#GUI MA CHO LCD (COMMAND WRITE)						
		MOV 	P2,A 							;#
		CLR 	P0.0 							;#RS=0 
		CLR 	P0.1 							;#R/W=0 
		SETB 	P0.2 							;#E=1 CHO XUNG CAO
		ACALL 	SDELAY 							
		CLR 	P0.2 							;#E=0 
		RET										
;--------------------------------------------------------------------------------------------------#!
DATAWRT:										;#HIEN THI LEN LCD
		MOV 	P2,A 							
		SETB 	P0.0 							;#RS=1 
		CLR 	P0.1 							;#R/W=0
		SETB 	P0.2 							;#E=1 CHO XUNG CAO 
		ACALL 	SDELAY 							;#GIU MAN HINH KET QUA TRONG 20 MS
		CLR 	P0.2 							
		RET										
;--------------------------------------------------------------------------------------------------#!
CLS:											;#CLEAR SCREEN
		MOV 	A,#01H							
		ACALL 	COMMWRT							;#GUI MA SANG LCD 
		RET										
;--------------------------------------------------------------------------------------------------#!
SDELAY:											;#DEALY 20MS
		MOV 	R0,#50							
S11:	MOV 	R1,#255							
S21:	DJNZ 	R1,S21										   			       
		DJNZ 	R0,S11							
		RET										
;--------------------------------------------------------------------------------------------------#!		
LDELAY:											;#DELAY 7*190*255
		MOV		R0,#7							
L33:	MOV		R1,#190							
L22:	MOV		R2,#255							
L11:	DJNZ	R2,L11							
		DJNZ	R1,L22							
		DJNZ	R0,L33							
		RET										
;--------------------------------------------------------------------------------------------------#!
;--------------------------------------------------------------------------------------------------#!

		ORG		300H
COMM: 	DB 		38H,0FH,01H,06H,80H,0
;-------CAC HANG CUA KEYPAD		
KCODE0: DB 		"7","8","9","/" 				
KCODE1: DB 		"4","5","6","*" 				
KCODE2: DB 		"1","2","3","-" 				
KCODE3: DB 		0,"0","=","+" 		 ; SO 0 LA NUT ON/C KHONG DUNG TOI			
;-------BAO LOI KHI NHAP SAI
ERRMSG:	DB		"ERROR!!",0
		END
