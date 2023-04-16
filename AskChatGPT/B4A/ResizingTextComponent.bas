﻿B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.2
@EndOfDesignText@
#Event: Click
#Event: LongClick
#DesignerProperty: Key: TextColor, DisplayName: Name Color, FieldType: Color, DefaultValue: 0xFF000000, Description: Text Colour
#DesignerProperty: Key: BackColor, DisplayName: Background Color, FieldType: Color, DefaultValue: 0xFFFFFFFF, Description: Background Color

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	Private xui As XUI 'ignore
	Public Tag As Object
	
	Private tclr As Int
	Private bclr As Int
	Private mcorn As Int
	Private txt As Object
	Private tfnt As B4XFont

	Private lpad As Int
	Private rpad As Int
	Private tpad As Int
	Private bpad As Int

	Private mlbl As B4XView
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, lbl As Label, Props As Map)
	mBase = Base
    Tag = mBase.Tag
	mBase.Tag = Me
	mBase.Color = Colors.Transparent
	
	tclr = xui.PaintOrColorToColor(Props.Get("TextColor"))
	bclr = xui.PaintOrColorToColor(Props.Get("BackColor"))
	#if b4a
	tfnt = xui.CreateFont(lbl.Typeface,lbl.textsize)
	#else	
	tfnt = lbl.Font
	#End If

	txt  = ""
	
	lpad = 10dip
	rpad = 10dip
	tpad = 10dip
	bpad = 10dip
	mcorn = 0
	
	Private llbl As Label
	
	llbl.Initialize("lbl")
	#if b4i
	llbl.Multiline = True
	#end if	
	mlbl = llbl
	
	mBase.AddView(mlbl,lpad,tpad,mBase.Width-(lpad+rpad),mBase.Height-(tpad+bpad))
	
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
	mlbl.SetLayoutAnimated(0,lpad,tpad,mBase.Width-(lpad+rpad),mBase.Height-(tpad+bpad))
	draw
End Sub

'Public Sub TextValue As String
'	Return txt 'mlbl.Text
'End Sub

public Sub setText(t As Object)
	txt = t
	draw
End Sub

public Sub setTextColor(clr As Int)
	tclr = clr
	draw
End Sub

public Sub SetBackColor(clr As Int)
	bclr = clr
	draw
End Sub


public Sub SetTextFont(fnt As B4XFont)
	tfnt = fnt
	draw
End Sub

public Sub SetPadding(l As Int, t As Int, r As Int, b As Int)
	lpad = l
	tpad = t
	rpad = r
	bpad = b
	draw
End Sub

public Sub SetCorners(c As Int)
	mcorn = c
	draw
End Sub

public Sub GetHeight As Int
	Return GetPerfectHeight
End Sub

'Vertical:		Horizontal:
' Gravity.Top	Gravity.Left
' Gravity.Center	Gravity.Center
' Gravity.Bottom	Gravity.Right
Public Sub SetTextAlling(vertical As String, horizontal As String)
	mlbl.SetTextAlignment(vertical.ToUpperCase, horizontal.ToUpperCase)
End Sub

private Sub draw
	If (mBase.IsInitialized And mlbl.IsInitialized) Then
		mBase.SetColorAndBorder(bclr,0dip,Colors.Transparent,mcorn)
		
		mBase.SetLayoutAnimated(0,0,0,mBase.Width,GetPerfectHeight)
		mlbl.SetLayoutAnimated(0,lpad,tpad,mBase.Width-(lpad+rpad),mBase.Height-(tpad+bpad))
		
		mlbl.Font = tfnt
		mlbl.TextColor = tclr
		mlbl.Color = bclr
	
		XUIViewsUtils.SetTextOrCSBuilderToLabel(mlbl,txt)
		
	End If
End Sub


#Region multiline DrawText
public Sub GetPerfectHeight As Int
	
	If mlbl.IsInitialized Then
		Private h As Int = (MeasureMultiTextHeight(mlbl, mBase.Width-(lpad+rpad), txt) + tpad + bpad)
'		Log("perfect height = "&h)
		Return h
	End If
'	Log("imperfect height = "&mBase.Height)
	Return mBase.Height
End Sub

Public Sub MeasureMultiTextHeight(lbl As Label, width As Int, Text As Object) As Int
	#if b4a
	Private su As StringUtils
	Return su.MeasureMultilineTextHeight(lbl, Text)
	#else if b4i
	Dim plbl As Label
	plbl.Initialize("")
	plbl.Width = width
	plbl.Multiline = True
	XUIViewsUtils.SetTextOrCSBuilderToLabel(plbl,text)
	plbl.SizeToFit	
	Return plbl.Height
	#End If
	
End Sub

#End Region

#Region Click

Private Sub mlbl_Click
	
	mlbl_click_handler(Sender)
	
End Sub

Private Sub mlbl_LongClick
	
	mlbl_longclick_handler(Sender)
	
End Sub

private Sub mlbl_click_handler(SenderPanel As B4XView)
	
	If xui.SubExists(mCallBack, mEventName & "_Click",0) Then
		CallSub(mCallBack, mEventName & "_Click")
	End If
	
End Sub

private Sub mlbl_longclick_handler(SenderPanel As B4XView)
	
	If xui.SubExists(mCallBack, mEventName & "_LongClick",0) Then
		CallSub(mCallBack, mEventName & "_LongClick")
	End If
	
End Sub

#End Region
