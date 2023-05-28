B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=12.2
@EndOfDesignText@
#Region Attributes 
	#IgnoreWarnings: 12
#End Region

Sub Process_Globals
	Private xui 					As XUI
	Private ColorLog				As Int 		= Colors.LightGray
	Public 	Pref 					As Setting
	Public  IsDebug					As Boolean 	= False
	Public 	SaveFileName			As String 	= "AskChatGPT.save"
	Public 	ConfigFileName			As String 	= "AskChatGPT.conf"
	Public 	SQLFileName				As String 	= "AskChatGPT.db"
	Public 	sql						As SQL
	Public 	APIKeyLabel				As String	= "Get your free OpenAI Key (Click Here)"
End Sub

#Region Save and Load Settings

Public Sub MyLog(text As String, color As Int, AlwaysShow As Boolean)
	
	If Not (IsDebug) Then Return
	
	DateTime.DateFormat = "HH:mm:ss.SSS"
	Dim time As String  = DateTime.Date(DateTime.Now)	
	
	If (AlwaysShow) Then
		LogColor(text & TAB & " (" & time & ")", color)
		Return
	End If
	
	If (IsDebug) Then
		LogColor(text & TAB & " (" & time & ")", color)
		Return
	End If
	
End Sub

Private Sub CreateDB
	
	MyLog("General.CreateDB", ColorLog, True)
	
	'// Reset Install
'	File.Delete(File.DirInternal, SQLFileName)
	
	If File.Exists(File.DirInternal, SQLFileName) Then
		sql.Initialize(File.DirInternal, SQLFileName, False)
		sql.BeginTransaction
		Return
	End If
	
	Dim tblConfig As String = $"CREATE TABLE "Config" (
	"FirstLang"	TEXT Not Null DEFAULT 'English',
	"SecondLang"	TEXT,
	"Creativity"	INTEGER DEFAULT 4,
	"AutoSend"	INTEGER DEFAULT 0,
	"Memory"	INTEGER DEFAULT 0,
	"APIKEY"	TEXT,
	"IsDevMode"	INTEGER DEFAULT 0,
	"LastTypeModel"	INTEGER DEFAULT 0
	);"$
	
	Dim tblMessages As String = $"CREATE TABLE "Messages" (
	"ID"	INTEGER NOT NULL DEFAULT 0 UNIQUE,
	"JsonMessage"	TEXT,
	"Title"	TEXT,
	PRIMARY KEY("ID" AUTOINCREMENT)
);"$
	
	sql.Initialize(File.DirInternal, SQLFileName, True)
	sql.BeginTransaction
	sql.ExecNonQuery(tblConfig)
	sql.ExecNonQuery(tblMessages)
End Sub


Public Sub LoadSettingDB
	
	MyLog("General.LoadSettingDB", ColorLog, True)
	
	CreateDB
	
	Dim CurSettingSql As ResultSet = sql.ExecQuery("SELECT * FROM Config")
'	Log(CurSettingSql)
	
	LogColor("Config Row Count: " & CurSettingSql.RowCount, Colors.Red)
	If (CurSettingSql.RowCount < 1) Then
		Pref.FirstLang 		= 	"English"
		Pref.SecondLang 	= 	"(None)"
		Pref.Creativity 	= 	4
		Pref.AutoSend 		= 	False
		Pref.Memory 		= 	False
		Pref.IsDevMode 		= 	IsDebug
		Pref.APIKEY 		= 	""
		Pref.LastTypeModel 	= 	0
		
		Log(Pref.APIKEY)
		SaveSettingDB
		Log(Pref.APIKEY)
	Else
		CurSettingSql.Position = 0
		Pref.FirstLang = CurSettingSql.GetString("FirstLang")
		Pref.SecondLang =  CurSettingSql.GetString("SecondLang")
		Pref.Creativity = CurSettingSql.GetInt("Creativity")
		Pref.AutoSend = ValToBool(CurSettingSql.GetInt("AutoSend"))
		Pref.Memory = ValToBool(CurSettingSql.GetInt("Memory"))
		Pref.IsDevMode = ValToBool(CurSettingSql.GetInt("IsDevMode"))
		Pref.APIKEY = DecKey(CurSettingSql.GetString("APIKEY"))
		Pref.LastTypeModel = CurSettingSql.GetInt("LastTypeModel")
		Log(Pref.APIKEY)
	End If
	
	CurSettingSql.Close
	
End Sub

Public Sub SaveSettingDB
	
	MyLog("General.SaveSettingDB", ColorLog, True)
	
'	sql.BeginTransaction
	
	sql.ExecNonQuery("DELETE FROM Config")
	
	Dim query 		As String = "INSERT INTO Config(FirstLang, SecondLang, Creativity, AutoSend, Memory, APIKEY, IsDevMode, LastTypeModel) VALUES(?, ?, ?, ?, ?, ?, ?, ?)"
	Dim Args(8) 	As Object
		Args(0) 	= Pref.FirstLang
		Args(1) 	= Pref.SecondLang
		Args(2) 	= Pref.Creativity
		Args(3) 	= Pref.AutoSend
		Args(4) 	= Pref.Memory
		If IsNull(Pref.APIKEY.Trim) Then
			Args(5) = Null
			Log("API Save: ###################### " & Args(5))
		Else
			Args(5) = EncKey(Pref.APIKEY.Trim)
			Log("API Save: ---------------------- " & Args(5))
		End If
		Args(6) 	= Pref.IsDevMode
		Args(7) 	= Pref.LastTypeModel
	
	Log(query)
	
	sql.ExecNonQuery2(query, Args)
	
	Starter.APIValidate
	
'	sql.TransactionSuccessful
'	sql.EndTransaction
	
'	ToastMessageShow("Settings Saved !", False)
End Sub

Private Sub ValToBool(value As Object) As Boolean
	
	MyLog("ValToBool", ColorLog, False)
	
	If IsNull(value) Then Return False
	If (value.As(String).ToLowerCase = "false") Then Return False
	If (value.As(String).ToLowerCase = "null") Then Return False
	If (value.As(String).ToLowerCase = "true") Then Return True
	
	Dim tmp As Int
	Try
		tmp = value.As(Int)
	Catch
		tmp = 0
	End Try
	
	If (tmp > 0) Then
		Return True
	Else
		Return False
	End If
	
End Sub

Private Sub GetLangFirstStr(txt As Object) As String
	
	MyLog("General.GetLangFirstStr: " & txt, ColorLog, False)
	
	If IsNull(txt) Then Return "English"
	
	Dim val As String = txt.As(String)
	
	If (val = "(None)") Then Return "English"
	
	Return val
End Sub

Private Sub GetDefaultMemory(val As Object) As Boolean
'	MyLog("General.GetDefaultMemory: " & val, ColorLog, False)
	If IsNull(val) Then Return True
	Return val.As(Boolean)
End Sub

Public Sub IsNull(txt As Object) As Boolean
'	MyLog("General.IsNull: " & txt, ColorLog, False)
	Try
		If (txt = Null) Or (txt.As(String).ToLowerCase = "null") Or _
		   (txt.As(String) = "") Or (txt.As(String).Length < 1) Then Return True
		Return False
	Catch
		Log(LastException)
		Return False
	End Try
End Sub

'Return correct work with A or AN
Public Sub a_OR_an(word As String) As String
	MyLog("General.a_OR_an: " & word, ColorLog, False)
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
	MyLog("General.IsAWord: " & text, ColorLog, False)
	Dim words() As String = Regex.Split("\s+", text.Trim)
	If words.Length = 1 Then
		Return True
	Else
		Return False
	End If
End Sub

Private Sub GetLangSecStr(txt As Object) As String
	MyLog("General.GetLangSecStr: " & txt, ColorLog, False)
	If IsNull(txt) Then Return "(None)"
	Return txt.As(String)
	
End Sub

Private Sub GetStr(txt As Object) As String
	MyLog("General.GetStr: " & txt, ColorLog, False)
	If IsNull(txt) Then Return ""
	Return txt.As(String)
	
End Sub

Private Sub GetCreativityInt(val As Object) As Int
	
'	MyLog("General.GetCreativityInt: " & val, ColorLog, False)

	If IsNull(val) Then Return 5
	If (val < 0)   Then Return 5
	
	If (val >= 0) And (val <= 10) Then
		Return val.As(Int)
	End If
	
	Return 5

End Sub

Private Sub GetBoolean(val As Object) As Boolean
'	MyLog("General.GetBoolean: " & val, ColorLog, False)
	If IsNull(val) Then Return False
	Return val.As(Boolean)
End Sub

#End Region Setting

Sub Size_textVertical(lb As Label,text As String) As Int
	MyLog("General.Size_textVertical: " & text, ColorLog, False)
	If text.Length < 1 Then Return 0
	Private su As StringUtils
	Return su.MeasureMultilineTextHeight(lb,text)
End Sub


Sub Set_StatusBarColor(clr As Int)
	MyLog("General.Set_StatusBarColor: " & clr, ColorLog, False)
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
	MyLog("General.Round_Image: " & imagem, ColorLog, False)
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
	MyLog("General.Size_textHorizontal: " & text, ColorLog, False)
	Private bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Private cvs As Canvas
	cvs.Initialize2(bmp)
	Return cvs.MeasureStringWidth(text, lb.Typeface , lb.TextSize)
End Sub

Sub setPadding(v As View, Left As Int, Top As Int, Right As Int, Bottom As Int)
	MyLog("General.setPadding", ColorLog, False)
	Dim jo = v As JavaObject
	jo.RunMethod("setPadding", Array As Object(Left, Top, Right, Bottom))
End Sub

Public Sub EncKey(txt As String) As String
	
	Dim secure As SecureMyText
		secure.Initialize("", "datacode")
	
	Dim enc As String = secure.EncryptToFinalTransferText(txt) 
	'secure.encrypt("Bearer sk-AAAAAAAAAAAAAAAAAAAAAAAA")
	
	Return enc
	
End Sub

Public Sub DecKey(txt As String) As String

	If (IsNull(txt)) Then Return ""
	
	Dim secure As SecureMyText
		secure.Initialize("", "datacode")
	
	Dim dec As String = secure.decrypt(txt)
	
	Return dec
	
End Sub

Public Sub PlaySound
	Try
		Dim media As MediaPlayer
			media.Initialize
			media.SetVolume(0.5, 0.5)
			media.Load(File.DirAssets, "Notice.mp3")
			media.Play
	Catch
		Log("General.PlaySound: " & LastException)
	End Try
End Sub

'Dim rm As RingtoneManager
'PlayRingtone(rm.GetDefault(rm.TYPE_NOTIFICATION))
Public Sub PlayRingtone(url As String)
	Dim jo As JavaObject
		jo.InitializeStatic("android.media.RingtoneManager")
	Dim jo2 As JavaObject
		jo2.InitializeContext
	Dim u As Uri
		u.Parse(url)
	jo.RunMethodJO("getRingtone", Array(jo2, u)).RunMethod("play", Null)
	
End Sub
