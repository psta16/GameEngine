﻿; Universal Game Engine
; 2/Jan/2017

; BUGS:
; 20241113 - LINUX - Switching from full screen windowed mode back to windowed mode seems to leave the window maximised

EnableExplicit

; Do compiler checks
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
  CompilerCase #PB_OS_Linux
  CompilerCase #PB_OS_MacOS
  CompilerDefault
    CompilerError "OS not supported"
CompilerEndSelect

;- Imports

Import ""
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      ; Function to get the actual memory size
      GetPhysicallyInstalledSystemMemory(Size)
  CompilerEndSelect
EndImport

;- Prototypes

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  PrototypeC gdk_display_get_default() ; r1 = gdkdisplay
  PrototypeC gdk_display_get_monitor_at_window(*display, *gdkwindow); r1 = gdkmonitor
  PrototypeC gdk_monitor_get_display(*monitor)
  PrototypeC gdk_monitor_get_refresh_rate(*monitor)
CompilerEndIf

;- Module Includes

;XIncludeFile "../MyLib/font/Font.pbi"
;XIncludeFile "../MyLib/joystick/Joystick.pbi"

;- Enumerations

; Layer 1 - System and universal controls

Enumeration Variable_Type
    #Byte
    #Ascii
    #Char
    #Word
    #Unicode
    #Long
    #Integer
    #Float
    #Double
    #String
EndEnumeration

Enumeration Render_Engine3D
  #Render_Engine3D_None
  #Render_Engine3D_Builtin ; custom built 3D engine
  #Render_Engine3D_Ogre
EndEnumeration

Enumeration Game_Window
  #Game_Window_Main
  #Game_Window_Debug ; debug window
  #Game_Window_Full_Screen_Minimised ; this is special window opened when classic full screen mode is switched back to the OS
EndEnumeration

Enumeration Full_Screen_Type
  #Full_Screen_Classic
  #Full_Screen_Windowed ; recommended, allows multiple monitor support
EndEnumeration

Enumeration Data_Source
  #Data_Source_None
  #Data_Source_Internal_Memory
  #Data_Source_File
  #Data_Source_Database
EndEnumeration

Enumeration Simulated_Resolution_Stretch_Type
  ; Used for simulating a low resolution game
  #Simulated_Resolution_Stretch_Smallest ; recommended
  #Simulated_Resolution_Stretch_H
  #Simulated_Resolution_Stretch_V
  #Simulated_Resolution_Stretch_Both
EndEnumeration

Enumeration Fonts
  #Font_Fixedsys_Neo_Plus
EndEnumeration

Enumeration Shapes ; used for vector graphics
  #Shape_None
  #Shape_Box
  #Shape_Round_Box
  #Shape_Line
  #Shape_Circle
  #Shape_Polygon
  #Shape_Fill ; use this to fill an area
EndEnumeration

Enumeration Control_Type
  #Control_Type_Keyboard
  #Control_Type_Joystick
  #Control_Type_Mouse
EndEnumeration  

; Layer 2 - Menus and controls

Enumeration Menu_System ; specifies how the menu will be navigated
  #Menu_System_Menuless ; uses buttons only to start and reset the game
  #Menu_System_Simple   ; like most console and some PC games (uses arrow keys/controller to navigate)
  #Menu_System_Pointer  ; like most PC games
EndEnumeration

Enumeration Menu_Action
  ; specifies different actions a menu will take
  #Menu_Action_None
  ; menuless
  #Menu_Action_Start  ; starts the game
  #Menu_Action_Select ; selects which mode of the game to play
  #Menu_Action_Reset  ; resets the game
  ; simple
  #Menu_Action_Confirm
  #Menu_Action_Back
  #Menu_Action_Up
  #Menu_Action_Down
  #Menu_Action_Left
  #Menu_Action_Right
  ; pointer based menu controls
  #Menu_Action_Click
EndEnumeration

Enumeration Menu_Background
  #Menu_Background_None ; displays a solid colour
  #Menu_Background_Vector
  #Data_Menu_Background_Image
EndEnumeration

;- Globals
Global Restart.i=0 ; restarts the game engine

;- Constants
; System
#Max_FPS_Samples = 500 ; number of FPS sample to average to get FPS
#Max_Monitors_Supported = 3
#Max_Sprite_Resources = 256 ; total amount of individual sprites supported
#Num_System_Font_Char = 101 ; number of characters in the system font
#Max_Variables = 128
#Max_Debug_Vars = 32
#Max_Keyboard_Value = 300 ; used for storing which keys are down
#Mouse_Sprite = 0
#Max_Vector_Graphics_Resources = 32
#Max_System_Font_Instances = 32

; Menu
#Max_Menu_Controls = 12

; Game
#Max_Sprite_Instances = 2048 ; all sprites used by the game

;- Structures

; System

Structure Variable_Structure
  Var_Type.i
  Name.s
  StructureUnion
    Byte.b
    Ascii.a
    Char.c
    Word.w
    Unicode.u
    Long.l
    Integer.i
    Float.f
    Double.d
  EndStructureUnion
  String.s
EndStructure

Structure Desktop_Structure ; structure to store parametres for each available display
  Name.s
  Width.i
  Height.i
  Depth.i
  Frequency.i
EndStructure

Structure System_Structure
  Current_Directory.s
  Data_Directory.s
  MutexID.i    ; used to check if more than one instance of the game is running
  MutexError.i
  Minimum_Colour_Depth.i
  Sprites_Loaded.i
  Font_Char_Sprite.i[#Num_System_Font_Char] ; sprite ID for the system font
  Fatal_Error_Message.s
  Game_Title.s
  Game_Config_File.s     ; filename of the confg file
  Sprite_List_Data_Source.i ; The source for the sprite resource list (see enumeration Data_Source)
  Sprite_Resource_Count.i   ; number of sprite resources
  Sprite_Instance_Count.i ; number of sprite instances
  Game_Resource_Location.s                                         ; location of files
  Debug_Window.i                                                   ; turns on the debug window
  Debug_Var_Count.i ; count of the number of debug variables in the Debug_Var() array, used with the debug window
  Config_File.i             ; set to 1 if config file exists, used for when there's no config file
  Last_Screen_Capture_File.s; last file used by screen capture
  Last_Screen_Capture_Number.i ; used for capturing more than one frame per second  
  Render_Engine3D.i            ; select which 3D rendering engine to use, select none for 2D only
  Last_Debug_Window_Update.q   ; time in milliseconds when the debug window was last updated
  Show_Debug_Info.i            ; when set this will show things like FPS etc on screen
  Show_Mouse.i           ; shows the mouse
  Mouse_Control.i        ; mouse is controlling the player
  Mouse_X.f              ; location of the mouse pointer when it is over the window
  Mouse_Offset_X.i       ; offset of the mouse sprite displayed
  Mouse_Y.f
  Mouse_Offset_Y.i
  Take_Screen_Capture.i ; flag to take a screen capture
  Mouse_Save_X.i   ; saves the position of the mouse when switching back to desktop (alt+tab)
  Mouse_Save_Y.i
  Quit.i                 ; flag to quit game 1 = quit. To restart the game use the global Restart variable
  Keyb.i[#Max_Keyboard_Value]       ; Array to hold which keyboard keys are pushed
  Allow_Restart.i        ; allows the game engine to be restarted
  Allow_Switch_to_Window.i  ; to allow switching between window and full screen
  Allow_Screen_Capture.i    ; allows a screenshot to be taken
  Allow_AltF4_Full_Screen.i ; allows full screen to be quit using Alt+F4
  Mouse_Sensitivity_X.f
  Mouse_Sensitivity_Y.f
  Mouse_Button_Left.i ; gives the actual mouse button state, only works in ExamineMouse() mode
  Mouse_Button_Middle.i
  Mouse_Button_Right.i  
  Mouse_Wheel_Movement.i ; movement of the mouse wheel since the last ExamineMouse()  
  Mouse_Left_Click.i  ; set when the mouse is clicked while in window mode
  Mouse_Right_Click.i
  Config_Loaded.i           ; set to 1 once the config is loaded. Cannot save until loaded  
  Initialisation_Error.i    ; will be set when there's an error. Helps track down the first error causing an issue
  Initialise_Error_Message.s; special string for giving an initialisation error message. Only set this using SetInitialiseError()
  Initialised.i             ; set when the game engine is initialised
  Time_Full_Screen_Switched.q ; special timer to keep track of when the screen was toggled between full screen and window, needed for keyboard handler
  Sprite_Vector_Resource_Count.i ; number of vector resources
  Variable.Variable_Structure[#Max_Variables] ; variables used for displaying values on screen etc
  System_Font_Instance_Count.i ; number of system font instances
EndStructure

Structure Debug_Structure
  Debug_Var.s[#Max_Debug_Vars]
EndStructure

Structure Window_Settings_Structure
  Allow_Window_Resize.i     ; to allow the game window to be resized or maximised (doesn't apply to full screen mode)
  Reset_Window.i            ; triggers a move back to the main monitor, useful if a monitor is unplugged
  Window_Maximised.i        ; set when window is maximised 
  Window_Minimised.i    ; set when window is minimised
  Window_Open.i             ; flag is set when window successfully open
  Window_X.i                ; position of window
  Window_Y.i
  Window_W.i            ; size of the window when in window mode
  Window_H.i
  Window_Debug_X.i ; debug window coordinates
  Window_Debug_Y.i
  Window_Debug_W.i
  Window_Debug_H.i  
  Window_Debug_Edit_Gadget.i ; ID for the edit gadget
  Debug_Window_Front_Colour.i
  Debug_Window_Back_Colour.i
  Window_Moved.i        ; triggers whenever the window in normal mode moves
  Background_Colour.i
EndStructure

Structure Screen_Settings_Structure
  Border.i ; sets whether the border is shown
  Border_Enable.i ; allows the border to be shown
  Border_Width.i ; border must be wider than screen res
  Border_Height.i
  Screen_Res_Width.i
  Screen_Res_Height.i
  Screen_Ratio.d ; 1 = square, 1.33 = 4:3, 1.77 = 16:9 , 1.6 = 16:10
  Pixel_Sprite.i ; ID of the sprite to be used for pixels
  Screen_Sprite.i; sprite used to grab the entire screen
  Border_Colour.i
  Background_Colour.i ; default background colour used for clearing the screen
  Full_Screen.i       ; set when in full screen mode
  Full_Screen_Type.i
  Screen_Actual_Width.i ; actual size of the screen
  Screen_Actual_Height.i
  Screen_Inner_Width.i ; size without border
  Screen_Inner_Height.i
  Screen_Inner_X.i ; coordinates of the screen in the final resolution (used for border)
  Screen_Inner_Y.i
  Set_Zoom.i ; change this to a number between 1 - 8 to set the zoom of the window
  Num_Monitors.i
  Screen_Left.i
  Screen_Top.i
  Desktop.Desktop_Structure[#Max_Monitors_Supported] ; Array to hold information about all monitorswdadsawdadwassdsa
  Total_Desktop_Width.i                              ; used for checking if the window is displayed off screen
  Selected_Desktop.i ; the selected monitor
  Screen_W.i ; dimensions of the screen for the monitor that is selected
  Screen_H.i
  Flip_Mode.i  ; Video flip mode: 0 = no sync, 1 = sync, 2 = smart sync
  Screen_Open.i; flag set when screen successfuly open (window or full screen)
  Screen_Active.i ; set when the screen is active (including the windowed screen)
  Classic_Screen_Background_Colour.i ; the colour used for the background of the classic screen (usually black)
  Full_Screen_Inactive.i             ; set when the user switches from the full screen to the desktop
  Screen_Filter.i ; turns the screen filter on or off
  Screen_Filter_Sprite.i             ; filter for CRT overlay
  Zoomed_Width.i ; used to find the dimensions of the screen based on the biggest size while still having square pixels
  Zoomed_Height.i
EndStructure  

Structure FPS_Data_Structure
  ; variables for measuring FPS
  Initialised.i
  Game_Start_Time.i ; when the game begins
  Frame_Start_Time.i ; time when the frame starts
  Last_Frame_Time.i  ; the time of the last frame
  Game_Run_Time.i    ; the time the game has been running
  Frame.i            ; the current frame of the game
  Begin_Time.i ; begin time of the FPS procedure
  Average_Sum.i
  Average_Index.i
  Samples.i[#Max_FPS_Samples] ; array for holding FPS samples
  Frequency.i                 ; the frequency of the monitor
  FPS.i
  FPS_Limit.i ; frequency of screen, FPS does not go higher than this
EndStructure

Structure Sprite_Resource_Structure
  ; Source collection of sprites
  ID.i
  Width.i
  Height.i
  Mode.i ; #PB_Sprite_PixelCollision and #PB_Sprite_AlphaBlending
  Transparent.i ; set if the sprite uses transparency
  Data_Source.i ; See Data_Source enumeration
  Memory_Location.i ; use one of these
  File_Location.s
  Database_Location.i
  Vector_Drawn.i ; used to select whether it will be drawn using vectors
EndStructure

Structure Vector_Graphics_Structure
  Shape_Type.i
  Background_Transparent.i
  Colour.i
  Background_Colour.i
  X.i 
  Y.i
  Width.i
  Height.i
  Radius.i
  Round_X.i ; used for rounded boxes
  Round_Y.i
  Cont.i ; indicates this is the last shape
EndStructure

Structure Sprite_Instance_Structure
  Sprite_Resource.i
  X.d
  Y.d
  Width.i
  Height.i
  Velocity_X.d
  Velocity_Y.d
  Intensity.i ; only works for transparent sprites
  Colour.i    ; only works for transparent sprites
  Layer.i     ; used to sort the sprite instance array for drawing order, 0 is background
  Visible.i
  Controlled_By.i
EndStructure

Structure System_Font_Instance_Structure
  S.s ; string to display
  Variable.i ; variable to use instead of string (-1 means not used)
  X.d
  Y.d
  Char_Width.i
  Char_Height.i
  Intensity.i
  Colour.i
  Layer.i     ; used to sort the sprite instance array for drawing order, 0 is background
  Visible.i
EndStructure


Structure Graphics_Structure
  Vector_Graphics_Resource.Vector_Graphics_Structure[#Max_Vector_Graphics_Resources] ; used for reading vector data and drawing onto a sprite
  Sprite_Resource.Sprite_Resource_Structure[#Max_Sprite_Resources] ; hold all sprite resources (the actual sprite image data)
  Sprite_Instance.Sprite_Instance_Structure[#Max_Sprite_Instances] ; instances of sprites on screen
  System_Font_Instance.System_Font_Instance_Structure[#Max_System_Font_Instances] ; instances of system font strings
EndStructure

Structure Control_Set_Structure
  ; Control sets can be saved for easy retrival
  Control_Type.i ; Enumeration Control_Type
  Up.i
  Down.i
  Left.i
  Right.i
  A.i
  B.i
  X.i
  Y.i
  Left_Shoulder.i
  Right_Shoulder.i
  Left_Triger_Axis.i
  Right_Trigger_Axis.i
  Left_Stick_X.i
  Left_Stick_Y.i
  Right_Stick_X.i
  Right_Stick_Y.i
  Left_Stick_Click.i
  Right_Stick_Click.i
  Start.i
  Select_Button.i
  Home.i
EndStructure

; Menu

Structure Menu_Control_Structure ; ways of controlling menus
  Menu_Control_Type.i ; specifies the type of the menu control system, see Enumeration Menu_System
  Menu_Control_Action.i ; this is the action the control will take, see Enumeration Menu_Control_Actions
  Menu_Control_Hardware_Type.i   ; see Enumeration Control_Hardware
  Menu_Control_ID.i              ; this is the ID of the actual control, for example a keyboard key
EndStructure

Structure Menu_Settings_Structure
  Menu_Active.i           ; when true means that the menu system is active and has control
  Menu_System_Type.i    ; the type of menu system
  Menu_Background.i       ; see enumeration Menu_Background
  Data_Menu_Background_Source.i   ; see enumeration Data_Source
  Menu_Background_Colour.i        ; background colour for the menu
  Menu_Action.i
  Menu_Controls_Count.i ; total number of menu controls loaded
  Menu_Control.Menu_Control_Structure[#Max_Menu_Controls] ; array that holds menu controls
EndStructure

; Game

Structure Player_Structure
  Player_Name.s
  Control_Set.Control_Set_Structure
EndStructure


;- Defines

;***************************************************
; System
;***************************************************

Define System.System_Structure
Define Debug_Settings.Debug_Structure
Define Window_Settings.Window_Settings_Structure
Define Screen_Settings.Screen_Settings_Structure
Define FPS_Data.FPS_Data_Structure
Define Graphics.Graphics_Structure
  
;***********************************************
; Menu
;***********************************************

Define Menu_Settings.Menu_Settings_Structure
  
;***********************************************
; Game
;***********************************************
 
;- Macros

Macro _dq_
  "
EndMacro

Macro LIBFUNC(_libFunction_, _library_)
  Global _libFunction_._libFunction_ = GetFunction(_library_, _dq_#_libFunction_#_dq_)
  CompilerIf #PB_Compiler_Debugger
    If _libfunction_ = 0
      Debug "Error: Invalid Library Function '" + _dq_#_libFunction_#_dq_ + "'"
      CallDebugger
    EndIf
  CompilerEndIf
EndMacro

;- Procedures

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
Procedure InitGDK()
  ; Used for Linux to find the refresh rate of the monitor
  Protected Lib.i
  Lib = OpenLibrary(#PB_Any, "libgdk-3.so")
  If Lib
    LIBFUNC(gdk_display_get_monitor_at_window, Lib)
    LIBFUNC(gdk_display_get_default, Lib)
    LIBFUNC(gdk_monitor_get_display, Lib)
    LIBFUNC(gdk_monitor_get_refresh_rate, Lib)
    LIBFUNC(gdk_monitor_get_refresh_rate, Lib)
  Else
    Debug "Error open library 'libgdk-3.so'"
  EndIf
  ProcedureReturn Lib
EndProcedure
CompilerEndIf

;- Error Handler

Procedure Fatal_Error(*System.System_Structure)
  Debug "FATAL ERROR: " + *System\Fatal_Error_Message
  CloseScreen() ; drop back to desktop
  MessageRequester (*System\Game_Title + " Fatal Error", "FATAL ERROR!" + #CRLF$ + *System\Fatal_Error_Message, #PB_MessageRequester_Error)
  End 1 ; 1 means there was an error
EndProcedure

;- Utilities

Procedure.q GetPhysicalMem()
  Protected Size.q
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      GetPhysicallyInstalledSystemMemory(@Size)
    CompilerCase #PB_OS_Linux
      Size = MemoryStatus(#PB_System_TotalPhysical)
  CompilerEndSelect
  ProcedureReturn Size
EndProcedure

Procedure.s GetOSVersionString()
  Define OS_Version.s
  Select OSVersion()
    Case #PB_OS_Windows_NT3_51 : OS_Version.s = "Windows NT 3.51"
    Case #PB_OS_Windows_95 : OS_Version.s = "Windows 95"
    Case #PB_OS_Windows_NT_4 : OS_Version.s = "Windows NT 4"
    Case #PB_OS_Windows_98 : OS_Version.s = "Windows 98"
    Case #PB_OS_Windows_ME : OS_Version.s = "Windows ME"
    Case #PB_OS_Windows_2000 : OS_Version.s = "Windows 2000"
    Case #PB_OS_Windows_XP : OS_Version.s = "Windows XP"
    Case #PB_OS_Windows_Server_2003 : OS_Version.s = "Windows Server 2003"
    Case #PB_OS_Windows_Vista : OS_Version.s = "Windows Vista"
    Case #PB_OS_Windows_Server_2008 : OS_Version.s = "Windows Server 2008"
    Case #PB_OS_Windows_7 : OS_Version.s = "Windows 7"
    Case #PB_OS_Windows_Server_2008_R2 : OS_Version.s = "Windows Server 2008 R2"
    Case #PB_OS_Windows_8 : OS_Version.s = "Windows 8"
    Case #PB_OS_Windows_Server_2012 : OS_Version.s = "Windows Server 2012"
    Case #PB_OS_Windows_8_1 : OS_Version.s = "Windows 8.1"
    Case #PB_OS_Windows_Server_2012_R2 : OS_Version.s = "Windows Server 2012 R2"
    Case #PB_OS_Windows_10 : OS_Version.s = "Windows 10"
    Case #PB_OS_Windows_11 : OS_Version.s = "Windows 11"
    Case #PB_OS_Windows_Future : OS_Version.s = "Unknown Windows"
    Default : OS_Version.s = "Unknown Windows"
  EndSelect
  ProcedureReturn OS_Version
EndProcedure

;- Graphics

Procedure InitDesktop(*Screen_Settings.Screen_Settings_Structure, *FPS_Data.FPS_Data_Structure)
  ; used to check which monitors are connected and how to display the game by default
  Protected c.i, t.i
  Protected *Display, *GDKWindow, *Monitor
  *Screen_Settings\Num_Monitors = ExamineDesktops()
  Debug "InitDesktop: " + *Screen_Settings\Num_Monitors + " monitors detected"
  *Screen_Settings\Selected_Desktop = 0 ; select the first monitor by default, need to add an option to change this somewhere
  If *Screen_Settings\Num_Monitors > 0
    t = *Screen_Settings\Num_Monitors
    If t > #Max_Monitors_Supported : t = #Max_Monitors_Supported : EndIf
    *Screen_Settings\Total_Desktop_Width = 0
    For c = 0 To *Screen_Settings\Num_Monitors - 1
      *Screen_Settings\Desktop[c]\Name = DesktopName(c)
      *Screen_Settings\Desktop[c]\Width = DesktopWidth(c)
      *Screen_Settings\Desktop[c]\Height = DesktopHeight(c)
      *Screen_Settings\Desktop[c]\Depth = DesktopDepth(c)
      *Screen_Settings\Desktop[c]\Frequency = DesktopFrequency(c)
      *Screen_Settings\Total_Desktop_Width = *Screen_Settings\Total_Desktop_Width + *Screen_Settings\Desktop[c]\Width
    Next
    ; Full screen mode is always on monitor 0, this is a limitation of PureBasic
    *Screen_Settings\Screen_W = DesktopWidth(0)
    *Screen_Settings\Screen_H = DesktopHeight(0) 
    ; Set frame rate to desktop 0 frequency
    If *Screen_Settings\Flip_Mode <> #PB_Screen_NoSynchronization ; NoSync mode leaves FPS_Limit unchanged
      *FPS_Data\FPS_Limit = *Screen_Settings\Desktop[0]\Frequency
    EndIf
    *FPS_Data\Frequency = *Screen_Settings\Desktop[0]\Frequency
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      *Display = gdk_display_get_default()
      *GDKWindow = gdk_get_default_root_window_()
      *Monitor = gdk_display_get_monitor_at_window(*Display, *GDKWindow)
      *FPS_Data\Frequency = gdk_monitor_get_refresh_rate(*Monitor) / 1000
    CompilerEndIf
    Debug "Desktop " + c + " frequency: " + *FPS_Data\Frequency
  Else
    Debug "InitDesktop: could not initialise desktop"
    ProcedureReturn 0
  EndIf
  ProcedureReturn 1
EndProcedure

Procedure SetWindowFlags(*Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure, *Window_Flags.Integer)
  ; used to set the flags for how the windowed application will be displayed
  If *Screen_Settings\Full_Screen
    ; Set window flags for windowed full screen
    *Window_Flags\i = #PB_Window_Maximize | #PB_Window_BorderLess
  Else
    *Window_Flags\i = #PB_Window_MinimizeGadget
    If *Window_Settings\Allow_Window_Resize
      *Window_Flags\i = *Window_Flags\i | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget
    EndIf
    If *Window_Settings\Reset_Window ; windows has been reset back to main display, centre it
      *Window_Flags\i = *Window_Flags\i | #PB_Window_ScreenCentered
    EndIf  
    If *Window_Settings\Window_Maximised
      *Window_Flags\i = *Window_Flags\i | #PB_Window_Maximize
    EndIf
  EndIf
EndProcedure

Procedure GetScreenWidth(*Screen_Settings.Screen_Settings_Structure)
  ; Returns the screen width whether it's a window or full screen
  If *Screen_Settings\Full_Screen
    ProcedureReturn *Screen_Settings\Screen_W
  Else
    ProcedureReturn WindowWidth(#Game_Window_Main)
  EndIf
EndProcedure

Procedure GetScreenHeight(*Screen_Settings.Screen_Settings_Structure)
  If *Screen_Settings\Full_Screen
    ProcedureReturn *Screen_Settings\Screen_H
  Else
    ProcedureReturn WindowHeight(#Game_Window_Main)
  EndIf
EndProcedure

Procedure GetCRTFilterLineValue(Pixel_Size.i, Position.i)
  ; Position is 0 to Pixel_Size - 1
  Protected Angle.i, Return_Val.i
  If Pixel_Size < 2
    ProcedureReturn 0 ; no filter
  EndIf
  If Pixel_Size = 2
    If Position = 0:ProcedureReturn 200:EndIf
    If Position = 1:ProcedureReturn 0:EndIf
  EndIf  
  If Pixel_Size = 3
    If Position = 0:ProcedureReturn 254:EndIf
    If Position = 1:ProcedureReturn 0:EndIf
    If Position = 2:ProcedureReturn 160:EndIf
  EndIf
  If Pixel_Size = 4
    If Position = 0:ProcedureReturn 254:EndIf
    If Position = 1:ProcedureReturn 80:EndIf
    If Position = 2:ProcedureReturn 0:EndIf
    If Position = 3:ProcedureReturn 160:EndIf
  EndIf
  If Pixel_Size = 5
    If Position = 0:ProcedureReturn 254:EndIf
    If Position = 1:ProcedureReturn 80:EndIf
    If Position = 2:ProcedureReturn 0:EndIf
    If Position = 3:ProcedureReturn 80:EndIf
    If Position = 4:ProcedureReturn 180:EndIf
  EndIf
  If Pixel_Size >= 6
    Angle = 360 / Pixel_Size * Position
    Return_Val = (127 * Cos(Radian(Angle)) + 128) - 1
    ProcedureReturn Return_Val
  EndIf
EndProcedure

Procedure LoadVectorResources(*System.System_Structure, *Graphics.Graphics_Structure)
  Protected c.i
  Debug "LoadVectorResources: loading vector resources"
  Restore Data_Vector_Resources ; start by loading the internal sprites in the game engine (other sprites are loaded from the game file)
  Read *System\Sprite_Vector_Resource_Count
  If *System\Sprite_Vector_Resource_Count > #Max_Vector_Graphics_Resources
    *System\Fatal_Error_Message = "#Max_Sprite_Resources too small to load all vector resources"
    Fatal_Error(*System)
  EndIf
  For c = 0 To *System\Sprite_Vector_Resource_Count - 1
    Read.i *Graphics\Vector_Graphics_Resource[c]\Shape_Type
    Read.i *Graphics\Vector_Graphics_Resource[c]\Background_Transparent
    Read.i *Graphics\Vector_Graphics_Resource[c]\Background_Colour
    Read.i *Graphics\Vector_Graphics_Resource[c]\X
    Read.i *Graphics\Vector_Graphics_Resource[c]\Y
    Read.i *Graphics\Vector_Graphics_Resource[c]\Width
    Read.i *Graphics\Vector_Graphics_Resource[c]\Height
    Read.i *Graphics\Vector_Graphics_Resource[c]\Round_X
    Read.i *Graphics\Vector_Graphics_Resource[c]\Round_Y
    Read.i *Graphics\Vector_Graphics_Resource[c]\Cont
  Next
  Debug "LoadVectorResources: " + *System\Sprite_Vector_Resource_Count + " vector resource(s) loaded"
EndProcedure

Procedure LoadSpriteResources(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure, *Graphics.Graphics_Structure)
  Protected a.i, c.i, d.i, i.i, j.i
  Protected f.s
  Protected Count.i
  Protected x.i, y.i, col.l
  Protected Scratch.i ; this is used as a variable for reading data to be discarded
  Protected Found.i, Zoom.i
  ; Create pixel sprite
  *Screen_Settings\Pixel_Sprite = CreateSprite(#PB_Any, 1, 1, #PB_Sprite_AlphaBlending)
  StartDrawing(SpriteOutput(*Screen_Settings\Pixel_Sprite))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Plot(0, 0, RGBA(255, 255, 255, 255))
  StopDrawing()
  ; Create screen sprite
  *Screen_Settings\Screen_Sprite = CreateSprite(#PB_Any, *Screen_Settings\Screen_Res_Width, *Screen_Settings\Screen_Res_Height, #PB_Sprite_AlphaBlending)
  TransparentSpriteColor(*Screen_Settings\Screen_Sprite, #Magenta)
  ; Find zoomed size that is as big as possible
  Zoom = 0
  Repeat
    Zoom = Zoom + 1
    *Screen_Settings\Zoomed_Width = *Screen_Settings\Screen_Res_Width * Zoom
    *Screen_Settings\Zoomed_Height = *Screen_Settings\Screen_Res_Height * Zoom
    If *Screen_Settings\Zoomed_Height > *Screen_Settings\Screen_Actual_Height
      Found = 1
      Zoom = Zoom - 1
    EndIf
  Until Found
  *Screen_Settings\Screen_Filter_Sprite = CreateSprite(#PB_Any, *Screen_Settings\Screen_Actual_Width, *Screen_Settings\Screen_Actual_Height, #PB_Sprite_AlphaBlending)
  TransparentSpriteColor(*Screen_Settings\Screen_Sprite, #Magenta)
  StartDrawing(SpriteOutput(*Screen_Settings\Screen_Filter_Sprite))
  DrawingMode(#PB_2DDrawing_AllChannels)
  y = 0
  Repeat
    For c = 0 To Zoom-1
      Line(0, y+c, *Screen_Settings\Screen_Actual_Width, 1, RGBA(0, 0, 0, GetCRTFilterLineValue(Zoom, c)))
    Next c
    y = y + zoom
  Until y > *Screen_Settings\Zoomed_Height-1
  StopDrawing()
  a = 0 ; used to read internal then external sprite resources
  i = 0 ; used to load sprite resources
  j = 0 ; used to load sprites
  *System\Sprite_Resource_Count = 0
  Repeat ; loop to read both internal and external data
    Debug "LoadSpriteResources: loading sprite resource list"
    Select *System\Sprite_List_Data_Source
      Case #Data_Source_None
        *System\Sprite_Resource_Count = 0
        Debug "LoadSpriteResources: no sprite resources to load"
      Case #Data_Source_Internal_Memory
        If a = 0
          Debug "LoadSpriteResources: loading internal sprite resource list from memory"
          Restore Data_Internal_Sprite_Resources ; start by loading the internal sprites in the game engine (other sprites are loaded from the game file)
        EndIf
        If a = 1
          Debug "LoadSpriteResources: loading custom sprite resource list from memory"
          Restore Data_Custom_Sprite_Resources ; start by loading the internal sprites in the game engine (other sprites are loaded from the game file)
        EndIf
        Read Count
        If Count > #Max_Sprite_Resources
          *System\Fatal_Error_Message = "#Max_Sprite_Resources too small to load all sprite resources"
          Fatal_Error(*System)
        EndIf
        ; Read complete sprite resource list first
        ; That way sprites can be loaded from the DataSection  
        For c = 0 To Count - 1
          Read.i *Graphics\Sprite_Resource[i]\Width
          Read.i *Graphics\Sprite_Resource[i]\Height
          Read.i *Graphics\Sprite_Resource[i]\Mode
          Read.i *Graphics\Sprite_Resource[i]\Transparent
          Read.i *Graphics\Sprite_Resource[i]\Vector_Drawn
          Read.i *Graphics\Sprite_Resource[i]\Data_Source
          Select *Graphics\Sprite_Resource[i]\Data_Source
            ; Have to specify which variable we read the next data in to
            Case #Data_Source_None
              Read.i Scratch
            Case #Data_Source_Internal_Memory
              Read.i *Graphics\Sprite_Resource[i]\Memory_Location
            Case #Data_Source_File
              Read.s *Graphics\Sprite_Resource[i]\File_Location
            Case #Data_Source_Database   
              Read.i *Graphics\Sprite_Resource[i]\Database_Location
          EndSelect
          i = i + 1
        Next
      Case #Data_Source_File
      Case #Data_Source_Database
    EndSelect
    ; Now that the resource list has been stored, load the sprites.
    ; This is necessary so that sprites can be stored in the DataSection
    If Count > 0
      Restore Data_Sprites
      For c = 0 To Count - 1
        Select *Graphics\Sprite_Resource[j]\Data_Source
          Case #Data_Source_None
            ; Nothing to do, empty sprite            
          Case #Data_Source_Internal_Memory
            *Graphics\Sprite_Resource[j]\ID = CreateSprite(#PB_Any, *Graphics\Sprite_Resource[j]\Width, *Graphics\Sprite_Resource[j]\Height, *Graphics\Sprite_Resource[j]\Mode)
            TransparentSpriteColor(*Graphics\Sprite_Resource[j]\ID, #Magenta)
            If *Graphics\Sprite_Resource[j]\Vector_Drawn
              Select *Graphics\Vector_Graphics_Resource[*Graphics\Sprite_Resource[j]\Memory_Location]\Shape_Type
                Case #Shape_None
                  StartDrawing(SpriteOutput(*Graphics\Sprite_Resource[j]\ID))
                  DrawingMode(#PB_2DDrawing_Default)
                  ;DrawingMode(#PB_2DDrawing_Outlined)
                  Box(0, 0, *Graphics\Sprite_Resource[j]\Width, *Graphics\Sprite_Resource[j]\Height, *Graphics\Vector_Graphics_Resource[*Graphics\Sprite_Resource[j]\Memory_Location]\Background_Colour)
                  StopDrawing()
              EndSelect
            Else
              If Not *Graphics\Sprite_Resource[j]\ID
                *System\Fatal_Error_Message = "Unable to create sprite " + j
                Fatal_Error(*System) 
              EndIf
              StartDrawing(SpriteOutput(*Graphics\Sprite_Resource[j]\ID))
              DrawingMode(#PB_2DDrawing_AllChannels)
              For y = 0 To *Graphics\Sprite_Resource[j]\Height - 1
                For x = 0 To *Graphics\Sprite_Resource[j]\Width - 1
                  Read.l col
                  Plot(x,y,col)
                Next
              Next
              StopDrawing()
            EndIf
          Case #Data_Source_File
            f = *System\Game_Resource_Location + "\" + *Graphics\Sprite_Resource[j]\File_Location
            *Graphics\Sprite_Resource[j]\ID = LoadSprite(#PB_Any, f, *Graphics\Sprite_Resource[c]\Mode)
            If Not *Graphics\Sprite_Resource[j]\ID
              *System\Fatal_Error_Message = "Unable to load sprite " + f
              Fatal_Error(*System)
            EndIf
          Case #Data_Source_Database
            *System\Fatal_Error_Message = "Loading sprites from a database not yet supported"
            Fatal_Error(*System)              
        EndSelect
        j = j + 1
      Next
    EndIf
    *System\Sprite_Resource_Count = *System\Sprite_Resource_Count + Count
    a = a + 1
  Until a = 2
  Debug "LoadSprites: " + *System\Sprite_Resource_Count + " sprite resource(s) loaded"
EndProcedure

Procedure LoadSpriteInstances(*System.System_Structure, *Graphics.Graphics_Structure)
  Protected c.i
  Debug "LoadSpriteInstances: loading sprite instance list"
  Restore Data_Sprite_Instances
  Read *System\Sprite_Instance_Count
  For c = 0 To *System\Sprite_Instance_Count - 1
    Read.i *Graphics\Sprite_Instance[c]\Sprite_Resource
    Read.i *Graphics\Sprite_Instance[c]\X
    Read.i *Graphics\Sprite_Instance[c]\Y
    Read.i *Graphics\Sprite_Instance[c]\Width
    Read.i *Graphics\Sprite_Instance[c]\Height    
    Read.i *Graphics\Sprite_Instance[c]\Velocity_X
    Read.i *Graphics\Sprite_Instance[c]\Velocity_Y
    Read.i *Graphics\Sprite_Instance[c]\Intensity
    Read.i *Graphics\Sprite_Instance[c]\Colour
    Read.i *Graphics\Sprite_Instance[c]\Layer
    Read.i *Graphics\Sprite_Instance[c]\Visible
    Read.i *Graphics\Sprite_Instance[c]\Controlled_By
    If *Graphics\Sprite_Instance[c]\Colour > -1 And *Graphics\Sprite_Instance[c]\Intensity = -1
      ; automatically make intensity 255 if there is a colour set and intensity is -1
      *Graphics\Sprite_Instance[c]\Intensity = 255
    EndIf
  Next c
  Debug "LoadSpriteInstances: " + *System\Sprite_Instance_Count + " sprite instance(s) loaded"
EndProcedure

Procedure LoadSystemFontInstances(*System.System_Structure, *Graphics.Graphics_Structure)
  Protected c.i
  Debug "LoadSystemFontInstances: loading system font instance list"
  Restore Data_System_Font_Instances
  Read *System\System_Font_Instance_Count
  For c = 0 To *System\System_Font_Instance_Count - 1
    Read.s *Graphics\System_Font_Instance[c]\S
    Read.i *Graphics\System_Font_Instance[c]\Variable
    Read.i *Graphics\System_Font_Instance[c]\X
    Read.i *Graphics\System_Font_Instance[c]\Y
    Read.i *Graphics\System_Font_Instance[c]\Char_Width
    Read.i *Graphics\System_Font_Instance[c]\Char_Height
    Read.i *Graphics\System_Font_Instance[c]\Intensity
    Read.i *Graphics\System_Font_Instance[c]\Colour
    Read.i *Graphics\System_Font_Instance[c]\Layer
    Read.i *Graphics\System_Font_Instance[c]\Visible
    If *Graphics\System_Font_Instance[c]\Colour > -1 And *Graphics\System_Font_Instance[c]\Intensity = -1
      ; automatically make intensity 255 if there is a colour set and intensity is -1
      *Graphics\System_Font_Instance[c]\Intensity = 255
    EndIf
  Next c
  Debug "LoadSystemFontInstances: " + *System\System_Font_Instance_Count + " system font instance(s) loaded"
EndProcedure

Procedure LoadSystemFont(*System.System_Structure)
  Protected c.i, x.i, y.i, Bit.i, BitV.i
  Protected PixelData.a
  Restore Data_Sprite_System_Font
  For c = 0 To #Num_System_Font_Char-1
    *System\Font_Char_Sprite[c] = CreateSprite(#PB_Any, 8, 8, #PB_Sprite_AlphaBlending)
    TransparentSpriteColor(*System\Font_Char_Sprite[c], #Magenta)
    StartDrawing(SpriteOutput(*System\Font_Char_Sprite[c]))
    DrawingMode(#PB_2DDrawing_AllChannels)
    For y = 0 To 7
      Read.a PixelData
      Bit = 128
      For x = 0 To 7
        If PixelData & Bit
          Plot(x, y, RGBA(255, 255, 255, 255))
        Else
          Plot(x, y, RGBA(0, 0, 0, 0))
        EndIf
        Bit = Bit / 2
      Next
    Next
    StopDrawing()
  Next
  Debug "LoadSystemFont: system font loaded"
EndProcedure

Procedure GetScreenPosition(*Screen_Settings.Screen_Settings_Structure)
  Protected Width.i, Height.i
  Protected Screen_Top.i, Screen_Left.i; coordinates to position the screen within the window useful for mazimised or full screen
  Protected Inner_Width.i
  Protected Inner_Height.i
  Protected Desktop_Res_X.d, Desktop_Res_Y.d
  Protected Border_Ratio_X.d, Border_Ratio_Y.d
  Desktop_Res_X = DesktopResolutionX()
  Desktop_Res_Y = DesktopResolutionY()
  If *Screen_Settings\Full_Screen
    Inner_Width = *Screen_Settings\Desktop[0]\Width
    Inner_Height = *Screen_Settings\Desktop[0]\Height
    Desktop_Res_X = 1.0
    Desktop_Res_Y = 1.0
  Else
    Inner_Width = WindowWidth(#Game_Window_Main, #PB_Window_InnerCoordinate) * Desktop_Res_X
    Inner_Height = WindowHeight(#Game_Window_Main, #PB_Window_InnerCoordinate) * Desktop_Res_Y
  EndIf
  Width = Inner_Width
  Height = Inner_Height
  If Inner_Width / *Screen_Settings\Screen_Ratio > Inner_Height
    ; zoom to the height
    Debug "Zooming to height"
    Width = Height * *Screen_Settings\Screen_Ratio
    Screen_Top = 0
    Screen_Left = ((Inner_Width / 2) - (Width / 2))
  Else
    ; Zoom to width
    Debug "Zooming to width"
    Height = Width / *Screen_Settings\Screen_Ratio
    Screen_Left = 0
    Screen_Top = ((Inner_Height / 2) - (Height / 2))
  EndIf
  *Screen_Settings\Screen_Top = Screen_Top
  *Screen_Settings\Screen_Left = Screen_Left
  *Screen_Settings\Screen_Actual_Width = Width
  *Screen_Settings\Screen_Actual_Height = Height
  Border_Ratio_X = *Screen_Settings\Border_Width / *Screen_Settings\Screen_Res_Width
  Border_Ratio_Y = *Screen_Settings\Border_Height / *Screen_Settings\Screen_Res_Height
  *Screen_Settings\Screen_Inner_Width = Width / Border_Ratio_X
  *Screen_Settings\Screen_Inner_Height = Height / Border_Ratio_Y
  *Screen_Settings\Screen_Inner_X = (*Screen_Settings\Screen_Actual_Width - *Screen_Settings\Screen_Inner_Width) / 2
  *Screen_Settings\Screen_Inner_Y = (*Screen_Settings\Screen_Actual_Height - *Screen_Settings\Screen_Inner_Height) / 2
EndProcedure

Procedure SetWindowScreen(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure)
  ; Sets the window screen closing the old one if necessary
  GetScreenPosition(*Screen_Settings)
  If *Screen_Settings\Screen_Open
    Debug "SetWindowScreen: closing current screen"
    CloseScreen()
    *Screen_Settings\Screen_Open = 0
  EndIf
  If OpenWindowedScreen(WindowID(#Game_Window_Main), *Screen_Settings\Screen_Left, *Screen_Settings\Screen_Top, *Screen_Settings\Screen_Actual_Width, *Screen_Settings\Screen_Actual_Height, #False, 0, 0, *Screen_Settings\Flip_Mode)
    *Screen_Settings\Screen_Open = 1
    *Screen_Settings\Screen_Active = 1
  Else
    Debug "SetWindowScreen: could not initialise windowed screen"
    ProcedureReturn 0
  EndIf
  ProcedureReturn 1
EndProcedure

Procedure SetScreen(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure)
  ; Sets (or resets) the screen. In fullscreen mode it opens a fullscreen.
  ; In window mode it opens a window then opens a window screen inside it.
  ; When used mid game-loop check if it failed and generate a fatal error.
  Protected Result.i
  Protected Temp_Zoom.i, Temp_Min_Width.i, Temp_Min_Height.i
  Protected Old_Width.i, Old_Height.i
  Protected Window_Flags.i
  Protected c.i
  If *Screen_Settings\Screen_Open
    Debug "SetScreen: closing screen"
    CloseScreen()
    *Screen_Settings\Screen_Open = 0
  EndIf
  If *Window_Settings\Window_Open
    ; Only used if switching to full screen from a window
    Debug "SetScreen: closing window"
    CloseWindow(#Game_Window_Main)
    If IsWindow(#Game_Window_Debug)
      ; only close the window if its open
      CloseWindow(#Game_Window_Debug)
    EndIf
    *Window_Settings\Window_Open = 0
  EndIf
  ; Set the screen ratio based on the actual screen resolution
  *Screen_Settings\Screen_Ratio = *Screen_Settings\Screen_Res_Width / *Screen_Settings\Screen_Res_Height
  If *Screen_Settings\Full_Screen And *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic
    ; set the classic full screen
    Debug "SetScreen: opening full screen " + *Screen_Settings\Screen_W + " x " + *Screen_Settings\Screen_H
    If OpenScreen(*Screen_Settings\Screen_W, *Screen_Settings\Screen_H, 32, *System\Game_Title, *Screen_Settings\Flip_Mode)
      *Screen_Settings\Screen_Open = 1
      *Screen_Settings\Screen_Active = 1
    Else
      Debug "SetScreen: could not intialise full screen"
      ProcedureReturn 0
    EndIf 
  EndIf
  If Not (*Screen_Settings\Full_Screen And *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic)
    ; If not full screen then a window needs to be opened
    If *Window_Settings\Window_X > *Screen_Settings\Total_Desktop_Width And Not *Screen_Settings\Full_Screen
      ; check the window is visible, useful if you unplug a monitor
      ; Only reset the window if it's not in windowed full screen mode
      Debug "SetScreen: window is not visible"
      *Window_Settings\Reset_Window = 1
      *Window_Settings\Window_X = 0
      *Window_Settings\Window_Y = 0
      *Window_Settings\Window_Maximised = 0 ; need to demaximise window so it can get new coordinates
    EndIf
    If *Window_Settings\Window_Debug_X > *Screen_Settings\Total_Desktop_Width And Not *Screen_Settings\Full_Screen
      Debug "SetScreen: debug window is not visible"
      *Window_Settings\Window_Debug_X = 0
      *Window_Settings\Window_Debug_Y = 0
    EndIf    
    If *Screen_Settings\Set_Zoom
      Old_Width = *Window_Settings\Window_W
      Old_Height = *Window_Settings\Window_H
      *Window_Settings\Window_W = *Screen_Settings\Screen_Res_Width * *Screen_Settings\Set_Zoom
      *Window_Settings\Window_H = *Screen_Settings\Screen_Res_Height * *Screen_Settings\Set_Zoom
      If Old_Width < *Window_Settings\Window_W
        ; move to the left an dup
        *Window_Settings\Window_X = *Window_Settings\Window_X - ((*Window_Settings\Window_W - Old_Width) / 3)
        *Window_Settings\Window_Y = *Window_Settings\Window_Y - ((*Window_Settings\Window_H - Old_Height) / 3)
      Else
        ; move to the right and down
        *Window_Settings\Window_X = *Window_Settings\Window_X + ((Old_Width - *Window_Settings\Window_W) / 3)
        *Window_Settings\Window_Y = *Window_Settings\Window_Y + ((Old_Height - *Window_Settings\Window_H) / 3)      
      EndIf
      *Screen_Settings\Set_Zoom = 0
    EndIf
    SetWindowFlags(*Window_Settings, *Screen_Settings, @Window_Flags)
    Debug "SetScreen: opening window"
    If OpenWindow(#Game_Window_Main, *Window_Settings\Window_X, *Window_Settings\Window_Y, *Window_Settings\Window_W / DesktopResolutionX(), *Window_Settings\Window_H / DesktopResolutionY(), *System\Game_Title, Window_Flags)  
      Debug "SetScreen: Window_X: " + *Window_Settings\Window_X + " Window_Y: " + *Window_Settings\Window_Y
      Debug "SetScreen: Window_W: " + *Window_Settings\Window_W + " Window_H: " + *Window_Settings\Window_H
      SetWindowColor(#Game_Window_Main, *Window_Settings\Background_Colour) 
      *Window_Settings\Window_Open = 1
      WindowBounds(#Game_Window_Main, *Screen_Settings\Screen_Res_Width / DesktopResolutionX(), *Screen_Settings\Screen_Res_Height / DesktopResolutionY(), #PB_Default, #PB_Default)
      ; Sets the limit of how small a window can be resized
      If Not *System\Config_File Or *Window_Settings\Reset_Window ; update window coordinates because there was no config file
        Debug "SetScreen: no config file, setting window properties"
        *Window_Settings\Window_X = WindowX(#Game_Window_Main)
        *Window_Settings\Window_Y = WindowY(#Game_Window_Main)
        *Window_Settings\Window_W = WindowWidth(#Game_Window_Main)
        *Window_Settings\Window_H = WindowHeight(#Game_Window_Main)
        *Window_Settings\Reset_Window = 0
      EndIf
      If *System\Debug_Window
        Debug "SetScreen: opening debug window"
        OpenWindow(#Game_Window_Debug, *Window_Settings\Window_Debug_X, *Window_Settings\Window_Debug_Y, *Window_Settings\Window_Debug_W, *Window_Settings\Window_Debug_H, "Debug", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget)
        WindowBounds(#Game_Window_Debug, 200, 300, #PB_Default, #PB_Default)
        StickyWindow(#Game_Window_Debug, #True) 
      EndIf
    Else
      Debug "SetScreen: could not initialise window"
      ProcedureReturn 0
    EndIf
  EndIf
  If Not (*Screen_Settings\Full_Screen And *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic)
    Debug "SetScreen: opening window screen"
    SetWindowScreen(*System, *Screen_Settings)
    SetActiveWindow(#Game_Window_Main)
  Else
    ; Calculate the screen position in the full screen classic
    GetScreenPosition(*Screen_Settings)
  EndIf
  ProcedureReturn 1
EndProcedure 

;Procedure InitialiseFonts(*System.System_Structure)
;  Protected.i Result
;  Font::Initialise()
;  Define Font_Parameters1.Font::Parameters_Structure
;  With Font_Parameters1
;    \Name = "Fixedsys Neo" ; used for debug info
;    \Filename = *System\Data_Directory + "data/fonts/FixedsysNeo/FixedsysNeo.ttf"
;    \Size = 8
;    CompilerIf #PB_Compiler_OS = #PB_OS_Windows Or #PB_Compiler_OS = #PB_OS_Linux
;      \Crop_Bottom_Ratio = 1.1
;      \Crop_Top_Ratio = 0.06
;    CompilerEndIf
;    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
;      \Crop_Bottom_Ratio = 0.55
;      \Crop_Right_Ratio = 0.4
;      \Crop_Top_Ratio = 0.01
;    CompilerEndIf
;    \Colour = RGBA(255, 255, 255, 255)
;    \Back_Colour = RGBA(0, 0, 0, 0)
;    \Available = Font::#Font_Characters_All
;    \Border = 0
;    \Border_Colour = RGBA(255, 0, 0, 255)
;    \Include_Sprite = 1 ; sprites
;  EndWith
;  Result = Font::CreateFontUnicode(#Font_Fixedsys_Neo_Plus, @Font_Parameters1)
;  If Result = -1
;    Debug "Failed initialising font Fixedsys Neo Plus"
;    ProcedureReturn 0
;  EndIf
;  ProcedureReturn 1
;EndProcedure

Procedure ResetScreen(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure, *Graphics.Graphics_Structure)
  *Window_Settings\Window_Debug_Edit_Gadget = 0 ; reset the gadgets on the debug window
  SetScreen(*System, *Window_Settings, *Screen_Settings)
  LoadSpriteResources(*System, *Screen_Settings, *Graphics)
  ;InitialiseFonts(*System)
  LoadSystemFont(*System)
EndProcedure

Procedure SwitchFullScreen(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure, *Graphics.Graphics_Structure)
  ; Handles reloading of resources
  Protected x.i, y.i
  *Window_Settings\Window_Debug_Edit_Gadget = 0 ; reset the gadgets on the debug window
  *Screen_Settings\Full_Screen = 1 - *Screen_Settings\Full_Screen ; toggle full screen
  If Not SetScreen(*System, *Window_Settings, *Screen_Settings)
    *System\Fatal_Error_Message = "SetScreen failed"
    Fatal_Error(*System)
  EndIf
  If *Screen_Settings\Full_Screen
    x = (*Screen_Settings\Screen_Actual_Width / 2) / DesktopResolutionX()
    y = (*Screen_Settings\Screen_Actual_Height / 2) / DesktopResolutionY()
  EndIf
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  If *Screen_Settings\Full_Screen_Type = #Full_Screen_Windowed
    If *Screen_Settings\Full_Screen
      gtk_window_fullscreen_(WindowID(#Game_Window_Main))
    Else
      gtk_window_unfullscreen_(WindowID(#Game_Window_Main))
    EndIf
  EndIf
  CompilerEndIf
  MouseLocate(x, y)
  LoadSpriteResources(*System, *Screen_Settings, *Graphics) ; need to reload sprites anytime SetScreen is called
  ;InitialiseFonts(*System)
  LoadSystemFont(*System)
  *System\Time_Full_Screen_Switched = ElapsedMilliseconds()
EndProcedure

Procedure SaveScreen(*System.System_Structure)
  Protected s.i, d.s, n.s, f.s
  s = GrabSprite(#PB_Any, 0, 0, ScreenWidth(), ScreenHeight())
  d = FormatDate("%yyyy%mm%dd-%hh%ii%ss", Date())
  n = ""
  If *System\Last_Screen_Capture_File = d
    ; add counter to end of date
    *System\Last_Screen_Capture_Number = *System\Last_Screen_Capture_Number + 1
    n = "-" + Str(*System\Last_Screen_Capture_Number)
  Else
    ; reset the counter because the time has incremented to the next second
    *System\Last_Screen_Capture_Number = 0
  EndIf
  f = *System\Current_Directory + "screen-capture-" + d + n + ".png"
  *System\Last_Screen_Capture_File = d
  If SaveSprite(s, f, #PB_ImagePlugin_PNG)
    Debug "SaveScreen: saved screen-capture-" + d + n + ".png"
  Else
    Debug "SaveScreen: failed"
  EndIf
  FreeSprite(s)
EndProcedure

Procedure DoClearScreen(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure)
  If *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic And *Screen_Settings\Full_Screen
    ClearScreen(*Screen_Settings\Classic_Screen_Background_Colour)
    ZoomSprite(*Screen_Settings\Pixel_Sprite, *Screen_Settings\Screen_Res_Width, *Screen_Settings\Screen_Res_Height)
    DisplayTransparentSprite(*Screen_Settings\Pixel_Sprite, 0, 0, 255, *Screen_Settings\Background_Colour)
  Else
    If Not *Screen_Settings\Full_Screen_Inactive
      ClearScreen(*Screen_Settings\Background_Colour)
    EndIf
  EndIf
EndProcedure

Procedure DoFlipBuffer(*Screen_Settings.Screen_Settings_Structure)
  If Not *Screen_Settings\Full_Screen_Inactive
    ; don't try and flip an inactive full screen
    FlipBuffers()
  EndIf
EndProcedure

Procedure Draw3DWorld(*System.System_Structure)
  Select *System\Render_Engine3D
    Case #Render_Engine3D_Ogre
      ; Insert 3D engine here
  EndSelect
EndProcedure

Procedure DisplaySpriteInstance(*Graphics.Graphics_Structure, i.i)
  ; Sprite instances are all the copies of sprites displayed in a level
  ;Debug "Zooming sprite to: " + *Graphics\Sprite_Instance[i]\Width + " x " + *Graphics\Sprite_Instance[i]\Height
  ZoomSprite(*Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\ID, *Graphics\Sprite_Instance[i]\Width, *Graphics\Sprite_Instance[i]\Height)
  ;DisplayTransparentSprite(*Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\ID, *Graphics\Sprite_Instance[i]\X, *Graphics\Sprite_Instance[i]\Y)
  
  If *Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\Transparent
    If *Graphics\Sprite_Instance[i]\Intensity > -1 And *Graphics\Sprite_Instance[i]\Colour = -1
      ; set intensity but not colour
      DisplayTransparentSprite(*Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\ID, *Graphics\Sprite_Instance[i]\X, *Graphics\Sprite_Instance[i]\Y, *Graphics\Sprite_Instance[i]\Intensity)
    ElseIf *Graphics\Sprite_Instance[i]\Intensity > -1 And *Graphics\Sprite_Instance[i]\Colour > -1
      ; set intensity and colour
      DisplayTransparentSprite(*Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\ID, *Graphics\Sprite_Instance[i]\X, *Graphics\Sprite_Instance[i]\Y, *Graphics\Sprite_Instance[i]\Intensity, *Graphics\Sprite_Instance[i]\Colour)
    ElseIf *Graphics\Sprite_Instance[i]\Intensity = -1 And *Graphics\Sprite_Instance[i]\Colour = -1
      ; ignore both intensity and colour
      DisplayTransparentSprite(*Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\ID, *Graphics\Sprite_Instance[i]\X, *Graphics\Sprite_Instance[i]\Y)
    EndIf
  Else
    DisplaySprite(*Graphics\Sprite_Resource[*Graphics\Sprite_Instance[i]\Sprite_Resource]\ID, *Graphics\Sprite_Instance[i]\X, *Graphics\Sprite_Instance[i]\Y)
  EndIf
EndProcedure

Procedure DisplaySpriteResource(*System.System_Structure, *Graphics.Graphics_Structure, s.i, x.i, y.i, Intensity.i=255)
  ; Used for manually displaying a sprite
  If *Graphics\Sprite_Resource[s]\Transparent
    DisplayTransparentSprite(*Graphics\Sprite_Resource[s]\ID, x, y, Intensity)
  Else
    DisplaySprite(*Graphics\Sprite_Resource[s]\ID, x, y)
  EndIf 
EndProcedure

Procedure GetSystemFontChar(c.i)
  Select c
    Case 65:ProcedureReturn 0 ;A
    Case 66:ProcedureReturn 1 ;B
    Case 67:ProcedureReturn 2 ;C
    Case 68:ProcedureReturn 3 ;D
    Case 69:ProcedureReturn 4 ;E
    Case 70:ProcedureReturn 5 ;F
    Case 71:ProcedureReturn 6 ;G
    Case 72:ProcedureReturn 7 ;H
    Case 73:ProcedureReturn 8 ;I
    Case 74:ProcedureReturn 9 ;J
    Case 75:ProcedureReturn 10 ;K
    Case 76:ProcedureReturn 11 ;L
    Case 77:ProcedureReturn 12 ;M
    Case 78:ProcedureReturn 13 ;N
    Case 79:ProcedureReturn 14 ;O
    Case 80:ProcedureReturn 15 ;P
    Case 81:ProcedureReturn 16 ;Q
    Case 82:ProcedureReturn 17 ;R
    Case 83:ProcedureReturn 18 ;S
    Case 84:ProcedureReturn 19 ;T
    Case 85:ProcedureReturn 20 ;U
    Case 86:ProcedureReturn 21 ;V
    Case 87:ProcedureReturn 22 ;W
    Case 88:ProcedureReturn 23 ;X
    Case 89:ProcedureReturn 24 ;Y
    Case 90:ProcedureReturn 25 ;Z
    Case 97:ProcedureReturn 26 ;a
    Case 98:ProcedureReturn 27 ;b
    Case 99:ProcedureReturn 28 ;c
    Case 100:ProcedureReturn 29 ;d
    Case 101:ProcedureReturn 30 ;e
    Case 102:ProcedureReturn 31 ;f
    Case 103:ProcedureReturn 32 ;g
    Case 104:ProcedureReturn 33 ;h
    Case 105:ProcedureReturn 34 ;i
    Case 106:ProcedureReturn 35 ;j
    Case 107:ProcedureReturn 36 ;k
    Case 108:ProcedureReturn 37 ;l
    Case 109:ProcedureReturn 38 ;m
    Case 110:ProcedureReturn 39 ;n
    Case 111:ProcedureReturn 40 ;o
    Case 112:ProcedureReturn 41 ;p
    Case 113:ProcedureReturn 42 ;q
    Case 114:ProcedureReturn 43 ;r
    Case 115:ProcedureReturn 44 ;s
    Case 116:ProcedureReturn 45 ;t
    Case 117:ProcedureReturn 46 ;u
    Case 118:ProcedureReturn 47 ;v
    Case 119:ProcedureReturn 48 ;w
    Case 120:ProcedureReturn 49 ;x
    Case 121:ProcedureReturn 50 ;y
    Case 122:ProcedureReturn 51 ;z
    Case 48:ProcedureReturn 52 ;0
    Case 49:ProcedureReturn 53 ;1
    Case 50:ProcedureReturn 54 ;2
    Case 51:ProcedureReturn 55 ;3
    Case 52:ProcedureReturn 56 ;4
    Case 53:ProcedureReturn 57 ;5
    Case 54:ProcedureReturn 58 ;6
    Case 55:ProcedureReturn 59 ;7
    Case 56:ProcedureReturn 60 ;8
    Case 57:ProcedureReturn 61 ;9
    Case 32:ProcedureReturn 62 ;space
    Case 33:ProcedureReturn 63 ;!
    Case 34:ProcedureReturn 64 ;"
    Case 35:ProcedureReturn 65 ;#
    Case 36:ProcedureReturn 66 ;$
    Case 37:ProcedureReturn 67 ;%
    Case 38:ProcedureReturn 68 ;&
    Case 39:ProcedureReturn 69 ;'
    Case 40:ProcedureReturn 70 ;(
    Case 41:ProcedureReturn 71 ;)
    Case 42:ProcedureReturn 72 ;*
    Case 43:ProcedureReturn 73 ;+
    Case 44:ProcedureReturn 74 ;,
    Case 45:ProcedureReturn 75 ;minus
    Case 46:ProcedureReturn 76 ;.
    Case 47:ProcedureReturn 77 ;/
    Case 58:ProcedureReturn 78 ;:
    Case 59:ProcedureReturn 79 ;;
    Case 60:ProcedureReturn 80 ;<
    Case 61:ProcedureReturn 81 ;=
    Case 62:ProcedureReturn 82 ;>
    Case 63:ProcedureReturn 83 ;?
    Case 64:ProcedureReturn 84 ;@
    Case 124:ProcedureReturn 85 ;|
    Case 91:ProcedureReturn 86 ;[
    Case 93:ProcedureReturn 87 ;]
    Case 163:ProcedureReturn 88 ;£
    Case 92:ProcedureReturn 89 ;\    
    Case 94:ProcedureReturn 90 ;^
    Case 95:ProcedureReturn 91 ;_  
    Case 96:ProcedureReturn 92 ;`
    Case 126:ProcedureReturn 93 ;~
    Case 123:ProcedureReturn 94 ;{
    Case 125:ProcedureReturn 95 ;}
    Case 8364:ProcedureReturn 96 ;€
    Case 165:ProcedureReturn 97 ;¥
    Case 169:ProcedureReturn 98 ;©
    Case 8482:ProcedureReturn 99 ;™
    Default:ProcedureReturn 100 ;unknown
  EndSelect
EndProcedure

Procedure DisplaySystemFontString(*System.System_Structure, s.s, x.i, y.i, Intensity.i, Colour.i, Width.i, Height.i)
  Protected c.i
  Protected Char.s
  Protected SystemFontIndex.i
  For c = 1 To Len(s)
    Char = Mid(s, c, 1)
    SystemFontIndex = Asc(Char)
    SpriteQuality(#PB_Sprite_NoFiltering)
    ZoomSprite(*System\Font_Char_Sprite[GetSystemFontChar(SystemFontIndex)], Width, Height)
    DisplayTransparentSprite(*System\Font_Char_Sprite[GetSystemFontChar(SystemFontIndex)], x, y, Intensity, Colour)
    x = x + Width
  Next
EndProcedure

Procedure DisplaySystemFontInstance(*System.System_Structure, *Graphics.Graphics_Structure, i.i)
  DisplaySystemFontString(*System, *Graphics\System_Font_Instance[i]\S, *Graphics\System_Font_Instance[i]\X, *Graphics\System_Font_Instance[i]\Y, *Graphics\System_Font_Instance[i]\Intensity,
                          *Graphics\System_Font_Instance[i]\Colour, *Graphics\System_Font_Instance[i]\Char_Width, *Graphics\System_Font_Instance[i]\Char_Height)
EndProcedure

Procedure ShowDebugInfo(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure, *FPS_Data.FPS_Data_Structure)
  Protected FPS.s
  If *System\Show_Debug_Info And Not *Screen_Settings\Full_Screen_Inactive
    FPS = "FPS:"
    FPS = FPS + Str(*FPS_Data\FPS)
    ;Font::DisplayStringSpriteUnicode(#Font_Fixedsys_Neo_Plus, FPS, 0, 0)
    DisplaySystemFontString(*System, FPS, 0, 0, 255, #White, 8, 8)
  EndIf
EndProcedure

Procedure ShowDebugWindowInfo(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *FPS_Data.FPS_Data_Structure, *Debug_Settings.Debug_Structure)
  ; Shows the variables in the Debug_Var array
  Protected Current_Time.q = ElapsedMilliseconds()
  Protected Text_Y.i = 2
  Protected Text_Height = 20
  Protected c.i
  Protected Displat_Text.s
  If *Debug_Settings\Debug_Var[0] <> "" And Not *Window_Settings\Window_Debug_Edit_Gadget
    ; there is at least one variable
    Debug "ShowDebugWindowInfo: creating debug window edit gadget"
    *Window_Settings\Window_Debug_Edit_Gadget = EditorGadget(#PB_Any, 10,  Text_Y, *Window_Settings\Window_Debug_W-20, *Window_Settings\Window_Debug_H-20, #PB_Editor_ReadOnly)
    If *Window_Settings\Debug_Window_Front_Colour Or *Window_Settings\Debug_Window_Back_Colour
      SetGadgetColor(*Window_Settings\Window_Debug_Edit_Gadget, #PB_Gadget_FrontColor, *Window_Settings\Debug_Window_Front_Colour)
      SetGadgetColor(*Window_Settings\Window_Debug_Edit_Gadget, #PB_Gadget_BackColor, *Window_Settings\Debug_Window_Back_Colour)
    EndIf
  EndIf
  If Current_Time - *System\Last_Debug_Window_Update > 200 ; 5 updates a second
    *System\Last_Debug_Window_Update = Current_Time
    If IsWindow(#Game_Window_Debug) And *Window_Settings\Window_Debug_Edit_Gadget
      ClearGadgetItems(*Window_Settings\Window_Debug_Edit_Gadget)
      For c = 1 To #Max_Debug_Vars
        If *Debug_Settings\Debug_Var[c-1] <> ""
          AddGadgetItem(*Window_Settings\Window_Debug_Edit_Gadget, c-1, *Debug_Settings\Debug_Var[c-1])
        EndIf
      Next c
    EndIf
  EndIf
EndProcedure

Procedure DrawPixel(*Screen_Settings.Screen_Settings_Structure, x.i, y.i, Colour.i)
  ;ZoomSprite(*Screen_Settings\Pixel_Sprite, *Screen_Settings\Zoom, *Screen_Settings\Zoom)
  DisplayTransparentSprite(*Screen_Settings\Pixel_Sprite, x, y, 255, Colour)
EndProcedure

;Procedure DrawPixel2(x.i, y.i, Colour.i, *Screen_Settings.Screen_Settings_Structure)
;  ; This draws a pixel and adjusts for different ratios
;  Protected Pixel_End.d, Next_Pixel_Start.d
;  Protected Width.d
;  Protected Height.d
;  Width = *Screen_Settings\Zoom
;  Height = *Screen_Settings\Zoom
;  If x > 0
;    Pixel_End = (x * *Screen_Settings\Zoom)
;    Next_Pixel_Start = (x+1) * *Screen_Settings\Zoom
;    If Round(Next_Pixel_Start, #PB_Round_Nearest) - Round(Pixel_End, #PB_Round_Nearest) > Round(*Screen_Settings\Zoom, #PB_Round_Down)
;      Width = Width + 1
;      Colour = #Red
;    EndIf
;  EndIf
;  If  y > 0
;    Pixel_End = (y * *Screen_Settings\Zoom)
;    Next_Pixel_Start = (y+1) * *Screen_Settings\Zoom
;    If Round(Next_Pixel_Start, #PB_Round_Nearest) - Round(Pixel_End, #PB_Round_Nearest) > Round(*Screen_Settings\Zoom, #PB_Round_Down)
;      Height = Height + 1
;      Colour = #Green
;    EndIf    
;  EndIf
;  ZoomSprite(*Screen_Settings\Pixel_Sprite, Width, Height)
;  DisplayTransparentSprite(*Screen_Settings\Pixel_Sprite, x * *Screen_Settings\Zoom, y * *Screen_Settings\Zoom, 255, Colour)
;EndProcedure

Procedure DrawLine(*Screen_Settings.Screen_Settings_Structure, x1.i, y1.i, x2.i, y2.i, Colour.i)
  Protected Steep.i, DeltaX.i, DeltaY.i, YStep.i, XStep.i, Error.i
  Protected x.i, y.i, cc.i, cs.i, c.i
  Protected Max_Offset.i
  Protected d.i = 0
  If Abs(y2 - y1) > Abs(x2 - x1);
    steep =#True 
    Swap x1, y1
    Swap x2, y2
  EndIf    
  If x1 > x2 
    Swap x1, x2
    Swap y1, y2
  EndIf 
  DeltaX = x2 - x1
  DeltaY = Abs(y2 - y1)
  Error = DeltaX / 2
  y = y1
  If y1 < y2  
    YStep = 1
  Else
    YStep = -1 
  EndIf
  ;If Dash_Length < 1 : Dash_Length = 1 : EndIf
  ;Max_Offset = Dash_Length * 2 - 1
  ;If Offset > Max_Offset : Offset = Max_Offset: EndIf
  ;If Offset < 0 : Offset = 0 : EndIf
  ;cc = Offset ; colour counter
  ;If cc > Dash_Length - 1 : cs = 1 : Else : cs = 0 : EndIf
  For x = x1 To x2
    ;If cs = 0 : c = col1 : Else : c = col2 : EndIf
    ;d = 1 - d
    ;If d = 0
    ;  c = #Black
    ;Else
    ;  c = #White
    ;EndIf      
    If Steep 
      ;Plot(y, x, c)
      DrawPixel(y, x, Colour, *Screen_Settings)
    Else 
      ;Plot(x, y, c)
      DrawPixel(x, y, Colour, *Screen_Settings)
    EndIf
    Error = Error - DeltaY
    If Error < 0 
      y = y + YStep
      Error = Error + DeltaX
    EndIf
    ;cc = cc + 1
    ;If cc = Dash_Length
    ;  cs = 1 - cs
    ;EndIf
    ;If cc = Dash_Length * 2
    ;  cc = 0
    ;  cs = 1 - cs
    ;EndIf
  Next
  ProcedureReturn cc ; return the offset so drawing can continue  
EndProcedure

Procedure DrawDashedLine(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure, x1.i, y1.i, x2.i, y2.i, col1.i, col2.i, Dash_Length.i, Offset.i = 0)
  ; Dash_Length must be 1 or greater
  ; Offset can be 0 to (2 * Dash_Length) - 1
  Protected Steep.i, DeltaX.i, DeltaY.i, YStep.i, XStep.i, Error.i
  Protected x.i, y.i, cc.i, cs.i, c.i
  Protected Max_Offset.i
  If Abs(y2 - y1) > Abs(x2 - x1);
    steep =#True 
    Swap x1, y1
    Swap x2, y2
  EndIf    
  If x1 > x2 
    Swap x1, x2
    Swap y1, y2
  EndIf 
  DeltaX = x2 - x1
  DeltaY = Abs(y2 - y1)
  Error = DeltaX / 2
  y = y1
  If y1 < y2  
    YStep = 1
  Else
    YStep = -1 
  EndIf
  If Dash_Length < 1 : Dash_Length = 1 : EndIf
  Max_Offset = Dash_Length * 2 - 1
  If Offset > Max_Offset : Offset = Max_Offset: EndIf
  If Offset < 0 : Offset = 0 : EndIf
  cc = Offset ; colour counter
  If cc > Dash_Length - 1 : cs = 1 : Else : cs = 0 : EndIf
  For x = x1 To x2
    If cs = 0 : c = col1 : Else : c = col2 : EndIf
    If Steep 
      ;Plot(y, x, c)
      DrawPixel(*Screen_Settings, y, x, c)
    Else 
      ;Plot(x, y, c)
      DrawPixel(*Screen_Settings, x, y, c)
    EndIf
    Error = Error - DeltaY
    If Error < 0 
      y = y + YStep
      Error = Error + DeltaX
    EndIf
    cc = cc + 1
    If cc = Dash_Length
      cs = 1 - cs
    EndIf
    If cc = Dash_Length * 2
      cc = 0
      cs = 1 - cs
    EndIf
  Next
  ProcedureReturn cc ; return the offset so drawing can continue
EndProcedure

Procedure DrawSprites(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure, *Menu_Settings.Menu_Settings_Structure, *Graphics.Graphics_Structure)
  Protected c.i
  ;For c = 1 To 1000
  ;  DrawPixel(*Screen_Settings, (Random(*Screen_Settings\Screen_Res_Width)), (Random(*Screen_Settings\Screen_Res_Height)), #White)
  ;Next
 
  ;DrawPixel(255, 0, #White, *Screen_Settings)
  ;DrawPixel(255, 223, #White, *Screen_Settings)
  ;DrawLine(*Screen_Settings, 0, 20, 60, 20, RGBA(255, 255, 255, 255))
  ;DrawLine(*Screen_Settings, 0, 20, 0, 80, RGBA(255, 255, 255, 255))
  ;DrawLine(*Screen_Settings, 0, 20, 60, 80, RGBA(255, 255, 255, 255))
  
  ;DisplaySystemFontString(*System, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0, 16, 255, #Red)
  ;DisplaySystemFontString(*System, "abcdefghijklmnopqrstuvwxyz", 0, 24, 255, #Yellow)
  ;DisplaySystemFontString(*System, "0123456789", 0, 32, 255, #Green)
  ;DisplaySystemFontString(*System, " !" + Chr(34) + "#$%&'()*+,-./:;<=>?@|[]£\^`~{}€¥©™", 0, 40, 255, #White)
  ;DisplaySystemFontString(*System, "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ", 0, 48, 255, #Gray)
  
  ;DisplayTransparentSprite(*System\Font_Char_Sprite[78], 100, 100, 255, #White)
  ;DisplaySpriteResource(*P, *System\Mouse_Sprite_Index, 80, 50)
  
  ;DrawDashedLine(*System, *Screen_Settings, 100, 80, 200, 120, #Black, #White, 2)
  
  ;DisplayTransparentSprite(*Graphics\Sprite_Resource[1]\ID, 10, 10)
  
  For c = 0 To *System\Sprite_Instance_Count - 1
    DisplaySpriteInstance(*Graphics, c)
  Next c
  For c = 0 To *System\System_Font_Instance_Count - 1
    DisplaySystemFontInstance(*System, *Graphics, c)
  Next c
  
  
  If Not *Screen_Settings\Full_Screen_Inactive ; don't draw anything if full screen has been alt+tabbed
    
    ; *************************************
    ; menu
    ; *************************************   
    ;StartDrawing(ScreenOutput())
    If *Menu_Settings\Menu_Active
      ; Only draw background and menus when active
      ; Draw menu background
      Select *Menu_Settings\Menu_Background
        Case #Menu_Background_None
          ; nothing to do
        Case #Menu_Background_Vector
        Case #Data_Menu_Background_Image
      EndSelect
    EndIf
    ;StopDrawing()
    
  EndIf
EndProcedure

Procedure GrabScreen(*Screen_Settings.Screen_Settings_Structure)
  If *Screen_Settings\Screen_Sprite
    FreeSprite(*Screen_Settings\Screen_Sprite)
  EndIf
  *Screen_Settings\Screen_Sprite = GrabSprite(#PB_Any, 0, 0, *Screen_Settings\Screen_Res_Width, *Screen_Settings\Screen_Res_Height, #PB_Sprite_AlphaBlending)
  TransparentSpriteColor(*Screen_Settings\Screen_Sprite, #Magenta)
EndProcedure

Procedure Draw2DGraphics(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure)
  ;StartDrawing(SpriteOutput(*Screen_Settings\Screen_Sprite))
  ;DrawingMode(#PB_2DDrawing_Outlined)
  ;Box(0, 0, *Screen_Settings\Screen_Res_Width, *Screen_Settings\Screen_Res_Height, RGBA(255, 0, 0, 255))
  ;StopDrawing()
EndProcedure

Procedure DrawBorder(*Screen_Settings.Screen_Settings_Structure)
  If *Screen_Settings\Border
    ClearScreen(*Screen_Settings\Border_Colour)
  EndIf
EndProcedure

Procedure ShowZoomed2DScreen(*Screen_Settings.Screen_Settings_Structure)
  Protected Use_Sprite.i
  ;ZoomSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Actual_Width, *Screen_Settings\Screen_Actual_Height)
  ;Debug "Screen_Res_Width: " + *Screen_Settings\Screen_Res_Width
  ;Debug "Screen_Actual_Width: " + Round(*Screen_Settings\Screen_Actual_Width * 1.5, #PB_Round_Up)
  If Not *Screen_Settings\Border And *Screen_Settings\Screen_Res_Width = *Screen_Settings\Screen_Actual_Width
    Use_Sprite = 0
  Else
    Use_Sprite = 1
  EndIf
  If Use_Sprite
    If *Screen_Settings\Full_Screen And *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic
      If *Screen_Settings\Border
        ZoomSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Inner_Width, *Screen_Settings\Screen_Inner_Height)
        DisplayTransparentSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Inner_X, *Screen_Settings\Screen_Inner_Y)
      Else
        ClearScreen(*Screen_Settings\Classic_Screen_Background_Colour) ; clear the screen to get rid of the native res screen
        ZoomSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Actual_Width, *Screen_Settings\Screen_Actual_Height)
        DisplayTransparentSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Left, *Screen_Settings\Screen_Top)
      EndIf      
    Else
      If *Screen_Settings\Border
        ZoomSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Inner_Width, *Screen_Settings\Screen_Inner_Height)
        DisplayTransparentSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Inner_X, *Screen_Settings\Screen_Inner_Y)
      Else
        ZoomSprite(*Screen_Settings\Screen_Sprite, *Screen_Settings\Screen_Actual_Width, *Screen_Settings\Screen_Actual_Height)
        DisplayTransparentSprite(*Screen_Settings\Screen_Sprite, 0, 0)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure AddScreenFilter(*Screen_Settings.Screen_Settings_Structure)
  If *Screen_Settings\Screen_Filter
    If *Screen_Settings\Full_Screen And *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic
      ;If *Screen_Settings\Border
      ;  DisplayTransparentSprite(*Screen_Settings\Screen_Filter_Sprite, *Screen_Settings\Screen_Inner_X, *Screen_Settings\Screen_Inner_Y)
      ;Else
      ;  DisplayTransparentSprite(*Screen_Settings\Screen_Filter_Sprite, *Screen_Settings\Screen_Left, *Screen_Settings\Screen_Top)
      ;EndIf      
    Else
      If *Screen_Settings\Border
        ;DisplayTransparentSprite(*Screen_Settings\Screen_Filter_Sprite, *Screen_Settings\Screen_Inner_X, *Screen_Settings\Screen_Inner_Y)
      Else
        SpriteQuality(#PB_Sprite_BilinearFiltering)
        ZoomSprite(*Screen_Settings\Screen_Filter_Sprite, *Screen_Settings\Screen_Actual_Width, *Screen_Settings\Screen_Actual_Height)
        DisplayTransparentSprite(*Screen_Settings\Screen_Filter_Sprite, 0, 0)
        SpriteQuality(#PB_Sprite_NoFiltering)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure ShowFullResGraphics(*System.System_Structure)
  ; Useful for showing system messages or a console etc
  
EndProcedure

Procedure DrawMouse(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure, *Graphics.Graphics_Structure)
  If *System\Show_Mouse And Not *Screen_Settings\Full_Screen_Inactive
    If Not *System\Mouse_Control
      ; dont show mouse when it's in control (ie first person mouse control)
     If *Screen_Settings\Full_Screen
        ; show the mouse sprite
        ; no need to show the mouse sprite in window mode when it's not in control of the player
        DisplaySpriteResource(*System, *Graphics, #Mouse_Sprite, *System\Mouse_X - *System\Mouse_Offset_X, *System\Mouse_Y - *System\Mouse_Offset_Y)
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure DoPostProcessing(*System.System_Structure)
  If *System\Take_Screen_Capture
    SaveScreen(*System)
    *System\Take_Screen_Capture = 0
  EndIf
EndProcedure

Procedure CheckFullScreen(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure)
  ; Manages the full screen in case the user switches back
  ; to the operating system (ie using alt+tab)
  Protected e.i
  If *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic
    If *Screen_Settings\Full_Screen_Inactive
      ; process window events for the minimised window
      e = WaitWindowEvent(10)
      If e = #PB_Event_ActivateWindow
        ; User has switched back to full screen
        Debug "CheckFullScreen: returned to full screen"
        CloseWindow(#Game_Window_Full_Screen_Minimised)
        ; this closes the dummy minimised window that gets
        ; created to hide the full screen
        If Not SetScreen(*System, *Window_Settings, *Screen_Settings)
          *System\Fatal_Error_Message = "SetScreen failed"
          Fatal_Error(*System)
        EndIf
        MouseLocate(*System\Mouse_Save_X, *System\Mouse_Save_Y) ; move the mouse back to the saved location
        ;LoadSpriteResources(*P)
        *Screen_Settings\Full_Screen_Inactive = 0
      EndIf      
    Else
      ; Check if the screen has gone inactive
      *Screen_Settings\Screen_Active = IsScreenActive()
      If Not *Screen_Settings\Screen_Active And *Screen_Settings\Full_Screen And *Screen_Settings\Full_Screen_Type = #Full_Screen_Classic
        ; only process IsScreenActive if in full screen
        *System\Mouse_Save_X = *System\Mouse_X ; Save the mouse position
        *System\Mouse_Save_Y = *System\Mouse_Y
        ReleaseMouse(1) ; release the mouse to the OS
        CloseScreen()
        *Screen_Settings\Screen_Open = 0
        *Screen_Settings\Full_Screen_Inactive = 1
        OpenWindow(#Game_Window_Full_Screen_Minimised, 1, 1, 1, 1, *System\Game_Title, #PB_Window_Minimize)
        Debug "CheckFullScreen: screen inactive, waiting for user to switch back"
      EndIf
    EndIf
  EndIf
EndProcedure

;- Input

Procedure KeyPressed(*System.System_Structure, k.i)
  ; Returns whether a key was pressed, one shot
  Protected Pressed.i = 0
      If KeyboardReleased(k)
        *System\Keyb[k] = 0
        Pressed = 0
      EndIf
      If KeyboardPushed(k)
        If Not *System\Keyb[k]
          ; Key push has not been registered yet
          *System\Keyb[k] = 1
          Pressed = 1
        EndIf
      EndIf
  ProcedureReturn Pressed
EndProcedure

Procedure ProcessKeyboard(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure,
                          *Menu_Settings.Menu_Settings_Structure, *Graphics.Graphics_Structure)
  Protected c.i
  If Not *Screen_Settings\Full_Screen_Inactive
    ; Disable keyboard when classic full screen inactive
    ExamineKeyboard()
    ; Always process CTRL, SHIFT and ALT pushed commands first
    ; Process alt commands
    If KeyboardPushed(#PB_Key_LeftAlt) Or KeyboardPushed(#PB_Key_RightAlt)
      If KeyPressed(*System, #PB_Key_Return)
        Debug "ProcessKeyboard: switch full screen"
        SwitchFullScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
      EndIf
    EndIf
    ; Process control commands
    If KeyboardPushed(#PB_Key_LeftControl) Or KeyboardPushed(#PB_Key_RightControl)
      ; Process control+shift commands
      If KeyboardPushed(#PB_Key_LeftShift) Or KeyboardPushed(#PB_Key_RightShift)
        If KeyPressed(*System, #PB_Key_R)
          If *System\Allow_Restart
            Debug "ProcessKeyboard: restarting"
            Restart = 1 ; global variable
          Else
            Debug "ProcessKeyboard: not allowed to restart"
          EndIf
        EndIf
        If KeyPressed(*System, #PB_Key_Q)
          Debug "ProcessKeyboard: quit"
          *System\Quit = 1
        EndIf
      EndIf
    EndIf    
    
    ; *************************************
    ; menu
    ; *************************************
    
    ;If *Menu_Settings\Menu_Active
    ;  ; only process menu controls when the menu is active
    ;  *Menu_Settings\Menu_Action = #Menu_Action_None
    ;  For c = 0 To #Max_Menu_Controls - 1
    ;    If *Menu_Settings\Menu_Control[c]\Menu_Control_Hardware_Type = #Control_Hardware_Keyboard
    ;      ; only check keyboard controls since this is the keyboard handler
    ;      If KeyPressed(*System, *Menu_Settings\Menu_Control[c]\Menu_Control_ID)
    ;        Debug "ProcessKeyboard: menu control " + *Menu_Settings\Menu_Control[c]\Menu_Control_ID + " pressed"
    ;        *Menu_Settings\Menu_Action = *Menu_Settings\Menu_Control[c]\Menu_Control_Action
    ;      EndIf
    ;    EndIf
    ;    If *Menu_Settings\Menu_Action <> #Menu_Action_None : Break : EndIf 
    ;  Next
    ;EndIf    
    
    ; *************************************
    ; system
    ; *************************************
    ; Process full screen only key commands
    ; *************************************
    If *Screen_Settings\Full_Screen
      If KeyboardPushed(#PB_Key_LeftAlt) Or KeyboardPushed(#PB_Key_RightAlt)
        If KeyPressed(*System, #PB_Key_F4)
          If *System\Allow_AltF4_Full_Screen
            Debug "ProcessKeyboard: quit by Alt+F4 in fullscreen"
            *System\Quit = 1
          Else
            Debug "ProcessKeyboard: not allowed to quit by Alt+F4 in fullscreen"
          EndIf
        EndIf
      EndIf
    Else
      ; Remove F10 and Alt
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        ;If KeyboardPushed(#PB_Key_F10) Or KeyboardPushed(#PB_Key_LeftAlt) Or KeyboardPushed(#PB_Key_RightAlt)
        ;  keybd_event_(#PB_Key_F9, 0, #KEYEVENTF_KEYUP, 0)
        ;  Debug "ProcessKeyboard: F10/Alt key pushed while in Window mode"
      CompilerEndIf
      If KeyboardPushed(#PB_Key_LeftAlt) Or KeyboardPushed(#PB_Key_RightAlt)
        If KeyPressed(*System, #PB_Key_1)
          *Screen_Settings\Set_Zoom = 1
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_2)
          *Screen_Settings\Set_Zoom = 2
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_3)
          *Screen_Settings\Set_Zoom = 3
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_4)
          *Screen_Settings\Set_Zoom = 4
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_5)
          *Screen_Settings\Set_Zoom = 5
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_6)
          *Screen_Settings\Set_Zoom = 6
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_7)
          *Screen_Settings\Set_Zoom = 7
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_8)
          *Screen_Settings\Set_Zoom = 8
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf
        If KeyPressed(*System, #PB_Key_9)
          *Screen_Settings\Set_Zoom = 9
          ResetScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
        EndIf          
      EndIf
    EndIf
    ; ************************************************
    ; Process both full screen and window key commands
    ; ************************************************ 
    
    If KeyPressed(*System, #PB_Key_F3)
      ; toggle border
     *Screen_Settings\Screen_Filter = 1 - *Screen_Settings\Screen_Filter
    EndIf    
    
    If KeyPressed(*System, #PB_Key_F9)
      ; toggle border
      If *Screen_Settings\Border_Enable
        *Screen_Settings\Border = 1 - *Screen_Settings\Border
      EndIf    
    EndIf
    
    If KeyPressed(*System, #PB_Key_F11)
      If *System\Allow_Switch_to_Window
        ; switch between window or full screen
        SwitchFullScreen(*System, *Window_Settings, *Screen_Settings, *Graphics)
      Else
        Debug "ProcessKeyboard: not allowed to switch between full screen and window"
      EndIf
    EndIf
    
    If ElapsedMilliseconds() - *System\Time_Full_Screen_Switched > 1000
      ; The F11 key needs to be released on a timer since resetting the screen resets the keyboard buffer
      *System\Keyb[#PB_Key_F11] = 0
    EndIf
    
    If KeyPressed(*System, #PB_Key_F12)
      If *System\Allow_Screen_Capture
        *System\Take_Screen_Capture = 1
      Else
        Debug "ProcessKeyboard: not allowed to screen capture"
      EndIf
    EndIf 
    
    If KeyPressed(*System, #PB_Key_Escape)
      Debug "ProcessKeyboard: quit"
      *System\Quit = 1
    EndIf
  EndIf
EndProcedure

Procedure ProcessControls()
EndProcedure

Procedure ProcessMouse(*System.System_Structure, *Screen_Settings.Screen_Settings_Structure)
  Protected c.i
  If Not *Screen_Settings\Full_Screen_Inactive
    ; only process is there has been a change
    If *Screen_Settings\Full_Screen Or *System\Mouse_Control
      ; Mouse is contained within the screen
      ExamineMouse()
      *System\Mouse_X = MouseX() * *System\Mouse_Sensitivity_X
      *System\Mouse_Y = MouseY() * *System\Mouse_Sensitivity_Y
      *System\Mouse_Button_Left = MouseButton(#PB_MouseButton_Left)
      *System\Mouse_Button_Middle = MouseButton(#PB_MouseButton_Middle)
      *System\Mouse_Button_Right = MouseButton(#PB_MouseButton_Right)
      *System\Mouse_Wheel_Movement = MouseWheel()
    Else
      *System\Mouse_X = WindowMouseX(#Game_Window_Main)
      *System\Mouse_Y = WindowMouseY(#Game_Window_Main)
      ; Window mouse clicks are handled by ProcessWindowEvents
    EndIf 
    
  EndIf
EndProcedure

;- Events

Procedure ProcessWindowEvents(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure, *Graphics.Graphics_Structure)
  Protected Event.i, Event_Window.i
  Protected c.i
  Protected Result.i
  If Not *Screen_Settings\Full_Screen Or *Screen_Settings\Full_Screen_Type = #Full_Screen_Windowed
    ; only process window events in a window mode               
    *System\Mouse_Left_Click = 0 ; Reset the mouse clicks
    *System\Mouse_Right_Click = 0
    Repeat              ; process all events
      Event = WindowEvent()
      Event_Window = EventWindow()
      Select Event
        Case #PB_Event_Menu
          Debug "ProcessWindowEvents: menu event"
        Case #PB_Event_DeactivateWindow
          Debug "ProcessWindowEvents: window deactivated"
        Case #PB_Event_ActivateWindow
          Debug "ProcessWindowEvents: window activated"          
        Case #PB_Event_CloseWindow
          Select Event_Window
            Case #Game_Window_Main
              *System\Quit = 1
            Case #Game_Window_Debug
              *System\Debug_Window = 0
              CloseWindow(#Game_Window_Debug)
          EndSelect
        Case #PB_Event_SizeWindow
          Debug "ProcessWindowEvents: resizing window"          
          Select Event_Window
            Case #Game_Window_Main
              If GetWindowState(#Game_Window_Main) = #PB_Window_Normal
                ; Only update window variables if it's a normal window
                ; This is needed for maximise etc to work
                If *Window_Settings\Window_W <> WindowWidth(#Game_Window_Main) * DesktopResolutionX() Or *Window_Settings\Window_H <> WindowHeight(#Game_Window_Main) * DesktopResolutionY()
                  *Window_Settings\Window_W = WindowWidth(#Game_Window_Main)
                  *Window_Settings\Window_H = WindowHeight(#Game_Window_Main)
                  *Window_Settings\Window_Moved = 1
                  ; Don't close the window And reopen (SetScreen), just reset the window screen
                  SetWindowScreen(*System, *Screen_Settings)
                  LoadSpriteResources(*System, *Screen_Settings, *Graphics) ; have to reload sprites after setting a new Window Screen
                  ;InitialiseFonts(*System)
                  LoadSystemFont(*System)
                EndIf 
              EndIf
            Case #Game_Window_Debug
              Debug "Resizing debug window"
              *Window_Settings\Window_Debug_W = WindowWidth(#Game_Window_Debug)
              *Window_Settings\Window_Debug_H = WindowHeight(#Game_Window_Debug)
              ResizeGadget(*Window_Settings\Window_Debug_Edit_Gadget, 10, 10, *Window_Settings\Window_Debug_W-20, *Window_Settings\Window_Debug_H-20)
          EndSelect
        Case #PB_Event_MoveWindow
          Select Event_Window
            Case #Game_Window_Main
              If GetWindowState(#Game_Window_Main) = #PB_Window_Normal ; only change the coordinates if it's a normal window
                Debug "ProcessWindowEvents: main window moved"
                *Window_Settings\Window_Moved = 1
                *Window_Settings\Window_X = WindowX(#Game_Window_Main)
                *Window_Settings\Window_Y = WindowY(#Game_Window_Main)
              EndIf
            Case #Game_Window_Debug
              Debug "ProcessWindowEvents: debug window moved"
              *Window_Settings\Window_Debug_X = WindowX(#Game_Window_Debug)
              *Window_Settings\Window_Debug_Y = WindowY(#Game_Window_Debug)              
          EndSelect
        Case #PB_Event_MaximizeWindow
          Debug "ProcessWindowEvents: window maximised"
          *Window_Settings\Window_Maximised = 1
          *Window_Settings\Window_Minimised = 0
          SetWindowScreen(*System, *Screen_Settings)
          LoadSpriteResources(*System, *Screen_Settings, *Graphics)    ; have to reload sprites after setting a new Window Screen
          ;InitialiseFonts(*System)
          LoadSystemFont(*System)
        Case #PB_Event_RestoreWindow
          Debug "ProcessWindowEvents: window restored"
          *Window_Settings\Window_Maximised = 0
          *Window_Settings\Window_Minimised = 0
          Debug "ProcessWindowEvents: resizing to: " + *Window_Settings\Window_W + " x " + *Window_Settings\Window_H
          ResizeWindow(#Game_Window_Main, *Window_Settings\Window_X, *Window_Settings\Window_Y, *Window_Settings\Window_W / DesktopResolutionX(), *Window_Settings\Window_H / DesktopResolutionY())  
          SetWindowScreen(*System, *Screen_Settings)
          LoadSpriteResources(*System, *Screen_Settings, *Graphics) ; have to reload sprites after setting a new Window Screen
          ;InitialiseFonts(*System)
          LoadSystemFont(*System)
        Case #PB_Event_MinimizeWindow
          *Window_Settings\Window_Maximised = 0
          *Window_Settings\Window_Minimised = 1
        Case #PB_Event_LeftClick
          Debug "ProcessWindowEvents: primary mouse button clicked"
          *System\Mouse_Left_Click = 1
        Case #PB_Event_RightClick
          Debug "ProcessWindowEvents: secondary mouse button clicked"
          *System\Mouse_Right_Click = 1
      EndSelect
    Until Event = 0
  EndIf  
EndProcedure

;- System

Procedure ProcessFPS(*FPS_Data.FPS_Data_Structure)
  *FPS_Data\Last_Frame_Time = ElapsedMilliseconds() - *FPS_Data\Begin_Time
  *FPS_Data\Begin_Time = ElapsedMilliseconds()
  If *FPS_Data\Frame > 20
    *FPS_Data\Average_Sum = *FPS_Data\Average_Sum - *FPS_Data\Samples[*FPS_Data\Average_Index] ; subtract the previous sample (it's zero on the first pass)
    *FPS_Data\Average_Sum = *FPS_Data\Average_Sum + *FPS_Data\Last_Frame_Time
    *FPS_Data\Samples[*FPS_Data\Average_Index] = *FPS_Data\Last_Frame_Time
    *FPS_Data\Average_Index = *FPS_Data\Average_Index + 1
    If *FPS_Data\Average_Index >= *FPS_Data\Frequency 
      *FPS_Data\Average_Index = 0
      *FPS_Data\Initialised = 1
    EndIf  
    If *FPS_Data\Initialised
      ;Debug "Frequency: " + *FPS_Data\Frequency
      *FPS_Data\FPS = 1000 / (*FPS_Data\Average_Sum / *FPS_Data\Frequency)
    Else
      *FPS_Data\FPS = 1000 / (*FPS_Data\Average_Sum / *FPS_Data\Average_Index)
    EndIf
    If *FPS_Data\FPS > *FPS_Data\Frequency
      *FPS_Data\FPS = *FPS_Data\Frequency
    EndIf
  EndIf
EndProcedure  

Procedure ProcessSystem(*FPS_Data.FPS_Data_Structure)
  ;*P\Game_Loop_Start_Time = ElapsedMilliseconds()
  *FPS_Data\Frame_Start_Time = ElapsedMilliseconds() 
  *FPS_Data\Game_Run_Time = ElapsedMilliseconds() - *FPS_Data\Game_Start_Time
  *FPS_Data\Frame = *FPS_Data\Frame + 1  
  ProcessFPS(*FPS_Data)
EndProcedure

Procedure SaveConfig(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure, Level.i=1)
  ; Never call SaveConfig before LoadConfig
  ; Save levels: 1 - window settings, 2 - game settings
  Protected f.s
  f = GetCurrentDirectory() + *System\Game_Config_File
  If *System\Config_Loaded ; only save if the config has been loaded
    If Level = 1 Or Level = 2
      ; Create or open the config file
      If Not *System\Config_File
        ; Need to create a new file
        Debug "SaveConfig: creating new config file"
        If Not CreatePreferences(f)
          Debug "SaveConfig: ERROR - unable to create config file"
          ProcedureReturn 0
        EndIf
        *Window_Settings\Reset_Window = 1 ; reset the window so that it's centred
        *System\Config_File = 1  ; config file exists now
      Else
        ; Open the existing config file
        If Not OpenPreferences(f)
          Debug "SaveConfig: ERROR - unable to open existing config file"
          ProcedureReturn 0
        EndIf
      EndIf
      ; Window settings are automatically saved when closing the game
      ; or changing the window (while in window mode)
      Debug "SaveConfig: writing window preferences"
      PreferenceGroup("Window")
      WritePreferenceInteger("Full_Screen", *Screen_Settings\Full_Screen)
      WritePreferenceInteger("Window_X", *Window_Settings\Window_X)
      WritePreferenceInteger("Window_Y", *Window_Settings\Window_Y)
      If *Window_Settings\Window_Maximised Or *Screen_Settings\Full_Screen
        WritePreferenceInteger("Window_W", *Window_Settings\Window_W)
        WritePreferenceInteger("Window_H", *Window_Settings\Window_H)
      Else        
        WritePreferenceInteger("Window_W", *Screen_Settings\Screen_Actual_Width)
        WritePreferenceInteger("Window_H", *Screen_Settings\Screen_Actual_Height)
      EndIf
      WritePreferenceInteger("Window_Debug_X", *Window_Settings\Window_Debug_X)
      WritePreferenceInteger("Window_Debug_Y", *Window_Settings\Window_Debug_Y)
      WritePreferenceInteger("Window_Debug_W", *Window_Settings\Window_Debug_W)
      WritePreferenceInteger("Window_Debug_H", *Window_Settings\Window_Debug_H)      
      WritePreferenceInteger("Window_Maximised", *Window_Settings\Window_Maximised)
      If Level = 2
        ; write the level 2 settings
        ; this is usually only run in-game
        Debug "SaveConfig: writing graphics preferences"
        PreferenceGroup("Graphics")
        ; WritePreferenceInteger("Flip_Mode", *Screen_Settings\Flip_Mode)
      EndIf
      ClosePreferences()
      ProcedureReturn 1
    Else ; invalid config level specified
      Debug "SaveConfig: ERROR - invalid config level specified: " + Level
      ProcedureReturn 0
    EndIf
  Else
    Debug "SaveConfig: ERROR - cannot save config if it hasn't been loaded yet"
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure LoadConfig(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure)
  ; Loads configuration if available and sets defaults when no config is available
  ; If there is no config file then SaveConfig will be called
  Protected f.s
  ; Layer 1
  f = *System\Game_Config_File
  If FileSize(f)>0
    *System\Config_File = 1 ; config file found
  EndIf
  Debug "LoadConfig: opening " + *System\Game_Config_File
  OpenPreferences(f)
  Debug "LoadConfig: loading window preferences"
  PreferenceGroup("Window")
  *Screen_Settings\Full_Screen = ReadPreferenceInteger("Full_Screen", 0)
  *Window_Settings\Window_X = ReadPreferenceInteger("Window_X", 0)
  *Window_Settings\Window_Y = ReadPreferenceInteger("Window_Y", 0)
  *Window_Settings\Window_W = ReadPreferenceInteger("Window_W", *Window_Settings\Window_W)
  *Window_Settings\Window_H = ReadPreferenceInteger("Window_H", *Window_Settings\Window_H)
  *Window_Settings\Window_Debug_X = ReadPreferenceInteger("Window_Debug_X", 0)
  *Window_Settings\Window_Debug_Y = ReadPreferenceInteger("Window_Debug_Y", 0)
  *Window_Settings\Window_Debug_W = ReadPreferenceInteger("Window_Debug_W", *Window_Settings\Window_Debug_W)
  *Window_Settings\Window_Debug_H = ReadPreferenceInteger("Window_Debug_H", *Window_Settings\Window_Debug_H)  
  *Window_Settings\Window_Maximised = ReadPreferenceInteger("Window_Maximised", 0)
  PreferenceGroup("Grapics")
  ; *Screen_Settings\Flip_Mode = ReadPreferenceInteger("Flip_Mode", #Default_Flip_Mode)
  *System\Config_Loaded = 1 ; set this so that SaveConfig can run. It's important to load config before saving
  ClosePreferences()
  ProcedureReturn 1
EndProcedure

Procedure SetInitialiseError(*System.System_Structure, Message.s)
  ; Sets a special error message on the first initialisation error encountered, to help troubleshooting
  If Not *System\Initialisation_Error
    ; Only set the error message if there has been no error yet, this helps with troubleshooting so you can see the first error
    *System\Initialisation_Error = 1
    *System\Initialise_Error_Message = Message
  EndIf
EndProcedure

Procedure Initialise(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure, *FPS_Data.FPS_Data_Structure,
                     *Menu_Settings.Menu_Settings_Structure, *Graphics.Graphics_Structure)
  ; Initialises the environment
  Protected Result.i, c.i
  
  Debug "Initialise: starting"
  Debug "OS: " + GetOSVersionString()
  Debug "CPU: " + CPUName()
  Debug "CPU cores: " + CountCPUs(#PB_System_CPUs)
  Debug "RAM: " + FormatNumber(GetPhysicalMem() / (1024 * 1024), 0) + "GB"  
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    If Not InitGDK()
      Debug "Initialise: could not initialise GDK"
      SetInitialiseError(*System, "Could not initialise GDK")
      ProcedureReturn 0
  EndIf
      
  CompilerEndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; Check if game is already running
    *System\MutexID = CreateMutex_(0, 1, *System\Game_Title)
    *System\MutexError = GetLastError_()
    If *System\MutexID = 0 Or *System\MutexError <> 0
      ReleaseMutex_(*System\MutexID)
      CloseHandle_(*System\MutexID)
      Debug "Initialise: " + *System\Game_Title + " is already running, cannot run more than one instance"
      SetInitialiseError(*System, *System\Game_Title + " is already running, cannot run more than one instance")
      ProcedureReturn 0
    EndIf
  CompilerEndIf
  
  InitKeyboard()
  InitMouse()
  UsePNGImageEncoder() ; enable PNG encoding for saving screen captures
  UsePNGImageDecoder()
  
  If Not InitDesktop(*Screen_Settings, *FPS_Data)
    Debug "Initialise: could not initialise desktop"
    SetInitialiseError(*System, "Could not initialise desktop (the operating system graphical display)")
    ProcedureReturn 0
  EndIf
  
  If *Screen_Settings\Desktop[0]\Depth < *System\Minimum_Colour_Depth
    Debug "Initialise: Unable to set minimum colour depth: " + *System\Minimum_Colour_Depth + " bit"
    SetInitialiseError(*System, "Unable to set minimum colour depth: " + *System\Minimum_Colour_Depth + " bit")
    ProcedureReturn 0    
  EndIf
  
  If Not InitSprite()
    Debug "Initialise: could not initialise sprite environment"
    SetInitialiseError(*System, "Could not initialise sprite environment (usually this is a DirectX problem)")
    ProcedureReturn 0    
  Else
    SpriteQuality(#PB_Sprite_NoFiltering)
  EndIf
  
  If Not LoadConfig(*System, *Window_Settings, *Screen_Settings)
    Debug "Initialise: could not load config"
    SetInitialiseError(*System, "Could not load config")
    ProcedureReturn 0
  EndIf    
  
  SaveConfig(*System, *Window_Settings, *Screen_Settings, 2) ; always save config on start in case of corrupt file
  
  If Not SetScreen(*System, *Window_Settings, *Screen_Settings)
    Debug "Initialise: could not set screen"
    SetInitialiseError(*System, "Could not set screen")
    ProcedureReturn 0
  EndIf
  
  ClearScreen(*Screen_Settings\Background_Colour)
  
  FlipBuffers()
  
  If *System\Render_Engine3D <> #Render_Engine3D_None
    ; Don't initialise 3D if it is not enabled
    Debug "Initialise: 3D engine"
    Select *System\Render_Engine3D ; Initialise render engine
      Case #Render_Engine3D_Builtin
        ; not written yet
    EndSelect
  EndIf
  
  Debug "Initialise: loading menu controls"
  
  Select *Menu_Settings\Menu_System_Type
    Case #Menu_System_Menuless
      Restore Data_Menu_Controls_Menuless
    Case #Menu_System_Simple
      Restore Data_Menu_Controls_Simple
    Case #Menu_System_Pointer
      Restore Data_Menu_Controls_Pointer
  EndSelect
  Read.i *Menu_Settings\Menu_Controls_Count
  If *Menu_Settings\Menu_Controls_Count > #Max_Menu_Controls
    *System\Fatal_Error_Message = "#Max_Menu_Controls too small to load all menu controls"
    Fatal_Error(*System)       
  EndIf
  For c = 0 To *Menu_Settings\Menu_Controls_Count - 1
    Read.i *Menu_Settings\Menu_Control[c]\Menu_Control_Type
    Read.i *Menu_Settings\Menu_Control[c]\Menu_Control_Action
    Read.i *Menu_Settings\Menu_Control[c]\Menu_Control_Hardware_Type
    Read.i *Menu_Settings\Menu_Control[c]\Menu_Control_ID
  Next
  
  LoadVectorResources(*System, *Graphics)
  LoadSpriteResources(*System, *Screen_Settings, *Graphics)
  LoadSpriteInstances(*System, *Graphics)
  LoadSystemFontInstances(*System, *Graphics)
  LoadSystemFont(*System)
  
  ;If Not InitialiseFonts(*System)
  ;  Debug "Initialise: could not initialise fonts"
  ;  SetInitialiseError(*P, "Could not initialise fonts")
  ;  ProcedureReturn 0
  ;EndIf  
  
  ; Elevate control to layer 2 (menu)
  ;*Screen_Settings\Background_Colour = *Menu_Settings\Menu_Background_Colour
  *Menu_Settings\Menu_Active = 1
  
  Debug "Initialise: completed"
  *System\Initialised = 1
  ProcedureReturn 1 ; Initialise successful
EndProcedure

Procedure Shutdown(*System.System_Structure, *Window_Settings.Window_Settings_Structure, *Screen_Settings.Screen_Settings_Structure)
  If *Screen_Settings\Screen_Open
    CloseScreen()
    *Screen_Settings\Screen_Open = 0
  EndIf
  If *Window_Settings\Window_Open
    CloseWindow(0)
    *Window_Settings\Window_Open = 0
  EndIf 
  SaveConfig(*System, *Window_Settings, *Screen_Settings) ; only need to save screen/window variables
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows : CloseHandle_(*System\MutexID) : CompilerEndIf
EndProcedure

;- Set defaults

CompilerIf #PB_Compiler_IsMainFile
  
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    System\Minimum_Colour_Depth = 32
  CompilerCase #PB_OS_Linux
    System\Minimum_Colour_Depth = 24
  CompilerCase #PB_OS_MacOS
    System\Minimum_Colour_Depth = 32
CompilerEndSelect  
System\Fatal_Error_Message = "none"
System\Game_Title = "Universal Game Engine"
System\Game_Config_File = "settings.cfg"
System\Sprite_List_Data_Source = #Data_Source_Internal_Memory
System\Game_Resource_Location = "Data"
System\Debug_Window = 1
System\Current_Directory = GetCurrentDirectory()
System\Render_Engine3D = #Render_Engine3D_Builtin
System\Show_Debug_Info = 0 ; onscreen debug info
System\Allow_Switch_to_Window = 1
Window_Settings\Allow_Window_Resize = 1
Window_Settings\Reset_Window = 0
Window_Settings\Background_Colour = #Black
Screen_Settings\Num_Monitors = 0
Screen_Settings\Total_Desktop_Width = 0
Screen_Settings\Flip_Mode = #PB_Screen_WaitSynchronization
Screen_Settings\Border_Enable = 1
Screen_Settings\Border = 0 ; turn the border on by default
Screen_Settings\Classic_Screen_Background_Colour = #Black
Screen_Settings\Border_Width = 316
Screen_Settings\Border_Height = 284
Screen_Settings\Screen_Res_Width = 256
Screen_Settings\Screen_Res_Height = 224
Screen_Settings\Border_Colour = RGBA(120, 170, 255, 255)
Screen_Settings\Background_Colour = #Blue
Screen_Settings\Full_Screen = 0
Screen_Settings\Full_Screen_Type = #Full_Screen_Classic

Repeat ; used for restarting the game
  If Restart : Debug "System: restarting..." : EndIf
  Restart = 0 ; game has started so don't restart again
  If Initialise(@System, @Window_Settings, @Screen_Settings, @FPS_Data, @Menu_Settings, @Graphics)
    Debug "System: starting main loop"
    FPS_Data\Game_Start_Time = ElapsedMilliseconds()
    Repeat
      ; main game loop
      ProcessSystem(@FPS_Data) ; must be first in the main loop
      Debug_Settings\Debug_Var[0] = "FPS: " + FPS_Data\FPS
      ProcessWindowEvents(@System, @Window_Settings, @Screen_Settings, @Graphics)
      ProcessMouse(@System, @Screen_Settings)
      ProcessKeyboard(@System, @Window_Settings, @Screen_Settings, @Menu_Settings, @Graphics)
      ProcessControls()
      DoClearScreen(@System, @Screen_Settings)
      Draw3DWorld(@System)
      DrawSprites(@System, @Screen_Settings, @Menu_Settings, @Graphics)
      ShowDebugInfo(@System, @Screen_Settings, @FPS_Data)
      GrabScreen(@Screen_Settings)
      Draw2DGraphics(@System, @Screen_Settings)
      DrawBorder(@Screen_Settings)
      ShowZoomed2DScreen(@Screen_Settings)
      AddScreenFilter(@Screen_Settings)
      DoPostProcessing(@System) ; eg screen capture
      DrawMouse(@System, @Screen_Settings, @Graphics)
      ShowFullResGraphics(@Screen_Settings) ; eg system messages or console (not captured by screen capture)
      ShowDebugWindowInfo(@System, @Window_Settings, @FPS_Data, @Debug_Settings)
      DoFlipBuffer(@Screen_Settings)
      CheckFullScreen(@System, @Window_Settings, @Screen_Settings)  ; check for switching back to main window system (alt+tab), must be after FlipBuffers      
    Until System\Quit Or Restart
    Debug "System: shutting down..."
    Shutdown(@System, @Window_Settings, @Screen_Settings)
  Else
    MessageRequester ("Unable to start " + System\Game_Title, System\Initialise_Error_Message, #PB_MessageRequester_Error)
  EndIf
Until Not Restart

Debug "System: game ended"
End 0

CompilerEndIf

;- Data section
DataSection
  Data_Menu_Controls:
  ; First record is the number of records (make sure #Max_Menu_Controls is higher than the largest)
  ; Data is in the format of the Structure Menu_Control_Type
  ; menuless system
  Data_Menu_Controls_Menuless:
  ; This menu control system is like the Atari 2600 and is only included for making very simple games
  Data.i 3
  Data.i #Menu_System_Menuless, #Menu_Action_Start, #Control_Type_Keyboard, #PB_Key_Space
  Data.i #Menu_System_Menuless, #Menu_Action_Select, #Control_Type_Keyboard, #PB_Key_F1
  Data.i #Menu_System_Menuless, #Menu_Action_Reset, #Control_Type_Keyboard, #PB_Key_F2
  ; simple menu system
  Data_Menu_Controls_Simple:
  ; This menu system is for making console type games where the menu is controlled by up/down/left/right etc
  Data.i 6
  Data.i #Menu_System_Simple, #Menu_Action_Confirm, #Control_Type_Keyboard, #PB_Key_Return
  Data.i #Menu_System_Simple, #Menu_Action_Back, #Control_Type_Keyboard, #PB_Key_Escape
  Data.i #Menu_System_Simple, #Menu_Action_Up, #Control_Type_Keyboard, #PB_Key_Up
  Data.i #Menu_System_Simple, #Menu_Action_Down, #Control_Type_Keyboard, #PB_Key_Down
  Data.i #Menu_System_Simple, #Menu_Action_Left, #Control_Type_Keyboard, #PB_Key_Left
  Data.i #Menu_System_Simple, #Menu_Action_Right, #Control_Type_Keyboard, #PB_Key_Right
  ; pointer menu system
  Data_Menu_Controls_Pointer:
  ; This menu system is the most common for PC games
  Data.i 3
  Data.i #Menu_System_Pointer, #Menu_Action_Click, #Control_Type_Keyboard, #PB_Key_Return
  Data.i #Menu_System_Pointer, #Menu_Action_Click, #Control_Type_Keyboard, #PB_Key_Space
  Data.i #Menu_System_Pointer, #Menu_Action_Click, #Control_Type_Mouse, #PB_MouseButton_Left
  
  Data_Images:
  ; These are all the 2D images loaded by the system available to the game
  Data.i 0 ; Number of records
  
  Data_Internal_Sprite_Resources:
  ; Provides a list of sprite resources to be loaded
  ; Format: Width, Height, Mode, Transparent, Vector_Drawn, Source, Index/file
  Data.i 1 ; Number of records
  Data.i 12, 19, #PB_Sprite_AlphaBlending, #True, #False, #Data_Source_Internal_Memory, 0 ; Mouse sprite
  
  Data_Sprites:

  Data_Sprite_Mouse:
  Data.l $FF000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FF000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$FF000000,$FF000000,$FF000000,$FF000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FFFFFFFF,$FF000000,$00000000,$00000000,$FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000,$00000000
  Data.l $FF000000,$FF000000,$00000000,$00000000,$00000000,$00000000,$FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000
  Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$FF000000,$FFFFFFFF,$FFFFFFFF,$FF000000,$00000000,$00000000
  Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$FF000000,$FF000000,$00000000,$00000000,$00000000
  
  Data_Sprite_System_Font: ; C64 8x8 style
  Data.a %00110000, %01111000, %11001100, %11111100, %11001100, %11001100, %11001100, %00000000 ;A
  Data.a %11111000, %11001100, %11111000, %11001100, %11001100, %11001100, %11111000, %00000000 ;B
  Data.a %01111000, %11001100, %11000000, %11000000, %11000000, %11001100, %01111000, %00000000 ;C
  Data.a %11111000, %11001100, %11000110, %11000110, %11000110, %11001100, %11111000, %00000000 ;D
  Data.a %11111100, %11000000, %11000000, %11110000, %11000000, %11000000, %11111100, %00000000 ;E
  Data.a %11111100, %11000000, %11000000, %11110000, %11000000, %11000000, %11000000, %00000000 ;F
  Data.a %01111000, %11001100, %11000000, %11011100, %11001100, %11001100, %01111100, %00000000 ;G
  Data.a %11001100, %11001100, %11001100, %11111100, %11001100, %11001100, %11001100, %00000000 ;H
  Data.a %01111000, %00110000, %00110000, %00110000, %00110000, %00110000, %01111000, %00000000 ;I
  Data.a %00111100, %00011000, %00011000, %00011000, %00011000, %11011000, %01110000, %00000000 ;J
  Data.a %11001100, %11011000, %11110000, %11100000, %11110000, %11011000, %11001100, %00000000 ;K
  Data.a %11000000, %11000000, %11000000, %11000000, %11000000, %11000000, %11111100, %00000000 ;L
  Data.a %11000110, %11101110, %11111110, %11010110, %11000110, %11000110, %11000110, %00000000 ;M
  Data.a %11001100, %11101100, %11111100, %11011100, %11001100, %11001100, %11001100, %00000000 ;N
  Data.a %01111000, %11001100, %11001100, %11001100, %11001100, %11001100, %01111000, %00000000 ;O
  Data.a %11111000, %11001100, %11001100, %11111000, %11000000, %11000000, %11000000, %00000000 ;P
  Data.a %01111000, %11001100, %11001100, %11001100, %11001100, %01111000, %00011100, %00000000 ;Q
  Data.a %11111000, %11001100, %11001100, %11111000, %11110000, %11011000, %11001100, %00000000 ;R
  Data.a %01111000, %11001100, %11000000, %01111000, %00001100, %11001100, %01111000, %00000000 ;S
  Data.a %11111100, %00110000, %00110000, %00110000, %00110000, %00110000, %00110000, %00000000 ;T
  Data.a %11001100, %11001100, %11001100, %11001100, %11001100, %11001100, %01111000, %00000000 ;U
  Data.a %11001100, %11001100, %11001100, %11001100, %11001100, %01111000, %00110000, %00000000 ;V
  Data.a %11000110, %11000110, %11000110, %11010110, %11111110, %11101110, %11000110, %00000000 ;W
  Data.a %11001100, %11001100, %01111000, %00110000, %01111000, %11001100, %11001100, %00000000 ;X
  Data.a %11001100, %11001100, %11001100, %01111000, %00110000, %00110000, %00110000, %00000000 ;Y
  Data.a %11111100, %00001100, %00011000, %00110000, %01100000, %11000000, %11111100, %00000000 ;Z
  Data.a %00000000, %00000000, %01111000, %00001100, %01111100, %11001100, %01111100, %00000000 ;a
  Data.a %00000000, %11000000, %11000000, %11111000, %11001100, %11001100, %11111000, %00000000 ;b
  Data.a %00000000, %00000000, %01111000, %11000000, %11000000, %11000000, %01111000, %00000000 ;c
  Data.a %00000000, %00001100, %00001100, %01111100, %11001100, %11001100, %01111100, %00000000 ;d
  Data.a %00000000, %00000000, %01111000, %11001100, %11111100, %11000000, %01111000, %00000000 ;e
  Data.a %00000000, %00111000, %01100000, %11111000, %01100000, %01100000, %01100000, %00000000 ;f
  Data.a %00000000, %00000000, %01111100, %11001100, %11001100, %01111100, %00001100, %01111000 ;g
  Data.a %00000000, %11000000, %11000000, %11111000, %11001100, %11001100, %11001100, %00000000 ;h
  Data.a %00000000, %00110000, %00000000, %01110000, %00110000, %00110000, %01111000, %00000000 ;i
  Data.a %00000000, %00011000, %00000000, %00011000, %00011000, %00011000, %00011000, %11110000 ;j
  Data.a %00000000, %11000000, %11000000, %11011000, %11110000, %11011000, %11001100, %00000000 ;k
  Data.a %00000000, %01110000, %00110000, %00110000, %00110000, %00110000, %01111000, %00000000 ;l
  Data.a %00000000, %00000000, %11001100, %11111110, %11010110, %11000110, %11000110, %00000000 ;m
  Data.a %00000000, %00000000, %11111000, %11001100, %11001100, %11001100, %11001100, %00000000 ;n
  Data.a %00000000, %00000000, %01111000, %11001100, %11001100, %11001100, %01111000, %00000000 ;o
  Data.a %00000000, %00000000, %11111000, %11001100, %11001100, %11111000, %11000000, %11000000 ;p
  Data.a %00000000, %00000000, %01111100, %11001100, %11001100, %01111100, %00001100, %00001100 ;q
  Data.a %00000000, %00000000, %11111000, %11001100, %11000000, %11000000, %11000000, %00000000 ;r
  Data.a %00000000, %00000000, %01111100, %11000000, %01111000, %00001100, %11111000, %00000000 ;s
  Data.a %00000000, %00110000, %11111100, %00110000, %00110000, %00110000, %00011100, %00000000 ;t
  Data.a %00000000, %00000000, %11001100, %11001100, %11001100, %11001100, %01111100, %00000000 ;u
  Data.a %00000000, %00000000, %11001100, %11001100, %11001100, %01111000, %00110000, %00000000 ;v
  Data.a %00000000, %00000000, %11000110, %11010110, %11111110, %01111100, %01101100, %00000000 ;w
  Data.a %00000000, %00000000, %11001100, %01111000, %00110000, %01111000, %11001100, %00000000 ;x
  Data.a %00000000, %00000000, %11001100, %11001100, %11001100, %01111100, %00011000, %11110000 ;y
  Data.a %00000000, %00000000, %11111100, %00011000, %00110000, %01100000, %11111100, %00000000 ;z
  Data.a %01111000, %11001100, %11011100, %11101100, %11001100, %11001100, %01111000, %00000000 ;0
  Data.a %00110000, %01110000, %00110000, %00110000, %00110000, %00110000, %11111100, %00000000 ;1
  Data.a %01111000, %11001100, %00001100, %00011000, %01100000, %11000000, %11111100, %00000000 ;2
  Data.a %01111000, %11001100, %00001100, %00111000, %00001100, %11001100, %01111000, %00000000 ;3
  Data.a %00001100, %00011100, %00111100, %11001100, %11111110, %00001100, %00001100, %00000000 ;4
  Data.a %11111100, %11000000, %11111000, %00001100, %00001100, %11001100, %01111000, %00000000 ;5
  Data.a %01111000, %11001100, %11000000, %11111000, %11001100, %11001100, %01111000, %00000000 ;6
  Data.a %11111100, %11001100, %00011000, %00110000, %00110000, %00110000, %00110000, %00000000 ;7
  Data.a %01111000, %11001100, %11001100, %01111000, %11001100, %11001100, %01111000, %00000000 ;8
  Data.a %01111000, %11001100, %11001100, %01111100, %00001100, %11001100, %01111000, %00000000 ;9
  Data.a %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000 ;space
  Data.a %00110000, %00110000, %00110000, %00110000, %00000000, %00000000, %00110000, %00000000 ;!
  Data.a %01100110, %01100110, %01100110, %00000000, %00000000, %00000000, %00000000, %00000000 ;"
  Data.a %01100110, %01100110, %11111111, %01100110, %11111111, %01100110, %01100110, %00000000 ;#
  Data.a %00110000, %01111100, %11000000, %01111000, %00001100, %11111000, %00110000, %00000000 ;$
  Data.a %11000100, %11001100, %00011000, %00110000, %01100000, %11001100, %10001100, %00000000 ;%
  Data.a %01111000, %11001100, %01111000, %01110000, %11001110, %11001100, %01111110, %00000000 ;&
  Data.a %00001100, %00011000, %00110000, %00000000, %00000000, %00000000, %00000000, %00000000 ;'
  Data.a %00110000, %01100000, %11000000, %11000000, %11000000, %01100000, %00110000, %00000000 ;(
  Data.a %11000000, %01100000, %00110000, %00110000, %00110000, %01100000, %11000000, %00000000 ;)
  Data.a %00000000, %01100110, %00111100, %11111111, %00111100, %01100110, %00000000, %00000000 ;*
  Data.a %00000000, %00110000, %00110000, %11111100, %00110000, %00110000, %00000000, %00000000 ;+
  Data.a %00000000, %00000000, %00000000, %00000000, %00000000, %00011000, %00011000, %00110000 ;,
  Data.a %00000000, %00000000, %00000000, %11111100, %00000000, %00000000, %00000000, %00000000 ;minus
  Data.a %00000000, %00000000, %00000000, %00000000, %00000000, %00110000, %00110000, %00000000 ;.
  Data.a %00000000, %00000110, %00001100, %00011000, %00110000, %01100000, %11000000, %00000000 ;/
  Data.a %00000000, %00000000, %00110000, %00000000, %00000000, %00110000, %00000000, %00000000 ;:
  Data.a %00000000, %00000000, %00110000, %00000000, %00000000, %00110000, %00110000, %01100000 ;;
  Data.a %00011000, %00110000, %01100000, %11000000, %01100000, %00110000, %00011000, %00000000 ;<
  Data.a %00000000, %00000000, %11111100, %00000000, %11111100, %00000000, %00000000, %00000000 ;=
  Data.a %11000000, %01100000, %00110000, %00011000, %00110000, %01100000, %11000000, %00000000 ;>
  Data.a %01111000, %11001100, %00001100, %00011000, %00110000, %00000000, %00110000, %00000000 ;?
  Data.a %01111000, %11001100, %11011100, %11011100, %11000000, %11000100, %01111000, %00000000 ;@
  Data.a %00110000, %00110000, %00110000, %00000000, %00110000, %00110000, %00110000, %00000000 ;|
  Data.a %11111000, %11000000, %11000000, %11000000, %11000000, %11000000, %11111000, %00000000 ;[
  Data.a %11111000, %00011000, %00011000, %00011000, %00011000, %00011000, %11111000, %00000000 ;]
  Data.a %00001100, %00010010, %00110000, %01111100, %00110000, %01100010, %11111100, %00000000 ;£
  Data.a %00000000, %11000000, %01100000, %00110000, %00011000, %00001100, %00000110, %00000000 ;\ (non C64)
  Data.a %00111000, %01101100, %11000110, %00000000, %00000000, %00000000, %00000000, %00000000 ;^ (non C64)
  Data.a %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111100 ;_ (non C64)
  Data.a %00110000, %00011000, %00001100, %00000000, %00000000, %00000000, %00000000, %00000000 ;` (non C64)
  Data.a %00000000, %01110110, %11011100, %00000000, %00000000, %00000000, %00000000, %00000000 ;~ (non C64)
  Data.a %00011000, %00110000, %00110000, %01100000, %00110000, %00110000, %00011000, %00000000 ;{ (non C64)
  Data.a %01100000, %00110000, %00110000, %00011000, %00110000, %00110000, %01100000, %00000000 ;} (non C64)
  Data.a %00111110, %01100000, %11111100, %01100000, %11111100, %01100000, %00111110, %00000000 ;€ (non C64)
  Data.a %11001100, %11001100, %01111000, %11111100, %00110000, %11111100, %00110000, %00000000 ;¥ (non C64)
  Data.a %01111100, %10000010, %10111010, %10100010, %10111010, %10000010, %01111100, %00000000 ;© (non C64)
  Data.a %11101010, %01001110, %01010101, %00000000, %00000000, %00000000, %00000000, %00000000 ;™ (non C64)
  Data.a %11111110, %11000110, %10101010, %10010010, %10101010, %11000110, %11111110, %00000000 ;unknown  
  
  CompilerIf #PB_Compiler_IsMainFile
    
  Data_Vector_Resources:
  ; Format: Shape type, Background Transparent (T/F), Colour, Background colour, X, Y, Width, Height, Radius, Round_X, Round_Y, Continue
  Data.i 0 ; Number of records
  Data_Custom_Sprite_Resources:
  ; Provides a list of sprite resources to be loaded
  ; Format: Width, Height, Mode, Transparent, Vector_Drawn, Source, Index/file
  Data.i 0 ; Number of records
  Data_Sprite_Instances:
  ; Format: Sprite_Resource, X, Y, Width, Height, Velocity_X, Velocity_Y, Intensity, Colour, Layer, Visible, Controlled_By
  ; Layer 0 is background, higher numbers are on top
  ; Intensity and Colour of -1 means don't use a colour
  ; You have to set an intensity if you want to set a colour
  Data.i 0 ; Number of records
  Data_System_Font_Instances:
  ; Used for displaying the system font
  ; Format: String, Variable, X, Y, Char_Width, Char_Height, Intensity, Colour, Layer, Visible
  Data.i 0 ; Number of records
  
  CompilerEndIf
  
EndDataSection

; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 2343
; FirstLine = 2312
; Folding = ------------
; EnableXP
; DPIAware
; Executable = ..\..\GameEngine.exe
; EnableUnicode