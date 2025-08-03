unit Options;

{ TODO -cOptions : Не гасить экран }
{ TODO -cOptions : Выбор времени  sss/mm:ss }
{ DONE -cOptions : Разделитель опции/шаги в виде вертикального слайдера }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.EditBox, FMX.SpinBox, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Layouts, FMX.TreeView, FMX.DateTimeCtrls, XML.XMLDoc, XML.xmldom, XML.XMLIntf,
  FMX.DialogService,
  DateUtils, TimerData, Workouts, FMX.Effects, FMX.ExtCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Objects, FMX.ListBox;

type
  TfOptions = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    btnWorkouts: TButton;
    ebName: TEdit;
    lblName: TLabel;
    btnSave: TButton;
    lvSetTime: TListView;
    Rectangle1: TRectangle;
    btnTOk: TButton;
    lMin: TLabel;
    lSec: TLabel;
    sbMin: TSpinBox;
    sbSec: TSpinBox;
    ShadowEffect1: TShadowEffect;
    btnTCancel: TButton;
    pMask: TPanel;
    BlurEffect1: TBlurEffect;
    pMain: TPanel;
    pOptList: TPanel;
    pOpt: TPanel;
    Splitter1: TSplitter;
    pList: TPanel;
    lblWarnings: TLabel;
    sbWarningTime: TSpinBox;
    btnInsert: TButton;
    btnDelete: TButton;
    tvCycles: TTreeView;
    Rectangle2: TRectangle;
    cbxWarnings: TComboBox;
    lblSec: TLabel;
    cbxTimeFormat: TComboBox;
    lblTimeFormat: TLabel;
    lblScreenOn: TLabel;
    swScreenOn: TSwitch;
    lblCountdown: TLabel;
    swCountdown: TSwitch;
    lblSkipLastStep: TLabel;
    swSkipLastStep: TSwitch;
    lblFlash: TLabel;
    swFlash: TSwitch;
    procedure btnInsertClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnWorkoutsClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnTOkClick(Sender: TObject);
    procedure btnTCancelClick(Sender: TObject);
    procedure cbxWarningsChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbWarningTimeTap(Sender: TObject; const Point: TPointF);
    procedure sbWarningTimeChange(Sender: TObject);
  private
    procedure RemoveZeroTimes();
    function SetSteps(): integer;
    procedure AddWorkout(nRootNode: IXMLNode);
  public
    { Public declarations }
  end;

  TTimeEditWOPicker = class(TTimeEdit)
  public
    function CanUsePicker: Boolean;  override;
  end;

  TCycleNode = class(TTreeViewItem)
  strict private
    FebName: TEdit;
    FsbCount: TSpinBox;
  private
  public
    constructor Create(Owner: TComponent; AName: string); reintroduce;
    destructor Destroy; override;
  published
    property ebName:  TEdit    Read FebName;
    property sbCount: TSpinBox Read FsbCount;
  end;

  TTimeNode = class(TTreeViewItem)
    procedure onTap(Sender: TObject; const Point: TPointF);
  strict private
    FebName: TEdit;
    FteTime: TTimeEditWOPicker;
  private
  public
    constructor Create(Owner: TComponent; ATime: TTime; AName: string); reintroduce;
    destructor Destroy; override;
  published
    property ebName: TEdit    Read FebName;
    property teTime: TTimeEditWOPicker Read FteTime;
  end;

var
  fOptions: TfOptions;
  teTaped: TTimeEditWOPicker;

implementation

{$R *.fmx}

uses Main;

// TTimeEditWOPicker implementation

function TTimeEditWOPicker.CanUsePicker;
begin
  Result := False;
end;

// TMainNode implementation

constructor TCycleNode.Create(Owner: TComponent; AName: string);
begin
  inherited Create(Owner);

  FebName := TEdit.Create(Self);
  Self.AddObject(FebName);

  FebName.BringToFront;

  FebName.Text := AName;
  FebName.Position.X := 24;
  FebName.Position.Y := 6;
  FebName.Width := 150;

  FsbCount := TSpinBox.Create(Self);
  Self.AddObject(FsbCount);

  FsbCount.BringToFront;

  FsbCount.Min := 1;
  FsbCount.Max := 99;
  FsbCount.Value := 3;
  FsbCount.Position.X := 182;
  FsbCount.Position.Y := 6;
  FsbCount.CanFocus := False;

  Height := 40;
end;

destructor TCycleNode.Destroy;
begin
  ebName.FreeOnRelease;
  sbCount.FreeOnRelease;
  inherited;
end;

// TTimeNode implementation

procedure TTimeNode.onTap(Sender: TObject; const Point: TPointF);
var
  iY: single;
  pPos: TPointF;
begin
  teTaped := Sender as TTimeEditWOPicker;
  fOptions.sbSec.Value := SecondOfTheDay(teTaped.Time) mod 60;
  fOptions.sbMin.Value := SecondOfTheDay(teTaped.Time) div 60 mod 60;

  pPos := TPointF.Create(0, 0);
  pPos := teTaped.ConvertLocalPointTo(fOptions.pMask, pPos);
  iY := pPos.Y + teTaped.Height;
  if iY + fOptions.lvSetTime.Height > fOptions.Height
  then iY := pPos.Y - fOptions.lvSetTime.Height;

  fOptions.lvSetTime.Position.X := pPos.X + teTaped.Width - fOptions.lvSetTime.Width;
  fOptions.lvSetTime.Position.Y := iY;
  fOptions.pMask.Visible := True;
  fOptions.BlurEffect1.Enabled := True;

{  if fOptions.cbxTimeFormat.ItemIndex = 0 then
  begin
    fOptions.sbMin.Enabled := True;
    fOptions.lMin.Enabled  := True;
    fOptions.sbSec.Max := 59;
  end
  else begin
    fOptions.sbMin.Enabled := False;
    fOptions.lMin.Enabled  := False;
    fOptions.sbSec.Max := 9999;
  end;
}
end;

constructor TTimeNode.Create(Owner: TComponent; ATime: TTime; AName: string);
var
  OnTap1: TMethod;
begin
  inherited Create(Owner);

  FebName := TEdit.Create(Self);
  Self.AddObject(FebName);
  FebName.BringToFront;
  FebName.Text := AName;
  FebName.Position.X := 0;
  FebName.Position.Y := 2;
  FebName.Width := 138;

  OnTap1.Code := @TTimeNode.onTap;
  OnTap1.Data := nil;

  FteTime := TTimeEditWOPicker.Create(Self);
  Self.AddObject(FteTime);
  FteTime.BringToFront;
  FteTime.Format := 'nn:ss';
  FteTime.Time := ATime;
  FteTime.Position.X := 148;
  FteTime.Position.Y := 2;
  FteTime.OnTap := TTapEvent(OnTap1);
  Height := 36;
end;

destructor TTimeNode.Destroy;
begin
  ebName.FreeOnRelease;
  teTime.FreeOnRelease;
  inherited;
end;

// TfOptions implementation

procedure TfOptions.RemoveZeroTimes();
var
  iI, iJ: integer;
begin
  { Удаляем все шаги с длительностью 0 }

  for iI := 0 to tvCycles.Count - 1 do
    for iJ := tvCycles.Items[iI].Count - 1 downto 0 do
      if (tvCycles.Items[iI].Items[iJ] as TTimeNode).teTime.Time = 0
      then tvCycles.RemoveObject(tvCycles.Items[iI].Items[iJ])
      else Inc(rTimerData.iSteps, Round((tvCycles.Items[iI] as TCycleNode).sbCount.Value));

  { Удаляем все циклы, где не осталось шагов }

    for iI := tvCycles.Count - 1 downto 0 do
      if tvCycles.Items[iI].Count = 0
      then tvCycles.RemoveObject(tvCycles.Items[iI]);
end;

function TfOptions.SetSteps(): integer;
var
  iCycle, iRepeats, iRepeat, iSteps, iStep, iStepTime, iI: integer;
begin
  iI := 0;

  { Записываем все шаги в массив

    Условие пропуска последнего шага в цикле:
    1. В цикле больше одного шага
    2. Это последний шаг
    3. Это последний проход цикла
    4. Свитч "пропускать" включен
  }

  for iCycle := 0 to tvCycles.Count - 1 do
  begin
    iRepeats := Round((tvCycles.Items[iCycle] as TCycleNode).sbCount.Value);
    for iRepeat := 0 to iRepeats - 1 do
    begin
      iSteps := tvCycles.Items[iCycle].Count;
      for iStep := 0 to iSteps - 1 do
        if (iSteps > 1) and (iStep = (iSteps - 1)) and (iRepeat = (iRepeats - 1)) and swSkipLastStep.IsChecked   // Условие пропуска последнего шага в цикле
        then Dec(rTimerData.iSteps)
        else begin
          iStepTime := SecondOfTheDay((tvCycles.Items[iCycle].Items[iStep] as TTimeNode).teTime.Time);
          Inc(rTimerData.iFullTime, iStepTime);
          rTimerData.arSteps[iI].sName := (tvCycles.Items[iCycle].Items[iStep] as TTimeNode).ebName.Text;
          rTimerData.arSteps[iI].iTime := iStepTime;
          rTimerData.arSteps[iI].sCycleName := (tvCycles.Items[iCycle] as TCycleNode).ebName.Text;
          rTimerData.arSteps[iI].iCycleNum := iCycle;
          rTimerData.arSteps[iI].iCycleCount := iRepeats;
          rTimerData.arSteps[iI].iCycle := iRepeat + 1;
          Inc(iI);
        end;
    end;
  end;

  rTimerData.iCycles := tvCycles.Count;
  Result := iI;
end;

procedure TfOptions.sbWarningTimeChange(Sender: TObject);
begin
  sbWarningTime.CanFocus := False;
end;

procedure TfOptions.sbWarningTimeTap(Sender: TObject; const Point: TPointF);
begin
//  sbWarningTime.CanFocus := True;
end;

procedure TfOptions.btnDeleteClick(Sender: TObject);
var
  iI: integer;
begin
  tvCycles.BeginUpdate;
  if tvCycles.Selected = nil
  then tvCycles.Items[tvCycles.Count - 1].Select;
  for iI := tvCycles.Selected.Count - 1  downto 0 do
    tvCycles.Selected.RemoveObject(iI);
  tvCycles.RemoveObject(tvCycles.Selected);
  tvCycles.EndUpdate;
end;

procedure TfOptions.AddWorkout(nRootNode: IXMLNode);
var
  iI, iJ: integer;
  cCycle: TCycle;
  woOptions: TWorkoutOptions;
begin
  nRootNode := nRootNode.AddChild('Workout');                                 // Добавляем тренировку
  AddWorkoutName(nRootNode, ebName.Text);

  nRootNode.AddChild('Cycles');
  for iI := 0 to tvCycles.Count - 1 do                                        // Добавляем ее циклы
  begin
    cCycle.sName := (tvCycles.Items[iI] as TCycleNode).ebName.Text;
    SetLength(cCycle.arSteps, tvCycles.Items[iI].Count);
    for iJ := 0 to tvCycles.Items[iI].Count - 1 do
    begin
      cCycle.arSteps[iJ].sName := (tvCycles.Items[iI].Items[iJ] as TTimeNode).ebName.Text;
      cCycle.arSteps[iJ].sTime := IntToStr(SecondOfTheDay((tvCycles.Items[iI].Items[iJ] as TTimeNode).teTime.Time));
    end;

    cCycle.sCount := (tvCycles.Items[iI] as TCycleNode).sbCount.Text;
    AddWorkoutCycle(nRootNode, cCycle);
  end;

  woOptions.bCountDown := swCountdown.IsChecked;
  woOptions.wWarning := TWarningType(fOptions.Tag);
  woOptions.sWarningTime := sbWarningTime.Text;
  woOptions.bSkipLastStep := swSkipLastStep.IsChecked;
  AddWorkoutOptions(nRootNode, woOptions);

  xmlSettings.SaveToFile(csWorkoutsXML);
end;

procedure TfOptions.btnInsertClick(Sender: TObject);
var
  tviCount: TCycleNode;
  tviTime:  TTimeNode;
  iNum, iPos: integer;
  bAddCycle: boolean;
begin
  tvCycles.BeginUpdate;

  if tvCycles.Selected = nil                  // Ничего не выбрано?
  then begin                                  // Добавляем цикл в конец
    bAddCycle := True;
    iPos := tvCycles.Count;
  end
  else begin
    if tvCycles.Selected.ParentItem = nil     // Родитель выбранной строки - сам список (выбрана строка с циклом)?
    then begin                                // Добавляем цикл после выбранного
      bAddCycle := True;
      iPos := tvCycles.Selected.Index + 1;
    end
    else begin                                // Родитель выбранной строки - не список (выбрана строка с шагом)?
      bAddCycle := False;                     // Добавляем шаг после выбранного
      iPos := tvCycles.Selected.Index + 1;
    end;
  end;

  if bAddCycle
  then begin                                 // Добавляем цикл
    iNum := tvCycles.Count + 1;
    tviCount := TCycleNode.Create(tvCycles, Format('Cycle %.2d', [iNum]));
    tvCycles.InsertObject(iPos, tviCount);

    tviTime := TTimeNode.Create(tvCycles, StrToTime('00:00:10'), 'Step 1');
    tviCount.AddObject(tviTime);
    tviTime := TTimeNode.Create(tvCycles, StrToTime('00:00:05'), 'Step 2');
    tviCount.AddObject(tviTime);

    tviCount.Expand;
  end
  else begin                                 // Добавляем шаг
    tviCount := tvCycles.Selected.ParentItem as TCycleNode;
    iNum := tviCount.Count + 1;
    tviTime := TTimeNode.Create(tvCycles, StrToTime('00:00:10'), Format('Step %.2d', [iNum]));
    tviCount.InsertObject(iPos, tviTime);
  end;
  tvCycles.EndUpdate;
end;

procedure TfOptions.btnOkClick(Sender: TObject);
var
  iI: integer;
begin
  InitTimerData(tvCycles.Count);

  RemoveZeroTimes();                         // Удаляем шаги с нулевым временем, если они есть

  SetLength(rTimerData.arSteps, rTimerData.iSteps + 2);

  iI := SetSteps();                          // Подсчитываем время тренировки и другие параметры

  rTimerData.arSteps[iI].sName := 'Workout complete';
  rTimerData.arSteps[iI].iTime := 0;
  Inc(iI);
  rTimerData.arSteps[iI].sName := '';
  rTimerData.arSteps[iI].iTime := 0;

  SetLength(rTimerData.arSteps, iI + 1);     // Возможно, массив стал короче из-за пропуска последних шагов в циклах

  fMain.HeaderLabel.Text := ebName.Text;
  fMain.lCycle.Text := fMain.CycleCaption(0);
  fMain.lCurrentStep.Text := fMain.StepCaption(0, 'Now:');
  fMain.lNextStep.Text := fMain.StepCaption(1, 'Next:');
  fMain.btnStart.Enabled := True;
  fMain.btnSkip.Enabled := True;
  fMain.btnReset.Enabled := True;

  if swCountdown.IsChecked
  then fMain.lTime.Text := Format('%.2d:%.2d', [rTimerData.arSteps[0].iTime div 60, rTimerData.arSteps[0].iTime mod 60])
  else fMain.lTime.Text := '00:00';
  iStep := 0;
  iTime := 0;
  fMain.Timer1.Enabled := False;
  fMain.btnStart.StyleLookup := 'playtoolbutton';
  fMain.pbTotal.Value := 0;
  fMain.pbTotal.Max := rTimerData.iFullTime;
end;


procedure TfOptions.btnSaveClick(Sender: TObject);
var
  iI: integer;
  nRootNode: IXMLNode;
  bAddWorkout: boolean;
begin
  xmlSettings.LoadFromFile(csWorkoutsXML);
  nRootNode := xmlSettings.DocumentElement.ChildNodes[0];                       // Ищем в файле тренировку с тем же имененм
  bAddWorkout := True;

  for iI := 0 to nRootNode.ChildNodes.Count - 1 do
  begin
    if GetWorkoutName(nRootNode.ChildNodes[iI]) = ebName.Text
    then begin                                                                  // Запрос на удаление
  {$IFDEF ANDROID}
      TDialogService.MessageDialog(Format('Workout "%s" already exists. Overwrite it?', [ebName.Text]), TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
                                   procedure (const AResult: TModalResult)
                                   begin
                                      if AResult = mrYes
                                      then begin
                                        nRootNode.ChildNodes.Delete(iI);
                                        AddWorkout(nRootNode);
                                      end;
                                   end);

      bAddWorkout := False;
  {$ENDIF}
  {$IFDEF WIN64}
      if MessageDlg(Format('Workout "%s" already exists. Overwrite it?', [ebName.Text]), TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0, TMsgDlgBtn.mbNo) = mrYes
      then begin
        nRootNode.ChildNodes.Delete(iI);
      end
      else bAddWorkout := False;
  {$ENDIF}
      Break;
    end;
  end;

  if bAddWorkout
  then AddWorkout(nRootNode);
end;

procedure TfOptions.btnWorkoutsClick(Sender: TObject);
begin
  {$IFDEF ANDROID}
    fWorkouts.ShowModal(
      procedure(ModalResult: TModalResult)
      begin
      end);
  {$ENDIF}
  {$IFDEF WIN64}
    fWorkouts.ShowModal();
  {$ENDIF}
end;

procedure TfOptions.cbxWarningsChange(Sender: TObject);
begin
  sbWarningTime.Visible := (cbxWarnings.ItemIndex > 0);
  lblSec.Visible        := (cbxWarnings.ItemIndex > 0);
end;

procedure TfOptions.FormShow(Sender: TObject);
begin
  cbxWarningsChange(Sender);
end;

procedure TfOptions.btnTOkClick(Sender: TObject);
begin
  teTaped.Time := EncodeTime(0, Round(sbMin.Value), Round(sbSec.Value), 0);
  pMask.Visible := False;
  fOptions.BlurEffect1.Enabled := False;
end;

procedure TfOptions.btnTCancelClick(Sender: TObject);
begin
  pMask.Visible := False;
  fOptions.BlurEffect1.Enabled := False;
end;

end.
