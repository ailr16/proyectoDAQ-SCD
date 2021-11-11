;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F877A. This file contains the basic code              *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F877A.INC                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _XT_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.






;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D		; variable used for context saving 
status_temp	EQU	0x7E		; variable used for context saving
pclath_temp	EQU	0x7F		; variable used for context saving			






;**********************************************************************
	ORG     0x000             ; processor reset vector

	nop			  ; nop required for icd
  	goto    main              ; go to beginning of program


	ORG     0x004             ; interrupt vector location

	movwf   w_temp            ; save off current W register contents
	movf	STATUS,w          ; move status register into W register
	movwf	status_temp       ; save off contents of STATUS register
	movf	PCLATH,w	  ; move pclath register into w register
	movwf	pclath_temp	  ; save off contents of PCLATH register

; isr code can go here or be located as a call subroutine elsewhere

	movf	pclath_temp,w	  ; retrieve copy of PCLATH register
	movwf	PCLATH		  ; restore pre-isr PCLATH register contents
	movf    status_temp,w     ; retrieve copy of STATUS register
	movwf	STATUS            ; restore pre-isr STATUS register contents
	swapf   w_temp,f
	swapf   w_temp,w          ; restore pre-isr W register contents
	retfie                    ; return from interrupt

resH	equ		0x21
resL	equ		0x22

main
		bcf		STATUS, RP0			;Banco 0
		bcf		STATUS, RP1
		clrf	PORTA
		movlw	b'01000001'
		movwf	ADCON0				;Habilitar A0
		
		bsf		STATUS, RP0			;Banco 1
		movlw	b'00000001'			
		movwf	TRISA				;RA0 y RA1 entradas
		movlw 	0x00
		movwf	TRISB				;Puerto B salida
		movwf	TRISD				;Puerto D salida
		movlw	b'01001110'
		movwf	ADCON1				;Vref, E/S digitales/analogicas

bucle:
		bcf		STATUS, RP0
		movlw	0xF0
		movwf	PORTB
;		bcf		STATUS, RP0
;		bsf		ADCON0, 2
;a1:		btfss	ADCON0, 2
;		goto 	a1
;		movf	ADRESH, W
;		movwf	resH
;		movwf	PORTB
;
;		bsf		STATUS, RP0
;		movf	ADRESL, W
;
;		bcf		STATUS, RP0
;		movwf	resL
;		movwf	PORTD
;		movf	resL, W
;		andlw	0xC0
;		movwf	resL
;		movwf	PORTD
;		goto	bucle
		goto	bucle
; remaining code goes here










	END                       ; directive 'end of program'

