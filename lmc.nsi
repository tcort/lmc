Name "Little Man Computer"
OutFile "lmc-1.0.0-installer.exe"
InstallDir $PROGRAMFILES\lmc
DirText "This will install the Little Man Computer virtual machine and assembler on your computer. Choose a directory..."

RequestExecutionLevel user

LicenseText "ISC"
LicenseData COPYING


Section ""

SetOutPath $INSTDIR

File COPYING
File as/lmas.exe
File vm/lmvm.exe

CreateDirectory "$SMPROGRAMS\lmc"
CreateShortCut "$SMPROGRAMS\lmc\lmas.exe.lnk" "$INSTDIR\lmas.exe"
CreateShortCut "$SMPROGRAMS\lmc\lmvm.exe.lnk" "$INSTDIR\lmvm.exe"
CreateShortCut "$SMPROGRAMS\lmc\uninstall.exe.lnk" "$INSTDIR\uninstall.exe"

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\lmc" \
"DisplayName" \
"Litte Man Computer (remove only)"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\lmc" \
"UninstallString" \
"$INSTDIR\uninstall.exe"

WriteUninstaller $INSTDIR\uninstall.exe 

MessageBox MB_OK "Installation was successful."

SectionEnd 


Section "Uninstall"

Delete $INSTDIR\COPYING
Delete $INSTDIR\lmas.exe
Delete $INSTDIR\lmvm.exe
Delete $INSTDIR\uninstall.exe
RMDir $INSTDIR

Delete "$SMPROGRAMS\lmc\lmas.exe.lnk"
Delete "$SMPROGRAMS\lmc\lmvm.exe.lnk"
Delete "$SMPROGRAMS\lmc\uninstall.exe.lnk"
RMDir "$SMPROGRAMS\lmc"

DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\lmc"
DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\lmc"

MessageBox MB_OK "Uninstall was successful."

SectionEnd 
