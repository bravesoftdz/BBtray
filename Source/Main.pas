
//
// BBtray: Main Unit
//
// (c) 1999,2001 - Deluan Cotts Quintão
// bbtray@deluan.com.br
//
// $Label: $
// $CheckOutDate: $
(*
$History: $
*)
// $NoKeyWords

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, CoolTrayIcon, ExtCtrls, Menus, ShellApi,
  MMSystem, IniFiles, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, IdAntiFreezeBase, IdAntiFreeze, IdIntercept,
  IdSSLIntercept, IdSSLOpenSSL;

const VERSION       = '0.9.1a';
      INIFILE       = 'BBTRAY.INI';
      BBDISPLAY     = '';
      BBSOUNDS      = '.\';
      BBICONS       = '.\';
      POLLFREQUENCY = 15;       // 15 seconds between checks
      PAGEDELAY     = 15 * 60;  // 15 mins between sound alerts
      POPUPLEVELS   = 'r,g,p,y';
      PROXYPORT     = 3128;

type
  TMainForm = class(TForm)
    CoolTrayIcon1: TCoolTrayIcon;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    N1: TMenuItem;
    OpenBigBrother1: TMenuItem;
    ImageList1: TImageList;
    About1: TMenuItem;
    http: TIdHTTP;
    IdAntiFreeze1: TIdAntiFreeze;
    IdConnectionInterceptOpenSSL1: TIdConnectionInterceptOpenSSL;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure CoolTrayIcon1DblClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
    FirstAlertTime: DWORD;
    FSound: TMemoryStream;
    FSoundHttp: TIdHTTP;
    FSoundsURL: String;
    FPollFrequency: Integer;
    FHintString: String;
    FPopupString: String;
    FStartAll: Boolean;
    FPageDelay: DWORD;
    FMsgVerify: String;
    FMsgNoConn: String;
    FMsgInvStatus: String;
    FPopupLevels: String;
    FProxyName: String;
    FIconsPath: String;
    FShowHTTPError: Boolean;
    FColor: String;
    FTitle: String;
    procedure LoadConfig(SectionName: String);
    procedure ShowStatus(NewStatus: String);
    procedure PlayStatus(NewStatus: String);
    procedure LoadIcons;
    procedure ParseURL(URL: String; DefaultPort: Integer;
      var NewURL: String; var Port: Integer);
    function PrepareURL(URL: String; H: TIdHTTP): String;
    procedure SetProxy(H: TIdHTTP);
    function FormatCaption(FmtStr: String): String;
    procedure StartAll(List: TStrings);
  public
    { Public declarations }
    FDisplayURL: String;
  end;

var
  MainForm: TMainForm;

implementation

uses Mesg;

const MAXCOLORS   = 4;
      ColorChars  = 'yprg';
      ColorColors : array[1..MAXCOLORS] of TColor =
                    (clYellow, clPurple, clRed, clGreen);
      ColorNames  : array[1..MAXCOLORS] of String =
                    ('yellow', 'purple', 'red', 'green');

{$R *.DFM}

function NoComment(S: String): String;
var I: Integer;
begin
     I := Pos(';', S);
     if I > 1 then
        SetLength(S, I-1);
     Result := Trim(S);
end;

procedure TMainForm.ParseURL(URL: String; DefaultPort: Integer;
  var NewURL: String; var Port: Integer);
var I: Integer;
    S: String;
begin
     if DefaultPort = 0 then begin
        if Copy(URL, 1, 5) = 'https' then
           DefaultPort := 443
        else
           DefaultPort := 80;
     end;
     
     NewURL := '';
     S := URL;
     Port := DefaultPort;
     if S <> '' then begin
        if Copy(S, 1, 4) = 'http' then begin
           I := Pos(':', S);
           NewURL := Copy(S, 1, I);
           Delete(S, 1, I);
        end;
        I := Pos(':', S);
        if I = 0 then begin
           NewURL := NewURL + S;
           Port := DefaultPort;
        end
        else
           try
              NewURL := NewURL + Copy(S, 1, I-1); Delete(S, 1, I);
              I := Pos('/', S);
              if I = 0 then I := 1000;
              Port := StrToInt(Copy(S, 1, I-1));
              Delete(S, 1, I-1);
              NewURL := NewURL + S;
           except
              NewURL := URL;
              Port := DefaultPort;
           end
     end;
end;

function TMainForm.PrepareURL(URL: String; H: TIdHTTP): String;
var I, AuthPos, AuthLen: Integer;
    S: String;
begin
     Result := URL;
     I := Pos('@', URL);
     if I = 0 then begin
        H.Request.Username := '';
        H.Request.Password := '';
     end
     else begin
        if Copy(URL, 1, 5) = 'https' then begin
           AuthPos := 9;
           AuthLen := I-8;
        end
        else begin
           AuthPos := 8;
           Authlen := I-7;
        end;
        Delete(Result, AuthPos, AuthLen);
        S := Copy(URL, AuthPos, AuthLen-1);
        I := Pos(':', S);
        H.Request.Username := Copy(S, 1, I-1);
        H.Request.Password := Copy(S, I+1, 255);
        S := H.Request.Password;
     end;
     ParseURL(Result, 0, S, I);
     H.Port := I;
end;

procedure TMainForm.SetProxy(H: TIdHTTP);
var U: String;
    P: Integer;
begin
     ParseURL(FProxyName, PROXYPORT, U, P);
     H.Request.ProxyServer := U;
     H.Request.ProxyPort := P;
end;

function TMainForm.FormatCaption(FmtStr: String): String;
var I: Integer;
    Ident: Char;
    Value: String;
begin
     Result := FmtStr;
     I := Pos('%', Result);
     while I > 0 do begin
           Delete(Result, I, 1);
           if Result[I] <> '%' then begin
              Ident := Result[I];
              Delete(Result, I, 1);
              case Ident of
                   'U': Value := FDisplayURL;
                   'c': Value := Copy(FColor, 1, 1);
                   'C': Value := FColor;
                   'T': Value := FTitle;
                   else Value := '';
              end;
              Insert(Value, Result, I);
           end;
           I := Pos('%', Result);
     end;
     I := Pos('\n', Result);
     while I > 0 do begin
           Delete(Result, I, 2);
           Insert(#10, Result, I);
           I := Pos('\n', Result);
     end;
end;

procedure TMainForm.LoadConfig(SectionName: String);
var Ini: TIniFile;
    SectionList: TStringList;
begin
     FDisplayURL := BBDISPLAY;
     FSoundsURL := BBSOUNDS;
     FIconsPath := BBICONS;
     FPollFrequency := POLLFREQUENCY;
     FPageDelay := PAGEDELAY;
     FPopupLevels := POPUPLEVELS;

     Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + INIFILE);
     try
        FDisplayURL := NoComment(Ini.ReadString('General', 'DisplayURL', BBDISPLAY));
        FSoundsURL := NoComment(Ini.ReadString('General', 'SoundsURL', BBSOUNDS)); // Backwards compatible
        FSoundsURL := NoComment(Ini.ReadString('General', 'SoundsPath', FSoundsURL));
        FIconsPath := NoComment(Ini.ReadString('General', 'IconsPath', FIconsPath));
        FPollFrequency := Ini.ReadInteger('General', 'PoolTime', POLLFREQUENCY); // Backwards compatible
        FPollFrequency := Ini.ReadInteger('General', 'PollFrequency', FPollFrequency);
        FPageDelay := Ini.ReadInteger('General', 'PageDelay', PAGEDELAY);
        FPopupLevels := NoComment(Ini.ReadString('General', 'PopupLevels', POPUPLEVELS));
        FProxyName := NoComment(Ini.ReadString('General', 'ProxyName', ''));
        FHintString := NoComment(Ini.ReadString('General', 'HintString', ''));
        FPopupString := NoComment(Ini.ReadString('General', 'PopupString', ''));

        if SectionName <> '' then begin
           FDisplayURL := NoComment(Ini.ReadString(SectionName, 'DisplayURL', FDisplayURL));
           FSoundsURL := NoComment(Ini.ReadString(SectionName, 'SoundsURL', FSoundsURL)); // Backwards compatible
           FSoundsURL := NoComment(Ini.ReadString(SectionName, 'SoundsPath', FSoundsURL));
           FIconsPath := NoComment(Ini.ReadString(SectionName, 'IconsPath', FIconsPath));
           FPollFrequency := Ini.ReadInteger(SectionName, 'PoolTime', FPollFrequency); // Backwards compatible
           FPollFrequency := Ini.ReadInteger(SectionName, 'PollFrequency', FPollFrequency);
           FPageDelay := Ini.ReadInteger(SectionName, 'PageDelay', FPageDelay);
           FPopupLevels := NoComment(Ini.ReadString(SectionName, 'PopupLevels', FPopupLevels));
           FProxyName := NoComment(Ini.ReadString(SectionName, 'ProxyName', ''));
           FHintString := NoComment(Ini.ReadString(SectionName, 'HintString', FHintString));
           FPopupString := NoComment(Ini.ReadString(SectionName, 'PopupString', FPopupString));
        end;

        FMsgVerify := Ini.ReadString('Messages', 'VERIFY', 'Verificando...');
        FMsgNoConn := Ini.ReadString('Messages', 'NOCONN', 'Não foi possível se conectar ao sistema de monitoramento!');
        FMsgInvStatus := Ini.ReadString('Messages', 'INVSTATUS', 'Recebido um status inválido!');
        FStartAll := Ini.ReadBool('General', 'StartAll', True);
        FShowHTTPError := Ini.ReadBool('General', 'ShowHTTPError', False);

        if FStartAll and (SectionName = '') then begin
           SectionList := TStringList.Create;
           try
              Ini.ReadSections(SectionList);
              StartAll(SectionList);
           finally
              SectionList.Free;
           end;
        end;

     finally
        Ini.Free;
     end;

     if FDisplayURL = '' then begin
        MessageDlg(INIFILE + ' misconfigured or not found! ' + #13 +
                   'Please read the documentation.', mtError, [mbOK], 0);
        Halt(0);
     end;
end;

procedure TMainForm.StartAll(List: TStrings);
var I: Integer;
begin
     for I := 0 to List.Count-1 do begin
         if (AnsiUpperCase(List[I]) <> 'GENERAL') and
            (AnsiUpperCase(List[I]) <> 'MESSAGES') then
            WinExec(PChar(ParamStr(0) + ' ' + List[I]), SW_SHOWNORMAL);
     end;
end;

procedure TMainForm.LoadIcons;
var I: Integer;
    FN: String;
    Icon: TIcon;
begin
     Icon := TIcon.Create;
     try
        for I := 1 to MAXCOLORS do begin
            FN := FIconsPath + '\' + ColorChars[I] + '.ico';
            if FileExists(FN) then begin
               try
                  Icon.LoadFromFile(FN);
                  ImageList1.Delete(I-1);
                  ImageList1.InsertIcon(I-1, Icon);
               except
               end;
            end;
        end;
     finally
        Icon.Free;
     end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
     LoadConfig(ParamStr(1));
     LoadIcons;
     SetProxy(http);
     FSound := TMemoryStream.Create;
     FirstAlertTime := 0;

     CoolTrayIcon1.IconVisible := True;
     CoolTrayIcon1.CycleIcons := True;

     Timer1Timer(Timer1);
     Timer1.Interval := FPollFrequency * 1000;
     Timer1.Enabled := True;
end;

procedure TMainForm.ShowStatus(NewStatus: String);
begin
     frmMesg.Close;
     if Pos(NewStatus, FPopupLevels) > 0 then begin
        frmMesg.Icon := CoolTrayIcon1.Icon;
        if FPopupString = '' then
           frmMesg.ShowMesg(FTitle, ColorColors[Pos(NewStatus, ColorChars)])
        else
           frmMesg.ShowMesg(FormatCaption(FPopupString), ColorColors[Pos(NewStatus, ColorChars)]);
     end;
end;

procedure TMainForm.PlayStatus(NewStatus: String);
var F: TFileStream;
    URL: String;
begin
     if NewStatus = 'r' then
        FirstAlertTime := timeGetTime;

     URL := FSoundsURL + NewStatus + '.wav';
     FSound.Seek(0, 0);
     try
        if Copy(URL, 1, 4) <> 'http' then begin
           F := TFileStream.Create(URL, fmOpenRead);
           try
              FSound.CopyFrom(F, 0);
           finally
              F.Free;
           end;
        end
        else begin
           if not Assigned(FSoundHttp) then begin
              FSoundHttp := TIdHTTP.Create(Nil);
              SetProxy(FSoundHttp);
           end;
           FSoundHttp.Get(PrepareURL(URL, FSoundHttp), FSound);
        end;
        PlaySound(FSound.Memory, Application.Handle, SND_ASYNC + SND_MEMORY + SND_NODEFAULT);
     except
        MessageBeep(MB_ICONEXCLAMATION);
     end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var html: String;
    I, J: Integer;
    LastStatus: String;
    HTTPError: Boolean;
begin
     Timer1.Enabled := False;
     HTTPError := True;
     try
        LastStatus := Copy(FTitle, 1, 1);
//        CoolTrayIcon1.CycleIcons := False;
        CoolTrayIcon1.Hint := FMsgVerify;
        FTitle := '';
        FColor := '';
        try
           html := http.Get(PrepareURL(FDisplayURL, http));
           HTTPError := False;
        except
           on E: EIdOSSLCouldNotLoadSSLLibrary do begin
              ShowMessage('Could not load OpenSSL libraries!' + #13 +
                         'Please check Readme.txt for instructions.');
              Halt(0);
           end;
           on E: Exception do begin
              if FShowHTTPError then begin
                 CoolTrayIcon1.Hint := E.Message;
                 ShowMessage(E.Message);
              end
              else
                 CoolTrayIcon1.Hint := FMsgNoConn;
              CoolTrayIcon1.CycleIcons := True;
           end;
        end;
        if html <> '' then begin
           I := Pos('<TITLE>', html);
           J := Pos('</TITLE>', html);
           if (I * J) = 0 then begin
              CoolTrayIcon1.Hint := FMsgInvStatus;
              CoolTrayIcon1.CycleIcons := True;
           end
           else begin
              Inc(I, 7);
              html := Copy(html, I, J-I);
              FTitle := html;
              I := Pos(html[1], ColorChars);
              if I = 0 then
                 CoolTrayIcon1.CycleIcons := True
              else begin
                 CoolTrayIcon1.CycleIcons := False;
                 FColor := ColorNames[I];
                 ImageList1.GetIcon(I-1, CoolTrayIcon1.Icon);
              end;
           end;
        end;
        CoolTrayIcon1.Refresh;
        CoolTrayIcon1.IconVisible := True;
        if (LastStatus <> Copy(FColor, 1, 1)) and (LastStatus <> '') then begin
           ShowStatus(Copy(FColor, 1, 1));
           PlayStatus(Copy(FColor, 1, 1));
        end
        else if (LastStatus = 'r') and ((timeGetTime - FirstAlertTime) > (FPageDelay * 1000)) then begin
           ShowStatus(Copy(FColor, 1, 1));
           PlayStatus(LastStatus);
        end;

     finally
        if not HTTPError then begin
           if FHintString <> '' then
              CoolTrayIcon1.Hint := Copy(FormatCaption(FHintString), 1, 63)
           else
              CoolTrayIcon1.Hint := FTitle;
        end;
        Timer1.Enabled := True;
     end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
     Halt(0);
end;

procedure TMainForm.CoolTrayIcon1DblClick(Sender: TObject);
begin
  ShellExecute(Application.MainForm.Handle, Nil, PChar(FDisplayURL),
               Nil, Nil, SW_SHOW);
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
     MessageDlg('BBtray ' + VERSION + #13 + #13 +
                'A Big Brother (http://bb4.com) companion' + #13 +
                'by Deluan (bbtray@deluan.com.br)', mtInformation, [mbOk], 0);

end;

end.
