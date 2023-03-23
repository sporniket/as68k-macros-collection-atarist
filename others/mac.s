; ================================================================================================================
; (C) 2023 David SPORN
; Distributed AS IS, in the hope that it will be useful, but WITHOUT ANY WARRANTY
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; ================================================================================================================
; REQUIRES ....
; ================================================================================================================
; Multiply & ACcumulate macros
; ---
; ================================================================================================================
; Private macros, basic steps of operations.
mac__shift      macro ; shift to left by 1 position, when needing more than 2 shifts, use lsl instead.
                ; 1 - dx, data register to shift left by 1 position
                ; 2 - size : b,w or l
                add.\2  \1,\1
                endm

mac__copy       macro
                ; 1 - dx, the data register source
                ; 2 - dy, the data register destination
                ; 3 - size
                move.\3 \1,\2
                endm

mac__acc        macro ; ACCumulate
                ; 1 - dx, the data register source
                ; 2 - dy, the data register used as accumulator
                ; 3 - size
                add.\3  \1,\2
                endm

mac__msa        macro ; call Macro, Shift, Accumulate
                ; 1 - dx, the data register source
                ; 2 - dy, the data register used as accumulator
                ; 3 - size
                ; 4 - the macro to call before doing another shift/accumulate
                \4  \1,\2,\3
                mac__shift  \1,\3
                mac__acc    \1,\2,\3
                endm

mac__mssa       macro ; call Macro, Shift, Shift, Accumulate
                ; 1 - dx, the data register source
                ; 2 - dy, the data register used as accumulator
                ; 3 - size
                ; 4 - the macro to call before doing another shift/accumulate
                \4  \1,\2,\3
                mac__shift  \1,\3
                mac__shift  \1,\3
                mac__acc    \1,\2,\3
                endm

mac__mul_mac    macro ; preshift the source before calling the macro
                ; 1 - dx, the data register source
                ; 2 - dy, the data register used as accumulator
                ; 3 - size
                mac__shift  \1,\3
                \4  \1,\2,\3
                endm

; ================================================================================================================
; Private macros, with parametrized size of operation.
; All these macros have the same interface :
; /1 - dx, the data register containing the operand to multiply ; the value is changed by the algorithm
; /2 - dy, the data register that will be used as accumulator
; /3 - size : b,w or l
; ================================================================================================================
mac__0      macro
            sub.\3  \2,\2 ; zeroing limited to the size, without using immediate value.
            endm

mac__1      macro
            mac__copy   \1,\2,\3
            endm

mac__2      macro
            mac__shift  \1,\3
            mac__copy   \1,\2,\3
            endm

mac__3      macro
            mac__msa    \1,\2,\3,mac__1
            endm

mac__4      macro
            mac__mul_mac  \1,\2,\3,mac__2
            endm

mac__5      macro
            mac__mssa   \1,\2,\3,mac__1
            endm

mac__6      macro
            mac__mul_mac  \1,\2,\3,mac__3
            endm

mac__7      macro
            mac__msa    \1,\2,\3,mac__3
            endm

mac__8      macro
            lsl.\3  #3,\1
            mac__copy   \1,\2,\3
            endm

mac__9      macro
            mac__1   \1,\2,\3
            lsl.\3  #3,\1
            mac__acc    \1,\2,\3
            endm

mac__10     macro
            mac__mul_mac  \1,\2,\3,mac__5
            endm

mac__11     macro
            mac__mssa \1,\2,\3,mac__3
            endm

mac__12     macro
            mac__mul_mac  \1,\2,\3,mac__6
            endm

mac__13     macro
            mac__msa \1,\2,\3,mac__5
            endm

mac__14     macro
            mac__mul_mac  \1,\2,\3,mac__7
            endm

mac__15     macro
            mac__msa \1,\2,\3,mac__7
            endm

mac__16     macro
            lsl.\3      #4,\1
            mac__copy   \1,\2,\3
            endm

mac__17     macro
            mac__1      \1,\2,\3
            lsl.\3      #4,\1
            mac__acc    \1,\2,\3
            endm

mac__18     macro
            mac__mul_mac  \1,\2,\3,mac__9
            endm

mac__19     macro
            mac__3      \1,\2,\3
            mac__shift  \1,\3
            mac__shift  \1,\3
            mac__shift  \1,\3
            mac__acc    \1,\2,\3
            endm

mac__20     macro
            mac__mul_mac  \1,\2,\3,mac__10
            endm

mac__21     macro
            mac__mssa \1,\2,\3,mac__5
            endm

mac__22     macro
            mac__mul_mac  \1,\2,\3,mac__11
            endm

mac__23     macro
            mac__mssa \1,\2,\3,mac__7
            endm

mac__24     macro
            mac__3      \1,\2,\3
            lsl.\3      #3,\2
            endm

mac__25     macro
            mac__msa    \1,\2,\3,mac__9
            endm

mac__26     macro
            mac__mul_mac  \1,\2,\3,mac__13
            endm

mac__27     macro
            mac__msa    \1,\2,\3,mac__11
            endm

mac__28     macro
            mac__mul_mac  \1,\2,\3,mac__14
            endm

mac__29     macro
            mac__msa    \1,\2,\3,mac__13
            endm

mac__30     macro
            mac__mul_mac  \1,\2,\3,mac__15
            endm

mac__31     macro
            mac__msa    \1,\2,\3,mac__15
            endm

; ================================================================================================================
; Public macros, byte sized.
; All these macros have the same interface :
; /1 - dx, the data register containing the operand to multiply ; the value is changed by the algorithm
; /2 - dy, the data register that will be used as accumulator
; ================================================================================================================
mac_0_b     macro
            mac__0  \1,\2,b
            endm

mac_1_b     macro
            mac__1  \1,\2,b
            endm

mac_2_b     macro
            mac__2  \1,\2,b
            endm

mac_3_b     macro
            mac__3  \1,\2,b
            endm

mac_4_b     macro
            mac__4  \1,\2,b
            endm

mac_5_b     macro
            mac__5  \1,\2,b
            endm

mac_6_b     macro
            mac__6  \1,\2,b
            endm

mac_7_b     macro
            mac__7  \1,\2,b
            endm

mac_8_b     macro
            mac__8  \1,\2,b
            endm

mac_9_b     macro
            mac__9  \1,\2,b
            endm

mac_10_b     macro
            mac__10  \1,\2,b
            endm

mac_11_b     macro
            mac__11  \1,\2,b
            endm

mac_12_b     macro
            mac__12  \1,\2,b
            endm

mac_13_b     macro
            mac__13  \1,\2,b
            endm

mac_14_b     macro
            mac__14  \1,\2,b
            endm

mac_15_b     macro
            mac__15  \1,\2,b
            endm

mac_16_b     macro
            mac__16  \1,\2,b
            endm

mac_17_b     macro
            mac__17  \1,\2,b
            endm

mac_18_b     macro
            mac__18  \1,\2,b
            endm

mac_19_b     macro
            mac__19  \1,\2,b
            endm

mac_20_b     macro
            mac__20  \1,\2,b
            endm

mac_21_b     macro
            mac__21  \1,\2,b
            endm

mac_22_b     macro
            mac__22  \1,\2,b
            endm

mac_23_b     macro
            mac__23  \1,\2,b
            endm

mac_24_b     macro
            mac__24  \1,\2,b
            endm

mac_25_b     macro
            mac__25  \1,\2,b
            endm

mac_26_b     macro
            mac__26  \1,\2,b
            endm

mac_27_b     macro
            mac__27  \1,\2,b
            endm

mac_28_b     macro
            mac__28  \1,\2,b
            endm

mac_29_b     macro
            mac__29  \1,\2,b
            endm

mac_30_b     macro
            mac__30  \1,\2,b
            endm

mac_31_b     macro
            mac__31  \1,\2,b
            endm

; ================================================================================================================
; Public macros, word sized.
; All these macros have the same interface :
; /1 - dx, the data register containing the operand to multiply ; the value is changed by the algorithm
; /2 - dy, the data register that will be used as accumulator
; ================================================================================================================
mac_0_w     macro
            mac__0  \1,\2,w
            endm

mac_1_w     macro
            mac__1  \1,\2,w
            endm

mac_2_w     macro
            mac__2  \1,\2,w
            endm

mac_3_w     macro
            mac__3  \1,\2,w
            endm

mac_4_w     macro
            mac__4  \1,\2,w
            endm

mac_5_w     macro
            mac__5  \1,\2,w
            endm

mac_6_w     macro
            mac__6  \1,\2,w
            endm

mac_7_w     macro
            mac__7  \1,\2,w
            endm

mac_8_w     macro
            mac__8  \1,\2,w
            endm

mac_9_w     macro
            mac__9  \1,\2,w
            endm

mac_10_w     macro
            mac__10  \1,\2,w
            endm

mac_11_w     macro
            mac__11  \1,\2,w
            endm

mac_12_w     macro
            mac__12  \1,\2,w
            endm

mac_13_w     macro
            mac__13  \1,\2,w
            endm

mac_14_w     macro
            mac__14  \1,\2,w
            endm

mac_15_w     macro
            mac__15  \1,\2,w
            endm

mac_16_w     macro
            mac__16  \1,\2,w
            endm

mac_17_w     macro
            mac__17  \1,\2,w
            endm

mac_18_w     macro
            mac__18  \1,\2,w
            endm

mac_19_w     macro
            mac__19  \1,\2,w
            endm

mac_20_w     macro
            mac__20  \1,\2,w
            endm

mac_21_w     macro
            mac__21  \1,\2,w
            endm

mac_22_w     macro
            mac__22  \1,\2,w
            endm

mac_23_w     macro
            mac__23  \1,\2,w
            endm

mac_24_w     macro
            mac__24  \1,\2,w
            endm

mac_25_w     macro
            mac__25  \1,\2,w
            endm

mac_26_w     macro
            mac__26  \1,\2,w
            endm

mac_27_w     macro
            mac__27  \1,\2,w
            endm

mac_28_w     macro
            mac__28  \1,\2,w
            endm

mac_29_w     macro
            mac__29  \1,\2,w
            endm

mac_30_w     macro
            mac__30  \1,\2,w
            endm

mac_31_w     macro
            mac__31  \1,\2,w
            endm

; ================================================================================================================
; Public macros, long word sized.
; All these macros have the same interface :
; /1 - dx, the data register containing the operand to multiply ; the value is changed by the algorithm
; /2 - dy, the data register that will be used as accumulator
; ================================================================================================================
mac_0_l     macro
            mac__0  \1,\2,l
            endm

mac_1_l     macro
            mac__1  \1,\2,l
            endm

mac_2_l     macro
            mac__2  \1,\2,l
            endm

mac_3_l     macro
            mac__3  \1,\2,l
            endm

mac_4_l     macro
            mac__4  \1,\2,l
            endm

mac_5_l     macro
            mac__5  \1,\2,l
            endm

mac_6_l     macro
            mac__6  \1,\2,l
            endm

mac_7_l     macro
            mac__7  \1,\2,l
            endm

mac_8_l     macro
            mac__8  \1,\2,l
            endm

mac_9_l     macro
            mac__9  \1,\2,l
            endm

mac_10_l     macro
            mac__10  \1,\2,l
            endm

mac_11_l     macro
            mac__11  \1,\2,l
            endm

mac_12_l     macro
            mac__12  \1,\2,l
            endm

mac_13_l     macro
            mac__13  \1,\2,l
            endm

mac_14_l     macro
            mac__14  \1,\2,l
            endm

mac_15_l     macro
            mac__15  \1,\2,l
            endm

mac_16_l     macro
            mac__16  \1,\2,l
            endm

mac_17_l     macro
            mac__17  \1,\2,l
            endm

mac_18_l     macro
            mac__18  \1,\2,l
            endm

mac_19_l     macro
            mac__19  \1,\2,l
            endm

mac_20_l     macro
            mac__20  \1,\2,l
            endm

mac_21_l     macro
            mac__21  \1,\2,l
            endm

mac_22_l     macro
            mac__22  \1,\2,l
            endm

mac_23_l     macro
            mac__23  \1,\2,l
            endm

mac_24_l     macro
            mac__24  \1,\2,l
            endm

mac_25_l     macro
            mac__25  \1,\2,l
            endm

mac_26_l     macro
            mac__26  \1,\2,l
            endm

mac_27_l     macro
            mac__27  \1,\2,l
            endm

mac_28_l     macro
            mac__28  \1,\2,l
            endm

mac_29_l     macro
            mac__29  \1,\2,l
            endm

mac_30_l     macro
            mac__30  \1,\2,l
            endm

mac_31_l     macro
            mac__31  \1,\2,l
            endm
