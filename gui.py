import tkinter
import tkinter.font as tkFont
import serial

ser = serial.Serial(port='COM4', baudrate=9600, timeout = 1)

ventana = tkinter.Tk()
ventana.title("App")

byte_d1H = ''
byte_d1L = ''
byte_d2 = ''

def salir():
    ser.close()
    exit()
  
ventana.geometry("800x480")
ventana.configure(bg = '#0F82C8')

fondoLabel = '#0F82C8'

label_d1 = tkinter.Label(ventana, text = "Dispositivo 1", bg = fondoLabel, font=tkFont.Font(family="Verdana", size=28))
label_d1.place(relx = 0.07, rely = 0.1)

label_d1_ad = tkinter.Label(ventana, text = "Direccion = 0x01", bg = fondoLabel, font=tkFont.Font(family="Verdana", size=16))
label_d1_ad.place(relx = 0.07, rely = 0.2)

label_d1_muestraH = tkinter.Label(ventana, text = "valor", bg = fondoLabel, font=tkFont.Font(family="Verdana", size=14))
label_d1_muestraH.place(relx = 0.24, rely = 0.26)

label_d1_muestraL = tkinter.Label(ventana, text = "valor", bg = fondoLabel, font=tkFont.Font(family="Verdana", size=14))
label_d1_muestraL.place(relx = 0.4, rely = 0.26)

def solicita_transmision_1():
    ser.write(b'\x01')
    byte_d1H = ser.read()
    byte_d1L = ser.read()
    label_d1_muestraL["text"] = format(int.from_bytes(byte_d1L, "big"),'08b')
    label_d1_muestraH["text"] = format(int.from_bytes(byte_d1H, "big"),'08b')


boton_muestra_d1 = tkinter.Button(ventana, text = "Solicita una muestra", command = solicita_transmision_1)
boton_muestra_d1.place(relx = 0.07, rely = 0.27)

boton_salir = tkinter.Button(ventana, text = "Salir", command = salir)
boton_salir.place(relx = 0.18, rely = 0.8)

ventana.mainloop()


