B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=12.2
@EndOfDesignText@

Sub Process_Globals
	Private xui As XUI
	Public 	Sett 					As KeyValueStore
	Public 	Pref 					As Setting
End Sub

#Region Save and Load Settings

Public Sub SaveSetting
	
	If Not(Sett.IsInitialized) Then
		Sett.Initialize(File.DirInternal, "AskChatGPT.conf")
	End If

	Sett.Put("FirstLang", Pref.FirstLang)
	Sett.Put("SecondLang", Pref.SecondLang)
	Sett.Put("Creativity", Pref.Creativity)
	Sett.Put("AutoSend", Pref.AutoSend)
	Sett.Put("Memory", Pref.Memory)
	Sett.Put("IsDevMode", Pref.IsDevMode)
	
'	LogColor($"SaveSetting: ${Pref.FirstLang} : ${Pref.SecondLang} :
'			 ${Pref.Creativity} : ${Pref.AutoSend} : ${Pref.Memory} :
'			 ${Pref.IsDevMode}"$, Colors.Blue)
End Sub

Public Sub LoadSetting
	
	If Not(Sett.IsInitialized) Then
		Sett.Initialize(File.DirInternal, "AskChatGPT.conf")
	End If

	Pref.FirstLang = GetLangFirstStr(Sett.Get("FirstLang").As(String))
	Pref.SecondLang = GetLangSecStr(Sett.Get("SecondLang"))
	Pref.Creativity = GetCreativityInt(Sett.Get("Creativity"))
	Pref.AutoSend = GetBoolean(Sett.Get("AutoSend"))
	Pref.Memory = GetDefaultMemory(Sett.Get("Memory"))	'Default True
	Pref.IsDevMode = GetBoolean(Sett.Get("IsDevMode"))
	
'	LogColor($"LoadSetting: ${Pref.FirstLang} : ${Pref.SecondLang} :
'			 ${Pref.Creativity} : ${Pref.AutoSend} : ${Pref.Memory} :
'			 ${Pref.IsDevMode}"$, Colors.Blue)
End Sub

Private Sub GetLangFirstStr(txt As Object) As String

	If IsNull(txt) Then Return "English"
	
	Dim val As String = txt.As(String)
	
	If (val = "(None)") Then Return "English"
	
	Return val
End Sub

Private Sub GetDefaultMemory(val As Object) As Boolean
	If IsNull(val) Then Return True
	Return val.As(Boolean)
End Sub

Public Sub IsNull(txt As String) As Boolean
	If (txt = Null) Or (txt.ToLowerCase) = "null" Then Return True
	Return False
End Sub

'Return correct work with A or AN
Public Sub a_OR_an(word As String) As String
	Dim firstLetter As String
		firstLetter = word.SubString2(0, 1).ToLowerCase
	
	Select Case firstLetter
		Case "a", "e", "i", "o", "u"
			Return "an " & word
		Case Else
			Return "a " & word
	End Select
End Sub

Public Sub IsAWord(text As String) As Boolean
	Dim words() As String = Regex.Split("\s+", text.Trim)
	If words.Length = 1 Then
		Return True
	Else
		Return False
	End If
End Sub

Private Sub GetLangSecStr(txt As Object) As String
	
	If IsNull(txt) Then Return "(None)"
	Return txt.As(String)
	
End Sub

Private Sub GetCreativityInt(val As Object) As Int

	If IsNull(val) Then Return 5
	If (val < 0)   Then Return 5
	
	If (val >= 0) And (val <= 10) Then
		Return val.As(Int)
	End If
	
	Return 5

End Sub

Private Sub GetBoolean(val As Object) As Boolean
	If IsNull(val) Then Return False
	Return val.As(Boolean)
End Sub

#End Region Setting

Sub Size_textVertical(lb As Label,text As String) As Int
	If text.Length < 1 Then Return 0
	Private su As StringUtils
	Return su.MeasureMultilineTextHeight(lb,text)
End Sub


Sub Set_StatusBarColor(clr As Int)
	Dim p As Phone
	If p.SdkVersion >= 21 Then
		Dim jo As JavaObject
		jo.InitializeContext
		Dim window As JavaObject = jo.RunMethodJO("getWindow", Null)
		window.RunMethod("addFlags", Array (0x80000000))
		window.RunMethod("clearFlags", Array (0x04000000))
		window.RunMethod("setStatusBarColor", Array(clr))
	End If
End Sub


Sub Round_Image (iv As ImageView, pasta As String, imagem As String )
	Private Input As B4XBitmap = LoadBitmapResize(pasta,imagem,iv.Width,iv.Height,True)
	If Input.Width <> Input.Height Then
		Dim l As Int = Min(Input.Width, Input.Height)
		Input = Input.Crop(Input.Width / 2 - l / 2, Input.Height / 2 - l / 2, l, l)
	End If
	Dim c As B4XCanvas
	Dim xview As B4XView = xui.CreatePanel("")
	xview.SetLayoutAnimated(0, 0, 0, iv.Width, iv.Width)
	c.Initialize(xview)
	Dim path As B4XPath
	path.InitializeOval(c.TargetRect)
	c.ClipPath(path)
	c.DrawBitmap(Input.Resize(iv.Width, iv.Width, False), c.TargetRect)
	c.RemoveClip
	c.Invalidate
	Dim res As B4XBitmap = c.CreateBitmap
	c.Release
	iv.Bitmap = res
End Sub




Sub Size_textHorizontal(lb As Label, text As String) As Int
	Private bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Private cvs As Canvas
	cvs.Initialize2(bmp)
	Return cvs.MeasureStringWidth(text, lb.Typeface , lb.TextSize)
End Sub



Sub setPadding(v As View, Left As Int, Top As Int, Right As Int, Bottom As Int)
	Dim jo = v As JavaObject
	jo.RunMethod("setPadding", Array As Object(Left, Top, Right, Bottom))
End Sub
