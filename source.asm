 
; --------------------------------------------
; Title:   constants
; Author:  azertyfun
; Date:    8/09/2012
; Version: 1.0
; --------------------------------------------

;:color DAT 0x9000
:color DAT 0xF900
:screen_map DAT 0x8000
:last_character DAT 0x81e0
:writing_address DAT 0x8005

:screen_address DAT 0
:keyboard_address DAT 0
:clock_address DAT 0
:disk_address DAT 0

:BOOLshutdown DAT 0

:blocksNumber DAT 0
:wordsPerSector DAT 0
:wordsNumber DAT 0

:validCommand DAT 0

; --------------------------------------------
; Title:   SimpleOS
; Author:  azertyfun
; Date:    8/09/2012
; Version: 1.0
; --------------------------------------------

JSR PILOT_search
JSR init_video
JSR ecran_accueil
JSR console

;After shutdown command

JSR ecran_accueil

SET A, 0
SET B, 0
HWI [screen_address]
SET C, 0
SET I, 0
SET J, 0
SET X, 0
SET Y, 0
SET Z, 0
SET SP, 0  
; --------------------------------------------
; Title:   detectHardware
; Author:  azertyfun - based on a Vdragorn's example
; Date:    8/09/2012
; Version: 1.0
; --------------------------------------------

:PILOT_search ; init pilot system
    HWN Z
    SET J, -1
    :PILOT_search_loop
        HWQ J
        IFE A, 0xF615
            SET [screen_address], J
        IFE a, 0x7406
            SET [keyboard_address], J
        IFE a, 0xB402
            SET [clock_address], J
        IFE A, 0x4CAE
        	SET [disk_address], J
        ADD J,1
        IFN Z,J
            SET PC, PILOT_search_loop
    SET PC, POP; --------------------------------------------
; Title:   disk
; Author:  azertyfun
; Date:    9/10/2012
; Version: 
; --------------------------------------------

;Returns 1 in Z if HMD present, else 0.
:detectHMD
	IFE [disk_address], 0
		SET Z, 0
	IFN [disk_address], 1
		SET Z, 1
		
	SET PC, POP
	
;Returns 1 in Z if a disk is present, else 0
:detectDisk
	SET A, 0x0000
	HWI [disk_address]
	SET Z, B
	
	SET PC, POP
	
;Returns 1 in Z if write-locket, else 0
:getLocked
	SET A, 0x0001
	HWI [disk_address]
	SET Z, X
	
	SET PC, POP
	
;Returns number of sectors in X, words per sector in Y, number of words in Z.
:getDiskInfo
	SET A, 0x0001
	HWI [disk_address]
	SET X, C
	SET Y, B
	SET Z, Y
	MUL Z, X
	
	SET PC, POP; --------------------------------------------
; Title:   keyboard
; Author:  azertyfun
; Date:    10/10/2012
; Version: 
; --------------------------------------------

:pressAnyKey
	JSR clearKeyBuffer
	SET C, 0
	:PAKLoop
	SET A, 1
	HWI [keyboard_address]
		IFN C, 0
			SET PC, POP
	SET PC, PAKLoop


:clearKeyBuffer
	SET A, 0
	HWI [keyboard_address]
	SET PC, POP; --------------------------------------------
; Title:   video
; Author:  azertyfun
; Date:    8/09/2012
; Version: 1.0
; --------------------------------------------

:init_video
	SET A, 0
	SET B, [screen_map]
	HWI [screen_address]
	
	SET PC, POP
	
; SET A to address of string
; SET B to ram address to start writing (ex: 0x8000)
:write
	SET Y, A
	SET Z, B
	SET A, 0
	SET B, 0x9000
	HWI [screen_address]
	SET A, Y
	SET B, Z

	SET C, [color]
	:writeLoop
		IFE [A], 0
			SET PC, writeLoopEnd
		SET [B], [A]
		BOR [B], C
		;IFE [A], 0x20
		;	SET [B], 0x205F
		ADD A, 1
		ADD B, 1
		SET PC, writeLoop
	
	:writeLoopEnd
	SET A, 0
	SET B, 0x8000
	HWI [screen_address]
	SET PC, POP
		
:clear
	SET A, 0
	SET B, 0x9000
	HWI [screen_address]

	SET B, [screen_map]
	:clearLoop
		SET [B], 0xF920
		IFE B, [last_character]
			SET PC, clearLoopEnd
		ADD B, 1
		SET PC, clearLoop
		
	:clearLoopEnd
	SET A, 0
	SET B, 0x8000
	HWI [screen_address]
	SET PC, POP 
; --------------------------------------------
; Title:   about
; Author:  azertyfun
; Date:    9/09/2012
; Version: 
; --------------------------------------------

:aboutprogram
	JSR clear
	SET [validCommand], 1
	SET A, aboutText
	SET B, 0x8000
	JSR write
	JSR pressAnyKey
	SET PC, POP; --------------------------------------------
; Title:   console
; Author:  azertyfun
; Date:    9/09/2012
; Version: 1.0
; --------------------------------------------

:console
	JSR init_console
	JSR read_console
	JSR execCommand	
	
	IFN [BOOLshutdown], 1
		SET PC, console
		
	SET PC, POP
	
:init_console
	JSR clear
	
	SET A, typeHelp
	SET B, 0x8000
	JSR write
	
	SET A, consoleStatusBar
	SET B, 0x8160
	JSR write
	
	SET [validCommand], 0
	
	SET [writing_address], 0x8025
	
	SET A, console_startLine
	SET B, 0x8020
	JSR write
	
	SET PC, POP
	
:read_console
	JSR getChar
	IFE C, 0x11
		SET PC, POP
	IFE C, 0x10
		JSR backSpace
	IFG C, 0x1F
		IFL C, 0x7F
			JSR printChar
			
	JSR clearKeyBuffer
			
	SET PC, read_console
	









:getChar
	SET A, 1
	HWI [keyboard_address]
	IFN C, 0
		SET PC, POP
	SET PC, getChar

:printChar
	IFG [writing_address], 0x8045
		SET PC, POP
		
	SET B, [writing_address]
	SET A, [color]
	BOR C, A
	SET [B], C
	ADD [writing_address], 1
	SET PC, POP
	
:backSpace
	IFE [writing_address], 0x8025
		SET PC, POP
		
	SUB [writing_address], 1
	SET B, [writing_address]
	SET [B], 0xF920
	
	SET PC, POP
	
:execCommand
	SET I, 0x8025
	SET A, command
	
	:execCommandLoop
		SET [A], [I]
		AND [A], 0x00FF
		
		IFE [A], 0x20
			SET [A], 0
		
		IFE I, 0x8045
			SET PC, execCommandNext
		
		ADD I, 1
		ADD A, 1
		SET PC, execCommandLoop
	:execCommandNext
		SET A, command
		SET B, help
		JSR strcmp
		IFE Z, 1
			JSR helpProgram
			
		SET B, about
		JSR strcmp
		IFE Z, 1
			JSR aboutProgram
			
		SET B, shutdown
		JSR strcmp
		IFE Z, 1
			JSR shutdownProgram
			
		SET B, readDisk
		JSR strcmp
		IFE Z, 1
			JSR readDiskProgram
			
		SET B, sysInfo
		JSR strcmp
		IFE Z, 1
			JSR sysinfoProgram
			
		SET B, sysInfoMin
		JSR strcmp
		IFE Z, 1
			JSR sysInfoProgram
			
		SET B, load
		JSR strcmp
		IFE Z, 1
			JSR loadProgram
			
		SET B, colRed
		JSR strcmp
		IFE Z, 1
			SET [color], 0x4900
		
		SET B, colWhite
		JSR strcmp
		IFE Z, 1
			SET [color], 0xF900
			
		SET B, colGreen
		JSR strcmp
		IFE Z, 1
			SET [color], 0x2900
		
		SET B, colBlack
		JSR strcmp
		IFE Z, 1
			SET [color], 0x0900
	IFN [validCommand], 1
		JSR invalidCommand
	
	SET PC, POP
	
	
;J'ai pris ça de frOSt :)
 
;---------------------------------------------
;STRCMP return 0 in Z if the strings at A and at B are different
;---------------------------------------------
:strcmp
set push,A
set push,B
set Z,0
sub A,1
sub B,1
:sc
add A,1
add B,1
ifn [A],0
ifn [B],0
ife [A],[B]
set PC,sc
ife [A],[B]
set Z,1
set B,pop
set A,pop
set PC,pop; --------------------------------------------
; Title:   ecran_accueil
; Author:  azertyfun
; Date:    2/10/2012
; Version: 
; --------------------------------------------

:ecran_accueil
	JSR clear
	
	SET A, 0
	SET B, 0x9000
	HWI [screen_address]

	SET A, accueil
	SET B, 0x80A0
	JSR write
	
	SET A, 0
	SET B, 0x8000
	HWI [screen_address]
	
	SET I, 0
	:waitLoopAccueil
	ADD I, 1
	IFN I, 100000
		SET PC, waitLoopAccueil
	
	SET PC, POP; --------------------------------------------
; Title:   help
; Author:  azertyfun
; Date:    8/09/2012
; Version: 1.0
; --------------------------------------------

:helpprogram
	JSR clear
	SET [validCommand], 1
	SET A, helpText
	SET B, 0x8000
	JSR write
	JSR pressAnyKey
	SET PC, POP; --------------------------------------------
; Title:   invalidCommand
; Author:  azertyfun
; Date:    3/10/2012
; Version: 
; --------------------------------------------

:invalidCommand
	
	SET A, invalidCommandTxt
	SET B, 0x8160
	JSR write
	
	:waitLoopInvalidCommand
	ADD I, 1
	IFN I, 50000
		SET PC, waitLoopinvalidCommand
	
	SET PC, POP; --------------------------------------------
; Title:   load
; Author:  azertyfun
; Date:    9/10/2012
; Version: 
; --------------------------------------------

:loadProgram
	JSR clear
	SET [validCommand], 1

	IFE [disk_address], 0
		SET PC, loaderNoHMD

	SET A, 0x0000
	HWI [disk_address]
	IFE B, 0
		SET PC, loaderNoDisk
		
	SET A, 0x0001
	HWI [disk_address]
	SET [wordsNumber], C
	MUL [wordsNumber], B
	SET [wordsPerSector], B
	SET [sectorsNumber], C

	IFG [wordsNumber], 0x1000
		JSR tooBigprogram
	
	:loadedProgram DAT 0
	SET A, 0x0010
	SET B, 0x0000
	SET C, [sectorsNumber]
	SET X, loadedProgram
	
	JSR loadedProgram
	
	SET PC, POP
	
	
	
:loaderNoDisk
	SET A, noDiskPresentText
	SET B, 0x8000
	JSR write
	
	JSR pressAnykey
	
	SET PC, POP ;Do not return to loadProgram but the console because we're here by a SET PC, loaderNoDisk and not a JSR loaderNoDisk
	
	
:loaderNoHMD
	SET A, noHMD2043presentText
	SET B, 0x8000
	JSR write
	
	JSR pressAnyKey
	
	SET PC, POP ;Idem that loaderNoDisk
	
	
:tooBigProgram
	SET A, tooBigText
	SET B, 0x8000
	JSR write
	
	JSR pressAnykey
	
	SET PC, POP ;Idem that loaderNoDisk
	
:sectorsNumber DAT 0
:wordsNumber DAT 0
:wordsPerSector DAT 0; -----------------------------------------------------------------------------------
; Title:   readDisk
; Author:  aezrtyfun
; Date:    12/09/2012
; Version: 1.0
;
;  
; ----- THIS CODE IS NOT COMPATIBLE WITH NOTCH'S DISK SPECS: ONLY WITH HMD2043 -----
;
;
; -----------------------------------------------------------------------------------

:readDiskProgram
	JSR clear
	SET [validCommand], 1
	JSR checkHMD2043
	IFE [disk_address], 0
		SET PC, POP
	
	JSR checkDisk
	IFE Z, 1
		SET PC, POP
		
	;Todo: add blocs counter & reader + screen writer.
	
	JSR pressAnyKey ;TEMP
	
	JSR readDisk
	
	JSR pressAnyKey
	
	SET PC, POP
	
	
	
:checkHMD2043
	IFN [disk_address], 0
		SET PC, POP
	SET A, noHMD2043PresentText
	SET B, 0x8000
	JSR write
	
	JSR pressAnyKey
	
	SET PC, POP
	
:checkDisk
	SET A, 0
	SET Z, 0
	HWI [disk_address]
	IFE B, 1
		SET PC, POP
	
	SET A, noDiskPresentText
	SET B, 0x8000
	JSR write
	
	JSR pressAnyKey
	
	SET Z, 1 ;To stop executing program after SET PC, POP
	
	SET PC, POP
	
:readDisk
	SET A, 0x0001
	HWI [disk_address]
	SET X, C ;Number of sectors
	IFG X, 16 ;If number of sector>16
		SET X, 16
	SET A, 0x0010
	SET B, 0
	SET C, X
	SET X, 0x8000
	HWI [disk_address]
	JSR pressAnyKey
	
	
	SET PC, POP; --------------------------------------------
; Title:   shutdown
; Author:  Nathan
; Date:    10/09/2012
; Version: 1.0
; --------------------------------------------

:shutdownProgram
	SET [validCommand], 1
	SET [BOOLshutdown], 1
	SET PC, POP; --------------------------------------------
; Title:   sysinfo
; Author:  zaertyfun
; Date:    8/10/2012
; Version: 1.0
; --------------------------------------------

:sysInfoProgram
	JSR clear
	SET [validCommand], 1
	
	SET A, sysInfoTitle
	SET B, 0x8000
	JSR write
	
	SET A, sysVersion
	SET B, 0x8040
	JSR write
	
	IFN [screen_address], 0
		SET A, screenPresent
	IFE [screen_address], 0
		SET A, screenNotPresent
	SET B, 0x8060
	JSR write
	
	IFN [disk_address], 0
		SET A, HMDPresent
	IFE [disk_address], 0
		SET A, HMDNotPresent
	SET B, 0x8080
	JSR write
	
	SET A, 0x0000
	HWI [disk_address]
	IFE B, 0x0001
		SET A, diskPresent
	IFN B, 0x0001
		SET A, diskNotPresent
	SET B, 0x80A0
	JSR write
	
	SET A, 0xFFFF
	HWI [disk_address]
	IFE B, 0x7FFF
		SET A, realHITmedia
	IFN B, 0xFFFF
		SET A, notRealHITmedia
	
	SET B, 0x80C0
	JSR write
	
	
	SET A, pressAnyKeyText
	SET B, 0x80E0
	JSR write
	
	JSR pressAnyKey
	
	SET PC, POP 
; --------------------------------------------
; Title:   DATA
; Author:  azertyfun
; Date:    10/10/2012
; Version: 
; --------------------------------------------

; --------------------------------------------
; Title:   DATA
; Author:  azertyfun
; Date:    8/09/2012
; Version: 
; --------------------------------------------

:video_initalized DAT "Video initalized", 0
:console_startLine DAT "SOS> ", 0
:actualAddress DAT 0x8005
:command DAT 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
:help DAT "help", 0
:about DAT "about", 0
:shutdown DAT "shutdown", 0
:readDisk DAT "readDisk", 0
:colorTxt DAT "color", 0
:helpText DAT "help: Shows this help page.     about: Shows the about window.  shutdown: shutdowns the computersysInfo: shows infos about the      computer.                   Press any key to continue...", 0
:aboutText DAT "About: SimpleOS veta v1.1.1 created by azertyfun for DCPU-16 (0x10c). Programmed on 0x10c devkit v1.7.5.", 0
:shutdownText DAT "Computer is shutted down.", 0
:noDiskPresentText DAT "No disk detected.", 0
:disk_sectors_number DAT 0
:noHMD2043PresentText DAT "No HMD2043 detected"
:readInto DAT "                                ", 0
:accueil DAT "            SimpleOS            ", 0
:colWhite DAT "white", 0
:colRed DAT "red", 0
:colBlack DAT "black", 0
:colGreen DAT "green", 0
:invalidCommandTxt DAT "Invalid command.                ", 0
:consoleStatusBar DAT "SimpleOS console by azertyfun   ", 0
:screenPresent DAT "- Screen present.", 0
:screenNotPresent DAT "- Screen not present or detected.", 0
:sysInfotitle DAT "System info:                    ------------", 0
:HMDPresent DAT "- HMD2043 present.", 0
:HMDNotPresent DAT "- HMD2043 not present or detected.", 0
:realHITmedia DAT "- Authentic HIT disk.", 0
:notRealHITmedia DAT "- Unreal or unpresent HIT disk.", 0
:diskPresent DAT "- Disk present.", 0
:diskNotPresent DAT "- Disk not present", 0
:sysVersion DAT "- SimpleOS beta v1.1.1", 0
:sysInfo DAT "sysInfo", 0
:sysInfoMin DAT "sysinfo", 0
:pressAnyKeyText DAT "Press any key to continue...", 0
:typeHelp DAT "Need help? Type help!", 0
:tooBigText DAT "The program you want to load is bigger than 0x1000 words.", 0
:load DAT "load", 0

:color DAT 0xF900
:screen_map DAT 0x8000
:last_character DAT 0x81e0
:writing_address DAT 0x8005

:screen_address DAT 0
:keyboard_address DAT 0
:clock_address DAT 0
:disk_address DAT 0

:BOOLshutdown DAT 0

:blocksNumber DAT 0
:wordsPerSector DAT 0
:wordsNumber DAT 0

:validCommand DAT 0
