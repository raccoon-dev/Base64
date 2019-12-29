unit Rac.Base64;

interface

uses
  System.SysUtils;

const
  SWRONG_MESSAGE_LENGTH    = 'Wrong decoded message length';
  SWRONG_MESSAGE_CHARACTER = 'Wrong character in decoded message';

type TBase64 = class
  protected
    procedure _Encode3B(StringBuilder: TStringBuilder; Byte1, Byte2, Byte3: Byte; PadsNr: Integer = 0);
    procedure _Decode4Chars(var Bytes: TBytes; StartBytesIndex: Integer; Char1, Char2, Char3, Char4: Char);
    function  _Encode(Bytes: TBytes; TerminateWithEqualSigns: Boolean = True) : string;
    function  _Decode(EncodedText: string): TBytes;
  public
    class function Encode(Bytes: TBytes; TerminateWithEqualSigns: Boolean = True) : string;
    class function Decode(EncodedText: string): TBytes;
end;

implementation

const
  Base64CharacterSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; // Do not translate

{ TBase64 }

class function TBase64.Decode(EncodedText: string): TBytes;
begin
  with Self.Create do
    try
      Result := _Decode(EncodedText);
    finally
      Free;
    end;
end;

class function TBase64.Encode(Bytes: TBytes; TerminateWithEqualSigns: Boolean): string;
begin
  with Self.Create do
    try
      Result := _Encode(Bytes, TerminateWithEqualSigns);
    finally
      Free;
    end;
end;

function TBase64._Decode(EncodedText: string): TBytes;
var
  i: Integer;
begin
  EncodedText := EncodedText.Trim.Replace(#13, string.Empty, [rfReplaceAll]).Replace(#10, string.Empty, [rfReplaceAll]);
  if EncodedText.Length > 0 then
  begin

    if EncodedText.EndsWith('==') then
    begin
      if (EncodedText.Length mod 4) <> 0 then
        raise Exception.Create(SWRONG_MESSAGE_LENGTH);

      SetLength(Result, ((EncodedText.Length div 4) * 3) - 2);
      for i := 1 to (EncodedText.Length div 4) do
        _Decode4Chars(Result,
                      (i - 1) * 3,
                      EncodedText[ ((i - 1) * 4)      + Low(string)],
                      EncodedText[(((i - 1) * 4) + 1) + Low(string)],
                      EncodedText[(((i - 1) * 4) + 2) + Low(string)],
                      EncodedText[(((i - 1) * 4) + 3) + Low(string)]);
    end else

    if EncodedText.EndsWith('=') then
    begin
      if (EncodedText.Length mod 4) <> 0 then
        raise Exception.Create(SWRONG_MESSAGE_LENGTH);

      SetLength(Result, ((EncodedText.Length div 4) * 3) - 1);
      for i := 1 to (EncodedText.Length div 4) do
        _Decode4Chars(Result,
                      (i - 1) * 3,
                      EncodedText[ ((i - 1) * 4)      + Low(string)],
                      EncodedText[(((i - 1) * 4) + 1) + Low(string)],
                      EncodedText[(((i - 1) * 4) + 2) + Low(string)],
                      EncodedText[(((i - 1) * 4) + 3) + Low(string)]);
    end else

    begin
      if (EncodedText.Length mod 4) = 1 then
        raise Exception.Create(SWRONG_MESSAGE_LENGTH);

      case (EncodedText.Length mod 4) of
        0: SetLength(Result, ((EncodedText.Length div 4) * 3)    );
        2: SetLength(Result, ((EncodedText.Length div 4) * 3) + 1);
        3: SetLength(Result, ((EncodedText.Length div 4) * 3) + 2);
      else
        // Impossible
      end;
      for i := 1 to (EncodedText.Length div 4) do
        _Decode4Chars(Result,
                      (i - 1) * 3,
                      EncodedText[ ((i - 1) * 4)      + Low(string)],
                      EncodedText[(((i - 1) * 4) + 1) + Low(string)],
                      EncodedText[(((i - 1) * 4) + 2) + Low(string)],
                      EncodedText[(((i - 1) * 4) + 3) + Low(string)]);
      case (EncodedText.Length mod 4) of
        2: _Decode4Chars(Result,
                         High(Result),
                         EncodedText[High(EncodedText) - 1],
                         EncodedText[High(EncodedText)    ],
                         '=',
                         '=');
        3: _Decode4Chars(Result,
                         High(Result) - 1,
                         EncodedText[High(EncodedText) - 2],
                         EncodedText[High(EncodedText) - 1],
                         EncodedText[High(EncodedText)    ],
                         '=');
      else
        // Impossible or nothing to do if 0
      end;
    end;

  end;
end;

procedure TBase64._Decode4Chars(var Bytes: TBytes; StartBytesIndex: Integer;
  Char1, Char2, Char3, Char4: Char);
var
  b1, b2, b3, b4: Integer;
begin
  b1 := Base64CharacterSet.IndexOf(Char1);
  b2 := Base64CharacterSet.IndexOf(Char2);
  b3 := Base64CharacterSet.IndexOf(Char3);
  b4 := Base64CharacterSet.IndexOf(Char4);
  if (b1 < 0) or (b2 < 0) or ((b3 < 0) and (Char3 <> '=')) or ((b4 < 0) and (Char4 <> '=')) then
    raise Exception.Create(SWRONG_MESSAGE_CHARACTER);

  Bytes[StartBytesIndex] := (b1 shl 2) + (b2 shr 4);
  if b3 > -1 then
    Bytes[StartBytesIndex + 1] := (b2 shl 4) + (b3 shr 2);
  if b4 > -1 then
    Bytes[StartBytesIndex + 2] := (b3 shl 6) +  b4;
end;

function TBase64._Encode(Bytes: TBytes; TerminateWithEqualSigns: Boolean): string;
var
  i: Integer;
  sb: TStringBuilder;
begin
  if Length(Bytes) > 0 then
  begin
    sb := TStringBuilder.Create;
    try
      for i := 1 to (Length(Bytes) div 3) do
        _Encode3B(sb,
                  Bytes[(i - 1) * 3],
                  Bytes[((i - 1) * 3) + 1],
                  Bytes[((i - 1) * 3) + 2]);
      if (Length(Bytes) mod 3) = 1 then
      begin
        _Encode3B(sb,
                  Bytes[High(Bytes)],
                  0,
                  0,
                  2);
        if not TerminateWithEqualSigns then
          sb.Remove(sb.Length - 2, 2);
      end else
      if (Length(Bytes) mod 3) = 2 then
      begin
        _Encode3B(sb,
                  Bytes[High(Bytes) - 1],
                  Bytes[High(Bytes)],
                  0,
                  1);
        if not TerminateWithEqualSigns then
          sb.Remove(sb.Length - 1, 1);
      end;
      Result := sb.ToString;
    finally
      sb.Free;
    end;

  end else
    Result := string.Empty;
end;

procedure TBase64._Encode3B(StringBuilder: TStringBuilder; Byte1, Byte2,
  Byte3: Byte; PadsNr: Integer);
begin
  StringBuilder.Append(Base64CharacterSet[(Byte1 shr 2) + Low(string)]);

  StringBuilder.Append(Base64CharacterSet[((Byte1 and $3) shl 4) + (Byte2 shr 4) + Low(string)]);

  if PadsNr < 2 then
    StringBuilder.Append(Base64CharacterSet[((Byte2 and $F) shl 2) + (Byte3 shr 6) + Low(string)]) else
  begin
    StringBuilder.Append('==');
    Exit;
  end;

  if PadsNr < 1 then
    StringBuilder.Append(Base64CharacterSet[(Byte3 and $3F) + Low(string)])
  else
    StringBuilder.Append('=');
end;

end.
