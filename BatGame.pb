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
  ;#Vector_Grid
  #Vector_Box
  #Vector_Ball
EndEnumeration

Enumeration Sprites
  ; Sprite #1 is the internal mouse sprite
  #Sprite_Box = 1
  #Sprite_Paddle
  #Sprite_Ball
  #Sprite_Grid
EndEnumeration

Enumeration Sprite_Instances
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

Repeat ; used for restarting the game
  If Restart : Debug "System: restarting..." : EndIf
  Restart = 0 ; game has started so don't restart again
  If Initialise(@System, @Window_Settings, @Screen_Settings, @FPS_Data, @Menu_Settings, @Graphics, @Controls, @Sprite_Constraints)
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
      ProcessSpritePositions(@System, @Graphics)
      ProcessSpriteConstraints(@System, @Graphics, @Sprite_Constraints)
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

#Colour_Black = -16777216
#Colour_Light_Grey = -3618616
#Colour_Dark_Grey = -10197916
#Colour_Yellow = -16711681
#Colour_White = -1
#Colour_Aqua = -327824
#Wall_Thickness = 6
#Paddle_Thickness = 6
#Paddle_Distance = 6
#Paddle_Length = 30
#Goal_Sides = 0
#Paddle_Colour = #Colour_Aqua
#Score_Size = 16
#Wall_Colour = #Colour_Light_Grey
#Ball_Diameter = 7
#Ball_Colour = #Colour_White
#Score_Colour = #Colour_Yellow
#Score_Top = 12
#Ball_X = (256/2)-(#Ball_Diameter/2)-1
#Ball_Y = (224/2)-(#Ball_Diameter/2)-1
#Ball_Velocity_X = -0.5
#Ball_Velocity_Y = -0.1
#Paddle_Start_Y1 = 224/2-#Paddle_Length/2
#Paddle_Start_Y2 = 224/2-#Paddle_Length/2

DataSection
  
  Data_Vector_Resources:
  ; Format: Shape type, Background Transparent (T/F), Colour, Background colour, X, Y, Width, Height, Radius, Round_X, Round_Y, Continue
  Data.i 2 ; Number of records
  ;Data.i #Shape_Grid, #False, -5742030, -9422572, 32, 32, 256, 224, 0, 0, 0, 0  ; background grid
  Data.i #Shape_None, #False, 0, #Colour_White, 0, 0, 10, 10, 0, 0, 0, 0  ; standard box
  Data.i #Shape_Circle, #True, #Ball_Colour, 0, 0, 0, 0, 0, #Ball_Diameter/2, 0, 0, 0  ; ball
  
  Data_Custom_Sprite_Resources:
  ; Provides a list of sprite resources to be loaded
  ; Format: Width, Height, Mode, Transparent, Vector_Drawn, Source, Index/file
  Data.i 3; Number of records
  Data.i 10, 10, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Box ; #Sprite_Box
  Data.i #Paddle_Thickness, #Paddle_Length, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Box ; #Sprite_Paddle
  Data.i #Ball_Diameter, #Ball_Diameter, #PB_Sprite_AlphaBlending, #True, #True, #Data_Source_Internal_Memory, #Vector_Ball ; #Sprite_Ball
  ;Data.i 256, 224, #PB_Sprite_AlphaBlending, #False, #True, #Data_Source_Internal_Memory, #Vector_Grid ; #Sprite_Grid

  Data_Sprite_Instances:
  ; Format: I:Sprite_Resource, Is_Static, Width, Height, Intensity, Use_Colour, Colour, Layer, Visible, Pixel_Collisions, Collision_Class, X, Y, Velocity_X, Velocity_Y
  ; Layer 0 is background, higher numbers are on top
  ; You have to set an intensity if you want to set a colour
  ; Collision_Class means only sprites with the same class can collied with it
  Data.i 9 ; Number of records
  ;Data.i #Sprite_Grid, #True, 256, 224, 255, #False, 0, 0, #True, #False, 0:Data.d 0, 0, 0, 0 ; top wall 1
  Data.i #Sprite_Box, #True, 256, #Wall_Thickness, 255, #True, #Wall_Colour, 0, #True, #False, 0:Data.d 0, 0, 0, 0 ; top wall 1
  Data.i #Sprite_Box, #True, 256, #Wall_Thickness, 255, #True, #Wall_Colour, 0, #True, 0, 0:Data.d 0, 224-#Wall_Thickness, 0, 0 ; bottom wall 2
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #False, 0:Data.d 0, #Wall_Thickness, 0, 0 ; goal side top left 3
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #False, 0:Data.d 0, 224-#Goal_Sides-#Wall_Thickness, 0, 0; goal side bottom left 4
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #False, 0:Data.d 256-#Wall_Thickness, #Wall_Thickness, 0, 0; goal side top right 5
  Data.i #Sprite_Box, #True, #Wall_Thickness, #Goal_Sides, 255, #True, #Wall_Colour, 0, #True, #False, 0:Data.d 256-#Wall_Thickness, 224-#Goal_Sides-#Wall_Thickness, 0, 0            ; goal side bottom right 6
  Data.i #Sprite_Paddle, #False, #Paddle_Thickness, #Paddle_Length, 255, #True, #Paddle_Colour, 0, #True, #False, 0:Data.d #Paddle_Distance, #Paddle_Start_Y1, 0, 0 ; paddle 1
  Data.i #Sprite_Paddle, #False, #Paddle_Thickness, #Paddle_Length, 255, #True, #Paddle_Colour, 0, #True, #False, 0:Data.d 256-#Paddle_Distance-#Paddle_Thickness, #Paddle_Start_Y2, 0, 0 ; paddle 2
  Data.i #Sprite_Ball, #False, #Ball_Diameter, #Ball_Diameter, 255, #True, #Ball_Colour, 0, #True, #False, 0:Data.d #Ball_X, #Ball_Y, #Ball_Velocity_X, #Ball_Velocity_Y ; ball
  
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
  ; Format: Sprite_Instance, Player, Control, Control_Type, Move_Speed
  ; Control - a key or joystick button etc
  ; Control_Type - move up, jump, fire etc
  ; Use -1 if not used
  Data.i 6
  Data.i #Sprite_Instance_Paddle1, #Player1, #Control_Button_Up, #Object_Control_Move_Up:Data.d 1.0
  Data.i #Sprite_Instance_Paddle1, #Player1, #Control_Button_Down, #Object_Control_Move_Down:Data.d 1.0
  Data.i #Sprite_Instance_Paddle1, #Player1, #Control_Button_X_Button, #Object_Control_Fire:Data.d -1
  Data.i #Sprite_Instance_Paddle2, #Player2, #Control_Button_Up, #Object_Control_Move_Up:Data.d 1.0
  Data.i #Sprite_Instance_Paddle2, #Player2, #Control_Button_Down, #Object_Control_Move_Down:Data.d 1.0
  Data.i #Sprite_Instance_Paddle2, #Player2, #Control_Button_X_Button, #Object_Control_Fire:Data.d -1
  
  Data_Sprite_Constraints:
  ; Format: Sprite_Instance, Type, Value, Sprite_Action, Game_Action1, Game_Action2, Game_Action3, Player
  Data.i 6
  Data.i #Sprite_Instance_Paddle1, #Constraint_Type_Bottom, #Wall_Thickness, #Constraint_Action_Stop, #Game_Action_None, #Game_Action_None, #Game_Action_None, 0
  Data.i #Sprite_Instance_Paddle1, #Constraint_Type_Top, 224-#Wall_Thickness-#Paddle_Length, #Constraint_Action_Stop, #Game_Action_None, #Game_Action_None, #Game_Action_None, 0
  Data.i #Sprite_Instance_Paddle2, #Constraint_Type_Bottom, #Wall_Thickness, #Constraint_Action_Stop, #Game_Action_None, #Game_Action_None, #Game_Action_None, 0
  Data.i #Sprite_Instance_Paddle2, #Constraint_Type_Top, 224-#Wall_Thickness-#Paddle_Length, #Constraint_Action_Stop, #Game_Action_None, #Game_Action_None, #Game_Action_None, 0
  Data.i #Sprite_Instance_Ball, #Constraint_Type_Right, 0, #Constraint_Action_Invisible, #Game_Action_Player_Point, #Game_Action_Restart_Level, #Game_Action_None, 2
  Data.i #Sprite_Instance_Ball, #Constraint_Type_Left, 255, #Constraint_Action_Invisible, #Game_Action_Player_Point, #Game_Action_Restart_Level, #Game_Action_None, 1
  
  Data_Game_Mode:
  ; Format: 
  Data.i 0
  
EndDataSection


; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 183
; FirstLine = 147
; Folding = -
; EnableXP
; DPIAware