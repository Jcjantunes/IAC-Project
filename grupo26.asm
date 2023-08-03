; **********************************************************************
; **********************************************************************
; 													********************
;	 PRIMEIRA ENTREGA PROJETO TETRIS INVADERS	    ********************
; 													********************
; **********************************************************************
;													
; GRUPO 26
; 		ANDRE PATRICIO, 87631
; 		CAROLINA CARREIRA, 87641					
; 		JOAO ANTUNES, 87668
;													
; **********************************************************************
; * Constantes
; **********************************************************************
	
LINHA   EQU 8       ; Posicao do bit correspondente à linha (4) a testar
BUFFERL EQU 0100H   ; Endereco de memoria onde se guarda a linha
PIN  	EQU 0E000H  ; Endereco de entrada do teclado
POUT1 	EQU 0A000H	; Displays
POUT2 	EQU 0C000H  ; Endereco de escrita do teclado

; **********************************************************************
; * Codigo
; **********************************************************************.

PLACE 1000H
pilha:
	TABLE 0100H
fim_pilha:

ultima_tecla_pressa: WORD 0H

PLACE 0000H
início:		

; ******************************************************************
; 			inicializações gerais
; ******************************************************************

	MOV  SP, fim_pilha
    MOV  R1, LINHA    ; testar a linha 4 
    MOV  R2, PIN      ; R2 com o endereço de entrada do teclado
	MOV	 R7, POUT1	  ; endeco do display
	MOV  R8, POUT2    ; R8 com o enderenço de saida do teclado

; ******************************************************************
; 			corpo principal do programa
; ******************************************************************

ciclo:
	CALL teclado
	CALL display
	JMP ciclo
	
; ******************************************************************
; 							ROTINAS
; ******************************************************************
;

;   INPUT - R1, linha a analizar
;	Rotina que deteta a linha e a coluna da tecla premida
; ******************************************************************
	
teclado:
    MOVB [R8],R1        ; escrever no periferico no teclado
    MOVB R3, [R2]       ; le coluna
    AND  R3, R3  	    ; ver se alguma tecla foi pressa
	JZ 	 muda           ; nenhuma tecla pressa vai para ciclo para mudar de linha
	MOV  R4, R3         ; guarda coluna
	MOV  R5, BUFFERL
	MOVB [R5], R1		; guardar linha
	JMP  muda     	    
muda:
	SHR R1, 1           ; vai ver a proxima linha
	AND R1,R1			; se a proxima linha for zero
	JNZ teclado		    ; se a proxima linha nao for zero continua a analizar       
	MOV R1, LINHA
	RET

	
; *******************************************************************
; 	INPUT - R4, coluna; BUFFERL, linha
; 	Rotina que calcula e manda o valor da tecla clicada para o display
; *******************************************************************

display:
	PUSH R1					
	PUSH R2
	CMP R4, 0000          	; saber se a tecla foi premida
	JNZ calc_tecla
	MOV R10, 0FFH			; escrever se nenhuma tecla foi pressa
	JMP escreve_display
	
; *****************************************
; 	Calcula o numero a representar no display
; *****************************************

calc_tecla:					
	CALL calcula_tecla  	; para saber a linha 0...3
	MOV R9, R11
	MOV R0,  BUFFERL
	MOVB R4, [R0]           ; para saber a coluna 0...3
	CALL calcula_tecla
	MOV R10, R11
	SHL R10, 2
	ADD R10, R9		    	; faz soma, e guarda no R10 o valor a mostrar no display
	
; ***************************************
;  	INPUT - R11, valor a escrever no display
; 	Escreve no display e guarda a ultima_tecla_pressa
; ***************************************

escreve_display:	
	MOV R2, ultima_tecla_pressa			
	MOV R11, [R2]			
	CMP R10, R11			; comparar o valor a escrever no display com ultima_tecla_pressa
	JZ sair					; se o for igual não escreve no display
	MOV [R2], R10			; escreve na ultima_tecla_pressa a tecla escrevera
	MOVB [R7], R10			; escreve no display
	JMP sair
	
sair:
	MOV R4, 0				; gera o registo que guarda a coluna
	POP R2
	POP R1
	RET

; ****************************
; 	INPUT - R4, uma linha ou coluna para calcular a posiçao
; 	Rotina que calcula a posiçao da linha ou coluna (0...3)
; ****************************

calcula_tecla:
	PUSH R1
	MOV  R1, 0             ; contador
cicloc:
	ADD R1, 1
	SHR R4, 1
	JNZ cicloc
	SUB R1, 1
	MOV R11, R1
	POP R1
	RET
	