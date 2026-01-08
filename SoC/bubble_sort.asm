; Bubble Sort
        JMS readEl
        INP R0, 2 
        PSH {R0}
        INP R1, 2
        PSH {R1}
        JMS bbsort
        HLT

readEl  INP R0, 2
        MOV R4, #fr
        STR R0, 0(R4)
        LDR R0, 0(R4)
        MOV R1, #0 ; i=0
        MOV R2, #200
loop    CMP R1, R0
        BGE endloop
        INP R3, 2
        STR R3, 0(R2)
        ADD R2, #1
        ADD R1, #1
        BRA loop
endloop RET

swap    POP {R2}
        POP {R1}
        POP {R0}
        ADD R4, R0, R1
        LDR R5, 0(R4)
        ADD R6, R0, R2
        LDR R7, 0(R6)
        STR R7, 0(R4)
        STR R5, 0(R6)
        RET

bbsort  POP {R1} ;N
        POP {R0} ;adrr
        PSH {LR}
        SUB R1, #1
        MOV R2, #0 ;i=0
loop1   CMP R2, R1
        BGE end1
        MOV R3, #0 ;j=0
loop2   SUB R4, R1, R2
        CMP R3, R4
        BGE end2
        ADD R5, R0, R3
        LDR R6, 0(R5)
        LDR R7, 1(R5)
if      CMP R6, R7
        BLE else
        MOV R5, R3
        ADD R5, #1
        PSH {R7}
        PSH {R6}
        PSH {R5} 
        PSH {R4}
        PSH {R3}
        PSH {R2}
        PSH {R1}
        PSH {R0}
        PSH {R0}
        PSH {R3}
        PSH {R5}
        JMS swap
        POP {R0}
        POP {R1}
        POP {R2}
        POP {R3}
        POP {R4}
        POP {R5}
        POP {R6}
        POP {R7}
else    ADD R3, #1
        BRA loop2
end2    ADD R2, #1
        BRA loop1
end1    POP {PC}
        RET

fr      DAT



