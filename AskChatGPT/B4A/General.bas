B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=12.2
@EndOfDesignText@

Sub Process_Globals
	Private xui As XUI
End Sub

#Region Save and Load Settings

Public Sub SaveSetting
	If Not (Main.Sett.IsInitialized) Then
		Main.Sett.Initialize(File.DirInternal, "ChatGPT.conf")
	End If
	
	Main.Sett.Put("FirstLang", Main.Pref.FirstLang)
	Main.Sett.Put("SecondLang", Main.Pref.SecondLang)
	Main.Sett.Put("Creativity", Main.Pref.Creativity)
	
End Sub

Public Sub LoadSetting
	If Not (Main.Sett.IsInitialized) Then
		Main.Sett.Initialize(File.DirInternal, "ChatGPT.conf")
	End If
	
	Main.Pref.FirstLang  = "English" 'sett.Get("FirstLang").As(String)
	Main.Pref.SecondLang = GetLangStr(Main.Sett.Get("SecondLang"))
	Main.Pref.Creativity = GetCreativityInt(Main.Sett.Get("Creativity"))
	LogColor("LoadSetting: " & Main.Pref.Creativity & " : " & Main.Sett.Get("Creativity"), Colors.Red)
	
End Sub
Private Sub GetLangStr(txt As Object) As String
	Try
		If (txt.As(String).Length < 0) Then Return "(None)"
		Return txt.As(String)
	Catch
		Return "(None)"
	End Try
End Sub

Private Sub GetCreativityInt(val As Object) As Int
	Try
		If IsNumber(val) Then
			If (val < 11) And (val > -1) Then
				Return val
			Else
				Return 5
			End If
		End If
		
		Return 5
		
	Catch
		Return 5
	End Try
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
