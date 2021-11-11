short res_adc = 0;
short res_adc_aux = 0;
short res_adc_aux2 = 0;
unsigned char res_adc_PB = 0;
unsigned char res_adc_PD = 0;
unsigned char res_adc_H = 0;
unsigned char res_adc_L = 0;

short mask_PB = (B00000011*256) + B11110000;
short mask_PD = (B00000000*256) + B00001111;
short mask_H = (B00000011*256) + B00000000;

void setup() {
  Serial.begin(9600);
  DDRB = B00111111;
  DDRD = B11111000;
  pinMode(A0, INPUT);
}

void loop() {
  res_adc = analogRead(A0);
  res_adc_aux2 = res_adc;
  res_adc_aux = res_adc&mask_PB;
  res_adc_aux = res_adc_aux>>4;
  res_adc_PB = res_adc_aux;
  res_adc = res_adc&mask_PD;
  res_adc = res_adc<<4;
  res_adc_PD = res_adc;
  PORTD = res_adc_PD;
  PORTB = res_adc_PB;
  delay(1);
  if(Serial.available()){
    if(Serial.read() =='+'){
      res_adc_L = res_adc_aux2;
      res_adc_aux2 = res_adc_aux2&mask_H;
      res_adc_aux2 = res_adc_aux2>>8;
      res_adc_H = res_adc_aux2;
      Serial.write(res_adc_H);
      Serial.write(res_adc_L);
    }
  }
}
