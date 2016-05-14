.model small        
.stack 100h
.data               
                    
GameTitle db 'Snake Game 2006 $' 
GameScore db 'Score: $'                        
GameInput db 'Enter Speed (1..15):$'
Err_Walls    db '     Snake Fall In The Wall ! $'
Err_Snake    db '      Snake Touch Himself !   $'
Err_Size     db '        Snake Out Of Size !   $'
Err_Esc      db '         Escape Pressed !     $'
Err_PressKey db '         Press Any Key...     $'
X db 1 ; Point To The Head Of The Snake
Y db 1 ; Point To The Head Of The Snake
TmpX db 0 ; Function Helper  
TmpY db 0 ; Function Helper 
Mx db 40  ; Point To Mouse X   
My db 12  ; Point To Mouse Y
ArrX db 350 dup (0)  ; Holds Snake X Data       
ArrY db 350 dup (0)  ; Holds Snake Y Data
Total db 0       ; Holds Previus Timer Tick           
TotalOld db 0    ; Holds Current Timer Tick           
DirX db 1         ; Direction Of The X Position (1 = Right, -1 = Left)  
DirY db 0         ; Direction Of The Y Position (1 = Down , -1 = Up )  
Snake_Size db 20  ; Snake Size (Grow Up During The Game)
Snake_Score dw 0  ; Snake Score. 1 Point Every Mouse Catch  
Snake_Max_Size db 25  ; Max Snake Size.
Key_Pressed db 0      ; Holds Current Scan Code Of The Keyboard
Key_Old db 0          ; Holds Old Scan Code Of The KeyBoard  
Snake_Input db 0      ; User Speed Input  
Input_Count db 0      ; Helper To Count Length Of Input 
TTime db 0            ; Helper To Count Ticks Per Time
TmpVar db 0             ; Helper Var                                   
;----------------------------------------------  
; Input:                                      
; Output:                                     
;----------------------------------------------
;----------------------------------  
; Input: X,Y Screen Positions     
; Output: Move Cursor To Position  
;----------------------------------
GOTOXY MACRO X,Y                   
MOV AH,2                           
MOV DL,X                           
MOV DH,Y                           
INT 10H                                        
ENDM                               
 
;----------------------------------------   
; Input: X - Counter Variable            
; Output:Put System Ticks To X  (18.2Mhz)  
;----------------------------------------   
GetTick Macro X
        mov al,0    
        mov ah,00h  
        int 1ah        
        mov X,dl
endm                             
;-----------------------------------------------------           
; Input: X,Y - Positions                              
;        Char - Char To Show                        
;        EX - Attribute Of The Char Cell
;             < (0..15)  + (0..7) * 16 >
;              Forground    Background
; Output: Put Char To Position In Screen                                          
;----------------------------------------------------            
PUTCHAREX MACRO X,Y,CHAR,EX          
push di                                
        mov al,160                     
        mov cl,Y                       
        mul cl                         
        mov dx,ax                      
        ;---end Y--                    
        mov al,2                       
        mov cl,X                       
        mul cl                         
        ;---end X--                    
        add dx,ax ;                  
        mov di,dx                      
        mov ax,0B800H                  
        mov es,ax                      
        mov byte ptr es:[di-2],CHAR  
        mov byte ptr es:[di-1],EX    
pop di                               
                                     
ENDM                                           
;------------------------------------------  
; Input:  X,Y: Positions
;         Str: String Variable          
; Output: Put String In The Screen                    
;------------------------------------------
PUTTEXT MACRO X,Y,STR                
GOTOXY X,Y                           
MOV DX,OFFSET STR                    
MOV AH,9                             
INT 21H                              
ENDM                                 
;-----------------------------------------------------           
; Input : X,Y - Positions                              
;         Char - Char To Show                        
; Output: Put Char To Position In Screen                                          
;----------------------------------------------------            
PUTCHAR MACRO X,Y,CHAR               
push di                                
        mov al,160                     
        mov cl,Y                               
        mul cl                         
        mov dx,ax                      
        ;---end Y--                    
        mov al,2                       
        mov cl,X                       
        mul cl                         
        ;---end X--                    
        add dx,ax                      
        mov di,dx                      
        mov ax,0B800H                  
        mov es,ax                      
        mov byte ptr es:[di-2],CHAR 
pop di           
                                   
ENDM                               
;----------------------------------------------  
; Input: Empty                                      
; Output: Wait Until User Press On The Keyborad                                     
;----------------------------------------------
GETCH MACRO                                    
MOV AH,7H                          
INT 21H                            
ENDM                 
;----------------------------------------------  
; Input: STR  - String Variable                                      
; Output: Show Error Box , And Error String                                    
;----------------------------------------------
SHOWERROR MACRO STR  
CALL Error_Box           ; Show Box
PUTTEXT 31,9 ,GameScore  ; Show Score String
SHOWSCORE 45,9           ; Show Score  
PUTTEXT 22,10,STR        ; Show Error String          
PUTTEXT 22,11,Err_PressKey   ; Show Press Key String           
GETCH                        ; Wait                       
ENDM                        
;----------------------------------------------  
; Input: X,Y Score Position
; Output: Show Scores, In X,Y
;----------------------------------------------
SHOWSCORE MACRO X,Y          
mov TmpX,X                   
mov TmpY,Y                   
Call Update_Score            
ENDM                         
                                   
.code                              
;----------------------------------------------  
; Input:  Empty                                     
; Output: Clear The Screen With Spaces
;----------------------------------------------
clear_screen proc                              
XOR CX,CX                
XOR BX,BX                
MOV X,79            
MOV Y,24            
CLS:                      
   DEC X                 
   PUTCHAR X,Y,' '
   CMP X,0                       
   JNE CLS                     
   MOV X,80         
   DEC Y                 
CMP Y,-1            
JNE CLS                   
                    
                         
ret                      
endp clear_screen           
;----------------------------------------------  
; Input:  Empty
; Output: Draw Round Box Of The Game                                    
;----------------------------------------------
prepare_background proc            
mov X,2             
PBX:                     
   PUTCHAREX X,0,'Í',113  
   PUTCHAREX X,24,'Í',113  
   inc X            
   cmp X,79         
   jne PBX          
                     
mov Y,1                          
PBY:                           
   PUTCHAREX 1 ,Y ,'º',113 
   PUTCHAREX 79,Y ,'º',113
   inc Y            
   cmp Y,24         
   jne PBY          
                                  
PUTCHAREX 1,0, 'É' ,113
PUTCHAREX 1,24,'È' ,113                        
PUTCHAREX 79,0, '»',113
PUTCHAREX 79,24,'¼',113
                    
ret                    
endp prepare_background      
;----------------------------------------------  
; Input:  Empty                                     
; Output: Draw Round Box Of The Error                                    
;----------------------------------------------
Error_Box proc   
mov X,20         
PBX1:                     
   PUTCHAREX X,8,'Í',7
   PUTCHAREX X,13,'Í',7
   inc X                 
   cmp X,60             
   jne PBX1             
                                  
mov Y,8                
PBY1:                                          
   PUTCHAREX 20 ,Y ,'º',7
   PUTCHAREX 60,Y ,'º' ,7
   inc Y                    
   cmp Y,13            
   jne PBY1            
                       
PUTCHAREX 20,8, 'É',7
PUTCHAREX 20,13,'È',7
PUTCHAREX 60,8, '»',7
PUTCHAREX 60,13,'¼',7
                    
ret                    
endp Error_Box       
;----------------------------------------------  
; Input:  ArrX, ArrY - Arrays Of The Snake                                     
; Output: Set Arrays To Initial Positions
;         And Draws The Snake.       
;----------------------------------------------
prepare_snake proc  
mov si,offset ArrX                             
mov di,offset ArrY        
mov bx,0                  
PS:                              
   mov X,bl                    
   add X,5                
   mov Y,1                  
   ;---calc X,Y           
   mov cl,X               
   mov ch,Y               
   ;-- Set Them To Cx                       
   mov [si + bx],cl       
   mov [di + bx],ch    
   ;--- Update Array      
   PUTCHAREX X,Y,'*',15     
                   
   inc bl                   
   cmp bl,Snake_Size    
   jne PS                         
                          
ret                                            
endp prepare_snake        
;----------------------------------------------  
; Input:  Empty
; Output: Exit Snake During The Game                                     
;----------------------------------------------
exit_snake proc                  
         PUTCHAREX MX,MY,' ',0         
         Call Cursor_On        ; Set Cursor On
                                    
   	MOV AX,4C00H
      	INT 21H                     
endp exit_snake                     
;-------------------------------------------------  
; Input:  Key_Pressed - Holds Key Of The Keyborad                                    
; Output: Update Key_Pressed,Key_Old, And Clear
;         The Buffer Of The Keyboard
;-------------------------------------------------
Check_Key proc                      
                                               
  mov al,Key_Pressed                
  cmp al,Key_Old                    
  je KX                             
  mov Key_Old,al                    
                                    
KX:  in al,60h                      
     mov dl,al                      
                            
                                    
;  in al,64H  ; Finalize Kyboard Port                      
;  or al,20H  ; Not In Use Here
;  out 42H,al                       
;  and al,0dfH                      
;  out 64H,al                       
                                    
  call clear_buffer                 
  mov Key_Pressed,dl                
                                    
KEYN:                               
ret                                            
endp Check_Key              
;----------------------------------------------  
; Input: Key_Old, Key_Pressed.                                     
; Output: Sound If The Key Is Unvalid.                                     
;----------------------------------------------
Try_Sound_Key proc          
                            
 mov al,Key_Old      ; Al = Old Scan Code
 cmp al,Key_Pressed  ; Compare Old And Now
 je SKEYEND          ; If No Change, Exit
                            
 ; Key Pressed              
 mov al,Key_old             
 cmp al,1Eh       ; Left    
 je SKEYEND                 
 cmp al,11h       ; Up      
 je SKEYEND                 
 cmp al,20h       ; Right   
 je SKEYEND                       
 cmp al,1Fh       ; Down                       
 je SKEYEND                 
                            
 ;Key UnPressed             
 cmp al,160 ; D             
 je SKEYEND                 
 cmp al,158 ; A             
 je SKEYEND                 
 cmp al,159 ; S             
 je SKEYEND                 
 cmp al,145 ; W             
 je SKEYEND                 
                            
 Call Do_Sound   ; If Still Here, Key Unvalid.  
                   
SKEYEND:                          
ret                  
endp Try_Sound_Key
;----------------------------------------------  
; Input:  Empry                   
; Output: Clears Keyboard Queue                
;----------------------------------------------
clear_buffer proc              
                            
        ; Clear KeyBoard Buffer
        mov ax,40H     ; Base Address Of The Keyboard
        push ds                
        mov ds,ax              
        mov ax,ds:[001ah]      
        mov ds:[001ch],ax      
        pop ds                 
ret                           
endp clear_buffer             
;----------------------------------------------  
; Input:  Total, TotalOld                                    
; Output: Wait Periud Of Time According To The
;         Sytem Timer Of 18.2 Mhz
;----------------------------------------------
Wait_Timer proc           
WTAG:                             
   mov al,TotalOld   ; Old Ticker              
   cmp al,Total      ; If Changed ,WTEN
   jne WTEN                   
   jmp WTNX          ; On Equal, WTNX         
WTEN:                         
   inc TTime           ; Increment, On Change         
   mov al,17           ; 18(18.2) = Once In a Second
   sub al,Snake_Input  ; 17 - (User Input) = Delay  
   cmp TTime,al        ; Compare Delay  
   je WTEN1            ; On Equal. WTEN1  
                                        
WTNX:                                   
    mov al,Total       ; Update Old Total                 
    mov TotalOld,al    ; To New One , And               
    GetTick Total      ; Read Ticks Again
                                        
    jmp WTAG           ; Jump To Start
                                   
WTEN1:                 ; Delay Ended   
   mov TTime,0                    
   mov Total,0                                 
                                   
ret                                
endp                               
;----------------------------------------------  
; Input: ArrX, ArrY                                      
; Output: Move Each Cell Of The Snake, To 
;         One Cell Back,(Last Erased) And Put 
;         Space To The Last Cell. This Simulate
;         Snake Movement Forward.              
;----------------------------------------------
Replace_Snake PROC         
mov si,OFFSET ArrX  ; ArrX Offset       
mov di,OFFSET ArrY  ; ArrY Offset      
                           
mov cl,[si]                
mov ch,[di]                
mov TmpX,cl                
mov TmpY,ch                
PUTCHAR TmpX,TmpY,' ' ; Put Space In Last
mov si,OFFSET ArrX         
mov di,OFFSET ArrY         
mov  bx,0                  
                                
GO:                        
mov al,[si+bx+1]    ; Read Next Cell (x+1)
mov [si+bx],al      ; Set To Current (x)       
mov al,[di+bx+1]    ; Read Next Cell (y+1)           
mov [di+bx],al      ; Set To Current (y)                     
                                               
inc bx                     
cmp bl,Snake_Size   ; Until Snake Size       
jne GO                     
                           
ret                        
endp Replace_Snake         
;----------------------------------------------  
; Input:  Key_Pressed                                    
; Output: Change DirX,DirY According To The Key
;         And Update X,Y (Snake Head)
;----------------------------------------------
Move_Snake proc           
    mov al,Key_Pressed    
    cmp al,20H ; Right Key
    je RI                 
    jmp R1                
RI: cmp DirX,-1; Opposite Dir, Return
    je  R4                           
    mov DirX,1                       
    mov DirY,0                                 
R1: cmp al,1EH ; Left Key       
    je LF                      
    jmp R2                  
LF: cmp DirX,1 ;Opposite dir, Return
    je R4                           
    mov DirX,-1                     
    mov DirY,0                      
R2: cmp al,11H ; Up Key             
    je UP                           
    jmp R3                          
UP: cmp DirY,1 ; Opposite Return
    je R4                      
    mov DirY,-1                
    mov DirX,0                      
R3: cmp al,1FH ; Down Key           
    je DU                           
    jmp R4                          
DU: cmp DirY,-1; Oposite, Return
    je R4                         
    mov DirY,1                                 
    mov DirX,0                      
R4:                                 
                                    
    mov al,DirX            
    add X,al     ; Update X         
    mov al,DirY            
    add Y,al     ; Update Y         
                           
ret                        
endp Move_Snake            
                           
;----------------------------------------------  
; Input:  ArrX,ArrY                                    
; Output: Put New Position To The Max Cell In
;         The Array, And Print The Head                                    
;----------------------------------------------
Update_Snake proc          
mov si,OFFSET ArrX         
mov di,OFFSET ArrY                
xor bx,bx                                      
mov bl,Snake_Size   ;Bx = Max Snake Size        
mov cl,X                        
mov [si+bx],cl      ;si + bx = Are The Address To Final Cell X
mov cl,Y            
mov [di+bx],cl      ;di + bx = Are The Address To Final Cell Y
PUTCHAREX X,Y,'*',15                         
                            
ret                        
endp Update_Snake          
;----------------------------------------------  
; Input: X,Y : Snake Head                                     
; Output:  ; Checks The Box Limitations                                   
;----------------------------------------------
Check_Walls proc           
     cmp X,1   ; X1           
     je EX                 
     cmp X,79  ; X2       
     je EX             
     cmp Y,0   ; Y1               
     je EX                                     
     cmp Y,24  ; Y2       
     je EX             
     jmp EX1           
                       
EX: SHOWERROR Err_Walls   ; On Error, Show Error
    Call Exit_Snake       ; Exit Snake         
EX1:                                           
ret                                            
endp Check_Walls                               
;----------------------------------------------  
; Input:  ArrX, ArrY, X,Y
; Output: Checks The X,Y Valus In The ArrX,ArrY
;         (Snake Touch Himeself)
;----------------------------------------------
Check_Snake proc                               
mov si,OFFSET ArrX                             
mov di,OFFSET ArrY                             
mov  bx,0                                      
                                               
TRY:                                           
        mov al,[si+bx]  ; Read X Value                       
        cmp X,al                               
        Jne ENDTRY      
        mov al,[di+bx]  ; Read Y Value 
        cmp Y,al                 
        Jne ENDTRY      
        SHOWERROR Err_Snake ; Found, Show Error 
        CALL Exit_Snake     ; Exit Snake                   
                             
ENDTRY: inc bx              ; Inc Index    
        cmp bl,Snake_Size   ; Check For End  
        jne TRY               
                              
        ; Check Max Snake Size 
        mov al,Snake_Size         
        cmp al,Snake_Max_Size     
        jne ENDSIZE           
        SHOWERROR Err_Size    
        Call Exit_Snake           
                                               
ENDSIZE:                         
ret                           
endp Check_Snake         
;----------------------------------------------  
; Input: Mx,My,X,Y                                     
; Output: Check Equal Of Mx=X,My=Y                                    
;----------------------------------------------
Check_Mouse proc                  
                                  
 mov cl,MX                        
 mov dl,MY                        
                                  
 cmp cl,X                         
 jne MOUSEND                      
 cmp dl,Y                         
 jne MOUSEND                      
                                  
 ; Found, Do Stuff...             
 Call Randomize_Mouse   ; Random New Mouse          
 inc Snake_Size         ; Increment Snake Size         
 inc Snake_Score        ; Increment Snake Score         
 SHOWSCORE 12,24        ; Update Snake Score
 Call Do_Sound          ; Play Sound
                       
MOUSEND:                        
ret                    
endp Check_Mouse       
;----------------------------------------------  
; Input:  Snake_Score In DW
; Output: Print To The Screen Snake_Score
;         Converted To Numeric Chars.
;         (Start 12,24)
;----------------------------------------------
Update_Score proc                 
 mov ax,Snake_Score               
 mov cl,10                        
 div cl               ; (SS mod 10)(LSB)  -> bl
 mov bl,ah            ; (SS div 10)(REST) -> TmpVar
 mov TmpVar,al                 
 add bl,48            ; Convert To Numeric Char
 PUTCHAR TmpX,TmpY,bl     ; Print LSB Char
 mov ah,0                                      
 mov al,TmpVar          ; al <- TmpVar (REST)
 mov cl,10            ; And Go On, 
 div cl               ; In That Algorithm
 mov bl,ah            ; 4 Times.  
 mov TmpVar,al        ; .
 add bl,48            ; .         
 dec TmpX                 
 PUTCHAR TmpX,TmpY,bl     
 mov ah,0                         
 mov al,TmpVar      
 mov cl,10                        
 div cl                           
 mov bl,ah                        
 mov TmpVar,al                      
 add bl,48                        
 dec TmpX
 PUTCHAR TmpX,TmpY,bl
 mov ah,0                         
 mov al,TmpVar 
 mov cl,10               
 div cl                  
 mov bl,ah                                     
 mov TmpVar,al             
 add bl,48                            
 dec TmpX
 PUTCHAR TmpX,TmpY,bl
                                      
ret                                   
endp                                  
;----------------------------------------------  
; Input:  Empty                                     
; Output: Create New Values For Mx, My
;         From Tick Counter (18.2 Mhz) 
;----------------------------------------------
                                      
Randomize_Mouse proc                  
 PUTCHAREX MX,MY,'*',15               
                                      
GetTick MX
 xor ax,ax                            
 mov al,MX                            
 mov cl,77                            
 div cl        ;[(0..255) mod 77] = Value Between (0..76)
 mov MX,ah                            
;------------                         
GetTick MY
 xor ax,ax                            
 mov al,MY                            
 mov cl,23                            
 div cl        ;[(0..255) mod 23] = Value Between (0..22)                       
 mov MY,ah                            
                                      
add MX,2       ; Between (2..78)                       
add MY,1       ; Between (1..23)                      
                                      
 PUTCHAREX MX,MY,' ',16   ; Print New Mouse            
                                      
ret                                   
endp Randomize_Mouse                  
;----------------------------------------------  
; Input:  Conrol Byte                                     
; Output: Init The 8254 To Sound Enable                                    
;----------------------------------------------
Init_Speaker proc         
     mov al,0b6h   ; control byte (counter 2      , 
                   ;               square wave   ,
                   ;               no BCD         ,
                   ;               8 low + 8 high ,
                   ;               mode 1,1)  
     mov dx,43h    ; 43h = control byte address of 8254
     out dx,al     ; Send       
ret                       
endp Init_Speaker         
;----------------------------------------------  
; Input:   Empty                                    
; Output:  Stop The Speaker
;----------------------------------------------
Stop_Speaker proc              
 mov dx ,61h           ; Port of The Speaker Bit        
 mov al,00000000b      ; set  speaker off
 out dx,al                     
ret                            
endp Stop_Speaker                              
;----------------------------------------------  
; Input:  Empty                                    
; Output: Update 8254 To Frequency For Sound                                    
;----------------------------------------------
Play_Note proc                              
 push dx                                    
push ax                                     
                                            
    mov dx ,61h                 
    mov al,00000011b   ; Open Speaker
    out dx,al                   
                                
    mov bx,11d0h                
    mov al,bl          ; set first 8 low byte
    mov dx,42h         ; to the port of counter 2 (42h)
                                
    out dx,al                   
                                
    mov al ,bh         ;set second high 8 byte
    out dx,al                                  
                                
pop ax                   
 pop dx                  
                         
  ret                    
                 
endp Play_Note   
;----------------------------------------------  
; Input:  Empty                                      
; Output: Make Small Software Delay Of Loops
;         To Play Quick Sound      
;----------------------------------------------
Delay_Note proc near   
push cx                
push bx                
  mov cx,66h            
    cycle1:            
            mov bx,0ffffh
     loop1: dec bx     
            cmp bx,0                           
            jne loop1  
            loop cycle1
pop bx                 
pop cx                 
                       
  ret                  
endp Delay_Note        
;----------------------------------------------  
; Input:  Empty                                     
; Output: Like It Sounds, Play Sound :-)                                    
;----------------------------------------------
Do_Sound proc          
 Call Play_Note            
 Call Delay_Note           
 Call Stop_Speaker         
ret                        
endp Do_Sound              
;----------------------------------------------  
; Input:  User Input From Keyboard                                     
; Output: Snake_Input                                    
;----------------------------------------------
User_Input proc            
                           
        mov Input_Count,0     
                           
 Ag1:   mov ah,1 ; Read Key
        int 21h            
                           
        cmp al,13  ; On Enter
        je EN      ; Exit    
                           
        cmp al,48  ; Not Valid,Clear 
        jl Bk              
                           
        cmp al,57          
        jg Bk    ; Not Valid,Clear
                         
        mov dl,al            ; dl <- Current Char Input   
        mov al,Snake_Input   ; al <- Current Snake Input   
        mov cl,10                              
        mul cl               
        mov Snake_Input,al   ; Snake_Input = Snake_Input * 10   
        sub dl,48            ; Convert From Char To Number   
        add Snake_Input,dl   ; Snake_Input += dl  
                                
        inc Input_Count      ; Count Num Of Chars
        cmp Input_Count,2    ; On 2 And More, Try Again   
        jne Ag1                                      
                                                     
        Jmp En               ;Here is Success of 2 Chars
                                                      
 Bk:    mov ah,3      ; Read Cursor                       
        mov bh,0                                      
        int 10h                                       
        sub dl,1      ; One Step Back                                    
        GOTOXY dl,dh  ; Going Back                                
        mov TmpX,dl                                   
        mov TmpY,dh                                   
        inc TmpX                                      
        PUTCHAR TmpX,TmpY,' ' ; Printing Space                        
        jmp Ag1                 
                             
                             
EN:  mov al,Snake_Input      
     cmp al,0             ; On First Time Enter TRY Again
     je AG2                  
     cmp al,15            ; On Val < 15 , Play Snake     
     jle EN1                  
                             
AG2: mov Input_Count,0    ; Not Valid, Trying All Back   
     mov Snake_Input,0       
     GOTOXY 21,1             
     PUTCHAR 22,1,' '         
     PUTCHAR 23,1,' '      
                           
     jmp Ag1                          
EN1:                       
ret                        
endp User_Input            
;----------------------------------------------  
; Input:  
; Output: Set Cursor On                                    
;----------------------------------------------       
Cursor_On proc
   mov al,6   
   mov cl,12  
   MOV AH,1   
   MOV CH,0Ah 
  INT 10H     
ret           
endp 
;----------------------------------------------  
; Input:  
; Output: Set Cursor Off                                    
;----------------------------------------------                
Cursor_Off proc
   mov al,0
   mov cl,0
   MOV AH,1   
   MOV CH,14
  INT 10H  
ret       
endp      
;----------------------------------------------  
; Input:   Empty
; Output:  Main Procedure Of The Game    
;----------------------------------------------
main    proc                       
        mov     ax,@data           
        mov     ds,ax              
                               
        call clear_screen           ; Clear Screen  
        call prepare_background     ; Draw Box         
        PUTTEXT 1,1,GameInput       ; Draw Input String
        Call User_Input             ; User Input
                                    
        call clear_screen           ; Clear Screen  
        call prepare_background     ; Draw Box  
        call prepare_snake          ; Init And Draw Snake
        Call Init_Speaker           ; Init Speaker To Sound  
        SHOWSCORE 12,24             ; Print Score
                                   
        PUTCHAREX MX,MY,' ',16      ; Print First Mouse In Middle
        PUTTEXT 30,0,GameTitle      ; Print Title String      
        PUTTEXT 1,24,GameScore      ; Print Score String     
                                   
        Call Cursor_Off             ; Clear Cursor
                               
        dec Snake_Size             ; Start Of 0
                                    
Main_Loop:                          
                                    
        ; Wait Time Acording To 8254 18.2 Mhz Timer
        Call Wait_Timer             
                                    
                                    
        ; Return The KeyBoard Key                      
        Call Try_Sound_Key          
        Call Check_Key                         
                                 
        ; Main Algorithm Of The Snake
        Call Move_Snake
        Call Replace_Snake
        Call Update_Snake
                         
        ; Conditions Of The Snake
        Call Check_Walls         
        Call Check_Snake 
        Call Check_Mouse
                         
        ; Check Escape Break
        mov dl,Key_Pressed
        cmp dl,1H        
    
    
        jne Main_Loop    
                                                
;---------------------------------------------------------
        PUTCHAREX MX,MY,' ',0     ; Clear Final Mouse
        SHOWERROR Err_Esc         ; Show Escape Error
        Call Cursor_On            ; Set Cursor On
                                     
        mov     ax,4C00h              
        int     21h                  
main    endp                         
end main                             
