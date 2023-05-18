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
	Dim strokewidth As Int = 4dip
	Dim cx = View.Width / 2 As Float
	Dim width As Float = View.Width / 50 * Min(50, Value)
	cvs.DrawLine(cx - width / 2, 0, cx + width / 2, 0, clr, strokewidth)
	cvs.DrawLine(cx - width / 2, View.Height, cx + width / 2, View.Height, clr, strokewidth)
	If Value > 50 Then
		Dim height As Float = View.Height / 50 * (Value - 50)
		cvs.DrawLine(0, 0, 0, height / 2, clr, strokewidth)
		cvs.DrawLine(0, View.Height, 0,  View.Height - height / 2, clr, strokewidth)
		cvs.DrawLine(View.Width, 0, View.Width, height / 2, clr, strokewidth)
		cvs.DrawLine(View.Width, View.Height, View.Width, View.Height - height / 2, clr, strokewidth)
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
	Dim strokewidth As Int = 4dip
	Dim width As Float = view.Width / 50 * Min(50, value)
	Dim height As Float = view.Height / 50 * Min(50, value)
	cvs.DrawLine(0, 0, width, 0, clr, strokewidth)
	cvs.DrawLine(0,0,0,height, clr, strokewidth)
	If value > 50 Then
		Dim width As Float = view.Width / 50 * (value-50)
		Dim height As Float = view.Height / 50 *  (value-50)
		cvs.DrawLine(0, 0, 0, view.height, clr, strokewidth)
		cvs.DrawLine(0, 0,  view.Width, 0,clr, strokewidth)
		cvs.DrawLine(0, view.Height, width,view.Height,  clr, strokewidth)
		cvs.DrawLine(view.Width, 0, view.Width, height, clr, strokewidth)
	End If
	view.Invalidate
End Sub


'##################
'##################

