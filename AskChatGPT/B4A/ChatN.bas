B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.2
@EndOfDesignText@

Sub Class_Globals
	
	Type textMessage (message As String, assistant As Boolean)
	Private su As StringUtils
	Private wrk_chat As ChatGPT
	
	'KEYBOARD
	Private ime As IME
	Private heightKeyboard As Int
	Private MaximumSize As Int = 0
	

	'CHAT
	Public txtQuestion As EditText
	Public imgSend As ImageView
	Public clvMessages As CustomListView
	Private panBottom As Panel
	Private pTopMenu As Panel
	Private lblTitleTopMenu As Label
	Private icMenuTopMenu As ImageView
	Private icConfigTopMenu As ImageView
	
	Private WaitingText As String = "Proccessing..."
	Private History 	As String
	
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
	Private webAnswer As WebView
	Private md As md2html
	
	Private webAnswerExtra As WebViewExtras
	Private jsi As DefaultJavascriptInterface
	
	Public AUTOSENDVOICE 		As Boolean = False
	Private panToolbar 			As B4XView
	Private chkCorrectEnglish 	As B4XView
	Private chkTranslate 		As CheckBox
	Private chkToFarsi 			As CheckBox
	Private chkVoiceLang 		As B4XView
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Parent As B4XView)
	
'	General.Set_StatusBarColor(Colors.RGB(89,89,89))
'	General.Set_StatusBarColor(Colors.RGB(51,129,232))
	General.Set_StatusBarColor(0xFF74A5FF)
	Parent.LoadLayout("Chat")
	
	ime.Initialize("ime")
	ime.AddHeightChangedEvent
	
'	History = "You are a helpful assistant."
	
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
	
	wrk_chat.Initialize
	
End Sub

Private Sub LoadCLVSetup
	
	Dim myStrings As List
		myStrings.Initialize
		myStrings.Add("What whould you like to know?")
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
		myStrings.Add("I can correct your English, just ask")
	
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
		LogColor("AdjustSize_Clv:" & LastException, Colors.Red)
	End Try
End Sub

Sub webAnswer_PageFinished (Url As String)
	LogColor("PageFinished", Colors.Blue)	
	webAnswerExtra.ExecuteJavascript("B4A.CallSub('SetWVHeight',true, document.documentElement.scrollHeight);")
End Sub

Sub SetWVHeight(height As String)
	LogColor("SetWVHeight: " & height & " : " & DipToCurrent(height), Colors.Green)
	
	If (DipToCurrent(height) > webAnswer.Height) Then
		webAnswerExtra.Height = DipToCurrent(height) + 1000
		webAnswer.Height = DipToCurrent(height) + 1000
	End If
	
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
					webAnswer.LoadHtml(md.mdTohtml(m.message, CreateMap("datetime":"today")))
					
					imgAnswer.Height = 3%y
					imgAnswer.Top = 0
					imgAnswer.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Puton.png", imgAnswer.Width, imgAnswer.Height, False)).Gravity = Gravity.CENTER
					
					'ADJUST VERTICAL
					Private TopMargin, BottomMargin As Int = 2%y
					Dim text As String = lblAnswer.Text
'					If (text.Length > 45) Then text = text & CRLF
					Dim t As Int
'					t = General.Size_textVertical(lblAnswer, text)
					t = General.Size_textVertical(lblAnswer, text) + BottomMargin
					LogColor("Length: " & text.Length, Colors.Blue)
					LogColor("H: " & t, Colors.Blue)
'					If (t > 150) Then
					webAnswer.Top = TopMargin + 1%y
					If (t > 80%y) Then
						webAnswer.Height = 70%y
					Else
						webAnswer.Height = t + 2%y
					End If
'					lblAnswer.Height = General.Size_textVertical(lblAnswer,lblAnswer.Text) + BottomMargin
'					lblAnswer.Top = TopMargin + 1%y
					
					'ADJUST HORIZONTAL
					Dim t As Int = General.Size_textHorizontal(lblAnswer,lblAnswer.Text)
					LogColor("H: " & t, Colors.Magenta)
					If (t < 130) Then
						webAnswer.Width = 50%x
						pnlAnswer.Width = webAnswer.Width + 4%x
						LogColor("W is smaller of 120", Colors.Cyan)
					Else If (t < 82%x) Then
'						lblAnswer.Width = General.Size_textHorizontal(lblAnswer,lblAnswer.Text)
'						lblAnswer.SingleLine = True
						webAnswer.Width = t
						pnlAnswer.Width = (webAnswer.Width + 4%x)
						LogColor("W is more than of 82%x", Colors.Yellow)
					Else
						webAnswer.Width = 90%x
						pnlAnswer.Width = webAnswer.Width + 4%x
						LogColor("Else Horizontal", Colors.Green)
					End If
					
					pnlAnswer.Height = webAnswer.Height + TopMargin + BottomMargin
					clvMessages.ResizeItem(i,pnlAnswer.Height)
					
					webAnswerExtra.Initialize(webAnswer)
					jsi.Initialize
					webAnswerExtra.AddJavascriptInterface(jsi,"B4A")
					pnlAnswer.Height = webAnswer.Height + 1000
					clvMessages.ResizeItem(i, pnlAnswer.Height)
				
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
	LogColor("clvMessages_ItemLongClick:" & Value, Colors.Blue)
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
	Else if (Main.voicer.IsSupported) Then
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
		csTitle.Color(Colors.White).Append("Dev by ").Color(Colors.LightGray).Clickable("csTitle", "site").Append("github.com/").Pop.Color(Colors.Yellow).Clickable("csTitle", "name").Underline.Append("Amm1rr").PopAll
		csTitle.EnableClickEvents(lblVersionText)
	lblVersionText.Text = csTitle
	
	pnlBackground.Visible = True
	pnlAbout.Visible = True
End Sub

Private Sub csTitle_Click (Tag As Object)
	
	' If the user clicked on
	' the word "Amm1rr" Tag is 1.

	Dim clicked As String = Tag.As(String)
	
	Select clicked
		Case "name":
			Dim x As XUI
				x.MsgboxAsync("Coded by M.Khani", ": )")
		
		Case "site":
			Dim p As PhoneIntents
			StartActivity(p.OpenBrowser("https://github.com/Amm1rr/"))
		'-- OR another way
'			Dim i As Intent
'				i.Initialize("i.ACTION_VIEW", "https://github.com/Amm1rr/")
'			StartActivity(i)
	End Select
End Sub

Sub setScrollBarEnabled(v As View, vertical As Boolean, horizontal As Boolean)
	Dim jo = v As JavaObject
		jo.RunMethod("setVerticalScrollBarEnabled"  , Array As Object (vertical  ))
		jo.RunMethod("setHorizontalScrollBarEnabled", Array As Object (horizontal))
End Sub

Public Sub imgSend_Click
	
	Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
'	LogColor("imgSend_Click:" & clvMessages.Size & " - " & msg.message, Colors.Magenta)
	If (msg.message = WaitingText) Then
		General.Size_textVertical(lblAnswer, lblAnswer.Text)
		General.Size_textHorizontal(lblAnswer, lblAnswer.Text)
		Return
	End If
	
	If (imgSend.Tag = "text") Then
		
		If (txtQuestion.Text.Trim.Length < 1) Then Return
		
		Dim sText As String
		Dim question As String
		Dim sAssistant As String
		
		If (chkCorrectEnglish.Checked) Then
			ResetAI
'			sText = "Correct Grammar improve to fluent English, and in output just show corrected text:" & CRLF
			sAssistant = "Correct grammar improves fluency in English and the output should only show the corrected text."
'			sAssistant = "You are an English grammar check and corrector."
		Else If (chkTranslate.Checked) Then
			ResetAI
'			sText = "Translate the following text to English:" & CRLF
			sAssistant = "You are a translator to English language."
		Else If (chkToFarsi.Checked) Then
			ResetAI
'			sText = "Translate the following text to Farsi:" & CRLF
			sAssistant = "You are a translator of the Farsi language, Translate the inputted text into Farsi and show only the correct result in the output."
		Else
			sAssistant = Null '"You are a helpful assistant."
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
		Ask(question, sAssistant)
		
	Else If Main.voicer.IsSupported Then	
		Log("imgSend_Click: Voice" & imgSend.Tag)
		
		Wait For (RecognizeVoice) Complete (Result As String)
		If (Result <> "") Then
			LogColor("Voice:" & Result, Colors.Blue)
			txtQuestion.Text = Result
			If (AUTOSENDVOICE) Then
				imgSend_Click
			Else
'				txtQuestion.SelectAll
			End If
		End If
		IME_HeightChanged(100%y, 0)
	
	Else
		LogColor("imgSend_Click: ELSE condition=> Voice:" & Result, Colors.Blue)
		imgSend.Tag = "text"
		imgSend_Click
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
	If (chkVoiceLang.Checked) Then
		Main.voicer.Language = "fa"
		Main.voicer.Prompt = "صحبت کنید"
	Else
		Main.voicer.Language = "en"
		Main.voicer.Prompt = "Speak Now"
	End If
	Main.voicer.Listen
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
		p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, 100%y)
'	If (clvMessages.Size > 0) Then
'		clvMessages.ReplaceAt(clvMessages.Size - 1, p, clvMessages.AsView.Width, m)
'	Else
'		m.message = WaitingText
		clvMessages.Add(p, m)
'	End If
	
	AdjustSize_Clv
	
End Sub

Sub HideKeyboard
	panBottom.Height = 7%y
	txtQuestion.Height = 7%y
	ime.HideKeyboard
End Sub

Public Sub Ask(question As String, assistant As String)
	
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
		p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width + 5%x, 15%y)
	clvMessages.Add(p, m)
	
	AdjustSize_Clv
	
	Wait For (wrk_chat.Query(assistant, question, History)) Complete (response As String)
'	History = History & CRLF & question 	'Me:
'	History = History & CRLF & response		'You:
	History = History & CRLF & question & CRLF & response		'You:
'	History = "You are a helpful assistant."
	
	clvMessages.RemoveAt(clvMessages.Size - 1)
	AdjustSize_Clv
	
	If (txtQuestion.Text.Length < 1) Then
		Select response
			Case wrk_chat.TimeoutText:
				txtQuestion.Text = question
			Case wrk_chat.OpenApiHostError:
				txtQuestion.Text = question
		End Select
	End If
	
'	Log("Ask:" & response)
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

Private Sub lblClearText_LongClick
	ResetAI
	ToastMessageShow("Session Reset.", False)
End Sub

Public Sub ResetAI
	wrk_chat.Initialize
	History = Null
'	History = "dynamic history of my and your replys in the chat: "
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
