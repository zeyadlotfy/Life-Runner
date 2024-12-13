title LifeRunner

;****************************************************************************;
;*********************  MACRO TO SCROLL SPECIFIC ROWS to SPECIFIC   *********************;

; starting row:    the upper line
; ending row:      the bottom line

; starting column: the left line 
; ending column:   the right line
SetResolution macro srow,scol,erow,ecol,attrib 
    mov al,0h
    mov bh,attrib
    
    ; defining the rectangle resolution 
    mov ch,srow
    mov cl,scol
    mov dh,erow
    mov dl,ecol
    
    mov ah,06h ; we can say drawing a rectangle with filled color[attribute] 
    int 10h

endm 

;****************************************************************************;
;*********************  MACRO TO Copy two Elements into another *********************;

copy macro row1,oldrow,col1,oldcol

    mov bl,row1
    mov oldrow,bl
    mov bl,col1
    mov oldcol,bl

endm

;****************************************************************************;
;*********************  MACRO TO Print a String *********************;

print macro string 
    mov dx,offset string

    mov ah,09h ; display string which is stored at DS:DX -> offset stored in dx 
    int 21h
endm

;****************************************************************************************************;
;*********************  MACRO TO write specific element with specific attributes*********************;


write macro  elem,attrib
    mov bh,0h  ; page number to display character
    mov cx,01h ; number of times to write character
    mov bl,attrib
    mov al,elem ; character to display

    mov ah,09h ; write character and attribute at cursor position 
    int 10h
endm
;****************************************************************************;
;****************************************************************************;

;****************************************************************************************************;
;*******************    MACRO TO SET THE CURSOR POSITION at SPECIFIC Row and column *****************;

setCursor macro row,col
    mov bh,0h ; page number
    mov dh,row ; row
    mov dl,col ; column
    
    mov ah,02 ; set  the cursor position
    int 10h

endm

;****************************************************************************;
;****************************************************************************;


.model small    ;define the model of the programe to small
.stack 64h  ;reserve 64 h places reserve in Stack for variables

.data
row1 db 23      ;row of player
col1 db 37      ;column of player
oldrow db 23    ;old row of player
oldcol db 37    ;old column of player
youwin db 'congratulations you have saved your life $'   ;string to print the indicator of win
intro db '      Life Runner Game $' ;string to print the starting text
spoint db 'Your life starts at the pink point $'    ;string to print the starting text
epoint db 'You must reach the red point. $'   ;string to print the starting text
press db 'Press Any Key to Continue $'  ;string to print the starting text
ulabel db '^ $'
maze db ' Avoid Enemies $'

lrlabel db 'Controls are :         < + > $'
dlabel db 'v $'

llabel db 'Game Over, you lost your life $'
;********************************************************************************


;*************  rows and columns of enemy 1 *******************
e1col db 49
e1row db 3
e1oldcol db 49
e1oldrow db 3

;*************  rows and columns of enemy 2 *******************

e2row db 15
e2col db 25
e2oldrow db 15
e2oldcol db 25


;*************************************************************************************


.code

main proc far

    mov ax,@data
    mov ds,ax

    jmp gamestart

;*****************  up down left and right labels for player    ************************
    go_up:
            dec row1
jmp back

go_down:
        inc row1
jmp back

go_left:
        dec col1
jmp back

go_right:
        inc col1
jmp back

;****************************************************************************************

gamestart:  ;label indicating that the game is start
    
    call IniFrame ; the 1st screen function
    call GameFrame; the 2nd screen function


;**************************************************************
;*************write the @ at starting point
setCursor 23,37 
write 'P',0A0h


alive:
    call ENEMY  ;call the enemy for the movements of ememies
    
    copy row1,oldrow,col1,oldcol
    
    mov ah,08h  ;read the input from the user 
    int 21h
    
    ;************************************************************************
    ;************* comparisn for the player movement with arrow keys ascii***
    
    cmp al,75       ;left
    je go_left
    
    cmp al,72       ;up
    je go_up
    
    cmp al, 77  ;right
    je go_right
    
    cmp al,80   ;down
    je go_down
    
    CMP al,27
    je exit
    
    ;**************************************************************************
    
    
    back:   ;label after setting up the player row and column
        CALL GameFrame  ;draw the game frame
        setCursor row1,col1 ;set cursor at row1 and column1
        call GetAttribute   ;get the attribute and store it in ah
        cmp ah,00h ; compare the ah with the red colour which indicate the winning point
        je win  
        cmp ah,0E0h ;compare the ah with the 0E0h (orange) which indicate the enemy
        je lose
        cmp ah,099h ;compare the ah with 099h which indicate the colour of the walls
        jne move_cursor ;jump to move if the colour is not blue
        je go_back  ;else jump to go back to same position
        
compare:
        cmp al,'+'      ;compare the + the hotkey to stop the loop
        jne alive
;**********************************************************************************;
;**************************** label indicatiing the winning goal*******************;
;**********************************************************************************;
win:    
    SetResolution 0,0,24,79,07h
    setCursor 10,23
    print youwin
    mov ah,01h
    int 21h
    jmp exit
    
;**********************************************************************************;
;****************************label indicatiing the loosing goal*******************;
;**********************************************************************************;
lose:

    SetResolution 0,0,24,79,07h
    setCursor 10,23
    print llabel
    mov ah,01h
    int 21h
;**********************************************************************************;
;***************************label indicatiing the exit point*********************************;
;**********************************************************************************;

exit:
    SetResolution 0,0,24,79,07h
    mov ax,4c00h
    int 21h
;**********************************************************************************;
;**********************************************************************************;

move_cursor:    ;label to write @ at the cursor positin
        write 'P',0A0h


jmp compare

go_back:    ;if there is a wal then go back to the previus position

        mov bl,oldrow
        mov row1,bl
        mov bl,oldcol
        mov col1,bl
        setCursor row1,col1
jmp move_cursor



main endp




IniFrame proc near  ;procedure to set the front page of the screen
    
   ;SetResolution srow,scolumn, erow, ecolumn, attribute 
   SetResolution   0 ,   0   ,  24 ,   79   ,   0Fh
   
   
   ;setCursor row, column (text)
    setCursor  8 ,   21
    print intro
    
    setCursor  9 ,   21
    print spoint
    
    setCursor  10,   21
    print epoint
    
    setCursor  11,   46
    print ulabel
    
    setCursor  12,   21
    print lrlabel
    
    setCursor  13,   46
    print dlabel
    
    setCursor  14,   25
    print press
    
    mov ah,01h ;Read character from standard input
    int 21h
    ret

IniFrame endp 


GameFrame proc near ;procedure to set the frame of the game

SetResolution 0,0,24,79,77h     ;to clear the screen
    
    SetResolution 0,0,1,79,99h
    SetResolution 0,0,23,2,99h
    SetResolution 23,0,24,79,99h
    SetResolution 1,77,24,79,99h
    SetResolution 23,36,23,38,0DDh

    SetResolution 10,29,16,50,99h
    SetResolution 13,43,16,44,77h
    SetResolution 13,33,13,44,77h

    SetResolution 14,33,14,34,077h
    SetResolution 15,33,15,34,00h
;0CC
    SetResolution 17,39,22,42,099h

    SetResolution 19,9,20,39,099h
    SetResolution 4,6,20,9,099h

    SetResolution 4,14,5,40,099h
    SetResolution 2,33,5,36,099h

    SetResolution 8,14,16,16,099h
    SetResolution 15,14,16,24,099h

    SetResolution 4,40,7,43,099h
    SetResolution 6,21,14,24,099h
    SetResolution 4,48,9,50,099h
    SetResolution 6,51,7,63,099h    
    SetResolution 10,55,15,57,099h
    SetResolution 6,68,20,71,099h
    SetResolution 18,45,20,71,099h
    
    SetResolution 19,45,20,71,099h
    SetResolution 20,45,23,47,099h
    SetResolution 12,57,13,68,099h
    SetResolution 11,32,11,48,03eh
    
    setCursor 11,33
    print maze
    
    setCursor e1row,e1col
    write 'O',0E0h
    
    setCursor e2row,e2col
    write 'O',0E0h
    
    ret

GameFrame endp

GetAttribute proc near ;procedure to get the attribute of the cursor position

mov ah,08h
mov bh,0h
int 10h
ret
GetAttribute endP


random proc near    ;procedure to get a random number

   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

   mov  ax, dx  ; to use it in the division process
   mov  dx, 0h  ; reset the dx value
   mov  cx, 6    
   div  cx       ; here dx contains the remainder of the division - from 0 to 6
   ; divide the AX by 4 and the result will be stored in AX and the remainder in DX[0 - 3] bcz the remainder will be less than the divisor 4
   add  dl, '0'  ; converting the number stored in dx to ascii from '0' to '6'
   ret
random endP


ENEMY proc near ;procedure to control the movements of the ememies 
jmp start1  ;jump to go to the starting instruction of the procedure

;labels for enemy 1 movements

e1_up:
    dec e1row 
    
    setCursor e1row,e1col
jmp e1done


e1_down:
    inc e1row 
    
    setCursor e1row,e1col
jmp e1done



start1:
    copy e1row,e1oldrow,e1col,e1oldcol
    
    call random     ;call the procedure random
    
    ;**********************************************************************************;
    ;****************************set the position acccording to the random number******;
    ;**********************************************************************************;

    cmp dl,'0'
    je e1_up
    
    cmp dl,'1'
    je e1_down
    
    cmp dl,'2'
    je e1_right
    
    cmp dl,'3'
    je e1_left
    
    cmp dl,'4'
    je e1_down

    cmp dl,'5'
    je e1_right

    e1done:
    call GetAttribute
    cmp ah,0B0h
    je e1_goback
    cmp ah,099h
    jne e1moved
    cmp ah,099h
    je e1_goback
    
    
    e1moved:    
    jmp enemy1Ind
    
;*****************  up down left and right labels for ememy 1   ************************
    e1_left:
        dec e1col 
        setCursor e1row,e1col
        jmp e1done
    
    e1_right:
        inc e1row 
        setCursor e1row,e1col
        jmp e1done
        
    e1_goback:
        copy e1oldrow,e1row,e1oldcol,e1col 
        setCursor e1row,e1col
        jmp e1moved
        
    copy e2row,e2oldrow,e2col,e2oldcol
    
    enemy1Ind:
    call random
    cmp dl,'0'
    je e2_up
    cmp dl,'1'
    je e2_down
    cmp dl,'2'
    je e2_right
    cmp dl,'3'
    je e2_left

    
    e2moved:    
    ret
    
    e2done:
    call GetAttribute
    cmp ah,099h
    jne e2moved
    
    cmp ah,099h
    je e2_goback
    
    cmp ah,0B0h
    je e2_goback
    
;*****************  up down left and right labels for enemy 2   ************************
    e2_up:
    dec e2row
     setCursor e2row,e2col
         
    jmp e2done


    e2_down:
        inc e2row
         setCursor e2row,e2col
         
    jmp e2done
    e2_left:
        dec e2col
         setCursor e2row,e2col
         
    jmp e2done
    e2_right:
        inc e2row
         setCursor e2row,e2col
         
    jmp e2done
    e2_goback:
        copy e2oldrow,e2row,e2oldcol,e2col      ;use the macro copy to copy the values
         setCursor e2row,e2col
        jmp e2moved
    jmp e2done


   
ENEMY endp


end main