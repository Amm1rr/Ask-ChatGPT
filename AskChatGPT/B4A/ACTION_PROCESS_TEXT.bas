B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.8
@EndOfDesignText@
#Region Attributes 
	#IgnoreWarnings: 9,12
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public 	SharedText As String
	Private OldIntent 				As Intent
	Private intpub					As Intent
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
	
	Private lblShareResult 	As Label
	Private ColorLog		As Int = Colors.Magenta
	
End Sub

Private Sub MyLog(text As String, color As Int, AlwaysShow As Boolean)
'	Dim obj As B4XView = Sender
'	Try
	
	DateTime.DateFormat = "HH:mm:ss.SSS"
	Dim time As String  = DateTime.Date(DateTime.Now)
	
	If (AlwaysShow) Then
		LogColor("ACTION." & text & TAB & " (" & time & ")", color)
		Return
	End If
		
	If (General.IsDebug) Then
		LogColor("ACTION." & text & TAB & " (" & time & ")", color)
		Return
	End If
		
'	Catch
'		LogColor($"${obj} & ": " text"$, Colors.Blue)
'		Log(LastException)
'	End Try
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	'Activity.LoadLayout("Layout1")
	
	LogColor($"ACTION.Activity_Create: ${FirstTime}"$, Colors.Blue)
	LogColor(Activity.GetStartingIntent.Action, Colors.Blue)
	
	intpub = Activity.GetStartingIntent
	Activity.LoadLayout("Share")
	
	If intpub.Action="android.intent.action.PROCESS_TEXT" Then
		SharedText = Activity.GetStartingIntent.GetExtra("android.intent.extra.PROCESS_TEXT")
		
		MyLog($"Activity_Resume: ${SharedText}"$, ColorLog, True)
		
'		General.Set_StatusBarColor(0xFF74A5FF)
		
		
		dd.Initialize
		xui.RegisterDesignerClass(dd)
		
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
		
		lblShareText.Text = SharedText
		lblShareResult.Text = SharedText
	
	Else If intpub.Action="android.intent.extra.TEXT" Then
		Dim intent As JavaObject = Activity.GetStartingIntent
		
		Dim cType As String = intent.RunMethod("getType", Null)
		If Not (cType.Contains("text")) Then Return
		
		SharedText = intpub.GetExtra("android.intent.extra.TEXT") 'Get the shared text
		
		lblShareText.Text = SharedText
		lblShareResult.Text = SharedText
	
	Else If IsRelevantIntent(intpub) Then
		
		SharedText = intpub.GetExtra("android.intent.extra.TEXT")
		lblShareText.Text = SharedText
		lblShareResult.Text = SharedText
		
	Else If (Main.TextShared <> "") Then
		
		Dim cs As CSBuilder
		cs.Initialize
		cs.Color(Colors.Gray).Append(Application.LabelName & " " & Application.VersionCode).Color(Colors.Blue).Append(Application.VersionName).PopAll
		lblShareTitleTopMenu.Text = cs
		
		lblShareText.Text = SharedText
		lblShareResult.Text = SharedText
		
	Else
		MsgboxAsync("Here", "Heeeyyyyyyyy")
	End If
	
End Sub

Private Sub IsRelevantIntent(in As Intent) As Boolean
	MyLog("IsRelevantIntent", ColorLog, False)
	If in.IsInitialized And in <> OldIntent And in.Action = in.ACTION_SEND Then
		OldIntent = in
		Return True
	End If
	Return False
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Private Sub ClickSimulation
	Try
		XUIViewsUtils.PerformHapticFeedback(Sender)
	Catch
		LogColor("ClickSimulation: It's a Handled Runtime Exeption. It's Ok, Ignore It." & CRLF & TAB & TAB & LastException.Message, Colors.LightGray)
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

	MyLog("lblShareConfigTopMenu_Click", ColorLog, True)
	
	Dim pm 		As PackageManager
	Dim Intent1 As Intent
		Intent1 = pm.GetApplicationIntent (Application.PackageName)
	If 	Intent1.IsInitialized Then
		Main.TextShared = "[NEW]"
		StartActivity (Intent1)
		Activity.Finish
	End If
	
'	Main.TextShared = "[NEW]"
'	CallSubDelayed2(Main, "Activity_Create", False)
''	StartActivity(Main)
'	Activity.Finish
	
End Sub

Private Sub lblShareMenuTopMenu_Click

	MyLog("lblShareMenuTopMenu_Click", ColorLog, True)
	
	Dim pm 		As PackageManager
	Dim Intent1 As Intent
		Intent1 = pm.GetApplicationIntent (Application.PackageName)
	If 	Intent1.IsInitialized Then
		Main.TextShared = SharedText
		StartActivity (Intent1)
		Activity.Finish
	End If
	
'	Main.TextShared = SharedText
'	CallSubDelayed2(Main, "Activity_Create", False)
''	StartActivity(Main)
'	Activity.Finish
	
End Sub

Private Sub lblShareText_Click
	
End Sub
