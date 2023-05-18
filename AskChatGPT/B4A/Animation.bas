B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=12.2
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	'### DrawHouse
	'###
	Private cvsHouse As B4XCanvas
	
End Sub

'// Clear Canvas
Private Sub ClearCanvas(cvs As Canvas)
	cvs.DrawColor(Colors.Transparent)
End Sub

Public Sub AnimateBorder(View As View)
	Dim n As Long = DateTime.Now
	Dim duration As Int = 500
	Dim start As Float = 0
	Dim tempValue As Float
	Dim cvs As Canvas
		cvs.Initialize(View)
		cvs.DrawColor(Colors.Transparent)
	Do While DateTime.Now < n + duration
		tempValue = ValueFromTimeLinear(DateTime.Now - n, start, 100 - start, duration)
		DrawValue(View, cvs, tempValue)
		Sleep(10)
	Loop
	DrawValue(View, cvs, 100)
	
End Sub

Private Sub DrawValue(View As View, cvs As Canvas, Value As Float)
	Dim clr As Int = Colors.White
	Dim StrokeWidth As Int = 4dip
	Dim cx = View.Width / 2 As Float
	Dim width As Float = View.Width / 50 * Min(50, Value)
	cvs.DrawLine(cx - width / 2, 0, cx + width / 2, 0, clr, StrokeWidth)
	cvs.DrawLine(cx - width / 2, View.Height, cx + width / 2, View.Height, clr, StrokeWidth)
	If Value > 50 Then
		Dim height As Float = View.Height / 50 * (Value - 50)
		cvs.DrawLine(0, 0, 0, height / 2, clr, StrokeWidth)
		cvs.DrawLine(0, View.Height, 0,  View.Height - height / 2, clr, StrokeWidth)
		cvs.DrawLine(View.Width, 0, View.Width, height / 2, clr, StrokeWidth)
		cvs.DrawLine(View.Width, View.Height, View.Width, View.Height - height / 2, clr, StrokeWidth)
	End If
	View.Invalidate
End Sub

Private Sub ValueFromTimeLinear(Time As Int, Start As Float, ChangeInValue As Float, Duration As Int) As Float 'ignore
	Return ChangeInValue * Time / Duration + Start
End Sub

'##############
'##############

Private Sub DrawValueProgressive(view As View, cvs As Canvas, value As Float,clr As Int)

 
	Select Floor(value/25)
		Case 0
			Dim width As Float = view.Width / 25 * Min(25, value)
			cvs.DrawLine(0,0,width,0,Colors.White,4dip)
		Case 1
			Dim height As Float = view.Height / 25 * (value-25)
			cvs.DrawLine(view.width,0,view.width,height,Colors.White,4dip)
			cvs.DrawLine(0,0,view.Width,0,Colors.White,4dip)
		Case 2
			Dim width As Float = view.Width / 25 * (value-50)
			cvs.DrawLine(view.Width,view.Height,view.Width-width,view.Height,Colors.White,4dip)
			cvs.DrawLine(0,0,view.Width,0,Colors.White,4dip)
			cvs.DrawLine(view.Width,0,view.Width,view.Height,Colors.White,4dip)
		Case 3
			Dim height As Float = view.Height / 25 * (value-75)
			cvs.DrawLine(0,view.Height,0,view.Height-height,Colors.White,4dip)
			cvs.DrawLine(0,0,view.Width,0,Colors.White,4dip)
			cvs.DrawLine(view.Width,0,view.Width,view.Height,Colors.White,4dip)
			cvs.DrawLine(view.Width,view.Height,0,view.Height,Colors.White,4dip)
	End Select
	view.Invalidate
End Sub

Public Sub AnimateBorderProgressive(view As View)
	Dim n As Long = DateTime.Now
	Dim duration As Int = 250
	Dim start As Float = 0
	Dim tempValue As Float
	Dim cvs As Canvas
	cvs.Initialize(view)
	cvs.DrawColor(Colors.Transparent)
	Do While DateTime.Now < n + duration
		tempValue = ValueFromTimeLinear(DateTime.Now - n, start, 100 - start, duration)
		DrawValueProgressive(view,cvs,tempValue,Colors.White)
		Sleep(10)
	Loop
	DrawValueProgressive(view, cvs, 100,Colors.White)
End Sub



'#################
'#################


Public Sub ABProgressiveMeet (view As View)
	Dim n As Long = DateTime.Now
	Dim duration As Int = 500
	Dim start As Float = 0
	Dim tempValue As Float
	Dim cvs As Canvas
	cvs.Initialize(view)
	cvs.DrawColor(Colors.Transparent)
	Do While DateTime.Now < n + duration
		tempValue = ValueFromTimeLinear(DateTime.Now - n, start, 100 - start, duration)
		DWProgressiveMeet(view,cvs,tempValue,Colors.White)
		Sleep(10)
	Loop
	DrawValueProgressive(view, cvs, 100,Colors.White)
End Sub

Private Sub DWProgressiveMeet(view As View, cvs As Canvas, value As Float,clr As Int)
	Dim StrokeWidth As Int = 4dip
	Dim width As Float = view.Width / 50 * Min(50, value)
	Dim height As Float = view.Height / 50 * Min(50, value)
	cvs.DrawLine(0, 0, width, 0, clr, StrokeWidth)
	cvs.DrawLine(0,0,0,height, clr, StrokeWidth)
	If value > 50 Then
		Dim width As Float = view.Width / 50 * (value-50)
		Dim height As Float = view.Height / 50 *  (value-50)
		cvs.DrawLine(0, 0, 0, view.height, clr, StrokeWidth)
		cvs.DrawLine(0, 0,  view.Width, 0,clr, StrokeWidth)
		cvs.DrawLine(0, view.Height, width,view.Height,  clr, StrokeWidth)
		cvs.DrawLine(view.Width, 0, view.Width, height, clr, StrokeWidth)
	End If
	view.Invalidate
End Sub


'################## Draw House
'##################

Private Sub DrawLineAnimated(Duration As Int, Steps As Int, StartX As Float, StartY As Float, EndX As Float, EndY As Float, Invalidate As Boolean)
	#if DEBUG
	Steps = Steps / 2
	#End If
	Dim StrokeWidth As Float = 4dip
	Dim StrokeColor As Int = 0xFFFFFA00
	
	Dim len As Float = Sqrt(Power(EndX - StartX, 2) + Power(EndY - StartY, 2)) / Steps
	Dim angle As Float = ATan2D(EndY - StartY, EndX - StartX)
	Dim x1, x2, y1, y2 As Float
	For i = 0 To Steps - 1
		x1 = StartX + len * i * CosD(angle)
		x2 = StartX + len * (i + 1) * CosD(angle)
		y1 = StartY + len * i * SinD(angle)
		y2 = StartY + len * (i + 1) * SinD(angle)
		cvsHouse.DrawLine(x1, y1, x2, y2, StrokeColor, StrokeWidth)
		If Invalidate Then
			cvsHouse.Invalidate
		End If
		Sleep(Duration / Steps)
	Next
End Sub

'DrawHouse(mainparent, clvMessages.sv.Left + 5dip, clvMessages.sv.Top + clvMessages.sv.Width / 2, 1000)
Public Sub DrawHouse (Parent As B4XView, TargetX As Float, TargetY As Float, VisibleDuration As Int)
	
	Dim xui As XUI
	Dim base As B4XView
		base = xui.CreatePanel("")
		base.SetLayoutAnimated(0, 0, 0, 200dip, 200dip)
		base.Enabled = False
	cvsHouse.Initialize(base)
	
	Parent.AddView(base, TargetX, TargetY, base.Width, base.Height)
	cvsHouse.ClearRect(cvsHouse.TargetRect)
	Dim duration As Int = 300
	DrawLineAnimated(duration, 20, 10dip, 100dip, 110dip, 100dip, True)
	Sleep(duration)
	DrawLineAnimated(duration, 20, 110dip, 100dip, 110dip, 200dip, True)
	Sleep(duration)
	DrawLineAnimated(duration, 20, 110dip, 200dip, 10dip, 200dip, True)
	Sleep(duration)
	DrawLineAnimated(duration, 20, 10dip, 200dip, 10dip, 100dip, True)
	Sleep(duration)
	DrawLineAnimated(duration, 20, 10dip, 100dip, 110dip, 200dip, False) 'It will be invalidated in the next line
	DrawLineAnimated(duration, 20, 110dip, 100dip, 10dip, 200dip, True)
	Sleep(duration)
	DrawLineAnimated(duration, 20, 10dip, 100dip, 60dip, 50dip, False)
	DrawLineAnimated(duration, 20, 110dip, 100dip, 60dip, 50dip, True)
	Sleep(duration)
	Sleep(VisibleDuration)
	base.SetVisibleAnimated(100, False)
	Sleep(100)
	base.RemoveViewFromParent
	cvsHouse.Release
End Sub
