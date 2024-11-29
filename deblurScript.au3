; Define paths
$softwarePath = "C:\Program Files (x86)\DeblurSoftwareSetup\DeblurSoftwareUI.exe"  ; Path to the deblurring software executable
$imagePath = $CmdLine[1]
$outputPath = $CmdLine[2]
If @error Then Exit ; Exit if no path is provided


; Run the deblurring software normally, then hide it
Run($softwarePath)


; Wait for the main window of the software to be ready
If WinWait("DeblurSoftwareWin", "", 10) Then

    ;WinSetState("DeblurSoftwareWin", "", @SW_MINIMIZE) ; Minimize the software window instead of hiding it
Else
    MsgBox(0, "Error", "Could not find the main window.")
    Exit
EndIf



; Open the File menu using Alt+F
Send("!f") ; Alt+F to open File menu
Sleep(500)
Send("o") ; Press "O" to select Open
Sleep(1000)

; Enter the image path directly and confirm
Send($imagePath) ; Send the image path to the Open dialog
Send("{ENTER}")
Sleep(2000) ; Wait for the image to load

; Check if the wizard window is open and click the Finish button
If WinExists("Deblur Wizard") Then ; Replace "Deblur Wizard Title" with the actual title of the wizard window
    WinActivate("Deblur Wizard")
	; Press Tab to cycle through controls until we reach Finish (adjust number of Tabs as needed)
    ;Send("{TAB 1}") ; Adjust the number of {TAB} presses based on how many tabs it takes to reach the Finish button
    Send("{ENTER}") ; Press Enter to confirm if Finish is in focus
	Sleep(1000)
EndIf
Send("{DOWN 2}")
Sleep(1000)
Send("{ENTER}")
Sleep(1000)
; Use `Send` with `Tab` only, to reach the dropdown (Adjust the number based on dropdown location)
;Send("{TAB 4}") ; Adjust the number of Tab presses as necessary
;Sleep(1000) ; Allow time to reach dropdown

; Navigate to "Large" (or relevant option) in the dropdown
Send("{DOWN 1}") ; Adjust Down arrows based on "Large" position
Sleep(500)
Send("{SPACE}") ; Confirm selection
Sleep(1000)
Send("{ENTER}") ; Confirm selection
Sleep(1000)

; Use `Send` with `Tab` only, to reach the dropdown (Adjust the number based on dropdown location)
;Send("{TAB 5}") ; Adjust the number of Tab presses as necessary
;Sleep(1000) ; Allow time to reach dropdown
;Send("{SPACE}") ; Confirm selection
;Sleep(1000)

Send("^r") ; This sends Ctrl + R
Sleep(39000)

Send("!f")
Sleep(500)
Send("a")
Sleep(1000)

Send($outputPath) ; Send save path
Send("{ENTER}")
Sleep(2000) ; Wait for save to complete


; Close the software using Alt+F4
Send("!{F4}") ; Alt+F4 to close the active window