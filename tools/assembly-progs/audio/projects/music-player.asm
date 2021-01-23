; Notes:
; Use EC_ESCAPE combined with other values to change properties of note player

; AUDIO FORMAT:
;
; [ESCAPE CODES]
; OSC0_NOTE
; OSC0_VOLUME
; OSC0_PITCH_BEND
;
; OSC1_NOTE
; OSC1_VOLUME
; OSC1_PITCH_BEND
;
; OSC2_NOTE
; OSC2_VOLUME
; OSC2_PITCH_BEND
;
; [ESCAPE CODES]
; OSC0_NOTE
; OSC0_VOLUME
; OSC0_PITCH_BEND
;
; (and so on)

; ESCAPE CODE FORMAT
; EC_ESCAPE <ESCAPE CODE> <ARGUMENT>
;
; "EC_ESCAPE EC_SONG_END" is the exception as it takes no argument

; Tempo is stored in R2
; Oscillator for EC is stored in R3

; BPM to Tempo
; Tempo = 60/(BPM/60)

ADR BANK_SELECTOR $DFFF
ADR OSC_SELECTOR $E002
ADR AUDIO_REG_SELECTOR $E003
ADR AUDIO_REG_VALUE $E004

LIT AUDIO_BANK #3
LIT CLOCK_BANK #4

LIT HIGHPASS_REG #0
LIT LOWPASS_REG #1
LIT WAVEFORM_REG #2
LIT PULSE_WIDTH_REG #3
LIT NOTE_REG #4
LIT PITCH_BEND_REG #5
LIT PHASE_REG #6
LIT VOLUME_REG #7

ADR CLOCK_CALLBACK_MSB $FFFE
ADR CLOCK_CALLBACK_LSB $FFFF

ADR NOTE_STORAGE_MSB $0
ADR NOTE_STORAGE_LSB $1

ADR TEMPO_COUNTER $2                           ; When this equals R2 (where tempo is stored) go to next note

; Escape codes
LIT EC_ESCAPE            #$FE                    ; Start an escape code with this
LIT EC_SONG_END          #$1                     ; End of song, NO ARGUMENTS
LIT EC_OSC_CHANGE        #$2                     ; Only affects other escape codes
LIT EC_HIGHPASS          #$3
LIT EC_LOWPASS           #$4
LIT EC_WAVEFORM          #$5
LIT EC_PULSE_WIDTH       #$6
LIT EC_PHASE             #$7
LIT EC_TEMPO             #$8                     ; Larger = slower, not mesured in BPM

; Waveforms
LIT PULSE_WAVE    #%00
LIT SAW_WAVE      #%01
LIT TRIANGLE_WAVE #%10
LIT NOISE_WAVE    #%11

; Notes
LIT NO_NOTE #0
LIT C3      #37
LIT C#3     #38
LIT D3      #39
LIT D#3     #40
LIT E3      #41
LIT F3      #42
LIT F#3     #43
LIT G3      #44
LIT G#3     #45
LIT A3      #46
LIT A#3     #47
LIT B3      #48
LIT C4      #49
LIT C#4     #50
LIT D4      #51
LIT D#4     #52
LIT E4      #53
LIT F4      #54
LIT F#4     #55
LIT G4      #56
LIT G#4     #57
LIT A4      #58
LIT A#4     #59
LIT B4      #60
LIT C5      #61
LIT C#5     #62
LIT D5      #63
LIT D#5     #64
LIT E5      #65
LIT F5      #66
LIT F#5     #67
LIT G5      #68
LIT G#5     #69
LIT A5      #70
LIT A#5     #71
LIT B5      #72
LIT C6      #73
LIT C#6     #74
LIT D6      #75
LIT D#6     #76
LIT E6      #77
LIT F6      #78
LIT F#6     #79
LIT G6      #80
LIT G#6     #81
LIT A6      #82
LIT A#6     #83
LIT B6      #84

; Error Codes
LIT CLOSED_SUCCESSFULY     #$00
LIT ERROR_BAD_CONTROL_BYTE #$01
LIT ERROR_DEBUG_1          #$F0
LIT ERROR_DEBUG_2          #$F1
LIT ERROR_DEBUG_3          #$F2
LIT ERROR_DEBUG_4          #$F3
LIT ERROR_DEBUG_5          #$F4
LIT ERROR_DEBUG_6          #$F5
LIT ERROR_DEBUG_7          #$F6
LIT ERROR_DEBUG_8          #$F7
LIT ERROR_DEBUG_9          #$F8
LIT ERROR_DEBUG_10         #$F9
LIT ERROR_DEBUG_11         #$FA
LIT ERROR_DEBUG_12         #$FB
LIT ERROR_DEBUG_13         #$FC
LIT ERROR_DEBUG_14         #$FD
LIT ERROR_DEBUG_15         #$FE

SET   I                                          ; Prevent interrupts while working in another bank
STR   CLOCK_BANK   BANK_SELECTOR                 ; Switch to clock bank
STR   >:CALLBACK   CLOCK_CALLBACK_MSB            ; Store location of custom clock callback subroutine for the clock callback
STR   <:CALLBACK   CLOCK_CALLBACK_LSB
CLR   I                                          ; Reenable interrupts

STR   >:NOTES      NOTE_STORAGE_MSB              ; Store location of the notes to be played
STR   <:NOTES      NOTE_STORAGE_LSB              ; Store location of the notes to be played


STR   AUDIO_BANK    BANK_SELECTOR                ; Switch to audio bank



LODI NOTE_STORAGE_MSB R0                         ; Load current value from :NOTES section


:LOOP

CMP R0 EC_ESCAPE
BRA Z  :CONTROL

:PLAY
LOD TEMPO_COUNTER R1
CMP R2 R1
BRA G :PLAY                                      ; Wait until TEMPO_COUNTER is greater than or equal to TEMPO value

STR #0 OSC_SELECTOR
STR NOTE_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
STR VOLUME_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
STR PITCH_BEND_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE

STR #1 OSC_SELECTOR
STR NOTE_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
STR VOLUME_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
STR PITCH_BEND_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE

STR #2 OSC_SELECTOR
STR NOTE_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
STR VOLUME_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
STR PITCH_BEND_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE

STR #0 TEMPO_COUNTER
JMP :LOOP

:CONTROL
JSR :NEXT_BYTE

CMP R0 EC_SONG_END
BRA Z :SONG_END
CMP R0 EC_OSC_CHANGE
BRA Z :OSC_CHANGE
CMP R0 EC_HIGHPASS
BRA Z :HIGHPASS
CMP R0 EC_LOWPASS
BRA Z :LOWPASS
CMP R0 EC_WAVEFORM
BRA Z :WAVEFORM
CMP R0 EC_PULSE_WIDTH
BRA Z :PULSE_WIDTH
CMP R0 EC_PHASE
BRA Z :PHASE
CMP R0 EC_TEMPO
BRA Z :TEMPO

PSH ERROR_BAD_CONTROL_BYTE
JMP :ERROR

:SONG_END
STR #0 OSC_SELECTOR
STR VOLUME_REG AUDIO_REG_SELECTOR
STR #0 AUDIO_REG_VALUE

STR #1 OSC_SELECTOR
STR VOLUME_REG AUDIO_REG_SELECTOR
STR #0 AUDIO_REG_VALUE

STR #2 OSC_SELECTOR
STR VOLUME_REG AUDIO_REG_SELECTOR
STR #0 AUDIO_REG_VALUE

PSH CLOSED_SUCCESSFULY
JMP :ERROR

JMP :SONG_END

:ERROR
PSH #$AD                                         ; Magic number to let user know this is a crash
PSH #$DE
BYTES $FD                                        ; Invalid opcode, causes crash

:OSC_CHANGE
JSR :NEXT_BYTE
TRN R0 R3                                        ; R3 is where EC oscillator value is stored
JSR :NEXT_BYTE
JMP :LOOP

:HIGHPASS
JSR :NEXT_BYTE
STR R3 OSC_SELECTOR
STR HIGHPASS_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
JMP :LOOP

:LOWPASS
JSR :NEXT_BYTE
STR R3 OSC_SELECTOR
STR LOWPASS_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
JMP :LOOP

:WAVEFORM
JSR :NEXT_BYTE
STR R3 OSC_SELECTOR
STR WAVEFORM_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
JMP :LOOP

:PULSE_WIDTH
JSR :NEXT_BYTE
STR R3 OSC_SELECTOR
STR PULSE_WIDTH_REG AUDIO_REG_SELECTOR
STR R0 AUDIO_REG_VALUE
JSR :NEXT_BYTE
JMP :LOOP

:PHASE
JSR :NEXT_BYTE
STR R3 OSC_SELECTOR
STR PHASE_REG AUDIO_REG_SELECTOR
JSR :NEXT_BYTE
STR R0 AUDIO_REG_VALUE
JMP :LOOP

:TEMPO                                           ; TODO
JSR :NEXT_BYTE
TRN R0 R2                                        ; Tempo is stored in R2
JSR :NEXT_BYTE
STR R2 TEMPO_COUNTER                             ; Ready the next note to be played
JMP :LOOP


:NEXT_BYTE                                       ; Subroutine to move to the next byte in :NOTES
PSH  ACC                                         ; Allow ACC and R1 to be used for other things
PSH  R1
LOD  NOTE_STORAGE_MSB ACC                        ; Add to NOTE_STORAGE address including carrying
LOD  NOTE_STORAGE_LSB R1
INC  R1
ADDC #0
STR  R1 NOTE_STORAGE_LSB
STR  ACC NOTE_STORAGE_MSB
LODI NOTE_STORAGE_MSB R0                         ; Load current value from :NOTES section
POP  R1
POP  ACC
RET


:CALLBACK
SET  I                                           ; Make sure callback isn't interrupted with another callback
PSH  ACC                                         ; Allow ACC and R1 to be used for other things
PSH  R1
LOD  TEMPO_COUNTER R1                            ; add to NOTE_STORAGE address including carrying
INC  R1
STR  R1 TEMPO_COUNTER
POP  R1
POP  ACC
CLR  I
RET

:NOTES

;  The Lick
BYTES EC_ESCAPE EC_OSC_CHANGE #0
BYTES EC_ESCAPE EC_WAVEFORM TRIANGLE_WAVE
; BYTES EC_ESCAPE EC_PULSE_WIDTH #$80
BYTES EC_ESCAPE EC_TEMPO #15
BYTES D3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES E3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES F3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES G3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES E3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES E3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES C3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES D3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES D3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES D3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES D3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES D3 #$80 #$00 NO_NOTE #$00 #$00 NO_NOTE #$00 #$00
BYTES EC_ESCAPE EC_SONG_END                       ; Mark end of notes

:LENGTH                                           ; For assembler to print address of this
