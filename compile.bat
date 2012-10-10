echo. >compiled.hex
type "SimpleOS\simpleOS.hex">>compiled.hex
echo. >>compiled.hex
type "hardware\hardware.hex">>compiled.hex
echo. >>compiled.hex
type "programs\programs.hex">>compiled.hex
echo. >>compiled.hex
type "DATA\DATA.hex">>compiled.hex

ren "SimpleOS\SimpleOS.10cproj" SimpleOS
ren "Hardware\hardware.10cproj" Hardware
ren "Programs\Programs.10cproj" Programs
ren "DATA\DATA.10cproj" "DATA"

echo. >>SimpleOS\*.10c
echo. >>hardware\*.10c
echo. >>programs\*.10c

echo. >source.asm
type "SimpleOS\*.10c">>source.asm
echo. >> source.asm
type "Hardware\*.10c">>source.asm
echo. >> source.asm
type "programs\*.10c">>source.asm
echo. >> source.asm
type "DATA\*.10c">>source.asm

ren "SimpleOS\SimpleOS" SimpleOS.10cproj
ren "Hardware\hardware" Hardware.10cproj
ren "Programs\Programs" Programs.10cproj
ren "DATA\DATA" "DATA.10cproj"

pause