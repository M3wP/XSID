unit FormDumpConvertMain;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}

interface

uses
{$IFDEF MSWINDOWS}
	Windows,
{$ENDIF}
	Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, ExtCtrls, Buttons;

type
	TXSIDHeaderRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Byte;
		version: Byte;
		format: Byte;
		sidCnt: Byte;
		system: Byte;
		updateRate: Byte;
	end;

	TXSIDSIDDescRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Cardinal;
		sid: Byte;
		sidType: Byte;
	end;

	TXSIDTrackRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Cardinal;
		compType: Byte;
	end;

	TXSIDMetaDataRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Cardinal;
	end;

	TForm1 = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		ComboBox1: TComboBox;
		Label3: TLabel;
		ComboBox2: TComboBox;
		Label4: TLabel;
		ComboBox3: TComboBox;
		Memo1: TMemo;
		Label5: TLabel;
		CheckBox1: TCheckBox;
		CheckBox2: TCheckBox;
		CheckBox3: TCheckBox;
		CheckBox4: TCheckBox;
		CheckBox5: TCheckBox;
		Memo2: TMemo;
		Label6: TLabel;
		Button1: TButton;
		OpenDialog1: TOpenDialog;
		Label7: TLabel;
		ComboBox4: TComboBox;
		Edit1: TEdit;
		SpeedButton1: TSpeedButton;
		procedure Button1Click(Sender: TObject);
		procedure SpeedButton1Click(Sender: TObject);
	private
		procedure DoWriteHeader(AStream: TStream);
		procedure DoWriteSIDDesc(AStream: TStream);
		procedure DoConvertTracks(AStream: TStream);
		procedure DoWriteMetaData(AStream: TStream);

	public
		{ Public declarations }
	end;

var
	Form1: TForm1;

implementation

{$R *.dfm}

uses
	ULZBinTree, URangeEncoder, ULZMAEncoder;

procedure TForm1.Button1Click(Sender: TObject);
	var
	s: string;
	m: TMemoryStream;
	f: TFileStream;

	begin
	if  FileExists(Edit1.Text) then
		begin
		s:= ChangeFileExt(Edit1.Text, '.xsid');

		m:= TMemoryStream.Create;
		try
			DoWriteHeader(m);
			DoWriteSIDDesc(m);
			DoConvertTracks(m);
			DoWriteMetaData(m);

			m.Position:= 0;

			f:= TFileStream.Create(s, fmCreate);
			try
				f.CopyFrom(m, m.Size);

				finally
				f.Free;
				end;

			finally
			m.Free;
			end;
		end;
	end;

//Should make it a function and return false if value can not fit in AResult
procedure CardToVarLen(const AValue: Cardinal; var ALen: Byte;
		var AResult: array of Byte; const AMaxLen: Byte = 4);
	var
	i: Byte;
	data: Cardinal;
	buffer: Integer;

	begin
//	These must be true
	Assert(AMaxLen > 0);
	Assert(Length(AResult) >= AMaxLen);
	Assert(AValue < ($01 shl (AMaxLen * 7)));

	ALen:= 0;
	buffer:= AValue and $7F;

	data:= AValue shr 7;
	while (ALen < AMaxLen) and (data > 0) do
		begin
//		Data bytes
		buffer:= buffer shl 8;
		buffer:= buffer or Byte((data and $7F) or $80);

		data:= data shr 7;
		Inc(ALen);
		end;

//	First/Last byte
	Inc(ALen);

//	Byte swap for big endian!
	for i:= 0 to ALen - 1 do
		begin
		AResult[i]:= buffer and $FF;

//		Shouldn't need this if test for break since the length is known
		if (buffer and $80) > 0 then
			buffer:= buffer shr 8
		else
//			???
			Break;
		end;
	end;

procedure TForm1.DoConvertTracks(AStream: TStream);
	var
	h: TXSIDTrackRec;
	mtk: Boolean;
	enb: array[0..3] of Boolean;
	os: Integer;
	mos: array[0..3] of TMemoryStream;
	mts: TMemoryStream;
	c: TLZMAEncoder;
	ofs: array[0..3] of Cardinal;
	fis: TFileStream;
	o: Cardinal;
	r,
	v: Byte;
	ov: array[0..3] of Byte;
	vl: Byte;
	w: Boolean;
	i: Integer;

	procedure ReadOffset;
		var
		b: AnsiChar;
		s: AnsiString;

		begin
		s:= '';
		fis.Read(b, 1);
		while b <> #32 do
			begin
			s:= s + b;
			fis.Read(b, 1);
			end;

		o:= StrToInt64(string(s));
		end;

	procedure ReadRegister;
		var
		b: AnsiChar;
		s: AnsiString;
		n: Byte;

		begin
		s:= '';
		fis.Read(b, 1);
		while b <> #32 do
			begin
			s:= s + b;
			fis.Read(b, 1);
			end;

		n:= StrToInt(string(s));
		if n > 24 then
			Exception.Create('Invalid register number');

		r:= Byte(n);
		end;

	procedure ReadValue;
		var
		b: AnsiChar;
		s: AnsiString;

		begin
		s:= '';
		fis.Read(b, 1);
		while not (b in [#32, #13, #10]) do
			begin
			s:= s + b;
			fis.Read(b, 1);
			end;

		v:= StrToInt(string(s));

		while (fis.Position < fis.Size) and (b in [#32, #13, #10]) do
			fis.Read(b, 1);

		if fis.Position < fis.Size then
			fis.Seek(-1, soCurrent);
		end;

	begin
	mtk:= ComboBox1.ItemIndex = 1;

	enb[0]:= CheckBox2.Checked;
	enb[1]:= CheckBox3.Checked;
	enb[2]:= CheckBox4.Checked;
	enb[3]:= CheckBox5.Checked;

	ofs[0]:= 0;
	ofs[1]:= 0;
	ofs[2]:= 0;
	ofs[3]:= 0;

	mos[0]:= TMemoryStream.Create;
	mos[1]:= TMemoryStream.Create;
	mos[2]:= TMemoryStream.Create;
	mos[3]:= TMemoryStream.Create;
	try
		fis:= TFileStream.Create(Edit1.Text, fmOpenRead);
		try
			fis.Seek(0, soFromBeginning);
			while fis.Position < fis.Size do
				try
					ReadOffset;
					ReadRegister;
					ReadValue;

					w:= ((r in [0..6]) and enb[0]) or
							((r in [7..13]) and enb[1]) or
							((r in [14..20]) and enb[2]) or
							((r in [21..24]) and enb[3]);

					if  w then
						if  (not mtk)
						or  (r in [0..6]) then
							os:= 0
						else if r in [7..13] then
							os:= 1
						else if r in [14..20] then
							os:= 2
						else
							os:= 3
					else
						os:= -1;

					for i:= 0 to 3 do
						Inc(ofs[i], o);

					if  w then
						begin
						CardToVarLen(ofs[os], vl, ov);
						mos[os].Write(ov[0], vl);
						mos[os].Write(r, 1);
						mos[os].Write(v, 1);

						ofs[os]:= 0;
						end;

					except
					Break;
					end;
			finally
			fis.Free;
			end;

		for i:= 0 to 3 do
			begin
			mos[i].Position:= 0;

			if  mos[i].Size > 0 then
				begin
				h.tag:= 'XSTK';

				if  CheckBox1.Checked then
					begin
					h.compType:= 2;

					mts:= TMemoryStream.Create;

					ULZBinTree.InitCRC;
					URangeEncoder.RangeEncoder:= TRangeEncoder.Create;
					c:= TLZMAEncoder.Create;
					try
						c.SetAlgorithm(2);
						c.SetDictionarySize(1 shl 23);
						c.SeNumFastBytes(128);
						c.SetMatchFinder(1);
						c.SetLcLpPb(3, 0, 2);
						c.SetEndMarkerMode(True);
//						c.WriteCoderProperties(mts);
						c.Code(mos[i], mts, -1, -1);

						finally
						c.Free;
						URangeEncoder.RangeEncoder.Free;
						end;


					mts.Position:= 0;
					end
				else
					begin
					h.compType:= 0;

					mts:= mos[i];
					end;

				h.size:= 1 + mts.Size;
				AStream.Write(h, SizeOf(TXSIDTrackRec));
				AStream.CopyFrom(mts, mts.Size);

				if  CheckBox1.Checked then
					mts.Free;
				end;
			end;

		finally
		mos[3].Free;
		mos[2].Free;
		mos[1].Free;
		mos[0].Free;
		end;
	end;

procedure TForm1.DoWriteHeader(AStream: TStream);
	var
	h: TXSIDHeaderRec;

	begin
	h.tag:= 'XSHD';
	h.size:= 5;
	h.version:= 1;
	h.format:= ComboBox1.ItemIndex;
	h.sidCnt:= 1;
	h.system:= ComboBox2.ItemIndex + 1;
	h.updateRate:= ComboBox4.ItemIndex;

	AStream.Write(h, SizeOf(TXSIDHeaderRec));
	end;

procedure TForm1.DoWriteMetaData(AStream: TStream);
	var
	h: TXSIDMetaDataRec;
	d: AnsiString;

	begin
	h.tag:= 'XSMD';

//FIXME Should actually convert it to UTF8.
	d:= AnsiString(Memo2.Lines.Text);

	h.size:= Length(d);

	AStream.Write(h, SizeOf(TXSIDMetaDataRec));
	if  Length(d) > 0 then
		AStream.Write(d[1], Length(d));
	end;

procedure TForm1.DoWriteSIDDesc(AStream: TStream);
	var
	h: TXSIDSIDDescRec;
	d: AnsiString;

	begin
	h.tag:= 'XSSD';
	h.sid:= 1;
	h.sidType:= ComboBox3.ItemIndex;

//FIXME Should actually convert it to UTF8.
	d:= AnsiString(Memo1.Lines.Text);

	h.size:= 2 + Length(d);

	AStream.Write(h, SizeOf(TXSIDSIDDescRec));
	if  Length(d) > 0 then
		AStream.Write(d[1], Length(d));
	end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
	begin
	if OpenDialog1.Execute then
		Edit1.Text:= OpenDialog1.FileName;
	end;

end.
