B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.2
@EndOfDesignText@
#Region Attributes 
	#IgnoreWarnings: 9
#End Region

Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

'translate("Welcome to new york and have a nice day","en","de")
Public Sub translate(text As String,source As String , destination As String)
	Dim job As HttpJob
 
	Dim transtr As String = text
	Dim jobname As String = "xlate"
	Dim jobtag As String = "french"

	job.Initialize(jobname, Me)
	job.Tag = jobtag

	' Use Google Free google API translate
	Dim srclang As String = source
	Dim dstlang As String = destination
	
	Dim poststr As String = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" & _
    srclang & "&tl=" & dstlang & "&dt=t&q=" & transtr
	Log(poststr)
	
	job.PostString(poststr, "")
	
	job.GetRequest.SetHeader("Content-Type", "application/json")
	job.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0")
	job.GetRequest.SetContentType("application/json")
	job.GetRequest.SetContentEncoding("text/plain")
'	job.GetRequest.SetContentEncoding("UTF8")
	
	Dim response As String
	
	LogColor("Bart: " & job, Colors.Black)
	
	Wait For (job) Complete(j As HttpJob) 'JobDone
'	Wait For (wrk_chat.Query(questionHolder, question, assistant, Temperature, AIType)) Complete (response As String)
	
	If j.Success Then
		
		'Raw JSON Response
		LogColor("Bart Respose: " & job.GetString, Colors.Blue)
		Dim trans As String = job.GetString
'		trans = job.pars(trans)
		
		Dim parser As JSONParser
		parser.Initialize(job.GetString)
		
		Dim txt As List
		txt = MyParser(job.GetString)
		If (response <> "") Then response = response & CRLF
'		response = response & txt
		LogColor("Bart Respose2: " & txt, Colors.Gray)
		
	End If
	
	job.Release
	
'	Return response
	
End Sub

Sub MyParser(js As String) As List ' returns list of string arrays
	Dim rlst As List
	Dim sa1(), str As String
	Dim p As Int
 
	rlst.Initialize
 
	sa1 = Regex.Split("]", js)
 
	For Each s1 As String In sa1
		p = s1.LastIndexOf("[")
		If (p < 0) Then Continue
    
		str = s1.SubString2(p + 1, s1.Length)
		str = str.Replace(QUOTE, "")
    
		Dim sa2() As String = Regex.Split(",", str)
		rlst.Add(sa2)
	Next
 
	Return(rlst)
End Sub
