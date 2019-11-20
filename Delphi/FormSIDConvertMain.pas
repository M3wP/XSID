unit FormSIDConvertMain;

interface

uses
	Winapi.Windows, Winapi.Messages, Winapi.ActiveX, System.SysUtils,
	System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Vcl.StdCtrls, VirtualTrees, Vcl.AppEvnts, SIDConvTypes, Vcl.ExtCtrls,
	Vcl.Mask;

type
	TSIDConvertMainForm = class(TForm)
		VirtualStringTree1: TVirtualStringTree;
		VirtualStringTree2: TVirtualStringTree;
		Label4: TLabel;
		Label3: TLabel;
		Label2: TLabel;
		ComboBox1: TComboBox;
		ComboBox2: TComboBox;
		ComboBox3: TComboBox;
		Label1: TLabel;
		CheckBox6: TCheckBox;
		Label5: TLabel;
		Label6: TLabel;
		Memo1: TMemo;
		Label7: TLabel;
		Memo2: TMemo;
		Button2: TButton;
		Button1: TButton;
		Label8: TLabel;
		ComboBox4: TComboBox;
		Button3: TButton;
		Button4: TButton;
		Label9: TLabel;
		Timer1: TTimer;
		Button5: TButton;
		Button6: TButton;
		Button7: TButton;
		Label10: TLabel;
		MaskEdit1: TMaskEdit;
		Button8: TButton;
		Label11: TLabel;
		ComboBox5: TComboBox;
		procedure FormCreate(Sender: TObject);
		procedure VirtualStringTree1DragOver(Sender: TBaseVirtualTree; Source: TObject;
				Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
				var Effect: Integer; var Accept: Boolean);
		procedure VirtualStringTree1DragDrop(Sender: TBaseVirtualTree; Source: TObject;
				DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
				Pt: TPoint; var Effect: Integer; Mode: TDropMode);
		procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
				Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
		procedure VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
				Node: PVirtualNode; Column: TColumnIndex);
		procedure VirtualStringTree2InitNode(Sender: TBaseVirtualTree; ParentNode,
				Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
		procedure VirtualStringTree2GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
				Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
		procedure Button2Click(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure VirtualStringTree2FocusChanged(Sender: TBaseVirtualTree;
				Node: PVirtualNode; Column: TColumnIndex);
		procedure VirtualStringTree2FocusChanging(Sender: TBaseVirtualTree; OldNode,
				NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
				var Allowed: Boolean);
		procedure VirtualStringTree2Checking(Sender: TBaseVirtualTree;
				Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
		procedure Button1Click(Sender: TObject);
		procedure ComboBox4Change(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure Button4Click(Sender: TObject);
		procedure ComboBox3Change(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
		procedure Button5Click(Sender: TObject);
		procedure Button6Click(Sender: TObject);
		procedure Button7Click(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure MaskEdit1KeyPress(Sender: TObject; var Key: Char);
		procedure Button8Click(Sender: TObject);
	private
		FSongLengths: TSIDPlayLengths;
		FAppendFiles: TStringList;
		FProcessFiles: TStringList;
		FFocusedData: PNodeData;
		FFocusedSubSong: Integer;
		FConfig: TSIDConvConfig;

		procedure AppendDropFiles(Sender: TVirtualStringTree;
				DataObject: IDataObject; Formats: TFormatArray; Effect: Integer;
				Mode: TVTNodeAttachMode);
		procedure ProcessAppendFiles;
		procedure ReadFocusedNode;

		procedure LoadSongLengths;

	protected
		FOldOnIdle: TIdleEvent;
		procedure DoOnIdle(ASender: TObject; var ADone: Boolean);

	public
		{ Public declarations }
	end;

var
	SIDConvertMainForm: TSIDConvertMainForm;

implementation

uses
	Winapi.ShlObj, IOUtils, Types, UITypes, FormSIDConvertConfig, FormSIDConvProgress,
	SIDPlay;

{$R *.dfm}

procedure TSIDConvertMainForm.AppendDropFiles(Sender: TVirtualStringTree;
		DataObject: IDataObject; Formats: TFormatArray; Effect: Integer;
		Mode: TVTNodeAttachMode);
	var
	i: Integer;
	FormatEtc: TFormatEtc;
	Medium: TStgMedium;
	OLEData: PDropFiles;
	Head, Tail: PWideChar;
//	TargetNode,
//	Node: PVirtualNode;
//	Data: PNodeData;
	fileName,
	ext: string;

	begin
	if  Mode <> amNowhere then
		for i:= 0 to High(Formats) do
			case Formats[I] of
				CF_HDROP:
					begin
//					fill the structure used to get the Unicode string
					with FormatEtc do
						begin
						cfFormat := CF_HDROP;
// 						no specific target device
						ptd := nil;
//						normal content to render
						dwAspect := DVASPECT_CONTENT;
//						no specific page of multipage data
						lindex := -1;
//						pass the data via memory
						tymed := TYMED_HGLOBAL;
						end;

//					Check if we can get the Unicode text data.
					if  DataObject.QueryGetData(FormatEtc) = S_OK then
						begin
//						Data is accessible so finally get a pointer to it
						if  DataObject.GetData(FormatEtc, Medium) = S_OK then
							begin
							OLEData:= GlobalLock(Medium.hGlobal);
							if  Assigned(OLEData) then
								begin
								Sender.BeginUpdate;
//								TargetNode:= Sender.DropTargetNode;
//								if  TargetNode = nil then
//									TargetNode:= Sender.FocusedNode;

								Head:= PWideChar(PByte(OLEData) + OLEData.pFiles);
								try
									while Head^ <> #0 do
										begin
										Tail := Head;
//                                         (Tail^ in [WideChar(#0), WideChar(#13), WideChar(#10), WideChar(#9)]) do
										while not CharInSet(Tail^, [#0, #9, #10, #13]) do
											Inc(Tail);
										if  Head <> Tail then
											begin
//											add a new node if we got a non-empty caption
//											Node:= Sender.InsertNode(TargetNode, Mode);

											SetString(fileName, Head, Tail - Head);
											ext:= TPath.GetExtension(fileName);

											if  (CompareText('.SID', ext) = 0)
											or  (Length(ext) = 0) then
												FAppendFiles.Add(fileName);
											end;
//										Skip any tab, new line, null.
										if  CharInSet(Tail^, [#0, #9, #10, #13]) then
											Inc(Tail);

										Head := Tail;
										end;
									finally
									GlobalUnlock(Medium.hGlobal);
									Sender.EndUpdate;
									end;
								end;
//							never forget to free the storage medium
							ReleaseStgMedium(Medium);
							end;
						end;

					Break;
					end;
				end;

//	ProcessAppendFiles;
	end;

procedure TSIDConvertMainForm.Button1Click(Sender: TObject);
	begin
	if  SIDConvertConfigForm.ShowConfig(@FConfig) = mrOk then
		FConfig.SaveToIniFile(ChangeFileExt(Application.ExeName, '.ini'));

	Button2.Enabled:= Length(FConfig.viceVSID) > 0;
	end;

procedure TSIDConvertMainForm.Button2Click(Sender: TObject);
	var
	cmd: string;
	sti: TStartupInfo;
	pri: TProcessInformation;
	ss: Integer;


	begin
	FillChar(sti, SizeOf(TStartupInfo), 0);
	FillChar(pri, SizeOf(TProcessInformation), 0);

	sti.cb:= SizeOf(TStartupInfo);

	if  Assigned(VirtualStringTree2.FocusedNode) then
		ss:= VirtualStringTree2.FocusedNode^.Index + 1
	else
		ss:= 1;

	cmd:= FConfig.viceVSID + ' -tune ' + IntToStr(ss) + ' ' +
			FProcessFiles[FFocusedData^.fileIndex];

	CreateProcess(nil, PWideChar(cmd), nil, nil, True, NORMAL_PRIORITY_CLASS, nil,
			nil, sti, pri);
	end;

procedure TSIDConvertMainForm.Button3Click(Sender: TObject);
	var
	i,
	cnt,
	spr,
	req,
	max: Integer;
	h,
	m,
	s,
	ms: Word;
	tf: Double;
	ti: Cardinal;
	n,
	f: string;
	node: PVirtualNode;
	data: PNodeData;
	fmt: TSIDConvCompFmt;
	typ: TSIDConvCompType;


(*
 * Load ROM dump from file.
 * Allocate the buffer if file exists, otherwise return 0.
 *)
	function DoLoadRom(path: string; romSize: Cardinal): TMemoryStream;
		begin
		Result:= TMemoryStream.Create;
		Result.LoadFromFile(path);

//		Result.SetSize(romSize);
		end;

	procedure DoDumpFile(ANode: PNodeData; ASong: Integer; ADumpFile: string;
			ADuration: Cardinal);
		var
		play,
		dump,
		tune,
		conf: Pointer;
		kr,
		br,
		cr: TMemoryStream;
		buf: array[0..15] of SmallInt;
		i: Cardinal;

		begin
		play:= PlayerCreate;

//		Load ROM files
		kr:= DoLoadRom('kernal', 8192);
		br:= DoLoadRom('basic', 8192);
		cr:= DoLoadRom('chargen', 4096);

		PlayerSetROMS(play, PByte(kr.Memory), PByte(br.Memory), PByte(cr.Memory));

		kr.Free;
		br.Free;
		cr.Free;

		dump:= DumpSIDCreate(PAnsiChar('ConvertDump'), PAnsiChar(AnsiString(ADumpFile)));

//		maxsids:= PlayerGetInfoMaxSIDs(play);
		DumpSIDCreateSIDs(dump, {maxsids}1);

		if  not DumpSIDGetStatus(dump) then
			raise Exception.Create(string(DumpSIDGetError(dump)));

		tune:= SIDTuneCreate(PAnsiChar(AnsiString(FProcessFiles[ANode^.fileIndex])));

		if  not SIDTuneGetStatus(tune) then
			raise Exception.Create('Tune Create Failed');

		SIDTuneSelectSong(tune, ASong);

		conf:= SIDConfigCreate;
		SIDConfigSetFrequency(conf, 48000);
		SIDConfigSetSamplingMethod(conf, 0);
		SIDConfigSetFastSampling(conf, False);
		SIDConfigSetPlayback(conf, 1);
		SIDConfigSetSIDEmulation(conf, dump);

		if  not PlayerSetConfig(play, conf) then
			raise Exception.Create(string(PlayerGetError(play)));

		if  not PlayerLoadTune(play, tune) then
			raise Exception.Create(string(PlayerGetError(play)));

		SIDConvProgressForm.ProgressBar3.Position:= 0;
		SIDConvProgressForm.ProgressBar3.Max:= ADuration;

		i:= 0;
		while i < ADuration do
			begin
			PlayerPlay(play, @buf[0], 0);
			i:= PlayerGetTime(play);

			SIDConvProgressForm.ProgressBar3.Position:= i;
			Application.ProcessMessages;
			end;

		PlayerDestroy(play);
		SIDConfigDestroy(conf);
		SIDTuneDestroy(tune);
		DumpSIDDestroy(dump);
		end;

	function StripChars(const ACharsToStrip, ASrc: string): string;
		var
		c: Char;

		begin
		Result:= aSrc;
		for c in aCharsToStrip do
			Result:= StringReplace(Result, c, '_', [rfReplaceAll, rfIgnoreCase]);
		end;

	begin
	Button3.Enabled:= False;
	Enabled:= False;
	SIDConvProgressForm:= TSIDConvProgressForm.Create(Self);
	try
		SIDConvProgressForm.PopupParent:= Self;
		SIDConvProgressForm.ProgressBar1.Max:= VirtualStringTree1.RootNodeCount;
		SIDConvProgressForm.Show;

		fmt:= TSIDConvCompFmt(ComboBox1.ItemIndex);
		typ:= TSIDConvCompType(ComboBox5.ItemIndex);

		if  fmt in [scfFormat0, scfFormat1] then
			req:= 1
		else if  fmt = scfDetermine then
			req:= 2
		else
			req:= 1;

		max:= CPUCount - 2;
		if  max < 1 then
			max:= req;

		node:= VirtualStringTree1.GetFirst;
		repeat
			data:= PNodeData(VirtualStringTree1.GetNodeData(node));

			SIDConvProgressForm.ProgressBar1.Position:= node^.Index;
			SIDConvProgressForm.ProgressBar2.Position:= 0;
			SIDConvProgressForm.ProgressBar2.Max:= data^.header.songs;
			SIDConvProgressForm.Label3.Caption:= FProcessFiles[data^.fileIndex];

			for i:= 0 to data^.header.songs - 1 do
				begin
				SIDConvProgressForm.Label4.Visible:= False;
				SIDConvProgressForm.ProgressBar2.Position:= i + 1;
				Application.ProcessMessages;

				if  i in data^.selected then
					begin
					DecodeTime(data^.lengths[i], h, m, s, ms);
					tf:= h * 3600 + m * 60 + s + ms / 1000;

					DecodeTime(FConfig.startDelay, h, m, s, ms);
					tf:= tf + h * 3600 + m * 60 + s + ms / 1000;

					ti:= Round(tf);

					n:= StripChars('?/\*&:<>', string(data^.header.author));
					if  n = '' then
						n:= 'Unknown';
					f:= TPath.Combine(FConfig.outputPath, n);

					n:= StripChars('?/\*&:<>', string(data^.header.name));
					if  n = '' then
						n:= 'Unknown';
					f:= TPath.Combine(f, n);

					ForceDirectories(f);

					f:= TPath.Combine(f, Format('%2.2d - ', [i + 1]) +
							TPath.GetFileName(FProcessFiles[data^.fileIndex]));
					f:= TPath.ChangeExtension(f, 'log');

					DoDumpFile(data, i + 1, f, ti);

					if  fmt <> scfDumpOnly then
						begin
						spr:= 0;

						while spr < req do
							begin
							ConvCountLock.BeginRead;
							try
								cnt:= ConvCount;

								finally
								ConvCountLock.EndRead;
								end;

							spr:= max - cnt;
							if  spr >= req then
								Break;

							SIDConvProgressForm.Label4.Visible:= True;
							Application.ProcessMessages;
							Sleep(100);
							end;

						TSIDConvCompCntrl.Create(data, i, fmt, typ, f);
						end;
					end;
				end;

			node:= VirtualStringTree1.GetNext(node);
			until not Assigned(node);

		SIDConvProgressForm.ProgressBar1.Position:= VirtualStringTree1.RootNodeCount;
		Application.ProcessMessages;

		finally
		SIDConvProgressForm.Release;
		Enabled:= True;
		Timer1.Enabled:= True;
		end;
	end;

procedure TSIDConvertMainForm.Button4Click(Sender: TObject);
	var
	v: Word;

	begin
	if  FFocusedData^.header.version >= 2 then
		begin
		v:= (FFocusedData^.header.flags and $0C) shr 2;
		ComboBox2.ItemIndex:= v;

		v:= (FFocusedData^.header.flags and $30) shr 4;
		if  v = 3 then
			FFocusedData^.sidType:= 0
		else
			FFocusedData^.sidType:= v;
		end
	else
		begin
		ComboBox2.ItemIndex:= 0;
		FFocusedData^.sidType:= 0;
		end;

	ComboBox3.ItemIndex:= FFocusedData^.sidType;
	end;

procedure TSIDConvertMainForm.Button5Click(Sender: TObject);
	var
	i: TSIDPlaySubSong;
	n: PVirtualNode;

	begin
	for i:= Low(TSIDPlaySubSong) to High(TSIDPlaySubSong) do
		Include(FFocusedData^.selected, i);

	n:= VirtualStringTree2.GetFirst;
	while  Assigned(n) do
		begin
		VirtualStringTree2.InvalidateNode(n);
		n:= VirtualStringTree2.GetNext(n);
		end;
	end;

procedure TSIDConvertMainForm.Button6Click(Sender: TObject);
	var
	i: TSIDPlaySubSong;
	n: PVirtualNode;

	begin
	for i:= Low(TSIDPlaySubSong) to High(TSIDPlaySubSong) do
		Exclude(FFocusedData^.selected, i);

	if  FFocusedData^.header.startSong > 0 then
		Include(FFocusedData^.selected, FFocusedData^.header.startSong - 1);

	n:= VirtualStringTree2.GetFirst;
	while  Assigned(n) do
		begin
		VirtualStringTree2.InvalidateNode(n);
		n:= VirtualStringTree2.GetNext(n);
		end;
	end;

procedure TSIDConvertMainForm.Button7Click(Sender: TObject);
	begin
	FFocusedSubSong:= -1;
	FFocusedData:= nil;

	VirtualStringTree2.Clear;
	Memo1.Clear;
	Memo2.Clear;

	VirtualStringTree1.Clear;
	FProcessFiles.Clear;
	end;

procedure TSIDConvertMainForm.Button8Click(Sender: TObject);
	var
	k: Char;

	begin
	if  Assigned(FFocusedData)
	and (FFocusedSubSong > -1) then
		if  Assigned(FFocusedData^.details)
		and (FFocusedData^.details.Count > FFocusedSubSong) then
			begin
			MaskEdit1.Text:= FormatDateTime('nn:ss',
					FFocusedData^.details[FFocusedSubSong].time);
			k:= #13;
			MaskEdit1KeyPress(Sender, k);
			end;
	end;

procedure TSIDConvertMainForm.ComboBox3Change(Sender: TObject);
	begin
	FFocusedData^.sidType:= ComboBox3.ItemIndex;
	end;

procedure TSIDConvertMainForm.ComboBox4Change(Sender: TObject);
	begin
	FFocusedData^.updateRate:= ComboBox4.ItemIndex;
	end;

procedure TSIDConvertMainForm.DoOnIdle(ASender: TObject; var ADone: Boolean);
	begin
	if  FAppendFiles.Count > 0 then
		ProcessAppendFiles;

	if  Assigned(FOldOnIdle) then
		FOldOnIdle(ASender, ADone)
	else
		ADone:= True;
	end;

procedure TSIDConvertMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
	var
	cnt: Integer;

	begin
	ConvCountLock.BeginRead;
	try
		cnt:= ConvCount;

		finally
		ConvCountLock.EndRead;
		end;

	if  cnt > 0 then
		if  MessageDlg('Conversion tasks are still in progress.  Closing the ' +
				'application now will result in a loss of data.'#13#10#13#10 +
				'Are you sure you wish to close the application?', mtWarning,
				[mbYes, mbNo], -1, mbNo) = mrNo then
			CanClose:= False;
	end;

procedure TSIDConvertMainForm.FormCreate(Sender: TObject);
	begin
	FAppendFiles:= TStringList.Create;
	FProcessFiles:= TStringList.Create;

	FSongLengths:= TSIDPlayLengths.Create;
	VirtualStringTree1.NodeDataSize:= SizeOf(TNodeData);

	FConfig.LoadFromIniFile(ChangeFileExt(Application.ExeName, '.ini'));

	FOldOnIdle:= Application.OnIdle;
    Application.OnIdle:= DoOnIdle;
	end;

procedure TSIDConvertMainForm.FormShow(Sender: TObject);
	var
	req: Boolean;

	begin
	req:= (FConfig.songLengths = '') or {(FConfig.viceVSID = '') or}
			(FConfig.outputPath = '');

	if  req then
		begin
		if  SIDConvertConfigForm.ShowConfig(@FConfig, req) = mrAbort then
			begin
			Application.Terminate;
			Exit;
			end;

		FConfig.SaveToIniFile(ChangeFileExt(Application.ExeName, '.ini'));
		end;

	Button2.Enabled:= Length(FConfig.viceVSID) > 0;

	LoadSongLengths;

	if  not FileExists('basic')
	or  not FileExists('chargen')
	or  not FileExists('kernal') then
		Button3.Enabled:= False;
	end;

procedure TSIDConvertMainForm.LoadSongLengths;
	var
	i: Integer;
	f: TextFile;
	sl: TStringList;
	dl: TStringList;
	md5: TSIDPlayMD5;
	det: TSIDPlayDetails;
	s: AnsiString;

	procedure ParseDetailValues(AList: TStringList; out ADetails: TSIDPlayDetails);
		var
		i,
		p: Integer;
		s: string;
		t: Char;
		d: PSIDPlayDetailRec;
		dt: TDateTime;

		begin
		ADetails:= TSIDPlayDetails.Create;
		for i:= 0 to AList.Count - 1 do
			begin
			New(d);

			p:= Pos('-', AList[i]);
			if  p > 0 then
				begin
				d^.time:= EncodeTime(0, 3, 0, 0);
				d^.endType:= speLoop;
				d^.lenType:= splDefault;
				end
			else
				begin
				p:= Pos('(', AList[i]);
				if  p > 0 then
					begin
					s:= '0:' + Copy(AList[i], 1, p - 1);
					t:= AList[i][p + 1];
					end
				else
					begin
					s:= '0:' + AList[i];
					t:= 'L';
					end;

				if  not TryStrToTime(s, dt) then
					begin
					d^.time:= EncodeTime(0, 3, 0, 0);
					d^.lenType:= splDefault;
					end
				else
					begin
                    d^.time:= dt;
					d^.lenType:= splClosestSeconds;
					end;

				case t of
					'G':
						begin
						d^.endType:= speOverlap;
						d^.lenType:= splEstimated;
						end;
					'B':
						begin
						d^.endType:= speLoop;
						d^.lenType:= splEstimated;
						end;
					'M':
						begin
						d^.endType:= speFadeOut;
						d^.lenType:= splClosestSeconds;
						end;
					'Z':
						begin
						d^.endType:= speFadeOut;
						d^.lenType:= splEstimated;
						end;
					else
						d^.endType:= speLoop;
					end;
				end;

			ADetails.Add(d);
			end;
		end;

	begin
	sl:= TStringList.Create;
	dl:= TStringList.Create;
	try
		dl.Delimiter:= ' ';

		FileMode:= fmOpenRead;
		AssignFile(f, FConfig.songLengths);
		try
			Reset(f);

			while not Eof(f) do
				begin
				Readln(f, s);
				if  Length(s) > 0 then
					if  not (s[1] in [';', '[']) then
						sl.Add(string(s));
				end;

			finally
			CloseFile(f);
			end;

		for i:= 0 to sl.Count - 1 do
			begin
			md5:= SIDPlayStringToMD5(AnsiString(sl.Names[i]));
			dl.DelimitedText:= sl.ValueFromIndex[i];
			ParseDetailValues(dl, det);

			FSongLengths.Add(md5, det);
			end;

		finally
		sl.Free;
		dl.Free;
		end;
	end;

procedure TSIDConvertMainForm.MaskEdit1KeyPress(Sender: TObject; var Key: Char);
	var
	s: string;
	n: PVirtualNode;

	begin
	if  Key = #13 then
		begin
		if  Assigned(FFocusedData)
		and (FFocusedSubSong > -1) then
			begin
			s:= '00:' + StringReplace(MaskEdit1.Text, ' ', '0', [rfReplaceAll]);
			FFocusedData^.lengths[FFocusedSubSong]:= StrToDateTime(s);

			n:= VirtualStringTree2.GetFirst;
			while Assigned(n) do
				begin
				if  VirtualStringTree2.Selected[n]
				or  (n^.Index = Cardinal(FFocusedSubSong)) then
					VirtualStringTree2.InvalidateNode(n);

				n:= VirtualStringTree2.GetNext(n);
				end;
			end;

		Key:= #0;
		end;
	end;

procedure TSIDConvertMainForm.ProcessAppendFiles;
	var
	i: Integer;

	function  ReadWordBE(AStream: TStream): Word; inline;
		var
		b1,
		b2: Byte;

		begin
		AStream.Read(b1, 1);
		AStream.Read(b2, 1);
		Result:= (b1 shl 8) or b2;
		end;

	function  ReadCardinalBE(AStream: TStream): Cardinal; inline;
		var
		b1,
		b2,
		b3,
		b4: Word;

		begin
		AStream.Read(b1, 1);
		AStream.Read(b2, 1);
		AStream.Read(b3, 1);
		AStream.Read(b4, 1);
		Result:= (b1 shl 24) or (b2 shl 16) or (b3 shl 8) or b4;
		end;

	procedure DoProcessFile(const AFile: string);
		const
		NL: AnsiString = #13#10;

		var
		f: TFileStream;
		idx: Integer;
		node: PVirtualNode;
		data: PNodeData;
		s1,
		s2: AnsiString;
		j: Integer;
		v: Word;
		t: TTime;
		i: Integer;

		begin
		idx:= FProcessFiles.IndexOf(AFile);
		if  idx = -1 then
			begin
			idx:= FProcessFiles.Add(AFile);

			node:= VirtualStringTree1.InsertNode(nil, amAddChildLast);
			data:= VirtualStringTree1.GetNodeData(node);

			data^.fileIndex:= idx;

			f:= TFileStream.Create(AFile, fmOpenRead);
			try
				f.Read(data^.header.tag, 4);
				data^.header.version:= ReadWordBE(f);
				data^.header.dataOffset:= ReadWordBE(f);
				data^.header.loadAddress:= ReadWordBE(f);
				data^.header.initAddress:= ReadWordBE(f);
				data^.header.playAddress:= ReadWordBE(f);
				data^.header.songs:= ReadWordBE(f);
				data^.header.startSong:= ReadWordBE(f);
				data^.header.speedFlags:= ReadCardinalBE(f);

				data^.updateRate:= 4;

				f.Read(data^.header.name, 32);
				f.Read(data^.header.author, 32);
				f.Read(data^.header.released, 32);

				if  data^.header.version >= 2 then
					data^.header.flags:= ReadWordBE(f)
				else
					data^.header.flags:= 0;

				f.Seek(data^.header.dataOffset + 2, soFromBeginning);
				SIDPlayComputeStreamMD5(f, data^.header, data^.md5);

				finally
				f.Free;
				end;

			if  data^.header.version >= 2 then
				begin
				v:= (data^.header.flags and $30) shr 4;
				if  v = 3 then
					data^.sidType:= 0
				else
					data^.sidType:= v;
				end
			else
				data^.sidType:= 0;

			data^.caption:= string(data^.header.author) + ' - ' +
					string(data^.header.name);
			if  data^.header.startSong > 0 then
				Include(data^.selected, data^.header.startSong - 1);

			if  not FSongLengths.TryGetValue(data^.md5, data^.details) then
				data^.details:= nil;

			SetLength(data^.lengths, data^.header.songs);
			t:= EncodeTime(0, 3, 0, 0);
			for i:= 0 to data^.header.songs - 1 do
				begin
				if  Assigned(data^.details)
				and (data^.details.Count > i) then
					data^.lengths[i]:= data^.details[i].time
				else
					data^.lengths[i]:= t;
				end;

			SetLength(data^.sidParams, data^.header.songs);
			SetLength(data^.metaData, data^.header.songs);

			s1:= data^.header.name + NL + data^.header.author + NL +
					data^.header.name + NL;
			s2:= Copy(data^.header.released, 1, 4);
			if  not TryStrToInt(string(s2), j) then
				s2:= '';
			s2:= s2 + NL + 'copyright=' + data^.header.released;

			for j:= 0 to data^.header.songs - 1 do
				data^.metaData[j]:= string(s1) + Format('%2.2d', [j + 1]) + string(NL) +
						string(s2);

			VirtualStringTree1.InvalidateNode(node);
			end;
		end;

	procedure DoProcessDirectory(const APath: string);
		var
		f: string;
		sda: TStringDynArray;

		begin
		if  TDirectory.Exists(APath) then
			begin
			sda:= TDirectory.GetFiles(APath, '*.SID');
			for f in sda do
				DoProcessFile(f);

			sda:= TDirectory.GetDirectories(APath);
			for f in sda do
				DoProcessDirectory(f);
			end;
		end;

	begin
	for i:= 0 to FAppendFiles.Count - 1 do
		if  Length(TPath.GetExtension(FAppendFiles[i])) = 0 then
			DoProcessDirectory(FAppendFiles[i])
		else
			DoProcessFile(FAppendFiles[i]);

	FAppendFiles.Clear;
	VirtualStringTree1.Invalidate;
	end;

procedure TSIDConvertMainForm.ReadFocusedNode;
	var
	v: Word;

	begin
	if  FFocusedData^.header.version >= 2 then
		begin
		v:= (FFocusedData^.header.flags and $0C) shr 2;
		ComboBox2.ItemIndex:= v;
//
//		v:= (FFocusedData^.header.flags and $30) shr 4;
//		if  v = 3 then
//			ComboBox3.ItemIndex:= 0
//		else
//			ComboBox3.ItemIndex:= v;
		end
	else
		begin
		ComboBox2.ItemIndex:= 0;
//		ComboBox3.ItemIndex:= 0;
		end;

	ComboBox3.ItemIndex:= FFocusedData^.sidType;

	ComboBox4.ItemIndex:= FFocusedData^.updateRate;

	VirtualStringTree2.Clear;
	VirtualStringTree2.RootNodeCount:= FFocusedData^.header.songs;
	end;

procedure TSIDConvertMainForm.Timer1Timer(Sender: TObject);
	const
	ARR_LIT_TOK_PROGRESS: array[0..5] of string = (
			'   ', '.  ', '.. ', '...', ' ..', '  .');
	var
	cnt: Integer;

	begin
	ConvCountLock.BeginRead;
	try
		cnt:= ConvCount;

		finally
		ConvCountLock.EndRead;
		end;

	if  cnt > 0 then
		begin
		Label9.Tag:= Label9.Tag + 1;
		if  Label9.Tag > High(ARR_LIT_TOK_PROGRESS) then
			Label9.Tag:= 0;
		end
	else
		begin
		Label9.Tag:= 0;
		if  Enabled then
			begin
			Button3.Enabled:= True;
            Timer1.Enabled:= False;
			end;
		end;

	Label9.Caption:= ARR_LIT_TOK_PROGRESS[Label9.Tag];
	end;

procedure TSIDConvertMainForm.VirtualStringTree1DragDrop(Sender: TBaseVirtualTree;
		Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
		Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
	var
	am: TVTNodeAttachMode;

	begin
	if  Assigned(DataObject) then
		begin
		Effect:= DROPEFFECT_COPY;

		case Mode of
			dmAbove:
				am:= amInsertBefore;
			dmOnNode, dmBelow:
				am:= amInsertAfter;
			else
				am:= amAddChildLast;
			end;

		AppendDropFiles(Sender as TVirtualStringTree, DataObject, Formats, Effect,
			am);
		end
	else
		Effect:= DROPEFFECT_NONE;
	end;

procedure TSIDConvertMainForm.VirtualStringTree1DragOver(Sender: TBaseVirtualTree;
		Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
		Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
	begin
	Effect:= DROPEFFECT_COPY;
	Accept:= True;
	end;

procedure TSIDConvertMainForm.VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex);
	begin
	FFocusedData:= Sender.GetNodeData(Node);
	ReadFocusedNode;

	VirtualStringTree2.FocusedNode:= VirtualStringTree2.GetFirst;
	end;

procedure TSIDConvertMainForm.VirtualStringTree1GetText(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
		var CellText: string);
	var
	Data: PNodeData;

	begin
	Data:= Sender.GetNodeData(Node);

	if  Length(Data^.caption) = 0 then
		CellText:= FProcessFiles[Data^.fileIndex]
	else
		CellText:= Data^.caption;
	end;

procedure TSIDConvertMainForm.VirtualStringTree2Checking(Sender: TBaseVirtualTree;
		Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
	begin
	if  NewState = csUncheckedNormal then
		Exclude(FFocusedData^.selected, Node^.Index)
	else if NewState = csCheckedNormal then
		Include(FFocusedData^.selected, Node^.Index);
	end;

procedure TSIDConvertMainForm.VirtualStringTree2FocusChanged(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex);
	begin
	if  Assigned(Node) then
		begin
		FFocusedSubSong:= Node^.Index;
		Memo1.Lines.Text:= FFocusedData^.sidParams[Node^.Index];
		Memo2.Lines.Text:= FFocusedData^.metaData[Node^.Index];

		MaskEdit1.Text:= FormatDateTime('nn:ss', FFocusedData^.lengths[Node^.Index]);
		end
	else
		FFocusedSubSong:= -1;
	end;

procedure TSIDConvertMainForm.VirtualStringTree2FocusChanging(Sender: TBaseVirtualTree;
		OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
		var Allowed: Boolean);
	begin
	if  Assigned(OldNode) then
		begin
		FFocusedData^.sidParams[OldNode^.Index]:= Memo1.Lines.Text;
		FFocusedData^.metaData[OldNode^.Index]:= Memo2.Lines.Text;
		end;
	end;

procedure TSIDConvertMainForm.VirtualStringTree2GetText(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
		var CellText: string);
	begin
	CellText:= IntToStr(Node^.Index + 1) + ' - ';

//	if  Assigned(FFocusedData^.details)
//	and (Integer(Node^.Index) < FFocusedData^.details.Count) then
//		CellText:= CellText + FormatDateTime('nn:ss',
//				FFocusedData^.details[Node^.Index].time)
		CellText:= CellText + FormatDateTime('nn:ss',
				FFocusedData^.lengths[Node^.Index]);
//	else
//		CellText:= CellText + '03:00';

	if  Node^.Index in FFocusedData^.selected then
		Node^.CheckState:= csCheckedNormal
	else
		Node^.CheckState:= csUncheckedNormal;
	end;

procedure TSIDConvertMainForm.VirtualStringTree2InitNode(Sender: TBaseVirtualTree;
		ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
	begin
	Node^.CheckType:= ctCheckBox;

	if  Node^.Index in FFocusedData^.selected then
		Node^.CheckState:= csCheckedNormal
	else
		Node^.CheckState:= csUncheckedNormal;
	end;


end.
