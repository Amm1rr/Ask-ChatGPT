B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.45
@EndOfDesignText@
Sub Class_Globals
	Private sb 	As StringBuilder
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	sb.Initialize
End Sub

Private Sub Data_Available (Buffer() As Byte)
	
	Dim newDataStart As Int = sb.Length
	sb.Append(BytesToString(Buffer, 0, Buffer.Length, "UTF-8"))
	Dim s As String = sb.ToString
	Dim start As Int = 0
	Dim check As Boolean
'	Log("Inputed String: " & s)
	For i = newDataStart To s.Length - 1
		Dim c As Char = s.CharAt(i)
		If i = 0 And c = Chr(10) Then '\n...
			start = 1 'might be a broken end of line character
			Continue
		End If
		If c = Chr(10) Then '\n
			If Not (check) Then
'				Dim data As String = s.SubString2(6, i)
				Dim data As String = s
'				Log(data)
				Dim json As JSONParser
					json.Initialize(data)
'				Log(json)
				Dim root As Map
					root.Initialize
					root = json.NextObject
				Dim choices As List
					choices.Initialize
					choices = root.Get("choices")
				Dim sub_choices As Map
					sub_choices.Initialize
					sub_choices = choices.Get(0)
				Dim message As Map
					message.Initialize
					message = sub_choices.Get("message")
				Dim text As String = message.Get("content")
'				If Not (text = Null) Then Log(text)
				Log(text)
				CallSub2(Main, "StreamCallMain", text)
				start = i + 1
			End If
			check = True
		Else If c = Chr(13) Then '\r
'			Dim data As String = s.SubString2(6, i)
			Dim data As String = s'.SubString2(0, i)
'			If Not (data = Null) Then
			Log(data) 'Data  {"id:"xxxxxx"..}
			CallSub2(Main, "StreamCallMain", text)
			check = True
			If i < s.Length - 1 And s.CharAt(i + 1) = Chr(10) Then '\r\n
				i = i + 1
			End If
			start = i + 1
		End If
	Next
	check = False
	If start > 0 Then sb.Remove(0, start)
	
End Sub
