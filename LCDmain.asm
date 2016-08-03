
    #include "configurationBits.h"
    #define portsAsDigital 0x0F ;  Entradas digitales
    #define RS LATA,0
    #define E  LATA,1
    #define CLEARSCREEN 0x01
    #define DISPLAYON 0x0C
    #define DISPLAYOFF 0x0A
    #define FIRSTLINE 0x80
    #define SECONDLINE 0x00
    #define THIRDLINE 0x00
    #define FOURTHLINE 0x00
    
    
    
    CBLOCK 0x60
    delayvar:3
    ENDC
    
    org 0 ;initial vector
;**********************************************************************MAIN FLOW    
main:
    call initialconfig
    
    bra main
    
;****************************************************************LCD SUBRUOTINES     
enablepulse: ;-------------------------------------For Latching data in the LCD 
    bsf E ;Rising Edge
    nop
    bcf E ;Falling Edge
    return 
    
comand:;---------------------------------------------------For execute commands
    movwf LATB
    bcf RS
    call enablepulse ;To latch data 
    movlw 0x02 
    call delayW0ms ;Delay for 20ms    
    return

pdata:;----------------------------------------------------For print data in LCD
    movwf LATB
    bsf RS
    call enablepulse ;To latch data 
    movlw 0x02 
    call delayW0ms ;Delay for 20ms  
    return

setLCDup:;-------------------------------------------------For Initializate LCD    
    
    return
    
;**************************************SET UP AND INITIALIZATION MCU SUBROUTINES     
initialconfig: 
    movlw portsAsDigital
    movwf ADCON1 ;Ports as digital instead of analogic
    clrf TRISA  ;PortA as digital output
    clrf LATA  ;Initializing PortA = '0'
    clrf TRISB ;PortC as digital output 
    clrf LATB ;Initializing PortC 
    return 

    
;***************************************************************DELAY SUBRUTINES   
delay10ms:  ;4MHz frecuency oscillator
    movlw d'84'  ;A Value
    movwf delayvar+1
d0:   movlw d'38' ;B Value
    movwf delayvar  
    nop
d1:  decfsz delayvar,F
    bra d1
    decfsz delayvar+1,F
    bra d0      
    return ;2+1+1+A[1+1+1+B+1+2B-2]+A+1+2A-2+2 => 5+A[5+3B]
    
delayW0ms: ;It is neccesary load a properly value in the acumulator before use this subrutine
    movwf delayvar+2
d2:    call delay10ms
    decfsz delayvar+2,F
    bra d2
    return
    
;********************************************************************DATA VECTOR
    org 0x60
ctrlcd:  db  DISPLAYON,CLEARSCREEN,FIRSTLINE,0,0   
msg1:    da "    BIENVENIDOS   ",0
msg2:    da " USTED HA INGRESADO UNA MONEDA "    
msg3:    da " GRACIAS"    
    
    
    
    END ;End