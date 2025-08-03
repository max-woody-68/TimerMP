unit Workouts;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Layouts, FMX.TreeView, XML.XMLDoc, XML.xmldom, XML.XMLIntf,
  TimerData;

type
  TfWorkouts = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    tvWorkouts: TTreeView;
    btnEdit: TButton;
    btnDelete: TButton;
    HeaderLabel: TLabel;
    procedure FillTreeView();
    procedure FormShow(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvWorkoutsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TMainNode = class(TTreeViewItem)
  strict private
    FlName: TLabel;
    FlInfo: TLabel;
  private
  public
    constructor Create(Owner: TComponent; sName, sInfo: string; iTag: integer); reintroduce;
    destructor Destroy; override;
  published
    property lName:     TLabel  read FlName;
    property lInfo:     TLabel  read FlInfo;
  end;

var
  fWorkouts: TfWorkouts;
  xmlSettings : IXMLDocument;

implementation

{$R *.fmx}

uses
  Options;

// TfWorkouts implementation

procedure TfWorkouts.btnEditClick(Sender: TObject);
var
  iI, iJ: integer;
  nRootNode: IXMLNode;
  tviCount: TCycleNode;
  tviTime:  TTimeNode;
  iTime: integer;
  sTime: string;
  cCycle: TCycle;
  woOptions: TWorkoutOptions;
begin
  with fOptions do
  begin
    tvCycles.BeginUpdate;

    // Удаляем старый список перед обновлением
    for iI := tvCycles.Count - 1 downto 0 do
      tvCycles.RemoveObject(tvCycles.Items[iI]);

    xmlSettings.LoadFromFile(csWorkoutsXML);
    nRootNode := xmlSettings.DocumentElement.ChildNodes[0].ChildNodes[(Sender as TButton).Tag];

    // Загрузим имя тренировки
    ebName.Text := GetWorkoutName(nRootNode);

    // Загрузим циклы
    for iI := 0 to nRootNode.ChildNodes['Cycles'].ChildNodes.Count - 1 do
    begin
      cCycle := GetWorkoutCycle(nRootNode, iI);

      tviCount := TCycleNode.Create(tvCycles, cCycle.sName);
      tvCycles.AddObject(tviCount);

      for iJ := 0 to Length(cCycle.arSteps) - 1 do
      begin
        iTime := StrToInt(cCycle.arSteps[iJ].sTime);
        sTime := Format('%.2d:%.2d:%.2d', [iTime div 3600, iTime mod 3600 div 60, iTime mod 60]);
        tviTime := TTimeNode.Create(tvCycles, StrToTime(sTime), cCycle.arSteps[iJ].sName);
        tviCount.AddObject(tviTime);
      end;
      tviCount.sbCount.Text := cCycle.sCount;
      tviCount.Expand;
    end;

    // Загрузим опции
    woOptions := GetWorkoutOptions(nRootNode);
    swCountdown.IsChecked := woOptions.bCountDown;
    cbxWarnings.ItemIndex := integer(woOptions.wWarning);
    cbxWarningsChange(Sender);
    sbWarningTime.Text := woOptions.sWarningTime;

    tvCycles.EndUpdate;
  end;
end;

procedure TfWorkouts.btnDeleteClick(Sender: TObject);
var
  nRootNode: IXMLNode;
begin
  xmlSettings.LoadFromFile(csWorkoutsXML);
  nRootNode := xmlSettings.DocumentElement.ChildNodes[0];
  nRootNode.ChildNodes.Delete((Sender as TButton).Tag);
  xmlSettings.SaveToFile(csWorkoutsXML);
  FillTreeView();
  tvWorkoutsClick(Sender);
end;

procedure TfWorkouts.FormCreate(Sender: TObject);
begin
  xmlSettings := NewXMLDocument;
end;

procedure TfWorkouts.FillTreeView();
var
  tviWorkout: TMainNode;
  iI, iJ, iSteps: integer;
  nRootNode, nNameNode, nCycleNode: IXMLNode;
  sInfo: string;
begin
  tvWorkouts.BeginUpdate;
  try
    xmlSettings.LoadFromFile(csWorkoutsXML);
  except
    xmlSettings := NewXMLDocument;
    xmlSettings.Encoding := 'utf-8';
    xmlSettings.Options := [doNodeAutoIndent, doNamespaceDecl]; // looks better in Editor ;)
    nRootNode := xmlSettings.AddChild('WoodyCycleTimer');
    nRootNode.Attributes['Version'] := '1.0';
    nRootNode.AddChild('Workouts');
    xmlSettings.SaveToFile(csWorkoutsXML);
  end;
  nRootNode := xmlSettings.DocumentElement.ChildNodes[0];

  // Удаляем старый список перед обновлением
  for iI := tvWorkouts.Count - 1 downto 0 do
    tvWorkouts.RemoveObject(tvWorkouts.Items[iI]);

  // Заполняем список тренировок
  for iI := 0 to nRootNode.ChildNodes.Count - 1 do
  begin
    sInfo := '';
    nNameNode  := nRootNode.ChildNodes[iI].ChildNodes['Name'];
    nCycleNode := nRootNode.ChildNodes[iI].ChildNodes['Cycles'].ChildNodes['Cycle'].ChildNodes['Steps'];
    iSteps := nCycleNode.ChildNodes.Count div 2;
    for iJ := 0 to iSteps - 1 do
      sInfo := sInfo + nCycleNode.ChildNodes[iJ * 2].Text + ' ' + nCycleNode.ChildNodes[iJ * 2 + 1].Text + 's; ';
    sInfo := sInfo + ' x' + nRootNode.ChildNodes[iI].ChildNodes['Cycles'].ChildNodes['Cycle'].ChildNodes['Count'].Text + '...';
    tviWorkout := TMainNode.Create(tvWorkouts, nNameNode.Text, sInfo, iI);
    tvWorkouts.AddObject(tviWorkout);
  end;
  tvWorkouts.EndUpdate;
end;

procedure TfWorkouts.FormShow(Sender: TObject);
begin
  FillTreeView();
end;

procedure TfWorkouts.tvWorkoutsClick(Sender: TObject);
var
  flShowButtons: boolean;
begin
  flShowButtons := Assigned(tvWorkouts.Selected);

  btnEdit.Visible   := flShowButtons;
  btnDelete.Visible := flShowButtons;
  if flShowButtons
  then begin
    btnEdit.Position.Y :=   tvWorkouts.Position.Y + tvWorkouts.Selected.Position.Y + 2;
    btnDelete.Position.Y := tvWorkouts.Position.Y + tvWorkouts.Selected.Position.Y + 2;
    btnEdit.Tag := tvWorkouts.Selected.Tag;
    btnDelete.Tag := tvWorkouts.Selected.Tag;
  end;
end;

// TMainNode implementation

constructor TMainNode.Create(Owner: TComponent; sName, sInfo: string; iTag: integer);
var
  mEditOnClick, mDeleteOnClick: TMethod;
begin
   mEditOnClick.Code := @TfWorkouts.btnEditClick;
   mEditOnClick.Data := nil;
   mDeleteOnClick.Code := @TfWorkouts.btnDeleteClick;
   mDeleteOnClick.Data := nil;

  inherited Create(Owner);
  self.Height := 48;
  self.Tag := iTag;

  FlName := TLabel.Create(Self);
  Self.AddObject(FlName);
  FlName.BringToFront;
  FlName.Align := TAlignLayout.Top;
  FlName.Text := sName;

  FlInfo := TLabel.Create(Self);
  Self.AddObject(FlInfo);
  FlInfo.BringToFront;
  FlInfo.Align := TAlignLayout.Top;
  FlInfo.Enabled := False;
  FlInfo.Text := sInfo;
end;

destructor TMainNode.Destroy;
begin
  lName.FreeOnRelease;
  lInfo.FreeOnRelease;
  inherited;
end;

end.
