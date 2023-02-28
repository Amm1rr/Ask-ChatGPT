B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.2
@EndOfDesignText@
'This class is based on:
'https://www.b4x.com/android/forum/threads/gpt-3.145654/#content
'by Abdull Cadre
'
'All I have done is extract Abdull's code essential component (subroutine
'[generate_gpt3_response] in [ChatUI] activity) turned it into a class, tidied
'it up a bit, anglicized it and documented extensively
'
'All basically for my own education - many thanks to Abdull for doing all
'original research
Sub Class_Globals
	Private API_KEY As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	Dim secure As SecureMyText
		secure.Initialize("", "datacode")
'	Dim enc As String = secure.EncryptToFinalTransferText("Bearer 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") 't.encrypt("Bearer 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")
'	LogColor(enc, Colors.Red)
	Dim enc As String = "znBwhu5Qbc1ilhM1t00vWHMkw1Or8GnLVa1HcEdo5nOMTXWD0gfnptHyfx+mclYeB1U5kVYNXnKo" & CRLF & _
						"6yzr6luiTA=="  & CRLF & _
						"Y3mDBhBbd0I="  & CRLF & _
						"PIoruDtshkcBM0Vj4KQQMA=="
	Dim dec As String = secure.decrypt(enc)
'	LogColor(dec, Colors.Red)
	API_KEY = dec
End Sub

Public Sub Query(query_string As String) As ResumableSub
 
    Try
 
        'Following parameter explanations I have primarily taken from
        'https://accessibleai.dev/post/generating_text_with_gpt_and_python/
        'with a few additions from various googlings

        'More googling and I found the definitive source:
        'https://platform.openai.com/docs/api-reference/introduction
        'there are a lot more options than used in this class
 
        '"n": 1
        'number of completions to generate
 
        '"stop": "None"
        'an optional setting to control response generation

        '"model": "text-davinci-003"
        'model to be used
        'see https://beta.openai.com/docs/models/gpt-3
 
        '"max_tokens": 350
        'maximum tokens in prompt AND response
 
        '"temperature": 0.5
        'level of creativity in response
        'a higher value means model will take more risks, try 0.9 for more
        'creative applications, and 0 for ones with a well-defined answer
		
        Dim m As Map = CreateMap("n": 1, "stop": "None", "model": "text-davinci-003", _
                                 "prompt": query_string, "max_tokens": 350, "temperature": 0.5)
		
        Dim js As JSONGenerator
        	js.Initialize(m)
		
		'Uncomment this if you want to see raw JSON string generated
		'Log(js.ToString)
 		
		Dim response As String
 		
		Dim req As HttpJob
	        req.Initialize("", Me)
	        req.PostString("https://api.openai.com/v1/completions", js.ToString)
 
        'Abdull has supplied his own account API key which is very generous of
        'him but you should not use it
        'req.GetRequest.SetHeader("Authorization","Bearer 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")
 
        'You can quite easily generate your own account API key by following
        'https://accessibleai.dev/post/generating_text_with_gpt_and_python/
        'under heading [Getting a GPT-3 API Key]
		req.GetRequest.SetHeader("Authorization", API_KEY)
 
        'If you generate your own account API key then Abdull's organisation
        'key will be of no use to you
        'req.GetRequest.SetHeader("OpenAI-Organization", "org-TV3YOqDRg5DXvAUcL7dC6lI9")
 
        'If your account default organisation is "Personal" then you can supply
        'a blank organisation key - or just comment this line out
        req.GetRequest.SetHeader("OpenAI-Organization", "")
 
        req.GetRequest.SetContentType("application/json")
 
        Wait For (req) JobDone(req As HttpJob)
 
        If req.Success Then
  
            'Uncomment this line if you want to see raw JSON response
            'Log(req.GetString)
  
            Dim parser As JSONParser
  
            parser.Initialize(req.GetString)
  
            Dim jRoot As Map = parser.NextObject
  
            Dim choices As List = jRoot.Get("choices")
  
            For Each colchoices As Map In choices
      
                Dim text As String = colchoices.Get("text")
      
                If response <> "" Then response = response & CRLF
      
                response = response & text.Trim
      
            Next
 
        Else
  
            response = "ERROR: " & req.ErrorMessage
 
        End If
 
        req.Release
 
    Catch
 
        response = "ERROR: " & LastException
 
    End Try
 
    Return response

End Sub