; ================================================================================================================
; (C) 2023 David SPORN
; Distributed AS IS, in the hope that it will be useful, but WITHOUT ANY WARRANTY
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; ================================================================================================================
; KBDVBASE -- see https://freemint.github.io/tos.hyp/en/xbios_structures.html#KBDVBASE
; ================================================================================================================
; INCLUDED BY input.s
; ================================================================================================================
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
; Just copy kbdvbase to another place, for loading into address register, put to or retrieve from an internal 
; cache,...
;
KBDVBASE_copy           macro
                        ;1 - address registry having KBDVBASE
                        ;2 - storage address for caching KBDVBASE
                        move.l                  \1,\2
                        endm

; ================================================================================================================
; Load kbdvbase into address register
;
KBDVBASE_fetchInto      macro
                        ;1 - address registry to put KBDVBASE into
                        _xos_Kbdvbase
                        KBDVBASE_copy           d0,\1
                        endm

; ================================================================================================================
; Wait for idle state
;
KBDVBASE_waitWhileBusy  macro
                        ;1 - address registry having KBDVBASE
.waitIkbd\@             tst.b                   KBDVBASE_drvstat(\1)
                        bne.s                   .waitIkbd\@
                        endm

; ================================================================================================================
; Save individual handler
;
KBDVBASE_backupHandler  macro
                        ;1 - address registry having KBDVBASE
                        ;2 - offset in KBDVBASE of the handler to save
                        ;3 - storage address of the backup
                        move.l                  \2(\1),\3
                        endm

; ================================================================================================================
; Change individual handler
;
KBDVBASE_setHandler     macro
                        ;1 - address registry having KBDVBASE
                        ;2 - offset in KBDVBASE of the handler to change
                        ;3 - storage address of the handler
                        move.l                  \3,\2(\1)
                        endm

; ================================================================================================================
