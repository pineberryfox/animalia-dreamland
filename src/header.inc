.segment "HEADER"
.byte $4e, $45, $53, $1a ; N E S EOF -- magic number
.byte $01                ; number of 16k PRG-ROM banks
.byte $01                ; number of  8k CHR-ROM banks
.byte %00000001          ; mirroring: V, SRAM: no, mapper: 0
.byte %00001000          ; special flags: no, mapper: 0 :: NES 2.0
.byte $00                ; no PRG-RAM
.byte $00                ; NTSC
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00
.byte $01                ; standard controllers
