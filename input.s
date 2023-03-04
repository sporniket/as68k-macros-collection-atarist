; ================================================================================================================
; (C) 2020 David SPORN
; Distributed AS IS, in the hope that it will be useful, but WITHOUT ANY WARRANTY
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; ================================================================================================================
; REQUIRES systraps.s
; ================================================================================================================
; Input macros
_xos_ikbdws                 macro
                        ;1 - corrected byte count (= byte count - 1)
                        ;2 - address of the bytes
                        pea                     \2
                        move.w                  #\1,-(sp)
                        ___xbios                25,8
                        endm
_xos_Kbdvbase               macro
                        ___xbios                34,2
                        endm
_dos_Cconis                 macro
                        ___gemdos               11,2
                        endm
;
_dos_Cconin                 macro
                        ; Read a character from the standard input device.
                        ___gemdos               1,2
                        endm

IsWaitingKey            macro
                        ; The CCR will be setup for beq.s
                        _dos_Cconis
                        tst.l                   d0
                        endm

_dos_Crawcin            macro
                        ___gemdos               7,2
                        endm

WaitInp                 macro
                        _dos_Crawcin
                        endm


FlushInp                macro
                        ; read and discards any char from input.
                        ; a0-a2/d0-d2 should be saved beforehand
                        ; --
.hasInput\@
                        IsWaitingKey
                        beq                     .thatsAll\@
                        _dos_Cconin
                        bra                     .hasInput\@
.thatsAll\@
                        endm

; ================================================================================================================
; REQUIRE THAT this 'macros' folder is in the include path
;
                        include                 'macros/ostypes/KBDVBASE.s'
