
section .data
    global target_function
    two_hundred: dd 200
    hundred: dd 100
    

section .text
    extern target_x
    extern target_y
    extern lfsr_function
    extern lfsr
    extern resume
    extern curr_drone_index
    extern maxint
    extern CORS
    extern range_random
    extern range_res
    extern min_range
    extern temp_for_random





target_function:
createTarget:
    mov dword [temp_for_random], 100
    mov dword [min_range], 0
    call range_random
in_target:
    fld dword [range_res]
    fld dword [target_x]
    faddp
    fild dword [hundred]
    fcomip
    jc normalGreat
    jmp end
normalGreat:
    fild dword [hundred]
    fsubp
end:
    fstp dword [target_x]
    
    mov dword [temp_for_random], 100
    mov dword [min_range], 0
    call range_random 
break3:
    fld dword [range_res]
    fld dword [target_y]
    faddp
    fild dword [hundred]
    fcomip
    jc normalGreat1
    jmp end1
normalGreat1:
    fild dword [hundred]
    fsubp
end1:
    fstp dword [target_y]
    mov ecx, [curr_drone_index]
    mov eax, [CORS]
    mov ebx, [eax+4*ecx]
    call resume
    jmp target_function
