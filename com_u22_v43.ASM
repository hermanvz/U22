;VER 4.3
;nucleo para comunicar el kit U22 con un ordenador
;Herman Vásquez - U.S.M - 23/NOVIEMBRE/1999


                  ORG 0000H
                  MOV SP,#60H     ;Inicio de la pila

	          LJMP INICIO
;----------------------------------
;SERVICIOS:
;----------------------------------
       ASCDPTR: push 0e0h         ;direccion ingresada al DPTR
             	anl 30H,#0FH      ;
                mov a,30H         ;
                swap a            ;
                anl 31h,#0fh      ;
                orl a,31h         ;+
                mov dph,a         ;
                anl 32h,#0fh      ;
                mov a,32h         ;
                swap a            ;
                anl 33h,#0fh      ;
                orl a,33h         ;-
                mov dpl,a         ;
                pop 0e0h          ;
                ret               ;
;--------------------------------------
       HACMENS: mov r7,#0ffh      ; numero maximo de caracteres
                mov 04,#00        ;

         mass : call resep        ; in ascii
                cjne a,#08,noo    ; 
                sjmp borra        ; 
         noo  : cjne a,#0dH,otras ; 
                sjmp term         ; 
         borra: call txa          ;
                mov a,#20h        ;
                call txa          ;
                mov a,#08
                call txa
                cjne r4,#00,decr  ;
                sjmp mass         ;
          decr: dec r4            ;
                mov a,dpl         ;
                dec a             ;
                mov dpl,a         ;
                sjmp mass         ;
        otras : inc 04h           ;
                movx @dptr,a      ;
                call txa          ;
                djnz r7,sigue     ;
                sjmp term         ;
        sigue : inc dptr          ;
                sjmp mass         ;
        term  : ret               ;

;--------------------------------------

       ALMCFIN: mov a,dpl         ;
                call morf         ;
                mov 33h,a         ;
                mov a,dpl         ;
                swap a            ;
                call morf         ;
                mov 32h,a         ;
                mov a,dph         ;
                call morf
                mov 31h,a
                mov a,dph
                swap a            ;
                call morf         ;
                mov 30h,a         ;
                ret               ;
;----------------------------------
          MORF: anl a,#0fh        ;
                call ranalfa      ;
                call rango        ;
                call conv         ;
                ret               ;
;----------------------------------
       RANALFA: mov r0,#0fh       ;
                mov 09,#0ah       ;
                ret               ;
;----------------------------------
          CONV: cjne r2,#00,alfa  ;
                add a,#30h        ;
                ret               ;
        alfa  : add a,#37h        ;
                ret               ;
;----------------------------------
        NCARAC: mov A,04          ;
                call morf         ;
                mov 34h,a         ;
                mov a,04          ;
                swap a            ;
                call morf         ;
                call txa          ;
                mov a,34h         ;
                call txa          ;
                ret               ;
;----------------------------------
      DIRECFIN: mov a,30h         ;
                call txa          ;
                mov a,31h         ;
                call txa          ;
                mov a,32h         ;
                call txa          ;
                mov a,33h         ;
                call txa          ;
                ret               ;
;----------------------------------
          BEEP: push 0e0h         ;
                mov a,#07h        ;
                call txa          ;
                pop 0e0h          ;
                ret               ;
;----------------------------------
           TXA:                   ; Tx
        intx  : jbc ti,initx      ;
                sjmp intx         ;
        initx : mov sbuf,a        ;
                ret               ;
;----------------------------------
         RESEP:                   ;espera que llegue un dato
                setb ren          ;
        rep   : jbc ri,dat        ;
                sjmp rep          ;
        dat   : mov a,sbuf        ;
                clr ren           ;
                ret               ;
;----------------------------------
      TRANSTEX:			  ;	
                push 0e0h         ;Tx text
        trans : movx a,@dptr      ;
                cjne a,#40h,sig   ;
                pop 0e0h          ;
                ret               ;
        sig   : jbc ti,itx        ;
                sjmp sig          ;
        itx   : mov sbuf,a        ;
                inc dptr          ;
                sjmp trans        ;
;----------------------------------
         RANGO:                   ;Rutina usada para ver si un dato
                cjne a,00,esmay   ;esta en un rango determinado, este rango
                sjmp si           ;lo determinan dos limites, inferior R9 
        esmay : jnc no            ;superior R0
                                  ;
                cjne a,09,esmen   ;
                sjmp si           ;
        esmen : jc no             ;
           si : mov r2,#1         ;
                ret
           no : mov r2,#0         ;
                ret               ;
;----------------------------------
           TEXT:push dph          ;Envia a pantalla texto 
                push dpl          ;
                mov dptr,#texto0  ;
                call transtex     ;
                pop dpl           ;
                pop dph           ;
                ret               ;
;----------------------------------
     RHEXASC:                     ;Verifica dato ingresado
        otro  : CALL RESEP        ;es ascci en HEX
                MOV R6,#00        ;
                CJNE A,#08,RAN    ;si es entre 0 y f o F entrega dato
                CJNE R7,#00,BACK  ;no es emite beep y pide otro 
                MOV R6,#01        ;
                RET               ;
          BACK: CALL TXA          ;
                MOV R6,#01        ;
                RET               ;

           RAN:                   ;
                mov r0,#39h       ;
                mov 09,#30h       ;
                call rango        ;
                cjne r2,#00,xxx   ;

                mov r0,#46h       ;
                mov 09,#41h       ;
                call rango        ;
                cjne r2,#00,sig22 ;
                                  ;
                mov r0,#66h       ;
                mov 09,#61h       ;
                call rango        ;
                cjne r2,#00,sig57 ;
                                  ;
                call beep         ;
                sjmp otro         ;
                                  ;
          xxx : MOV R7,#01        ;
                call txa          ;
                ret               ;
        sig22 : MOV R7,#01        ;
                call txa          ;
                subb a,#37h       ;
                ret               ;
        sig57 : MOV R7,#01        ;
                call txa          ;
                subb a,#57h       ;
                ret               ;
;-------------------------------------------
      RANCONTR:                   ;
                push 00           ;
                push 09           ;
                mov r0,#1bh       ;
                mov 09,#00h       ;
                call rango        ;
                pop 09            ;
                pop 00            ;
                ret               ;
;----------------------------------
         INGDIR:                  ;In direccion de inicio
          INI1: MOV R7,#00        ;
                call rhexasc      ;
                CJNE R6,#00,INI1  ;
                mov 30h,a         ; byte mas significativo
          INI2: call rhexasc      ;
                CJNE R6,#00,INI1  ;
                mov 31h,a         ; 
          INI3: call rhexasc      ;
                CJNE R6,#00,INI2  ;
                mov 32h,a         ; 
          INI4: call rhexasc      ;
                CJNE R6,#00,INI3  ;
                mov 33h,a         ; byte menos significativo
                                  ;
            NI: CALL RESEP        ;
                CJNE A,#0DH,NI2   ;
                JMP ALRET         ;
           NI2: CJNE A,#08,NI     ;
                CALL TXA          ;
                JMP INI4          ;
         ALRET: ret               ;
;--------------------------------------------
        INGFIN:                   ;Direccion final
         INIX1: MOV R7,#00        ;
                CALL RHEXASC      ;
                CJNE R6,#00,INIX1 ;
                MOV 35h,a         ; byte mas significativo
         INIX2: call rhexasc      ;
                CJNE R6,#00,INIX1 ;
                mov 36h,a         ;
         INIX3: call rhexasc      ;
                CJNE R6,#00,INIX2 ;
                mov 37h,a         ;
         INIX4: call rhexasc      ;
                CJNE R6,#00,INIX3 ;
                mov 38h,a         ; byte menos significativo
                                  ;
           NIX: CALL RESEP        ;
                CJNE A,#0DH,NIX2  ;
                JMP CONTX         ;
          NIX2: CJNE A,#08,NIX    ;
                CALL TXA          ;
                JMP INIX4         ;
                                  ;
         CONTX: anl 35h,#0fh      ;
                mov a,35h         ;
                swap a            ;
                anl 36h,#0fh      ;
                orl a,36h         ;
                mov 35h,a         ;mas
                anl 37h,#0fh      ;
                mov a,37h         ;
                swap a            ;
                anl 38h,#0fh      ;
                orl a,38h         ;
                mov 36h,a         ;menos
                ret               ;
;--------------------------------------------
          DATS: call rhexasc2     ;rutina que que trabaja junto con rhexasc2
                anl a,#0fh        ;
                swap a            ;
                mov 03,a          ;
                call rhexasc2     ;
                anl a,#0fH        ;
                orl a,03          ;
                ret
;-------------------------------------------
      RHEXASC2:                   ; ranhexac que no envia el codigo entrado de vuelta al pc
        otro2 : CALL RESEP        ; 
                                  ; 
                                  ;
          RAN2: mov r0,#39h       ;limite sup
                mov 09,#30h       ;limite inf
                call rango        ;
                cjne r2,#00,xxx2  ;
                                  ;
                mov r0,#46h       ;limite sup
                mov 09,#41h       ;limite inf
                call rango        ;
                cjne r2,#00,sig222;
                                  ;
                sjmp otro2        ;
                                  ;
          xxx2: ret               ;NUM HEX
                                  ;
        sig222: subb a,#37h       ;ALF HEX
                ret               ;
;-------------------------------------------
                                  ;
       DIRINIC: CALL Rhexasc2     ;
                mov 30h,a         ;
                CALL Rhexasc2     ;
                mov 31h,a         ;
                CALL Rhexasc2     ;
                mov 32h,a         ;
                CALL Rhexasc2     ;
                mov 33h,a         ;
                RET               ;
;============================================================================
;----------------------------------------------------------------------------
;          ********** ----  I  N  I  C  I  O  ---- **********
;----------------------------------------------------------------------------
;============================================================================

         inicio:mov dptr,#0a000H            ;seteando la puerta de
                mov a,#08H                  ;comunicaciones A o B
                movx @DPTR,A                ;

                mov tmod,#20H               ;seteando el BaudRate
                mov a,#0F3H                 ;de transmicion
                mov TH1,A                   ;
                mov TL1,A                   ;
                mov SCON,#42H               ;
                SETB TR1                    ;


;----------------------------------------------------------------------------
;--main----------------------------------------------------------------------
;----------------------------------------------------------------------------

        head  : call text                   ;,
                mov dptr,#texto1            ;,
                call transtex               ;,

        reciv : call resep                  ;,
                cjne a,#"1",ver2            ;,
                sjmp es1                    ;,

        ver2  : cjne a,#"2",ver3            ;,
                sjmp es2                    ;,

        ver3  : cjne a,#"3",ver4
                ljmp es3

        ver4  : cjne a,#"4",ver5
                ljmp es4

        ver5  : cjne a,#"5",ver6
                ljmp es5

        ver6  : cjne a,#"6",bep
                ljmp es6

        bep   : call beep                   ;,
                sjmp reciv                  ;,
;------------------------------------------------------------------------------
;-----------------------------------------------------------------------

        es1   : call text                   ; ,escribir un mensaje en ramX
                mov dptr,#texto2            ; ,
                call transtex               ; ,
                call ingdir                 ; ,
                mov dptr,#texto3            ; ,
                call transtex               ; ,

                call ascdptr                ; ,
                call hacmens                ; ,
                call almcfin                ; ,
                mov dptr,#texto4            ; ,
                call transtex               ; ,
                call ncarac                 ; ,
                mov dptr,#texto5            ; ,
                call transtex               ; ,
                call direcfin               ; ,
                mov dptr,#texto6            ; ,
                call transtex               ; ,
                call resep                  ; ,
                sjmp head                   ; ,

;-----------------------------------------------------------------------------
;----------------------------------------------------------------------

        es2   : call text                   ;  volcado de memoria
                mov dptr,#texto7            ;
                call transtex               ;,
                call ingdir                 ;,
                mov dptr,#texto8            ;,
                call transtex               ;,
                call resep                  ;,
                cjne a,#1bh,sig2            ;,
                sjmp es2                    ;,

        sig2  : call text                   ; ,
                mov dptr,#texto9            ; ,
                call transtex               ; ,
                call ascdptr                ; ,mover al dptr  la direccion
                                            ;de inicio

      mainloop: mov r7,#10h                 ;contador vertical
        
        loopin: push dph
                push dpl
                call almcfin                ;direccion de inicio
                call direcfin               ;de las filas con datos
                mov dptr,#texto11
                call transtex
                pop dpl
                pop dph

                
                mov r1,#40h                 ;direccion donde se almacenan
                                            ;los datos ascii

                mov r6,#10h                 ;contador horizontal

        volc  : movx a,@dptr                ;*
                mov @r1,a                   ;*
                mov r3,a                    ;*
                call morf
                mov r4,a                    ;
                mov a,r3                    ;*******
                swap a                      ;
                call morf
                call txa                    ;
                mov a,r4                    ;
                call txa                    ;
                mov a,#20h                  ;
                call txa                    ;
                inc dptr                    ;
                inc 01                      ;
                djnz r6,volc                ;

                mov a,#20h                  ;espacio
                call txa                    ;
                mov r1,#40h                 ;direccion datos ascii
                mov r6,#10h                 ;contador horizontal
        otrasc: mov a,@r1                   ;
                call rancontr               ;
                cjne r2,#00,escontr         ;
                sjmp sigue3                 ;
       escontr: mov a,#00                   ;
       sigue3 : call txa                    ;
                inc 01                      ;
                djnz r6,otrasc              ;
                mov a,#0dh                  ;
                call txa                    ;
                mov a,#0ah                  ;
                call txa                    ;
                djnz r7,loopin              ;
                push dph                    ;
                push dpl                    ;
                mov dptr,#texto10           ;
                call transtex               ;
                pop dpl                     ;
                pop dph                     ;
                call resep                  ;
                cjne a,#1bh,mas             ;
                ljmp head                   ;

        mas   : call text                   ;
                push dph                    ;
                push dpl                    ;
                mov dptr,#texto9            ;
                call transtex               ;
                pop dpl                     ;
                pop dph                     ;
                ljmp mainloop               ;

;----------------------------------------------------------------------------
;-------------------------------------------------------------------------
          ES3 : CALL TEXT                   ;
                                            ;cargar un segmento de ramX
                MOV DPTR,#TEXTO12           ;con un dato
                call transtex
                call ingdir

                mov dptr,#texto13
                call transtex
                call ingfin

                mov dptr,#texto14          ;dato a cargar
                call transtex

                call rhexasc               ;rango ascii numerico o alfa
                mov 50h,a                  ;mas significativo
                call rhexasc
                mov 51h,a                  ;menos significativo

;----------------------------------------


         LIMP:  anl 50h,#0fh            ;eliminando cuarteto superior
                mov a,50h               ;
                swap a                  ;subiendo cuarteto inferior
                anl 51h,#0fh            ;eliminando cuarteto superior
                orl a,51h               ;formando el dato
                mov 0ah,a


                call ascdptr            ;cargando dptr con direccion inicial
         otrax: mov a,0ah
                movx @dptr,a
                mov a,36h               ;byte menos significativo final
                cjne a,82H,otra         ;comparar con dpl
                mov a,35h               ;byte mas significativo final
                cjne a,83H,otra         ;comparar con dph
                mov dptr,#texto15
                call transtex
                call resep
                ljmp head
         otra : inc dptr
                sjmp otrax
;---------------------------------------------------------------------------
;------------------------------------------------------------------------
                                        ;Limpiar RamX 8000h 9fffh
           ES4: mov a,#30h              ;carga el ascci del 0 en el acumulador
                mov 50h,a               ;
                mov 51h,a               ;

                mov 30h,#38h            ; cargando el ascci del 8
                mov 31h,a               ;
                mov 32h,a               ;
                mov 33h,a               ;

                mov 35h,#9fh            ; cargando final 16bits
                mov 36h,#0ffh           ;
                JMP limp               ;
                ljmp inicio
;----------------------------------------------------------------------------
;-------------------------------------------------------------------------
;----------------------------------------------------------------------------
                                        ;Transmitir un programa del pc al kit
                                        ;
           es5: call text               ;
                mov dptr,#texto16       ;
                call transtex           ;
                                        ;
                mov 10h,#00             ;
       comiens: call resep              ;
                cjne a,#58,comiens      ;Inicio del regitro


                call dats               ;campo de longitud del registro
          long: mov 04h,a               ;
                mov 05h,a               ;

                call DIRINIC            ;campo de la direccion de carga
                call ascdptr            ;del registro
                mov a,05h               ;
                mov 11h,82h
                add a,11h               ;
                mov 12h,83h
                add a,12h               ;
                mov 05,a                ;

                call dats               ;campo del tipo de registro
                add a,05                ;
                mov 05,a                ;

    otraintruc: call dats               ;campo de datos propiamentetal
                                        ;
                mov 13h,a
                add a,05                ;
                mov 05,a                ;
                mov a,13h                ;
                movX @dptr,a            ;almacenando los datos
                inc dptr                ;
                djnz 04,otraintruc      ;
                                        ;
                mov a,05                ;Algoritmos para verificar
                cpl a                   ;el codigo de validacion
                add a,#1                ;de archivo INTEL.HEX
                mov 05,a                ;
                call datS               ;
                cjne a,05,error         ;hacia la rutina de error
                                        ;
       backerr: mov r1,#04              ;
                mov r2,#06
         cont2: call resep              ;

                cjne a,#58,decr1        ;
                call dats
                cjne a,#00,long
       ffs    : call dats
                djnz r2,ff2
                ljmp fnd
         ff2  : cjne a,#0ffh,ffs
                call resep
                mov dptr,#texto17
                call transtex
                call resep
                ljmp head
         decr1: djnz r1,cont2
         fnd :  mov dptr,#texto21
                call transtex
                mov a,10h
                cjne a,#1,siguen
                mov dptr,#texto18
                call transtex
        siguen: call resep
                ljmp head
                                        ;
         error: mov 10h,#1              ;
                jmp backerr             ;
                                        ;
                                        ;
;----------------------------------------------------------------------------
;-------------------------------------------------------------------------
           es6: call text               ;ejacutar un programa
                mov dptr,#texto19       ;
                call transtex           ;
                call ingdir             ;

                call ascdptr
                push 82h
                push 83h
                ret
;----------------------------------------------------------------------------
;TEXTOS:
;-------
 
texto0:
db 0ch,09h,09h,09h,"      Herman Vasquez"
db 0dh,0ah,09h,09h,09h,"      --------------"
db 13,10,9,9,9,"    COM KIT U22 Ver 4.3"
db 13,10,9,9,9,9,"   U.S.M"
db 13,10,"         --*- Sistema de desarrollo mcs51 en modo procesador-*--",64

texto1:
db 13,10,10
db 9,9,9,"  ----------------------"
db 13,10,9,9,9,"      MENU PRINCIPAL",13,10
db"-----------------------------------------------------------------------------"
db 13,10,10,9,"1) Escribir un mensaje en RAMx"
db 13,10,10,9,"2) Volcado de memoria"
db 13,10,10,9,"3) Cargar un segmento de RamX con un dato"
db 13,10,10,9,"4) Limpiar RamX 8000h 9FFFh"
db 13,10,10,9,"5) Transmitir un programa(.HEX) del PC al Kit"
db 13,10,10,9,"6) Ejecutar un Programa"
db 13,10
db"-----------------------------------------------------------------------------",64
texto2:
db 13,10,"Escribir un mensaje en RAMx"
db 13,10,"---------------------------"
db 13,10,10,9,"Indicar direccion de inicio en hexadecimal,  partiendo"
db 13,10,"desde 8000H. Para finalizar con ENTER (Retorno de carro 13D)"
db 13,10,"Maximo 1 pagina logica (256 posiciones de memoria)"
db 13,10,10,"Direccion de inicio:",64

texto3:
db 13,10,"Listo",13,10
db "----------------------------------------"
db "----------------------------------------",13,10,64

texto4:
db 13,10,10 
db "----------------------------------------"
db "----------------------------------------",13,10,"* Total : ",64

texto5:
db "H Caracteres almacenados ",13,10
db "* Direccion de termino : ",64

texto6:
db 13,10,10,"Para continuar presionar cualquier tecla",64

texto7:
db 13,10,10,"Volcado de memoria"
db 13,10,"------------------",13,10
db 13,10,"El volcado se hace de los primeros 256 caracteres los"
db 13,10,"codigos de control son presentados como nulos (00)"
db 13,10,10,"Ingresar direccion inicial en HEX:",64

texto8:
db 13,10,"Presionar cualquier tecla para seguir  ESC volver atras",64

texto9:
db 13,10,"Volcado de memoria",13,10
db "--------------------",13,10,64

texto10:
db 13,"Para ver los siguientes 256 caracteres presionar cualquier tecla"
db 13,10,"Para terminar ESC",64

texto11:
db "H   ",64

texto12:
db 13,10,10,"Cargar un segmento de RamX con un dato"
db 13,10,"--------------------------------------",13,10
db 13,10,10,10,9,9,"Ingresar direccion de inicio  : ",64

texto13:
db 13,10,10,10,9,9,"Ingresar direccion de termino : ",64

texto14:
db 13,10,10,10,9,9,"Dato a cargar   :  ",64

texto15:
db 13,10,10
db 10,10,9,"Hecho. Precionar cualquier tecla para continuar",64

texto16:
db 13,10,10,"      Cargar un programa desde el PC a la memoria RamX del kit8031h"
db 13,10,10,"      Presionar  [ REG PAG ] para comenzar",64

texto17:
db 13,10,10,"   EXITO"
db 13,10,10,"   Para continuar presiona cualquier tecla..",10,10,13,64

texto18:
db 13,10,10,10,10,10,9,9,"[  E R R O R  ] . . . . . ."
DB 13,10,10,9,9,"*  No coincide el codigo de validacion......"
db 13,10,10,9,9,"*  No es el formato correcto"
db 13,10,10,9,9,"*  Archivo debe ser formato INTEL [.HEX ] ..",10,10,10,64

texto19:
db 13,10,10,10
db "Ejecutar un programa"
db 13,10,"--------------------"
db 13,10,10,"Ingresar direccion en [ HEX ] : ",64

texto20:
db 13,10,10,10,10,9,9,9,"Ejecutando programa.",64

texto21:
db 13,10,10,9,9,"Programa cargado "
db 13,10,10,9,9,"Presionar cualquier tecla para continuar",64


;----------------------------------------------------------------------------
                END
