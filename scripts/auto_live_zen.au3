; ZLAPS
; auto_live_zen.au3
; 2019-2020 Martin H. Dominguez
; Gladstone Institutes


#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <Misc.au3>
#include <File.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <Date.au3>

Func ZEN_Mark_Spot()

   Local $UserDLL = DllOpen("user32.dll")

   $hCross_GUI = GUICreate("Test", @DesktopWidth, @DesktopHeight - 20, 0, 0, $WS_POPUP, $WS_EX_TOPMOST)
   WinSetTrans($hCross_GUI, "", 2)
   GUISetState(@SW_SHOW, $hCross_GUI)
   GUISetCursor(3, 1, $hCross_GUI)

   ;Wait until mouse button pressed
   While Not _IsPressed("01", $UserDLL)
       Sleep(10)
   WEnd

	Local $aMouse_Pos = MouseGetPos()
    ;$iX1 = $aMouse_Pos[0]
    ;$iY1 = $aMouse_Pos[1]

	GUIDelete($hCross_GUI)
    DllClose($UserDLL)

	Return $aMouse_Pos

EndFunc

Func winlist_to_combobox_array ($aArray)
   Local $bArray[0]
   Dim $bArray
   ;_ArrayDisplay($aArray, "A 2D display")
    ;Local $bArray[Ubound($aArray)]
    For $i = 1 To Ubound($aArray) - 1
		If Not StringInStr( $aArray[$i][0], "Frozen") Then
			Local $Bound = UBound($bArray)
			ReDim $bArray[$Bound+1]
			$bArray[$Bound] = $aArray[$i][0]
		EndIf
	 Next
	 ;_ArraySort($bArray, "B 1D display")
	 ;_ArrayDisplay($bArray, "B 1D display")
   Return $bArray
EndFunc



 ;MAIN SUBROUTINE BELOW

;Make sure ZEN open
Local $aWinlist_comb = winlist_to_combobox_array(WinList("[REGEXPTITLE:(?i)(.*Zen.*)]") )
While UBound($aWinlist_comb) < 1
	Local $retrycancel_input = MsgBox( $MB_RETRYCANCEL, "Cannot find ZEN Window", "Cannot find an open ZEN Window; please start ZEN application and try again." )
	if $retrycancel_input = $IDRETRY Then
		$aWinlist_comb = winlist_to_combobox_array(WinList())
	Else
		Exit
	EndIf
Wend

;0. Create GUI
$hMain_GUI = GUICreate("Automatic MVL Time Series Controller", 360, 440)
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
GUISetOnEvent( $GUI_EVENT_CLOSE ,   "Quit")
Opt("MouseCoordMode",1) ;~ 1 = absolute screen coordinates (default)

;1. Choose ZEN Window:
;Local $sZEN_window_title = "ZEN 2014 SP1" ; default option
$hCombo_Label = GUICtrlCreateLabel("1. Choose ZEN Window:", 10, 10, 120, 20)
$hCombo = GUICtrlCreateCombo("ZEN Window...", 140, 7, 180, 20)

;Create combobox elements from window titles with "ZEN"
$sList = ""
For $i = 0 To UBound($aWinlist_comb) - 1
	$sList &= "|" & $aWinlist_comb[$i]
	Next
GUICtrlSetData($hCombo, $sList, $aWinlist_comb[0])

;2. Set-up ZEN workspace and aquisition settings
$hSetup_Label = GUICtrlCreateLabel("2. Set-up ZEN workspace and aquisition settings (no Time Series)", 10, 40, 380, 20)

;3. Locate Fiji/ImageJ Binary
Local $sfiji_binary = ""
$hFiji_Button   = GUICtrlCreateButton(" 3. Locate ImageJ Binary",  10, 70, 150, 30, $BS_LEFT)
GUICtrlSetOnEvent($hFiji_Button, "PickFijiBinary")
$hFiji_Label = GUICtrlCreateLabel("None Selected", 170, 77, 300, 20)

;4. Mark 'Start Experiment' Button
Local $aStart_Pos[2] = [ 300, 336 ]
Local $hRect_Button   = GUICtrlCreateButton(" 4. Mark 'Start Experiment' Button",  10, 110, 167, 30, $BS_LEFT)
GUICtrlSetOnEvent($hRect_Button, "MarkStartExp")
Local $hRect_Label = GUICtrlCreateLabel($aStart_Pos[0] & " x " & $aStart_Pos[1], 187, 117, 80, 20)

;5. Mark 'MultiViewList Open' Button
Local $aMVLOpen_Pos[2] = [ 698, 1228 ]
Local $hMVLOpen_Button   = GUICtrlCreateButton(" 5. Mark 'MultiViewList Open' Button",  10, 150, 180, 30, $BS_LEFT)
GUICtrlSetOnEvent($hMVLOpen_Button, "MarkMVLOpen")
Local $hMVLOpen_Label = GUICtrlCreateLabel($aMVLOpen_Pos[0] & " x " & $aMVLOpen_Pos[1], 200, 157, 80, 20)

;6. Mark 'MultiViewList Save' Button
Local $aMVLSave_Pos[2] = [ 728, 1228 ]
Local $hMVLSave_Button   = GUICtrlCreateButton(" 6. Mark 'MultiViewList Save' Button",  10, 190, 180, 30, $BS_LEFT)
GUICtrlSetOnEvent($hMVLSave_Button, "MarkMVLSave")
Local $hMVLSave_Label = GUICtrlCreateLabel($aMVLSave_Pos[0] & " x " & $aMVLSave_Pos[1], 200, 197, 80, 20)

;;7. Mark 'Acquisition' Tab
;Local $aAcqTab_Pos[2] = [ 728, 1228 ]
;Local $hAcqTab_Button   = GUICtrlCreateButton(" 7. Mark 'Acquisition' Tab",  10, 230, 180, 30, $BS_LEFT)
;GUICtrlSetOnEvent($hAcqTab_Button, "MarkAcqTab")
;Local $hAcqTab_Label = GUICtrlCreateLabel($aAcqTab_Pos[0] & " x " & $aAcqTab_Pos[1], 200, 237, 80, 20)

;7. Choose time interval between aquisitions
Local $hInput_Label_1 = GUICtrlCreateLabel("7. Set time interval (minutes) between aquisitions:", 10, 230, 240, 20)
Local $hInput_Box_1 = GUICtrlCreateInput( "6", 250, 227, 30, 20, $ES_RIGHT )
Local $hInput_Label_2 = GUICtrlCreateLabel("(must be long enough to acquire each full time point!)", 30, 250, 300, 20)
Local $n_time_diff_next = Number(GUICtrlRead($hInput_Box_1)) ;global variable that stores the time interval

;8. Choose CZI save directory
Local $ssave_dir = ""
Local $hSave_Button   = GUICtrlCreateButton(" 8. Choose CZI save directory",  10, 275, 150, 30, $BS_LEFT)
GUICtrlSetOnEvent($hSave_Button, "ChooseSaveDir")
Local $hSave_Label = GUICtrlCreateLabel("None Selected", 170, 282, 300, 20)

;10. Choose starting index number
Local $hInput_Label_3 = GUICtrlCreateLabel("9. Set start index number:", 10,315, 140, 20)
Local $hInput_Box_2 = GUICtrlCreateInput( "0", 150, 312, 40, 20, BitOR($ES_NUMBER,$ES_RIGHT) )
;$hInput_Label_2 = GUICtrlCreateLabel("minutes", 240, 230, 40, 20)
Local $n_image_index = Number(GUICtrlRead($hInput_Box_2)) ;global variable that stores the current index number

;11. Go!
$hStart_Button = GUICtrlCreateButton("Start",    10, 390, 80, 30)
GUICtrlSetOnEvent($hStart_Button, "StartPushed")
$hCancel_Button = GUICtrlCreateButton("Quit",    100, 390, 80, 30)
GUICtrlSetOnEvent($hCancel_Button, "Quit")
$hReset_Button = GUICtrlCreateButton("Reset Positioning",    190, 390, 120, 30)
GUICtrlSetOnEvent($hReset_Button, "ResetPushed")

AutoItSetOption("WinTitleMatchMode", -2)
GUISetState()
Local $Islive = false;
Local $LiveStop = false;
Local $NextTime = 0
Local $hTimer = TimerInit() ; Begin the timer and store the handle in a variable.
Local $StartButtonCRC
Local $run_fiji = -2
Local $run_fiji_time = 0
;Sleep(3000) ; Sleep for 3 seconds.
;Local $fDiff = TimerDiff($hTimer) ; Find the difference in time from the previous call of TimerInit. The variable we stored the TimerInit handlem is passed as the "handle" to TimerDiff.

;DEBUG: establish logging
;Local $h_logfile = FileOpen("%userprofile%\Desktop\" & "auto_live_zen_auit3.log", 1)
Local $s_logfile = "%userprofile%\Desktop\" & "auto_live_zen_auit3.log"


; Main loop here
While 1
	If ( $Islive = true ) Then
		If ( $LiveStop = true ) Then
			$Islive = false
			$LiveStop = false
			$NextTime = 0
		ElseIf( TimerDiff($hTimer) > $NextTime ) Then ;time to do another acquisition
			GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
			Disable_buttons()
			$NextTime = GoAcquire($NextTime)
			;MsgBox( $MB_OK, "Time vs. Return Time", String( TimerDiff($hTimer)) & " vs. " & String($NextTime) & " done with GoAcquire")
		Else
			PublishTimeToStopButton($NextTime)
			If $run_fiji > 0 Then
				If ProcessExists ($run_fiji) Then
					;Do nothing here, ImageJ still running to create next MVL file
					GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
				Else
					;ImageJ is done, so open the new MVL file and reset the flag
					GoOpenSaveMVL("open")
					$run_fiji = -1 ;reset runfiji so we do it next time
					GuiCtrlSetState ($hReset_Button, $GUI_ENABLE)
					If FileExists( $sfiji_binary ) And $run_fiji_time < $NextTime Then
						$run_fiji = Run($sfiji_binary & ' -macro "' & @ScriptDir & '\mvl_updater.ijm" "' & $ssave_dir & '"', $ssave_dir)
						GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
						$run_fiji_time = $NextTime
					EndIf
				EndIf
			Else
				GuiCtrlSetState ($hReset_Button, $GUI_ENABLE)
			EndIf
		EndIf
	Else
		GUICtrlSetData($hStart_Button, "Start")
		Enable_Buttons()
		If $run_fiji > 0 Then
			If ProcessExists ($run_fiji) Then
				;Do nothing here, ImageJ still running to create next MVL file
				GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
			Else
				$run_fiji = -1 ;reset runfiji so we do it next time
				GuiCtrlSetState ($hReset_Button, $GUI_ENABLE)
			EndIf
		Else
			GuiCtrlSetState ($hReset_Button, $GUI_ENABLE)
		EndIf
		Sleep(1000)
	EndIf
	Sleep(1000) ; Sleep to reduce CPU usage
WEnd


Func Disable_buttons()
	GuiCtrlSetState ($hCombo, $GUI_DISABLE)
	GuiCtrlSetState ($hFiji_Button, $GUI_DISABLE)
	GuiCtrlSetState ($hRect_Button, $GUI_DISABLE)
	GuiCtrlSetState ($hMVLOpen_Button, $GUI_DISABLE)
	GuiCtrlSetState ($hMVLSave_Button, $GUI_DISABLE)
	GuiCtrlSetState ($hInput_Box_1, $GUI_DISABLE)
	GuiCtrlSetState ($hInput_Box_2, $GUI_DISABLE)
	GuiCtrlSetState ($hSave_Button, $GUI_DISABLE)
EndFunc

Func Enable_buttons()
	GuiCtrlSetState ($hCombo, $GUI_ENABLE)
	GuiCtrlSetState ($hFiji_Button, $GUI_ENABLE)
	GuiCtrlSetState ($hRect_Button, $GUI_ENABLE)
	GuiCtrlSetState ($hMVLOpen_Button, $GUI_ENABLE)
	GuiCtrlSetState ($hMVLSave_Button, $GUI_ENABLE)
	GuiCtrlSetState ($hInput_Box_1, $GUI_ENABLE)
	GuiCtrlSetState ($hInput_Box_2, $GUI_ENABLE)
	GuiCtrlSetState ($hSave_Button, $GUI_ENABLE)
EndFunc


;Func start_timer()
;    If $state == "Idle" Then
;        Global $timer = TimerInit(), $state = "Running", $render_timer = TimerInit()
;    EndIf
;EndFunc

;Func pause_timer()
;    If $state == "Running" Then
;        $state = "Paused"
;        $saved_time = TimerDiff($timer) + $saved_time
;        GUICtrlSetData($b_pause, "Resume")
;    ElseIf $state == "Paused" Then
;        $state = "Running"
;        $timer = TimerInit()
;        GUICtrlSetData($b_pause, "Pause")
;    EndIf
;EndFunc

;Func reset_timer()
;    Global $timer = "", $state = "Idle", $render_timer = "", $saved_time = 0
;    GUICtrlSetData($l_timer, "00:00:00")
;    GUICtrlSetData($b_pause, "Pause")
;EndFunc

Func PublishTimeToStopButton($next_time)
    Local $diff = $next_time - TimerDiff($hTimer)
    ;MsgBox( $MB_OK, "Time vs. Return Time", String( TimerDiff($hTimer)) & " vs. " & String($next_time) & " = " & String($diff))
    Local $sec = Int(Mod($diff/1000, 60))
    Local $min = Int(Mod($diff/60000, 60))
    Local $hour = Int($diff/3600000)
    If $sec < 10 Then $sec = "0"&$sec
    If $min < 10 Then $min = "0"&$min
    If $hour < 10 Then $hour = "0"&$hour
    GUICtrlSetData($hStart_Button, $min&":"&$sec&" ...Stop")
EndFunc


Func MarkStartExp()
	Local $sZEN_window_title = GUICtrlRead($hCombo)
	GUISetState(@SW_HIDE, $hMain_GUI)
	WinActivate( $sZEN_window_title )
	$aStart_Pos = ZEN_Mark_Spot()
	GUICtrlSetData($hRect_Label, $aStart_Pos[0] & " x " & $aStart_Pos[1])
	GUISetState(@SW_SHOW, $hMain_GUI)
EndFunc

Func MarkMVLOpen()
	Local $sZEN_window_title = GUICtrlRead($hCombo)
	GUISetState(@SW_HIDE, $hMain_GUI)
	WinActivate( $sZEN_window_title )
	$aMVLOpen_Pos = ZEN_Mark_Spot()
	GUICtrlSetData($hMVLOpen_Label, $aMVLOpen_Pos[0] & " x " & $aMVLOpen_Pos[1])
	GUISetState(@SW_SHOW, $hMain_GUI)
EndFunc

Func MarkMVLSave()
	Local $sZEN_window_title = GUICtrlRead($hCombo)
	GUISetState(@SW_HIDE, $hMain_GUI)
	WinActivate( $sZEN_window_title )
	$aMVLSave_Pos = ZEN_Mark_Spot()
	GUICtrlSetData($hMVLSave_Label, $aMVLSave_Pos[0] & " x " & $aMVLSave_Pos[1])
	GUISetState(@SW_SHOW, $hMain_GUI)
EndFunc

;Func MarkAcqTab()
;	$sZEN_window_title = GUICtrlRead($hCombo)
;	GUISetState(@SW_HIDE, $hMain_GUI)
;	WinActivate( $sZEN_window_title )
;	$aAcqTab_Pos = ZEN_Mark_Spot()
;	GUICtrlSetData($hAcqTab_Label, $aAcqTab_Pos[0] & " x " & $aAcqTab_Pos[1])
;	GUISetState(@SW_SHOW, $hMain_GUI)
;EndFunc

Func PickFijiBinary()
	$sfiji_binary = FileOpenDialog("Select ImageJ/Fiji Binary File", "%userprofile%\Desktop\ImageJ.app", "Executable (*.exe)", $FD_FILEMUSTEXIST )
	;GUICtrlSetData($hFiji_Label, $sfiji_binary )
	GUICtrlSetData($hFiji_Label, StringLeft($sfiji_binary,30) & " ..." )
	;$run_fiji = RunWait($sfiji_binary & ' -macro "' & @ScriptDir & '\mvl_updater.ijm"', $ssave_dir)
 EndFunc

Func ResetPushed()
	If $run_fiji > 0 Then
		If ProcessExists ($run_fiji) Then
			;Do nothing here, ImageJ still running to create next MVL file
			MsgBox( $MB_OK, "ImageJ appears to be running...", "PID: " & $run_fiji )
			GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
		Else
			$run_fiji = -2 ;reset runfiji so we do it next time as if it was a new start
		EndIf
	Else
		$run_fiji = -2 ;reset runfiji so we do it next time as if it was a new start
	EndIf
	GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
EndFunc

Func Quit()
	Exit
EndFunc

Func ChooseSaveDir()
	$ssave_dir = FileSelectFolder("Select CZI Save Folder", "Z:\SWAP\Martin")
	;GUICtrlSetData($hSave_Label, $ssave_dir )
	GUICtrlSetData($hSave_Label, StringLeft($ssave_dir,30) & " ..." )
	;FileWrite ( "$ssave_dir\mvl_updater.ijm", $sImageJMacro )
	;MsgBox( $MB_OK, "Save Dir Chosen...", $ssave_dir )
	;WinWait($sZEN_window_title)
	;Sleep(500)
	; DEBUG: set logfile to this folder location
	$s_logfile = $ssave_dir & "\auto_live_zen_auit3.log"
EndFunc


Func StartPushed()
	;Local $sZEN_window_title = GUICtrlRead($hCombo)
	;Local $current_index = GUICtrlRead($hInput_Box_2)


	If $IsLive = true Then
		$LiveStop = true;
		  ;MsgBox( $MB_OK, "Stop", "We are quitting GoExperiment" )
	Else
		$n_image_index = GUICtrlRead($hInput_Box_2)

		$n_time_diff_next = Number(GUICtrlRead($hInput_Box_1))
		If IsNumber($n_time_diff_next) And $n_time_diff_next > 0 Then
			;do nothing
		Else
			MsgBox( $MB_OK, "Cannot Start: Bad time interval", "Time interval (" & GUICtrlRead($hInput_Box_1) & ") between acquisitions must be a number greater than zero!" )
			Return
		EndIf

		Local $current_filename = "LSFM_" & StringFormat("%04d",String($n_image_index)) & ".czi"

		If $sfiji_binary = "" Then
			PickFijiBinary()
		EndIf
		While $ssave_dir = ""
			ChooseSaveDir()
		WEnd
		If FileExists( $ssave_dir & "\" & $current_filename) Then ;Preview problems that are going to occur going forward
			MsgBox( $MB_OK, "Cannot Start: Save File Exists", "File already exists:" & $ssave_dir & "\" & $current_filename )
			Return
		EndIf
		$IsLive = true;
		$LiveStop = false;
		GUICtrlSetData($hStart_Button, "Stop")

		_FileWriteLog ( $s_logfile, _NowTime(5) & " Auto Live Embryo is starting..."  ) ;DEBUG: TODO: comment me
		GoOpenSaveMVL("save")
		;Local $sFileSelectFolder = FileSelectFolder("Select CZI Save Folder", "")
		;GoExperiment()

		;DEBUG: logging activity

	EndIf
EndFunc

;Func GoExperiment()
;   MsgBox( $MB_OK, "Start", "We are starting GoExperiment" )
;   While 1
;	  If $IsLive = true And $LiveStop = false Then
;		 ; do nothing
;	  Else
;		 MsgBox( $MB_OK, "Stop", "We are quitting GoExperiment" )
;		 Return
;	  EndIf
;  WEnd
;EndFunc

Func GoOpenSaveMVL($function)
	If $ssave_dir = "" Then
		Return
	EndIf
	Local $sZEN_window_title = GUICtrlRead($hCombo)
	Local $not_finished = true
	;Local $current_index = GUICtrlRead($hInput_Box_2)
	Local $current_index = $n_image_index
	Local $current_filename = "LSFM_" & StringFormat("%04d",String($current_index)) & ".mvl"
	Local $wcount = 0
	Local $vcount = 0

	_FileWriteLog ( $s_logfile, _NowTime(5) & "  GoOpenSaveMVL called for " & $function & ", with current index: " & $current_index  ) ;DEBUG: TODO: comment me

	While ( $not_finished )
		WinActivate( $sZEN_window_title )

		Local $hWin = 0
		Local $hWinErr = 0
		If $function = "save" Then
			If  FileExists( $ssave_dir & "\" & $current_filename ) Then
				;make sure we don't get a replace/overwrite file dialog
				DirCreate ( $ssave_dir & "\Backup\" )
				FileMove($ssave_dir & "\" & $current_filename,$ssave_dir & "\Backup\" & $current_filename & "." & _GetUnixTime(),$FC_OVERWRITE)
			EndIf
			FileDelete($ssave_dir & "\" & $current_filename) ;make sure we don't get a replace/overwrite file dialog, in case filemove doesn't work
			MouseClick( "Left", $aMVLSave_Pos[0], $aMVLSave_Pos[1] )
			$hWin = WinWait("Save As","",3)
			If $hWin = 0 Then ;no window pops up -- likely because ROI is incorrect, since save/open aren't critical, just return function and give up
				_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 1"  ) ;DEBUG: TODO: comment me
				Return
			EndIf
			$hWin = WinActivate("Save As")
		ElseIf $function = "open" Then
			$vcount = 0
			;$current_filename = "LSFM_" & StringFormat("%04d",String($current_index)) & ".mvl"
			;MsgBox( $MB_OK, "DEBUG: About to open .mvl file", "To open:" & $current_filename & "!" ) ;TODO: comment this
			While ( (Not FileExists( $ssave_dir & "\" & $current_filename )) And $vcount < 20 )
				$current_index -= 1
				$current_filename = "LSFM_" & StringFormat("%04d",String($current_index)) & ".mvl"
				$vcount += 1
			WEnd
			;MsgBox( $MB_OK, "DEBUG: About to open .mvl file", "To open:" & $current_filename & "!" ) ;TODO: comment this
			MouseClick( "Left", $aMVLOpen_Pos[0], $aMVLOpen_Pos[1] )
			$hWin = WinWait("Open","",3)
			If $hWin = 0 Then ;no window pops up -- likely because ROI is incorrect, since save/open aren't critical, just return function and give up
				_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 2"  ) ;DEBUG: TODO: comment me
				Return
			EndIf
			$hWin = WinActivate("Open")
		Else
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 3"  ) ;DEBUG: TODO: comment me
			Return
		EndIf

		Sleep(500)
		;ControlSend($hWin,"","[CLASS:Edit; INSTANCE:1]",'"' & $ssave_dir & "\" & $current_filename & '"')
		ControlSetText($hWin,"","[CLASS:Edit; INSTANCE:1]",'"' & $ssave_dir & "\" & $current_filename & '"')
		Sleep(500)
		ControlClick($hWin,"","Button2")

		;Sleep(1000)
		If $function = "save" Then
			$hWinErr = WinWaitActive("Save As","OK",1)
		ElseIf $function = "open" Then
			$hWinErr = WinWaitActive("Open","OK",1)
		Else
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 4"  ) ;DEBUG: TODO: comment me
			Return
		EndIf

		If $hWinErr = 0 Then ;check for persistently open dialog, again
			If $function = "save" Then
				$hWinErr = WinWait("Save As","",1)
			ElseIf $function = "open" Then
				$hWinErr = WinWait("Open","",1)
			Else
				_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 5"  ) ;DEBUG: TODO: comment me
				Return
			EndIf
		EndIf

		If $hWinErr <> 0 Then
			WinActivate($hWinErr)
			Sleep(500)
			;Send("N+{ALT}")
			;$current_index+=1
			;GUICtrlSetData($hInput_Box_2, $current_index)
			;$hSaveAs = WinWait("Save As")
			;WinActivate($hSaveAs)
			ControlClick($hWinErr,"","Button1") ;hit cancel button
			Sleep(1000)
			If WinExists($hWinErr) Then
				WinClose($hWinErr)
			EndIf
			Sleep(1000)
			If $function = "save" Then
				$current_index += 1
			ElseIf $function = "open" Then
				$current_index -= 1
			Else
				_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 6"  ) ;DEBUG: TODO: comment me
				Return
			EndIf
			$current_filename = "LSFM_" & StringFormat("%04d",String($current_index)) & ".mvl"
		Else
			$not_finished = false
		EndIf
		$wcount += 1

		If $wcount > 20 Then
			$not_finished = true
			 MsgBox( $MB_OK, "Problem with MVL Operartion", "Cannot " & $function & " MVL file at current index " & String($current_index) & ", after " & String($wcount) & " tries." )
		EndIf
	WEnd

	_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoOpenSaveMVL return condition: 0"  ) ;DEBUG: TODO: comment me
EndFunc


Func GoAcquire($next_time)
	If $ssave_dir = "" Then
		Return
	EndIf
	;If $ssave_dir = "" Then
	;	ChooseSaveDir()
	;EndIf
	;Bring up the window
	Local $sZEN_window_title = GUICtrlRead($hCombo)
	WinActivate( $sZEN_window_title )
	;Local $time_diff_next = GUICtrlRead($hInput_Box_1)
	;Local $time_diff_next = $n_time_diff_next
	;Local $current_index = GUICtrlRead($hInput_Box_2)
	Local $current_index = $n_image_index
	Local $current_filename = "LSFM_" & StringFormat("%04d",String($current_index)) & ".czi"
	;Local $vcount = 0

	_FileWriteLog ( $s_logfile, _NowTime(5) & "  GoAcquire called for crossing next_time: " & $next_time & ", with current index: " & $current_index  ) ;DEBUG: TODO: comment me

	; Area to scan for changes is 40px by 20px, centered around the spot selected for "Start Experiment" button
  	Local $scan_x1 = $aStart_Pos[0] - 4
	Local $scan_x2 = $aStart_Pos[0] + 4
  	Local $scan_y1 = $aStart_Pos[1] - 2
	Local $scan_y2 = $aStart_Pos[1] + 2
	MouseMove($aStart_Pos[0]+100, $aStart_Pos[1]+100) ;nomans land
	Sleep(300)
	Local $dPixel_CRC32_init = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
	ControlSend($sZEN_window_title,"","","{TAB}")
	ControlSend($sZEN_window_title,"","","{TAB}")
	Sleep(300)
	Local $dPixel_CRC32_init_tab = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
	MouseMove($aStart_Pos[0], $aStart_Pos[1]) ;move over start experiment
	Sleep(300)
	Local $dPixel_CRC32_hover = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
	ControlSend($sZEN_window_title,"","","{TAB}")
	ControlSend($sZEN_window_title,"","","{TAB}")
	Sleep(300)
	Local $dPixel_CRC32_hover_tab = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)

   ;check for file exists and increment the current index if it does exist
	Local $vcount = 0
	While ( FileExists( $ssave_dir & "\" & $current_filename ) And $vcount < 1000 ) ;try 1000 times to rename the file by incrementing the start index number
		$current_index += 1
		$current_filename = "LSFM_" & StringFormat("%04d",String($current_index)) & ".czi"
		$vcount += 1
	WEnd

	_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire to save file with index: " & $current_index ) ;DEBUG: TODO: comment me

	MouseClick( "Left", $aStart_Pos[0], $aStart_Pos[1] )

	;terminate sort view anlges window
	Local $hOverwrite = WinWait("Multiview","",2)
	If $hOverwrite == 0 Then
		$hOverwrite = WinWait("Multiview","",2)
	EndIf
	If $hOverwrite <> 0 Then
		WinActivate($hOverwrite)
		Sleep(500)
		ControlSend($hOverwrite,"","","n")
		;Send("N+{ALT}")
		Sleep(500)
	EndIf
	$hOverwrite = 0

	; deal with Save As dialog
	Local $hSaveAs = WinWait("Save As","",15)
	If $hSaveAs == 0 Then
		$hSaveAs = WinWait("Save As","",30)
		If $hSaveAs == 0 Then
			GUICtrlSetData($hInput_Box_2, $current_index)
			$n_image_index = $current_index
			If WinExists($hSaveAs) Then
				WinClose($hSaveAs) ;just incase still active
			EndIf
			ControlSend($sZEN_window_title,"","","{TAB}") ;move focus away from Start Experiment button so it does not have blue outline (cannot be compared from start to finish because blue outline is lost regardless of how it looked at the start)
			ControlSend($sZEN_window_title,"","","{TAB}") ;move focus away from Start Experiment button so it does not have blue outline (cannot be compared from start to finish because blue outline is lost regardless of how it looked at the start)
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire return condition: 1"  ) ;DEBUG: TODO: comment me
			Return TimerDiff($hTimer)
		EndIf
	EndIf

	If  FileExists( $ssave_dir & "\" & $current_filename ) Then
		;make sure we don't get a replace/overwrite file dialog
		DirCreate ( $ssave_dir & "\Backup\" )
		FileMove($ssave_dir & "\" & $current_filename,$ssave_dir & "\Backup\" & $current_filename & "." & _GetUnixTime(),$FC_OVERWRITE )
		_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire entered FileExists condition, current filename:" & $current_filename  ) ;DEBUG: TODO: comment me
	EndIf
	FileDelete($ssave_dir & "\" & $current_filename) ;make sure we don't get a replace/overwrite file dialog -- incase file move doesn't work

	$hSaveAs = WinActivate("Save As")
	;Sleep(500)
	;ControlSend($hSaveAs,"","[CLASS:Edit; INSTANCE:1]"," ")
	;Sleep(500)
	;ControlFocus($hSaveAs,"","[CLASS:Edit; INSTANCE:1]")
	;ControlSend($hSaveAs,"","[CLASS:Edit; INSTANCE:1]", '"' & $ssave_dir & "\" & $current_filename & '"')
	ControlSetText($hSaveAs,"","[CLASS:Edit; INSTANCE:1]", '"' & $ssave_dir & "\" & $current_filename & '"')
	Sleep(500)
	ControlClick($hSaveAs,"","Button2")
	;Sleep(500)

	;terminate overwrite window
	$hOverwrite = 0
	$hOverwrite = WinWait("File Save","",2)
	If $hOverwrite <> 0 Then
		WinActivate($hOverwrite)
		Sleep(500)
		;Send("N+{ALT}")
		ControlSend($hOverwrite,"","","n")
		;$current_index+=1 ; TODO: consider uncommenting this line
		GUICtrlSetData($hInput_Box_2, $current_index)
		$n_image_index = $current_index
		$hSaveAs = WinWait("Save As")
		WinActivate($hSaveAs)
		ControlClick($hSaveAs,"","Button3") ;hit cancel button
		If WinExists($hSaveAs) Then
			WinClose($hSaveAs) ;just incase still active
		EndIf
		ControlSend($sZEN_window_title,"","","{TAB}") ;move focus away from Start Experiment button so it does not have blue outline (cannot be compared from start to finish because blue outline is lost regardless of how it looked at the start)
		ControlSend($sZEN_window_title,"","","{TAB}") ;move focus away from Start Experiment button so it does not have blue outline (cannot be compared from start to finish because blue outline is lost regardless of how it looked at the start)
		;Return $next_time
		_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire return condition: 2"  ) ;DEBUG: TODO: comment me
		Return TimerDiff($hTimer)
	EndIf

	;set variables for continuing the run
	Local $time_diff_sec = 60 * $n_time_diff_next ; 60 sec/min
	Local $return_time = TimerDiff($hTimer) ;start with no change to return time
	_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire ready to wait for acquisition start, current return time is: " & $return_time  ) ;DEBUG: TODO: comment me
	Local $b_did_start = false

	;now, wait for acquisition to be finished
	Local $dPixel_CRC32_start = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
	;MsgBox( $MB_OK, "CRC32 Start vs. Init vs. Hover", String($dPixel_CRC32_start) & " vs. " & String($dPixel_CRC32_init)& " vs. " & String($dPixel_CRC32_hover) )
	For $i = 1 To 60 ; wait 60 seconds for Start Experiment button to change to End Experiment
		If ( $dPixel_CRC32_start <> $dPixel_CRC32_init And $dPixel_CRC32_start <> $dPixel_CRC32_hover And  $dPixel_CRC32_start <> $dPixel_CRC32_init_tab And $dPixel_CRC32_start <> $dPixel_CRC32_hover_tab ) Then
			;increment index and set next time for acquisition
			$return_time = TimerDiff($hTimer) + ( $time_diff_sec * 1000) ; 1000msec/sec
			;MsgBox( $MB_OK, "Time vs. Return Time", String( TimerDiff($hTimer)) & " vs. " & String($return_time) )
			$current_index+=1
			$n_image_index = $current_index
			GUICtrlSetData($hInput_Box_2, $current_index)
			PublishTimeToStopButton($return_time)
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire incrementing index to: " & $current_index  ) ;DEBUG: TODO: comment me
			$b_did_start = true
			ExitLoop
		EndIf
		Sleep(1000)
		$dPixel_CRC32_start = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
		PublishTimeToStopButton($return_time)
	Next
	_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire ready to wait for acquisition finish (" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time  ) ;DEBUG: TODO: comment me

	;now, wait for experiment acquisition to finish

	Local $dPixel_CRC32_now = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
	Local $b_success = false
	Local $n_timeout = $time_diff_sec * 2
	;MsgBox( $MB_OK, "CRC32 Start vs. Init vs. Now vs. Hover", String($dPixel_CRC32_start) & " vs. " & String($dPixel_CRC32_init)& " vs. " & String($dPixel_CRC32_now)& " vs. " & String($dPixel_CRC32_hover) )
	For $i = 1 To $n_timeout ; wait for three full periods before giving up and trying to cancel acquisition
		;MsgBox( $MB_OK, "CRC32 Start vs. Init vs. Now vs. Hover, loop " & String($i), String($dPixel_CRC32_start) & " vs. " & String($dPixel_CRC32_init)& " vs. " & String($dPixel_CRC32_now)& " vs. " & String($dPixel_CRC32_hover) )
		If ( $dPixel_CRC32_start <> $dPixel_CRC32_now And ($dPixel_CRC32_now=$dPixel_CRC32_init Or $dPixel_CRC32_now=$dPixel_CRC32_hover Or $dPixel_CRC32_now=$dPixel_CRC32_init_tab Or $dPixel_CRC32_now=$dPixel_CRC32_hover_tab) ) Then
			$b_success = true
			ExitLoop
		EndIf
		Sleep(1000)
		$dPixel_CRC32_now = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
		PublishTimeToStopButton($return_time)
		If $i > $time_diff_sec Then ; for whatever reason we have exceeded the actual time until the next image should be acquired, so aggressively press tab to try to get a pixel CRC consistent with imaging run being complete
			ControlSend($sZEN_window_title,"","","{TAB}")
			ControlSend($sZEN_window_title,"","","{TAB}")
			;Sleep(10000)
			If ( Mod($i,10) == 0 ) Then
			   _FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire entered protracted acquisition (" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time  ) ;DEBUG: TODO: comment me
			EndIf
		EndIf
	 Next

	If $b_success == false Then ;did not terminate normally; presumably is in a protracted acquisition
		Local $dPixel_CRC32_start = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
		For $i = 1 To 8640 ;try to stop for 24 hours
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire will attempt to terminate protracted acquisition (" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time  ) ;DEBUG: TODO: comment me
			MouseMove($aStart_Pos[0], $aStart_Pos[1]) ;move over start experiment
			Sleep(300)
			MouseClick( "Left", $aStart_Pos[0], $aStart_Pos[1] )
			Sleep(99700)
			Local $dPixel_CRC32_now = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
			$hOverwrite = WinWait("Error","",2)
			If $hOverwrite <> 0 Then
				WinActivate($hOverwrite)
				Sleep(500)
				ControlSend($sZEN_window_title,"","","{ENTER}")
				WinClose($hOverwrite)
				;Send("N+{ALT}")
				Sleep(500)
			EndIf
			If WinExists($hOverwrite) Then
				WinClose($hOverwrite) ;just incase still active
			EndIf
			If ( $dPixel_CRC32_start <> $dPixel_CRC32_now ) Then ;And ($dPixel_CRC32_now=$dPixel_CRC32_init Or $dPixel_CRC32_now=$dPixel_CRC32_hover Or $dPixel_CRC32_now=$dPixel_CRC32_init_tab Or $dPixel_CRC32_now=$dPixel_CRC32_hover_tab) ) Then
			    _FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire successful termination of acquisition (" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time  ) ;DEBUG: TODO: comment me
			   $b_success = true
			   ExitLoop
			EndIf
			PublishTimeToStopButton($return_time)
			If ($i > ($time_diff_sec / 10)) Then ; for whatever reason we have exceeded the actual time until the next image should be acquired, so aggressively press tab to try to get a pixel CRC consistent with imaging run being complete
			   ControlSend($sZEN_window_title,"","","{TAB}")
			   ControlSend($sZEN_window_title,"","","{TAB}")
			   Sleep(500)
			   Local $dPixel_CRC32_now = PixelChecksum($scan_x1, $scan_y1, $scan_x2, $scan_y2)
			   If ( $dPixel_CRC32_start <> $dPixel_CRC32_now And ($dPixel_CRC32_now=$dPixel_CRC32_init Or $dPixel_CRC32_now=$dPixel_CRC32_hover Or $dPixel_CRC32_now=$dPixel_CRC32_init_tab Or $dPixel_CRC32_now=$dPixel_CRC32_hover_tab) ) Then
				  _FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire successful termination of acquisition (" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time  ) ;DEBUG: TODO: comment me
				  $b_success = true
				  ExitLoop
			   EndIf
			EndIf
		 Next
		 If $b_success == true Then
			 ; most likely we were successful at terminating the acquisition, but it is possible that we instead initiated a new acquisition -- so have to look out for that, then return from this function
			;terminate sort view anlges window
			$hOverwrite = WinWait("Multiview","",2)
			If $hOverwrite == 0 Then
				$hOverwrite = WinWait("Multiview","",2)
			EndIf
			If $hOverwrite <> 0 Then
				WinActivate($hOverwrite)
				Sleep(500)
				ControlSend($hOverwrite,"","","n")
				;Send("N+{ALT}")
				Sleep(500)
			EndIf
			$hOverwrite = 0

			; deal with Save As dialog
			Local $hSaveAs = WinWait("Save As","",15)
			If $hSaveAs == 0 Then
				$hSaveAs = WinWait("Save As","",30)
			EndIf
			If WinExists($hSaveAs) Then
				WinClose($hSaveAs) ;just incase still active
			EndIf

			;prep ending of this function and return
			ControlSend($sZEN_window_title,"","","{TAB}") ;move focus away from Start Experiment button so it does not have blue outline (cannot be compared from start to finish because blue outline is lost regardless of how it looked at the start)
			ControlSend($sZEN_window_title,"","","{TAB}") ;move focus away from Start Experiment button so it does not have blue outline (cannot be compared from start to finish because blue outline is lost regardless of how it looked at the start)
			GUICtrlSetData($hInput_Box_2, $current_index)
			$n_image_index = $current_index
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire return condition: 3"  ) ;DEBUG: TODO: comment me
			Return TimerDiff($hTimer)
		Else
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire unable to satisfactorily terminate acquisition (" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time & ". Aborting!"  ) ;DEBUG: TODO: comment me
			$LiveStop = true
			Return TimerDiff($hTimer)
		EndIf

	EndIf

	_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire acquisition finished(" & BinaryToString ($b_did_start) & "), current return time is: " & $return_time  ) ;DEBUG: TODO: comment me

	;Local $aCoord = PixelSearch(200, 260, 220, 270, 0x6B3F4F)  ; look for red pixels inside the start-button area
	;While Not @error
	;    Sleep(500)
	;	Local $aCoord = PixelSearch(200, 260, 220, 270, 0x6B3F4F) ;sets the @error flag to 1 if the color is not found
	;WEnd

	If FileExists( $sfiji_binary ) And $run_fiji <= 0 Then
		If $run_fiji < -1 Then
			;numbers below -1 correspond with steps needing to be done before imageJ tries to do any processing
			$run_fiji += 1
		Else
			;run IJ script here
			;MsgBox( $MB_OK, "Running ImageJ", "Yipee" )
			_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire running fiji, current return time is: " & $return_time  ) ;DEBUG: TODO: comment me
			$run_fiji = Run($sfiji_binary & ' -macro "' & @ScriptDir & '\mvl_updater.ijm" "' & $ssave_dir & '"', $ssave_dir)
			$run_fiji_time = $return_time ;let us know that we ran imageJ on this run of GoAcquire
			GuiCtrlSetState ($hReset_Button, $GUI_DISABLE)
			;ImageJ-win64.exe -macro Test D:\In.tif#D:\Out3.tif
			;open newly created MVL file here
			;GoOpenSaveMVL("open")
		EndIf
	EndIf
	;MsgBox( $MB_OK, "Run ImageJ", String( $run_fiji) & " is the return of " & $sfiji_binary )

	;close open window to alleviate ZEN clutter and free memory  for whatever reason the keys have to be sent twice to the application, unclear why
	WinActivate( $sZEN_window_title )
	Send("^{F4}") ;CTRL+F4
	;ControlSend($sZEN_window_title,"","","{LCTRL}+{F4}")

	;terminate save as box when closing a window that is unsaved
	$hOverwrite = 0
	$hOverwrite = WinWait("Close image","",2)
	If $hOverwrite <> 0 Then
		WinActivate($hOverwrite)
		Sleep(500)
		ControlSend($hOverwrite,"","","n")
		;Send("N+{ALT}")
		Sleep(500)
	EndIf

	_FileWriteLog ( $s_logfile, _NowTime(5) & "   GoAcquire return condition: 0"  ) ;DEBUG: TODO: comment me
	Return $return_time
EndFunc




;AutoItSetOption ( "WinTitleMatchMode" , 3 )
;WinActivate("ZEN 2012","");
;if PixelGetColor(9,259)<>0xE5E6EA  then ; test if z-stack enabled
;   MouseClick("left", 556,873,1) ; load position list single plane
;else
;   MouseClick("left", 556,909,1) ; load position list z-stack plane
;endif
;Sleep(500)
;
;Send($CmdLine[1])
;Sleep(2000)
;Send("{ENTER}")
;Sleep(1000)

Func _GetUnixTime($sDate = 0);Date Format: 2013/01/01 00:00:00 ~ Year/Mo/Da Hr:Mi:Se

    Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
    Local $utcTime = ""

    If Not $sDate Then $sDate = _NowCalc()

    If Int(StringLeft($sDate, 4)) < 1970 Then Return ""

    If $aSysTimeInfo[0] = 2 Then ; if daylight saving time is active
        $utcTime = _DateAdd('n', $aSysTimeInfo[1] + $aSysTimeInfo[7], $sDate) ; account for time zone and daylight saving time
    Else
        $utcTime = _DateAdd('n', $aSysTimeInfo[1], $sDate) ; account for time zone
    EndIf

    Return _DateDiff('s', "1970/01/01 00:00:00", $utcTime)
EndFunc   ;==>_GetUnixTime
