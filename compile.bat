@echo off
echo. >compiled.hex
type "SimpleOS\simpleOS.hex">>compiled.hex
echo. >>compiled.hex
type "hardware\hardware.hex">>compiled.hex
echo. >>compiled.hex
type "programs\programs.hex">>compiled.hex
echo. >>compiled.hex
type "Strings & constants\Strings & constants.hex">>compiled.hex

ren "SimpleOS\SimpleOS.10cproj" SimpleOS
ren "Hardware\hardware.10cproj" Hardware
ren "Programs\Programs.10cproj" Programs
ren "Strings & constants\Strings & constants.10cproj" "Strings & constants"

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
type "Strings & constants\*.10c">>source.asm

ren "SimpleOS\SimpleOS" SimpleOS.10cproj
ren "Hardware\hardware" Hardware.10cproj
ren "Programs\Programs" Programs.10cproj
ren "Strings & constants\Strings & constants" "Strings & constants.10cproj"

pause