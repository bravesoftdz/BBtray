object frmMesg: TfrmMesg
  Left = 225
  Top = 177
  BorderStyle = bsDialog
  ClientHeight = 142
  ClientWidth = 533
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 533
    Height = 142
    Cursor = crHandPoint
    Align = alClient
    Alignment = taCenter
    Caption = 'green : Big Brother - Status @ Wed Nov 24 19:23:48 BRST 1999'
    Color = clGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
    WordWrap = True
    OnClick = Label1Click
    OnDblClick = Label1Click
  end
end
