; ================================================================================================================
; (C) 2023 David SPORN
; Distributed AS IS, in the hope that it will be useful, but WITHOUT ANY WARRANTY
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; ================================================================================================================
; REQUIRES ...
; ================================================================================================================
; Ring buffer of 4 bytes long items
; ---
; Typical use -- feeding the buffer, given that a2 points to the source data, and using an item size of 3 bytes,
; working using a4 and a3
;
;                       rnbuf_withRingBuffer    a4,#my_ring_buffer
;                       move.l                  RingBuffer_adrPush(a4),a3
;                       ; copy 3 bytes
;                       move.b                  (a2)+,(a3)+
;                       move.b                  (a2)+,(a3)+
;                       move.b                  (a2)+,(a3)+
;                       rnbuf_donePush          a4,#3
;                       ; ...
;                       ; ... etc.
;                       ; ...
; my_ring_buffer        ds.b                    SIZEOF_RingBuffer,0
;                       even
;
; ---
; Typical use -- reading the buffer, given that a2 points to the destination of the data, and using an item size of 3 bytes,
; working using a4 and a3
;
;                       rnbuf_withRingBuffer    a4,#my_ring_buffer
;                       rnbuf_isEmpty           a4,a3 ; side effect : a3 = loaded with adrPop
;                       beq                     done ; empty buffer
;                       ; copy 3 bytes
;                       move.b                  (a3)+,(a2)+
;                       move.b                  (a3)+,(a2)+
;                       move.b                  (a3)+,(a2)+
;                       rnbuf_drop              a4,#3
; done                  ; ...
;                       ; ... etc.
;                       ; ...
; my_ring_buffer        ds.b                    SIZEOF_RingBuffer,0
;                       even
;
; ================================================================================================================
; Ring buffer general structure (will have to be factored at some point)
; * the size of the storage area is assumed to be of the right size according to the size of the items to store.
                        rsreset
RingBuffer_adrStart     rs.l    1 ; Pointer to the beginning (first byte) of the storage area
RingBuffer_adrEnd       rs.l    1 ; Pointer to the end (after the last byte) of the storage area
RingBuffer_adrPush      rs.l    1 ; Pointer to the first byte where the next item will be pushed
RingBuffer_adrPop       rs.l    1 ; Pointer to the first byte of the next item to be poped/dropped

SIZEOF_RingBuffer       rs.b 0 ;
EVENSIZEOF_RingBuffer   rs.b 0 ;

; ================================================================================================================
; Use given address register as pointer to a RingBuffer
rnbuf_withRingBuffer    macro
                        ; 1 - <<this>>, address registry to use, will point to the RingBuffer
                        ; the pointer to the Ring Buffer to use.
                        move.l \2,\1
                        endm

; ================================================================================================================
; Increment given address by a given amount, go back to adrStart if going to or beyond adrEnd
; "protected" macro (should not be called outside extensions)
rnbuf__incAdr           macro 
                        ; 1 - <<this>>, address registry pointing to the RingBuffer
                        ; 2 - address registry to increment
                        ; 3 - item size
                        add.l   \3,\2
                        cmp.l   RingBuffer_adrEnd(\1),\2
                        bhi     .done_\@
                        move.l  RingBuffer_adrStart(\1),\2
.done_\@                nop
                        endm

; ================================================================================================================
; Test whether the buffer is empty, one can then chain with beq (branching when empty) or bne (branching when non empty)
rnbuf_isEmpty           macro
                        ; 1 - <<this>>, address registry pointing to the RingBuffer
                        ; 2 - address registry to work, will be loaded with adrPop
                        move.l      RingBuffer_adrPop(\1),\2
                        cmp.l       RingBuffer_adrPush(\1),\2
                        endm


; ================================================================================================================
; Drop the next popable item, if any (i.e. if not empty, increment adrPop)
rnbuf_drop              macro
                        ; 1 - <<this>>, address registry pointing to the RingBuffer
                        ; 2 - address registry to work, will be loaded with adrPop
                        ; 3 - item size
                        rnbuf_isEmpty   \1,\2
                        beq             .done_\@
                        ; \2 = this.adrPop, to update
                        move.l          RingBuffer_adrPop(\1),\2
                        rnbuf__incAdr   \1,\2,\3
                        move.l          \2,RingBuffer_adrPop(\1)
.done_\@                nop
                        endm

; ================================================================================================================
; Acknowledge a push (increment adrPush, drop one item if the buffer is full)
rnbuf_donePush          macro
                        ; 1 - <<this>>, address registry pointing to the RingBuffer
                        ; 2 - address registry to work, will be loaded with adrPop
                        ; 3 - item size
                        ; \2 = this.adrPush
                        move.l          RingBuffer_adrPush(\1),\2
                        rnbuf__incAdr   \1,\2,\3
                        move.l          \2,RingBuffer_adrPush(\1)
                        ; drop if the this.adrPush == this.adrPop
                        ; meaning adrPush has caught up to adrPop
                        rnbuf_isEmpty   \1,\2
                        bne             .done_\@
                        ; by the way, now \2 = this.adrPop 
                        rnbuf__incAdr   \1,\2,\3
                        move.l          \2,RingBuffer_adrPop(\1)
.done_\@                nop
                        endm

