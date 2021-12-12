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
  DDRB = B00111111;
  pinMode(13, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(A0, INPUT);
  digitalWrite(3, LOW);
  Serial.begin(9600);
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
  digitalWrite(1, HIGH);
  delay(1);
  if(Serial.available()){
    if(Serial.read() == '*'){
      res_adc_L = res_adc_aux2;
      res_adc_aux2 = res_adc_aux2&mask_H;
      res_adc_aux2 = res_adc_aux2>>8;
      res_adc_H = res_adc_aux2;
      digitalWrite(3, LOW);
      Serial.write(res_adc_H);
      Serial.write(res_adc_L);
      digitalWrite(3, HIGH);                                                                                                   
    }
  }
}
