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
		movlw	0x03			
		movwf	TRISA				;RA0 y RA1 entradas
		movlw 	0x00
		movwf	TRISB				;Puerto B salida
		movwf	TRISD				;Puerto D salida

		movlw	0x01
		movwf	ADCON0				;Habilitar A0
		movlw	0x0E
		movwf	ADCON1				;Vref, E/S digitales/analogicas
		movlw	0x15
		movwf	ADCON2				;Tiempo muestreo

		movlw	0xC0
		movwf	TRISC				;RC6 y RC7 entradas
		clrf	SPBRGH				;Limpiar Byte H Baudrate Generator
		movlw 	0x4E				
		movwf	SPBRG				;9600baud a 48MHz
		movlw	0x20
		movwf	TXSTA				;Habilitar transmisiones
		movlw	0x90
		movwf	RCSTA
		bcf		BAUDCON, TXCKP		;Señal no invertida
		bcf		PIE1, TXIE			;Deshabilitar interrupcion de Tx
		bcf		PORTC, 2

resH	equ		0x20				;Para guardar byte H del resultado ADC
resL	equ		0x21				;Para guardar byte L del resultado ADC
rxres	equ		0x22				;Para guardar resultado de recepcion

main:
		bsf		ADCON0, 1			;Inicia conversion AD
a1:		btfss	ADCON0, 1			;Si la conversion no ha terminado
		goto 	a1					;Volver a comprobar
		movff	ADRESH, resH		;Guardar byte H del resultado ADC
		movff	ADRESL, resL		;Guardar byte L del resultado ADC
		movff	resH, PORTB			;Enviar byte H ADC al puerto B
		movf	resL, W
		andlw	0xC0				;Enmascarar bits del byte L ADC
		movwf	resL
		movwf	PORTD				;Enviar byte L ADC al puerto D
		btfss	PIR1, RCIF			;Comprueba si se recibio un byte
		goto	main
		clrf	rxres				;Limpiar registro de recepcion
		movf	RCREG, W			;Guarda el byte recibido (limpia RCIF)
		movwf	rxres
		btfss	rxres, 0			;Condicion para transmitir
		goto	main
		bsf		PORTC, 2			;Bit 2 puerto C estado alto
		movff	resH, TXREG			;Transmite primer byte
tx1:	btfss	TXSTA, TRMT			;Verifica que el registro
		goto 	tx1					;esta vacio
		movff	resL, TXREG			;Transmite segundo byte
tx2:	btfss	TXSTA, TRMT
		goto 	tx2
		bcf		PORTC, 2			;Bit 2 puerto C estado bajo
		goto 	main
					; end of main	
;******************************************************************************
; Espacio para subrutinas
;******************************************************************************
		
;******************************************************************************
;Fin del programa
	END
