 
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

:validCommand DAT 0; --------------------------------------------
; Title:   SimpleOS
; Author:  azertyfun
; Date:    8/09/2012
; Version: 1.0
; --------------------------------------------

JSR PILOT_search
JSR init_video
JSR ecran_accueil

JSR loadChoice
IFE Z, 1
	JSR console
IFN Z, 1
	JSR [other_program]

;When the program ends

JSR ecran_accueil ;Write the screen with "SimpleOS" a few seconds

SET A, 0
SET B, 0
HWI [screen_address] ;Stopping LEM1802
;Reinitalising registers
SET C, 0
SET I, 0
SET J, 0
SET X, 0
SET Y, 0
SET Z, 0
SET SP, 0
SET [0xFFFE], 0
SET [0xFFFF], 0
SET PC, 0xFFFE 
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
        IFE A, 0xBF3C
        	SET [sped3_address], J
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
	
	SET PC, POP
	
;A: String to write
;B: Sector to write to
:writeDisk
	;TODO
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


;Returns 1 in Z if the specified key in A was pressed
:waitKey
	SET Z, 0
	SET B, A
	HWI [keyboard_address]
	IFE C, 1
		SET Z, 1
	

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
	
	set I, 0x9000
	
	:init_video_loop
		SET [I], 0xF920
		ADD I, 1
		IFN I, 0x91e0
			SET PC, init_video_loop
		
	
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
			
		SET A, command
		SET B, about
		JSR strcmp
		IFE Z, 1
			JSR aboutProgram
			
		SET A, command
		SET B, shutdown
		JSR strcmp
		IFE Z, 1
			JSR shutdownProgram
			
		SET A, command
		SET B, sysInfo
		JSR strcmp
		IFE Z, 1
			JSR sysInfoProgram
			
		SET A, command
		SET B, sysInfoMin
		JSR strcmp
		IFE Z, 1
			JSR sysInfoProgram
			
		SET A, command
		SET B, colRed
		JSR strcmp
		IFE Z, 1
			SET [color], 0x4900
		
		SET A, command
		SET B, colWhite
		JSR strcmp
		IFE Z, 1
			SET [color], 0xF900
		
		SET A, command
		SET B, colGreen
		JSR strcmp
		IFE Z, 1
			SET [color], 0x2900
		
		SET A, command
		SET B, colBlack
		JSR strcmp
		IFE Z, 1
			SET [color], 0x0900
	IFN [validCommand], 1
		JSR invalidCommand
	
	SET PC, POP
	
	
;J'ai pris ça de frOSt :)
 
;------------------------------------------------------------------
; STRCMP: return 0 in Z if the strings at A and at B are different
;------------------------------------------------------------------
:strcmp
	SET Z, 0
	SUB A, 1
	SUB B, 1
	:sc
		ADD A, 1
	ADD B, 1
	IFN [A], 0
		IFN [B], 0
			IFE [A], [B]
	SET PC, sc
	IFE [A], [B]
		SET Z, 1
	SET PC, pop; --------------------------------------------
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
	SET A, 0x0001
	HWI [keyboard_address]
	IFE C, 1
		SET PC, POP
	ADD I, 1
	IFN I, 90000
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
; Title:   loadChoice
; Author:  azertyfun
; Date:    21/10/2012
; Version: 
; --------------------------------------------

:loadChoice
	JSR clear
	
	IFE [other_program], 0
		SET Z, 1
	IFE [other_program], 0
		SET PC, POP
	
	SET A, launchConsole
	SET B, 0x8000
	JSR write
	
	SET A, launchOtherProgram
	SET B, 0x8020
	JSR write
	
	:loadChoiceloop
		JSR pressAnyKey
		SET Z, 2
		IFE C, 0x61
			SET Z, 1
		IFE C, 0x62
			SET Z, 0
		IFN Z, 2
			SET PC, POP
		SET PC, loadChoiceLoop; --------------------------------------------
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
	
	IFN [sped3_address], 0
		SET A, sped3Present
	IFE [sped3_address], 0
		SET A, sped3NotPresent
	SET B, 0x8080
	JSR write
	
	IFN [disk_address], 0
		SET A, HMDPresent
	IFE [disk_address], 0
		SET A, HMDNotPresent
	SET B, 0x80A0
	JSR write
	
	SET A, 0x0000
	HWI [disk_address]
	IFE B, 0x0001
		SET A, diskPresent
	IFN B, 0x0001
		SET A, diskNotPresent
	SET B, 0x80C0
	JSR write
	
	SET A, 0xFFFF
	HWI [disk_address]
	IFE B, 0x7FFF
		SET A, realHITmedia
	IFN B, 0xFFFF
		SET A, notRealHITmedia
	
	SET B, 0x80E0
	JSR write
	
	
	SET A, pressAnyKeyText
	SET B, 0x8110
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
:sped3Present DAT "- SPED-3 present.", 0
:sped3NotPresent DAT "- SPED-3 not present or detected.", 0
:sysVersion DAT "- SimpleOS beta v1.1.1", 0
:sysInfo DAT "sysInfo", 0
:sysInfoMin DAT "sysinfo", 0
:pressAnyKeyText DAT "Press any key to continue...", 0
:typeHelp DAT "Need help? Type help!", 0
:tooBigText DAT "The program you want to load is bigger than 0x1000 words.", 0
:load DAT "load", 0
:launchConsole DAT "a. launch console", 0
:launchOtherProgram DAT "b. launch external program", 0

:color DAT 0xF900
:screen_map DAT 0x8000
:last_character DAT 0x81e0
:writing_address DAT 0x8005

:screen_address DAT 0
:keyboard_address DAT 0
:clock_address DAT 0
:disk_address DAT 0
:sped3_address DAT 0

:BOOLshutdown DAT 0

:blocksNumber DAT 0
:wordsPerSector DAT 0
:wordsNumber DAT 0

:validCommand DAT 0
:other_program DAT 0 ;Replace 0 by the address of your program (in the programs project) and the user can launch it at the startup