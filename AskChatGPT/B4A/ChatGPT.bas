﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.2
@EndOfDesignText@
#Region Attributes 
	#IgnoreWarnings: 12
#End Region

'This class is based on:
'https://www.b4x.com/android/forum/threads/gpt-3.145654/#content
'by Abdull Cadre
'
'All basically for my own education - many thanks to Abdull for doing all
'original research
Sub Class_Globals
	Private API_KEY 			As String
	Public TimeoutText 			As String = $"Timeout ${CRLF} Server is busy. Just try again. ${CRLF} سرور شلوغ است، مجددا امتحان کنید."$
	Public OpenApiHostError 	As String = $"api.openai.com is unreachable. ${CRLF} دسترسی به سرور وجود ندارد، اینترنت خود را چک کنید."$
	Public ConnectException 	As String = $"Internet is unreachable. ${CRLF} دسترسی به سرور وجود ندارد، اینترنت خود را چک کنید."$
	Public InstructureError 	As String = "Could not edit text. Please sample again or try with a different temperature setting, input, or instruction."
	
	Private Const MAXTOKEN 		As Int	= 2000
	Private Const TIMEOUT		As Int 	= 90000
	
'	Private conversationId 	As Int
'	Private parentMessageId As Int
'	Private messageId As Int
	Public ChatHistoryList As List
	
	Public Const AITYPE_Chat 			As Int	= 0
	Public Const AITYPE_Grammar 		As Int	= 1
	Public Const AITYPE_Translate 		As Int 	= 2
	Public Const AITYPE_Practice 		As Int	= 3
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
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
	
	ChatHistoryList.Initialize
	
'	LogColor("Initialize:" & dec, Colors.Red)
	
End Sub

'System String 	   : The System Message helps set the behavior of the assistant.
'		     example, the assistant should instructed with "You are a helpful assistant."
'User Messages 	   : User Question
'Assistant Messages : The Assistant Messages help store prior responses. They can also be written by a developer
' 					  To help give examples of desired behavior.
Public Sub Query(system_string As String, _
				 query_string As String, _
				 assistant_string As String, _
				 temperature As Double, _
				 AI_Type As Int) As ResumableSub
    Try
        'Following parameter explanations I have primarily taken from
        'https://accessibleai.dev/post/generating_text_with_gpt_and_python/
        'with a few additions from various googlings
		
        'More googling and I found the definitive source:
        'https://platform.openai.com/docs/api-reference/introduction
        'there are a lot more options than used in this class
 		
        '"n": 1
        'number of completions to generate
		'تعداد تکمیل‌هایی که باید تولید شوند
 		
        '"stop": "None" OR "."
        'an optional setting to control response generation
		'یک تنظیم اختیاری برای کنترل تولید پاسخ.
		
		'"model": "text-davinci-003" OR "gpt-3.5-turbo" OR "gpt-4"
		'model to be used
        'see https://beta.openai.com/docs/models/gpt-3
		'مدلی که باید استفاده شود
 		
        '"max_tokens": 350
        'maximum tokens in prompt AND response4
		'حداکثر تعداد توکن‌ها در پرسش و پاسخ
 		
        '"temperature": 0.5
        'level of creativity in response
        'a higher value means model will take more risks, try 0.9 for more
		'creative applications, and 0 for ones with a well-defined answer
'
'		"دما": 0.5
'		توضیح: اصطلاح "دما" به پارامتری اشاره دارد که بر روی تصادفی بودن یا خلاقیت خروجی مدل تأثیر می‌گذارد. در اینجا مقدار 0.5 مشخص شده است، که نشان‌دهنده یک سطح متوسط از خلاقیت در پاسخ مدل است. این بدان معنی است که مدل به خطراتی در تولید خروجی پاسخ می‌دهد، اما به میزانی نیست که بسیاری باشد.
'		
'		"سطح خلاقیت در پاسخ"
'		توضیح: این عبارت می‌تواند برای بیان میزان یا درجه خلاقیت در خروجی تولید شده توسط مدل استفاده شود. این نشان می‌دهد که تا چه حد خروجی‌های مدل نوآورانه و غیرمعمولی خواهند بود در هنگام تولید خروجی.
'		
'		ترجمه: "مقدار بالاتر به معنی بیشتر برداشتن خطرات توسط مدل است، برای برنامه‌های خلاقانه از 0.9 استفاده کنید"
'		توضیح: این جمله توضیح می‌دهد که افزایش مقدار پارامتر "دما" به مقدار بالاتری مانند 0.9، باعث می‌شود مدل در تولید خروجی بیشترین خطرات را بپذیرد. این می‌تواند منجر به برنامه‌های خلاقانه و غیرمعمولی باشد که خروجی آن‌ها کمتر قابل پیش‌بینی و نوآورانه‌تر باشد.
'		
'		"0 برای پاسخ‌هایی با پاسخ معرفی شده به‌خوبی"
'		توضیح: این جمله اشاره می‌کند که تنظیم پارامتر "دما" به مقدار 0، باعث می‌شود مدل خروجی تولیدی خود را به تأمین پاسخ‌های به‌خوبی تعبیه شده متمرکز کند. این در
		
		'role:system message 	 - The system message helps set the behavior of the assistant. example, the assistant should instructed with "You are a helpful assistant."
		'role:user messages 	 - The user messages help instruct the assistant. They can be generated by the end users of an Application, Or set by a developer As an instruction.
		'role:assistant messages - The assistant messages help store prior responses. They can also be written by a developer To help give examples of desired behavior.
		
'	/// <summary>
'	/// Ask the API To complete the prompt(s) using the specified parameters.  This Is non-streaming, so it will wait Until the API returns the full result.  Any non-specified parameters will fall back To default values specified in <see cref="DefaultCompletionRequestArgs"/> If present.
'	/// </summary>
'	/// <param name="prompt">The prompt To generate from</param>
'	/// <param name="model">The model To use. You can use <see cref="ModelsEndpoint.GetModelsAsync()"/> To see all of your available models, Or use a standard model like <see cref="Model.DavinciText"/>.</param>
'	/// <param name="max_tokens">How many tokens To complete To. Can Return fewer If a stop sequence Is hit.</param>
'	/// <param name="temperature">What sampling temperature To use. Higher values means the model will take more risks. Try 0.9 For more creative applications, And 0 (argmax sampling) For ones with a well-defined answer. It Is generally recommend To use this Or <paramref name="top_p"/> but Not both.</param>
'	/// <param name="top_p">An alternative To sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. It Is generally recommend To use this Or <paramref name="temperature"/> but Not both.</param>
'	/// <param name="numOutputs">How many different choices To request For Each prompt.</param>
'	/// <param name="presencePenalty">The scale of the penalty applied If a token Is already present at all.  Should generally be between 0 And 1, although negative numbers are allowed To encourage token reuse.</param>
'	/// <param name="frequencyPenalty">The scale of the penalty For how often a token Is used.  Should generally be between 0 And 1, although negative numbers are allowed To encourage token reuse.</param>
'	/// <param name="logProbs">Include the Log probabilities on the logprobs most likely tokens, which can be found in <see cref="CompletionResult.Completions"/> -> <see cref="Choice.Logprobs"/>. So For example, If logprobs Is 10, the API will Return a list of the 10 most likely tokens. If logprobs Is supplied, the API will always Return the logprob of the sampled token, so there may be up To logprobs+1 elements in the response.</param>
'	/// <param name="echo">Echo back the prompt in addition To the completion.</param>
'	/// <param name="stopSequences">One Or more sequences where the API will stop generating further tokens. The returned text will Not contain the stop sequence.</param>
		
		' Create a JSON object
		Dim json As Map
		
'		If (AI_Type = AITYPE_Grammar) Then
'			json.Initialize
'			json.Put("model", "text-davinci-edit-001")
'			json.Put("input", query_string)
'			json.Put("instruction", system_string)
'			json.Put("temperature", 0)
'			json.Put("top_p", 1)
'		
'		Else 
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
			Else ' Chat and AI
				Dim text 		As String  	= ParseJson(req.GetString, False, False)
				Dim endofconv 	As String 	= ParseJson(req.GetString, True, False)
				If (response <> "") Then response = response & CRLF
				response = response & text.Trim
				
				If (endofconv <> "stop") Then
					response = response & CRLF & "»»"
					resobj.Put("response", response)
					resobj.Put("continue", True)
				Else
					resobj.Put("response", response)
					resobj.Put("continue", True)
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
			
        End If
		
        req.Release
		
    Catch
		
		Dim response As String
			response = "ChatGPT:Query-> ERROR: " & LastException
		
		Dim resobj As Map
			resobj.Initialize
			resobj.Put("response", response)
			resobj.Put("continue", False)
		
	End Try
	
	Return resobj
	
End Sub

'I did as JohnC suggested in:
'https://www.b4x.com/android/forum/threads/lost-in-chatgpt-json.146738/post-930211
'and asked ChatGPT:
'using b4a how do I parse this json string: "{""id"":""chatcmpl-6t2JQdgU1ypn0ayhONAkE6bAEoGkz"",""object"":""chat.completion"",""created"":1678574948,""model"":""gpt-3.5-turbo-0301"",""usage"":{""prompt_tokens"":25,""completion_tokens"":110,""total_tokens"":135},""choices"":[{""message"":{""role"":""assistant"",""content"":""Ahoy matey, ye be askin' a great question. The worst investment be ones that promise quick riches without flappin' yer sails too much, like the \""get rich quick\"" schemes, ponzi schemes Or pyramid schemes. These scams be all about misuse of trust And deceivin' the inexperienced. They be luring investors with high promised returns, but in the end, they just take yer doubloons and disappear into the horizon. Stay away from such crooks and keep yer treasure safe, me hearty!""},""finish_reason"":""stop"",""index"":0}]}" for content
'and it responded with this - except it used a variable named "object" which
'B4A objected to that I had to change to "object_string"
'I also had to change the management of the variable "content" so the subroutine would return a result
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