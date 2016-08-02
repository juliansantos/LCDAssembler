
    #include "configurationBits.h"
    #define portsAsDigital 0x0F ;  Entradas digitales
    #define apagar bsf TRISA,0 bsf TRISB,0
    CBLOCK 0x60
    delayvar:3
    ENDC
    
    org 0
    apagar
main:
    call initialconfig
HERE    btg LATA,1
    movlw 0xA
    call delayW0ms ;delay of 100ms
    bra HERE
    
initialconfig:
    movlw portsAsDigital
    movwf ADCON1 ;Ports as digital instead of analogic
    clrf TRISA  ;PortA as digital output
    clrf LATA  ;Initializing PortA = '0'
    return 
    
delay10ms:  ;8MHz frecuency oscillator
    movlw d'129'  ;A Value
    movwf delayvar+1
d0:   movlw d'50' ;B Value
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
    
    END 