unit U_MicroMineFile;

interface

uses IdGlobal, System.Classes, System.SysUtils, StrUtils, System.Math, Vcl.Dialogs;

// описание поля в файде MICROMINE
type
  TmmFieldDef = class
    Name             : String;
    Decription       : String;
    DataType         : String;
    Size             : Integer;
    DecSeparator     : String;
    VisibleSize      : Integer;
end;
// поле MICROMINE
type
  TmmField = class
    FieldDef   : TmmFieldDef;
    Data       : TIdBytes; // данные
  private
    FValue      : String;
    function  GetFValue: String;
    procedure SetFValue(const Value: String);
  published
    property Value       : String read GetFValue write SetFValue;
end;
// файл MICROMINE
type
  TMicroMineFile = class(TObject)
    Name           : String;
    Header         : String;
    FileType       : String;
    Size           : Integer;
    FieldCount     : Integer;           // кол-полей
    Data           : TIdBytes;          // данные файла в бинарном виде
    OffSet         : Integer;           // теукщее смещение
    FieldDefList   : TStringList;       // список описания полей
    Records        : TStringList;       // список записей
    TxtTable       : TStringList;       // импортированное представление запсисей в виде таблицы
    FieldSeparator : String;
    DecSeparator   : String;
    FirstRowNames  : Boolean;
  private
    FFileName   : String;
    procedure GetFFileName(const Value: String);
    procedure ReadData;
    procedure ReadHeader;
    // пропуск перевода строки смещением позиции в массиве байтов
    procedure SkipCRLF;
    // пропуск пробелов смещением позиции в массиве байтов
    procedure SkipSpace;
    // чтенеи описания полей
    procedure ReadFieldDefList;
    // чтение данныых записи
    procedure ReadFieldDataList(AFieldDataList : TStringList);
    // чтение записей
    procedure ReadRecordList;
    // поиск начала позиции строки в массиве данных
    function PosByString(AFindString : String) : Integer;
  public
    function ExportToTxt : TStringList;

    constructor Create;
    destructor  Destroy;
published
    property FileName : String read FFileName write GetFFileName;
end;


implementation

uses U_Tools;

{ TMicoMineFile }

constructor TMicroMineFile.Create;
begin
  FieldDefList := TStringList.Create;
  Records      := TStringList.Create;
  TxtTable     := TStringList.Create;
end;

destructor TMicroMineFile.Destroy;
var
   i                             : Integer;
   wTStringList                  : TStringList;
begin
  if Records <> nil then
    begin
      for i := Pred(Records.Count) downto 0 do
        begin
             if Records.Objects[i] <> nil then
               begin
                 wTStringList := TStringList(Records.Objects[i]);
                 FreeAndNil(wTStringList);
               end;
        end;
      FreeAndNil(Records);
    end;
  if FieldDefList <> nil then
    begin
      for i := Pred(FieldDefList.Count) downto 0 do
        begin
             if FieldDefList.Objects[i] <> nil then
               begin
                 wTStringList := TStringList(FieldDefList.Objects[i]);
                 FreeAndNil(wTStringList);
               end;
        end;
      FreeAndNil(FieldDefList);
    end;
  if TxtTable <> nil then
      FreeAndNil(TxtTable);
end;

function TMicroMineFile.ExportToTxt : TStringList;
var
   i                   : Integer;
   j                   : Integer;
   wTStringList        : TStringList;
   wS                  : String;
   wTmmFieldDef        : TmmFieldDef;
   wFieldDataList      : TStringList;
   wTmmField           : TmmField;
begin
  wTStringList := TStringList.Create;

  wS := '';
  // описание полей
  for j := 0 to Pred(FieldDefList.Count) do
    begin
      wS := '';
      wTmmFieldDef                := TmmFieldDef(FieldDefList.Objects[j]);
      wS := wS  + wTmmFieldDef.Name + ' ' + wTmmFieldDef.DataType
         + ' ' + IntToStr(wTmmFieldDef.Size)
         + ' ' + IntToStr(wTmmFieldDef.VisibleSize);
       //wTStringList.Add(wS);
    end;

  wS := '';
  // имена полей
  if FirstRowNames then
    begin
      for j := 0 to Pred(FieldDefList.Count) do
        begin
           wTmmFieldDef                := TmmFieldDef(FieldDefList.Objects[j]);
           wTmmFieldDef.DecSeparator   := DecSeparator;
           wS                          := wS + wTmmFieldDef.Name + FieldSeparator;
        end;
      wTStringList.Add(wS);
    end;
  // данные
  for i := 0 to Pred(Records.Count) do
    begin
      wFieldDataList := TStringList(Records.Objects[i]);
      wS := '';
      for j := 0 to Pred(FieldDefList.Count) do
        begin
          wTmmField := TmmField(wFieldDataList.Objects[j]);
          wS := wS + wTmmField.Value + FieldSeparator;
        end;
       wTStringList.Add(wS);
    end;

  TxtTable.Assign(wTStringList);
  Result := wTStringList;
end;

// начало разбора файла
procedure TMicroMineFile.GetFFileName(const Value: String);
begin
  FFileName := Value; // имя файла
  ReadData;           // чтение данных файла
  // разбор данных
  ReadHeader;
  if FileType = 'MICROMINE' then
    begin
      ReadFieldDefList;   // чтение описания полей
      ReadRecordList;     // чтение записей
      Exit;
    end;

  FileType := 'UNKNOWN';
  Exit;
  // пока реализации нет

  // иначе возможно MINEFRAME
  TxtTable.LoadFromFile(FFileName);
  ReadFieldDefList;   // чтение описания полей
  if FileType = 'UNKNOWN' then
    begin
      Exit;
    end;
  ReadRecordList;     // чтение записей
end;

// поиск начала позиции строки в массиве данных
function TMicroMineFile.PosByString(AFindString: String): Integer;
var
   i       : Integer;
   j       : Integer;
   wLength : Integer;
   wS      : String;
   wBytes  : TIdBytes;
begin
     Result := 0;
     wLength := Length(AFindString);
     SetLength(wBytes, wLength);
     for i := 0 to Pred(Size) do
         begin
              for j := 0 to Pred(wLength) do
                begin
                     wBytes[j] := Data[i + j];
                end;
              ws := BytesToString(wBytes, IndyTextEncoding_OSDefault);
              if ws =  AFindString then
                begin
                  Result := i;
                  Exit;
                end;
         end;
end;

// чтение данных файла
procedure TMicroMineFile.ReadData;
var
   FileStream    : TFileStream;
begin
   // Создаем объект TFileStream для чтения бинарного файла
   FileStream := TFileStream.Create(FFileName, fmOpenRead);
   try     // Определяем размер бинарных данных
     Size := FileStream.Size;
     SetLength(Data, Size);
     // Считываем бинарные данные в массив байт
     FileStream.ReadBuffer(Data[0], FileStream.Size);
   finally
     // Закрываем файл
     FileStream.Free;
   end;

end;

procedure TMicroMineFile.ReadFieldDefList;
var
   i                : Integer;
   wBytes           : TIdBytes;
   wByte            : Byte;
   wTmmFieldDef     : TmmFieldDef;
   wS               : String;
begin
     if FieldDefList = nil then
       FieldDefList := TSTringList.Create;
     FieldDefList.Clear;
     if FileType = 'MICROMINE' then
       begin
          // читаем описания полей
          for i := 0 to Pred(FieldCount) do
              begin
                SkipCRLF; // пропускаем перевод строки
                // создаем эксземпляр класса TmmFieldDef
                wTmmFieldDef := TmmFieldDef.Create;
                // имя поля
                wS := ReadStringFromBytes(Data, OffSet, OffSet + 10);
                wTmmFieldDef.Name := Trim(wS);
                OffSet := OffSet + 10;
                // тип
                wS := ReadStringFromBytes(Data, OffSet, OffSet + 1);
                wTmmFieldDef.DataType := Trim(wS);
                OffSet := OffSet + 1;
                // размер
                wS := ReadStringFromBytes(Data, OffSet, OffSet + 3);
                wTmmFieldDef.Size := StrToInt(Trim(wS));
                OffSet := OffSet + 3;
                // видимый размер
                wS := ReadStringFromBytes(Data, OffSet, OffSet + 3);
                wTmmFieldDef.VisibleSize := StrToInt(Trim(wS));
                OffSet := OffSet + 3;
                // смотрил есть ли описание поля
                wS := ReadStringFromBytes(Data, OffSet, OffSet + 1);
                if wS = '|' then  // заявленный разделитель описания поля
                  begin
                       OffSet := OffSet + 1;
                       wS := ReadStringFromBytes(Data, OffSet, OffSet + 20); // размер с потолка
                       wTmmFieldDef.Decription := Trim(wS);
                       OffSet := OffSet + Length(wS);
                       // поиск конца строки
                       while OffSet < Size do
                             begin
                               wByte   := Data[OffSet];
                               if wByte  = 13 then
                                 begin
                                   OffSet := OffSet + 1;
                                   Break;
                                 end;
                               OffSet := OffSet + 1;
                             end;
                       //wS := ReadStringFromBytes(ABytes, wOffSet, wOffSet + 20);
                  end
                else
                    wTmmFieldDef.Decription := wTmmFieldDef.Name;

                FieldDefList.AddObject(wTmmFieldDef.Name, wTmmFieldDef);
              end;
          Exit;
       end;

       // MINEFRAME или UNKNOWN
       if TxtTable.Count > 0 then
         begin
           wS := TxtTable[0]; // предположительно заголовок таблицы
           if Pos(FieldSeparator, wS) < 1 then
             begin
               FileType := 'UNKNOWN';
               Exit;
             end;

           StringToList(wS, FieldSeparator, FieldDefList);
           if FieldDefList.Count =  0 then
             begin
               FileType := 'UNKNOWN';
               Exit;
             end;
           for i := 0 to Pred(FieldDefList.Count) do
             begin
               wTmmFieldDef                := TmmFieldDef.Create;
               wTmmFieldDef.Name           := FieldDefList[i];
               wTmmFieldDef.DataType       := 'C';
               wTmmFieldDef.Size           := 255;
               FieldDefList.Objects[i]     := wTmmFieldDef;
             end;
         end;

end;

procedure TMicroMineFile.ReadHeader;
var
   wPos        : Integer;
   wS          : String;
begin
     Header := ReadStringFromBytes(Data, 0, 255);
     FileType := 'MICROMINE';
     if Pos('THIS IS MICROMINE', Header) < 1 then
       begin
         FileType := 'MAINFRAME'; // предположительно
         Exit;
       end;
     // Находим объявление кол-ва полей
     wPos := PosByString('VARIABLES');
     // Читаем кол-во полей оно идет до VARIABLES    - весьма странный подход
     wS := ReadStringFromBytes(Data, wPos - 4, wPos - 1);
     FieldCount := StrToInt(Trim(wS));
     // текущая позиция после того как узнали кол-во
     // дальше будет опмсание полеей
     OffSet := wPos + Length('VARIABLES');
end;

// чтение данных полей записи
procedure TMicroMineFile.ReadFieldDataList(AFieldDataList : TStringList);
var
   i                : Integer;
   j                : Integer;
   wTmmFieldDef     : TmmFieldDef;
   wTmmField        : TmmField;
   wS               : String;
begin
     if AFieldDataList = nil then
       AFieldDataList := TSTringList.Create;
     AFieldDataList.Clear;

     //SkipSpace;
     for i := 0 to Pred(FieldDefList.Count) do
       begin
            wTmmFieldDef := TmmFieldDef(FieldDefList.Objects[i]);
            wTmmField    := TmmField.Create;
            wTmmField.FieldDef := wTmmFieldDef;
            // выделяем память для данных соответсвенно описанию
            SetLength(wTmmField.Data, wTmmFieldDef.Size);
            // размещаем данные
            for j := 0 to Pred(wTmmFieldDef.Size) do
              begin
                wTmmField.Data[j] := Data[OffSet];
                Inc(OffSet);
              end;

            wS := BytesToString(wTmmField.Data, IndyTextEncoding_OSDefault);
            AFieldDataList.AddObject(wTmmField.FieldDef.Name, wTmmField);
       end;
end;

// чтение записей
procedure  TMicroMineFile.ReadRecordList;
var
   i                : Integer;
   j                : Integer;
   wS               : String;
   wFieldDataList   : TStringList;
   wTmmFieldDef     : TmmFieldDef;
   wTmmField        : TmmField;
   wTStringList     : TStringList;
begin
     i := 0;
     Records.Clear;
     if FileType = 'MICROMINE' then
       begin
          Self.SkipSpace;
          Self.SkipCRLF;
          while OffSet < Size do  // смещения OffSet происходит в процедурах чтения данных
             begin
                  Inc(i);
                  // поля с данными
                  wFieldDataList := TStringList.Create;
                  Records.AddObject(IntToStr(i), wFieldDataList);  // список записей с данными полей
                  ReadFieldDataList(wFieldDataList);               // чтение данных
                  Self.SkipSpace;
                  Self.SkipCRLF;
             end;
          Exit;
       end;

     // иначе пытаемся читать как MINEFRAME
     for i := 1 to Pred(TxtTable.Count) do
       begin
         wTStringList := TStringList.Create; // временный буфер для чтения данных
         try
           // поля с данными
            wFieldDataList := TStringList.Create;
            Records.AddObject(IntToStr(i), wFieldDataList);  // список записей с данными полей
            wS := TxtTable[i]; // читаем строку с данными полец
            StringToList(wS, FieldSeparator, wTStringList);
            for j  := 0 to Pred(FieldDefList.Count) do
              begin
                wTmmFieldDef := TmmFieldDef(FieldDefList.Objects[j]);
                wTmmField    := TmmField.Create;
                wTmmField.FieldDef := wTmmFieldDef;
                wTmmField.Value    := wTStringList[j];
                wFieldDataList.AddObject(wTmmFieldDef.Name, wTmmFieldDef); // поле и его значение
              end;
         finally
           FreeAndNil(wTStringList);
         end;
       end;

end;

// пропуск перевода строки смещением позиции в массиве байтов
procedure TMicroMineFile.SkipCRLF;
var
   wByte            : Byte;
begin
  if OffSet >= Size then
    Exit;
   wByte := Data[OffSet];
   if WByte = 13 then
     Inc(OffSet);
  if OffSet >= Size then
    Exit;
   wByte := Data[OffSet];
   if WByte = 10 then
     Inc(OffSet);
end;

// пропуск пробелов смещением позиции в массиве байтов
procedure TMicroMineFile.SkipSpace;
var
   wByte            : Byte;
begin
     while Self.OffSet < Self.Size do
       begin
         wByte := Data[OffSet];
         if wByte = 32 then
           begin
             Inc(OffSet);
           end
         else
           Break;
       end;
end;

{ TmmField }


// преобразуем бинарные данные поля в строку
function TmmField.GetFValue: String;
var
   wM         : Int64;       // мантисса
   wE         : Integer;     // экспонента
   wSgn       : Integer;     // знак
   wMBits     : AnsiString;
   wEBits     : AnsiString;
   wSign      : AnsiString;
   i          : Integer;
   wS         : AnsiString;
   wByte      : Byte;
   wValue     : Double;
begin
  if FieldDef.DataType = 'C' then
    begin
         Result := BytesToString(Data, IndyTextEncoding_OSDefault);
         Result := Trim(Result);
         Exit;
    end;

  if FieldDef.DataType = 'N' then
    begin
         Result := BytesToString(Data, IndyTextEncoding_OSDefault);
         Result := Trim(Result);
         Exit;
    end;

  if FieldDef.DataType = 'R'then
    begin
      // не ожидал подобного хранения вещественного числа - танцуем с бубнами
      wValue := BytesArrayToDouble(Data); // берем прочитанные из файла байты и преобразуем в Double
      FValue := FloatToStr(wValue);
      //if FValue = 'NAN' then        // не число
      //  ShowMessage('NAN');
      Result := FloatToStr(wValue); // тут полное число с десятичными в строке
      // не понятна тема кол-ва отображаемых цифр
      Result := FloatToStrF(wValue, ffFixed, 8, FieldDef.VisibleSize); // тут можно сделать форматирование
      Exit;

      // далее классический разбор Double в памяти, как оказалось всё не так
      wS := '';
      for i := 0 to  Pred(FieldDef.Size) do
        begin
          wByte := Data[i];
          wS := wS + dec2bin(wByte);
        end;
      wSign     := Copy(wS, 1, 1);         // знак
      if wSign = '1' then
        wSgn := -1
      else
        wSgn :=  1;

      wEBits    := Copy(wS, 2, 11);        // побитовая экспонента
      wMBits    := Copy(wS, 13, 52);       // побитовая мантисса

      wE   := bin2dec(wEBits);             // десятичная экспонента
      wM   := bin2dec(wMBits);             // десятичная мантисса
      // Вычисляем значение поля
      wValue := wSgn * Power(wE - 1023, 2) * (1 + wM / Power(52, 2));
      Result := FloatToStrF(wValue, ffExponent, FieldDef.Size, FieldDef.VisibleSize);
      Result := StringReplace(Result, ',', FieldDef.DecSeparator, []);
      Exit;
    end;
end;

// пишем строковое значение поля в бинарном представление
procedure TmmField.SetFValue(const Value: String);
var
  i       : Integer;
  wByte   : Byte;
  wValue  : Double;
  wS      : String;
  wM         : Double;       // мантисса
  wE         : Integer;     // экспонента
  wSgn       : Integer;     // знак
  wMBits     : String;
  wEBits     : String;
  wSign      : String;
begin
  SetLength(Data, FieldDef.Size);
  if FieldDef.DataType = 'C' then
    begin
        for i := 1 to Length(Value) do
          begin
            wByte := Ord(Value[i]);
            Data[i - 1] := wByte;
          end;
        for i := i to FieldDef.Size do
          begin
            Data[i - 1] := 32; // пробелы
          end;
        wS := BytesToString(Data, IndyTextEncoding_OSDefault);
    end;
  if FieldDef.DataType = 'N' then
    begin
        for i := 1 to Length(Value) do
          begin
            wByte := Ord(Value[i]);
            Data[i - 1] := wByte;
          end;
        for i := i to FieldDef.Size do
          begin
            Data[i - 1] := 32; // пробелы
          end;
        wS := BytesToString(Data, IndyTextEncoding_OSDefault);
    end;
  // пытаемся перевести вещественное в бинарное представление
  if FieldDef.DataType = 'R' then
    begin
      try
        wValue := StrToFloat(Value);
        Frexp(wValue, wM, wE);
      except
        //
      end;
    end;

end;

end.
