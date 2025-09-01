 unit TimerData;

interface

uses
  System.SysUtils, XML.XMLIntf;  //XML.XMLDoc, XML.xmldom, XML.XMLIntf

type

  TWarningType = (wtNone, wtBeeps, wtSingle);
  TTimeFormat = (tfMinSec, tfSecOnly);

  TSteps = record
    sCycleName: string;
    iCycleNum: integer;
    sName: string;
    iTime: integer;
    iCycleCount: integer;
    iCycle: integer;
  end;

  TStep = record
    sName: string;
    sTime: string;
  end;

  TCycle = record
    sName: string;
    arSteps: array of TStep;
    sCount: string;
    sCycles: string;
  end;

  TWorkoutOptions = record
    bCountDown: boolean;
		wWarning: TWarningType;
    sWarningTime: string;
    tfTimeFormat: TTimeFormat;
    bScreenOn: boolean;
    bSkipLastStep: boolean;
  end;

  TTimerData = record
    iCycles: integer;
    iSteps: integer;
    iFullTime: integer;
    iCurrentCycle: integer;
    iNextCycle: integer;
    iCurrentStep: integer;
    iNextStep: integer;
    arSteps: array of TSteps;
    rOptions: TWorkoutOptions;
  end;

procedure AddWorkoutName(var nWorkoutNode: IXMLNode; sName: string);
procedure AddWorkoutCycle(var nWorkoutNode: IXMLNode; cCycle: TCycle);
procedure AddWorkoutOptions(var nWorkoutNode: IXMLNode; woOptions: TWorkoutOptions);

function GetWorkoutName(nWorkoutNode: IXMLNode): string;
function GetWorkoutCycle(nWorkoutNode: IXMLNode; iCycleNum: integer): TCycle;
function GetWorkoutOptions(nWorkoutNode: IXMLNode): TWorkoutOptions;

procedure InitTimerData(iCycles: integer);

var
  rTimerData: TTimerData;
  csWorkoutsXML: string;
  csLastWorkoutXML: string;

implementation

procedure AddWorkoutName(var nWorkoutNode: IXMLNode; sName: string);
var
  nNameNode: IXMLNode;
begin
  nNameNode := nWorkoutNode.AddChild('Name');
  nNameNode.Text := sName;
end;

procedure AddWorkoutCycle(var nWorkoutNode: IXMLNode; cCycle: TCycle);
var
  nCycleNode, nStepsNode, nCurNode: IXMLNode;
  iI: integer;
begin
  nCycleNode := nWorkoutNode.ChildNodes['Cycles'].AddChild('Cycle');
  nCurNode := nCycleNode.AddChild('Name');
  nCurNode.Text := cCycle.sName;
  nStepsNode := nCycleNode.AddChild('Steps');

  for iI := 0 to Length(cCycle.arSteps) - 1 do
  begin
    nCurNode := nStepsNode.AddChild(Format('S%.3d', [iI + 1]));
    nCurNode.Text := cCycle.arSteps[iI].sName;
    nCurNode := nStepsNode.AddChild(Format('T%.3d', [iI + 1]));
    nCurNode.Text := cCycle.arSteps[iI].sTime;
  end;
  nCurNode := nCycleNode.AddChild('Count');
  nCurNode.Text := cCycle.sCount;
end;

procedure AddWorkoutOptions(var nWorkoutNode: IXMLNode; woOptions: TWorkoutOptions);
var
  nOptionsNode, nCurNode: IXMLNode;
begin
  nOptionsNode := nWorkoutNode.AddChild('Options');
  nCurNode := nOptionsNode.AddChild('Countdown');
  if woOptions.bCountDown
  then nCurNode.Text := '1'
  else nCurNode.Text := '0';
  nCurNode := nOptionsNode.AddChild('WarningType');
  nCurNode.Text := IntToStr(Integer(woOptions.wWarning));
  nCurNode := nOptionsNode.AddChild('WarningTime');
  nCurNode.Text := woOptions.sWarningTime;
  nCurNode := nOptionsNode.AddChild('TimeFormat');
  nCurNode.Text := IntToStr(Ord(woOptions.tfTimeFormat));
  nCurNode := nOptionsNode.AddChild('ScreenOn');
  if woOptions.bScreenOn
  then nCurNode.Text := '1'
  else nCurNode.Text := '0';
  nCurNode := nOptionsNode.AddChild('SkipLastStep');
  if woOptions.bSkipLastStep
  then nCurNode.Text := '1'
  else nCurNode.Text := '0';
end;

function GetWorkoutName(nWorkoutNode: IXMLNode): string;
begin
  result := nWorkoutNode.ChildNodes['Name'].Text;
end;

function GetWorkoutCycle(nWorkoutNode: IXMLNode; iCycleNum: integer): TCycle;
var
  nCycleNode, nStepsNode: IXMLNode;
  iI, iSteps: integer;
begin
  nCycleNode := nWorkoutNode.ChildNodes['Cycles'].ChildNodes[iCycleNum];
  result.sName := nCycleNode.ChildNodes['Name'].Text;

  nStepsNode := nCycleNode.ChildNodes['Steps'];
  iSteps := nStepsNode.ChildNodes.Count div 2;
  SetLength(result.arSteps, iSteps);

  for iI := 0 to iSteps - 1 do
  begin
    result.arSteps[iI].sName := nStepsNode.ChildNodes[iI * 2].Text;
    result.arSteps[iI].sTime := nStepsNode.ChildNodes[iI * 2 + 1].Text;
  end;
  result.sCount := nCycleNode.ChildNodes['Count'].Text;
  result.sCycles := IntToStr(iSteps);
end;

function GetWorkoutOptions(nWorkoutNode: IXMLNode): TWorkoutOptions;
var
  nOptionstNode: IXMLNode;
begin
  nOptionstNode := nWorkoutNode.ChildNodes['Options'];
  result.bCountDown := (nOptionstNode.ChildNodes['Countdown'].Text <> '0');
  result.wWarning := TWarningType(StrToInt(nOptionstNode.ChildNodes['WarningType'].Text));
  result.sWarningTime := nOptionstNode.ChildNodes['WarningTime'].Text;
  result.tfTimeFormat := TTimeFormat(StrToInt(nOptionstNode.ChildNodes['TimeFormat'].Text));
  result.bScreenOn := (nOptionstNode.ChildNodes['ScreenOn'].Text <> '0');
  result.bSkipLastStep := (nOptionstNode.ChildNodes['SkipLastStep'].Text <> '0');
end;

procedure InitTimerData(iCycles: integer);
begin
  with rTimerData do
  begin
    rTimerData.iCycles := iCycles;
    iFullTime := 0;
    iSteps := 0;
    iCurrentCycle := 0;
    iCurrentStep := 0;
  end;
end;

end.
