;                                                                         
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓                                                                         ▓
;▓                            NUNO MARTINS 99292                           ▓
;▓                                                                         ▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

;=================================================================
; CONSTANTES
;-----------------------------------------------------------------

stackInit       EQU     7000h
dim             EQU     80

read            EQU     FFFFh
write           EQU     FFFEh
status          EQU     FFFDh
cursor          EQU     FFFCh	; posiciona o cursor no terminal
color           EQU     FFFBh	; muda as cores do terminal

disp_0          EQU     FFF0h
disp_1          EQU     FFF1h
disp_2          EQU     FFF2h
disp_3          EQU     FFF3h
disp_4          EQU     FFEEh
disp_5          EQU     FFEFh

timer_control   EQU     FFF7h
timer_counter   EQU     FFF6h
timer_setstart  EQU     1
timer_setstop   EQU     0
timercount      EQU     1

int_mask        EQU     FFFAh
int_mask_value  EQU     80FFh ; 1000 0000 1111 1111 b

altura_max      EQU     7

dino_symbol     EQU     '█'
cactus_symbol   EQU     '╬'
solo_symbol1    EQU     '_'

solo_symbol2    EQU     '░'

solo_symbol3    EQU     '▀'

;=================================================================
; VARIAVEIS GLOBAIS
;-----------------------------------------------------------------

ORIG            0000h

dino_str1       STR     '           ,  ;:._.-`''.',0
dino_str2       STR     '         ;.;`.;`      _ `.',0
dino_str3       STR     '          `,;`       ( \ ,`-. ',0
dino_str4       STR     '       `:.`,         (_/ ;\  `-.',0
dino_str5       STR     '        `;:              / `.   `-',0
dino_str6       STR     '      `;.;`              `-,/ .     `',0
dino_str7       STR     '      `;;`              _    `^`       `',0
dino_str8       STR     '    `;;;            ,`-` `--._          ;',0
dino_str9       STR     ' `;`;,         ,;     `.    `:`,,.__,,_ /',0
dino_str10      STR     '`;           ,;  `.     ;,    `;`;`:`;;`',0
dino_str11      STR     '          .,; `    `-._ ``:.;    ',0
dino_str12      STR     '        .:;            `._ ``;;,',0
dino_str13      STR     ',.,,.,;:`                 `,__.)',0


credits_str     STR     'Made by Inês Pissarra 99236 & Nuno Martins 99292',0
gameover_str1   STR     'GAME OVER',0
gameover_str2   STR     'Play again? Press button [0]',0



title_str1      STR     '▓  ╔═════════╗  ▓',0
title_str2      STR     '▓══╣         ╠══▓',0
title_str3      STR     '▓  ╚═════════╝  ▓',0
title_str4      STR     'DINO JUMP', 0
title_str5      STR     '┤Button [0] to start├',0
title_str6      STR     '┤Press ↑ to JUMP├',0

x               WORD    5

start           WORD    0

score_1         WORD    0
score_2         WORD    0
score_3         WORD    0
score_4         WORD    0
score_5         WORD    0
score_6         WORD    0

timer_tick      WORD    0

ORIG            3000h
game_over       WORD    0
saltar          WORD    0 ;quando carregar na uparrow fica saltar=10
altura_dino     WORD    1
altura_cacto    WORD    0
score           WORD    0
max_score       WORD    0
ORIG            4000h

inicio          TAB     dim

;                                                                         
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓                                                                         ▓
;▓                                PROGRAMA                                 ▓
;▓                                                                         ▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

ORIG            0000h

MAIN:           MVI     R6, stackInit ;inicializar pilha
                ;--------------------------------------------   
                JAL     credits
                ;--------------------------------------------
.new_game:      MVI     R1, color
                MVI     R2, 00FFh
                STOR    M[R1], R2 ; colocar fundo preto e letras brancas
                ;--------------------------------------------
                DSI               
                ;--------------------------------------------
                MVI     R1, int_mask
                MVI     R2, int_mask_value
                STOR    M[R1], R2
                ;--------------------------------------------   
                MVI     R1, inicio
                MVI     R2, dim   ;R1 e R2: argumentos da funcao ResetTerreno
                JAL     ResetTerreno
                ;--------------------------------------------
                ENI
.start_loop:    MVI     R1, start
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    .start_loop ; loop infinito até carregar no botao B0
                DSI
                ;--------------------------------
                JAL     reset_variables 
                ;--------------------------------
                JAL     remove_gameover
                ;--------------------------------                
                ENI
                MVI     R2,timercount 
                MVI     R1,timer_counter
                STOR    M[R1],R2  ; set timer
                MVI     R1, timer_tick
                STOR    M[R1],R0 ; limpar timer ticks
                MVI     R1,timer_control
                MVI     R2,timer_setstart
                STOR    M[R1],R2 ; iniciar timer 
                ;--------------------------------
.refresh:       MVI     R2, timer_tick
.LOOP:          LOAD    R1,M[R2]
                CMP     R1, R0
                BR.Z    .LOOP ;loop até timer_tick ser incrementado
                DSI
                DEC     R1
                STOR    M[R2],R1
                ENI
                ;--------------------------------
                JAL     pos_dino
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 00E1h
                STOR    M[R1], R2 ; colocar fundo preto e letras vermelhas
                ;--------------------------------
                JAL     atualiza_salto
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 003Ch
                STOR    M[R1], R2 ; colocar fundo preto e letras verdes
                ;--------------------------------
                MVI     R1, inicio
                MVI     R2, dim  ;R1 e R2: argumentos da funcao atualizajogo
                JAL     atualizajogo
                ;--------------------------------
                MVI     R1, altura_cacto
                LOAD    R1, M[R1]
                MVI     R2, altura_dino
                LOAD    R2, M[R2]
                CMP     R2, R1
                BR.P    .next    ; verificar se altura_dino > altura_cacto
                ;--------------------------------
                MVI     R1, game_over ; se nao, entao game_over = 1
                MVI     R2, 1
                STOR    M[R1], R2
                ;--------------------------------
.next:          MVI     R1, game_over ;se altura_dino <= altura_cacto, 
                LOAD    R2, M[R1]     ;game_over = 0 e novo loop em .refresh
                CMP     R2, R0
                BR.Z    .refresh
                ;--------------------------------
                JAL     gameover_term ; se game_over = 1 entao gameover_term
                ;--------------------------------
                ENI     ; ativar interrupcoes
.game_over:     MVI     R1, start
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    .game_over ; loop infinito até carregar no botao B0
                DSI     ; desligar interrupcoes
                ;--------------------------------
                BR      .new_game ; recomeçar novo jogo
                ;--------------------------------
Fim:            BR      Fim

;                                                                         
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓                                                                         ▓
;▓                         FUNÇÕES PRINCIPAIS                              ▓
;▓                                                                         ▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

;============================================================================
; credits: esta função desenha no terminal as coisas que são para ficar     
; fixas independentemente de ser game_over ou não. São elas: o chão
; que é composto por 3 camadas; os creditos (que é a frase 'Made by...');
; o dinossauro gigante a branco (que é a excepçao de mudança uma vez que irá 
; ficar vermelho quando ocorrer game over); o dino que é o nosso boneco do
; jogo (que salta); o titulo do jogo e as instruçoes à sua direita.
;---------------------------------------------------------------------------- 

credits:        DEC     R6
                STOR    M[R6], R7
                ;--------------------------------
                MVI     R1, 2100h ; ponto (33,0) do terminal
                MVI     R2, dim 
                MVI     R5, solo_symbol1
                JAL     ResetTerminal
                MVI     R1, 2200h ; ponto (34,0) do terminal
                MVI     R2, dim 
                MVI     R5, solo_symbol2
                JAL     ResetTerminal 
                MVI     R1, 2300h ; ponto (35,0) do terminal
                MVI     R2, dim 
                MVI     R5, solo_symbol3
                JAL     ResetTerminal             
                ;--------------------------------
                MVI     R2, 2811h
                MVI     R3, credits_str
                JAL     credit_draw
                ;--------------------------------
                JAL     dino_draw ; desenhar dino a branco
                ;--------------------------------
                MVI     R2, 0125h
                MVI     R3, title_str1
                JAL     credit_draw
                MVI     R2, 0225h
                MVI     R3, title_str2
                JAL     credit_draw
                MVI     R2, 0325h
                MVI     R3, title_str3
                JAL     credit_draw
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 003Ch
                STOR    M[R1], R2 ; terminal fundo preto letras verdes
                
                MVI     R2, 0229h
                MVI     R3, title_str4
                JAL     credit_draw 
                MVI     R2, 0138h
                MVI     R3, title_str5
                JAL     credit_draw
                MVI     R2, 033Ah
                MVI     R3, title_str6
                JAL     credit_draw
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 00E1h
                STOR    M[R1], R2 ; terminal fundo preto letras vermelhas
                ;--------------------------------
                MVI     R2, 2010h ; dino no ponto (32,16)
                MVI     R1, cursor
                STOR    M[R1], R2
                MVI     R1, write
                MVI     R2, dino_symbol
                STOR    M[R1], R2  ; colocar o DINO no terminal (cor vermelha)
                ;--------------------------------
                LOAD    R7, M[R6]
                INC     R6
                
                JMP     R7

;===========================================================================
; ResetTerreno (Reseta o terreno e poe todos os valores da tabela a 0)
;---------------------------------------------------------------------------

ResetTerreno:   STOR    M[R1], R0
                INC     R1
                DEC     R2
                CMP     R2, R0
                BR.NZ   ResetTerreno
                ;--------------------------------
                JMP     R7

;===========================================================================
; reset_variables (esta função reseta as variáveis de forma a colocá-las no
; seu valor inicial default, de forma a recomeçar o jogo quando o jogador
; assim o entende)
;---------------------------------------------------------------------------
reset_variables:MVI     R1, start
                STOR    M[R1], R0 ; start=0 por default
                ;--------------------------------
                MVI     R1, saltar
                STOR    M[R1], R0 ; saltar=0 por default
                ;--------------------------------
                MVI     R1, score
                STOR    M[R1], R0 ; score=0 por default
                ;--------------------------------
                MVI     R1, altura_cacto
                STOR    M[R1], R0 ; altura_cacto=0 por default
                ;--------------------------------
                MVI     R1, altura_dino
                MVI     R2, 1
                STOR    M[R1], R2 ; altura_dino=1 por default
                ;--------------------------------
                MVI     R1, game_over
                STOR    M[R1], R0 ; game_over=0 por default
                ;--------------------------------
                JMP     R7

;===========================================================================
; pos_dino: com base no valor de saltar, no facto de haver tecla pressionada
; ou não (com base no status ser 1 ou 0) e na tecla pressionada ser ou não ser
; a tecla ↑, esta função incrementa ou decrementa a variavel saltar (e inclusive
; inicia esta variável a 14, de forma a começar um novo salto)
;---------------------------------------------------------------------------
pos_dino:       MVI     R1, saltar ; se saltar != 0 -> .next
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.P    .next
                ;--------------------------------
                MVI     R1, status ; se saltar = 0 e não há tecla pressionada 
                LOAD    R2, M[R1]  ; entao return
                CMP     R2, R0
                BR.Z    .return
                ;--------------------------------
                MVI     R1, read 
                LOAD    R2, M[R1]
                MVI     R3, '↑'
                CMP     R2, R3
                BR.NZ   .return ; se saltar=0 e tecla ↑ nao pressionada return
                ;--------------------------------
                MVI     R1, saltar ; se saltar=0 e tecla ↑ pressionada saltar=14
                MVI     R2, 14
                STOR    M[R1], R2
                ;--------------------------------
.next:          MVI     R5, 7 
                MVI     R1, saltar
                LOAD    R2, M[R1]
                CMP     R2, R5 ; se saltar <= 7: descer, else: subir
                BR.NP   .descer
                ;--------------------------------
                MVI     R3, altura_dino
                LOAD    R4, M[R3]
                INC     R4
                STOR    M[R3], R4 ; altura_dino += 1
                
                BR      .store_var ; saltar para .store_var
                ;--------------------------------
.descer:        MVI     R3, altura_dino
                LOAD    R4, M[R3]
                DEC     R4
                STOR    M[R3], R4 ; altura_dino -= 1  
                ;--------------------------------
.store_var:     MVI     R1, saltar
                LOAD    R2, M[R1]
                DEC     R2
                STOR    M[R1], R2
                ;--------------------------------
.return:        JMP     R7

;===========================================================================
; atualiza_salto (esta função reseta toda a coluna do dinossauro e depois
; com base na altura_dino, coloca o dino_symbol na posiçao correta no terminal
; correspondente à altura do dinossauro nesse instante).
;---------------------------------------------------------------------------
                ; R4 = altura_dino
atualiza_salto: MVI     R2, 8 ; contador
                MVI     R3, 1810h
                MVI     R5, 0100h
                ;--------------------------------
.loop:          MVI     R1, cursor
                STOR    M[R1], R3
                MVI     R1, write
                STOR    M[R1], R0
                ADD     R3, R3, R5
                DEC     R2 
                CMP     R2, R0
                BR.NZ   .loop ;reset_coluna do dino (põe tudo a 0)
                ;--------------------------------
                MVI     R3, altura_dino
                LOAD    R4, M[R3]
                MVI     R2, 0 ; contador (pára quando chega a altura_dino)
                MVI     R3, 2110h
.dino:          INC     R2
                SUB     R3, R3, R5
                CMP     R2, R4
                BR.NZ   .dino
                MVI     R1, cursor
                STOR    M[R1], R3
                MVI     R1, write
                MVI     R5, dino_symbol
                STOR    M[R1], R5
                ;--------------------------------
                MVI     R1, saltar
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    .return
                ;--------------------------------
                MVI     R1, cursor
                MVI     R2, 2010h
                STOR    M[R1], R2
                MVI     R1, write
                STOR    M[R1], R0
                ;--------------------------------
.return:        JMP     R7

;=========================================================================
; atualizajogo: recebe um valor da função geracacto e atualiza os valores
; da tabela 'inicio' da direita para a esquerda, deslocando-os uma posiçao. 
; Após isso, usa a função atualiza_term para atualizar o terminal com base 
; nos novos valores da tabela 'inicio' e usa a função atualiza_score
; para atualizar a pontuação do jogo, assim como colocá-la nos displays
; e no terminal para o jogador ver a sua pontuação em tempo real sem ter
; de observar os displays.
;-------------------------------------------------------------------------

atualizajogo:   DEC     R6
                STOR    M[R6], R7
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R7  
                MVI     R1, 4  ;R1 = argumento da funçao geracacto
                JAL     geracacto
                LOAD    R7, M[R6]
                INC     R6
                LOAD    R1, M[R6] 
                INC     R6
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2 
                ADD     R1, R1, R2  
                DEC     R1      ; ultima posicao tabela
                LOAD    R5, M[R1] 
                STOR    M[R1], R3
                DEC     R1
                DEC     R2
                ;--------------------------------
.loop:          LOAD    R4, M[R1]  ; este é o loop que desloca os valores
                STOR    M[R1], R5  ; da tabela inicio
                MOV     R5, R4
                DEC     R1          
                DEC     R2
                CMP     R2, R0
                BR.NZ   .loop
                ;--------------------------------
                
                MVI     R2, dim
                MVI     R4, 204Fh ; ultima posicao da linha 32 do terminal
                MVI     R5, 404Fh ; ultima posicao da tabela
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R7
                JAL     atualiza_term ; atualiza terminal com base nos novos
                LOAD    R7, M[R6]     ; valores da tabela 'inicio'
                INC     R6
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R7
                JAL     atualiza_score ; atualiza score e atualiza displays
                LOAD    R7, M[R6]
                INC     R6
                ;--------------------------------
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6] 
                INC     R6
                LOAD    R7, M[R6]
                INC     R6
                ;--------------------------------
                JMP     R7 

;===========================================================================
; gameover_terminal (linhas 10, 16): esta função desenha a vermelho no 
; terminal, o dinossauro, a frase 'GAME OVER', assim como a frase 'Play again? 
; Press button [0]' no caso do jogador querer jogar novamente. 
;---------------------------------------------------------------------------

gameover_term:  DEC     R6
                STOR    M[R6], R7
                ;--------------------------------
                MVI     R1,timer_control
                MVI     R2,timer_setstop
                STOR    M[R1],R2 ; parar timer 
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 00E1h
                STOR    M[R1], R2 ; colocar fundo preto e letras vermelhas
                ;--------------------------------
                JAL     dino_draw ; desenhar dinossauro
                ;--------------------------------
                MVI     R1, cursor
                MVI     R4, write
                MVI     R2, 0A38h ;  linha 10
                STOR    M[R1], R2
                MVI     R3, gameover_str1 ; write 'GAME OVER'
.loop1:         STOR    M[R1], R2
                LOAD    R5, M[R3]
                STOR    M[R4], R5
                INC     R3
                INC     R2
                LOAD    R5, M[R3]
                CMP     R5, R0
                BR.NZ   .loop1
                ;--------------------------------
                MVI     R1, cursor
                MVI     R4, write
                MVI     R2, 1030h ; linha 16
                STOR    M[R1], R2
                MVI     R3, gameover_str2 ; write 'Play again? Press button [0]'
.loop2:         STOR    M[R1], R2
                LOAD    R5, M[R3]
                STOR    M[R4], R5
                INC     R3
                INC     R2
                LOAD    R5, M[R3]
                CMP     R5, R0
                BR.NZ   .loop2
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 00FFh
                STOR    M[R1], R2
                ;--------------------------------
                LOAD    R7, M[R6]
                INC     R6
                
                JMP     R7

;===========================================================================
; remove_gameover (linha 10, 13, 16): esta funçao vai limpar o terminal
; nas linhas 10, 13, 16 (para nao limpar o dinossauro começa a limpar a 
; linha na coluna 48 e termina na 78)
;---------------------------------------------------------------------------
remove_gameover:DEC     R6
                STOR    M[R6], R7
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 0000h
                STOR    M[R1], R2 ; colocar fundo preto e letras pretas
                ;--------------------------------
                MVI     R1, 0A30h ; limpar linha 10
                MVI     R2, 30
                MOV     R5, R0
.loop1:         JAL     ResetTerminal
                CMP     R2, R0
                BR.NZ   .loop1
                ;--------------------------------
                MVI     R1, 0D30h ;  limpar linha 13
                MVI     R2, 30
                MOV     R5, R0
.loop3:         JAL     ResetTerminal
                CMP     R2, R0
                BR.NZ   .loop3
                ;--------------------------------
                MVI     R1, 1030h ;  limpar linha 16
                MVI     R2, 30
                MOV     R5, R0
.loop4:         JAL     ResetTerminal
                CMP     R2, R0
                BR.NZ   .loop4
                ;--------------------------------
                MVI     R1, color
                MVI     R2, 00FFh
                STOR    M[R1], R2 ; colocar fundo preto e letras brancas
                ;--------------------------------
                LOAD    R7, M[R6]
                INC     R6
                JMP     R7

;                                                                         
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓                                                                         ▓
;▓       FUNÇÕES AUXILIARES (são usadas detro das funções principais)      ▓
;▓                                                                         ▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;===========================================================================
; ResetTerminal: esta função recebe 3 argumentos: R1 (posiçao do cursor),
; R2 (contador) e R5 (simbolo/valor a escrever no terminal).
;---------------------------------------------------------------------------

ResetTerminal:  MVI     R3, cursor
                STOR    M[R3], R1
                MVI     R4, write
                STOR    M[R4], R5
                INC     R1
                DEC     R2
                BR.NZ   ResetTerminal
                ;--------------------------------
                JMP     R7

;===========================================================================
; atualiza_score: incrementa 1 ao score e escreve-o nos displays e terminal
;---------------------------------------------------------------------------
atualiza_score: DEC     R6
                STOR    M[R6], R3
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                ;--------------------------------
                MVI     R1, score ; incrementa score
                LOAD    R2, M[R1]
                INC     R2
                ;--------------------------------
                MVI     R3, fh
                AND     R3, R2, R3
                MVI     R4, ah
                CMP     R4, R3        ; se R3 < 'a' entao salta para a etiqueta
                BR.P    et            ; e insere o numero no display 
                MVI     R4, 6h        ; caso contrário terá de se adicionar 6
                ADD     R2, R2, R4    ; para passar o numero de hexadecimal
                ADD     R3, R3, R4    ; para decimal
et:             MVI     R1, disp_0
                STOR    M[R1], R3 ; atualiza display 0
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3
                
                MVI     R1, cursor
                MVI     R2, 0D3Eh
                STOR    M[R1], R2
                MVI     R1, write
                MVI     R2, '0'
                ADD     R3, R3, R2
                STOR    M[R1], R3 ; atualiza digito das unidades no terminal
                
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                ;--------------------------------
                MOV     R5, R2
                SHR     R5
                SHR     R5
                SHR     R5
                SHR     R5
                MVI     R3, fh
                AND     R3, R5, R3
                MVI     R4, ah
                CMP     R4, R3
                BR.P    et1
                MVI     R4, 60h
                ADD     R2, R2, R4
                MVI     R4, 6h
                ADD     R3, R3, R4
                ADD     R5, R5, R3
et1:            MVI     R1, disp_1
                STOR    M[R1], R3 ; atualiza display 1
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3
                
                MVI     R1, cursor
                MVI     R2, 0D3Dh
                STOR    M[R1], R2
                MVI     R1, write
                MVI     R2, '0'
                ADD     R3, R3, R2
                STOR    M[R1], R3 ; atualiza digito das dezenas no terminal
                
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                ;--------------------------------
                SHR     R5
                SHR     R5
                SHR     R5
                SHR     R5
                MVI     R3, fh
                AND     R3, R5, R3
                MVI     R4, ah
                CMP     R4, R3
                BR.P    et2
                MVI     R4, 600h
                ADD     R2, R2, R4
                MVI     R4, 6h
                ADD     R3, R3, R4
                ADD     R5, R5, R3
et2:            MVI     R1, disp_2
                STOR    M[R1], R3 ; atualiza display 2
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3
                
                MVI     R1, cursor
                MVI     R2, 0D3Ch
                STOR    M[R1], R2
                MVI     R1, write
                MVI     R2, '0'
                ADD     R3, R3, R2
                STOR    M[R1], R3 ; atualiza digito das centenas no terminal
                
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                ;--------------------------------
                SHR     R5
                SHR     R5
                SHR     R5
                SHR     R5
                MVI     R3, fh
                AND     R3, R5, R3
                MVI     R4, ah
                CMP     R4, R3
                BR.P    et3
                MVI     R4, 6000h
                ADD     R2, R2, R4
                MVI     R4, 6h
                ADD     R2, R2, R4
et3:            MVI     R1, disp_3
                STOR    M[R1], R3 ; atualiza display 3
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R2
                
                MVI     R1, cursor
                MVI     R2, 0D3Bh
                STOR    M[R1], R2
                MVI     R1, write
                MVI     R2, '0'
                ADD     R3, R3, R2
                STOR    M[R1], R3 ; atualiza digito dos milhares no terminal
                
                LOAD    R2, M[R6]
                INC     R6
                ;--------------------------------
                MVI     R1, score 
                STOR    M[R1], R2 ; guardar o novo valor do score na variável
                ;--------------------------------
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                ;--------------------------------
                JMP     R7

;=========================================================================
; atualiza_term : esta função recebe 3 argumentos: R2 (com valor dim (80) 
; que vai servir como contador), R4 (204Fh que corresponde à ultima posicao
; da linha 32 do terminal que é de onde vêm os cactos e R5 (404Fh que
; corresponde à ultima posicao da tabela 'inicio').
;-------------------------------------------------------------------------    
atualiza_term:  MVI     R1, 17 
                CMP     R2, R1 
                BR.NZ   .continue ; enquanto contador != 17, continuar
                                  ; else significa que estamos na coluna
                                  ; do dinossauro e nesse caso vamos guardar
                                  ; o valor da tabela 'inicio' nessa posicao
                                  ; correspondente à altura do cacto nessa 
                                  ; posicao e guardamos esse valor na 
                                  ; variavel altura_cacto
                ;--------------------------------
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                
                MVI     R1, altura_cacto
                LOAD    R2, M[R5]
                STOR    M[R1], R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                BR      next ;proxima posicao
                ;--------------------------------
.continue:      MVI     R1, cursor ; neste caso contador != 17
                STOR    M[R1], R4  ; e vamos ver se a altura do cacto (valor
                LOAD    R3, M[R5]  ; da tabela 'inicio') é igual a 0 ou 'mais'
                CMP     R3, R0     ; se maior que 0
                BR.NZ   mais
                
                DEC     R6
                STOR    M[R6], R2 ; se altura do cacto = 0
                DEC     R6        ; vamos colocar R0 no terminal nas 6 linhas
                STOR    M[R6], R4 ; acima do chão
                DEC     R6        
                STOR    M[R6], R5
                
                MVI     R5, 6
                MVI     R2, 0100h
                
.loop1:         MVI     R1, write
                STOR    M[R1], R0
                SUB     R4, R4, R2
                MVI     R1, cursor
                STOR    M[R1], R4
                DEC     R5
                CMP     R5, R0
                BR.NZ   .loop1
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                
                BR      next
                ;--------------------------------
mais:           DEC     R6
                STOR    M[R6], R2 ; se altura do cacto > 0 então vamos fazer
                DEC     R6        ; um loop x vezes (x é altura do cacto)
                STOR    M[R6], R4 ; colocando em cada linha acima do chão
                DEC     R6        ; 1 simbolo do cacto
                STOR    M[R6], R5
                
                MOV     R5, R3 ; R5 é o contador(tem o valor da altura do cacto)
                
.loop2:         MVI     R2, cactus_symbol
                MVI     R1, write
                STOR    M[R1], R2
                MVI     R2, 0100h
                SUB     R4, R4, R2
                MVI     R1, cursor
                STOR    M[R1], R4
                DEC     R5
                CMP     R5, R0
                BR.NZ   .loop2
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                
                ;--------------------------------
                
                STOR    M[R1], R2
                
next:           DEC     R4
                DEC     R5
                DEC     R2
                CMP     R2, R0
                BR.NZ   atualiza_term ; repete loop se contador != 0
                ;--------------------------------
                JMP     R7
;=========================================================================
; geracacto: esta função retorna um valor aleatório com 95% chance de ser 0
; e 5% de chance de ser um valor entre 1 e o argumento dado à função 
; (neste caso 4), valor esse que corresponde à altura do cacto.
;-------------------------------------------------------------------------

geracacto:      MVI     R3, 0
                MVI     R5, x       
                LOAD    R5, M[R5]
                MVI     R4, 1
                AND     R3, R5, R4
                SHR     R5
                CMP     R3, R0
                BR.Z    .if1                
                MVI     R4, b400h  
                XOR     R5, R5, R4
                ;--------------------------------
.if1:           MVI     R4, x
                STOR    M[R4], R5 ;guardar novo valor de x em x (sobrescrevê-lo)
                MVI     R4, 62258 ;if x<62258: -> If2
                CMP     R5, R4
                BR.C    .if2
                DEC     R1
                AND     R3, R5, R1
                INC     R3 ; else: return (x AND (altura-1)) + 1
                JMP     R7
                ;--------------------------------
.if2:           MVI     R3, 0
                JMP     R7
                
;============================================================================
; dino_draw: esta função desenha o dinossauro gigante (de fundo)
;----------------------------------------------------------------------------

dino_draw:      DEC     R6
                STOR    M[R6], R7
                
                ;--------------------------------
                MVI     R2, 0200h
                MVI     R3, dino_str1
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 0400h
                MVI     R3, dino_str2
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 0600h
                MVI     R3, dino_str3
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 0800h
                MVI     R3, dino_str4
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 0A00h
                MVI     R3, dino_str5
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 0C00h
                MVI     R3, dino_str6
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 0E00h
                MVI     R3, dino_str7
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 1000h
                MVI     R3, dino_str8
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 1200h
                MVI     R3, dino_str9
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 1400h
                MVI     R3, dino_str10
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 1600h
                MVI     R3, dino_str11
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 1800h
                MVI     R3, dino_str12
                JAL     credit_draw
                ;--------------------------------
                MVI     R2, 1A00h
                MVI     R3, dino_str13
                JAL     credit_draw
                ;--------------------------------
                
                LOAD    R7, M[R6]
                INC     R6
                
                JMP     R7

;============================================================================
; credit_draw: esta função recebe como argumentos R2 (posição do cursor) e
; R3 (string a ser desenhada) e desenha no terminal a string desde a posiçao
; do cursor dada como argumento até a string terminar (quando chega a 0).
;----------------------------------------------------------------------------       

credit_draw:    DEC     R6
                STOR    M[R6], R7
                
                MVI     R1, cursor
                MVI     R4, write
.loop:          STOR    M[R1], R2
                LOAD    R5, M[R3]
                STOR    M[R4], R5
                INC     R3
                INC     R2
                LOAD    R5, M[R3]
                CMP     R5, R0
                BR.NZ   .loop
                
                LOAD    R7, M[R6]
                INC     R6
                JMP     R7
                
;============================================================================
; aux_timer: esta função dá auxilio ao timer, incrementado o timer_tick
; de maneira ao programa prosseguir a leitura do código no "tempo certo"
;---------------------------------------------------------------------------- 
                
aux_timer:      DEC     R6
                STOR    M[R6],R1
                DEC     R6
                STOR    M[R6],R2
                ;------------------------
                MVI     R2,timercount
                MVI     R1,timer_counter
                STOR    M[R1],R2 ; restart timer
                MVI     R1,timer_control
                MVI     R2,timer_setstart
                STOR    M[R1],R2  
                MVI     R2,timer_tick
                LOAD    R1,M[R2]
                INC     R1 ; incrementar timer_tick
                STOR    M[R2],R1
                ;------------------------
                LOAD    R2,M[R6]
                INC     R6
                LOAD    R1,M[R6]
                INC     R6
                JMP     R7

;=============================================================================
; Serviços de Interrupção de Rotinas: O botão key 0 (B0), de forma
; a começar/jogar novamente o jogo quando pressionado. Ao carregar nele, 
; a variável global start (que inicialmente está a 0 por default) fica a 1.
; O timer de maneira a que o jogo corra a uma velocidade de 1x100ms
;-----------------------------------------------------------------------------
                
                ORIG    7F00h
                
key_zero:       DEC     R6
                STOR    M[R6], R5
                DEC     R6
                STOR    M[R6], R3
                
                MVI     R5, 1
                MVI     R3, start
                STOR    M[R3], R5 ; start = 1 (the game begins)
                
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R5, M[R6]
                INC     R6
                RTI     ; return from interrupt    
                
                
                ORIG    7FF0h
timer:          DEC     R6
                STOR    M[R6],R7
                
                JAL     aux_timer
                
                LOAD    R7,M[R6]
                INC     R6
                RTI
;-------------------------------------------------------------------------------
