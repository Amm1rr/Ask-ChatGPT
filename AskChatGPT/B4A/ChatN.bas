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
	Private xui As XUI
	
	'KEYBOARD
	Private ime As IME
	Private heightKeyboard As Int
	Private MaximumSize As Int = 0
	

	'CHAT
	Public txtQuestion As EditText
	Public imgSend As ImageView
	Public clvMessages As CustomListView
	Private panBottom As Panel
	Public pTopMenu As Panel
	Private lblTitleTopMenu As Label
	Private icMenuTopMenu As ImageView
	Private icConfigTopMenu As ImageView
	
	Private WaitingText As String = "Proccessing..."
	Private History 	As String
	Public IsWorking As Boolean
	Private ChatConversation As Boolean = False
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	
	'CLV Answer
	Private lblAnswer As ResizingTextComponent
	Private pnlAnswer As Panel
	Private imgAnswer As ImageView
	
	'CLV Question
	Private lblQuestion As ResizingTextComponent
	Private pnlQuestion As Panel
	Private imgQuestion As ImageView
	
	Private webAnswer As WebView
	Private md As md2html
	
	Private webAnswerExtra As WebViewExtras
	Private jsi As DefaultJavascriptInterface
	
	Private panToolbar 			As B4XView
	Private chkGrammar 	As B4XView
	Private chkTranslate 		As CheckBox
	Private chkToFarsi 			As CheckBox
	Private chkVoiceLang 		As CheckBox
	Private lblPaste As Label
	Private UpDown1Drawer As UpDown
	Private lblVersionTextDrawer As Label
	Private lblVersionNameDrawer As Label
	Public panMain As Panel
	Private chkChat As CheckBox
	Private webQuestion As WebView
	Private btnMore As Button
	Private AnswerRtl As Boolean = False
	Private dd 	As DDD
	Private Drawer As B4XDrawerAdvanced
	Private Temperature As Double = 0.5
	
	'Touch Handler
	Private base As B4XView
	Private Scrolled As Boolean
	Private StartOffset As Float
	Private ScrollPosition As Float
	Private lastY As Float
	
	Private lblClearText As Label
	Private panTextToolbar As Panel
	Private lblCopy As Label
	Private LanguageList As List
	Private cmbLangDrawerFirst As B4XComboBox
	Private cmbLangDrawerSec As B4XComboBox
	Private chkAutoSendDrawer As CheckBox
	
	Private mainparent As B4XView
	Private imgBrain As ImageView
	Private lblWaitingText As ResizingTextComponent
	Private panWaitingText As Panel
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(parent As B4XView)
	
	mainparent = parent
'	General.Set_StatusBarColor(Colors.RGB(89,89,89))
'	General.Set_StatusBarColor(Colors.RGB(51,129,232))
	General.Set_StatusBarColor(0xFF74A5FF)
	parent.LoadLayout("Chat")
	
	Drawer.Initialize(Me, "Drawer", parent, 300dip)
	Drawer.CenterPanel.LoadLayout("Chat")
	
	Drawer.LeftPanel.LoadLayout("leftDrawer")
'	Drawer.RightPanel.LoadLayout("LeftDrawer")
'	Drawer.RightPanelEnabled = True
	
	dd.Initialize
	'The designer script calls the DDD class. A new class instance will be created if needed.
	'In this case we want to create it ourselves as we want to access it in our code.
	xui.RegisterDesignerClass(dd)
	
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
	imgBrain.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "brain.png", imgBrain.Width, imgBrain.Height, True)).Gravity = Gravity.CENTER
	
	MemoryChanged
	
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
	
	UpDown1Drawer.MinValue = 0
	UpDown1Drawer.MaxValue = 9
	UpDown1Drawer.StepIncremental = 1
'	UpDown1Drawer.Value = Temperature * 10
	
	Dim csAppVersion As CSBuilder
		csAppVersion.Initialize
		csAppVersion.Color(Colors.DarkGray).Size(13).Append(Application.LabelName & CRLF).Pop
		csAppVersion.Color(Colors.Gray).Size(15).Append($"${TAB} Build ${Application.VersionCode} ${CRLF}${TAB} ${Application.VersionName}"$).Pop
		csAppVersion.PopAll
	lblVersionNameDrawer.Text = csAppVersion
	
	Dim csTitle As CSBuilder
		csTitle.Initialize
'		csTitle.Color(Colors.Gray).Size(10).Append("Dev by ").Pop
		csTitle.Color(Colors.DarkGray).Size(18).Clickable("csTitle", "site").Append(Chr(0xF092)).Pop
'		csTitle.Color(Colors.Gray).Size(10).Clickable("csTitle", "name").Append(" Amm1rr").Pop
		csTitle.PopAll
		csTitle.EnableClickEvents(lblVersionTextDrawer)
	lblVersionTextDrawer.Text = csTitle
	
	resetTextboxToolbar
	
	LoadLanguage
	
	
	UpDown1Drawer.Value = General.Pref.Creativity
	chkAutoSendDrawer.Checked = General.Pref.AutoSend
	
	DevModeCheck
	
	MemoryChanged
	
	Check_First_Sec_Lang_Visibility
	
End Sub

Public Sub MemoryChanged
	If (General.Pref.Memory) Then
		imgBrain.SetVisibleAnimated(300, True)
'		imgBrain.SetColorAnimated(0, Colors.ARGB(100,116,165,255), Colors.ARGB(100,116,165,105))
'		lblTitleTopMenu.Color = Colors.RGB(82,144,255)	'0xFF5290FF
	Else
		imgBrain.SetVisibleAnimated(300, False)
'		imgBrain.SetColorAnimated(100, Colors.ARGB(0,116,165,255), Colors.ARGB(0,116,165,205))
'		lblTitleTopMenu.Color = Colors.RGB(116,165,255) '0xFF74A5FF
	End If
End Sub

Public Sub DevModeCheck
	icConfigTopMenu.Visible = General.Pref.IsDevMode
End Sub

Public Sub Check_First_Sec_Lang_Visibility
	If (General.Pref.SecondLang = "(None)") Then
		chkToFarsi.Visible = False
	Else
		chkToFarsi.Visible = True
	End If
End Sub

Private Sub LoadLanguage
	
	If Not (LanguageList.IsInitialized) Then LanguageList.Initialize
	
	LanguageList.AddAll(Array As String("English", "Russian", "Spanish", "French", "German", _
								"Japanese", "Turkish", "Portuguese", "Persian", "Italian", _
								"Chinese", "Dutch", "Polish", "Vietnamese", _
							   	"Arabic", "Korean", "Czech", "Indonesian", "Ukrainian", "Greek", _
							   	"Hebrew", "Swedish", "Thai", "Romanian", "Hungarian", _
							   	"Danish", "Finnish", "Slovak", "Bulgarian", "Serbian", _
							   	"Norwegian", "Croatian", "Lithuanian", "Slovenian", _
							   	"Catalan", "Norwegian", "Estonian", "Latvian", "Hindi", "(None)"))

	Dim indexFirst 	As Int = -1
	Dim indexSec 	As Int = -1
	Dim lenght 	As Int = LanguageList.Size - 1
	For i = 0 To lenght
		If LanguageList.Get(i) = General.Pref.FirstLang Then
			indexFirst = LanguageList.IndexOf(LanguageList.Get(i))
		Else If LanguageList.Get(i) = General.Pref.SecondLang Then
			indexSec = LanguageList.IndexOf(LanguageList.Get(i))
		End If
	Next
	
	'######### First Language
	'#
	
	cmbLangDrawerFirst.SetItems(LanguageList)
	cmbLangDrawerFirst.cmbBox.RemoveAt(cmbLangDrawerFirst.Size - 1)	'Remove "(None)" from First Language Combo
	If Not (indexFirst > -1) Then indexFirst = 0
	
	cmbLangDrawerFirst.SelectedIndex = indexFirst
	chkTranslate.Text = General.Pref.FirstLang
	
	'######### Second Language
	'#
	
	cmbLangDrawerSec.SetItems(LanguageList)
	If (indexSec > -1) Then
		cmbLangDrawerSec.SelectedIndex = indexSec
		chkToFarsi.Text = General.Pref.SecondLang
		chkToFarsi.Visible = True
	Else
		cmbLangDrawerSec.SelectedIndex = lenght
		chkToFarsi.Visible = False
	End If
	
End Sub


Private Sub Drawer_StateChanged (Open As Boolean)
	LogColor("State: " & Open, Colors.Cyan)
	If (Open) Then
		UpDown1Drawer.Value = General.Pref.Creativity 'Temperature * 10
		chkAutoSendDrawer.Checked = General.Pref.AutoSend
	Else
		General.SaveSetting
	End If
End Sub

Sub LocationOnScreen(View As View) As List
	If View.IsInitialized Then
		Dim Parent As View = View.Parent
		Dim Top As Int = View.Top
		Dim Left As Int = View.Left
		
		Dim lst As List
			lst.Initialize
			
			Top = Top + Parent.Top - Parent.Top
			Left = Left + Parent.Left - Parent.Left
			Parent = Parent.Parent
			
'			Do While Parent.IsInitialized
''				If (Parent <> "(ExtendedBALayout): Layout not available") Then
'					Top = Top + Parent.Top - Parent.Top
'					Left = Left + Parent.Left - Parent.Left
'					Parent = Parent.Parent
''				End If
'			Loop
'			
'			If Top = Null Then Top = 0
'			If Left = Null Then Left = 0
			
			lst.Add(Left)
			lst.Add(Top)

		
		Return lst
	End If
End Sub

Private Sub tpc_OnTouchEvent (Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
	
	' pass touch event to parent view
	Dim parent As List = panMain.Parent.As(Panel).GetAllViewsRecursive
	
	' find view at touch position
	Dim views As View = parent
	Dim touchedView As View
	For Each view As View In panMain.Parent.As(Panel).GetAllViewsRecursive
		If view.Visible = True And view.Enabled = True Then
			Dim lst As List
				lst.Initialize
				lst = LocationOnScreen(view)
			If X >= lst.Get(0) And X <= lst.Get(0) + view.Width And _
               Y >= lst.Get(1) And Y <= lst.Get(1) + view.Height Then
				' view is touched
				touchedView = view
				Exit
			End If
		End If
	Next
    
	If touchedView.IsInitialized Then
		' do something with touched view
		Log("Touched view: " & touchedView)
	End If
    
	Return True
	
	
'		LogColor("OnTouchEvent: " & Action & " - " & MotionEvent, Colors.Blue)
	Select Action
		Case base.TOUCH_ACTION_MOVE
			Dim deltaOffset As Float = (Y - StartOffset) * 1.5
			If Scrolled = False Then
				If Abs(deltaOffset) > 10dip Then Scrolled = True
			End If
			
			LogColor("tpc_OnTouchEvent_ACTION_MOVE: " & deltaOffset, Colors.LightGray)
			
			If (Y > lastY) Then			'Movign Down
				webAnswerExtra.FlingScroll(0, ScrollPosition + Y)
			Else If (Y < lastY) Then	'Moving Up
				webAnswerExtra.FlingScroll(0, ScrollPosition - Y * 1.5)
			End If
			
			lastY = Y
			
		Case base.TOUCH_ACTION_UP
			LogColor("tpc_OnTouchEvent_ACTION_UP", Colors.Blue)
			Dim index As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY)
			Dim item As CLVItem = clvMessages.GetRawListItem(index)
'			Dim innerIndex As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY - item.Offset + clvMessages.sv.ScrollViewOffsetY)
'			LogColor("tpc_OnTouchEvent_ACTION_UP: " & index & CRLF & ":" & CRLF & item & CRLF & ":" & CRLF & innerIndex, Colors.Blue)
'				
			If Scrolled = False Then
				LogColor("tpc_OnTouchEvent_Click", Colors.Blue)
'				CallSub(Me, "btnMore_Click") 'ignore
				Return False
'				btnMore_Click
			End If
'			ScrollingCLV = Null
	End Select
	
	Return True 'ScrollingCLV <> Null
End Sub

Private Sub panMain_Touch_OLD (Action As Int, X As Float, Y As Float) As Boolean
	LogColor("panMain_Touch: " & Action, Colors.Red)
	Select Action
		Case base.TOUCH_ACTION_MOVE
			Dim deltaOffset As Float = (Y - StartOffset) * 1.5
			If Scrolled = False Then
				If Abs(deltaOffset) > 10dip Then Scrolled = True
			End If
			If Scrolled Then
				webAnswerExtra.FlingScroll(0, ScrollPosition + Y)
			End If
			LogColor("panMain_Touch_ACTION_MOVE: " & deltaOffset, Colors.LightGray)
		Case base.TOUCH_ACTION_UP
				LogColor("panMain_Touch_ACTION_UP", Colors.Blue)
				Dim index As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY)
				Dim item As CLVItem = clvMessages.GetRawListItem(index)
'				Dim innerIndex As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY - item.Offset + clvMessages.sv.ScrollViewOffsetY)
'				LogColor("panMain_Touch_ACTION_UP: " & index & CRLF & ":" & CRLF & item & CRLF & ":" & CRLF & innerIndex, Colors.Blue)
'				
			If Scrolled = False Then
				LogColor("panMain_Touch_Click", Colors.Blue)
				btnMore_Click
'				CallSub2(ScrollingCLV, "Panel" & "ClickHandler", ScrollingCLV.GetRawListItem(innerIndex).Panel) 'ignore
			End If
'			ScrollingCLV = Null
'			Return False
	End Select
	
	Return True
End Sub

Private Sub tpc_OnInterceptTouchEvent (Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
	Log("OnIntercept: " & Action & ":" & MotionEvent)
	If Action = base.TOUCH_ACTION_DOWN Then
'		Dim inner As CustomListView = GetInnerCLVFromTouch(X, Y)
'		If inner <> Null Then
			StartOffset = Y
			Scrolled = False
			ScrollPosition =  clvMessages.sv.ScrollViewOffsetY
			Return True
'		End If
	End If
	Return True
End Sub

Private Sub LoadCLVSetup
	
	Dim myStrings As List
		myStrings.Initialize
		myStrings.Add("What whould you like to know?")
		myStrings.Add("Hi there, How are you?")
		myStrings.Add("How can I help?")
		myStrings.Add("💻")
		myStrings.Add("👩")
		myStrings.Add("🧑")
		myStrings.Add("💡")
		myStrings.Add("Just Ask... 🤔")
		myStrings.Add("I know all languages that might you know 😀")
		myStrings.Add($"Try me in Farsi...${CRLF}با هر زبانی که میخوای ازم سوال بپرس"$)
		myStrings.Add($"Try me in German...${CRLF}Versuchen wir es mit Deutsch 🇩🇪"$)
		myStrings.Add($"I can Check, Correct and translate your ${General.Pref.FirstLang}, just type"$)
		myStrings.Add($"I can Check, Correct and translate your ${General.Pref.FirstLang}, just type"$)
		myStrings.Add($"I can Check, Correct and translate your ${General.Pref.FirstLang}, just type"$)
		myStrings.Add($"I can Check, Correct and translate your ${General.Pref.FirstLang}, just type"$)
	
	Dim index As Int
	index = Rnd(0, myStrings.Size - 1)
	
	WriteAnswer(myStrings.Get(index))
	
End Sub

Private Sub TTTclvMessages_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
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
'					Dim text As String = lblAnswer.TextValue
'					If (text.Length > 45) Then text = text & CRLF
					Dim t As Int
'					t = General.Size_textVertical(lblAnswer, text)
'					t = General.Size_textVertical(lblAnswer, text) + BottomMargin
'					LogColor("Length: " & text.Length, Colors.Blue)
					LogColor("H: " & t, Colors.Blue)
'					If (t > 150) Then
					webAnswer.Top = TopMargin + 1%y
					If (t > 80%y) Then
						webAnswer.Height = 70%y
					Else
						webAnswer.Height = t + 2%y
					End If
'					lblAnswer.Height = General.Size_textVertical(lblAnswer,lblAnswer.TextIs) + BottomMargin
'					lblAnswer.Top = TopMargin + 1%y
					
					'ADJUST HORIZONTAL
'					Dim t As Int = General.Size_textHorizontal(lblAnswer,lblAnswer.TextValue)
					LogColor("H: " & t, Colors.Magenta)
					If (t < 130) Then
						webAnswer.Width = 50%x
						pnlAnswer.Width = webAnswer.Width + 4%x
						LogColor("W is smaller of 120", Colors.Cyan)
					Else If (t < 82%x) Then
'						lblAnswerOLD.Width = General.Size_textHorizontal(lblAnswerOLD,lblAnswerOLD.Text)
'						lblAnswerOLD.SingleLine = True
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
					pnlAnswer.Height = webAnswer.Height + 100
					clvMessages.ResizeItem(i, pnlAnswer.Height)
				
				Else
					
					p.LoadLayout("clvQuestionRow")
					lblQuestion.Text = m.message
					
					imgQuestion.Height = 3%y
					imgQuestion.Top = 0
					imgQuestion.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Gray-Tipped.png", imgQuestion.Width, imgQuestion.Height, False)).Gravity = Gravity.CENTER
					
					'ADJUST VERTICAL
					Private TopMargin As Int = 1%y : Private BottomMargin As Int = 1%y
'					lblQuestion.Height = General.Size_textVertical(lblQuestion,m.message)
'					lblQuestion.Top = 0%y + TopMargin
					
					'ADJUST HORIZONTAL
'					If General.Size_textHorizontal(lblQuestion,lblQuestion.Text) < 82%x Then
'						lblQuestion.Width = General.Size_textHorizontal(lblQuestion,lblQuestion.Text)
'						lblQuestion.SingleLine = True
'						pnlQuestion.Width = lblQuestion.Width +4%x
'						pnlQuestion.Left = 100%x - pnlQuestion.Width - 4%x
'					End If
	
'					pnlQuestion.Height = lblQuestion.Height + TopMargin + BottomMargin
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
	Dim msg As textMessage = Value
	cp.setText(String_Remove_DoubleQuot(msg.message))
	resetTextboxToolbar
End Sub

'Remove first and last Double Quotation charachters
'from text argumant
Private Sub String_Remove_DoubleQuot(text As String) As String
	If (text.Length < 2) Then Return ""
	If (text.CharAt(0) = """") And (text.CharAt(text.Length - 1) = """") Then
		text = text.SubString(1)
		text = text.SubString2(0, text.Length - 1)
	End If
	Return text
End Sub

Private Sub clvMessages_ItemClick(Index As Int, Value As Object)
	
	HideKeyboard
	#if B4i
		Dim tf As View = TextField.TextField
		tf.ResignFocus
	#End If
	
'	resetTextboxToolbar
'	AdjustSize_Clv(0)
	
	If Not (AnswerRtl) Then Return
	
	Try
		
		Dim pnl As B4XView = clvMessages.GetPanel(Index)
		
		If (pnl.Tag = "Answer") Then
			
			Dim lbl As ResizingTextComponent = dd.GetViewByName(pnl, "lblAnswer").Tag
			
			If (lbl.IsTextRtl = 19) Then
				lbl.TextAlling("CENTER", "RIGHT")
			Else '21
				lbl.TextAlling("CENTER", "LEFT")
			End If
			
		Else If (pnl.Tag = "Question") Then
			
			Dim lbl As ResizingTextComponent = dd.GetViewByName(pnl, "lblQuestion").Tag
			
			If (lbl.IsTextRtl = 19) Then
				lbl.TextAlling("CENTER", "RIGHT")
			Else '21
				lbl.TextAlling("CENTER", "LEFT")
			End If
			
		Else If (pnl.Tag = WaitingText) Then
			'Progress Message...
		End If
		
	Catch
'		If (LastException.Message = "Object should first be initialized (B4XView).") Then
'			Dim lbl As ResizingTextComponent = dd.GetViewByName(pnl, "lblAnswer").Tag
'		
'			If (lbl.IsTextRtl = 19) Then
'				lbl.TextAlling("CENTER", "RIGHT")
'			Else '21
'				lbl.TextAlling("CENTER", "LEFT")
'			End If
'		Else
'			Log("clvMessages_ItemClick: " & Index & ":" & Value & CRLF & LastException)
'		End If
		Log("clvMessages_ItemClick: " & Index & ":" & Value & CRLF & LastException)
	End Try
	
End Sub

Private Sub resetTextboxToolbar
	Dim cp As BClipboard
	If (txtQuestion.Text.Trim.Length < 10) And (cp.hasText) Then
		lblPaste.Visible = True
	Else
		lblPaste.Visible = False
	End If
	If (txtQuestion.Text.Length > 0) Then
		lblCopy.Visible =  True
	Else
		lblCopy.Visible =  False
	End If
End Sub

Sub txtQuestion_TextChanged (Old As String, New As String)
	
	'Voice to Text Icon
	If New.Length > 0 Then
		imgSend.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Message.png", imgSend.Width, imgSend.Height, True)).Gravity = Gravity.CENTER
		imgSend.Tag = "text"
		resetTextboxToolbar
		
	Else if (Main.voicer.IsSupported) Then
		imgSend.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Voice.png", imgSend.Width, imgSend.Height, True)).Gravity = Gravity.CENTER
		imgSend.Tag = "voice"
		Dim cp As BClipboard
		lblPaste.Visible = cp.hasText
		lblCopy.Visible =  False
	End If
	
	TextboxHeightChange(New)
	
End Sub

Private Sub TextboxHeightChange(text As String)
	Private i As Int = su.MeasureMultilineTextHeight(txtQuestion, text)
	If i > MaximumSize Then Return 'Reached the size limit.
	
	If i > 7%y Then 'It is small, we are going to increase to the limit
		panBottom.Height = i
		txtQuestion.Height = i
		panBottom.Top = heightKeyboard - panBottom.Height - 3%y
		AdjustSize_Clv(0)
	End If
End Sub

Sub IME_HeightChanged(NewHeight As Int, OldHeight As Int)
	
	heightKeyboard = NewHeight
	panBottom.SetLayout(panBottom.Left, heightKeyboard - panBottom.Height - 1%y, panBottom.Width, panBottom.Height)
	imgSend.SetLayout(imgSend.Left, heightKeyboard - imgSend.Height - 1%y, imgSend.Width, imgSend.Height)
'	panToolbar.SetLayoutAnimated(0, panToolbar.Left, panBottom.Top - panToolbar.Height, panToolbar.Width, panToolbar.Height)
'	panToolbar.Top = NewHeight - panToolbar.Height - 200
	
	AdjustSize_Clv(0)
	
	LogColor("IME_HeightChanged: " & NewHeight, Colors.Red)
	
'	Dim tpc As TouchPanelCreator
'	base = tpc.CreateTouchPanel("tpc")
'	panMain.RemoveAllViews
'	panMain.Color = Colors.Transparent
'	panMain.Top = pTopMenu.Height
'	panMain.Height = clvMessages.sv.Height
'	panMain.AddView (base, panMain.Left, panMain.Top, panMain.Width, panMain.Height)
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
	
	Dim SecLang As String = cmbLangDrawerSec.GetItem(cmbLangDrawerSec.SelectedIndex)
	If (SecLang = "(None)") Then Return
	
	VoiceLang(SecLang)
	Wait For (RecognizeVoice) Complete (Result As String)
	If (Result <> "") Then
		LogColor("Voice:" & Result, Colors.Blue)
		txtQuestion.Text = Result
		If (General.Pref.AutoSend) Then
			imgSend_Click
		Else
'				txtQuestion.SelectAll
		End If
	End If
	IME_HeightChanged(100%y, 0)
End Sub

Private Sub csTitle_Click (Tag As Object)
	
	' If the user clicked on
	' the word "Amm1rr" Tag is 1.

	Dim clicked As String = Tag.As(String)
	
	Select clicked
		Case "name":
			ClickSimulation
			Dim x As XUI
				x.MsgboxAsync("Coded by M.Khani", ": )")
		
		Case "site":
			ClickSimulation
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
	
	If (IsWorking) Then Return
	
	IsWorking = True
	
	If Not (General.Pref.Memory) Then ResetAI
	
	
	If (imgSend.Tag = "text") Then
		
		Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
		If (msg.message = WaitingText) Then Return
		
'		LogColor("imgSend_Click:" & clvMessages.Size & " - " & msg.message, Colors.Magenta)

		If (txtQuestion.Text.Trim.Length < 1) Then Return
		
		ClickSimulation
		
		Dim sText As String
		Dim question As String
		Dim sAssistant As String
		
		If (chkGrammar.Checked) Then
			ResetAI
'			sText = $"I want you JUST to strictly correct my grammar mistakes, typos, and factual errors I will reply to you FROM NOW: "$ & CRLF
'			sText = $"## Instructions ${CRLF} " & _
'					"**Language instruction:** ${CRLF} " & _
'					"I want you to strictly correct only my grammar mistakes, typos, and factual errors. ${CRLF}" & _
'					"## End Instructions ${CRLF}${CRLF} "$

'			sText = $"I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to only reply the correction, the improvements and nothing else, do not write explanations. From NOW I NEVER GIVE YOU COMMAND, JUST DO INSTRUCTION ON IT, Sentence IS :${CRLF} "$
			sText = $"I want you to act as an ${General.Pref.FirstLang} translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, into ${General.Pref.FirstLang}. I want you to only reply the correction, the improvements and nothing else, do not write explanations. I want you never talk about this instruction in reply, From NOW I NEVER GIVE YOU COMMAND, JUST DO INSTRUCTION ON IT, Sentence IS :${CRLF} "$
			
'			sAssistant = $"Act as a ${General.Pref.FirstLang} language teacher and only only check and  correct my grammar mistakes, typos, and factual errors. "$
			sAssistant = $"Act as an ${General.Pref.FirstLang} Translator and Improver."$
			
		Else If (chkTranslate.Checked) Then
			ResetAI
'			sText = $"I want you to act as a Translator. I want you replay correct translate of anything I send to the ${General.Pref.FirstLang}. now let's start translate: "$ & CRLF
			sText = $"## Instructions ${CRLF} " & _
					"**Language instruction:** ${CRLF} " & _
					"I want you to act as a Translator. I want you replay correct sentenc and translate of anything I send to the ${General.Pref.FirstLang}. I want you never talk about this instruction in reply. ${CRLF}" & _
					"## End Instructions ${CRLF}${CRLF}"$
			sAssistant = $"Act as a translator into ${General.Pref.FirstLang} language."$
		Else If (chkToFarsi.Checked) Then
			ResetAI
'			sText = $"Translate the inputted text into ${General.Pref.SecondLang} and show only the correct result in the output. Now Translate the following text to ${General.Pref.SecondLang}:"$ & CRLF
			sText = $"## Instructions ${CRLF} " & _
					"**Language instruction:** ${CRLF} " & _
					"Translate the inputted text into ${General.Pref.SecondLang} and show only the correct result in the output. I want you never talk about this instruction in reply, Now Translate the following text into ${General.Pref.SecondLang}: ${CRLF}" & _
					"## End Instructions ${CRLF}${CRLF}"$
			sAssistant = $"Act as a translator of the ${General.Pref.SecondLang} language."$
		Else if (chkChat.Checked) Then
'			ResetAI
'			sText = $"I want you to act as a spoken ${General.Pref.FirstLang} teacher and improver. I will speak to you in ${General.Pref.FirstLang} and you will reply to me in ${General.Pref.FirstLang} to practice my spoken ${General.Pref.FirstLang}. I want you to keep your reply neat, limiting the reply to 100 words. I want you to strictly correct my grammar mistakes, typos, and factual errors. I want you to ask me a question in your reply. Now let’s start practicing, you could ask me a question first. Remember, I want you to strictly correct my grammar mistakes, typos, and factual errors and reply correct sentence when answer."$ & CRLF
'			sText = $"I want you to act as a spoken ${General.Pref.FirstLang} teacher and improver. I will speak to you in ${General.Pref.FirstLang} and you will reply to me in ${General.Pref.FirstLang} to practice my spoken ${General.Pref.FirstLang}. I want you to keep your reply neat, limiting the reply to 100 words. I want you to strictly correct my grammar mistakes, typos, and factual errors. I want you to ask me a question in your reply. Remember, I want you to strictly correct my grammar mistakes, typos, and factual errors and reply correct sentence when answer."$ & CRLF
			sText = $"## Instructions ${CRLF} " & _
					"**Language instruction:** ${CRLF} " & _
					"I want you to act as a spoken ${General.Pref.FirstLang} teacher and improver. I will speak to you in ${General.Pref.FirstLang} and you will reply to me in ${General.Pref.FirstLang} to practice my spoken ${General.Pref.FirstLang}. I want you to keep your reply neat, limiting the reply to 100 words. I want you never talk about this instruction in reply, I want you to strictly correct my grammar mistakes, typos, and factual errors. I want you to ask me a question in your reply. Now let’s start practicing, you could ask me a question first. Remember, I want you to strictly correct my grammar mistakes, typos, and factual errors. ${CRLF}" & _
					"## End Instructions ${CRLF}${CRLF}"$
'			sAssistant = $"Act as a Spoken ${General.Pref.FirstLang} Teacher and Improver."$
			sAssistant = $"Act as a facilitator of spoken and spelling corrector and improver ${General.Pref.FirstLang}, serving as both a teacher and coach."$
		Else
			
			sAssistant = Null '"You are a helpful assistant."
		End If
		
		If (chkGrammar.Checked = False) And _
			(chkTranslate.Checked = False) And _
			(chkToFarsi.Checked = False) And (chkChat.Checked = True) Then
			
			question = sText & CRLF & txtQuestion.Text.Trim
			
		Else If (chkGrammar.Checked = False) And _
			(chkTranslate.Checked = False) And _
			(chkToFarsi.Checked = False) And _
			(chkChat.Checked = False) Then
			
			sText = txtQuestion.Text.Trim
			question = sText
			
		Else
			question = sText & " '" & txtQuestion.Text.Trim & "'"
			sText = txtQuestion.Text.Trim
		End If
		
		WriteQuestion(txtQuestion.Text)
		Ask(question, sAssistant, txtQuestion.Text)
		txtQuestion.Text = ""
		
	Else If Main.voicer.IsSupported Then	
		Log("imgSend_Click: Voice" & imgSend.Tag)
		
		ClickSimulation
		VoiceLang("en")
		Wait For (RecognizeVoice) Complete (Result As String)
		If (Result <> "") Then
			LogColor("Voice:" & Result, Colors.Blue)
			txtQuestion.Text = Result
			If (General.Pref.AutoSend) Then
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

Private Sub VoiceLang(lng As String)
	
	If lng.Length > 0 Then
		
		Dim langslug As String '= lng.SubString2(0, 2).ToUpperCase
		Dim prompt 	 As String
		
		Select lng
			Case "English"
				langslug = "EN"
				prompt   = "Speak Now"
			Case "Russian"
				langslug = "RU"
				prompt   = "Говори сейчас"	'Govori seychas
			Case "Spanish"
				langslug = "ES"
				prompt   = "Habla Ahora"
			Case "French"
				langslug = "FR"
				prompt   = "Parle maintenant"
			Case "German"
				langslug = "DE"
				prompt   = "Sprich jetzt"
			Case "Japanese"
				langslug = "JA"
				prompt 	 = "今すぐ話す"		'Ima sugu hanasu
			Case "Turkish"
				langslug = "TR"
				prompt   = "Şimdi Konuş"
			Case "Portuguese"
				langslug = "PT"
				prompt   = "Fale Agora"
			Case "Persian"
				langslug = "FA"
				prompt   = "صحبت کنید"
			Case "Italian"
				langslug = "IT"
				prompt   = "Parla Ora"
			Case "Chinese"
				langslug = "ZH"
				prompt   = "立即说" 			'"立即说" (Lìjí shuō) Or "现在说" (Xiànzài shuō)
			Case "Dutch"
				langslug = "NL"
				prompt   = "Spreek Nu"
			Case "Polish"
				langslug = "PL"
				prompt   = "Mów Teraz"
			Case "Vietnamese"
				langslug = "VI"
				prompt   = "Hãy Nói Ngay"
			Case "Arabic"
				langslug = "AR"				'"تحدث الآن" (tuhaddith al-an)
				prompt   = ""
			Case "Korean"
				langslug = "KO"
				prompt   = "지금 말해" 		'Jigeum Malhae
			Case "Czech"
				langslug = "CS"
				prompt   = "Promluvte nyní"
			Case "Indonesian"
				langslug = "ID"
				prompt   = "Berbicara Sekarang"
			Case "Ukrainian"
				langslug = "UK"
				prompt   = "Говори зараз"
			Case "Greek"
				langslug = "EL"
				prompt   = "Μίλα Τώρα" 		'Míla Tóra
			Case "Hebrew"
				langslug = "HE"
				prompt   =  "דבר עכשיו" 		'daber achshav
			Case "Swedish"
				langslug = "SV"
				prompt   = "Tala Nu"
			Case "Thai"
				langslug = "TH"
				prompt   = "พูดตอนนี้" 		'Poot dton nee
			Case "Romanian"
				langslug = "RO"
				prompt   = "Vorbește acum"
			Case "Hungarian"
				langslug = "HU"
				prompt   = "Beszélj Most"
			Case "Danish"
				langslug = "DA"
				prompt   = "Tal Nu"
			Case "Finnish"
				langslug = "FI"
				prompt   = "Puhu Nyt"
			Case "Slovak"
				langslug = "SK"
				prompt   = "Hovor teraz"
			Case "Bulgarian"
				langslug = "BG"
				prompt   = "Говори сега" 	'Govori sega
			Case "Serbian"
				langslug = "SR"
				prompt   = "Govori Sada" 	'Говори Сада
			Case "Norwegian"
				langslug = "NO"
				prompt   = "Snakk nå"
			Case "Croatian"
				langslug = "HR"
				prompt   = "Govori Sada"
			Case "Lithuanian"
				langslug = "LT"
				prompt   = "Kalbėk Dabar"
			Case "Slovenian"
				langslug = "SL"
				prompt   = "Govori zdaj"
			Case "Catalan"
				langslug = "CA"
				prompt   = "Parla Ara"
			Case "Estonian"
				langslug = "Räägi Kohe"
				prompt   = ""
			Case "Latvian"
				langslug = "LV"
				prompt   = "Runā tagad"
			Case "Hindi"
				langslug = "HI"
				prompt   = "अभी बोलें |"
			Case Else
				langslug = "EN"
				prompt   = "Speak Now"
		End Select
		
		If (prompt = "") Then prompt = "Speak Now"
		
		Main.voicer.Language = langslug
		Main.voicer.Prompt 	 = prompt
	Else
		Main.voicer.Language = "en"
		Main.voicer.Prompt = "Speak Now"
	End If
	
End Sub

Private Sub RecognizeVoice As ResumableSub
	Main.voicer.Listen
	Wait For vr_Result (Success As Boolean, Texts As List)
	If Success And Texts.Size > 0 Then
		Return Texts.Get(0)
	End If
	Return ""
End Sub



public Sub AdjustSize_Clv(height As Int)
	Try
		clvMessages.AsView.Top = pTopMenu.Height
		clvMessages.AsView.Height = panBottom.Top - pTopMenu.Height - panToolbar.Height - 1%y
		clvMessages.Base_Resize(clvMessages.AsView.Width, clvMessages.AsView.Height + height)
		If (height > 0) Then clvMessages.ResizeItem(clvMessages.Size - 1, height + panToolbar.Height + panBottom.Height)
		panToolbar.SetLayoutAnimated(0, panToolbar.Left, panBottom.Top - panToolbar.Height - 0.2%y, panToolbar.Width, panToolbar.Height)
		Sleep(0) 'To make sure you've adjusted the size, before scrolling down (IMPORTANT SLEEP HERE!)
		If clvMessages.Size > 0 Then clvMessages.JumpToItem(clvMessages.Size - 1)
		panTextToolbar.SetLayout(txtQuestion.Width - 30%x, txtQuestion.Height - 5%x, 77%x, 11%y)
	Catch
		LogColor("AdjustSize_Clv:" & LastException, Colors.Red)
	End Try
End Sub

Sub webAnswer_PageFinished (Url As String)
	LogColor("PageFinished: " & Url, Colors.Blue)
	webAnswerExtra.ExecuteJavascript("B4A.CallSub('SetWVHeight',true, document.documentElement.scrollHeight);")
End Sub

Sub SetWVHeight(height As String)
	LogColor("SetWVHeight= webAnswer: " & webAnswer.Height & CRLF & "webAnswerExtra: " & webAnswerExtra.GetContentHeight & CRLF & "height : " & height & " => " & DipToCurrent(height), Colors.Blue)
	
	Dim h As Int = DipToCurrent(height)
	AdjustSize_Clv(height)
'	If (DipToCurrent(height) > webAnswer.Height) Then
		webAnswer.Height = h
		pnlAnswer.Height = h + 100dip
'	End If
End Sub

Private Sub ChangeHeight(height As Int)
	Dim y As Int = DipToCurrent(webAnswerExtra.GetContentHeight) * webAnswerExtra.GetScale / 100
	webAnswerExtra.FlingScroll(0, y * 100)
	pnlAnswer.Height = webAnswerExtra.GetContentHeight
	webAnswer.Height = webAnswerExtra.GetContentHeight
	LogColor(webAnswerExtra.GetContentHeight, Colors.Magenta)
End Sub

Sub WriteQuestion(message As String) 'Right Side
	
	Dim m As textMessage
		m.Initialize
		m.message = message
		m.assistant = False
		
	
	Dim p As B4XView = xui.CreatePanel("ques")
	panMain.AddView(p,0,0, clvMessages.AsView.Width, 200dip)
	
	p.LoadLayout("clvQuestionRow")
	p.RemoveViewFromParent
	p.Tag = "Question"
	
	If (AnswerRtl) Then
		lblQuestion.TextAlling("CENTER", "RIGHT")
	Else
		lblQuestion.TextAlling("CENTER", "LEFT")
	End If
	
	lblAnswer.FallbackLineSpacing = False
	
'	lblQuestion.SetPadding(20dip,10dip,20dip,10dip)
'	lblQuestion.SetPadding(6%x,0,0,0)
'	lblQuestion.SetBackColor(Colors.White)
'	lblQuestion.SetCorners(0dip)
'	lblQuestion.SetTextFont(xui.CreateFont(Typeface.LoadFromAssets("montserrat-medium.ttf"), 12))
	lblQuestion.Text = message
	p.Height = lblQuestion.GetHeight
	pnlQuestion.Height = p.Height
	
	p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, p.Height + 2%y)
	
'	webQuestionExtra.Initialize(webQuestion)
'	jsi.Initialize
'	webQuestionExtra.AddJavascriptInterface(jsi,"B4A")
'	webQuestion.LoadHtml(md.mdTohtml(message, CreateMap("datetime":"today")))
	
	clvMessages.Add(p, m)
	AdjustSize_Clv(0)
	
'	setScrollBarEnabled(webAnswer.As(View), True, True)
	
End Sub


Sub WriteAnswer(message As String) 'Left Side
	
	Dim m As textMessage
		m.Initialize
		m.message = message
		m.assistant = True
	
	Dim p As B4XView = xui.CreatePanel("answ")
	
'	panMain.Parent.As(B4XView).AddView(p,0,0, clvMessages.AsView.Width,200dip)
'	panMain.AddView(p,0,0, clvMessages.AsView.Width, 200dip)
	mainparent.AddView(p,0,0, clvMessages.AsView.Width, 200dip)
	
	p.LoadLayout("clvAnswerRow")
	p.RemoveViewFromParent
	p.Tag = "Answer"
	
	If (AnswerRtl) Then
		lblAnswer.TextAlling("CENTER", "RIGHT")
	Else
		lblAnswer.TextAlling("CENTER", "LEFT")
	End If
	
	lblAnswer.FallbackLineSpacing = False
	
'	lblAnswer.SetPadding(20dip,10dip,20dip,10dip)
'	lblAnswer.SetPadding(6%x,0,0,0)
'	lblAnswer.SetBackColor(Colors.White)
	lblAnswer.SetCorners(0dip)
'	lblAnswer.SetTextFont(xui.CreateFont(Typeface.LoadFromAssets("montserrat-medium.ttf"), 12))
	lblAnswer.Text = message
	p.Height = lblAnswer.GetHeight
	pnlAnswer.Height = p.Height
	
	p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, p.Height + 2%y)
	
	
'	webAnswerExtra.Initialize(webAnswer)
'	jsi.Initialize
'	webAnswerExtra.AddJavascriptInterface(jsi,"B4A")
'	webAnswer.LoadHtml(md.mdTohtml(message, CreateMap("datetime":"today")))

	
	clvMessages.Add(p, m)
'	clvMessages.AddTextItem(message, m)

'	clvMessages.ResizeItem(clvMessages.Size - 1, p.Height + panToolbar.Height + panBottom.Height + 10dip)
'	clvMessages.ResizeItem(clvMessages.Size - 1, lblAnswer.GetHeight)
'	AdjustSize_Clv(0)
	
	IsWorking = False
	
	
'	setScrollBarEnabled(webAnswer.As(View), True, True)
	
End Sub

Sub HideKeyboard
	panBottom.Height = 7%y
	txtQuestion.Height = 7%y
	ime.HideKeyboard
End Sub

Public Sub Ask(question As String, assistant As String, questionHolder As String)
	
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
	Dim p As B4XView = xui.CreatePanel("")
		p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width + 8%x, 12%y)
		p.LoadLayout("clvWaitingText")
		p.Tag = WaitingText
	lblWaitingText.Text = m.message
	panWaitingText.Height = lblWaitingText.GetHeight + 2%y
	
	lblWaitingText.FallbackLineSpacing = False
	
'	dd.GetViewByName(p, "lblAppTitle").Text = Text.Trim
'	webQuestion.LoadHtml(md.mdTohtml(m.message, CreateMap("datetime":"today")))
	clvMessages.Add(p, m)
	
	AdjustSize_Clv(0)
	
'	If (History.Length > 1000) Then
'		History = History.SubString(History.Length / 2)
'	End If
	
	Wait For (wrk_chat.Query(assistant, question, History, Temperature)) Complete (response As String)
	History = Null
	History = History & CRLF & question 	'Me:
	History = History & CRLF & response		'You:
'	History = History & CRLF & question & CRLF & response	'Me: CRLF You:
'	History = "You are a helpful assistant."
	
	clvMessages.RemoveAt(clvMessages.Size - 1)
	AdjustSize_Clv(0)
	
	If (txtQuestion.Text.Length < 1) Then
		Select response
			Case wrk_chat.TimeoutText:
				txtQuestion.Text = questionHolder
			Case wrk_chat.OpenApiHostError:
				txtQuestion.Text = questionHolder
		End Select
	End If
	
'	Log("Ask:" & response)
	WriteAnswer(response)
	
	Return
	
End Sub

Public Sub ShowKeyboard
	ime.ShowKeyboard(txtQuestion)
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

Public Sub ClickSimulation
	Try
		XUIViewsUtils.PerformHapticFeedback(Sender)
	Catch
		XUIViewsUtils.PerformHapticFeedback(panMain)
		LogColor("ClickSimulation: It's a Handaled Runtime Exeption. It's Ok, Ignore It." & CRLF & TAB & TAB & LastException.Message, Colors.LightGray)
	End Try
End Sub

Private Sub lblClearText_Click
	ClickSimulation
	txtQuestion.Text = ""
	ShowKeyboard
End Sub

Private Sub lblClearText_LongClick
	ClickSimulation
	ResetAI
	ToastMessageShow("Session Reset.", False)
End Sub

Public Sub ResetAI
	wrk_chat.Initialize
	IsWorking = False
	History = Null
'	History = "dynamic history of my and your replys in the chat: "
	Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
	If (msg.message = WaitingText) Then
		clvMessages.RemoveAt(clvMessages.Size - 1)
	End If
End Sub

Private Sub txtQuestion_FocusChanged (HasFocus As Boolean)
'	resetTextboxToolbar
	If Not (HasFocus) Then HideKeyboard
End Sub


Private Sub chkGrammar_CheckedChange(Checked As Boolean)
	ClickSimulation
	If (Checked = True) Then
		chkTranslate.Checked = False
		chkToFarsi.Checked = False
	End If
End Sub

Private Sub chkTranslate_CheckedChange(Checked As Boolean)
	ClickSimulation
	If (Checked = True) Then
		chkGrammar.Checked = False
		chkToFarsi.Checked = False
	End If
End Sub

Private Sub chkToFarsi_CheckedChange(Checked As Boolean)
	ClickSimulation
	If (Checked = True) Then
		chkGrammar.Checked = False
		chkTranslate.Checked = False
	End If
End Sub


Private Sub btnMore_Click
'	Dim y As Int = webAnswerExtra.GetContentHeight * webAnswerExtra.GetScale / 100
'	ChangeHeight(y)
	webAnswer.Height = pnlAnswer.Height * pnlAnswer.Height
	pnlAnswer.Height = webAnswer.Height
End Sub

'Example:
'SetShadow(Pane1, 4dip, 0xFF757575)
'SetShadow(Button1, 4dip, 0xFF757575)
'
Public Sub SetShadow (View As B4XView, Offset As Double, Color As Int)
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


Private Sub chkVoiceLang_CheckedChange(Checked As Boolean)
	ClickSimulation
	AnswerRtl = Checked
End Sub

Private Sub lblPaste_Click
	ClickSimulation
	Dim cp As BClipboard
	If (txtQuestion.Text.Trim.Length < 1) And (cp.hasText) Then
		txtQuestion.Text = cp.getText
	End If
End Sub


Private Sub chkChat_CheckedChange(Checked As Boolean)
	ClickSimulation
	ChatConversation = Checked
End Sub

Private Sub icConfigTopMenu_Click
	
	ClickSimulation
	
	If (General.Pref.IsDevMode) Then
		
		Dim v As String = "0، 1، 2، 3، 4، 5، 6، 7، 8، 9، 10، 11، 12، 13، 14، 15، 16، 17، 18، 19، 20، 21، 22، 23، 24، 25، 26، 27، 28، 29، 30، 31، 32، 33، 34، 35، 36، 37، 38، 39، 40، 41، 42، 43، 44، 45، 46، 47، 48، 49، 50، 51، 52، 53، 54، 55، 56، 57، 58، 59، 60، 61، 62، 63، 64، 65، 66، 67، 68، 69، 70، 71، 72، 73، 74، 75، 76، 77، 78، 79، 80، 81، 82، 83، 84، 85، 86، 87، 88، 89، 90، 91، 92، 93، 94، 95، 96، 97، 98، 99، 100"
		
		Dim myStrings As List
			myStrings.Initialize
			myStrings.Add("Hi there, How are you?")
'			myStrings.Add("🤔")
'			myStrings.Add(v)
			myStrings.Add(v & CRLF & CRLF & v & CRLF & CRLF & v)
			myStrings.Add(v & CRLF & CRLF & v & CRLF & CRLF & v & CRLF & CRLF & v & CRLF & CRLF & v)
'			myStrings.Add($"Try me in Farsi...${CRLF}فارسی بپرس"$)
'			myStrings.Add($"Try me in German...${CRLF}Versuchen wir es mit Deutsch 🇩🇪"$)
		
		Dim index As Int
			index = Rnd(0, myStrings.Size - 1)
	
		WriteAnswer(myStrings.Get(index))
		
	Else
		Drawer.LeftOpen = Not (Drawer.LeftOpen)
	End If
	
End Sub

Private Sub icMenuTopMenu_Click
	Drawer.LeftOpen = Not (Drawer.LeftOpen)
End Sub


Private Sub UpDown1Drawer_ChangeValue
	Temperature = (UpDown1Drawer.Value / 10)
	General.Pref.Creativity = UpDown1Drawer.Value
	General.SaveSetting
End Sub

Private Sub lblTemperatureDrawer_LongClick
	UpDown1Drawer.Value = 5
	ToastMessageShow("Critivity Reset to Default.", False)
End Sub

Private Sub lblCopy_Click
	If (txtQuestion.Text.Length > 0) Then
		ClickSimulation
		Dim cp As BClipboard
			cp.setText(txtQuestion.Text)
	End If
End Sub

Private Sub cmbLangDrawerFirst_SelectedIndexChanged (Index As Int)
	
	General.Pref.FirstLang = cmbLangDrawerFirst.GetItem(Index)
	chkTranslate.Text = General.Pref.FirstLang
	General.SaveSetting
	
End Sub

Private Sub cmbLangDrawerSec_SelectedIndexChanged (Index As Int)
	General.Pref.SecondLang = cmbLangDrawerSec.GetItem(Index)
	
	If (General.Pref.SecondLang = "(None)") Then
		chkToFarsi.SetVisibleAnimated(150, False)
	Else
		chkToFarsi.Text = General.Pref.SecondLang
		chkToFarsi.SetVisibleAnimated(300, True)
	End If
	General.SaveSetting
End Sub

Private Sub chkAutoSendDrawer_CheckedChange(Checked As Boolean)
	General.Pref.AutoSend = Checked
	General.SaveSetting
End Sub


Private Sub lblVersionNameDrawer_LongClick
	General.Pref.IsDevMode = Not(General.Pref.IsDevMode)
	DevModeCheck
	General.SaveSetting
	ToastMessageShow("IsDevMode: " & General.Pref.IsDevMode, False)
End Sub

'Private Sub lblAnswer_Click
'	
'	LogColor(AnswerRtl, Colors.Red)
'	
'	If Not (AnswerRtl) Then Return
'	
'	Try
'		
'		Dim index As Int = clvMessages.GetItemFromView(Sender)
'		Dim pnl As B4XView = clvMessages.GetPanel(index)
'		Dim lbl As B4XView = dd.GetViewByName(pnl, "lblAnswer")
'		
'		LogColor(lbl.As(Label).Gravity, Colors.Red)
''		If (lbl.As(Label).Gravity = 51) Then
'		If (AnswerRtl) Then
'			lbl.As(Label).Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.RIGHT)
'			lbl.SetTextAlignment("CENTER", "RIGHT")
'		Else '53
'			lbl.As(Label).Gravity = Bit.Or(Gravity.LEFT, Gravity.CENTER_HORIZONTAL)
'			lbl.SetTextAlignment("CENTER", "LEFT")
'		End If
'		
'	Catch
'		Log("lblAnswer_Click - " & CRLF & LastException)
'	End Try
'	
'End Sub
'
'Private Sub lblAnswer_LongClick
'	
'	Dim index As Int = clvMessages.GetItemFromView(Sender)
'	clvMessages_ItemLongClick(index, clvMessages.GetValue(index))
'	
'End Sub

Private Sub lblTitleTopMenu_Click
	lblTitleTopMenu_LongClick
End Sub

Private Sub lblTitleTopMenu_LongClick
	If (General.Pref.Memory) Then
		General.Pref.Memory = False
		ToastMessageShow("Memory Deactivated", False)
	Else
		General.Pref.Memory = True
		ToastMessageShow("Memory Activated", True)
	End If
	MemoryChanged
	General.SaveSetting
End Sub

Private Sub imgBrain_Click
	lblTitleTopMenu_LongClick
End Sub

Private Sub imgBrain_LongClick
	lblTitleTopMenu_LongClick
End Sub