B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=12.2
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	
	Private dd 	As DDD
	Private xui As XUI
	Private icConfigTopMenu As ImageView
	Private icShareMenuTopMenu As ImageView
	Private lblShareTitleTopMenu As Label
	Private panShare As Panel
	Private pShareTopMenu As Panel
	Private chkShareAllign As CheckBox
	Private chkShareGrammar As CheckBox
	Private chkShareSec As CheckBox
	Private chkShareTranslate As CheckBox
	Private icShareMenuTopMenu As ImageView
	Private lblShareText As Label
	Private panShareToolbar As Panel
	
	Private lblShareResult As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	
	MyLog($"Activity_Create Share, ${FirstTime}, ${ACTION_PROCESS_TEXT.SharedText}"$, True)
	
'	General.Set_StatusBarColor(0xFF74A5FF)
	
	Activity.LoadLayout("Share")
	
	dd.Initialize
	xui.RegisterDesignerClass(dd)
	
'	Dim lbl As Label
'		lbl.Initialize("lbl")
'		lbl.Text = "Transparent activty"
'		lbl.TextColor= Colors.Red
'		lbl.TextSize = 21
'	Activity.AddView(lbl,10dip,50%x,100%y,25dip)
	
	'###### { ### Set Navigation Bar Transparent
	Dim jo 		As JavaObject
	jo.InitializeContext
	Dim window 	As JavaObject
	window = jo.RunMethod("getWindow", Null)
	window.RunMethod("addFlags", Array(Bit.Or(0x00000200, 0x08000000)))
	'}-----
	
	Dim cs As CSBuilder
		cs.Initialize
		cs.Color(Colors.Gray).Append(Application.LabelName & " " & Application.VersionCode).Color(Colors.Blue).Append(Application.VersionName).PopAll
	lblShareTitleTopMenu.Text = cs
	lblShareText.Text = ACTION_PROCESS_TEXT.SharedText
	lblShareResult.Text = ACTION_PROCESS_TEXT.SharedText

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub MyLog(text As String, AlwaysShow As Boolean)
'	Dim obj As B4XView = Sender
'	Try

	If (AlwaysShow) Then
		LogColor(text, Colors.Black)
		Return
	End If
		
	If (General.IsDebug) Then
		LogColor(text, Colors.Black)
		Return
	End If
		
'	Catch
'		LogColor($"${obj} & ": " text"$, Colors.Blue)
'		Log(LastException)
'	End Try
End Sub

Private Sub ClickSimulation
	Try
		XUIViewsUtils.PerformHapticFeedback(Sender)
	Catch
		LogColor("ClickSimulation: It's a Handaled Runtime Exeption. It's Ok, Ignore It." & CRLF & TAB & TAB & LastException.Message, Colors.LightGray)
	End Try
End Sub

'Example:
'SetShadow(Pane1, 4dip, 0xFF757575)
'SetShadow(Button1, 4dip, 0xFF757575)
'
Private Sub SetShadow (View As B4XView, Offset As Double, Color As Int)
    #if B4J
    Dim DropShadow As JavaObject
	'You might prefer to ignore panels as the shadow is different.
	'If View Is Pane Then Return
    DropShadow.InitializeNewInstance(IIf(View Is Pane, "javafx.scene.effect.InnerShadow", "javafx.scene.effect.DropShadow"), Null)
    DropShadow.RunMethod("setOffsetX", Array(Offset))
    DropShadow.RunMethod("setOffsetY", Array(Offset))
    DropShadow.RunMethod("setRadius", Array(Offset))
    Dim fx As JFX
    DropShadow.RunMethod("setColor", Array(fx.Colors.From32Bit(Color)))
    View.As(JavaObject).RunMethod("setEffect", Array(DropShadow))
    #Else If B4A
	Offset = Offset * 2
	View.As(JavaObject).RunMethod("setElevation", Array(Offset.As(Float)))
    #Else If B4i
    View.As(View).SetShadow(Color, Offset, Offset, 0.5, False)
    #End If
End Sub


Private Sub Panel1_Click
	Activity.Finish
End Sub

Private Sub lblShareTitleTopMenu_Click
	
End Sub

Private Sub lblShareResult_Click
	
End Sub

Private Sub lblShareConfigTopMenu_Click
	
	StartActivity(Main)
	Activity.Finish
	
End Sub

Private Sub lblShareMenuTopMenu_Click
	
End Sub

Private Sub lblShareText_Click
	
End Sub
