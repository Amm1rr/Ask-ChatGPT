B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.85
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	Private API_KEY 			As String
	Public TimeoutText 			As String = $"Timeout ${CRLF} Server is busy. Just try again. ${CRLF} سرور شلوغ است، مجددا امتحان کنید."$
	Public OpenApiHostError 	As String = $"api.openai.com is unreachable. ${CRLF} دسترسی به سرور وجود ندارد، اینترنت خود را چک کنید."$
	Public ConnectException 	As String = $"Internet is unreachable. ${CRLF} دسترسی به سرور وجود ندارد، اینترنت خود را چک کنید."$
	Public InstructureError 	As String = "Could not edit text. Please sample again or try with a different temperature setting, input, or instruction."
	
	Private Const MAXTOKEN 		As Int	= 2000
	Private Const TIMEOUT		As Int 	= 90000
	
	Public ChatHistoryList 	As List
	Public MessageList 		As List
	
	Public Const AITYPE_Chat 			As Int	= 0
	Public Const AITYPE_Grammar 		As Int	= 1
	Public Const AITYPE_Translate 		As Int 	= 2
	Public Const AITYPE_Practice 		As Int	= 3
	
End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	
'	Try
	
	Dim txt As String = "znBwhu5Qbc1ilhM1t00vWHMkw1Or8GnLVa1HcEdo5nOMTXWD0gfnptHyfx+mclYeB1U5kVYNXnKo" & CRLF & _
						"6yzr6luiTA=="  & CRLF & _
						"Y3mDBhBbd0I="  & CRLF & _
						"PIoruDtshkcBM0Vj4KQQMA=="
	
	Dim dec As String = General.DecKey(txt)
	
	If (General.IsNull(General.Pref.APIKEY)) Then
		API_KEY = dec
	Else
		API_KEY = $"Bearer ${General.Pref.APIKEY}"$
	End If
	
	MessageList.Initialize
	
	ChatHistoryList.Initialize
	
'	LogColor("Initialize:" & dec, Colors.Red)

End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub

Public Sub Query(system_string As String, _
				 query_string As String, _
				 assistant_string As String, _
				 temperature As Double, _
				 AI_Type As Int, _
				 QuestionIndex As Int) As ResumableSub
	Try
		' Create a JSON object
		Dim json As Map
		
		If (AI_Type = AITYPE_Translate) Or (AI_Type = AITYPE_Grammar) Then
			json.Initialize
			json.Put("model", "text-davinci-003")
			json.Put("prompt", query_string)
			Dim token As Int = query_string.Length + system_string.Length + assistant_string.Length
			Log("token: " & token)
			If (token >= MAXTOKEN) Then token = MAXTOKEN
			json.Put("max_tokens", token)
			json.Put("temperature", 0)
			json.Put("top_p", 1)
			json.Put("frequency_penalty", 0)
			json.Put("presence_penalty", 0)
			
		Else ' AI - Chat
			json.Initialize
			json.Put("model", "gpt-3.5-turbo")
'			json.Put("model", "gpt-4")
			json.Put("n", 1)
			json.Put("stop", "stop")
			json.Put("max_tokens", MAXTOKEN)
			If (AI_Type = AITYPE_Chat) Then json.Put("temperature", 0.10)
			json.Put("temperature", temperature)
			json.Put("stream", False)
			
			' Create an array of messages
			Dim messages As List
			messages.Initialize
			Dim systemMessage As Map
			systemMessage.Initialize
			systemMessage.Put("role", "system")
			systemMessage.Put("content", system_string)
			messages.Add(systemMessage)
			Dim userMessage As Map
			userMessage.Initialize
			userMessage.Put("role", "user")
			userMessage.Put("content", query_string)
			messages.Add(userMessage)
			Dim assistantMessage As Map
			assistantMessage.Initialize
			assistantMessage.Put("role", "assistant")
			assistantMessage.Put("content", assistant_string)
			
			messages.Add(assistantMessage)
			
			If (General.Pref.Memory) Then
				
				If (ChatHistoryList.Size < 1) Then
					ChatHistoryList.Add(systemMessage)
					ChatHistoryList.Add(assistantMessage)
					ChatHistoryList.Add(userMessage)
				Else
					ChatHistoryList.Add(userMessage)
					ChatHistoryList.Add(assistantMessage)
				End If
				
				json.Put("messages", ChatHistoryList)
				
			Else
				
				json.Put("messages", messages)
			End If
			
		End If
		
		Dim js As JSONGenerator
		js.Initialize(json)
		
		'Raw JSON String Generated
'		LogColor("Param: " & js.ToString, Colors.Magenta)
 		
		Dim response 	As String
		Dim resobj 		As Map
		resobj.Initialize
 		
		Dim req 		As HttpJob
		req.Initialize("", Me)
		
		'https://chat.openai.com/backend-api/conversation
		Select AI_Type
			
			Case AITYPE_Chat, AITYPE_Practice
				req.PostString("https://api.openai.com/v1/chat/completions", js.ToString)
				
'			Case AITYPE_Grammar
'				req.PostString("https://api.openai.com/v1/edits", js.ToString)
				
			Case AITYPE_Translate, AITYPE_Grammar
				req.PostString("https://api.openai.com/v1/completions", js.ToString)
			
				
		End Select
		
		'Abdull has supplied his own account API key which is very generous of
		'him but you should not use it
		'req.GetRequest.SetHeader("Authorization","Bearer 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")
 
		'You can quite easily generate your own account API key by following
		'https://accessibleai.dev/post/generating_text_with_gpt_and_python/
		'under heading [Getting a GPT-3 API Key]
		req.GetRequest.SetHeader("Authorization", API_KEY)
		LogColor("API Key: " & API_KEY, Colors.Magenta)
 
		'If you generate your own account API key then Abdull's organisation
		'key will be of no use to you
		'req.GetRequest.SetHeader("OpenAI-Organization", "org-TV3YOqDRg5DXvAUcL7dC6lI9")
 
		'If your account default organisation is "Personal" then you can supply
		'a blank organisation key - or just comment this line out
		req.GetRequest.SetHeader("OpenAI-Organization", "")
		req.GetRequest.SetContentType("application/json")
		req.GetRequest.SetContentEncoding("UTF8")
		req.GetRequest.Timeout = TIMEOUT
		
		Wait For (req) JobDone(req As HttpJob)
		
		If req.Success Then
			
			'Raw JSON Response
'			LogColor("Respose: " & req.GetString, Colors.Blue)
			
'			conversationId = ParseJson(req.GetString, False, True)
			
			Dim parser As JSONParser
			parser.Initialize(req.GetString)
			
'			If (AI_Type = AITYPE_Grammar) Then
'				Dim text 		As String  	= ParseJSONEditMode(req.GetString)
'				If (response <> "") Then response = response & CRLF
'				response = response & text.Trim
'				resobj.Put("response", response)
'				resobj.Put("continue", False)
'			Else 
			If (AI_Type = AITYPE_Translate) Or (AI_Type = AITYPE_Grammar) Then
				Dim text 		As String  	= ParseJSONTranslate(req.GetString)
				If (response <> "") Then response = response & CRLF
				response = response & text.Trim
				resobj.Put("response", response)
				resobj.Put("continue", False)
				resobj.Put("QuestionIndex", QuestionIndex)
			Else ' Chat and AI
				Dim text 		As String  	= ParseJson(req.GetString, False, False)
				Dim endofconv 	As String 	= ParseJson(req.GetString, True, False)
				If (response <> "") Then response = response & CRLF
				response = response & text.Trim
				
				If (endofconv <> "stop") Then
					response = response & CRLF & "»»"
					resobj.Put("response", response)
					resobj.Put("continue", True)
					resobj.Put("QuestionIndex", QuestionIndex)
				Else
					resobj.Put("response", response)
					resobj.Put("continue", True)
					resobj.Put("QuestionIndex", QuestionIndex)
				End If
				
				'اگه جواب قبلی که بهمون داده رو بهش ارسال نکنیم، توی توکن خیلی صرفه جویی میشه
				'ولی خب مثلا یک سوال رو اگه پشت سر هم ازش بپرسی بازم همون جواب و میده
				If (General.Pref.Memory) Then
					Dim assistantMessage As Map
						assistantMessage.Initialize
						assistantMessage.Put("role", "assistant")
						assistantMessage.Put("content", response)
					ChatHistoryList.Add(assistantMessage)
				End If
			End If
			
		Else
			
			If req.ErrorMessage.Contains("java.net.SocketTimeoutException") Then
				response = TimeoutText
			Else If (req.ErrorMessage.Contains("java.net.UnknownHostException")) Then
				response = OpenApiHostError
			Else If (req.ErrorMessage.Contains("java.net.ConnectException")) Then
				response = OpenApiHostError
			Else if (req.ErrorMessage = "Could not edit text. Please sample again or try with a different temperature setting, input, or instruction.") Then
				response = InstructureError
			Else
				response = "ChatGPT:Query-> Unsuccess: " & req.ErrorMessage
			End If
			
'			If (req.ErrorMessage = "java.net.SocketTimeoutException: timeout") Then
'				response = TimeoutText
'			Else If (req.ErrorMessage = "java.net.UnknownHostException: Unable to resolve host ""api.openai.com"": No address associated with hostname") Then
'				response = OpenApiHostError & " (Code 1)"
'			Else If (req.ErrorMessage = "java.net.ConnectException: Failed to connect to api.openai.com/104.18.7.192:443") Then
'				response = OpenApiHostError & " (Code 2)"
'			Else if (req.ErrorMessage = "Could not edit text. Please sample again or try with a different temperature setting, input, or instruction.") Then
'				response = InstructureError
'			Else
'				response = "ChatGPT:Query-> ERROR Unsuccess: " & req.ErrorMessage
'			End If

			resobj.Put("response", response)
			resobj.Put("continue", False)
			resobj.Put("QuestionIndex", QuestionIndex)
			
		End If
		
		req.Release
		
	Catch
		
		Dim response As String
			response = "ChatGPT:Query-> ERROR: " & LastException
			
		Dim resobj As Map
			resobj.Initialize
			resobj.Put("response", response)
			resobj.Put("continue", False)
			resobj.Put("QuestionIndex", QuestionIndex)
			
	End Try
	
	Dim count As Int = MessageList.Size - 1
	
	Log("response: " & response)
	
	For i = 0 To count
		
		Dim stack As Map = MessageList.Get(i)
		Dim indx As Int = stack.Get("QuestionIndex")
		
		Log("idx : " & indx)
		Log("stack : " & stack)
		Log("MessageList: " & MessageList)
		Log("-----")
		Log(QuestionIndex & " : " & indx)
		If (indx = QuestionIndex) Then
			Log("indx = QuestionIndex")
			MessageList.RemoveAt(i)
			
			stack.Initialize
			stack.Put("QuestionIndex", indx)
			stack.Put("Response", response)
			Log("Stack => " & stack)
			MessageList.Add(stack)
			
		End If
		
	Next
	
	LogColor("Worked: " & MessageList, Colors.Magenta)
	LogColor("Worked: " & resobj, Colors.Blue)
	
	StartActivity(Main)
	
	Return resobj
	
End Sub

Private Sub ParseJson(json As String, CheckEndOfConv As Boolean, getID As Boolean) As String
	Dim parser As JSONParser
	parser.Initialize(json)
	Dim root As Map
	root = parser.NextObject
	Dim id As String
	id = root.Get("id")
'	Dim object_string As String
'		object_string = root.Get("object")
'	Dim created As Long
'		created = root.Get("created")
'	Dim model As String
'		model = root.Get("model")
'	Dim usage As Map
'		usage = root.Get("usage")
'	Dim promptTokens As Int
'		promptTokens = usage.Get("prompt_tokens")
'	Dim completionTokens As Int
'		completionTokens = usage.Get("completion_tokens")
'	Dim totalTokens As Int
'		totalTokens = usage.Get("total_tokens")
	Dim choices As List
	choices = root.Get("choices")
	Dim choiceIndex As Int
	Dim content As String
	For choiceIndex = 0 To choices.Size - 1
		Dim choice As Map
		choice = choices.Get(choiceIndex)
		Dim message As Map
		message = choice.Get("message")
		Dim role As String
		role = message.Get("role")
		If content <> "" Then content = content & CRLF
		content = content & message.Get("content")
		Dim finishReason As String
		finishReason = choice.Get("finish_reason")
		If (CheckEndOfConv) Then _
			content = finishReason
		Log("Choice " & choiceIndex)
		Log("Role: " & role)
		Log("Content: " & content)
		Log("Finish Reason: " & finishReason)
	Next
	If (getID) Then content = id
	Return content
End Sub

Private Sub ParseJSONEditMode(json As String) As String 'As Map
	Dim parser As JSONParser
	parser.Initialize(json)

	Dim root As Map = parser.NextObject
	Dim result As Map
	result.Initialize

	result.Put("object", root.Get("object"))
	result.Put("created", root.Get("created"))

	Dim choices As List = root.Get("choices")
	Dim choice As Map = choices.Get(0)
	result.Put("text", choice.Get("text"))
	result.Put("index", choice.Get("index"))

	Dim usage As Map = root.Get("usage")
	result.Put("prompt_tokens", usage.Get("prompt_tokens"))
	result.Put("completion_tokens", usage.Get("completion_tokens"))
	result.Put("total_tokens", usage.Get("total_tokens"))

	'    Return result
	Return choice.Get("text")
End Sub

Private Sub ParseJSONTranslate(jsonString As String) As String 'As Map
	Dim JSON As JSONParser
	JSON.Initialize(jsonString)
	Dim root As Map = JSON.NextObject
    
	Dim id As String = root.Get("id")
	Dim obj As String = root.Get("object")
	Dim created As Long = root.Get("created")
	Dim model As String = root.Get("model")
    
	Dim choices As List = root.Get("choices")
	Dim choice As Map = choices.Get(0)
	Dim text As String = choice.Get("text")
	Dim index As Int = choice.Get("index")
	Dim logprobs As Object = choice.Get("logprobs")
	Dim finish_reason As String = choice.Get("finish_reason")
    
	Dim usage As Map = root.Get("usage")
	Dim prompt_tokens As Int = usage.Get("prompt_tokens")
	Dim completion_tokens As Int = usage.Get("completion_tokens")
	Dim total_tokens As Int = usage.Get("total_tokens")
    
	Dim parsedData As Map
	parsedData.Initialize
	parsedData.Put("id", id)
	parsedData.Put("object", obj)
	parsedData.Put("created", created)
	parsedData.Put("model", model)
	parsedData.Put("text", text)
	parsedData.Put("index", index)
	parsedData.Put("logprobs", logprobs)
	parsedData.Put("finish_reason", finish_reason)
	parsedData.Put("prompt_tokens", prompt_tokens)
	parsedData.Put("completion_tokens", completion_tokens)
	parsedData.Put("total_tokens", total_tokens)
    
	'    Return parsedData
	Return text
End Sub
