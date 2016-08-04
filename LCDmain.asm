
    #include "configurationBits.h"
    #define portsAsDigital 0x0F ;  Entradas digitales
    #define DATAB LATB ; D0-D7
    #define RS LATA,0
    #define E  LATA,1
    #define CLEARSCREEN 0x01
    #define DISPLAYON 0x0C
    #define DISPLAYOFF 0x0A
    #define FIRSTLINE 0x80
    #define SECONDLINE 0x00
    #define THIRDLINE 0x00
    #define FOURTHLINE 0x00
    #define MODE8BIT5x8M 0x38
     
    CBLOCK 0x60
    delayvar:3
    ENDC
    
    org 0 ;initial vector
;**********************************************************************MAIN FLOW    
main:
    call initialconfig
    call setLCDup
    call LCDCover
    btg LATA,2
    goto $
    bra main
;****************************************************************INITIAL MESSAGE    
LCDCover:   
    movlw low msg1
    movwf TBLPTRL
    movlw high msg1
    movwf TBLPTRH
    movlw upper msg1
    movwf TBLPTRU

LCD1: tblrd*+
    movf TABLAT,W
    btfsc STATUS,Z
    return
    call pdata 
    bra LCD1
    
;****************************************************************LCD SUBRUOTINES     
enablepulse: ;-------------------------------------For Latching data in the LCD 
    bsf E ;Rising Edge
    movlw 0x01
    call delayW0ms
    bcf E ;Falling Edge
    return 
    
command:;---------------------------------------------------For execute commands
    movwf DATAB
    bcf RS
    call enablepulse ;To latch data 
    movlw 0x02 
    call delayW0ms ;Delay for 20ms    
    return

pdata:;----------------------------------------------------For print data in LCD
    movwf DATAB
    bsf RS
    call enablepulse ;To latch data 
    movlw 0x02 
    call delayW0ms ;Delay for 20ms  
    return

setLCDup:;-------------------------------------------------For Initializate LCD    
    movlw 0x02
    call delayW0ms ; Wait 10ms for Start up of LCD
    movlw low ctrlcd ;To load the address 0x000100
    movwf TBLPTRL
    movlw high ctrlcd
    movwf TBLPTRH
    movlw upper ctrlcd
    movwf TBLPTRU

set1:    TBLRD*+
    movf TABLAT,W   
    btfsc  STATUS,Z 
    return
    call command ;execute the command
    bra set1

    
;**************************************SET UP AND INITIALIZATION MCU SUBROUTINES     
initialconfig: 
    movlw portsAsDigital
    movwf ADCON1 ;Ports as digital instead of analogic
    clrf TRISA  ;PortA as digital output
    clrf LATA  ;Initializing PortA = '0'
    clrf TRISB ;PortB as digital output 
    clrf LATB ;Initializing PortB 
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
    org 0x100
ctrlcd:  db  MODE8BIT5x8M,DISPLAYON,CLEARSCREEN,FIRSTLINE,0  ;Comandos a ejecutar 
msg1:    da "BIENVENIDOS         ",0			    
msg2:    da "USTED HA INGRESADO U",0    
msg3:    da "GRACIAS             ",0
msg4:    da "JULIAN SANTOS SA    ",0    
    
    END ;End