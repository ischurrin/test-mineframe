unit U_Tools;

interface

uses IdGlobal, System.StrUtils, System.Classes, System.SysUtils;

function StrToBinStr(const aStr : AnsiString) : AnsiString;
function BinStrToByte(const aBinStr : AnsiString) : Byte;
function dec2bin(x : integer) : string;
function bin2dec(s : string) : Int64;

// чтение строки из массива байтов
function ReadStringFromBytes(ABytes : TIdBytes; AStart : Integer; AEnd : Integer) : String;

procedure StringToList(AString, ADelimeter : String; AList : TStringList);
function  ListToString(AList : TStringList; ADelimeter : String =';') : String;
function  BytesArrayToDouble(ABytes : TIdBytes): Double;


implementation

function  BytesArrayToDouble(ABytes : TIdBytes): Double;
type
 TArray8 = array [0..7] of byte;
var
 wArray     : TArray8;
 wD         : Double;
 i          : Integer;
begin
  Result := 0;
  for i := 0 to 7 do
    wArray[i] := ABytes[i];

   Move (wArray, wD ,SizeOf(Double));
   //wD:=Double(wArray);
   Result := wD;
end;

function  ListToString(AList : TStringList; ADelimeter : String =';') : String;
begin
  Result := StringReplace(AList.Text, #$D#$A, ADelimeter, [rfReplaceAll]);
end;

procedure StringToList(AString, ADelimeter : String; AList : TStringList);
begin
  if AList = nil then
    AList := TStringList.Create;

  AList.Text := StringReplace(AString, ADelimeter, #$D#$A, [rfReplaceAll]);
end;

// чтение строки из массива байтов
function ReadStringFromBytes(ABytes: TIdBytes; AStart,
  AEnd: Integer): String;
var
   i              : Integer;
   wBytes         : TIdBytes;
   wLength        : Integer;
begin
     wLength := AEnd - AStart;
     SetLength(wBytes, wLength);
     for i  := 0 to Pred(wLength) do
       wBytes[i] := ABytes[AStart + i];
     Result := BytesToString(wBytes, IndyTextEncoding_OSDefault);
end;


function bin2dec(s : string) : Int64;
var
   x : Int64;
   i : integer;
begin
  x := 0;
  for i := 1 to length(s) do
  begin
     x := x+ord(s[i])-ord('0');
     if i < length(s) then x:=x*2;
  end;
  Result := x;
end;

function dec2bin(x : integer) : string;
var
   s : string;
begin
  s := '';
  while x > 0 do
  begin
     s := chr(ord('0')+x mod 2)+s;
     x := x div 2;
  end;
  s := LeftStr('00000000', 8 - Length(s)) + s;
  Result := s;
end;

function BinStrToByte(const aBinStr : AnsiString) : Byte;
var
  i : Integer;
begin
  Result := 0;
  for i := 1 to Length(aBinStr) do begin
    Result := Result shl 1;
    if aBinStr[i] = '1' then Result := Result or 1;
  end;
end;

function StrToBinStr(const aStr : AnsiString) : AnsiString;
var
  i, Num : Integer;
  S : AnsiString;
begin
  Result := '';
  for i := 1 to Length(aStr) do begin
    S := '';
    Num := Byte(aStr[i]);
    repeat
      case Num mod 2 of
        0 : S := '0' + S;
        1 : S := '1' + S;
      end;
      Num := Num div 2;
    until Num = 0;
    Result := Result + S;
  end;
end;


end.
