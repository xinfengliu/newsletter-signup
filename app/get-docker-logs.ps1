 Get-EventLog -LogName Application -Source Docker -After (Get-Date).AddMinutes(-2) | ft -wrap -autosize