# Base64
Base64 for Delphi

## How to...
```
uses
  Rac.Base64;

...
var
  Encod, Decod: string;
begin
  Encod := TBase64.Encode(TEncoding.UTF8.GetBytes('ABC'));
  try
    Decod := TEncoding.UTF8.GetString(TBase64.Decode(Encod));
  except
    on E: Exception do
      Decod := 'Decode Error: ' + E.Message;
  end;
end;  
```