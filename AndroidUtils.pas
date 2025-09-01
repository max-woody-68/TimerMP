unit AndroidUtils;

{$IFDEF ANDROID}

interface

uses
  Androidapi.JNIBridge, AndroidApi.JNI.Media;

procedure MyBeep(iToneType, iDuration: Integer);

implementation

procedure MyBeep(iToneType, iDuration: Integer);
var
  Volume: Integer;
  StreamType: Integer;
  ToneGenerator: JToneGenerator;
begin
  Volume := TJToneGenerator.JavaClass.MAX_VOLUME;
  StreamType := TJAudioManager.JavaClass.STREAM_ALARM;
  ToneGenerator := TJToneGenerator.JavaClass.init(StreamType, Volume);
  try
    if ToneGenerator <> nil then
      ToneGenerator.startTone(iToneType, iDuration);     // Обернуто в try/finally по рекомендации Codex
  finally
    if ToneGenerator <> nil then
      ToneGenerator.release;
  end;
end;

{$ELSE}

interface

implementation

{$ENDIF}

end.
