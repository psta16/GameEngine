; Bat and Ball Game
; 13/11/2024 - Project started

EnableExplicit

;- Compiler checks

CompilerIf #PB_Compiler_DPIAware = 0 And #PB_Compiler_OS = #PB_OS_Windows
  CompilerError "Please turn on 'Enable DPI Aware executable' in compiler options"
CompilerEndIf

CompilerIf #PB_Compiler_Thread
  CompilerError "Please turn off 'Create threadsafe executable' in compiler options"
CompilerEndIf

;- Windows imports

;- Enumerations

Enumeration Vectors
  #Vector_Box
  #Vector_Ball
  #Vector_Dashed_Line
EndEnumeration

Enumeration Sprites
  ; Sprite #1 is the internal mouse sprite
  #Sprite_Box = 1
  #Sprite_Paddle
  #Sprite_Ball
  #Sprite_Dashed_Line
EndEnumeration

Enumeration Sprite_Instances
  #Sprite_Instance_Centre_Line1
  #Sprite_Instance_Centre_Line2
  #Sprite_Instance_Centre_Line3
  #Sprite_Instance_Centre_Line4
  #Sprite_Instance_Centre_Line5
  #Sprite_Instance_Centre_Line6
  #Sprite_Instance_Centre_Line7
  #Sprite_Instance_Centre_Line8
  #Sprite_Instance_Centre_Line9
  #Sprite_Instance_Centre_Line10
  #Sprite_Instance_Centre_Line11
  #Sprite_Instance_Centre_Line12
  #Sprite_Instance_Centre_Line13
  #Sprite_Instance_Centre_Line14
  #Sprite_Instance_Centre_Line15
  #Sprite_Instance_Centre_Line16
  #Sprite_Instance_Centre_Line17
  #Sprite_Instance_Centre_Line18
  #Sprite_Instance_Centre_Line19
  #Sprite_Instance_Centre_Line20
  #Sprite_Instance_Centre_Line21
  #Sprite_Instance_Centre_Line22
  #Sprite_Instance_Centre_Line23
  #Sprite_Instance_Centre_Line24
  #Sprite_Instance_Centre_Line25
  #Sprite_Instance_Centre_Line26
  #Sprite_Instance_Centre_Line27
  #Sprite_Instance_Centre_Line28
  #Sprite_Instance_Centre_Line29
  #Sprite_Instance_Centre_Line30
  #Sprite_Instance_Centre_Line31
  #Sprite_Instance_Centre_Line32
  #Sprite_Instance_Centre_Line33
  #Sprite_Instance_Centre_Line34
  #Sprite_Instance_Centre_Line35
  #Sprite_Instance_Centre_Line36
  #Sprite_Instance_Centre_Line37
  #Sprite_Instance_Field1 ; used to create the playing field
  #Sprite_Instance_Field2
  #Sprite_Instance_Field3
  #Sprite_Instance_Field4
  #Sprite_Instance_Field5
  #Sprite_Instance_Field6
  #Sprite_Instance_Paddle1 ; player paddles
  #Sprite_Instance_Paddle2
  #Sprite_Instance_Ball
EndEnumeration

Enumeration Control_Sets
  #Control_Set_Keyboard
  #Control_Set_Keyboard_Alt
  #Control_Set_Keyboard_2Ply_1
  #Control_Set_Keyboard_2Ply_2
EndEnumeration

Enumeration Sprite_Class
  #Sprite_Class_In_Play ; objects in play (ie excludes the score)
EndEnumeration

Enumeration Variables
  #Player_1_Score
  #Player_2_Score
EndEnumeration

Enumeration Story_Actions
  #Story_Actions_Start
  #Story_Actions_Pause
  #Story_Actions_Sprite_Change_Velocity
  #Story_Actions_Continue
  #Story_Actions_Player1_Point
  #Story_Actions_Restart_Level1
  #Story_Actions_Player2_Point
  #Story_Actions_Restart_Level2
EndEnumeration

;- Constants

;- Structures

;- Variables

;- Globals

;- Includes

XIncludeFile "GameEngine.pbi"

;- Procedure Declaration

;- Error handling

;- Threads

;- Callbacks

;- Procedures

Procedure InitialiseCustomCode()
  
EndProcedure

Procedure ProcessCustomSpritePositions()
  ; Do collision between ball and paddle
  
  
EndProcedure

;- Main

;- Set defaults
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    System\Minimum_Colour_Depth = 32
  CompilerCase #PB_OS_Linux
    System\Minimum_Colour_Depth = 24
  CompilerCase #PB_OS_MacOS
    System\Minimum_Colour_Depth = 32
CompilerEndSelect  
System\Fatal_Error_Message = "none"
System\Game_Title = "Battle Pong"
System\Game_Config_File = "settings.cfg"
System\Sprite_List_Data_Source = #Data_Source_Internal_Memory
System\Game_Resource_Location = "Data"
System\Debug_Window = 1
System\Current_Directory = GetCurrentDirectory()
System\Render_Engine3D = #Render_Engine3D_Builtin
System\Show_Debug_Info = 0 ; onscreen debug info
System\Allow_Switch_to_Window = 1
System\Allow_Screen_Capture = 1
Window_Settings\Allow_Window_Resize = 1
Window_Settings\Reset_Window = 0
Window_Settings\Background_Colour = #Gray
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
Screen_Settings\Full_Screen_Type = #Full_Screen_Windowed
Players\Player[0]\Player_Name = "Player 1"
Players\Player[0]\Control_Set = #Control_Set_Keyboard_2Ply_1
Players\Player[1]\Player_Name = "Player 2"
Players\Player[1]\Control_Set = #Control_Set_Keyboard_2Ply_2
System\Player_Count = 2
Story_Actions\Story_Position = #Story_Actions_Start

Repeat ; used for restarting the game
  If Restart : Debug "System: restarting..." : EndIf
  Restart = 0 ; game has started so don't restart again
  If Initialise(@System, @Window_Settings, @Screen_Settings, @FPS_Data, @Menu_Settings, @Graphics, @Controls, @Sprite_Constraints, @Story_Actions)
    InitialiseCustomCode()
    Debug "System: starting main loop"
    FPS_Data\Game_Start_Time = ElapsedMilliseconds()
    Repeat
      ; main game loop
      ProcessSystem(@FPS_Data) ; must be first in the main loop
      Debug_Settings\Debug_Var[0] = "FPS: " + FPS_Data\FPS
      Debug_Settings\Debug_Var[1] = "Player 1 Y: " + Graphics\Sprite_Instance[#Sprite_Instance_Paddle1]\Y
      Debug_Settings\Debug_Var[2] = "Player 2 Y: " + Graphics\Sprite_Instance[#Sprite_Instance_Paddle2]\Y
      Debug_Settings\Debug_Var[3] = "Ball X: " + FormatNumber(Graphics\Sprite_Instance[#Sprite_Instance_Ball]\X, 1)
      Debug_Settings\Debug_Var[4] = "Ball Y: " + FormatNumber(Graphics\Sprite_Instance[#Sprite_Instance_Ball]\Y, 1)
      Debug_Settings\Debug_Var[5] = "Ball Velocity X: " + FormatNumber(Graphics\Sprite_Instance[#Sprite_Instance_Ball]\Velocity_X, 1)
      Debug_Settings\Debug_Var[6] = "Ball Velocity Y: " + FormatNumber(Graphics\Sprite_Instance[#Sprite_Instance_Ball]\Velocity_Y, 1)
      ProcessWindowEvents(@System, @Window_Settings, @Screen_Settings, @Graphics)
      ProcessMouse(@System, @Screen_Settings)
      ProcessKeyboard(@System, @Window_Settings, @Screen_Settings, @Menu_Settings, @Graphics)
      ProcessControls(@System, @Graphics, @Controls, @Players)
      ProcessStory(@System, @Graphics, @Story_Actions)
      ProcessCustomSpritePositions()
      ProcessSpritePositions(@System, @Graphics)
      ProcessSpriteConstraints(@System, @Graphics, @Sprite_Constraints, @Story_Actions)
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

;- Custom data

#Colour_Black = #Black
#Colour_Light_Grey = 14474460
#Colour_Dark_Grey = 9868950
#Colour_Yellow = -16711681
#Colour_White = -1
#Colour_Blue_Slightly_Lighter = 16732184
#Colour_Transparent = 0
#Wall_Thickness = 6
#Paddle_Thickness = 6
#Paddle_Distance = 6
#Paddle_Length = 30
#Paddle_Speed = 400 ; pixels per second
#Goal_Sides = 0
#Paddle_Colour = #Colour_Light_Grey
#Score_Size = 16
#Wall_Colour = #Colour_Light_Grey
#Ball_Diameter = 7
#Ball_Colour = #Colour_White
#Score_Colour = #Colour_Yellow
#Score_Top = 12
#Ball_X = (256/2)-(#Ball_Diameter/2)-1
#Ball_Y = (224/2)-(#Ball_Diameter/2)-1
#Ball_Velocity_X = 0
#Ball_Velocity_Y = 0
#Paddle_Start_Y1 = 224/2-#Paddle_Length/2
#Paddle_Start_Y2 = 224/2-#Paddle_Length/2
#Ball_Velocity_Y_Min = -200
#Ball_Velocity_Y_Max = 200

DataSection
  
  Data_Vector_Resources:
  ; Format: Shape type, Background Transparent (T/F), Colour, Background colour, X, Y, Width, Height, Radius, Round_X, Round_Y, Continue
  Data.i 3 ; Number of records
  ;Data.i #Shape_Grid, #False, -5742030, -9422572, 32, 32, 256, 224, 0, 0, 0, 0  ; background grid
  Data.i #Shape_None, #False, 0, #Colour_White, 0, 0, 10, 10, 0, 0, 0, 0  ; standard box
  Data.i #Shape_Circle, #True, #Ball_Colour, 0, 0, 0, 0, 0, #Ball_Diameter/2, 0, 0, 0 ; ball
  Data.i #Shape_Box, #True, #Colour_White, 0, 0, 0, 3, 3, 0, 0, 0, 1                  ; centre line
  
  Data_Custom_Sprite_Resources:
  ; Provides a list of sprite resources to be loaded
  ; Format: Width, Height, Mode, Transparent, Vector_Drawn, Source, Index/file
  Data.i 4; Number of records
  Data.i 10, 10, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Box ; #Sprite_Box
  Data.i #Paddle_Thickness, #Paddle_Length, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Box ; #Sprite_Paddle
  Data.i #Ball_Diameter, #Ball_Diameter, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Ball   ; #Sprite_Ball
  Data.i 3, 6, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Dashed_Line

  Data_Sprite_Instances:
  ; Format: Sprite_Resource, Is_Static, Width, Height, Intensity, Use_Colour, Colour, Layer, Visible, Enabled, Pixel_Collisions, Collision_Class, No Reset, X, Y, Velocity_X, Velocity_Y
  ; Layer 0 is background, higher numbers are on top
  ; You have to set an intensity if you want to set a colour
  ; Collision_Class means only sprites with the same class can collied with it
  ; No reset means the sprite doesn't reset it's position when the level resets
  Data.i 46 ; Number of records
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+6, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+12, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+18, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+24, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+30, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+36, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+42, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+48, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+54, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+60, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+66, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+72, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+78, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+84, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+90, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+96, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+102, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+108, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+114, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+120, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+126, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+132, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+138, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+144, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+150, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+156, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+162, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+168, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+174, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+180, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+186, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+192, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+198, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+204, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+210, 0, 0
  Data.i #Sprite_Dashed_Line, #True, 3, 6, 255, #True, #Colour_Blue_Slightly_Lighter, 0, #True, #True, #False, 0, #False: Data.d 126, #Wall_Thickness+216, 0, 0
  Data.i #Sprite_Box, #True, 256, #Wall_Thickness, 255, #True, #Wall_Colour, 0, #True, #True, #False, 1, #False:Data.d 0, 0, 0, 0 ; top wall
  Data.i #Sprite_Box, #True, 256, #Wall_Thickness, 255, #True, #Wall_Colour, 0, #True, #True, #False, 1, #False:Data.d 0, 224-#Wall_Thickness, 0, 0 ; bottom wall
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #True, #False, 1, #False:Data.d 0, #Wall_Thickness, 0, 0 ; goal side top left
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #True, #False, 1, #False:Data.d 0, 224-#Goal_Sides-#Wall_Thickness, 0, 0; goal side bottom left
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #True, #False, 1, #False:Data.d 256-#Wall_Thickness, #Wall_Thickness, 0, 0; goal side top right
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #True, #False, 1, #False:Data.d 256-#Wall_Thickness, 224-#Goal_Sides-#Wall_Thickness, 0, 0 ; goal side bottom right
  Data.i #Sprite_Paddle, #False, #Wall_Thickness, #Paddle_Length, 255, #True, #Paddle_Colour, 0, #True, #True, #False, 1, #True:Data.d #Paddle_Distance, #Paddle_Start_Y1, 0, 0 ; paddle 1
  Data.i #Sprite_Paddle, #False, #Paddle_Thickness, #Paddle_Length, 255, #True, #Paddle_Colour, 0, #True, #True, #False, 1, #True:Data.d 256-#Paddle_Distance-#Paddle_Thickness, #Paddle_Start_Y2, 0, 0 ; paddle 2
  Data.i #Sprite_Ball, #False, #Ball_Diameter, #Ball_Diameter, 255, #True, #Ball_Colour, 0, #True, #True, #False, 1, #False:Data.d #Ball_X, #Ball_Y, #Ball_Velocity_X, #Ball_Velocity_Y                  ; ball
  
  Data_System_Font_Instances:
  ; Used for displaying the system font
  ; Format: String, Variable, X, Y, Char_Width, Char_Height, Intensity, Colour, Layer, Visible
  Data.i 2 ; Number of records
  ;Data.s "AaBbCcDdEeFfGgHhIiJjKkLlMm":Data.i -1, 30, 30, 8, 8, 255, #White, 0, 1
  ;Data.s "NnOoPpQqRrSsTtUuVvWwXxYyZz":Data.i -1, 30, 38, 8, 8, 255, #White, 0, 1
  ;Data.s "Score: 15450":Data.i -1, 30, 46, 8, 8, 255, #White, 0, 1
  Data.s "00":Data.i -1, 64-#Score_Size, 16, #Score_Size, #Score_Size, 255, #Score_Colour, 0, 1
  Data.s "00":Data.i -1, 192-#Score_Size, 16, #Score_Size, #Score_Size, 255, #Score_Colour, 0, 1
  
  Data_Control_Sets:
  ; Format: up, down, left, right, A_Button, B_Button, X_Button, Y_Button, Left_Shoulder, Right_Shoulder, Left_Trigger_Axis, Right_Trigger_Axis, Left_Stick_X, Left_Stick_Y,
  ; Right_Stick_X, Right_Stick_Y, Left_Stick_Click, Right_Stick_Click, Start, Select_Button, Home
  ; Use -1 for not connected
  Data.i 4
  Data.s "Keyboard one player":Data.i #Control_Type_Keyboard, #PB_Key_Up, #PB_Key_Down, -1, -1, #PB_Key_Space, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, #PB_Key_Return, -1, -1
  Data.s "Keyboard one player (alternate)":Data.i #Control_Type_Keyboard, #PB_Key_A, #PB_Key_Z, -1, -1, #PB_Key_Space, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, #PB_Key_Return, -1, -1
  Data.s "Keyboard two players (player one)":Data.i #Control_Type_Keyboard, #PB_Key_A, #PB_Key_Z, -1, -1, #PB_Key_Space, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, #PB_Key_Return, -1, -1
  Data.s "Keyboard two players (player two)":Data.i #Control_Type_Keyboard, #PB_Key_Up, #PB_Key_Down, -1, -1, #PB_Key_Pad0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, #PB_Key_Return, -1, -1
  
  Data_Object_Controls:
  ; These are control actions that affect a sprite
  ; Format: Sprite_Instance, Player, Control, Control_Type, Move_Speed (pixels per second)
  ; Control - a key or joystick button etc
  ; Control_Type - move up, jump, fire etc
  ; Use -1 if not used
  Data.i 6
  Data.i #Sprite_Instance_Paddle1, #Player1, #Control_Button_Up, #Object_Control_Move_Up:Data.d #Paddle_Speed
  Data.i #Sprite_Instance_Paddle1, #Player1, #Control_Button_Down, #Object_Control_Move_Down:Data.d #Paddle_Speed
  Data.i #Sprite_Instance_Paddle1, #Player1, #Control_Button_X_Button, #Object_Control_Fire:Data.d -1
  Data.i #Sprite_Instance_Paddle2, #Player2, #Control_Button_Up, #Object_Control_Move_Up:Data.d #Paddle_Speed
  Data.i #Sprite_Instance_Paddle2, #Player2, #Control_Button_Down, #Object_Control_Move_Down:Data.d #Paddle_Speed
  Data.i #Sprite_Instance_Paddle2, #Player2, #Control_Button_X_Button, #Object_Control_Fire:Data.d -1
  
  Data_Story_Actions:
  ; Format: Action, Time_length, Sprite_Instance, Player, Random_X(T/F), Random_Y(T/F), Random_Steps, Velocity_X, Velocity_Y, Random_X_Low, Random_X_High, Random_Y_Low, Random_Y_High
  ; Note: you can create random values lower than 1 by using random steps. For example low=-0.5 high=0.5 steps = 100
  Data.i 8
  Data.i #Story_Action_Start, 0, -1, -1, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Game Start
  Data.i #Story_Action_Pause, 1000, -1, -1, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Pause
  Data.i #Story_Action_Sprite_Change_Velocity, 0, #Sprite_Instance_Ball, -1, #False, #True, 100:Data.d 200, 0, 0, 0, #Ball_Velocity_Y_Min, #Ball_Velocity_Y_Max ; Sprite change veloocity
  Data.i #Story_Action_Continue, 0, -1, -1, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Game continue
  Data.i #Story_Action_Player_Point, 0, -1, 1, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Player 1 point
  Data.i #Story_Action_Restart_Level, 0, -1, -1, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Restart level
  Data.i #Story_Action_Player_Point, 0, -1, 2, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Player 2 point
  Data.i #Story_Action_Restart_Level, 0, -1, -1, #False, #False, 0:Data.d 0, 0, 0, 0, 0, 0 ; Restart level  
  
  Data_Sprite_Constraints:
  ; Format: Sprite_Instance, Type, Value, Sprite_Action, Story_Action, Player
  ; Use -1 for no change in story action
  Data.i 6
  Data.i #Sprite_Instance_Paddle1, #Constraint_Type_Bottom, #Wall_Thickness, #Sprite_Action_Stop, -1, 0
  Data.i #Sprite_Instance_Paddle1, #Constraint_Type_Top, 224-#Wall_Thickness-#Paddle_Length, #Sprite_Action_Stop, -1, 0
  Data.i #Sprite_Instance_Paddle2, #Constraint_Type_Bottom, #Wall_Thickness, #Sprite_Action_Stop, -1, 0
  Data.i #Sprite_Instance_Paddle2, #Constraint_Type_Top, 224-#Wall_Thickness-#Paddle_Length, #Sprite_Action_Stop, -1, 0
  Data.i #Sprite_Instance_Ball, #Constraint_Type_Right, 0, #Sprite_Action_Invisible, 4, 1
  Data.i #Sprite_Instance_Ball, #Constraint_Type_Left, 255, #Sprite_Action_Invisible, 6, 2
  
  Data_Variables:
  ;Format: Type, default value
  Data.i 2
  Data.i #Variable_Type_Integer, 0
  Data.i #Variable_Type_Integer, 0
  
EndDataSection
; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 44
; FirstLine = 27
; Folding = -
; EnableXP
; DPIAware