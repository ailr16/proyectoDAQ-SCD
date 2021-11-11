;******************************************************************************
;   This file is a basic template for assembly code for a PIC18F4550. Copy    *
;   this file into your project directory and modify or add to it as needed.  *
;                                                                             *
;   The PIC18FXXXX architecture allows two interrupt configurations. This     *
;   template code is written for priority interrupt levels and the IPEN bit   *
;   in the RCON register must be set to enable priority levels. If IPEN is    *
;   left in its default zero state, only the interrupt vector at 0x008 will   *
;   be used and the WREG_TEMP, BSR_TEMP and STATUS_TEMP variables will not    *
;   be needed.                                                                *
;                                                                             *
;   Refer to the MPASM User's Guide for additional information on the         *
;   features of the assembler.                                                *
;                                                                             *
;   Refer to the PIC18FXX50/XX55 Data Sheet for additional                    *
;   information on the architecture and instruction set.                      *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Filename:    Plantilla                                              *
;    Date:        18/12/19                                                    *
;    File Version: 1.0                                                        *
;                                                                             *
;    Author:   Jose Luis Bravo                             *
;    Company:   Acad. Computación ICE                             *
;                                                                             * 
;******************************************************************************
;                                                                             *
;    Files required: P18F4550.INC                                             *
;                                                                             *
;******************************************************************************

	LIST P=18F4550, F=INHX32	;directive to define processor
	#include <P18F4550.INC>		;processor specific variable definitions

;******************************************************************************
;Configuration bits

	CONFIG PLLDIV   = 5         ;(20 MHz crystal on PICDEM FS USB board)
    CONFIG CPUDIV   = OSC1_PLL2	
    CONFIG USBDIV   = 2         ;Clock source from 96MHz PLL/2
    CONFIG FOSC     = HSPLL_HS
    CONFIG FCMEN    = OFF
    CONFIG IESO     = OFF
    CONFIG PWRT     = OFF
    CONFIG BOR      = ON
    CONFIG BORV     = 3
    CONFIG VREGEN   = ON		;USB Voltage Regulator
    config WDT      = OFF
    config WDTPS    = 32768
    config MCLRE    = ON
    config LPT1OSC  = OFF
    config PBADEN   = OFF		;NOTE: modifying this value here won't have an effect
        							  ;on the application.  See the top of the main() function.
        							  ;By default the RB4 I/O pin is used to detect if the
        							  ;firmware should enter the bootloader or the main application
        							  ;firmware after a reset.  In order to do this, it needs to
        							  ;configure RB4 as a digital input, thereby changing it from
        							  ;the reset value according to this configuration bit.
    config CCP2MX   = ON
    config STVREN   = ON
    config LVP      = OFF
    config ICPRT    = OFF       ; Dedicated In-Circuit Debug/Programming
    config XINST    = OFF       ; Extended Instruction Set
    config CP0      = OFF
    config CP1      = OFF
    config CP2      = OFF
    config CP3      = OFF
    config CPB      = OFF
    config CPD      = OFF
    config WRT0     = OFF
    config WRT1     = OFF
    config WRT2     = OFF
    config WRT3     = OFF
    config WRTB     = OFF       ; Boot Block Write Protection
    config WRTC     = OFF
    config WRTD     = OFF
    config EBTR0    = OFF
    config EBTR1    = OFF
    config EBTR2    = OFF
    config EBTR3    = OFF
    config EBTRB    = OFF
;******************************************************************************
; DEFINICION DE VARIABLES
; 


;******************************************************************************
; Reset vector
; Esta sección se ejecutara cuando ocurra un RESET.

RESET_VECTOR	ORG		0

		goto	INICIO		;go to start of main code

;******************************************************************************

;******************************************************************************
;Start of main program
; el PROGRAMA PRINCIPAL inicia aqui

	ORG		0x1000
INICIO				; *** main code goes here **
		movlw	b'00000011'			
		movwf	TRISA				;RA0 y RA1 entradas
		movlw 	0x00
		movwf	TRISB				;Puerto B salida
		movwf	TRISD				;Puerto D salida

		movlw	0x01
		movwf	ADCON0				;Habilitar A0
		movlw	b'00001110'
		movwf	ADCON1				;Vref, E/S digitales/analogicas
		movlw	b'00010101'
		movwf	ADCON2				;Tiempo muestreo

		movlw	b'11000000'
		movwf	TRISC				;RC6 y RC7 entradas
		clrf	SPBRGH				;Limpiar Byte H Baudrate Generator
		movlw 	0x4D				
		movwf	SPBRG				;9600baud a 48MHz
		movlw	b'00100000'
		movwf	TXSTA				;Habilitar transmisiones
		movlw	0x90
		movwf	RCSTA
		bcf		BAUDCON, TXCKP		;Señal no invertida
		bcf		PIE1, TXIE			;Deshabilitar interrupcion de Tx
		bsf		PORTC, 2

resH	equ		0x20				;Guardar byte H del resultado ADC
resL	equ		0x21				;Guardar byte L del resultado ADC
rxres	equ		0x22				;Guardar resultado de recepcion
R0		equ		0x10
R1		equ		0x11
R2		equ		0x12

main:
		bsf		ADCON0, 1
a1:		btfss	ADCON0, 1
		goto 	a1
		movff	ADRESH, resH
		movff	ADRESL, resL
		movff	resH, PORTB
		movf	resL, W
		andlw	0xC0
		movwf	resL
		movwf	PORTD
		btfss	PIR1, RCIF		;Comprueba si se recibio un byte
		goto	main
		clrf	rxres
		movf	RCREG, W		;Guarda el byte recibido (limpia RCIF)
		movwf	rxres
		btfss	rxres, 0		;Condicion para transmitir
		goto	main
		bcf		PORTC, 2
		movff	resH, TXREG		;Transmite primer byte
tx1:	btfss	TXSTA, TRMT		;Verifica que el registro
		goto 	tx1				;esta vacio
		movff	resL, TXREG		;Transmite segundo byte
tx2:	btfss	TXSTA, TRMT
		goto 	tx2

		movlw	0x07
		movwf	R0
		movlw	0xFF
ETQ2:	movwf	R1
ETQ3:	movwf	R2
ETQ4:	decf	R2,1
		bnz		ETQ4
		decf 	R1,1
		bnz		ETQ3
		decf	R0,1
		bnz		ETQ2
	
		bsf		PORTC, 2
		goto 	main
					; end of main	
;******************************************************************************
; Espacio para subrutinas
;******************************************************************************
		
;******************************************************************************
;Fin del programa
	END
