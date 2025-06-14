[Setup]
AppName=ZenBreak
AppVersion=1.0
DefaultDirName={pf}\ZenBreak
OutputDir=build\installer
OutputBaseFilename=ZenBreakInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\ZenBreak"; Filename: "{app}\zenbreak.exe"
Name: "{userstartup}\ZenBreak"; Filename: "{app}\zenbreak.exe"
Name: "{userdesktop}\ZenBreak"; Filename: "{app}\zenbreak.exe"
