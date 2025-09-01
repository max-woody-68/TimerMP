program WorkoutTimer;

uses
  System.StartUpCopy,
  System.IOUtils,
  System.SysUtils,
  FMX.Forms,
  Main in 'Main.pas' {fMain},
  AndroidUtils in 'AndroidUtils.pas',
  TimerData in 'TimerData.pas',
  Options in 'Options.pas' {fOptions},
  Workouts in 'Workouts.pas' {fWorkouts},
  TimePicker in 'TimePicker.pas' {fTimePicker};

{$R *.res}

begin
  Application.Initialize;

  {$IFDEF ANDROID}
    csWorkoutsXML    := TPath.GetDocumentsPath + PathDelim +'Workouts.xml';
    csLastWorkoutXML := TPath.GetDocumentsPath + PathDelim +'LastWorkout.xml';
  {$ENDIF}
  {$IFDEF WIN64}
    csWorkoutsXML := 'Workouts.xml';
  {$ENDIF}

  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfOptions, fOptions);
  Application.CreateForm(TfWorkouts, fWorkouts);
  Application.CreateForm(TfTimePicker, fTimePicker);
  Application.Run;
end.
