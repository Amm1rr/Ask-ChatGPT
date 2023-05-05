B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region


'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

Private Sub Button1_Click
	
	Dim chat As ChatGPT
		chat.Initialize
	
	Dim questionHolder 	As String = "Translate"
	Dim question 		As String = "Translate book into Persian"
	Dim assistant 		As String = "You are a Smart helpfull AI Assistant."
	Dim Temperature		As Double = 0
	
	Wait For (chat.Query(questionHolder, _
							 question, _
							 assistant, _
							 Temperature, _
							 0)) Complete (response As Map)
	
	Dim responsetext As String 	= response.Get("response")
	Dim contine 	 As Boolean = response.Get("continue")
	
	xui.MsgboxAsync(responsetext, contine)
	
End Sub

Private Sub OldMethod
	Dim chat As ChatGPT
	chat.Initialize
	
	Dim questionHolder 	As String = "Translate"
	Dim question 		As String = "Translate book into Persian"
	Dim assistant 		As String = "You are a Smart helpfull AI Assistant."
	Dim Temperature		As Double = 0
	
	Wait For (chat.Query(questionHolder, _
							 question, _
							 assistant, _
							 Temperature, _
							 0)) Complete (response As Map)
	
	Dim responsetext As String 	= response.Get("response")
	Dim contine 	 As Boolean = response.Get("continue")
	
	xui.MsgboxAsync(responsetext, contine)
End Sub