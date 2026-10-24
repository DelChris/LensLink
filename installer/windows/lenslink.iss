; LensLink OBS-plugin installer (Inno Setup 6).
;
; Compiled by the release workflow from the repository root:
;   iscc /DAppVersion=1.2.0 installer\windows\lenslink.iss
; with the plugin already packaged into stage\ (same layout the zip uses).
;
; Installs into OBS's per-machine plugin folder,
; C:\ProgramData\obs-studio\plugins\lenslink, and registers a normal Windows
; uninstaller. The DLL sits both at the folder root (OBS 33+) and in
; bin\64bit (OBS 32), sharing one data\ folder.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{7C34D6B2-9A41-4F0E-8B7D-2E5A31C90F6E}
AppName=LensLink for OBS Studio
AppVersion={#AppVersion}
AppPublisher=Exalted Pixels
AppPublisherURL=https://github.com/MyNamesEMurray/LensLink
AppSupportURL=https://github.com/MyNamesEMurray/LensLink/issues
DefaultDirName={commonappdata}\obs-studio\plugins\lenslink
; Releases before OBS 33 installed into the OBS folder; don't reuse it.
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
; ProgramData, and removing old copies from Program Files, need elevation.
PrivilegesRequired=admin
; "x64" (not the newer "x64compatible") so any Inno Setup 6.x compiles it.
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
; Keep the uninstaller beside the plugin's data, not its DLL.
UninstallFilesDir={app}\data
OutputBaseFilename=LensLink-installer-windows-x64
SourceDir=..\..
OutputDir=.
WizardStyle=modern
SolidCompression=yes

[InstallDelete]
; Pre-1.0 builds shipped as "ios-camera-source". If a copy is still present
; it loads first, registers the source id, and OBS rejects the current
; plugin as a duplicate — the user silently keeps running the old code.
Type: files; Name: "{code:GetObsDir}\obs-plugins\64bit\ios-camera-source.dll"
Type: filesandordirs; Name: "{code:GetObsDir}\data\obs-plugins\ios-camera-source"
; Releases before OBS 33 installed into the OBS folder (a location OBS 34
; no longer loads). Left in place, that copy would also load and register
; the same source ids as this one.
Type: files; Name: "{code:GetObsDir}\obs-plugins\64bit\lenslink.dll"
Type: filesandordirs; Name: "{code:GetObsDir}\data\obs-plugins\lenslink"

[Files]
Source: "stage\lenslink\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Code]
function GetObsDir(Param: string): string;
begin
  { OBS Studio's installer records its location here. }
  if not RegQueryStringValue(HKLM, 'SOFTWARE\OBS Studio', '', Result) then
    Result := ExpandConstant('{autopf}\obs-studio');
end;

