' Solution from: https://stackoverflow.com/questions/171588/is-there-a-command-to-refresh-environment-variables-from-the-command-prompt-in-w

SET oShell = WScript.CreateObject("WScript.Shell")
filename = oShell.ExpandEnvironmentStrings("%TEMP%\res_env_var.bat")
SET objFileSystem = CreateObject("Scripting.fileSystemObject")
SET oFile = objFileSystem.CreateTextFile(filename, TRUE)

SET oEnv=oShell.Environment("System")
FOR EACH sitem in oEnv 
    oFile.WriteLine("SET " & sitem)
NEXT
path = oEnv("PATH")

SET oEnv=oShell.Environment("User")
FOR EACH sitem in oEnv 
    oFile.WriteLine("SET " & sitem)
NEXT

path = path & ";" & oEnv("PATH")
oFile.WriteLine("SET PATH=" & path)
oFile.Close
