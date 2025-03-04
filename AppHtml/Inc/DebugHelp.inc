
<script Language="VBScript" RUNAT="Server">

Sub ShowPostGet
    Dim x, Nam
    response.write ("<hr><strong>----DEBUG INFORMATION----</strong><br>")
    response.write ("content_length = " + request.servervariables("content_length")+"<br>")
    response.write ("request_method = " + request.servervariables("request_method")+"<br>")
    For Each x In Request.Form
        set nam = Request.Form(x)
        response.write(x +"= " +nam+"<br>")
    Next
    response.write ("Querystring = " + request.querystring+"<br>")
    response.write "<strong>----END DEBUG INFORMATION----</strong><hr>"
End Sub
</script>

<%
If DebugMode = 0 then DebugMode = session ("debug")
If DebugMode <> 0 then ShowPostGet
%>
