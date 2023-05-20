B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.2
@EndOfDesignText@
#Region Attributes 
	#IgnoreWarnings: 9,12
#End Region

Sub Class_Globals
	
	Type textMessage (Message As String	,assistant As Boolean ,msgtype 		As Int)
	Type typeMessage (answer  As Int	,question  As Int	  ,waitingtxt 	As Int)
	Private  typeMSG As typeMessage
	
	Private su As StringUtils
	Private wrk_chat As ChatGPT
	Private xui As XUI
	Public 	MessageIndex As Int = -1
	
	Private flowTabToolbar As ASFlowTabMenu
	
	'KEYBOARD
	Private ime As IME
	Private heightKeyboard As Int
	Private MaximumSize As Int = 0
	
	Private HalfMode As Boolean
	

	'CHAT
	Public txtQuestion As EditText
	Public imgSend As ImageView
	Public clvMessages As CustomListView
	Private panBottom As Panel
	Public pTopMenu As Panel
	Private lblTitleTopMenu As Label
	Private icMenuTopMenu As ImageView
	Private icConfigTopMenu As ImageView
	
	Private ColorLog As Int = Colors.Black
	
	Private WaitingText As String = "Proccessing..."
	Private History 	As String
	Public IsWorking As Boolean
	
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
	Private Temperature As Double = 1 '0.99
	
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
	Private lblSample As Label
	Private btnLoad As Button
	Private btnSave As Button
	Private panRightMainDrawer As Panel
	Private clvTitles	As CustomListView
	
	Public prefdialog As PreferencesDialog
	Private Options	As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(parent As B4XView, text As String)
	
	MyLog($"Initilize: ${text}"$, ColorLog, True)
	
	mainparent = parent
'	General.Set_StatusBarColor(Colors.RGB(89,89,89))
'	General.Set_StatusBarColor(Colors.RGB(51,129,232))
	General.Set_StatusBarColor(0xFF74A5FF)
	parent.LoadLayout("Chat")
	
	Drawer.Initialize(Me, "Drawer", parent, 300dip)
	Drawer.CenterPanel.LoadLayout("Chat")
	
	Drawer.LeftPanel.LoadLayout("LeftDrawer")
	Drawer.RightPanel.LoadLayout("RightDrawer")
	Drawer.RightPanelEnabled = True
	
	dd.Initialize
	'The designer script calls the DDD class. A new class instance will be created if needed.
	'In this case we want to create it ourselves as we want to access it in our code.
	xui.RegisterDesignerClass(dd)
	
	ime.Initialize("ime")
	ime.AddHeightChangedEvent
	
'	History = "You are a helpful assistant."
	
	'TOP MENU
	Dim csTitle As CSBuilder
		csTitle.Initialize
		csTitle.Color(Colors.White).Append("Ask Chat").Color(Colors.Yellow).Append("GPT").PopAll
	lblTitleTopMenu.Text = csTitle
	icMenuTopMenu.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "settings.png", icMenuTopMenu.Width, icMenuTopMenu.Height, True)).Gravity = Gravity.CENTER
	icConfigTopMenu.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "menu.png", icConfigTopMenu.Width, icConfigTopMenu.Height, True)).Gravity = Gravity.CENTER
	imgBrain.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "brain.png", imgBrain.Width, imgBrain.Height, True)).Gravity = Gravity.CENTER
	
	MemoryChanged
	
	Dim cc As ColorDrawable
		cc.Initialize2(Colors.RGB(250,250,250),10,2,Colors.LightGray)
	panBottom.Background = cc
	txtQuestion.Background = Null
	General.setPadding(txtQuestion,5dip,5dip,5dip,5dip) 'REMOVE PADDING DO EDITTEXT
	
	imgSend.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Voice.png", imgSend.Width, imgSend.Height, True)).Gravity = Gravity.CENTER
	imgSend.Tag = "voice"
	
	'Calls the function of adjusting the size of the keyboard
	IME_HeightChanged(100%y,0)
	MaximumSize = su.MeasureMultilineTextHeight(txtQuestion,"Size Test!") * 8 'After 6 lines, the EditText will increase, and after that, the scroll will appear
	TextboxHeightChange("Size Test!")
	
	typeMSG.Initialize
	typeMSG.answer = 0
	typeMSG.question = 1
	typeMSG.waitingtxt = 3
	
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
	LoadListDB
	
	SetupSettingDialog(parent)
	
	UpDown1Drawer.Value = General.Pref.Creativity
	chkAutoSendDrawer.Checked = General.Pref.AutoSend
	
	
	If (General.Pref.SecondLang <> "" And General.Pref.SecondLang <> "(None)") Then
		LogColor(General.Pref.FirstLang & " : " & General.Pref.SecondLang, Colors.Red)
		chkToFarsi.Text = General.Pref.SecondLang
		chkToFarsi.Visible = True
		chkTranslate.Visible = True
	Else
		LogColor(General.Pref.FirstLang & " : " & General.Pref.SecondLang, Colors.Red)
		chkTranslate.Text = General.Pref.FirstLang
		chkToFarsi.Visible = False
		chkTranslate.Visible = True
	End If
	
	DevModeCheck
	
	MemoryChanged
	
	Check_First_Sec_Lang_Visibility
	
'	SetChatBackground("Bg-Chat03.jpg")
	SetChatBackground("Bg-Chat01.jpg")
	
	Dim clr As Int = Colors.RGB(13, 85, 25)
	
	flowTabToolbar.AddTab(flowTabToolbar.FontToBitmap(Chr(0xE8CE),True,20,clr),"Check")
	flowTabToolbar.AddTab(flowTabToolbar.FontToBitmap(Chr(0xE894),True,20,clr),"En")
	flowTabToolbar.AddTab(flowTabToolbar.FontToBitmap(Chr(0xE927),True,20,clr),"Fa")
	flowTabToolbar.AddTab(flowTabToolbar.FontToBitmap(Chr(0xF1D7),False,20,clr),"Nerv")
	flowTabToolbar.AddTab(flowTabToolbar.FontToBitmap(Chr(0xE8AF),True,20,clr),"Chat")
	ControlCheckBox
	
'	LogColor("ChatN.Init text: " & text, Colors.Red)
	txtQuestion.Text = text
'	If Not (text = "") Then
'		LogColor("ChatN.Initialize.ReciveText: " & text, Colors.Blue)
'		txtQuestion.Text = text
''		imgSend_Click
'	End If
	
	General.sql.TransactionSuccessful
	General.sql.EndTransaction
	
End Sub

Private Sub SetupSettingDialog(parent As B4XView)
	
	prefdialog.Initialize(parent, "Setting", parent.Width - 10%x, parent.Height / 2 )
	prefdialog.mBase.Top = 20%y
'	prefdialog.Dialog.OverlayColor = xui.Color_ARGB(128, 0, 10, 40)
'	prefdialog.Dialog.TitleBarColor = xui.Color_RGB(65, 105, 225)
	prefdialog.Dialog.TitleBarHeight = 75dip
'	prefdialog.CustomListView1.sv.Height = prefdialog.CustomListView1.sv.ScrollViewInnerPanel.Height + 10dip
	prefdialog.LoadFromJson(File.ReadString(File.DirAssets, "PrefsJson.json"))
	prefdialog.SetEventsListener(Me, "PrefDialog")
	
	
	'// اگه این متن رو عوض کردیم باید تویه
	'// و توی رویداد کلیک برای لیبل ها هم تغییر بدهیم PreferencesDialog
	'// Label1_Click - بصورت متغیر قرارش دادم و این متن صرفا برای یادآوری است
	prefdialog.AddApiKeyItem("APIKEY", "API", General.APIKeyLabel)
	'//
	
	prefdialog.SeparatorBackgroundColor = xui.Color_White
	prefdialog.Dialog.BorderColor = Colors.RGB(2,76,109)
	prefdialog.Dialog.BorderCornersRadius = 5dip
	prefdialog.Dialog.BlurBackground = True
	
	Options.Initialize
	Dim Options As Map = CreateMap()
		Options.Put("Creativity", General.Pref.Creativity)
		Options.Put("FirstLang", General.Pref.FirstLang)
		Options.Put("SecondLang",General.Pref.SecondLang)
		Options.Put("AutoSend", General.Pref.AutoSend)
		Options.Put("APIKEY", General.Pref.APIKEY)
	
End Sub

Private Sub SetChatBackground(fileName As String)
	
	MyLog("SetChatBackground", ColorLog, True)
	
	panMain.SetBackgroundImage(LoadBitmapResize(File.DirAssets, fileName, clvMessages.sv.Width, clvMessages.sv.Height, False)).Gravity = Gravity.FILL
	
'	Dim BackgroundImage As Bitmap
'	BackgroundImage.Initialize(File.DirAssets, "Bg-Chat2.jpg")
'	parent.SetBitmap(BackgroundImage)
End Sub

Public Sub MemoryChanged
	MyLog("MemoryChanged", ColorLog, False)
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
	MyLog("DevModeCheck", ColorLog, False)
	If General.Pref.IsDevMode Then
		Dim csTitle As CSBuilder
			csTitle.Initialize
			csTitle.Color(Colors.White).Append("Dev Chat").Color(Colors.Yellow).Append("GPT").PopAll
	Else
		Dim csTitle As CSBuilder
			csTitle.Initialize
			csTitle.Color(Colors.White).Append("Ask Chat").Color(Colors.Yellow).Append("GPT").PopAll
	End If
	
	lblTitleTopMenu.Text = csTitle
End Sub

Public Sub Check_First_Sec_Lang_Visibility
	
	MyLog("Check_First_Sec_Lang_Visibility: " & General.Pref.SecondLang, ColorLog, True)
	
	If (General.Pref.SecondLang = "(None)") Or (General.Pref.SecondLang = "") Then
		chkToFarsi.Visible = False
'		chkTranslate.Visible = False
	Else
		chkToFarsi.Visible = True
		chkTranslate.Visible = True
	End If
End Sub

Private Sub LoadLanguage
	
	MyLog("LoadLanguage", ColorLog, True)
	
	If Not (LanguageList.IsInitialized) Then LanguageList.Initialize
	
	LanguageList.AddAll(Array As String("(None)", "English", "Russian", "Spanish", "French", "German", _
								"Japanese", "Turkish", "Portuguese", "Persian", "Italian", _
								"Chinese", "Dutch", "Polish", "Vietnamese", _
							   	"Arabic", "Korean", "Czech", "Indonesian", "Ukrainian", "Greek", _
							   	"Hebrew", "Swedish", "Thai", "Romanian", "Hungarian", _
							   	"Danish", "Finnish", "Slovak", "Bulgarian", "Serbian", _
							   	"Norwegian", "Croatian", "Lithuanian", "Slovenian", _
							   	"Catalan", "Norwegian", "Estonian", "Latvian", "Hindi"))
	
'	Private supportLanguages As List
'		supportLanguages.Initialize
'		supportLanguages.Add(Array As String("en", "English"))
'		supportLanguages.Add(Array As String("zh-Hans", "简体中文"))
'		supportLanguages.Add(Array As String("zh-Hant", "繁體中文"))
'		supportLanguages.Add(Array As String("yue", "粤语"))
'		supportLanguages.Add(Array As String("wyw", "古文"))
'		supportLanguages.Add(Array As String("ja", "日本語"))
'		supportLanguages.Add(Array As String("ko", "한국어"))
'		supportLanguages.Add(Array As String("fr", "Français"))
'		supportLanguages.Add(Array As String("de", "Deutsch"))
'		supportLanguages.Add(Array As String("es", "Español"))
'		supportLanguages.Add(Array As String("it", "Italiano"))
'		supportLanguages.Add(Array As String("ru", "Русский"))
'		supportLanguages.Add(Array As String("pt", "Português"))
'		supportLanguages.Add(Array As String("nl", "Nederlands"))
'		supportLanguages.Add(Array As String("pl", "Polski"))
'		supportLanguages.Add(Array As String("ar", "العربية"))
'		supportLanguages.Add(Array As String("af", "Afrikaans"))
'		supportLanguages.Add(Array As String("am", "አማርኛ"))
'		supportLanguages.Add(Array As String("az", "Azərbaycan"))
'		supportLanguages.Add(Array As String("be", "Беларуская"))
'		supportLanguages.Add(Array As String("bg", "Български"))
'		supportLanguages.Add(Array As String("bn", "বাংলা"))
'		supportLanguages.Add(Array As String("bs", "Bosanski"))
'		supportLanguages.Add(Array As String("ca", "Català"))
'		supportLanguages.Add(Array As String("ceb", "Cebuano"))
'		supportLanguages.Add(Array As String("co", "Corsu"))
'		supportLanguages.Add(Array As String("cs", "Čeština"))
'		supportLanguages.Add(Array As String("cy", "Cymraeg"))
'		supportLanguages.Add(Array As String("da", "Dansk"))
'		supportLanguages.Add(Array As String("el", "Ελληνικά"))
'		supportLanguages.Add(Array As String("eo", "Esperanto"))
'		supportLanguages.Add(Array As String("et", "Eesti"))
'		supportLanguages.Add(Array As String("eu", "Euskara"))
'		supportLanguages.Add(Array As String("fa", "فارسی"))
'		supportLanguages.Add(Array As String("fi", "Suomi"))
'		supportLanguages.Add(Array As String("fj", "Fijian"))
'		supportLanguages.Add(Array As String("fy", "Frysk"))
'		supportLanguages.Add(Array As String("ga", "Gaeilge"))
'		supportLanguages.Add(Array As String("gd", "Gàidhlig"))
'		supportLanguages.Add(Array As String("gl", "Galego"))
'		supportLanguages.Add(Array As String("gu", "ગુજરાતી"))
'		supportLanguages.Add(Array As String("ha", "Hausa"))
'		supportLanguages.Add(Array As String("haw", "Hawaiʻi"))
'		supportLanguages.Add(Array As String("he", "עברית"))
'		supportLanguages.Add(Array As String("hi", "हिन्दी"))
'		supportLanguages.Add(Array As String("hmn", "Hmong"))
'		supportLanguages.Add(Array As String("hr", "Hrvatski"))
'		supportLanguages.Add(Array As String("ht", "Kreyòl Ayisyen"))
'		supportLanguages.Add(Array As String("hu", "Magyar"))
'		supportLanguages.Add(Array As String("hy", "Հայերեն"))
'		supportLanguages.Add(Array As String("id", "Bahasa Indonesia"))
'		supportLanguages.Add(Array As String("ig", "Igbo"))
'		supportLanguages.Add(Array As String("is", "Íslenska"))
'		supportLanguages.Add(Array As String("jw", "Jawa"))
'		supportLanguages.Add(Array As String("ka", "ქართული"))
'		supportLanguages.Add(Array As String("kk", "Қазақ"))
'		supportLanguages.Add(Array As String("mn", "Монгол хэл"))
'		supportLanguages.Add(Array As String("tr", "Türkçe"))
'		supportLanguages.Add(Array As String("ug", "ئۇيغۇر تىلى"))
'		supportLanguages.Add(Array As String("uk", "Українська"))
'		supportLanguages.Add(Array As String("ur", "اردو"))
'		supportLanguages.Add(Array As String("vi", "Tiếng Việt"))

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
'	cmbLangDrawerFirst.cmbBox.RemoveAt(cmbLangDrawerFirst.Size - 1)	'Remove "(None)" from First Language Combo
	cmbLangDrawerFirst.cmbBox.RemoveAt(0)	'Remove "(None)" from First Language Combo
	If Not (indexFirst > -1) Then indexFirst = 0
	
	cmbLangDrawerFirst.SelectedIndex = indexFirst
	chkTranslate.Text = General.Pref.FirstLang
	
	'######### Second Language
	'#
	
	cmbLangDrawerSec.SetItems(LanguageList)
	If (indexSec > -1) Then
		LogColor(General.Pref.SecondLang, Colors.Red)
		cmbLangDrawerSec.SelectedIndex = indexSec
		chkToFarsi.Text = General.Pref.SecondLang
		chkToFarsi.Visible = True
		chkTranslate.Visible = True
	Else
		cmbLangDrawerSec.SelectedIndex = 0 'lenght
		chkToFarsi.Visible = False
		chkTranslate.Visible = True
	End If
	
End Sub

Private Sub Drawer_StateChanged (Open As Boolean)
	MyLog("Drawer State Open: " & Open, ColorLog, True)
	If (Open) Then
		UpDown1Drawer.Value = General.Pref.Creativity 'Temperature * 10
		chkAutoSendDrawer.Checked = General.Pref.AutoSend
	Else
		General.SaveSettingDB
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
	Return Null
End Sub

Private Sub tpc_OnTouchEvent (Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
	
	' pass touch event to parent view
'	Dim parent As List = panMain.Parent.As(Panel).GetAllViewsRecursive
	
	' find view at touch position
'	Dim views As View = parent
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
'	
'	
''		LogColor("OnTouchEvent: " & Action & " - " & MotionEvent, Colors.Blue)
'	Select Action
'		Case base.TOUCH_ACTION_MOVE
'			Dim deltaOffset As Float = (Y - StartOffset) * 1.5
'			If Scrolled = False Then
'				If Abs(deltaOffset) > 10dip Then Scrolled = True
'			End If
'			
'			LogColor("tpc_OnTouchEvent_ACTION_MOVE: " & deltaOffset, Colors.LightGray)
'			
'			If (Y > lastY) Then			'Movign Down
'				webAnswerExtra.FlingScroll(0, ScrollPosition + Y)
'			Else If (Y < lastY) Then	'Moving Up
'				webAnswerExtra.FlingScroll(0, ScrollPosition - Y * 1.5)
'			End If
'			
'			lastY = Y
'			
'		Case base.TOUCH_ACTION_UP
'			LogColor("tpc_OnTouchEvent_ACTION_UP", Colors.Blue)
''			Dim index As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY)
''			Dim item As CLVItem = clvMessages.GetRawListItem(index)
''			Dim innerIndex As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY - item.Offset + clvMessages.sv.ScrollViewOffsetY)
''			LogColor("tpc_OnTouchEvent_ACTION_UP: " & index & CRLF & ":" & CRLF & item & CRLF & ":" & CRLF & innerIndex, Colors.Blue)
''				
'			If Scrolled = False Then
'				LogColor("tpc_OnTouchEvent_Click", Colors.Blue)
''				CallSub(Me, "btnMore_Click") 'ignore
'				Return False
''				btnMore_Click
'			End If
''			ScrollingCLV = Null
'	End Select
'	
'	Return True 'ScrollingCLV <> Null
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
'				Dim index As Int = clvMessages.FindIndexFromOffset(StartOffset + clvMessages.sv.ScrollViewOffsetY)
'				Dim item As CLVItem = clvMessages.GetRawListItem(index)
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
	
	Dim index As Int
		index = Rnd(0, myStrings.Size - 1)
	
	WriteAnswer(myStrings.Get(index), False, "", -1)
	
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
					
'					'ADJUST VERTICAL
'					Private TopMargin, BottomMargin As Int = 2%y
''					Dim text As String = lblAnswer.TextValue
''					If (text.Length > 45) Then text = text & CRLF
'					Dim t As Int
''					t = General.Size_textVertical(lblAnswer, text)
''					t = General.Size_textVertical(lblAnswer, text) + BottomMargin
''					LogColor("Length: " & text.Length, Colors.Blue)
'					LogColor("H: " & t, Colors.Blue)
''					If (t > 150) Then
'					webAnswer.Top = TopMargin + 1%y
'					If (t > 80%y) Then
'						webAnswer.Height = 70%y
'					Else
'						webAnswer.Height = t + 2%y
'					End If
''					lblAnswer.Height = General.Size_textVertical(lblAnswer,lblAnswer.TextIs) + BottomMargin
''					lblAnswer.Top = TopMargin + 1%y
					
'					'ADJUST HORIZONTAL
''					Dim t As Int = General.Size_textHorizontal(lblAnswer,lblAnswer.TextValue)
'					LogColor("H: " & t, Colors.Magenta)
'					If (t < 130) Then
'						webAnswer.Width = 50%x
'						pnlAnswer.Width = webAnswer.Width + 4%x
'						LogColor("W is smaller of 120", Colors.Cyan)
'					Else If (t < 82%x) Then
''						lblAnswerOLD.Width = General.Size_textHorizontal(lblAnswerOLD,lblAnswerOLD.Text)
''						lblAnswerOLD.SingleLine = True
'						webAnswer.Width = t
'						pnlAnswer.Width = (webAnswer.Width + 4%x)
'						LogColor("W is more than of 82%x", Colors.Yellow)
'					Else
'						webAnswer.Width = 90%x
'						pnlAnswer.Width = webAnswer.Width + 4%x
'						LogColor("Else Horizontal", Colors.Green)
'					End If
					
'					pnlAnswer.Height = webAnswer.Height + TopMargin + BottomMargin
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
'					Private TopMargin As Int = 1%y : Private BottomMargin As Int = 1%y
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
	Dim msg As textMessage = Value
	If (msg.message = WaitingText) Then Return
	ToastMessageShow("Copied", False)
	Dim cp As BClipboard
	Dim msg As textMessage = Value
	cp.setText(String_Remove_DoubleQuot(msg.message))
	resetTextboxToolbar
	Log(msg)
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
	MyLog("clvMessages_ItemClick: " & Index & " - " & Value, ColorLog, True)
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

Private Sub MyLog(text As String, color As Int, AlwaysShow As Boolean)
''	Dim obj As B4XView = Sender
''	Try
		General.MyLog("ChatN." & text, color, AlwaysShow)
'		
'		DateTime.DateFormat="HH:mm:ss.SSS"
'		Dim time As String = DateTime.Date(DateTime.Now)
'		
'		If (AlwaysShow) Then
'			LogColor(text & TAB & " (" & time & ")", color)
'			Return
'		End If
'		
'		If (General.IsDebug) Then
'			LogColor(text & TAB & " (" & time & ")", color)
'			Return
'		End If
'		
''	Catch
''		LogColor($"${obj} & ": " text"$, Colors.Blue)
''		Log(LastException)
''	End Try
End Sub

Sub txtQuestion_TextChanged (Old As String, New As String)
	
	MyLog("txtQuestion_TextChanged: " & Old & " - " & New, ColorLog, False)
	
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
	
	MyLog("TextboxHeightChange: " & text, ColorLog, False)
	
	Private i As Int = su.MeasureMultilineTextHeight(txtQuestion, text)
	If i > MaximumSize Then Return 'Reached the size limit.
	
	
	If i > 8%y Then 'It is small, we are going to increase to the limit
'		LogColor("TextboxHeightChange: " & text & " - " & i, Colors.Red)
		
		If (panBottom.Height > i) Then
'			LogColor("ChatN." & i, Colors.Red)
			
			panBottom.Height = i
			txtQuestion.Height = i
			panBottom.Top = heightKeyboard - panBottom.Height
			txtQuestion.Top = 1%y
			panToolbar.Top = panBottom.Top - panToolbar.Height
			AdjustSize_Clv(panBottom.Height, False)
		Else
'			LogColor("ChatN." & i, Colors.Blue)
			
			panBottom.Height = i
			txtQuestion.Height = i
			panBottom.Top = heightKeyboard - panBottom.Height
			txtQuestion.Top = 1%y
			panToolbar.Top = panBottom.Top - panToolbar.Height
			AdjustSize_Clv(panBottom.Height, False)
		End If
	Else
		If (i < 9%y) Then
'			LogColor("ChatN.Smaller: " & text & " - " & i, Colors.Red)
			panBottom.Height = 9%y
			txtQuestion.Height = panBottom.Height - 1
			panBottom.Top = heightKeyboard - panBottom.Height 'panToolbar.Top + panToolbar.Height
			txtQuestion.Top = 1%y
			panToolbar.Top = panBottom.Top - panToolbar.Height
			AdjustSize_Clv(0, False)
			
		Else
			
'			LogColor("ChatN.Normal: " & text & " - " & i, Colors.Blue)
'			panBottom.Height = 100%y * 0.2
			panBottom.Top = panToolbar.Top + panToolbar.Height
			txtQuestion.Top = panBottom.Top
			panBottom.Height = i
			txtQuestion.Height = panBottom.Height - 1
			AdjustSize_Clv(0, False)
		End If
	End If
End Sub

public Sub AdjustSize_Clv(height As Int, GotoEnd As Boolean)
	Try
		MyLog("AdjustSize_Clv: " & height, ColorLog, False)
		clvMessages.AsView.Top = pTopMenu.Height
			
		If (HalfMode) Then
			clvMessages.AsView.Height = panBottom.Top - pTopMenu.Height
			
			AddSeperator
		Else
			clvMessages.AsView.Height = panToolbar.Top - pTopMenu.Height
			
			RemoveSeperator
		End If
		clvMessages.Base_Resize(clvMessages.AsView.Width, clvMessages.AsView.Height)
		
''		If (height > 0) Then clvMessages.ResizeItem(clvMessages.Size - 1, height + panBottom.Top + panBottom.Height)
'		panToolbar.SetLayoutAnimated(0, 0%x, (clvMessages.sv.Height + pTopMenu.Height) - panToolbar.Height, 100%x, panToolbar.Height)
		Sleep(0) 'To make sure you've adjusted the size, before scrolling down (IMPORTANT SLEEP HERE!)
		If (GotoEnd) Then 
			If clvMessages.Size > 0 Then ScrollToLastItem(clvMessages)
		End If
		panTextToolbar.SetLayout(txtQuestion.Width - 30%x, txtQuestion.Height - 5%x, 77%x, 11%y)
		
	Catch
		MyLog("AdjustSize_Clv: " & height, ColorLog, True)
		LogColor("AdjustSize_Clv:" & LastException, Colors.Red)
	End Try
End Sub

Sub IME_HeightChanged(NewHeight As Int, OldHeight As Int)
	
	MyLog("IME_HeightChanged: NewHeight= " & NewHeight, ColorLog, False)
	
	heightKeyboard = NewHeight
	
'	If prefdialog.IsInitialized And prefdialog.Dialog.Visible Then
'		prefdialog.Dialog.Resize(mainparent.Width - 10%x, NewHeight)
'	End If
	
'	prefdialog.KeyboardHeightChanged(NewHeight)
	
	If (NewHeight > OldHeight) Then 'Full Screen
'		LogColor("ChatN.IME_HeightChanged.Full: " & NewHeight, ColorLog)
		
		HalfMode = False
		
		panBottom.SetLayout(panBottom.Left, NewHeight - panBottom.Height, panBottom.Width, panBottom.Height)
		txtQuestion.SetLayout(1%x, 1%y, panBottom.Width - 15%x, panBottom.Height - 1)
		imgSend.SetLayout(imgSend.Left, NewHeight - imgSend.Height - 1%y, imgSend.Width, imgSend.Height)
		panToolbar.SetLayoutAnimated(0, panToolbar.Left, NewHeight - panBottom.Height - panToolbar.Height, panToolbar.Width, panToolbar.Height)
		AdjustSize_Clv(0, False)
	Else							' Half Screen
'		LogColor("ChatN.IME_HeightChanged.Half: " & NewHeight, ColorLog)
		
		HalfMode = True
		
		panBottom.SetLayout(panBottom.Left, NewHeight - panBottom.Height, panBottom.Width, panBottom.Height)
		txtQuestion.SetLayout(1%x, 1%y, panBottom.Width - 15%x, panBottom.Height - 1)
		imgSend.SetLayout(imgSend.Left, NewHeight - imgSend.Height - 1%y, imgSend.Width, imgSend.Height)
		panToolbar.SetLayoutAnimated(0, panToolbar.Left, panBottom.Top - panToolbar.Height, panToolbar.Width, panToolbar.Height)
		AdjustSize_Clv(0, False)
		
	End If
	
'	clvMessages.sv.Height = NewHeight
	
'	Dim tpc As TouchPanelCreator
'	base = tpc.CreateTouchPanel("tpc")
'	panMain.RemoveAllViews
'	panMain.Color = Colors.Transparent
'	panMain.Top = pTopMenu.Height
'	panMain.Height = clvMessages.sv.Height
'	panMain.AddView (base, panMain.Left, panMain.Top, panMain.Width, panMain.Height)
End Sub


Public Sub ScrollToLastItem(CLV As CustomListView)
'	MyLog("ScrollToLastItem", ColorLog, False)
	Sleep(50)
	If CLV.Size > 0 Then
		If CLV.sv.ScrollViewContentHeight > CLV.sv.Height Then
			CLV.ScrollToItem(CLV.Size - 1)
		End If
	End If
End Sub

Private Sub imgSend_LongClick

	MyLog("imgSend_LongClick", ColorLog, True)
	
	If (General.Pref.SecondLang = "(None)") Or (General.Pref.SecondLang = "") Then Return
	
	VoiceLang(General.Pref.SecondLang)
	Wait For (RecognizeVoice) Complete (Result As String)
	If (Result <> "") Then
'		LogColor("Voice:" & Result, Colors.Blue)
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
	
	MyLog("csTitle_Click: " & Tag, ColorLog, True)
	
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
	MyLog("setScrollBarEnabled", ColorLog, False)
	Dim jo = v As JavaObject
		jo.RunMethod("setVerticalScrollBarEnabled"  , Array As Object (vertical  ))
		jo.RunMethod("setHorizontalScrollBarEnabled", Array As Object (horizontal))
End Sub

Public Sub imgSend_Click
	
	MyLog("imgSend_Click", ColorLog, True)
	
	If (IsWorking) Then Return
	
	IsWorking = True
	
'	Dim bartAI As Bart
'	bartAI.Initialize
'	bartAI.translate(txtQuestion.Text, "en", "fa")
'	Return
	
	If (clvMessages.Size > 0) Then
		Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
		If (msg.msgtype = typeMSG.waitingtxt) Then Return
	End If
	
	If Not (General.Pref.Memory) Then ResetAI
	
	Dim questionHolder As String = txtQuestion.Text.Trim
	
	If (imgSend.Tag = "text") Then
		
		If (clvMessages.Size > 0) Then
			Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
			If (msg.msgtype = typeMSG.waitingtxt) Then Return
		End If
		
'		LogColor("imgSend_Click:" & clvMessages.Size & " - " & msg.message, Colors.Magenta)
		
		If (questionHolder.Trim.Length < 1) Then Return
		
		ClickSimulation
		
		Dim question As String = questionHolder
		Dim sAssistant As String
		Dim sSystem As String
		
		If (chkGrammar.Checked) Then
			
			ResetAI
			
			If (General.IsAWord(question)) Then
'				sSystem = $"Fix word into ${General.Pref.FirstLang} or Translate word into ${General.Pref.FirstLang}:"$
				sSystem = $"Change this word into ${General.Pref.FirstLang} or translate it into ${General.Pref.FirstLang}:"$
			Else
'				sSystem = $"Only Fix grammar and correct it into standard ${General.Pref.FirstLang}: "$
				sSystem = $"Only fix the grammar and correct it into standard ${General.Pref.FirstLang}: "$
			End If
			
'			sAssistant = $"Act As ${General.a_OR_an(General.Pref.FirstLang)} Translator, Proofreader, And Punctuation Corrector For Spelling And Grammar."$
			sAssistant = $"Act as ${General.a_OR_an(General.Pref.FirstLang)} translator, proofreader, and corrector of spelling and grammar for punctuation."$
			
			question = sSystem & questionHolder
			
		Else If (chkTranslate.Checked) Then
			
			ResetAI
			
			If (General.IsAWord(question)) Then
'				sSystem = $"You are ${General.a_OR_an(General.Pref.FirstLang)} Dictionary, Show definition and synonyms use ${General.Pref.FirstLang} and so minimum and limited tokens."$
				sSystem = $"You are ${General.a_OR_an(General.Pref.FirstLang)} Dictionary; show definitions and synonyms using ${General.Pref.FirstLang} with a minimum and limited number of tokens."$
			Else
''				sSystem = $"You are ${General.a_OR_an(General.Pref.FirstLang)} translation engine that can only translate text and cannot interpret it."$
'				sSystem = $"Only translate into standard ${General.Pref.FirstLang}, don't interpret it or only show meaning, definitions and synonyms."$
				sSystem = $"Only translate into standard ${General.Pref.FirstLang}; do not interpret it or provide only meaning, definitions, and synonyms."$
			End If
			
			question = sSystem & " The Text Is: " & CRLF & questionHolder
			
'			sAssistant = $"Act as ${General.a_OR_an(General.Pref.FirstLang)} Translator and Improver."$
			sAssistant = $"Translate this into ${General.Pref.FirstLang}."$
			
		Else If (chkToFarsi.Checked) Then
			ResetAI
			
			If (General.IsAWord(question)) Then
'				sSystem = $"You are ${General.a_OR_an(General.Pref.SecondLang)} Dictionary, Show definition and synonyms use ${General.Pref.SecondLang} and so minimum and limited tokens."$
				sSystem = $"You are ${General.a_OR_an(General.Pref.SecondLang)} dictionary; show definitions and synonyms using ${General.Pref.SecondLang} with a minimum of tokens."$
			Else
'				sSystem = $"Only translate into ${General.Pref.SecondLang}, don't interpret or only show meaning, definitions and synonyms."$
				sSystem = $"Only translate into ${General.Pref.SecondLang}; do not interpret or provide meaning, definitions, or synonyms."$
			End If
			
			sSystem = sSystem.Replace("\t", Null)
			
			question = sSystem & " The Text Is: " & CRLF & questionHolder
			
			sAssistant = $"Translate this into ${General.Pref.SecondLang}."$
			
		Else if (chkChat.Checked) Then
			
'			sSystem = $"Act as a spoken ${General.Pref.FirstLang} teacher and improver and strictly correct my grammar, typos, and factual errors.
'Reply Correct ${General.Pref.FirstLang} of my question and answer disrespectfully."$
			
'			sAssistant = $"Reply in Correct ${General.Pref.FirstLang} and Answer disrespectfully to the question:"$
			
			'# Funny Angry
'			sSystem = $"Act as a spoken teacher and improver and strictly correct my grammar, typos, and factual errors.
'Correct my mistakes And answer like a funny angry And disrespectful character."$
			
			'# Teacher
'			sSystem = $"Act as a strict teacher and correct my grammar, typos, and factual errors. Answer with an air of disapproval and disdain."$
			
			'# Funny Angry Teacher
			sSystem = $"Act as a strict teacher and correct my grammar, typos, and factual errors. Answer with the funny angry mode of a disrespectful character."$
			
			sAssistant = ""
			
			
			question = questionHolder
		Else
			sSystem = "You are a smart and helpful assistant."
			sAssistant = ""
			
			question = questionHolder
		End If
		
		WriteQuestion(questionHolder)
		Ask(question, sAssistant, sSystem, questionHolder)
		txtQuestion.Text = ""
		
	Else If Main.voicer.IsSupported Then	
		
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
		IsWorking = False
	
	Else
		LogColor("imgSend_Click: ELSE condition=> Voice:" & Result, Colors.Cyan)
		IsWorking = False
		imgSend.Tag = "text"
'		imgSend_Click
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
	
	MyLog("VoiceLang: " & lng, ColorLog, False)
	
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
	
	MyLog("RecognizeVoice", ColorLog, False)
	
	Main.voicer.Listen
	Wait For vr_Result (Success As Boolean, Texts As List)
	If Success And Texts.Size > 0 Then
		Return Texts.Get(0)
	End If
	Return ""
End Sub

'Sub webAnswer_PageFinished (Url As String)
'	LogColor("PageFinished: " & Url, Colors.Blue)
'	webAnswerExtra.ExecuteJavascript("B4A.CallSub('SetWVHeight',true, document.documentElement.scrollHeight);")
'End Sub
'
'Sub SetWVHeight(height As String)
'	LogColor("SetWVHeight= webAnswer: " & webAnswer.Height & CRLF & "webAnswerExtra: " & webAnswerExtra.GetContentHeight & CRLF & "height : " & height & " => " & DipToCurrent(height), Colors.Blue)
'	
'	Dim h As Int = DipToCurrent(height)
'	AdjustSize_Clv(height)
''	If (DipToCurrent(height) > webAnswer.Height) Then
'		webAnswer.Height = h
'		pnlAnswer.Height = h + 100dip
''	End If
'End Sub

Private Sub ChangeHeight(height As Int)
'	MyLog("ChangeHeight: " & height, ColorLog, False)
	Dim y As Int = DipToCurrent(webAnswerExtra.GetContentHeight) * webAnswerExtra.GetScale / 100
	webAnswerExtra.FlingScroll(0, y * 100)
	pnlAnswer.Height = webAnswerExtra.GetContentHeight
	webAnswer.Height = webAnswerExtra.GetContentHeight
	LogColor(webAnswerExtra.GetContentHeight, Colors.Magenta)
End Sub

Private Sub SaveMessage(title As String)
	
	MyLog("SaveMessage", ColorLog, True)
	
	btnSave.Enabled = False
	
	Dim count 	As Int  = clvMessages.Size - 1
	Dim map1 	As Map
	Dim lst 	As List
		lst.Initialize
	
	For i = 0 To count
		Dim msg As textMessage = clvMessages.GetValue(i)
			map1.Initialize
			
		If (msg.msgtype <> typeMSG.waitingtxt) Then
			map1.Put("assistant", msg.assistant)
			map1.Put("message", msg.message)
			map1.Put("msgtype", msg.msgtype)
			lst.Add(map1)
		End If
	Next
	
	Dim jso As JSONGenerator
		jso.Initialize2(lst)
	
	If (MessageIndex = -1) Then
		
		LogColor("New: " & MessageIndex & "/" & (clvTitles.Size - 1), Colors.Red)
		
		Dim query As String = "INSERT INTO Messages(JsonMessage, Title) VALUES(?, ?)"
		
		Dim Args(2) As Object
			Args(0) = jso.ToString
			Args(1) = title
		
		General.sql.ExecNonQuery2(query, Args)
		
		Dim id As Int = General.sql.ExecQuerySingleResult("Select last_insert_rowid()")
		LogColor("ID: " & id, Colors.Red)
		Log("Title: " & title)
		
		Dim count As Int = clvTitles.Size + 1
		clvTitles.AddTextItem(count & ". " & title, id)
		
		Log(count)
		
		MessageIndex = clvTitles.Size - 1
		
		LogColor("MessageIndex: " & MessageIndex & "/" & (clvTitles.Size - 1), Colors.Blue)
		
	Else
		
		LogColor("Update: " & MessageIndex & "/" & (clvTitles.Size - 1), Colors.Red)
		
		Dim query As String = "UPDATE Messages SET JsonMessage=? WHERE ID=?"
		
		Dim Args(2) As Object
			Args(0) = jso.ToString
			Args(1) = clvTitles.GetValue(MessageIndex)
		Log(Args)
		
		General.sql.ExecNonQuery2(query, Args)
	End If
	
	btnSave.Enabled = True
	
'	ToastMessageShow("Saved !", False)
	
End Sub

Public Sub AddtoHistory(question As String, answer As String)
	
'	History = Null
	If (History = Null) Or (History = "") Then History = "Our Conversetion History:"
	History = History & CRLF & "Me: " & question 	'Me:
	History = History & CRLF & "You: " & answer		'You:
'	History = History & CRLF & question & CRLF & responsetext	'Me: CRLF You:
'	History = "You are a helpful assistant."

End Sub

Public Sub Ask(question As String, assistant As String, system As String, questionHolder As String)
	
	MyLog("Ask: " & questionHolder, ColorLog, True)
	
	If (question = "") Then
		txtQuestion.RequestFocus
		ShowKeyboard
		Return
	End If
	
	Dim msgindx As Int = LastMsgIndex
	
	Dim m As textMessage
		m.Initialize
		m.message = WaitingText '"Proccessing..."
		m.assistant = True
		m.msgtype = typeMSG.waitingtxt
	
	Dim p As B4XView = xui.CreatePanel("")
	mainparent.AddView(p,0,0,clvMessages.AsView.Width,200dip)
	p.LoadLayout("clvWaitingText")
	p.RemoveViewFromParent
	p.Tag = WaitingText
	
	lblWaitingText.SetPadding(2%x, 1%x, 2%x, 1%x)
	lblWaitingText.Text = m.message
	panWaitingText.Height = lblWaitingText.GetHeight
	lblWaitingText.FallbackLineSpacing = False
	
'	dd.GetViewByName(p, "lblAppTitle").Text = Text.Trim
'	webQuestion.LoadHtml(md.mdTohtml(m.message, CreateMap("datetime":"today")))

	p.SetLayoutAnimated(50,0,0, clvMessages.AsView.Width, panWaitingText.Height + 2%y)
	
	RemoveSeperator
	clvMessages.Add(p, m)
	
	AdjustSize_Clv(0, True)
	
'	If (History.Length > 1000) Then
'		History = History.SubString(History.Length / 2)
'	End If
	
	Dim AIType As Int
	If (chkGrammar.Checked) Then
		AIType = wrk_chat.AITYPE_Grammar
	Else If (chkTranslate.Checked) Or (chkToFarsi.Checked) Then
		AIType = wrk_chat.AITYPE_Translate
	Else If (chkChat.Checked) Then
		AIType = wrk_chat.AITYPE_Practice
	Else
		AIType = wrk_chat.AITYPE_Chat
	End If
	
	Wait For (Starter.Query(system, _
							 question, _
							 assistant, _
							 Temperature, _
							 AIType, _
							 msgindx)) Complete (response As Map)
	
	Dim responsetext As String 	= response.Get("response")
	Dim QuestionIndex As Int = msgindx 'response.GetDefault("QuestionIndex", 0)
'	Dim Contine 	 As Boolean = response.Get("continue")
	
	AddtoHistory(questionHolder, responsetext)
	
'	clvMessages.RemoveAt(clvMessages.Size - 1)
	AdjustSize_Clv(0, True)
	
	If (txtQuestion.Text.Length < 1) Then
		Select responsetext
			Case wrk_chat.TimeoutText:
				txtQuestion.Text = questionHolder
			Case wrk_chat.OpenApiHostError  & " (Code 1)":
				txtQuestion.Text = questionHolder
			Case wrk_chat.OpenApiHostError  & " (Code 2)":
				txtQuestion.Text = questionHolder
			Case wrk_chat.InstructureError
				chkTranslate.Checked = True
				txtQuestion.Text = questionHolder
				imgSend_Click
				
		End Select
	End If
	
'	Log("Answer:" & responsetext)
'	Log("Question Holder:" & questionHolder)
	WriteAnswer(responsetext, True, questionHolder, QuestionIndex)
	
	ScrollToLastItem(clvMessages)
	
'	LogColor("Continue:" & contine, Colors.Blue)
	
	Return
	
End Sub

Sub WriteAnswer(message As String, save As Boolean, questionHolder As String, QuestionIndex As Int) 'Left Side
	
	MyLog($"WriteAnswer: ${message}"$, ColorLog, True)
	
	Dim m As textMessage
		m.Initialize
		m.message = message
		m.assistant = True
		m.msgtype = typeMSG.answer
	
	Dim p As B4XView = xui.CreatePanel("answ")
	
''	panMain.Parent.As(B4XView).AddView(p,0,0, clvMessages.AsView.Width,200dip)
''	panMain.AddView(p,0,0,clvMessages.AsView.Width,200dip)
	mainparent.AddView(p,0,0,clvMessages.AsView.Width,200dip)
	
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
	lblAnswer.SetPadding(2%x,2%x,2%x,2%x)
'	lblAnswer.SetBackColor(Colors.White)
	lblAnswer.SetCorners(0dip)
'	lblAnswer.SetTextFont(xui.CreateFont(Typeface.LoadFromAssets("montserrat-medium.ttf"), 12))
	lblAnswer.Text = message
	p.Height = lblAnswer.GetHeight
	pnlAnswer.Height = p.Height
	
	'##########################
	'#						  #
	'#   	  Width   		  #
	
	Dim labelWidth As Int
		labelWidth = lblAnswer.GetWidth
	
	' Check if the label width is equal to or larger than the available width in the view
	If (labelWidth >= (clvMessages.AsView.Width)) Then
'		LogColor("Answer Bigger: " & labelWidth, Colors.Red)
		pnlAnswer.Left = 5%x
		pnlAnswer.Width = clvMessages.AsView.Width - pnlAnswer.Left - 15%x
	Else
'		LogColor("Answer Smaller: " & labelWidth, Colors.Blue)
		
		Dim wid As Int = labelWidth + 5%x
		Dim Left As Int = 5%x
		pnlAnswer.Left = Left
		
		' Check if the panel overflows the ScrollView width
		If ((Left + wid) >= clvMessages.sv.Width) Then
			
			' Adjust panel position based on available space
			If (Left - 5%x) < 5%x Then
'				Log("Answer Smaller: Width: " & pnlAnswer.Width)
				pnlAnswer.Width = clvMessages.sv.Width - 15%x
			Else
				pnlAnswer.Width = wid
'				Log("Answer Smaller: Inside: " & pnlAnswer.Width)
			End If
		Else
			If (wid >= clvMessages.sv.Width - 15%x) Then
'				Log("Answer Else: " & pnlAnswer.Left)
				pnlAnswer.Width = clvMessages.sv.Width - 15%x
			Else
				pnlAnswer.Width = wid
			End If
		End If
	End If
	
	imgAnswer.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "puton.png", imgAnswer.Width, imgAnswer.Height, False)).Gravity = Gravity.CENTER
	
	p.SetLayoutAnimated(0, 0, 0, labelWidth, p.Height + 2%y)
	
'	webAnswerExtra.Initialize(webAnswer)
'	jsi.Initialize
'	webAnswerExtra.AddJavascriptInterface(jsi,"B4A")
'	webAnswer.LoadHtml(md.mdTohtml(message, CreateMap("datetime":"today")))
	
	RemoveSeperator
	LogColor("Question Index: " & QuestionIndex, Colors.Red)
	
	' The meaning of -1 is that it comes from LoadMessage
	' OR from: Main->Resume=>TextShared = "[NEW]"
	'
	If (QuestionIndex = -1) Then
		clvMessages.Add(p, m)
	Else
		If (clvMessages.Size > 0) Then
			clvMessages.ReplaceAt(QuestionIndex + 1, p, pnlAnswer.Height,m)
		Else
			'It's the first message in clvMessage
			clvMessages.Add(p, m)
		End If
	End If
	
'	clvMessages.InsertAt(QuestionIndex + 1, p, m)
'	clvMessages.RemoveAt(QuestionIndex + 1)
	
'	clvMessages.AddTextItem(message, m)
'	clvMessages.ResizeItem(clvMessages.Size - 1, p.Height + panToolbar.Height + panBottom.Height + 10dip)
'	clvMessages.ResizeItem(clvMessages.Size - 1, lblAnswer.GetHeight)
	
	AdjustSize_Clv(0, True)
	
	Log(questionHolder)
	If save Then
		If (questionHolder <> "") Then
			If (questionHolder.Length > 80) Then
				Log("Here: " & questionHolder.SubString2(0, 80))
				SaveMessage(questionHolder.SubString2(0, 80))
			Else
				Log("Second: " & questionHolder)
				SaveMessage(questionHolder)
			End If
		Else
			Log("Untitle: " & questionHolder)
			SaveMessage("Untitle " & Rnd(100, 999))
		End If
	End If
	
	IsWorking = False
	
'	setScrollBarEnabled(webAnswer.As(View), True, True)
	
End Sub

Sub WriteQuestion(message As String) 'Right Side
	
	MyLog($"WriteQuestion: ${message}"$, ColorLog, True)
	
	Dim m As textMessage
		m.Initialize
		m.message = message
		m.assistant = False
		m.msgtype = typeMSG.question
	
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
	
	lblQuestion.FallbackLineSpacing = False
	
	lblQuestion.SetPadding(2%x,2%x,2%x,2%x)
'	lblQuestion.SetBackColor(Colors.White)
'	lblQuestion.SetCorners(0dip)
'	lblQuestion.SetTextFont(xui.CreateFont(Typeface.LoadFromAssets("montserrat-medium.ttf"), 12))
	lblQuestion.Text = message
	p.Height = lblQuestion.GetHeight
	pnlQuestion.Height = p.Height
	
	'##########################
	'#						  #
	'#   	  Width   		  #
	
	Dim labelWidth As Int
	labelWidth = lblQuestion.GetWidth

	' Check if the label width is equal to or larger than the available width in the view
	If (labelWidth >= (clvMessages.AsView.Width - 5%x)) Then
'		LogColor("Bigger: " & labelWidth, Colors.Red)
		pnlQuestion.Left = 15%x
		pnlQuestion.Width = clvMessages.AsView.Width - pnlQuestion.Left - 5%x
	Else
'		LogColor("Smaller: " & labelWidth, Colors.Blue)
		
		Dim wid As Int = labelWidth + 5%x
		Dim Left As Int = clvMessages.AsView.Width - pnlQuestion.Width
		
		' Check if the panel overflows the ScrollView width
		If ((Left + wid) >= clvMessages.sv.Width) Then
			
			' Adjust panel position based on available space
			If (Left - 15%x) < 15%x Then
'				Log("Smaller: Left: " & pnlQuestion.Left)
				pnlQuestion.Left = 15%x
			Else
				pnlQuestion.Left = pnlQuestion.Width - 5%x
'				Log("Smaller: Inside: " & pnlQuestion.Left)
			End If
		Else
'			Log("Else: " & pnlQuestion.Left)
			pnlQuestion.Width = wid
			pnlQuestion.Left = clvMessages.sv.Width - pnlQuestion.Width - 5%x
		End If
	End If
	
	imgQuestion.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "Gray-Tipped.png", imgQuestion.Width, imgQuestion.Height, False)).Gravity = Gravity.CENTER
	
'	lblQuestion.mBase.Left = clvMessages.sv.Width - labelWxidth - 10%x
	p.SetLayoutAnimated(0, 15%x, 0, pnlQuestion.Width, p.Height + 2%y)
	
'	webQuestionExtra.Initialize(webQuestion)
'	jsi.Initialize
'	webQuestionExtra.AddJavascriptInterface(jsi,"B4A")
'	webQuestion.LoadHtml(md.mdTohtml(message, CreateMap("datetime":"today")))
	
	RemoveSeperator
	
	Log("Quesion: " & m)
	
	clvMessages.Add(p, m)
	AdjustSize_Clv(0, True)
	
	Dim stack As Map
		stack.Initialize
		stack.Put("QuestionIndex", LastMsgIndex)
		stack.Put("Response", "")
	Starter.MessageList.Add(stack)
	
	LogColor("Write Question: " & Starter.MessageList, Colors.Red)
	LogColor("Write Stack: " & stack, Colors.Red)
	
	
'	setScrollBarEnabled(webAnswer.As(View), True, True)
	
End Sub

Sub HideKeyboard
	ime.HideKeyboard
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
'	ShowKeyboard
End Sub

Private Sub lblClearText_LongClick
	ClickSimulation
	ResetAI
	MessageIndex = -1
	clvMessages.Clear
	LogColor("MessageIndex: " & clvTitles.Size & "/" & MessageIndex, Colors.Red)
	ToastMessageShow("New Session", False)
End Sub

Public Sub ResetAI
	
	MyLog("ResetAI", ColorLog, True)
	
	wrk_chat.Initialize
	IsWorking = False
	History = Null
	wrk_chat.ChatHistoryList.Initialize
	
	If (clvMessages.Size > 0) Then
		
		Dim msg As textMessage = clvMessages.GetValue(clvMessages.Size - 1)
		
		If (msg.msgtype = typeMSG.waitingtxt) Then
			clvMessages.RemoveAt(clvMessages.Size - 1)
		End If
	End If
	
End Sub

Private Sub txtQuestion_FocusChanged (HasFocus As Boolean)
'	MyLog("txtQuestion_FocusChanged: " & HasFocus, ColorLog, False)
'	resetTextboxToolbar
	If Not (HasFocus) Then HideKeyboard
End Sub


Private Sub chkGrammar_CheckedChange(Checked As Boolean)
	ClickSimulation
	If (Checked = True) Then
		chkTranslate.Checked = False
		chkToFarsi.Checked = False
		chkChat.Checked = False
		ControlCheckBox
	End If
End Sub

Private Sub chkTranslate_CheckedChange(Checked As Boolean)
	ClickSimulation
	If (Checked = True) Then
		chkGrammar.Checked = False
		chkToFarsi.Checked = False
		chkChat.Checked = False
		ControlCheckBox
	End If
End Sub

Private Sub chkToFarsi_CheckedChange(Checked As Boolean)
	ClickSimulation
	If (Checked = True) Then
		chkGrammar.Checked = False
		chkTranslate.Checked = False
		chkChat.Checked = False
		ControlCheckBox
	End If
End Sub

Private Sub chkChat_CheckedChange(Checked As Boolean)
	
	ClickSimulation
	If (Checked = True) Then
		chkGrammar.Checked = False
		chkTranslate.Checked = False
		chkToFarsi.Checked = False
		ControlCheckBox
	End If
	
End Sub

Private Sub ControlCheckBox
	
	MyLog("ControlCheckBox", ColorLog, False)
	
	Dim Firstlang 	As String = cmbLangDrawerFirst.GetItem(cmbLangDrawerFirst.SelectedIndex)
	Dim Seclang 	As String = cmbLangDrawerSec.GetItem(cmbLangDrawerSec.SelectedIndex)
	
	chkGrammar.Visible = False
	chkTranslate.Visible = False
	chkToFarsi.Visible = False
	chkChat.Visible = False
	
End Sub

Private Sub IsLangRTL(langname As String) As Boolean
	If (langname = "Hebrew") Or (langname = "Arabic") Or (langname = "Persian") Then
		AnswerRtl = True
		Return True
	Else
		AnswerRtl = False
		Return False
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

Private Sub lblPaste_Click
	ClickSimulation
	Dim cp As BClipboard
	If (txtQuestion.Text.Trim.Length < 1) And (cp.hasText) Then
		txtQuestion.Text = cp.getText
	End If
End Sub

Private Sub icConfigTopMenu_Click

	MyLog("icConfigTopMenu_Click", ColorLog, True)
	
	ClickSimulation
	
	Drawer.RightOpen = Not (Drawer.RightOpen)
	
End Sub

Public Sub LastMsgIndex As Int
	If Not (clvMessages.IsInitialized) Then Return 0
	If (clvMessages.Size < 1) Then Return 0
	Return clvMessages.Size - 1
End Sub

Private Sub SimulateMessage
	
	MyLog("SimulateMessage", ColorLog, True)
	
'	If (General.Pref.IsDevMode) Then
		
		Dim v As String = "0، 1، 2، 3، 4، 5، 6، 7، 8، 9، 10، 11، 12، 13، 14، 15، 16، 17، 18، 19، 20، 21، 22، 23، 24، 25، 26، 27، 28، 29، 30، 31، 32، 33، 34، 35، 36، 37، 38، 39، 40، 41، 42، 43، 44، 45، 46، 47، 48، 49، 50، 51، 52، 53، 54، 55، 56، 57، 58، 59، 60، 61، 62، 63، 64، 65، 66، 67، 68، 69، 70، 71، 72، 73، 74، 75، 76، 77، 78، 79، 80، 81، 82، 83، 84، 85، 86، 87، 88، 89، 90، 91، 92، 93، 94، 95، 96، 97، 98، 99، 100."
		
		Dim myStrings As List
		myStrings.Initialize
		myStrings.Add("Hi there, How are you?")
'			myStrings.Add("🤔")
		myStrings.Add(v)
		myStrings.Add(v.SubString2(0, Rnd(5, 100)))
'			myStrings.Add(v & CRLF & v & CRLF & v & CRLF & v & CRLF & v)
		myStrings.Add($"Try me in Farsi...${CRLF}فارسی بپرس"$)
'			myStrings.Add($"Try me in German...${CRLF}Versuchen wir es mit Deutsch 🇩🇪"$)
		
		Dim index As Int
		index = 10 Mod (myStrings.Size - 1)
		
'		Dim index As Int
'			index = Rnd(10, myStrings.Size - 1)
		
		If Rnd(0, 2) = 1 Then
			If Rnd(0, 2) Mod 2 = 1 Then
				WriteAnswer(myStrings.Get(index), True, "", LastMsgIndex)
			Else
				WriteQuestion(myStrings.Get(index))
			End If
		Else
			Log("Do something: Proccessing")
			
			Dim m As textMessage
			m.Initialize
			m.message = WaitingText '"Proccessing..."
			m.assistant = False
			m.msgtype = typeMSG.waitingtxt
			
			Dim p As B4XView = xui.CreatePanel("")
			mainparent.AddView(p,0,0,clvMessages.AsView.Width,200dip)
			p.LoadLayout("clvWaitingText")
			p.RemoveViewFromParent
			p.Tag = WaitingText
			
			lblWaitingText.SetPadding(2%x, 1%x, 2%x, 1%x)
			lblWaitingText.Text = m.message
			panWaitingText.Height = lblWaitingText.GetHeight
			panWaitingText.Width = 80%x
			lblWaitingText.FallbackLineSpacing = False
			
			p.SetLayoutAnimated(0, 0, 0, clvMessages.AsView.Width, panWaitingText.Height + 2%y)
			
			RemoveSeperator
			clvMessages.Add(p, m)
			
			AdjustSize_Clv(0, True)
			
		End If
'	End If

End Sub

Private Sub RemoveSeperator
	Log("RemoveSeperator: " & clvMessages.Size)
	If (clvMessages.Size < 1) Then Return
	If (clvMessages.GetValue(clvMessages.Size-1) = "SEPERATOR") Then
		clvMessages.RemoveAt(clvMessages.Size-1)
	End If
End Sub

Private Sub AddSeperator
	If (clvMessages.GetValue(clvMessages.Size-1) <> "SEPERATOR") Then Return
	clvMessages.AddTextItem("", "SEPERATOR")
End Sub

'Private Sub PrefDialog_IsValid (TempData As Map) As Boolean
'	Try
'		Dim txt As String = TempData.GetDefault("APIKEY", "")
'		Options.Remove("APIKEY")
'		Options.Put("APIKEY", txt)
'		
'		Return True
'	Catch
'		Log(LastException)
'		Return False
'	End Try
'End Sub

Private Sub SetWidthItemPrefDialog (Pref As PreferencesDialog, Key As String, wwidth As Double)
	For i = 0 To Pref.PrefItems.Size - 1
		Dim pi As B4XPrefItem = Pref.PrefItems.Get(i)
		If pi.key = Key Then
			If pi.ItemType = Pref.TYPE_SHORTOPTIONS Then
				Dim Parent As B4XView = Pref.CustomListView1.GetPanel(i).GetView(1)
				Parent.Left = (Parent.Left + Parent.Width) - wwidth
				Parent.Width = wwidth
				Dim view As B4XView = Parent.GetView( 0)
				view.Width = Parent.Width
			Else
				Dim oldx As Double=Pref.CustomListView1.GetPanel(i).GetView(1).Left
				Dim oldw As Double=Pref.CustomListView1.GetPanel(i).GetView(1).Width
				Pref.CustomListView1.GetPanel(i).GetView(1).Left=(oldx+oldw)-wwidth
				Pref.CustomListView1.GetPanel(i).GetView(1).Width= wwidth
			End If
		End If
	Next
End Sub

Private Sub PrefDialog_BeforeDialogDisplayed (Template As Object)
	Try
		' Fix Linux UI (Long Text Button)
		Dim btnCancel As B4XView = prefdialog.Dialog.GetButton(xui.DialogResponse_Cancel)
		If btnCancel.IsInitialized Then
				btnCancel.Text = "Cancel"
				btnCancel.Width = btnCancel.Width + 20dip
				btnCancel.Left = btnCancel.Left - 20dip
				btnCancel.TextColor = xui.Color_Red
		End If
		Dim btnOk As B4XView = prefdialog.Dialog.GetButton(xui.DialogResponse_Positive)
		If btnOk.IsInitialized Then
			btnOk.Text = "Save"
			btnOk.Width = btnOk.Width + 20dip
			btnOk.Left = btnCancel.Left - btnOk.Width
			btnOk.TextColor = Colors.RGB(40,161,38)
		End If
	
	For i = 0 To prefdialog.PrefItems.Size - 1
		Dim pi As B4XPrefItem = prefdialog.PrefItems.Get(i)
		LogColor("Type: " & pi.ItemType, Colors.Black)
		
		'## Resize Seprator befor APIKey
		'##
		If pi.ItemType = prefdialog.TYPE_SEPARATOR Then
			If (pi.Title = "") Then
				prefdialog.CustomListView1.ResizeItem(i, 80dip)
				
'			Else If (pi.Title = "OpenAI API Key") Then
'				
'				Dim pnl As B4XView = prefdialog.CustomListView1.GetPanel(i)
'				pnl.Color =  xui.Color_RGB(65, 105, 225)
''					pnl.Height = pnl.Parent.Height
''					pnl.GetView(0).Height = pnl.Height - 20dip
''					pnl.GetView(0).TextSize = 12
''					pnl.GetView(1).Top = 20dip
			End If
		End If
		
'		If pi.ItemType = prefdialog.TYPE_TEXT  Then
'			Dim txt As B4XFloatTextField = prefdialog.CustomListView1.GetPanel(i).GetView(0).Tag
'			txt.TextField.Enabled = False
'		End If
'		If pi.ItemType=prefdialog.TYPE_BOOLEAN Then
'			Dim bool As B4XSwitch = prefdialog.CustomListView1.GetPanel(i).GetView(1).Tag
'			bool.Enabled = False
'		End If
	Next
		
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub icMenuTopMenu_Click
	
	Wait For (prefdialog.ShowDialog(Options, "Save", "Cancel")) Complete (Result As Int)
	
	If Result = xui.DialogResponse_Positive Then
		LogColor(Options, Colors.Blue)
		
		
		General.Pref.Creativity = Options.Get("Creativity")
		General.Pref.FirstLang = Options.Get("FirstLang")
		General.Pref.SecondLang = Options.Get("SecondLang")
		General.Pref.APIKEY = Options.Get("APIKEY")
		
		If General.IsNull(Options.Get("AutoSend")) Then
			General.Pref.AutoSend = False
		Else
			General.Pref.AutoSend = Options.Get("AutoSend")
		End If
		
		chkTranslate.Text = General.Pref.FirstLang
		ControlCheckBox
		If (General.Pref.SecondLang = "(None)") Or General.IsNull(General.Pref.SecondLang) Then
			chkToFarsi.SetVisibleAnimated(150, False)
'			chkTranslate.SetVisibleAnimated(150, False)
		Else
			LogColor(General.Pref.SecondLang, Colors.Red)
			chkToFarsi.Text = General.Pref.SecondLang
			chkToFarsi.SetVisibleAnimated(300, True)
			chkTranslate.SetVisibleAnimated(300, True)
		End If
		
		General.SaveSettingDB
		
	End If
	
'	Drawer.LeftOpen = Not (Drawer.LeftOpen)
End Sub


Private Sub UpDown1Drawer_ChangeValue
	Temperature = (UpDown1Drawer.Value / 10)
	General.Pref.Creativity = UpDown1Drawer.Value
	General.SaveSettingDB
End Sub

Private Sub lblTemperatureDrawer_LongClick
	UpDown1Drawer.Value = 5
	ToastMessageShow("Creativity Reset to Default.", False)
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
	General.SaveSettingDB
	ControlCheckBox
	
End Sub

Private Sub cmbLangDrawerSec_SelectedIndexChanged (Index As Int)
	
	MyLog("cmbLangDrawerSec_SelectedIndexChanged", ColorLog, True)
	
	General.Pref.SecondLang = cmbLangDrawerSec.GetItem(Index)
	
	If (General.Pref.SecondLang = "(None)") Then
		chkToFarsi.SetVisibleAnimated(150, False)
'		chkTranslate.SetVisibleAnimated(150, False)
	Else
		LogColor(General.Pref.SecondLang, Colors.Red)
		chkToFarsi.Text = General.Pref.SecondLang
		chkToFarsi.SetVisibleAnimated(300, True)
		chkTranslate.SetVisibleAnimated(300, True)
	End If
	General.SaveSettingDB
	ControlCheckBox
End Sub

Private Sub chkAutoSendDrawer_CheckedChange(Checked As Boolean)
	General.Pref.AutoSend = Checked
	General.SaveSettingDB
End Sub


Private Sub lblVersionNameDrawer_LongClick
	General.Pref.IsDevMode = Not(General.Pref.IsDevMode)
	DevModeCheck
	General.SaveSettingDB
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
	If (General.Pref.Memory) Then
		General.Pref.Memory = False
'		ToastMessageShow("Memory Deactivated", False)
	Else
		General.Pref.Memory = True
'		ToastMessageShow("Memory Activated", True)
	End If
	MemoryChanged
	General.SaveSettingDB
End Sub

Private Sub lblTitleTopMenu_LongClick
	
	MyLog("lblTitleTopMenu_LongClick", ColorLog, True)
	
	If (General.Pref.IsDevMode) Then SimulateMessage
	
End Sub

Private Sub imgBrain_Click
	lblTitleTopMenu_Click
End Sub

'Private Sub imgBrain_LongClick
'	
'End Sub


Private Sub panTextToolbar_Click
	
End Sub


Private Sub btnSave_Click
	SaveList_OLD
End Sub

Private Sub btnLoad_Click
	LoadList_OLD
End Sub

Private Sub SaveList_OLD
	
	btnSave.Enabled = False
	
	Dim count 	As Int  = clvMessages.Size - 1
	Dim map1 	As Map
	Dim lst 	As List
		lst.Initialize
	
	For i = 0 To count
		Dim msg As textMessage = clvMessages.GetValue(i)
		map1.Initialize
		If (msg.msgtype <> typeMSG.waitingtxt) Then
			map1.Put("assistant", msg.assistant)
			map1.Put("message", msg.message)
			map1.Put("msgtype", msg.msgtype)
			lst.Add(map1)
		End If
	Next
	
	Dim jso As JSONGenerator
		jso.Initialize2(lst)
	
	File.WriteString(File.DirInternal, General.SaveFileName, jso.ToString)
	
	btnSave.Enabled = True
	
'	LogColor(jso.ToString, Colors.Red)
	
End Sub

Private Sub LoadList_OLD
	
	
	If Not (File.Exists(File.DirInternal, General.SaveFileName)) Then Return
	
	Dim txt As String = File.ReadString(File.DirInternal, General.SaveFileName)
	
	If (txt.Length < 1) Then Return
	
	imgSend.Enabled = False
	
	clvMessages.Clear
	
	Dim JSON As JSONParser
		JSON.Initialize(txt)
	
	Dim lst As List = JSON.NextArray
	
	Dim count As Int = lst.Size - 1
	
	For i = 0 To count
		
		Dim m As Map = lst.Get(i)
		Dim msg As textMessage
			msg.Initialize
'			msg.assistant = m.Get("assistant")
			msg.message = m.Get("message")
			msg.msgtype = m.Get("msgtype")
		
		Select msg.msgtype
			
			Case typeMSG.answer
				WriteAnswer(msg.message, False, "", LastMsgIndex)
				
			Case typeMSG.question
				WriteQuestion(msg.message)
			
		End Select
		
	Next
	
	imgSend.Enabled = True
	
End Sub


Private Sub LoadListDB
	
	MyLog("LoadListDB", ColorLog, True)
	
	imgSend.Enabled = False
	clvTitles.Clear
	
	Dim recset As ResultSet = General.sql.ExecQuery("SELECT * FROM Messages")
	
	Do While recset.NextRow
		
		Dim Title 		As String = recset.GetString("Title")
		Dim ID 			As Int 	  = recset.GetInt("ID")
		
		clvTitles.AddTextItem((clvTitles.Size+1) & ". " & Title, ID)
		
	Loop
	
	recset.Close
	
	imgSend.Enabled = True
	
End Sub

Private Sub clvTitles_ItemClick (Index As Int, Value As Object)
	
	MyLog("clvTitles_ItemClick: " & Index & " - " & Value, ColorLog, True)
	
	MessageIndex = Index
	LogColor("MessageIndex: " & MessageIndex & "/" & (clvTitles.Size - 1), Colors.Red)
	
	Dim recsetJson As ResultSet = General.sql.ExecQuery($"SELECT * FROM Messages WHERE ID='${Value}'"$)
	
	Do While recsetJson.NextRow
		LoadMessage(recsetJson.GetString("JsonMessage"))
	Loop
	
	recsetJson.Close
	
End Sub

Private Sub LoadMessage(Value As String)
	
	MyLog("LoadMessage: " & Value, ColorLog, True)
	
	If (Value.Trim.Length < 1) Then Return
	
	imgSend.Enabled = False
	clvMessages.sv.Visible = False
	
	clvMessages.Clear
	
	Dim JSON As JSONParser
		JSON.Initialize(Value)
	
	Dim lst As List
		lst = JSON.NextArray
	
	Dim count As Int = lst.Size - 1
	Dim question As String
	
	For i = 0 To count
		
		Dim m As Map = lst.Get(i)
		
		Log("m: " & m)
		
		Dim msg As textMessage
			msg.Initialize
'			msg.assistant = m.Get("assistant")
			msg.message = m.Get("message")
			msg.msgtype = m.Get("msgtype")
		
		Log(msg)
		
		If (msg.msgtype = typeMSG.answer) Then
			Log("answer: " & msg.message)
'			WriteAnswer(msg.message, False, question, (LastMsgIndex-1))
			WriteAnswer(msg.message, False, question, -1)
		Else if (msg.msgtype = typeMSG.question) Then
			Log("question: " & msg.message)
			question = msg.message
			WriteQuestion(question)
		Else
			LogColor("LoadMessage Else Type: " & msg, Colors.Red)
		End If
	Next
	
	Sleep(250)
	clvMessages.sv.SetVisibleAnimated(250, True)
	imgSend.Enabled = True
	
End Sub

Private Sub clvTitles_ItemLongClick (Index As Int, Value As Object)
	
	MyLog("clvTitles_ItemLongClick: " & Index & " - " & Value, ColorLog, True)
	
	'اگر این خط فعال بشه MessageIndex صفر میشه و به خطا میخوره موقع ذخیره
'	clvTitles_ItemClick(Index, Value)
	
	Dim pnl As B4XView = clvTitles.GetPanel(Index).Parent
	Dim lbl As Label = pnl.GetView(0).GetView(0)
	
	Msgbox2Async(lbl.Text, "Delete ?", "Delete", "Cancel", "", Null, True)
	Wait For Msgbox_Result (Result As Int)
		
		If (DialogResponse.POSITIVE = Result) Then
		
			Dim query As String = $"DELETE FROM Messages WHERE ID=?"$
			General.sql.ExecNonQuery2(query, Array As String(Value))
			
			clvMessages.Clear
			clvTitles.RemoveAt(Index)
			MessageIndex = -1
			LogColor("MessageIndex: "  & clvTitles.Size & "/" &  MessageIndex, Colors.Red)
			
			ToastMessageShow("Deleted", False)
		End If
		
End Sub


Private Sub lblNew_Click
	MyLog("lblNew_Click", ColorLog, True)
	
	lblClearText_LongClick
	ClickSimulation
	
End Sub


Private Sub btnClearTitles_Click
	
	Msgbox2Async("Clear All Messages ?", "Delete All", "Delete", "CANCEL", "", Null, True)
	
	Wait For Msgbox_Result (Result As Int)
	
	If (DialogResponse.POSITIVE = Result) Then
		
		Dim query As String = $"DELETE FROM Messages"$
		General.sql.ExecNonQuery(query)
		
		clvTitles.Clear
		
		MessageIndex = -1
		Starter.MessageList.Clear
		
	End If
End Sub

Private Sub flowTabToolbar_TabClick(index As Int)
	
	Select index
		Case 0
			chkGrammar.Checked = True
		Case 1
			chkTranslate.Checked = True
		Case 2
			chkToFarsi.Checked = True
		Case 3
			chkChat.Checked = True
		Case 4
			chkGrammar.Checked = False
			chkTranslate.Checked = False
			chkToFarsi.Checked = False
			chkChat.Checked = False
	End Select
	
End Sub