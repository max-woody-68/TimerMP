unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Ani, DateUtils, System.IOUtils,
  Options, TimerData
{$IFDEF ANDROID}
  , AndroidUtils, AndroidApi.JNI.Media, Androidapi.Helpers, Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText,
  FMX.Media

{$ENDIF}
{$IFDEF WIN64}
  , Windows, FMX.Media
{$ENDIF}
  ;

type
  TfMain = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    lTime: TLabel;
    lCycle: TLabel;
    lCurrentStep: TLabel;
    lNextStep: TLabel;
    btnReset: TButton;
    btnStart: TButton;
    btnSkip: TButton;
    Timer1: TTimer;
    btnOptions: TButton;
    StyleBook1: TStyleBook;
    pbTotal: TProgressBar;
    MediaPlayer1: TMediaPlayer;
    pbStep: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnSkipClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function CycleCaption(iStep: integer): string;
    function StepCaption(iStep: integer; sPrefix: string): string;
    procedure KeepScreenOn(bKeepOn: boolean);
  end;

var
  fMain: TfMain;
  iStep: integer;
  iTime: integer;

implementation

{$R *.fmx}

function GetFullFileName(sFileName: string): string;
begin
{$IFDEF ANDROID}
  Result := TPath.Combine(TPath.GetDocumentsPath, sFileName);
{$ENDIF}
{$IFDEF WIN64}
  Result := sFileName;
{$ENDIF}
end;

procedure PlayWarning(iRestTime: integer);
var
  iSygnalTime: integer;
begin
  iSygnalTime := StrToInt(fOptions.sbWarningTime.Text);
{$IFDEF ANDROID}
  case fOptions.cbxWarnings.ItemIndex of
    0: Exit;
    1: if iRestTime <= iSygnalTime then MyBeep(TJToneGenerator.JavaClass.TONE_DTMF_9, 250); //(7000, 400);
    2: if iRestTime  = iSygnalTime then MyBeep(TJToneGenerator.JavaClass.TONE_DTMF_0, 400); //(7000, 400);
  end;
{$ENDIF}
{$IFDEF WIN64}
  case fOptions.cbxWarnings.ItemIndex of
    0: Exit;
    1: if iRestTime <= iSygnalTime then Beep(7000, 400);
    2: if iRestTime  = iSygnalTime then Beep(7000, 400);
  end;
{$ENDIF}
end;

procedure PlayStepFinished();
var
  sFile: string;
begin
  sFile := GetFullFileName('Step01.mp3');
  if FileExists(sFile)
  then begin
    fMain.MediaPlayer1.FileName := sFile;
    fMain.MediaPlayer1.Play;
  end
  else begin
    {$IFDEF ANDROID}
      MyBeep(TJToneGenerator.JavaClass.TONE_DTMF_0, 400);
    {$ENDIF}
    {$IFDEF WIN64}
      Beep(7000, 400);
    {$ENDIF}
  end;
end;

procedure PlayWorkoutFinished();
var
  sFile: string;
begin
  sFile := GetFullFileName('Finish01.mp3');
  if FileExists(sFile)
  then begin
    fMain.MediaPlayer1.FileName := sFile;
    fMain.MediaPlayer1.Play;
  end
  else begin
    {$IFDEF ANDROID}
      MyBeep(TJToneGenerator.JavaClass.TONE_DTMF_0, 1000);
    {$ENDIF}
    {$IFDEF WIN64}
      Beep(7000, 1000);
    {$ENDIF}
  end;
end;

function TfMain.CycleCaption(iStep: integer): string;
begin
  with rTimerData.arSteps[iStep] do
  begin
    Result := Format('%s - %d (%d)', [sCycleName, iCycleNum + 1, rTimerData.iCycles]);
  end;
end;

function TfMain.StepCaption(iStep: integer; sPrefix: string): string;
var
  iStepTime: integer;
begin
  with rTimerData.arSteps[iStep] do
  begin
    iStepTime := iTime;
    if iStepTime = 0
    then Result := Format('%s %s', [sPrefix, sName])
    else Result := Format('%s %s %.2d:%.2d - %d(%d)', [sPrefix, sName, iStepTime div 60, iStepTime mod 60, iCycle, iCycleCount]);
  end;
end;

procedure TfMain.KeepScreenOn(bKeepOn: Boolean);
var
  iFlag: integer;
begin
  {$IFDEF ANDROID}
  iFlag := TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON;

  if bKeepOn
  then TAndroidHelper.Activity.GetWindow.addFlags(iFlag)
  else TAndroidHelper.Activity.GetWindow.clearFlags(iFlag);
  {$ENDIF}
end;

procedure TfMain.Button1Click(Sender: TObject);
begin
//
end;

procedure TfMain.btnOptionsClick(Sender: TObject);
begin
  {$IFDEF ANDROID}
    fOptions.ShowModal(
      procedure(ModalResult: TModalResult)
      begin
      end);
  {$ENDIF}
  {$IFDEF WIN64}
    fOptions.ShowModal();
  {$ENDIF}
end;

procedure TfMain.btnResetClick(Sender: TObject);
begin
  fOptions.btnOkClick(Sender);
end;

procedure TfMain.btnStartClick(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
  if Timer1.Enabled
  then btnStart.StyleLookup := 'pausetoolbutton'
  else btnStart.StyleLookup := 'playtoolbutton';
  KeepScreenOn(fOptions.swScreenOn.IsChecked);
end;

procedure TfMain.btnSkipClick(Sender: TObject);
begin
  iTime := rTimerData.arSteps[iStep].iTime - 1;
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  iShowTime: integer;
begin
  Inc(iTime);
  pbTotal.Value := pbTotal.Value + 1;
  if fOptions.swCountdown.IsChecked
  then iShowTime := rTimerData.arSteps[iStep].iTime - iTime
  else iShowTime := iTime;
  lTime.Text := Format('%.2d:%.2d', [iShowTime div 60, iShowTime mod 60]);

  if iTime = rTimerData.arSteps[iStep].iTime then
  begin
    iTime := 0;
    Inc(iStep);
    if iStep = rTimerData.iSteps
    then begin
      PlayWorkoutFinished;
      Timer1.Enabled := False;
      lTime.Text := '00:00';
      lCycle.Text := '';
      lCurrentStep.Text := rTimerData.arSteps[Length(rTimerData.arSteps) - 2].sName;
      lNextStep.Text := '';
      KeepScreenOn(False);
    end
    else begin
      PlayStepFinished;
      lCycle.Text := CycleCaption(iStep);
      lCurrentStep.Text := StepCaption(iStep, 'Now:');
      lNextStep.Text := StepCaption(iStep + 1, 'Next:');
    end;
  end
  else PlayWarning(rTimerData.arSteps[iStep].iTime - iTime);

end;

end.
