#include "io430.h"

unsigned char i = 0;
unsigned char resADCH = 0;
unsigned char resADCL = 0;
unsigned short resADC = 0;
unsigned char rx_byte = 0;

unsigned char obtenByteH(unsigned short A);

int main( void ){
  WDTCTL = WDTPW + WDTHOLD;     // Stop watchdog timer to prevent time out reset
  BCSCTL1 = CALBC1_1MHZ;        //DCO Trabajando a 1MHz aprox.
  DCOCTL  = CALDCO_1MHZ;
  
  P1SEL  = BIT1 + BIT2 ;               // Configurando las terminales P1.1 y P1.2
  P1SEL2 = BIT1 + BIT2 ;               // como parte del sistema UART
  P1DIR = 0x0;                       // P1.1 <-- RXD
  //P1DIR |= BIT2;                        // P1.2 --> TXD
  P1DIR |= BIT6;                        //P1.6 salida
  P1DIR |= BIT7;                        //P1.7 salida
  UCA0CTL1 |= UCSSEL_2;                 // SMCLK
  
  ADC10CTL0 = SREF_0 + ADC10SHT_2 + MSC + ADC10ON + ADC10IE;
  ADC10CTL1 = INCH_5 + CONSEQ_0;
  ADC10DTC0 = ADC10TB;
  ADC10AE0 = BIT5;                      //Entrada analogica P1.5
    
  //--------9600baud----------------------------------------------
  UCA0BR0 = 104;                       // 1MHz 9600
  UCA0BR1 = 0;                         // 1MHz 9600
  UCA0MCTL = UCBRS0;                   // Modulation UCBRSx = 1
  IE2 |= UCA0RXIE;                          // Enable USCI_A0 RX interrupt
  //-------------------------------------------------------------
  
  UCA0CTL1 &= ~UCSWRST;                 // **Initialize USCI state machine**
  
  __bis_SR_register(GIE);    
  
  while(1){
    ADC10CTL0 |= ENC+ADC10SC;           //Habilita la conversion A-D
    
    resADCH = obtenByteH(resADC);
    resADCL = resADC;
    
    if(rx_byte == 0x01){
      UCA0TXBUF = resADCH;
      while(!(IFG2&UCA0TXIFG));     //Imprime byte Alto
      UCA0TXBUF = resADCL;
      while(!(IFG2&UCA0TXIFG));     //Imprime byte bajo
      rx_byte = 0;
    }
    else;
    __delay_cycles(10000);       //Retardo de 10ms
  }
}

#pragma vector = ADC10_VECTOR
__interrupt void ADC10RESULTADO(void){
  resADC = ADC10MEM;            //Guarda el resultado de la conversion A-D
  __delay_cycles(10000);        
}

#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCI0RX_ISR(void){
  while (!(IFG2&UCA0TXIFG));                // USCI_A0 TX buffer ready?
  rx_byte = UCA0RXBUF;                    // TX -> RXed character
}

unsigned char obtenByteH(unsigned short A){
  unsigned char byteH = 0;
  A = A & 0x0300;
  A = A >> 8;
  byteH = A;
  return byteH;
}