B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.2
@EndOfDesignText@

Sub Class_Globals
	
	Type textMessage (message As String, assistant As Boolean)
	Private su As StringUtils
	
	'KEYBOARD
	Private ime As IME
	Private heightKeyboard As Int
	Private MaximumSize As Int = 0
	

	'CHAT
	Public txtQuestion As EditText
	Public imgSend As ImageView
	Private clvMessages As CustomListView
	Private panBottom As Panel
	Private pTopMenu As Panel
	Private lblTitleTopMenu As Label
	Private icMenuTopMenu As ImageView
	Private icConfigTopMenu As ImageView
	
	Private WaitingText As String = "Proccessing..."
	
	
	'CLV Answer
	Private lblAnswer As Label
	Private pnlAnswer As Panel
	Private imgAnswer As ImageView
	
	'CLV Question
	Private lblQuestion As Label
	Private pnlQuestion As Panel
	Private imgQuestion As ImageView
	
	Private btnCloseAbout As B4XView
	Private pnlAbout As B4XView
	Private pnlBackground As B4XView
	Private lblVersionNumber As B4XView
	Private lblVersionName As B4XView
	Private lblVersionText As B4XView
	
	Public AUTOSENDVOICE As Boolean = False
	Private chkCorrectEnglish As B4XView
	Private chkTranslate As CheckBox
	Private chkToFarsi As CheckBox
	Private panToolbar As B4XView
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Parent As B4XView)
	
'	General.Set_StatusBarColor(Colors.RGB(89,89,89))
'	General.Set_StatusBarColor(Colors.RGB(51,129,232))
	General.Set_StatusBarColor(0xFF74A5FF)
	Parent.LoadLayout("Chat")
	
	ime.Initialize("ime")
	ime.AddHeightChangedEvent
	
	
	'TOP MENU
	Private csTitle As CSBuilder
	csTitle.Initialize
	csTitle.Color(Colors.White).Append("Ask Chat").Color(Colors.Yellow).Append("GPT").PopAll
	lblTitleTopMenu.Text = csTitle
	icMenuTopMenu.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "menu.png", icMenuTopMenu.Width, icMenuTopMenu.Height, True)).Gravity = Gravity.CENTER
	icConfigTopMenu.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "settings.png", icConfigTopMenu.Width, icConfigTopMenu.Height, True)).Gravity = Gravity.CENTER
	


	Private cc As ColorDrawable
	cc.Initialize2(Colors.RGB(250,250,250),10,2,Colors.LightGray)
	panBottom.Background = cc
	txtQuestion.Background = Null
	General.setPadding(txtQuestion,0,0,0,0) 'REMOVE PADDING DO EDITTEXT
	
	imgSend.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Voice.png", imgSend.Width, imgSend.Height, True)).Gravity = Gravity.CENTER
	imgSend.Tag = "voice"


	'Calls the function of adjusting the size of the keyboard
	IME_HeightChanged(100%y,0)
	MaximumSize = su.MeasureMultilineTextHeight(txtQuestion,"Size Test!") * 6 'After 6 lines, the EditText will increase, and after that, the scroll will appear
	
	
	LoadCLVSetup
	
	
End Sub

Private Sub LoadCLVSetup
	
	Dim myStrings As List
		myStrings.Initialize
		myStrings.Add("Hey, What whould you like to know ?")
		myStrings.Add("Hi there, How are you?")
		myStrings.Add("How can I help?")
		myStrings.Add("💻")
		myStrings.Add("👩")
		myStrings.Add("👨‍🏫")
		myStrings.Add("🧑")
		myStrings.Add("🤖")
		myStrings.Add("📚")
		myStrings.Add("🤔")
		myStrings.Add("💡")
		myStrings.Add("Just Ask... 🤔")
		myStrings.Add("I know all languages that might you know 😀")
		myStrings.Add("Try me in Farsi...فارسی بپرس")
		myStrings.Add("Try me in Farsi...با هر زبانی که میخوای ازم سوال بپرس")
		myStrings.Add("Try me in Farsi...بیا فارسی صحبت کنیم 😉")
		myStrings.Add("Try me in German...Versuchen wir es mit Deutsch 🇩🇪")
		myStrings.Add("I can correct your english, just ask")
	
	Dim index As Int
	index = Rnd(0, myStrings.Size - 1)
	
	WriteAnswer(myStrings.Get(index))
	
End Sub

public Sub AdjustSize_Clv
	Try
		clvMessages.AsView.Top = 0 + pTopMenu.Height
		clvMessages.AsView.Height = panBottom.Top - pTopMenu.Height - panToolbar.Height - 1%y
		clvMessages.Base_Resize(clvMessages.AsView.Width,clvMessages.AsView.Height)
		panToolbar.SetLayoutAnimated(0, panToolbar.Left, panBottom.Top - panToolbar.Height - 0.2%y, panToolbar.Width, panToolbar.Height)
		Sleep(0) 'To make sure you've adjusted the size, before scrolling down (IMPORTANT SLEEP HERE!)
		If clvMessages.Size > 0 Then clvMessages.JumpToItem(clvMessages.Size - 1)
	Catch
		LogColor(LastException, Colors.Red)
	End Try
End Sub

Private Sub clvMessages_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 2
	For i = 0 To clvMessages.Size - 1
		Dim p As Panel = clvMessages.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If p.NumberOfViews = 0 Then
				
				Dim m As textMessage = clvMessages.GetValue(i)
				
				If (m.assistant) Then
		
					p.LoadLayout("clvAnswerRow")
					lblAnswer.Text = m.message
	
					imgAnswer.Height = 3%y
					imgAnswer.Top = 0
					imgAnswer.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Puton.png", imgAnswer.Width, imgAnswer.Height, False)).Gravity = Gravity.CENTER
					
					'ADJUST VERTICAL
					Private TopMargin As Int = 1%y : Private BottomMargin As Int = 1%y
					lblAnswer.Height = General.Size_textVertical(lblAnswer,lblAnswer.Text)
					lblAnswer.Top = 0%y + TopMargin
					
					'ADJUST HORIZONTAL
					If General.Size_textHorizontal(lblAnswer,lblAnswer.Text) < 82%x Then
						lblAnswer.Width = General.Size_textHorizontal(lblAnswer,lblAnswer.Text)
						lblAnswer.SingleLine = True
						pnlAnswer.Width = lblAnswer.Width +4%x
					End If
					
					pnlAnswer.Height = lblAnswer.Height + TopMargin + BottomMargin
					clvMessages.ResizeItem(i,pnlAnswer.Height)
				
				Else
					
					p.LoadLayout("clvQuestionRow")
					lblQuestion.Text = m.message
					
					imgQuestion.Height = 3%y
					imgQuestion.Top = 0
					imgQuestion.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Gray-Tipped.png", imgQuestion.Width, imgQuestion.Height, False)).Gravity = Gravity.CENTER
					
					'ADJUST VERTICAL
					Private TopMargin As Int = 1%y : Private BottomMargin As Int = 1%y
					lblQuestion.Height = General.Size_textVertical(lblQuestion,m.message)
					lblQuestion.Top = 0%y + TopMargin
					
					'ADJUST HORIZONTAL
					If General.Size_textHorizontal(lblQuestion,lblQuestion.Text) < 82%x Then
						lblQuestion.Width = General.Size_textHorizontal(lblQuestion,lblQuestion.Text)
						lblQuestion.SingleLine = True
						pnlQuestion.Width = lblQuestion.Width +4%x
						pnlQuestion.Left = 100%x - pnlQuestion.Width - 4%x
					End If
	
					pnlQuestion.Height = lblQuestion.Height + TopMargin + BottomMargin
					clvMessages.ResizeItem(i,pnlQuestion.Height)
			
				End If
			End If
		Else
			If p.NumberOfViews > 0 Then
				p.RemoveAllViews
			End If
		End If
	Next
End Sub


Private Sub clvMessages_ItemLongClick (Index As Int, Value As Object)
	LogColor(Value, Colors.Blue)
	ToastMessageShow("Copied", False)
	Dim cp As BClipboard
	Dim vl As textMessage = Value
	cp.setText(vl.message)
End Sub

Private Sub clvMessages_ItemClick(Index As Int, Value As Object)
	HideKeyboard
'	#if B4i
'		Dim tf As View = TextField.TextField
'		tf.ResignFocus
'	#End If
End Sub





Sub txtQuestion_TextChanged (Old As String, New As String)
	
	'Voice to Text Icon
	If New.Length > 0 Then
		imgSend.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Message.png", imgSend.Width, imgSend.Height, True)).Gravity = Gravity.CENTER
		imgSend.Tag = "text"
	Else
		imgSend.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Voice.png", imgSend.Width, imgSend.Height, True)).Gravity = Gravity.CENTER
		imgSend.Tag = "voice"
	End If
	
	
	Private i As Int = su.MeasureMultilineTextHeight(txtQuestion,New)
	If i > MaximumSize Then Return 'Reached the size limit.
	
	If i > 7%y Then 'It is small, we are going to increase to the limit
		panBottom.Height = i
		txtQuestion.Height = i
		panBottom.Top = heightKeyboard - panBottom.Height - 1%y
		AdjustSize_Clv
	End If
	
End Sub



Sub IME_HeightChanged(NewHeight As Int, OldHeight As Int)
	heightKeyboard = NewHeight
	panBottom.SetLayout(panBottom.Left, heightKeyboard - panBottom.Height - 1%y, panBottom.Width, panBottom.Height)
	imgSend.SetLayout(imgSend.Left, heightKeyboard - imgSend.Height - 1%y, imgSend.Width, imgSend.Height)
'	panToolbar.SetLayoutAnimated(0, panToolbar.Left, panBottom.Top - panToolbar.Height, panToolbar.Width, panToolbar.Height)
'	panToolbar.Top = NewHeight - panToolbar.Height - 200
	AdjustSize_Clv
End Sub


Public Sub ScrollToLastItem(CLV As CustomListView)
	Sleep(50)
	If CLV.Size > 0 Then
		If CLV.sv.ScrollViewContentHeight > CLV.sv.Height Then
			CLV.ScrollToItem(CLV.Size - 1)
		End If
	End If
End Sub




Private Sub imgSend_LongClick
	AUTOSENDVOICE = Not(AUTOSENDVOICE)
	ToastMessageShow("Auto Send " & AUTOSENDVOICE, False)
End Sub

Public Sub About
	
	lblVersionName.Text = Application.LabelName
	lblVersionNumber.Text = "Build " & Application.VersionCode & " " & Application.VersionName
	
	Dim csTitle As CSBuilder
		csTitle.Initialize
		csTitle.Color(Colors.White).Append("Dev by ").Color(Colors.LightGray).Append("github.com/").Color(Colors.Yellow).Clickable("csTitle", 1).Underline.Append("Amm1rr").PopAll
	lblVersionText.Text = csTitle
	
	pnlBackground.Visible = True
	pnlAbout.Visible = True
	
End Sub

Private Sub csTitle_Click (Tag As Object)
	LogColor("Click: " & Tag, Colors.Blue)
End Sub

Public Sub imgSend_Click
	
	Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
'	LogColor(clvMessages.Size & " - " & msg.message, Colors.Magenta)
	If (msg.message = WaitingText) Then Return
	
	If (imgSend.Tag = "text") Then
		
		Dim sText As String
		Dim question As String
		
		If (chkCorrectEnglish.Checked) Then
			sText = "Check Grammer, Correct and Improve this English sentenc:" & CRLF
		Else If (chkTranslate.Checked) Then
			sText = "Translate to English this:" & CRLF
		Else If (chkToFarsi.Checked) Then
			sText = "Translate to Farsi this:" & CRLF
		End If
		
		If (chkCorrectEnglish.Checked = False) And _
			(chkTranslate.Checked = False) And _
			(chkToFarsi.Checked = False) Then
			
			sText = txtQuestion.Text.Trim
			question = sText
		Else
			question = sText & " '" & txtQuestion.Text.Trim & "'"
			sText = txtQuestion.Text.Trim
		End If
		WriteQuestion(sText)
		txtQuestion.Text = ""
		Ask(question)
		
	Else
		Log(imgSend.Tag)
		Log("Voice")
		
		Wait For (RecognizeVoice) Complete (Result As String)
		If (Result <> "") Then
			LogColor(Result, Colors.Blue)
			txtQuestion.Text = Result
			If (AUTOSENDVOICE) Then
				imgSend_Click
			Else
				txtQuestion.SelectAll
			End If
		End If
		IME_HeightChanged(100%y, 0)
		
	End If
	
'	#if B4J
'		Dim ta As TextArea = txtQuestion
'			ta.SelectAll
'	#else if B4A
'	Dim et As EditText = txtQuestion
'		et.SelectAll
'	#else if B4i
'		Dim ta As TextView = txtQuestion
'			ta.SelectAll
'	#end if
	
End Sub


Private Sub RecognizeVoice As ResumableSub
	Main.vr.Listen
	Wait For vr_Result (Success As Boolean, Texts As List)
	If Success And Texts.Size > 0 Then
		Return Texts.Get(0)
	End If
	Return ""
End Sub








Sub WriteQuestion(message As String) 'Right Side
	Dim m As textMessage
		m.Initialize
		m.message = message
		m.assistant = False
	Dim p As Panel
		p.Initialize("p")
		p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, 15%y)
	clvMessages.Add(p, m)
	AdjustSize_Clv
End Sub


Sub WriteAnswer(message As String) 'Left Side
	Dim m As textMessage
		m.Initialize
		m.message = message
		m.assistant = True
	Dim p As Panel
		p.Initialize("p")
		p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, 15%y)
'	If (clvMessages.Size > 0) Then
'		clvMessages.ReplaceAt(clvMessages.Size - 1, p, clvMessages.AsView.Width, m)
'	Else
'		m.message = WaitingText
		clvMessages.Add(p, m)
'	End If
	AdjustSize_Clv
End Sub

Sub HideKeyboard
	txtQuestion.Text = ""
	panBottom.Height = 7%y
	txtQuestion.Height = 7%y
	ime.HideKeyboard
End Sub

Public Sub Ask(question As String)
	
	Dim wrk_chat As ChatGPT
		wrk_chat.Initialize
	
	If (question = "") Then
		txtQuestion.RequestFocus
		ShowKeyboard
		Return
	End If
	
'	Dim msg As textMessage
'		msg.Initialize
'		msg.message = question
'		msg.assistant = True
'	clvMessages.AddTextItem(WaitingText, msg)
	
	Dim m As textMessage
		m.Initialize
		m.message = WaitingText '"Proccessing..."
		m.assistant = True
	Dim p As Panel
		p.Initialize("p")
		p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, 15%y)
	clvMessages.Add(p, m)
	
	AdjustSize_Clv
	
	Wait For (wrk_chat.Query(question)) Complete (response As String)
	
	clvMessages.RemoveAt(clvMessages.Size - 1)
	AdjustSize_Clv
	
	Log(response)
	WriteAnswer(response)
	
	Return
	
End Sub

Public Sub ShowKeyboard
	ime.ShowKeyboard(txtQuestion)
End Sub

Private Sub icConfigTopMenu_Click
	HideKeyboard
	About
End Sub

#if B4J
Sub imgSend_MouseClicked (EventData As MouseEvent)
	lblSend_Click
	EventData.Consume
End Sub
Sub icConfigTopMenu_MouseClicked (EventData As MouseEvent)
	icConfigTopMenu_Click
	EventData.Consume
End Sub
#end if


Private Sub btnCloseAbout_Click
	pnlBackground.Visible = False
	pnlAbout.Visible = False
End Sub


Private Sub pnlBackground_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub lblClearText_Click
	txtQuestion.Text = ""
	ShowKeyboard
End Sub

Private Sub txtQuestion_FocusChanged (HasFocus As Boolean)
	If Not (HasFocus) Then HideKeyboard
End Sub


Private Sub chkCorrectEnglish_CheckedChange(Checked As Boolean)
	If (Checked = True) Then
		chkTranslate.Checked = False
		chkToFarsi.Checked = False
		Return
	End If
End Sub

Private Sub chkTranslate_CheckedChange(Checked As Boolean)
	If (Checked = True) Then
		chkCorrectEnglish.Checked = False
		chkToFarsi.Checked = False
		Return
	End If
End Sub

Private Sub chkToFarsi_CheckedChange(Checked As Boolean)
	If (Checked = True) Then
		chkCorrectEnglish.Checked = False
		chkTranslate.Checked = False
	End If
End Sub
