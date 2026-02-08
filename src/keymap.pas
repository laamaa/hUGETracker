unit Keymap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Constants, LCLType, LCLProc, Grids;

type
  TKeybindings = specialize TFPGmap<Word, Integer>;

procedure LoadDefaultKeybindings;
procedure LoadCustomKeybindings(Grid: TStringGrid);

var
  Keybindings: TKeybindings;

implementation

procedure LoadDefaultKeybindings;
begin
  Keybindings.Clear;

  // IT piano layout - lower octave (Z row = white keys, S/D/G/H/J = black keys)
  Keybindings.Add(VK_Z, C_3);
  Keybindings.Add(VK_S, CS3);
  Keybindings.Add(VK_X, D_3);
  Keybindings.Add(VK_D, DS3);
  Keybindings.Add(VK_C, E_3);
  Keybindings.Add(VK_V, F_3);
  Keybindings.Add(VK_G, FS3);
  Keybindings.Add(VK_B, G_3);
  Keybindings.Add(VK_H, GS3);
  Keybindings.Add(VK_N, A_3);
  Keybindings.Add(VK_J, AS3);
  Keybindings.Add(VK_M, B_3);

  // IT piano layout - upper octave (Q row = white keys, 2/3/5/6/7 = black keys)
  Keybindings.Add(VK_Q, C_4);
  Keybindings.Add(VK_2, CS4);
  Keybindings.Add(VK_W, D_4);
  Keybindings.Add(VK_3, DS4);
  Keybindings.Add(VK_E, E_4);
  Keybindings.Add(VK_R, F_4);
  Keybindings.Add(VK_5, FS4);
  Keybindings.Add(VK_T, G_4);
  Keybindings.Add(VK_6, GS4);
  Keybindings.Add(VK_Y, A_4);
  Keybindings.Add(VK_7, AS4);
  Keybindings.Add(VK_U, B_4);
  Keybindings.Add(VK_I, C_5);
end;

procedure LoadCustomKeybindings(Grid: TStringGrid);
var
  I: Integer;
  SC: TShortCut;
begin
  Keybindings.Clear;

  for I := 1 to Grid.RowCount-1 do begin
    SC := TextToShortCut(Grid.Cells[0, I]);

    if SC = 0 then Continue;
    if NoteToCodeMap.IndexOf(Grid.Cells[1, I]) = -1 then Continue;

    Keybindings.Add(SC, NoteToCodeMap.KeyData[Grid.Cells[1, I]]);
  end;
end;

begin
  Keybindings := TKeybindings.Create;
end.

