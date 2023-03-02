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
; ================================================================================================================
; IKBD handlers management
; ================================================================================================================
; KBDVBASE -- see https://freemint.github.io/tos.hyp/en/xbios_structures.html#KBDVBASE
;
                        rsreset

KBDVBASE_midivec        rs.l 1 ; MIDI interrupt vector
KBDVBASE_vkbderr        rs.l 1 ; Keyboard error vector
KBDVBASE_vmiderr        rs.l 1 ; MIDI error vector
KBDVBASE_statvec        rs.l 1 ; Keyboard status
KBDVBASE_mousevec       rs.l 1 ; Keyboard mouse status
KBDVBASE_clockvec       rs.l 1 ; Keyboard clock
KBDVBASE_joyvec         rs.l 1 ; Keyboard joystick status
KBDVBASE_midisys        rs.l 1 ; System Midi vector
KBDVBASE_kbdsys         rs.l 1 ; Keyboard vector
KBDVBASE_drvstat        rs.b 1 ; Keyboard driver status

SIZEOF_KBDVBASE         rs.b 1 ; WITH EVEN FIX PADDING
EVENSIZEOF_KBDVBASE     rs.b 0 ; 

; ================================================================================================================
; Wait for idle state
;
WaitForIdleIkbdHandlers macro
                        ;1 - address registry having KBDVBASE
.waitIkbd\@             tst.b                   KBDVBASE_drvstat(\1)
                        bne.s                   .waitIkbd\@
                        endm

; ================================================================================================================
; Save individual handler
;
SaveSysIkbdHandler      macro
                        ;1 - storage address of the structure
                        ;2 - storage address for the default handler for joystick
                        ;3 - adresse registry to use (side effect)
                        ;4 - offset of handler to save in KBDVBASE
                        _xos_Kbdvbase
                        move.l                  d0,\1
                        move.l                  d0,\3
                        move.l                  \4(\3),\2
                        endm

; ================================================================================================================
; Restore individual handler
;
RestoreSysIkbdHandler   macro
                        ;1 - storage address of the structure
                        ;2 - storage address for the default handler for joystick
                        ;3 - adresse registry to use (side effect)
                        ;4 - offset of handler to save in KBDVBASE
                        move.l                  \1,\3
                        move.l                  \2,\4(\3)
                        endm

; ================================================================================================================
