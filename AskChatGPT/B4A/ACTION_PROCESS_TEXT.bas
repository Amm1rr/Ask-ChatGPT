B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public SharedText As String
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	'Activity.LoadLayout("Layout1")
	
	LogColor($"Share Initilize, ${FirstTime}"$, Colors.Blue)
	
	Try
		If Activity.GetStartingIntent.Action="android.intent.action.PROCESS_TEXT" Then
			SharedText = Activity.GetStartingIntent.GetExtra("android.intent.extra.PROCESS_TEXT")
			StartActivity(Reciver)
			
		End If
	Catch
		LogColor("ACTION_PROCESS_TEXT - Activity_Create:" & CRLF & LastException, Colors.Red)
	End Try
	
	LogColor("Activity Finish", Colors.Blue)
	Activity.Finish
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
