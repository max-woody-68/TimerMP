unit TimePicker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.EditBox, FMX.SpinBox;

type
  TfTimePicker = class(TForm)
    HeaderLabel: TLabel;
    lSec: TLabel;
    sbSec: TSpinBox;
    lMin: TLabel;
    sbMin: TSpinBox;
    lHour: TLabel;
    smHour: TSpinBox;
    bOk: TButton;
    bCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fTimePicker: TfTimePicker;

implementation

{$R *.fmx}

end.
