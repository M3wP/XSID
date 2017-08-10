unit FormXSIDToMIDIMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	System.ImageList, Vcl.ImgList, Vcl.StdCtrls, Vcl.ExtCtrls, VirtualTrees,
	XSIDFiles, XSIDTypes, XSIDThread, XSIDToMIDITypes, System.Win.TaskbarCore,
	Vcl.Taskbar, Vcl.Samples.Spin;

const
	UM_DUMPEND = WM_USER + $0B00;
	UM_DUMPNEXT = WM_USER + $0B01;


type
	TXSIDToMIDIMainForm = class(TForm)
		vstInstruments: TVirtualStringTree;
		Panel1: TPanel;
		ButtonedEdit1: TButtonedEdit;
		Label1: TLabel;
		ImageList1: TImageList;
		OpenDialog1: TOpenDialog;
		Panel2: TPanel;
		Button2: TButton;
		Button3: TButton;
		Label2: TLabel;
		Label3: TLabel;
		Button4: TButton;
		Button5: TButton;
		Button6: TButton;
		CheckBox1: TCheckBox;
		CheckBox2: TCheckBox;
		Button7: TButton;
		Label4: TLabel;
		Edit1: TEdit;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		Label10: TLabel;
		Label11: TLabel;
		Label12: TLabel;
		Label13: TLabel;
		Label14: TLabel;
		Label15: TLabel;
		Button1: TButton;
		Edit2: TEdit;
		Edit3: TEdit;
		Label16: TLabel;
		Label17: TLabel;
		Edit4: TEdit;
		Label18: TLabel;
		Label19: TLabel;
		ComboBox1: TComboBox;
		Button8: TButton;
		Button9: TButton;
		Button10: TButton;
		Button11: TButton;
		SaveDialog1: TSaveDialog;
		OpenDialog2: TOpenDialog;
		ButtonedEdit2: TButtonedEdit;
		Label20: TLabel;
		FileOpenDialog1: TFileOpenDialog;
		Taskbar1: TTaskbar;
		Label21: TLabel;
		SpinEdit1: TSpinEdit;
		procedure ButtonedEdit1RightButtonClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure vstInstrumentsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
				Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
		procedure Button2Click(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure Button5Click(Sender: TObject);
		procedure Button4Click(Sender: TObject);
		procedure Button6Click(Sender: TObject);
		procedure Button7Click(Sender: TObject);
		procedure Button1Click(Sender: TObject);
		procedure Button8Click(Sender: TObject);
		procedure Button9Click(Sender: TObject);
		procedure Button10Click(Sender: TObject);
		procedure Button11Click(Sender: TObject);
		procedure ButtonedEdit2RightButtonClick(Sender: TObject);
		procedure vstInstrumentsDblClick(Sender: TObject);

	private type
		TDumpIndex = 0..128;
		TDumpIndexes = set of TDumpIndex;
		TDumpData = record
			ID: Integer;
			DumpIndex: TDumpIndex;
			ProgIndex: Integer;
			XSIDThread: TXSIDThread;
			XSIDEvents: TXSIDEventManager;
			XSIDConfig: TXSIDConfig;
			Size: Cardinal;
			Ticks: Cardinal;
		end;

	private
		FXSIDConfig: TXSIDFileConfig;
		FDumpConfig: TXSIDConfig;
		FEventsList: TList;
		FSongSize: Cardinal;
		FInstruments: TSIDInstrumentMap;
		FMIDIMapping: TMIDIInsMap;
		FSongRecompose: array of TSIDNoteModulationMap;
		FSongFiltMix: TSIDFiltMixMap;

		FDumpCount: Integer;
		FDumpIndexes: TDumpIndexes;
		FDumpSlots: Integer;
		FDumpAvail: TDumpIndexes;
		FDumpData: array of TDumpData;

		FDumpProc: Boolean;
		FDumpAbort: Boolean;
		FDumpFiltIns: Boolean;

		FBPM: Cardinal;
		FPPQN: Word;
		FMIDIResidual: Extended;

		procedure DoLoadFile(const AFileName: string);
		procedure DoClearData;
		procedure DoInitialiseProject;
		procedure DoAnalyseInstruments;
		procedure DoPrepareMIDIMapping;
		procedure DoDisplayInstruments;
		procedure DoDumpFile(const AEvents: TList; const AFileName: string);
		function  DoDumpInsEvents(const AIns: Integer; const AEvents: TList): Cardinal;
		function  DoDumpFiltEvents(const AEvents: TList): Cardinal;
		procedure DoInitDump(const AFiltIns: Boolean; const AMaxThreads: Integer);
		procedure DoStartDump;
		procedure DoPrepareSMF(var ASMF: TSMFFile);
		procedure DoFreeSMF(var ASMF: TSMFFile);
		procedure DoAddNewMIDIEvent(const AOffset: UInt64;
				const AFamily: TMIDIEvFamily; const AChannel: TMIDIEvChannel;
				const AData: array of Byte; var AEvent: PSMFMTev;
				const ATrack: PSMFMTrk);
		procedure DoDumpMIDIIns(var ASMF: TSMFFile; var ATrack: PSMFMTrk;
				const AIns: Integer);

	protected
		procedure FindOrInsertInstrument(const AInstrument: TSIDInstrument;
				const ANoteDuration: Cardinal; const ANoteMod: TSIDNoteModulation);

		procedure LoadCallback(const AStage: TXSIDFileStage;
				const APosition, ASize: Int64);
		procedure DumpCallback(const AID: Integer; const AStats: TXSIDStats);

		procedure DumpEnd(var AMsg: TMessage); message UM_DUMPEND;
		procedure DumpNext(var AMsg: TMessage); message UM_DUMPNEXT;

	public
		property  DumpAbort: Boolean read FDumpAbort write FDumpAbort;
	end;

var
	XSIDToMIDIMainForm: TXSIDToMIDIMainForm;

implementation

{$R *.dfm}

uses
	UITypes,
	VCL.ComCtrls,
	IniFiles,
	IOUtils,
	C64Types,
	FormDumpProgress,
	FormFileLoad,
	FormMIDIMapping;


procedure TXSIDToMIDIMainForm.Button10Click(Sender: TObject);
	var
	i,
	j: Integer;
	f: TIniFile;
	s: string;

	begin
	SaveDialog1.InitialDir:= ButtonedEdit2.Text;

	if  SaveDialog1.Execute then
		begin
		if  TFile.Exists(SaveDialog1.FileName) then
			TFile.Delete(SaveDialog1.FileName);

		f:= TIniFile.Create(SaveDialog1.FileName);
		try
			f.WriteString('Project', 'Version', '1.0');
			f.WriteString('Project', 'XSID', ButtonedEdit1.Text);
			f.WriteString('Project', 'Path', ButtonedEdit2.Text);
			f.WriteString('Project', 'BPM', Edit2.Text);
			f.WriteString('Project', 'Division', Edit3.Text);
			f.WriteString('Project', 'Numerator', Edit4.Text);
			f.WriteInteger('Project', 'Denominator', ComboBox1.ItemIndex);
			f.WriteInteger('Project', 'Count', Length(FInstruments));

			for i:= 0 to High(FMIDIMapping) do
				begin
				s:= 'Mapping' + IntToStr(i);
				f.WriteString(s, 'Name', string(FMIDIMapping[i].Name));
				f.WriteBool(s, 'Suppress', FMIDIMapping[i].Suppress);
				f.WriteBool(s, 'DrumMode', FMIDIMapping[i].DrumMode);
				f.WriteInteger(s, 'Channel', FMIDIMapping[i].Channel);
				f.WriteBool(s, 'ExtendForBend', FMIDIMapping[i].ExtendForBend);
				f.WriteInteger(s, 'PWidthStyle', Ord(FMIDIMapping[i].PWidthStyle));
				f.WriteBool(s, 'EffectOutput', FMIDIMapping[i].EffectOutput);

				if  FMIDIMapping[i].DrumMode then
					for j:= 0 to 127 do
						f.WriteInteger(s, 'NoteMap' + IntToStr(j),
								FMIDIMapping[i].NoteMap[j]);
				end;

			finally
			f.UpdateFile;
			f.Free;
			end;
		end;
	end;

procedure TXSIDToMIDIMainForm.Button11Click(Sender: TObject);
	var
	f: TIniFile;
	c,
	i,
	j,
	k: Integer;
	s: string;

	begin
	OpenDialog2.InitialDir:= ButtonedEdit2.Text;

	if  OpenDialog2.Execute then
		begin
		f:= TIniFile.Create(OpenDialog2.FileName);
		try
			DoClearData;
			ButtonedEdit1.Text:= f.ReadString('Project', 'XSID', '');
			ButtonedEdit2.Text:= f.ReadString('Project', 'Path',
					TPath.GetDirectoryName(Application.ExeName));

			DoLoadFile(ButtonedEdit1.Text);

			DoInitialiseProject;

			Edit2.Text:= f.ReadString('Project', 'BPM', '120');
			Edit3.Text:= f.ReadString('Project', 'Division', '168');
			Edit4.Text:= f.ReadString('Project', 'Numerator', '4');
			ComboBox1.ItemIndex:= f.ReadInteger('Project', 'Denominator', 1);

			c:= f.ReadInteger('Project', 'Count', 0);
			if  c <> Length(FInstruments) then
				begin
				MessageDlg('Instrument analysis mismatch in Project File!', mtError,
						[mbOK], -1);
				Exit;
				end;

			for i:= 0 to c - 1 do
				begin
				s:= 'Mapping' + IntToStr(i);

				FMIDIMapping[i].Name:= AnsiString(f.ReadString(s, 'Name', ''));
				FMIDIMapping[i].Suppress:= f.ReadBool(s, 'Suppress', False);
				FMIDIMapping[i].DrumMode:= f.ReadBool(s, 'DrumMode', False);
				FMIDIMapping[i].Channel:= f.ReadInteger(s, 'Channel',
						FMIDIMapping[i].Channel);
				FMIDIMapping[i].ExtendForBend:= f.ReadBool(s, 'ExtendForBend', True);
				FMIDIMapping[i].PWidthStyle:=
						TMIDIPWidthStyle(f.ReadInteger(s, 'PWidthStyle', 1));
				FMIDIMapping[i].EffectOutput:= f.ReadBool(s, 'EffectOutput', True);

				if  FMIDIMapping[i].DrumMode then
					for j:= 0 to 127 do
						begin
						k:= f.ReadInteger(s, 'NoteMap' + IntToStr(j),
								FMIDIMapping[i].NoteMap[j]);

						if  FInstruments[i].UsedNotes[j]
						and (k = -1) then
							begin
//							raise Exception.Create('Invalid Note Map reference in Project File!');
							MessageDlg('Invalid Note Map reference in Project File!',
									mtError, [mbOK], -1);
							Exit;
							end;

						FMIDIMapping[i].NoteMap[j]:= k;
						end;
				end;

			finally
			f.Free;
			end;
		end;
	end;

procedure TXSIDToMIDIMainForm.Button1Click(Sender: TObject);
	var
	smf: TSMFFile;
	trk: PSMFMTrk;
	i,
	ins: Integer;
	node: PVirtualNode;
	f: TFileStream;

	begin
	smf.HeaderChunk:= nil;
	smf.TrackChunks:= nil;

	ins:= -1;
	node:= vstInstruments.GetFirst(False);
	for i:= 0 to Length(FInstruments) - 1 do
		begin
		if  vstInstruments.Selected[node] then
			begin
			ins:= i;
			Break;
			end;

		node:= vstInstruments.GetNext(node);
		end;

	if  ins = -1 then
		Exit;

	DumpProgressForm:= TDumpProgressForm.Create(Self);
	try
		DumpProgressForm.SetSubProgressCount(0);

		DumpProgressForm.ProgressBar1.Min:= 0;
		DumpProgressForm.ProgressBar1.Max:= 1;
		DumpProgressForm.ProgressBar1.Position:= 0;

		Taskbar1.ProgressState:= TTaskBarProgressState.Normal;
		Taskbar1.ProgressValue:= 0;
		Taskbar1.ProgressMaxValue:= 1;

		DumpProgressForm.Show;
		Application.ProcessMessages;

		DoPrepareSMF(smf);

		New(smf.TrackChunks^.Next);
		Inc(smf.HeaderChunk^.NumTrks);

		trk:= smf.TrackChunks^.Next;
		trk^.Prev:= smf.TrackChunks;
		trk^.Next:= nil;

		trk^.ID:= LIT_TOK_SMFTRACK;
		trk^.Len:= 0;
		trk^.First:= nil;
		trk^.Last:= nil;

		DoDumpMIDIIns(smf, trk, ins);

		DumpProgressForm.ProgressBar1.Position:= 1;
		Application.ProcessMessages;

		Taskbar1.ProgressValue:= 1;

		f:= TFileStream.Create(Format('%sins%2.2d.mid', [
				IncludeTrailingPathDelimiter(ButtonedEdit2.Text), ins + 1]), fmCreate);
		try
			WriteSMFFile(smf, f);

			finally
			f.Free;
			end;

		finally
		DumpProgressForm.Release;
		DumpProgressForm:= nil;

		Taskbar1.ProgressState:= TTaskBarProgressState.None;
		Taskbar1.ProgressValue:= 0;

        DoFreeSMF(smf);
		end;
	end;

procedure TXSIDToMIDIMainForm.Button2Click(Sender: TObject);
	var
	i: Integer;
	events: TList;
	ins: Integer;
	node: PVirtualNode;

	begin
	events:= TList.Create;
	try
		ins:= -1;
		node:= vstInstruments.GetFirst(False);
		for i:= 0 to Length(FInstruments) - 1 do
			begin
			if  vstInstruments.Selected[node] then
				begin
				ins:= i;
				Break;
				end;

			node:= vstInstruments.GetNext(node);
			end;

		if  ins = -1 then
			Exit;

		DoDumpInsEvents(ins, events);
		DoDumpFile(events, IncludeTrailingPathDelimiter(ButtonedEdit2.Text) +
				Format('ins%2.2d.log', [ins + 1]));

		finally
		for i:= events.Count - 1 downto 0 do
			GlobalEventPool.ReleaseEvent(PXSIDEvent(events[i]));

		events.Free;
		end;
	end;

procedure TXSIDToMIDIMainForm.Button3Click(Sender: TObject);
	var
	i: Integer;
	events: TList;

	begin
	events:= TList.Create;
	try
		DoDumpFiltEvents(events);
		DoDumpFile(events, IncludeTrailingPathDelimiter(ButtonedEdit2.Text) + 'filt.log');

		finally
		for i:= events.Count - 1 downto 0 do
			GlobalEventPool.ReleaseEvent(PXSIDEvent(events[i]));

		events.Free;
		end;
	end;

procedure TXSIDToMIDIMainForm.Button4Click(Sender: TObject);
	begin
	FDumpCount:= 1;
	FDumpIndexes:= [1];

	DoInitDump(CheckBox2.Checked, StrToInt(Edit1.Text));
	end;

procedure TXSIDToMIDIMainForm.Button5Click(Sender: TObject);
	var
	i: Integer;
	ins: Integer;
	node: PVirtualNode;

	begin
	ins:= -1;
	node:= vstInstruments.GetFirst(False);
	for i:= 0 to Length(FInstruments) - 1 do
		begin
		if  vstInstruments.Selected[node] then
			begin
			ins:= i;
			Break;
			end;

		node:= vstInstruments.GetNext(node);
		end;

	if  ins = -1 then
		Exit;

	FDumpCount:= 1;
	FDumpIndexes:= [TDumpIndex(ins + 2)];

	DoInitDump(CheckBox2.Checked, StrToInt(Edit1.Text));
	end;

procedure TXSIDToMIDIMainForm.Button6Click(Sender: TObject);
	var
	i: TDumpIndex;

	begin
	FDumpCount:= Length(FInstruments);

	FDumpIndexes:= [];
	for i:= 2 to TDumpIndex(High(FInstruments) + 2) do
		Include(FDumpIndexes, i);

	if  CheckBox1.Checked then
		begin
		Inc(FDumpCount);
		Include(FDumpIndexes, 1);
		end;

	DoInitDump(CheckBox2.Checked, StrToInt(Edit1.Text));
	end;

procedure TXSIDToMIDIMainForm.Button7Click(Sender: TObject);
	begin
	FDumpCount:= 1;
	FDumpIndexes:= [0];

	DoInitDump(False, 1);
	end;

procedure TXSIDToMIDIMainForm.Button8Click(Sender: TObject);
	var
	i,
	ins: Integer;
	node: PVirtualNode;

	begin
	ins:= -1;
	node:= vstInstruments.GetFirst(False);
	for i:= 0 to Length(FInstruments) - 1 do
		begin
		if  vstInstruments.Selected[node] then
			begin
			ins:= i;
			Break;
			end;

		node:= vstInstruments.GetNext(node);
		end;

	if  ins = -1 then
		Exit;

	MIDIMappingForm:= TMIDIMappingForm.Create(Self);
	try
		MIDIMappingForm.EditMapping(@FMIDIMapping[ins], FInstruments[ins], ins);

		vstInstruments.Invalidate;

		finally
		MIDIMappingForm.Release;
		MIDIMappingForm:= nil;
		end;
	end;

procedure TXSIDToMIDIMainForm.Button9Click(Sender: TObject);
	var
	smf: TSMFFile;
	trk: PSMFMTrk;
	i: Integer;
	f: TFileStream;

	begin
	smf.HeaderChunk:= nil;
	smf.TrackChunks:= nil;

	DumpProgressForm:= TDumpProgressForm.Create(Self);
	try
		FDumpAbort:= False;

		DumpProgressForm.SetSubProgressCount(0);

		DumpProgressForm.ProgressBar1.Min:= 0;
		DumpProgressForm.ProgressBar1.Max:= Length(FInstruments);
		DumpProgressForm.ProgressBar1.Position:= 0;

		Taskbar1.ProgressState:= TTaskBarProgressState.Normal;
		Taskbar1.ProgressValue:= 0;
		Taskbar1.ProgressMaxValue:= Length(FInstruments);

		DumpProgressForm.Show;
		Application.ProcessMessages;

		DoPrepareSMF(smf);

		trk:= smf.TrackChunks;
		for i:= 0 to High(FInstruments) do
			begin
			if  not FMIDIMapping[i].Suppress then
				begin
				New(trk^.Next);
				Inc(smf.HeaderChunk^.NumTrks);

				trk^.Next^.Prev:= trk;
				trk^.Next^.Next:= nil;
				trk:= trk^.Next;

				trk^.ID:= LIT_TOK_SMFTRACK;
				trk^.Len:= 0;
				trk^.First:= nil;
				trk^.Last:= nil;

				DoDumpMIDIIns(smf, trk, i);
				end;

			if  FDumpAbort then
				Exit;

			DumpProgressForm.ProgressBar1.Position:= i + 1;
			Taskbar1.ProgressMaxValue:= i + 1;

			Application.ProcessMessages;
			end;

		f:= TFileStream.Create(IncludeTrailingPathDelimiter(ButtonedEdit2.Text) + 'song.mid', fmCreate);
		try
			WriteSMFFile(smf, f);

			finally
			f.Free;
			end;

		finally
		DumpProgressForm.Release;
		DumpProgressForm:= nil;
		Taskbar1.ProgressState:= TTaskBarProgressState.None;
		Taskbar1.ProgressValue:= 0;

        DoFreeSMF(smf);
		end;
	end;

procedure TXSIDToMIDIMainForm.ButtonedEdit1RightButtonClick(Sender: TObject);
	begin
	if  OpenDialog1.Execute then
		begin
		ButtonedEdit1.Text:= OpenDialog1.FileName;

		DoLoadFile(ButtonedEdit1.Text);
		DoInitialiseProject;
		end;
	end;

procedure TXSIDToMIDIMainForm.ButtonedEdit2RightButtonClick(Sender: TObject);
	begin
	FileOpenDialog1.DefaultFolder:= ButtonedEdit2.Text;

	if  FileOpenDialog1.Execute then
		ButtonedEdit2.Text:= FileOpenDialog1.FileName;
	end;

procedure TXSIDToMIDIMainForm.DoAddNewMIDIEvent(const AOffset: UInt64;
		const AFamily: TMIDIEvFamily; const AChannel: TMIDIEvChannel;
		const AData: array of Byte; var AEvent: PSMFMTev; const ATrack: PSMFMTrk);
	var
	i,
	l: Integer;
	oo: Extended;

	begin
	if  Assigned(AEvent) then
		begin
		New(AEvent^.Next);
		AEvent^.Next^.Prev:= AEvent;
		AEvent^.Next^.Next:= nil;

		AEvent:= AEvent^.Next;
		end
	else
		begin
		New(AEvent);
		AEvent^.Prev:= nil;
		AEvent^.Next:= nil;
		ATrack^.First:= AEvent;
		end;

	ATrack^.Last:= AEvent;

	oo:= AOffset / FBPM * FPPQN + FMIDIResidual;
	AEvent^.Delta:= Round(oo);
	FMIDIResidual:= oo - AEvent^.Delta;

	CardToVarLen(AEvent^.Delta, AEvent^.DVLen, AEvent^.DVari);

	AEvent^.Family:= AFamily;
	AEvent^.Chan:= AChannel;

	if  AFamily <> mefRunningStatus then
		l:= AEvent^.DVLen + 1
	else
		l:= AEvent^.DVLen;

	Inc(l, Length(AData));
	SetLength(AEvent^.Data, Length(AData));
	for i:= 0 to High(AData) do
		AEvent^.Data[i]:= AData[i];

	Inc(ATrack^.Len, l);
	end;

procedure TXSIDToMIDIMainForm.DoAnalyseInstruments;
	var
	i: Integer;
	ss: TSIDState;
	ev: PXSIDEvent;
	lt,
	rt: TSIDRegType;
	evvoc: Integer;
	evnew,
	evoff: Boolean;
	notecyc: array[0..2] of Cardinal;
	curinsts: array[0..2] of TSIDInstrument;
	curnotem: array[0..2] of TSIDNoteModulation;
	ao: Cardinal;

	begin
	lt:= srtFreqLo;
	ao:= 0;

	notecyc[0]:= 0;
	notecyc[1]:= 0;
	notecyc[2]:= 0;

	curinsts[0].Initialise;
	curinsts[1].Initialise;
	curinsts[2].Initialise;

	curnotem[0].Initialise;
	curnotem[1].Initialise;
	curnotem[2].Initialise;

	ss.Initialise;

	for i:= 0 to FEventsList.Count - 1 do
		try
			ev:= PXSIDEvent(FEventsList[i]);
			evvoc:= -1;
			evoff:= False;
			evnew:= False;

			Inc(ao, ev^.offs);

			if  ss.IsVoiceReg(ev^.data.reg) then
				begin
				evvoc:= ss.VoiceForReg(ev^.data.reg);

				if  (not ss.Voices[evvoc].Gated)
//				and not ss.Voices[evvoc].Testing
				and ss.IsGateChanged(ev^.data.reg, ev^.data.val) then
					evnew:= True;

				if  ss.Voices[evvoc].Gated
				and ss.IsGateChanged(ev^.data.reg, ev^.data.val) then
					evoff:= True;

				lt:= ss.Voices[evvoc].LastRegType;
				end
			else
				begin
				SetLength(FSongFiltMix, Length(FSongFiltMix) + 1);
				FSongFiltMix[High(FSongFiltMix)].Offset:= ao;
				FSongFiltMix[High(FSongFiltMix)].Reg:= ev^.data.reg;
				FSongFiltMix[High(FSongFiltMix)].Value:= ev^.data.val;
				end;

			if  curinsts[0].Valid then
//			and not ss.Voices[0].Testing then
				Inc(notecyc[0], ev^.offs);
			if  curinsts[1].Valid then
//			and not ss.Voices[1].Testing then
				Inc(notecyc[1], ev^.offs);
			if  curinsts[2].Valid then
//			and not ss.Voices[2].Testing then
				Inc(notecyc[2], ev^.offs);

			ss.UpdateRegister(ev^.data.reg, ev^.data.val);

			if  not evnew
			and (evvoc > -1)
			and (curinsts[evvoc].Valid) then
				begin
				rt:= ss.RegisterType(ev^.data.reg);

				if  ss.Voices[evvoc].Waveform <>
						curinsts[evvoc].WaveformMap[High(curinsts[evvoc].WaveformMap)].Waveform then
//				if  rt = srtControl then
					begin
					SetLength(curinsts[evvoc].WaveformMap,
							Length(curinsts[evvoc].WaveformMap) + 1);
					curinsts[evvoc].WaveformMap[High(curinsts[evvoc].WaveformMap)].Offset:=
							notecyc[evvoc];
					curinsts[evvoc].WaveformMap[High(curinsts[evvoc].WaveformMap)].Waveform:=
							ss.Voices[evvoc].Waveform;
					end;

				if  (rt in [srtFreqLo, srtFreqHi])
				and (ss.Voices[evvoc].Note > -1) then
					begin
					if  (Length(curnotem[evvoc].PitchMap) = 0)
//					or  not ((rt = srtFreqHi)
//					and  (lt = srtFreqLo)
//					and  ((notecyc[evvoc] - curnotem[evvoc].PitchMap[High(curnotem[evvoc].PitchMap)].Offset) <= 50)) then
					or  not ((lt in [srtFreqLo, srtFreqHi])
					and  ((notecyc[evvoc] - curnotem[evvoc].PitchMap[High(curnotem[evvoc].PitchMap)].Offset) <= 20)) then
						SetLength(curnotem[evvoc].PitchMap, Length(curnotem[evvoc].PitchMap) + 1);

					curnotem[evvoc].PitchMap[High(curnotem[evvoc].PitchMap)].Offset:=
							notecyc[evvoc];
					curnotem[evvoc].PitchMap[High(curnotem[evvoc].PitchMap)].Frequency:=
							ss.Voices[evvoc].Frequency;
					curnotem[evvoc].PitchMap[High(curnotem[evvoc].PitchMap)].Note:=
							ss.Voices[evvoc].Note;
					curnotem[evvoc].PitchMap[High(curnotem[evvoc].PitchMap)].Cents:=
							ss.Voices[evvoc].Cents;

					if  Length(curnotem[evvoc].PitchMap) = 1 then
						curnotem[evvoc].Sustain:= ss.Voices[evvoc].Sustain;
					end;

				if  rt in [srtPWLo, srtPWHi] then
					begin
					if  (Length(curnotem[evvoc].PWidthMap) = 0)
//					or  not ((rt = srtPWHi)
//					and  (lt = srtPWLo)
//					and  ((notecyc[evvoc] - curnotem[evvoc].PWidthMap[High(curnotem[evvoc].PWidthMap)].Offset) <= 50)) then
					or  not ((lt in [srtPWLo, srtPWHi])
					and  ((notecyc[evvoc] - curnotem[evvoc].PWidthMap[High(curnotem[evvoc].PWidthMap)].Offset) <= 20)) then
						SetLength(curnotem[evvoc].PWidthMap, Length(curnotem[evvoc].PWidthMap) + 1);

					curnotem[evvoc].PWidthMap[High(curnotem[evvoc].PWidthMap)].Offset:=
							notecyc[evvoc];
					curnotem[evvoc].PWidthMap[High(curnotem[evvoc].PWidthMap)].Width:=
							ss.Voices[evvoc].PWidth;
					end;

				if  rt = srtControl then
					if  ss.Voices[evvoc].Effect <>
							curinsts[evvoc].EffectMap[High(curinsts[evvoc].EffectMap)].Effect then
						begin
						SetLength(curinsts[evvoc].EffectMap, Length(curinsts[evvoc].EffectMap) + 1);
						curinsts[evvoc].EffectMap[High(curinsts[evvoc].EffectMap)].Offset:=
								notecyc[evvoc];
						curinsts[evvoc].EffectMap[High(curinsts[evvoc].EffectMap)].Effect:=
								ss.Voices[evvoc].Effect;
						end;

				end;

			if  evoff
			and curinsts[evvoc].Valid then
				curnotem[evvoc].NoteOff:= ao;

			if  evnew then
				begin
				curnotem[evvoc].NoteEnd:= curnotem[evvoc].NoteStart +
						notecyc[evvoc] - Cardinal(ev^.offs);

				if  curinsts[evvoc].Valid
				and (Length(curnotem[evvoc].PitchMap) = 0) then
					if (curinsts[evvoc].ResidualPitch.Note > -1) then
						begin
						SetLength(curnotem[evvoc].PitchMap, 1);
						curnotem[evvoc].PitchMap[0].Offset:= 0;
						curnotem[evvoc].PitchMap[0].Frequency:=
								curinsts[evvoc].ResidualPitch.Frequency;
						curnotem[evvoc].PitchMap[0].Note:=
								curinsts[evvoc].ResidualPitch.Note;
						curnotem[evvoc].PitchMap[0].Cents:=
								curinsts[evvoc].ResidualPitch.Cents;
						curnotem[evvoc].Sustain:= ss.Voices[evvoc].Sustain;
						end;

				FindOrInsertInstrument(curinsts[evvoc], notecyc[evvoc], curnotem[evvoc]);

				curinsts[evvoc].Initialise;
				curnotem[evvoc].Initialise;

				curnotem[evvoc].NoteStart:= ao;

				curinsts[evvoc].Voice:= evvoc;
				curinsts[evvoc].Valid:= True;

				curinsts[evvoc].Attack:= ss.Voices[evvoc].Attack;
				curinsts[evvoc].Decay:= ss.Voices[evvoc].Decay;
				curinsts[evvoc].Release:= ss.Voices[evvoc].Release;

				SetLength(curinsts[evvoc].WaveformMap, 1);
				curinsts[evvoc].WaveformMap[0].Offset:= 0;
				curinsts[evvoc].WaveformMap[0].Waveform:= ss.Voices[evvoc].Waveform;

				SetLength(curinsts[evvoc].EffectMap, 1);
				curinsts[evvoc].EffectMap[0].Offset:= 0;
				curinsts[evvoc].EffectMap[0].Effect:= ss.Voices[evvoc].Effect;

				if  not ss.Voices[evvoc].UseFreqAfterGate
				and (ss.Voices[evvoc].Note > -1) then
					begin
					SetLength(curnotem[evvoc].PitchMap, 1);
					curnotem[evvoc].PitchMap[0].Offset:= 0;
					curnotem[evvoc].PitchMap[0].Frequency:= ss.Voices[evvoc].Frequency;
					curnotem[evvoc].PitchMap[0].Note:= ss.Voices[evvoc].Note;
					curnotem[evvoc].PitchMap[0].Cents:= ss.Voices[evvoc].Cents;
                    curnotem[evvoc].Sustain:= ss.Voices[evvoc].Sustain;
					end;

				curinsts[evvoc].ResidualPitch.Offset:= 0;
				curinsts[evvoc].ResidualPitch.Frequency:= ss.Voices[evvoc].Frequency;
				curinsts[evvoc].ResidualPitch.Note:= ss.Voices[evvoc].Note;
				curinsts[evvoc].ResidualPitch.Cents:= ss.Voices[evvoc].Cents;

				notecyc[evvoc]:= 0;
				end;

			except
			ShowMessage('Analysis failed at index:  ' + IntToStr(i));
			end;

		for i:= 0 to 2 do
			if  curinsts[i].Valid then
				begin
				if  curnotem[i].NoteOff = 0 then
					curnotem[i].NoteOff:= ao;

				curnotem[i].NoteEnd:= ao;

				if  curinsts[i].Valid
				and (Length(curnotem[i].PitchMap) = 0) then
					if (curinsts[i].ResidualPitch.Note > -1) then
						begin
						SetLength(curnotem[i].PitchMap, 1);
						curnotem[i].PitchMap[0].Offset:= 0;
						curnotem[i].PitchMap[0].Frequency:=
								curinsts[i].ResidualPitch.Frequency;
						curnotem[i].PitchMap[0].Note:=
								curinsts[i].ResidualPitch.Note;
						curnotem[i].PitchMap[0].Cents:=
								curinsts[i].ResidualPitch.Cents;
						end;

				FindOrInsertInstrument(curinsts[i], notecyc[i], curnotem[i]);
				end;
	end;

procedure TXSIDToMIDIMainForm.DoClearData;
	var
	i: Integer;

	begin
	if  Assigned(FXSIDConfig) then
		begin
		FXSIDConfig.Free;
		FXSIDConfig:= nil;
		end;

	if  Assigned(FEventsList) then
		begin
		for i:= FEventsList.Count - 1 downto 0 do
			GlobalEventPool.ReleaseEvent(PXSIDEvent(FEventsList[i]));

		FEventsList.Free;
		FEventsList:= nil;
		end;

	vstInstruments.RootNodeCount:= 0;

	SetLength(FInstruments, 0);
	SetLength(FMIDIMapping, 0);

	SetLength(FSongRecompose, 0);
	SetLength(FSongFiltMix, 0);
	end;

procedure TXSIDToMIDIMainForm.DoDisplayInstruments;
	begin
	vstInstruments.RootNodeCount:= Length(FInstruments);
	end;

procedure TXSIDToMIDIMainForm.DoDumpFile(const AEvents: TList; const AFileName: string);
	var
	i: Integer;
	f: TStringStream;
	s: string;
	ev: PXSIDEvent;

	begin
	f:= TStringStream.Create;
	try
		for i:= 0 to AEvents.Count - 1 do
			begin
			ev:= PXSIDEvent(AEvents[i]);

			s:= IntToStr(ev^.offs) + ' ';
			s:= s + IntToStr(ev^.data.reg) + ' ' + IntToStr(ev^.data.val) + #13#10;

			f.WriteString(s);
			end;

		finally
		f.SaveToFile(AFileName);

		f.Free;
		end;
	end;

function TXSIDToMIDIMainForm.DoDumpFiltEvents(const AEvents: TList): Cardinal;
	var
	co,
	eo: Cardinal;
	f: Integer;
	reg,
	val: Byte;

	procedure AddNewEvent;
		var
		ev: PXSIDEvent;

		begin
		ev:= GlobalEventPool.AllocateEvent;

		ev^.offs:= eo;
		ev^.data.reg:= reg;
		ev^.data.val:= val;

		AEvents.Add(ev);
		end;

	procedure AddFiltMixChange;
		begin
		reg:= FSongFiltMix[f].Reg;
		val:= FSongFiltMix[f].Value;
		AddNewEvent;
		Inc(f);
		end;

	begin
	co:= 0;
	f:= 0;
	while f < Length(FSongFiltMix) do
		begin
		eo:= FSongFiltMix[f].Offset - co;
		AddFiltMixChange;
		Inc(co, eo);
		end;

	Result:= co;
	end;

function TXSIDToMIDIMainForm.DoDumpInsEvents(const AIns: Integer;
		const AEvents: TList): Cardinal;
	var
	co,
	eo,
	lo,
	no,
	ro,
	fo,
	el: Cardinal;
	i,
	w,
	p,
	j,
	k,
	f: Integer;
	reg,
	val: Byte;
	g,
	dg,
	s: Boolean;
	im,
	nm: TSIDMessageType;
	lw: TSIDWaveformTypes;
	le: TSIDEffectTypes;
	fm: TSIDFiltMixState;

	procedure AddNewEvent;
		var
		ev: PXSIDEvent;

		begin
		ev:= GlobalEventPool.AllocateEvent;

		ev^.offs:= eo;
		ev^.data.reg:= reg;
		ev^.data.val:= val;

		AEvents.Add(ev);
		end;

	function EffectToRegValue(const AEffect: TSIDEffectTypes): Byte;
		begin
		Result:= 0;
		if  setRing in AEffect then
			Result:= Result or $04;
		if  setSync in AEffect then
			Result:= Result or $02;
		end;

	function WaveformToRegValue(const AWaveform: TSIDWaveformTypes): Byte;
		begin
		Result:= 0;

		if  swtTest in AWaveform then
			Result:= Result or $08;

		if  swtNoise in AWaveform then
			Result:= Result or $80;
		if  swtPulse in AWaveform then
			Result:= Result or $40;
		if  swtSawtooth in AWaveform then
			Result:= Result or $20;
		if  swtTriangle in AWaveform then
			Result:= Result or $10;
		end;

	procedure AddWaveChange;
		begin
		reg:= FInstruments[AIns].Voice * 7 + Ord(srtControl);
		val:= WaveformToRegValue(FInstruments[AIns].WaveformMap[w].Waveform) or
				EffectToRegValue(le);
		if  g then
			val:= val or $01;

		AddNewEvent;

		lw:= FInstruments[AIns].WaveformMap[w].Waveform;
		Inc(w);

		if  not g
		and not dg then
			dg:= True;
		end;

	procedure AddEffectChange;
		begin
		reg:= FInstruments[AIns].Voice * 7 + Ord(srtControl);
		val:= WaveformToRegValue(FInstruments[AIns].WaveformMap[w].Waveform) or
				EffectToRegValue(FInstruments[AIns].EffectMap[k].Effect);
		if  g then
			val:= val or $01;

		AddNewEvent;

		le:= FInstruments[AIns].EffectMap[k].Effect;
		Inc(k);

		if  not g
		and not dg then
			dg:= True;
		end;

	procedure AddPitchChange;
		var
		pitch: Word;

		begin
		pitch:= Round(FSongRecompose[AIns, i].PitchMap[p].Frequency * VAL_SIZ_SIDFREQGEN /
				ARR_VAL_SYSCYCPSEC[XSIDSystem]);

		reg:= FInstruments[AIns].Voice * 7 + Ord(srtFreqHi);
		val:= (pitch and $FF00) shr 8;
		AddNewEvent;

		eo:= 14;
		reg:= FInstruments[AIns].Voice * 7 + Ord(srtFreqLo);
		val:= pitch and $FF;
		AddNewEvent;

		Inc(p);
		end;

	procedure AddPWidthChange;
		begin
		reg:= FInstruments[AIns].Voice * 7 + Ord(srtPWHi);
		val:= (FSongRecompose[AIns, i].PWidthMap[j].Width and $FF00) shr 8;
		AddNewEvent;

		eo:= 14;
		reg:= FInstruments[AIns].Voice * 7 + Ord(srtPWLo);
		val:= FSongRecompose[AIns, i].PWidthMap[j].Width and $FF;
		AddNewEvent;

		Inc(j);
		end;

	procedure AddFiltMixChange;
		begin
		reg:= FSongFiltMix[f].Reg;
		val:= FSongFiltMix[f].Value;
		AddNewEvent;
		Inc(f);
		end;

	begin
	el:= SpinEdit1.Value;

	eo:= 6;
	reg:= 24;
	val:= $0F;
	AddNewEvent;

	eo:= 6;
	reg:= FInstruments[AIns].Voice * 7 + Ord(srtEnvAD);
	val:= (FInstruments[AIns].Attack shl 4) or FInstruments[AIns].Decay;
	AddNewEvent;

	eo:= 6;
	reg:= FInstruments[AIns].Voice * 7 + Ord(srtEnvSR);
	val:= $F0 or FInstruments[AIns].Release;
	AddNewEvent;

	co:= 18;
	i:= 0;
	f:= 0;
	while  i < Length(FSongRecompose[AIns]) do
		begin
		if  FDumpFiltIns then
			begin
			fm.Initialise;
			fo:= co;

			while (f < Length(FSongFiltMix)) and
					(FSongFiltMix[f].Offset < FSongRecompose[AIns, i].NoteStart)  do
				begin
				fm.UpdateRegister(FSongFiltMix[f].Reg, FSongFiltMix[f].Value);
				fo:= FSongFiltMix[f].Offset;
				Inc(f);
				end;

			if  (fo - co) >= el * 4  then
				begin
				eo:= fo - co - el * 3;
				reg:= 21;
				val:= fm.FCLo;
				AddNewEvent;
				eo:= el;
				reg:= 22;
				val:= fm.FCHi;
				AddNewEvent;
				reg:= 23;
				val:= fm.ResFilt;
				AddNewEvent;
				reg:= 24;
				val:= fm.ModeVol;
				AddNewEvent;
				end;

			co:= fo;
			end;

		w:= 1;
		p:= 0;
		j:= 0;
		k:= 1;

		lw:= FInstruments[AIns].WaveformMap[0].Waveform;
		le:= FInstruments[AIns].EffectMap[0].Effect;

		eo:= FSongRecompose[AIns, i].NoteStart - co;
		reg:= FInstruments[AIns].Voice * 7 + Ord(srtControl);
		val:= WaveformToRegValue(lw) or EffectToRegValue(le) or $01;
		AddNewEvent;

		Inc(co, eo);

		g:= True;
		dg:= False;
		ro:= 0;
		no:= 0;
		nm:= smtNext;
		while no < FSongRecompose[AIns, i].NoteEnd - FSongRecompose[AIns, i].NoteStart do
			begin
//			Find next event
			for im:= Low(TSIDMessageType) to High(TSIDMessageType) do
				case im of
					smtNext:
						begin
						no:= FSongRecompose[AIns, i].NoteEnd - FSongRecompose[AIns, i].NoteStart;
						nm:= smtNext;
						end;
					smtGateOff:
						if  g
//						or  ((not g)
//						and  (not dg)))
						and (FSongRecompose[AIns, i].NoteOff - FSongRecompose[AIns, i].NoteStart < no) then
							begin
							no:= FSongRecompose[AIns, i].NoteOff - FSongRecompose[AIns, i].NoteStart;
							nm:= smtGateOff;
							end;
					smtPitch:
						if  (p < Length(FSongRecompose[AIns, i].PitchMap))
						and (FSongRecompose[AIns, i].PitchMap[p].Offset < no) then
							begin
							no:= FSongRecompose[AIns, i].PitchMap[p].Offset;
							nm:= smtPitch;
							end;
					smtWaveform:
						if  (w < Length(FInstruments[AIns].WaveformMap))
						and (FInstruments[AIns].WaveformMap[w].Offset <= no) then
							begin
							no:= FInstruments[AIns].WaveformMap[w].Offset;
							nm:= smtWaveform;
							end;
					smtPWidth:
						if  (j < Length(FSongRecompose[AIns, i].PWidthMap))
						and (FSongRecompose[AIns, i].PWidthMap[j].Offset < no) then
							begin
							no:= FSongRecompose[AIns, i].PWidthMap[j].Offset;
							nm:= smtPWidth;
							end;
					smtEffect:
						if  (k < Length(FInstruments[AIns].EffectMap))
						and (FInstruments[AIns].EffectMap[k].Offset <= no) then
							begin
//							no:= FSongRecompose[AIns, i].EffectMap[k].Offset;
//							nm:= smtEffect;
							end;
					smtFiltMix:
						if  FDumpFiltIns
						and (f < Length(FSongFiltMix))
						and (FSongFiltMix[f].Offset < no + FSongRecompose[AIns, i].NoteStart) then
							begin
							no:= FSongFiltMix[f].Offset - FSongRecompose[AIns, i].NoteStart;
							nm:= smtFiltMix;
							end;
					end;


			if  no > ro then
				eo:= no - ro
			else
				begin
				eo:= el;
				no:= ro + el;
				end;

			lo:= eo;

//			Do wav change, pwidth change or pitch change
			case nm of
				smtNext:
					begin
					if  g then
						begin
						reg:= FInstruments[AIns].Voice * 7 + Ord(srtControl);
						val:= WaveformToRegValue(lw) or EffectToRegValue(le);
						AddNewEvent;
						g:= False;
						dg:= True;
						Inc(ro, eo);
//						Inc(co, eo);
						end;
					Break;
					end;
				smtGateOff:
					begin
//					if  not g
//					and not dg then
						begin
						reg:= FInstruments[AIns].Voice * 7 + Ord(srtControl);
						val:= WaveformToRegValue(lw) or EffectToRegValue(le);
						AddNewEvent;
						g:= False;
//						dg:= True;
						end;
					end;
				smtWaveform:
					begin
//					if  eo >= 42 then
//						begin
//						Dec(eo, 28);
//						reg:= FInstruments[AIns].Voice * 7 + Ord(srtEnvAD);
//						val:= (FInstruments[AIns].Attack shl 4) or FInstruments[AIns].Decay;
//						AddNewEvent;
//
//						eo:= 14;
//						reg:= FInstruments[AIns].Voice * 7 + Ord(srtEnvSR);
//						val:= $F0 or FInstruments[AIns].Release;
//						AddNewEvent;
//
//						eo:= 14;
//						end;

					AddWaveChange;
					end;
				smtPitch:
					begin
					if  eo >= el * 2 then
						begin
						s:= True;
						Dec(eo, el);
						end
					else
						s:= False;

					AddPitchChange;
					end;
				smtPWidth:
					begin
					if  eo >= el * 2 then
						begin
						s:= True;
						Dec(eo, el);
						end
					else
						s:= False;

					AddPWidthChange;
					end;
				smtEffect:
					AddEffectChange;
				smtFiltMix:
					AddFiltMixChange;
				end;

			Inc(ro, lo);
//			Inc(co, eo);
//			ro:= no;
			end;

		Inc(co, ro);
//		co:= FSongRecompose[AIns, i].NoteEnd;
		Inc(i);
		end;

	Result:= co;
	end;

procedure TXSIDToMIDIMainForm.DoDumpMIDIIns(var ASMF: TSMFFile; var ATrack: PSMFMTrk;
		const AIns: Integer);
	var
	ev: PSMFMTev;
	eo,
	lo,
	co,
	no: UInt64;
	ro: Extended;
	i,
	p,
	j,
	k: Integer;
	g: Boolean;
	d: array of Byte;
	im,
	nm: TSIDMessageType;
//	ln: TMIDINote;
	ch: Byte;
	ic: Integer;
	nn: TMIDINoteMap;
	nc: Integer;

	procedure CalculateEventOffset(const ANextOffset: UInt64);
		var
		us: Extended;

		begin
		us:= ANextOffset / ARR_VAL_SYSCYCPSEC[XSIDSystem] * 1000000 + ro;
		eo:= Round(us);
		ro:= us - eo;
		end;

	procedure AddMIDIPitchBendRange;
		var
		mn: Byte;

		begin
		mn:= FInstruments[AIns].BendRange div 100;

		SetLength(d, 2);
		d[0]:= $65;
		d[1]:= 0;
		DoAddNewMIDIEvent(0, mefController, ch, d, ev, ATrack);
		d[0]:= $64;
		d[1]:= 0;
		DoAddNewMIDIEvent(0, mefController, ch, d, ev, ATrack);
		d[0]:= $06;
		d[1]:= mn;
		DoAddNewMIDIEvent(0, mefController, ch, d, ev, ATrack);
		d[0]:= $26;
//		d[1]:= FInstruments[AIns].BendRangeCents;
		d[1]:= 0;
		DoAddNewMIDIEvent(0, mefController, ch, d, ev, ATrack);
		end;

	procedure AddMIDIPitchBend(const ATotalCents: Integer);
		var
		tc: Integer;
		bb: TMIDIPitchBend;
		br: Integer;
		bc: TMIDIDataLong;

		begin
		br:= FInstruments[AIns].BendRange;

		if  Abs(ATotalCents) > br then
			if  ATotalCents < 0 then
				tc:= -br
			else
				tc:= br
		else
			tc:= ATotalCents;

		if  tc < 0 then
			bb:= Round(tc / br * 8192)
		else
			bb:= Round(tc / br * 8191);

		bc:= bb + 8192;

		SetLength(d, 2);
		d[0]:= bc and $7F;
		d[1]:= (bc and $3F80) shr 7;
		DoAddNewMIDIEvent(eo, mefPitchWheel, ch, d, ev, ATrack);
		end;

	procedure AddPitchChange(const AInitCents: Integer; const ANewNote: TMIDINote;
			const ANewCents: TMIDICents);
		var
		l,
		newc: Integer;

		begin
		if  not FMIDIMapping[AIns].ChordMode then
			begin
			newc:= ANewNote * 100 + ANewCents;

			if  Abs(AInitCents - newc) > FInstruments[AIns].BendRange then
				begin
				ic:= ANewNote * 100 + ANewCents;

				AddMIDIPitchBend(ANewCents);
				eo:= 0;
				SetLength(d, 2);
				d[0]:= ANewNote;
				d[1]:= Round((FSongRecompose[AIns, i].Sustain + 1) / 16 * 64 + 63);
				DoAddNewMIDIEvent(eo, mefNoteOn, ch, d, ev, ATrack);

				d[0]:= nn[0];
				d[1]:= 0;
				DoAddNewMIDIEvent(eo, mefNoteOff, ch, d, ev, ATrack);

				nn[0]:= ANewNote;
				end
			else
				AddMIDIPitchBend(newc - AInitCents);
			end
		else
			begin
			newc:= ANewNote;
			for l:= 0 to nc - 1 do
				if  nn[l] = newc then
					begin
					newc:= -1;
					Break;
					end;

			if  newc <> -1 then
				begin
				SetLength(d, 2);
				d[0]:= ANewNote;
				d[1]:= Round((FSongRecompose[AIns, i].Sustain + 1) / 16 * 64 + 63);
				DoAddNewMIDIEvent(eo, mefNoteOn, ch, d, ev, ATrack);

				nn[nc]:= ANewNote;
				Inc(nc);
				end
			else
				begin
				SetLength(d, 2);
				d[0]:= 19;
				d[1]:= 127;
				DoAddNewMIDIEvent(eo, mefController, ch, d, ev, ATrack);
				end;
			end;
		end;

	procedure AddGateOff;
		var
		i: Integer;

		begin
		for i:= 0 to nc - 1 do
			begin
			SetLength(d, 2);
			d[0]:= nn[i];
			d[1]:= 0;
			DoAddNewMIDIEvent(eo, mefNoteOff, ch, d, ev, ATrack);
			eo:= 0;
			end;
		g:= False;
		nc:= 0;
		end;

	procedure AddPWidthChange;
		var
		pwsw: TMIDIDataLong;
		pwsl,
		pwsh: Byte;

		begin
		if  FMIDIMapping[AIns].PWidthStyle = mpwDouble then
			begin
			pwsw:= Round(FSongRecompose[AIns, i].PWidthMap[j].Width /
					High(TSIDPulseWidth) * High(TMIDIDataLong));
			pwsl:= pwsw and $7F;
			pwsh:= (pwsw and $3F80) shr 7;

			SetLength(d, 2);
			d[0]:= 17;
			d[1]:= pwsl;
			DoAddNewMIDIEvent(eo, mefController, ch, d, ev, ATrack);
			eo:= 0;
			end
		else
			pwsh:= Round(FSongRecompose[AIns, i].PWidthMap[j].Width /
					High(TSIDPulseWidth) * 127);

		if  FMIDIMapping[AIns].PWidthStyle > mpwNone then
			begin
			SetLength(d, 2);
			d[0]:= 16;
			d[1]:= pwsh;
			DoAddNewMIDIEvent(eo, mefController, ch, d, ev, ATrack);
			end;
		end;

	procedure AddEffectChange;
		var
//		mrm,
		mos: Byte;

		begin
		if  setRing in FInstruments[AIns].EffectMap[k].Effect then
			mos:= 64
		else
			mos:= 0;

		if  setSync in FInstruments[AIns].EffectMap[k].Effect then
			mos:= mos + 32;
//		else
//			mos:= 0;

		SetLength(d, 2);
		d[0]:= 18;
		d[1]:= mos;
		DoAddNewMIDIEvent(eo, mefController, ch, d, ev, ATrack);
		eo:= 0;

//		d[0]:= 18;
//		d[1]:= mrm;
//		DoAddNewMIDIEvent(eo, mefController, ch, d, ev, ATrack);
//		eo:= 0;
		end;

	begin
	ev:= nil;
	FMIDIResidual:= 0;

	if  Length(FMIDIMapping[AIns].Name) > 0 then
		begin
		SetLength(d, Length(FMIDIMapping[AIns].Name) + 2);
		d[0]:= 03;
		d[1]:= Length(FMIDIMapping[AIns].Name);
		Move(AnsiString(FMIDIMapping[AIns].Name)[1], d[2], Length(FMIDIMapping[AIns].Name));
		DoAddNewMIDIEvent(0, mefSystem, 15, d, ev, ATrack);
		end;

	if  FMIDIMapping[AIns].DrumMode then
		ch:= 9
	else
		begin
		ch:= FMIDIMapping[AIns].Channel;

		AddMIDIPitchBendRange;
		end;

	co:= 0;
	ro:= 0;

	i:= 0;
	while  i < Length(FSongRecompose[AIns]) do
		begin
		p:= 0;
		j:= 0;

		for nc:= 0 to High(nn) do
			nn[nc]:= -1;
//		nc:= 0;

		Assert(FSongRecompose[AIns, i].PitchMap[0].Note > -1);

		lo:= FSongRecompose[AIns, i].NoteStart - co;
		CalculateEventOffset(lo);

		if  not FMIDIMapping[AIns].DrumMode
		and FMIDIMapping[AIns].EffectOutput
		and ((FInstruments[AIns].EffectMap[0].Effect <> [])
		or   (Length(FInstruments[AIns].EffectMap) > 1)) then
			begin
			k:= 0;
			AddEffectChange;
			eo:= 0;
			end;
		k:= 1;

		if  not FMIDIMapping[AIns].DrumMode
		and not FMIDIMapping[AIns].ChordMode then
			begin
			AddMIDIPitchBend(FSongRecompose[AIns, i].PitchMap[0].Cents);
			eo:= 0;
			end;
		ic:= FSongRecompose[AIns, i].PitchMap[0].Note * 100 +
					FSongRecompose[AIns, i].PitchMap[0].Cents;

		SetLength(d, 2);
		if  FMIDIMapping[AIns].DrumMode then
			d[0]:= FMIDIMapping[AIns].NoteMap[FSongRecompose[AIns, i].PitchMap[0].Note]
		else
			d[0]:= FSongRecompose[AIns, i].PitchMap[0].Note;

		d[1]:= Round((FSongRecompose[AIns, i].Sustain + 1) / 16 * 64 + 63);
		DoAddNewMIDIEvent(eo, mefNoteOn, ch, d, ev, ATrack);

		co:= FSongRecompose[AIns, i].NoteStart;

		nn[0]:= d[0];
		nc:= 1;

		g:= True;
		no:= 0;
		nm:= smtNext;
		while no < FSongRecompose[AIns, i].NoteEnd do
			begin
//			Find next event
			for im:= Low(TSIDMessageType) to High(TSIDMessageType) do
				case im of
					smtNext:
						begin
						no:= FSongRecompose[AIns, i].NoteEnd;
						nm:= smtNext;
						end;
					smtGateOff:
						if  g
						and (FMIDIMapping[AIns].DrumMode
						or   not FMIDIMapping[AIns].ExtendForBend)
//						or  ((not g)
//						and  (not dg)))
						and (FSongRecompose[AIns, i].NoteOff < no) then
							begin
							no:= FSongRecompose[AIns, i].NoteOff;
							nm:= smtGateOff;
							end;
					smtPitch:
						if  not FMIDIMapping[AIns].DrumMode
						and (p < Length(FSongRecompose[AIns, i].PitchMap))
						and (FSongRecompose[AIns, i].PitchMap[p].Offset < no -
								FSongRecompose[AIns, i].NoteStart) then
							begin
							no:= FSongRecompose[AIns, i].PitchMap[p].Offset +
									FSongRecompose[AIns, i].NoteStart;
							nm:= smtPitch;
							end;
					smtPWidth:
						if  not FMIDIMapping[AIns].DrumMode
						and (FMIDIMapping[AIns].PWidthStyle > mpwNone)
						and (j < Length(FSongRecompose[AIns, i].PWidthMap))
						and (FSongRecompose[AIns, i].PWidthMap[j].Offset < no -
								FSongRecompose[AIns, i].NoteStart) then
							begin
							no:= FSongRecompose[AIns, i].PWidthMap[j].Offset +
									FSongRecompose[AIns, i].NoteStart;
							nm:= smtPWidth;
							end;
					smtEffect:
						if  not FMIDIMapping[AIns].DrumMode
						and FMIDIMapping[AIns].EffectOutput
						and (k < Length(FInstruments[AIns].EffectMap))
						and (FInstruments[AIns].EffectMap[k].Offset <= no -
								FSongRecompose[AIns, i].NoteStart) then
							begin
							no:= FInstruments[AIns].EffectMap[k].Offset +
									FSongRecompose[AIns, i].NoteStart;
							nm:= smtEffect;
							end;
					end;


			lo:= no - co;

//			Do wav change, pwidth change or pitch change
			case nm of
				smtNext:
					begin
					if  g then
						begin
						CalculateEventOffset(lo);
						AddGateOff;
						co:= no;
						end;
					Break;
					end;
				smtGateOff:
					begin
					CalculateEventOffset(lo);
					AddGateOff;
					end;
				smtPitch:
					begin
					CalculateEventOffset(lo);
					AddPitchChange(ic, FSongRecompose[AIns, i].PitchMap[p].Note,
							FSongRecompose[AIns, i].PitchMap[p].Cents);
					Inc(p);
					end;
				smtPWidth:
					begin
					CalculateEventOffset(lo);
					AddPWidthChange;
					Inc(j);
					end;
				smtEffect:
					begin
					CalculateEventOffset(lo);
					AddEffectChange;
					Inc(k);
					end;
				end;

			co:= no;
			end;

//		Inc(co, oo);
		Inc(i);
		end;

	eo:= 0;
	SetLength(d, 2);
	d[0]:= $2F;
	d[1]:= $00;
	DoAddNewMIDIEvent(eo, mefSystem, $0F, d, ev, ATrack);
	end;

procedure TXSIDToMIDIMainForm.DoFreeSMF(var ASMF: TSMFFile);
	begin
    FinaliseSMFFile(ASMF);
	end;

procedure TXSIDToMIDIMainForm.DoInitDump(const AFiltIns: Boolean;
		const AMaxThreads: Integer);
	var
	i,
	a: Integer;

	begin
	FDumpFiltIns:= AFiltIns;

	FDumpAbort:= False;
	DumpProgressForm:= TDumpProgressForm.Create(Self);

	i:= CPUCount - 1;
	if  i = 0 then
		i:= 1;
	if  (AMaxThreads > 0)
	and (i > AMaxThreads) then
		i:= AMaxThreads;
	if  FDumpCount < i then
		i:= FDumpCount;

	FDumpSlots:= i;
	DumpProgressForm.SetSubProgressCount(i);

	FDumpAvail:= [];
	for a:= 0 to Pred(TDumpIndex(i)) do
		Include(FDumpAvail, a);

	SetLength(FDumpData, i);
	for i:= 0 to High(FDumpData) do
		begin
		FDumpData[i].ID:= -128;
		FDumpData[i].DumpIndex:= 0;
		FDumpData[i].ProgIndex:= i;
		FDumpData[i].XSIDThread:= nil;

		FDumpData[i].XSIDConfig:= TXSIDConfig.Create;
		FDumpData[i].XSIDConfig.Assign(FDumpConfig);

		FDumpData[i].XSIDEvents:= TXSIDEventManager.Create;
		FDumpData[i].XSIDConfig.Renderer:= GlobalRenderers.Items[0].GetName;

		FDumpData[i].Size:= 0;
		FDumpData[i].Ticks:= 0;
		end;

	DumpProgressForm.ProgressBar1.Min:= 0;
	DumpProgressForm.ProgressBar1.Max:= FDumpCount;
	DumpProgressForm.ProgressBar1.Position:= 0;

	Taskbar1.ProgressState:= TTaskBarProgressState.Normal;
	Taskbar1.ProgressValue:= 0;
	Taskbar1.ProgressMaxValue:= FDumpCount;

	DumpProgressForm.Show;
	Application.ProcessMessages;

	DoStartDump;
	end;

procedure TXSIDToMIDIMainForm.DoInitialiseProject;
	begin
	FDumpConfig.Assign(GlobalConfig);

//	TODO Need override flags checking.

	if  FXSIDConfig.System > cstAny then
		FDumpConfig.System:= FXSIDConfig.System;
//	FDumpConfig.System:= cstNTSC;

	FDumpConfig.UpdateRate:= FXSIDConfig.UpdateRate;

	if  FXSIDConfig.Model > csmAny then
		FDumpConfig.Model:= FXSIDConfig.Model;

	FDumpConfig.FilterEnable:= FXSIDConfig.FilterEnable;
	FDumpConfig.Filter6581:= FXSIDConfig.Filter6581;
	FDumpConfig.Filter8580:= FXSIDConfig.Filter8580;
	FDumpConfig.DigiBoostEnable:= FXSIDConfig.DigiBoostEnable;

	Label7.Caption:=
			StringReplace(string(FXSIDConfig.Title), '&', '&&', [rfReplaceAll]);
	Label8.Caption:=
			StringReplace(string(FXSIDConfig.Artist), '&', '&&', [rfReplaceAll]);
	Label12.Caption:=
			StringReplace(string(FXSIDConfig.Album), '&', '&&', [rfReplaceAll]);
	Label13.Caption:=
			StringReplace(string(FXSIDConfig.Date), '&', '&&', [rfReplaceAll]);
	Label14.Caption:=
			StringReplace(string(FXSIDConfig.TrackNumber), '&', '&&', [rfReplaceAll]);

	XSIDSystem:= FDumpConfig.System;

	DoAnalyseInstruments;

	DoPrepareMIDIMapping;

	DoDisplayInstruments;
	end;

procedure TXSIDToMIDIMainForm.DoLoadFile(const AFileName: string);
	begin
	FileLoadForm:= TFileLoadForm.Create(Self);
	try
		FileLoadForm.Show;
		Application.ProcessMessages;

		FEventsList:= TList.Create;
		FSongSize:= XSIDLoadFileXSID(AFileName, FEventsList, LoadCallback, FXSIDConfig);

		FileLoadForm.Hide;

		finally
		FileLoadForm.Release;
		FileLoadForm:= nil;
		end;
	end;

procedure TXSIDToMIDIMainForm.DoPrepareMIDIMapping;
	var
	i,
	j: Integer;

	begin
	SetLength(FMIDIMapping, Length(FInstruments));

	for i:= 0 to High(FMIDIMapping) do
		begin
		FMIDIMapping[i].DrumMode:= False;
		FMIDIMapping[i].Channel:= i mod 16;
		FMIDIMapping[i].ExtendForBend:= True;
		FMIDIMapping[i].ChordMode:= False;
		FMIDIMapping[i].PWidthStyle:= mpwSingle;
		FMIDIMapping[i].EffectOutput:= True;

		if  FMIDIMapping[i].Channel = 9 then
			FMIDIMapping[i].Channel:= 0;

		FMIDIMapping[i].Name:= AnsiString(Format('%2.2d', [FMIDIMapping[i].Channel + 1]));

		for j:= 0 to High(FMIDIMapping[i].NoteMap) do
			if  FInstruments[i].UsedNotes[j] then
				begin
//				FMIDIMapping[i].NoteMap[j].Source:= j;
				FMIDIMapping[i].NoteMap[j]:= j;
				end
			else
				begin
//				FMIDIMapping[i].NoteMap[j].Source:= -1;
				FMIDIMapping[i].NoteMap[j]:= -1;
				end;
		end;
	end;

procedure TXSIDToMIDIMainForm.DoPrepareSMF(var ASMF: TSMFFile);
	var
	ev: PSMFMTev;
	d: array of Byte;
	trk: PSMFMTrk;

	begin
	FBPM:= Round(60000000 / StrToFloat(Edit2.Text));
	FPPQN:= StrToInt(Edit3.Text);

	InitialiseSMFFile(ASMF);

	ASMF.HeaderChunk^.Division:= FPPQN;

	trk:= ASMF.TrackChunks;
	trk^.Len:= 0;
	ev:= nil;

	SetLength(d, 5);
	d[0]:= $51;
	d[1]:= $03;
	d[2]:= (FBPM and $FF0000) shr 16;
	d[3]:= (FBPM and $FF00) shr 8;
	d[4]:= (FBPM and $FF);
	DoAddNewMIDIEvent(0, mefSystem, $0F, d, ev, trk);

	SetLength(d, 6);
	d[0]:= $58;
	d[1]:= $04;
	d[2]:= StrToInt(Edit4.Text);
	d[3]:= ComboBox1.ItemIndex + 1;
	d[4]:= $18;
	d[5]:= $08;
	DoAddNewMIDIEvent(0, mefSystem, $0F, d, ev, trk);

	SetLength(d, 2);
	d[0]:= $2F;
	d[1]:= $00;
	DoAddNewMIDIEvent(0, mefSystem, $0F, d, ev, trk);

	ASMF.HeaderChunk^.NumTrks:= 1;
	end;

procedure TXSIDToMIDIMainForm.DoStartDump;
	var
	idx: TDumpIndex;
	avl: TDumpIndex;

	procedure PrepareForDump(const AIdx, ASlt: TDumpIndex);
		var
		events: TList;
		p: string;

		begin
		if  FDumpData[ASlt].ID > -128 then
			FDumpData[ASlt].XSIDEvents.ClearEvents(FDumpData[ASlt].ID > -2);

		FDumpData[ASlt].ID:= Ord(AIdx) - 2;
		FDumpData[ASlt].DumpIndex:= AIdx;
		FDumpData[ASlt].ProgIndex:= ASlt;

//		FDumpData[ASlt].XSIDConfig:= TXSIDConfig.Create;
//		FDumpData[ASlt].XSIDConfig.Assign(FDumpConfig);
//
//		FDumpData[ASlt].XSIDEvents:= TXSIDEventManager.Create;
//		FDumpData[ASlt].XSIDConfig.Renderer:= GlobalRenderers.Items[0].GetName;

		p:= IncludeTrailingPathDelimiter(ButtonedEdit2.Text);

		events:= TList.Create;
		try
			if  FDumpData[ASlt].ID = -1 then
				FDumpData[ASlt].Size:= DoDumpFiltEvents(events)
			else if FDumpData[ASlt].ID >= 0 then
				FDumpData[ASlt].Size:= DoDumpInsEvents(FDumpData[ASlt].ID, events);

			FDumpData[ASlt].XSIDConfig.GetRenderParams.Clear;
			if  FDumpData[ASlt].ID = -2 then
				begin
				FDumpData[ASlt].Size:= FSongSize;
				FDumpData[ASlt].XSIDConfig.GetRenderParams.Add('File Name=' + p + 'song.wav');
				DumpProgressForm.SubProgressText[ASlt].Caption:= 'Song:';
				end
			else if  FDumpData[ASlt].ID = -1 then
				begin
				FDumpData[ASlt].XSIDConfig.GetRenderParams.Add('File Name=' + p + 'filt.wav');
				DumpProgressForm.SubProgressText[ASlt].Caption:= 'Filt./Mix:';
				end
			else
				begin
				FDumpData[ASlt].XSIDConfig.GetRenderParams.Add('File Name=' + p + 'ins' +
						Format('%2.2d', [FDumpData[ASlt].ID + 1]) + '.wav');
				DumpProgressForm.SubProgressText[ASlt].Caption:= 'Ins. ' +
						IntToStr(FDumpData[ASlt].ID + 1) + ':';
				end;

			DumpProgressForm.SubProgressBar[ASlt].Min:= 0;
			DumpProgressForm.SubProgressBar[ASlt].Max:= FDumpData[ASlt].Size;

			if  FDumpData[ASlt].ID = -2 then
				FDumpData[ASlt].XSIDEvents.CopyEvents(FEventsList)
			else
				FDumpData[ASlt].XSIDEvents.CopyEvents(events);

			FDumpData[ASlt].Ticks:= 0;

			FDumpData[ASlt].XSIDConfig.Started:= False;
			FDumpData[ASlt].XSIDConfig.Changed:= False;

			FDumpData[ASlt].XSIDThread:= TXSIDThread.Create(
					FDumpData[ASlt].XSIDConfig, DumpCallback, FDumpData[ASlt].ID,
					FDumpData[ASlt].XSIDEvents);
			finally
			events.Free;
			end;
		end;

	begin
	FDumpProc:= True;

	for idx:= 0 to High(TDumpIndex) do
		if  idx in FDumpIndexes then
			for avl:= 0 to TDumpIndex(FDumpSlots - 1) do
				if  avl in FDumpAvail then
					begin
					PrepareForDump(idx, avl);
					Exclude(FDumpAvail, avl);
					Exclude(FDumpIndexes, idx);
					Break;
					end;
	end;

procedure TXSIDToMIDIMainForm.DumpCallback(const AID: Integer;
		const AStats: TXSIDStats);
	var
	wn: Boolean;
	slt: Integer;

	begin
	wn:= False;

	slt:= 0;
	while slt < FDumpSlots do
		begin
		if  FDumpProc
		and (AID = FDumpData[slt].ID) then
			Break;

		Inc(slt);
		end;

	if  slt < FDumpSlots then
		begin
		Inc(FDumpData[slt].Ticks, Cardinal(AStats.ThsTick));
		if  Assigned(DumpProgressForm) then
			begin
			DumpProgressForm.SubProgressBar[slt].Position:= FDumpData[slt].Ticks;
			Application.ProcessMessages;
			end;

		if  (FDumpCount > 0)
		and (FDumpData[slt].Ticks > FDumpData[slt].Size) then
			begin
			Dec(FDumpCount);
			if  Assigned(DumpProgressForm) then
				begin
				DumpProgressForm.ProgressBar1.Position:=
						DumpProgressForm.ProgressBar1.Position + 1;
				DumpProgressForm.SubProgressBar[slt].Position:= 0;

				Taskbar1.ProgressValue:= Taskbar1.ProgressValue + 1;

				Application.ProcessMessages;
				end;

			wn:= True;
			end;
		end;

	if  FDumpProc
	and (FDumpAbort
	or   (FDumpCount = 0)) then
		begin
		PostMessage(Self.Handle, UM_DUMPEND, 0, 0);
		wn:= False;
		end;

	if  FDumpProc
	and wn then
		begin
		FDumpData[slt].ID:= -128;
		PostMessage(Self.Handle, UM_DUMPNEXT, 0, slt);
		end;
	end;

procedure TXSIDToMIDIMainForm.DumpEnd(var AMsg: TMessage);
	var
	slt: Integer;

	begin
	FDumpProc:= False;
	FDumpAbort:= False;

	Taskbar1.ProgressState:= TTaskBarProgressState.None;
	Taskbar1.ProgressValue:= 0;

//	DumpProgressForm.Hide;
	DumpProgressForm.Release;
	DumpProgressForm:= nil;

	for slt:= 0 to FDumpSlots - 1 do
		if  Assigned(FDumpData[slt].XSIDThread) then
			begin
			if  FDumpData[slt].ID > -128 then
				FDumpData[slt].XSIDEvents.ClearEvents(FDumpData[slt].ID > -2);

			FDumpData[slt].ID:= -128;

			FDumpData[slt].XSIDThread.RunSignal.ResetEvent;
			FDumpData[slt].XSIDThread.PausedSignal.WaitFor;
			FDumpData[slt].XSIDThread.Terminate;

			FDumpData[slt].XSIDEvents.Free;
			FDumpData[slt].XSIDConfig.Free;
			end;
	end;

procedure TXSIDToMIDIMainForm.DumpNext(var AMsg: TMessage);
	var
	slt: Integer;

	begin
//	FDumpProc:= False;
	FDumpAbort:= False;

	slt:= AMsg.LParam;

	if  Assigned(FDumpData[slt].XSIDThread) then
		begin
		FDumpData[slt].XSIDThread.RunSignal.ResetEvent;
		FDumpData[slt].XSIDThread.PausedSignal.WaitFor;
		FDumpData[slt].XSIDThread.Terminate;
//		FDumpData[slt].XSIDThread.WaitFor;
//		FDumpData[slt].XSIDThread.Free;
		FDumpData[slt].XSIDThread:= nil;

		FDumpData[slt].XSIDEvents.ClearEvents(FDumpData[slt].DumpIndex > 0);

//		FDumpData[slt].XSIDEvents.Free;
//		FDumpData[slt].XSIDConfig.Free;
		end;

	Include(FDumpAvail, TDumpIndex(slt));
	Exclude(FDumpIndexes, FDumpData[slt].DumpIndex);

	DumpProgressForm.SubProgressText[slt].Caption:= '';
	DumpProgressForm.SubProgressBar[slt].Position:= 0;

	DoStartDump;
	end;

procedure TXSIDToMIDIMainForm.FindOrInsertInstrument(
			const AInstrument: TSIDInstrument; const ANoteDuration: Cardinal;
			const ANoteMod: TSIDNoteModulation);
	var
	i,
	j,
	k: Integer;
	t,
	n: Cardinal;
	m: Boolean;
	bcur,
	bmax,
	nonc,
	ntsc: Word;

	function  CompareOffsets(const AA, AB: Cardinal): Boolean;
		var
		m,
		h,
		l: Cardinal;

		begin
		Result:= False;

		m:= AA;
		if  AB > m then
			m:= AB;

//todo  Make this amount (+-30% configurable)
		l:= Round(m - m * 0.30);
		h:= Round(m + m * 0.30);

		if  (AB >= l)
		and (AB <= h)
		and (AA >= l)
		and (AA <= h) then
			Result:= True;
		end;

	begin
	if  AInstrument.Valid then
		begin
		i:= 0;
		while i <= High(FInstruments) do
			begin
			m:= False;

			if  (FInstruments[i].Voice = AInstrument.Voice)
			and (FInstruments[i].Attack = AInstrument.Attack)
			and (FInstruments[i].Decay = AInstrument.Decay)
			and (FInstruments[i].Release = AInstrument.Release) then
				m:= True;

			if  m then
				begin
				j:= 0;
				k:= 1;
				while j < Length(FInstruments[i].WaveformMap) do
					begin
					if  High(FInstruments[i].WaveformMap) > j then
						n:= FInstruments[i].WaveformMap[k].Offset
					else
						n:= ANoteDuration;

					t:= n;
					if  t >= ANoteDuration then
						Break;

					Inc(k);
					Inc(j);
					end;

				if  Length(AInstrument.WaveformMap) >= k then
					begin
					j:= 0;
					while  j < k do
						begin
						if  (AInstrument.WaveformMap[j].Waveform <>
								FInstruments[i].WaveformMap[j].Waveform)
						or  not CompareOffsets(AInstrument.WaveformMap[j].Offset,
								FInstruments[i].WaveformMap[j].Offset) then
							begin
							m:= False;
							Break;
							end;

						Inc(j);
						end;
					end;
				end;

			if  m then
				begin
				j:= 0;
				k:= 1;
				while j < Length(FInstruments[i].EffectMap) do
					begin
					if  High(FInstruments[i].EffectMap) > j then
						n:= FInstruments[i].EffectMap[k].Offset
					else
						n:= ANoteDuration;

					t:= n;
					if  t >= ANoteDuration then
						Break;

					Inc(k);
					Inc(j);
					end;

				if  Length(AInstrument.EffectMap) >= k then
					begin
					j:= 0;
					while  j < k do
						begin
						if  (AInstrument.EffectMap[j].Effect <>
								FInstruments[i].EffectMap[j].Effect)
						or  not CompareOffsets(AInstrument.EffectMap[j].Offset,
								FInstruments[i].EffectMap[j].Offset) then
							begin
							m:= False;
							Break;
							end;

						Inc(j);
						end;
					end;
				end;

			if  m then
				Break;

			Inc(i);
			end;

		if  i > High(FInstruments) then
			begin
			SetLength(FInstruments, Length(FInstruments) + 1);
			FInstruments[High(FInstruments)]:= AInstrument;

			SetLength(FSongRecompose, Length(FSongRecompose) + 1);
			end;

		if  Length(ANoteMod.PitchMap) > 0 then
			begin
			if  not FInstruments[i].UsedNotes[ANoteMod.PitchMap[0].Note] then
				begin
				Inc(FInstruments[i].NotesCount);
				FInstruments[i].UsedNotes[ANoteMod.PitchMap[0].Note]:= True;
				end;

//			for j:= 0 to High(FInstruments[i].UsedNotes) do
//				if  AInstrument.UsedNotes[j] then
//					begin
//					if  not FInstruments[i].UsedNotes[j] then
//						Inc(FInstruments[i].NotesCount);
//
//					FInstruments[i].UsedNotes[j]:= True;
//					end;
			end;

		Inc(FInstruments[i].HitCount);

		if  Length(AInstrument.WaveformMap) > Length(FInstruments[i].WaveformMap) then
			begin
//			FInstruments[i].WaveformMap:= AInstrument.WaveformMap;

			k:= Length(FInstruments[i].WaveformMap);
			SetLength(FInstruments[i].WaveformMap, Length(AInstrument.WaveformMap));
			for j:= k to High(FInstruments[i].WaveformMap) do
				FInstruments[i].WaveformMap[j]:= AInstrument.WaveformMap[j];
			end;

		if  Length(AInstrument.EffectMap) > Length(FInstruments[i].EffectMap) then
			begin
//			FInstruments[i].EffectMap:= AInstrument.EffectMap;

			k:= Length(FInstruments[i].EffectMap);
			SetLength(FInstruments[i].EffectMap, Length(AInstrument.EffectMap));
			for j:= k to High(FInstruments[i].EffectMap) do
				FInstruments[i].EffectMap[j]:= AInstrument.EffectMap[j];
			end;

		if  FInstruments[i].MaxDuration < ANoteDuration then
			FInstruments[i].MaxDuration:= ANoteDuration;

		SetLength(FSongRecompose[i], Length(FSongRecompose[i]) + 1);
		FSongRecompose[i, High(FSongRecompose[i])]:= ANoteMod;

		if  ANoteMod.PitchMap[0].Note > -1 then
			begin
			bmax:= 0;
			nonc:= ANoteMod.PitchMap[0].Note * 100 + ANoteMod.PitchMap[0].Cents;

			for j:= 1 to High(ANoteMod.PitchMap) do
				begin
				ntsc:= ANoteMod.PitchMap[j].Note * 100 + ANoteMod.PitchMap[j].Cents;

				if  ntsc > nonc then
					begin
					if  (ntsc - nonc) > bmax then
						bmax:= ntsc - nonc
					end
				else
					if  (nonc - ntsc) > bmax then
						bmax:= nonc - ntsc;
				end;

			if  FInstruments[i].BendRangeNotes = -1 then
				bcur:= 0
			else
				bcur:= FInstruments[i].BendRangeNotes * 100 +
						FInstruments[i].BendRangeCents;

			if  bmax >= bcur then
				begin
				FInstruments[i].BendRangeNotes:= bmax div 100;
				FInstruments[i].BendRangeCents:= bmax -
						FInstruments[i].BendRangeNotes * 100;

				bmax:= FInstruments[i].BendRangeNotes * 100;
				if  FInstruments[i].BendRangeCents > 0 then
					Inc(bmax, 100);

				if  bmax > 2400 then
					bmax:= 2400;

				if  bmax < 200 then
                    bmax:= 200;

				FInstruments[i].BendRange:= bmax;
				end;
			end;
		end;
	end;

procedure TXSIDToMIDIMainForm.FormCreate(Sender: TObject);
	begin
	InitialiseConfig(ChangeFileExt(Application.ExeName, '.ini'));
	FDumpConfig:= TXSIDConfig.Create(nil);

    ButtonedEdit2.Text:= TPath.GetDirectoryName(Application.ExeName);
	end;

procedure TXSIDToMIDIMainForm.FormDestroy(Sender: TObject);
	begin
	FDumpConfig.Free;
	FinaliseConfig(ChangeFileExt(Application.ExeName, '.ini'));
	end;

procedure TXSIDToMIDIMainForm.LoadCallback(const AStage: TXSIDFileStage;
		const APosition, ASize: Int64);
	begin
	if  AStage = rfsPrepare then
		begin
		FileLoadForm.ProgressBar1.Style:= pbstNormal;
		FileLoadForm.ProgressBar1.Min:= 0;
		FileLoadForm.ProgressBar1.Max:= ASize - 1;
		FileLoadForm.ProgressBar1.Position:= APosition;
		end
	else if  AStage = rfsLoad then
		FileLoadForm.ProgressBar1.Position:= APosition
	else if  (AStage = rfsInitialise)
	and (APosition > -1) then
		begin
		FileLoadForm.Label1.Caption:= 'Initialising';
		FileLoadForm.ProgressBar1.Style:= pbstMarquee;
		end;

	Application.ProcessMessages;
	end;

procedure TXSIDToMIDIMainForm.vstInstrumentsDblClick(Sender: TObject);
	begin
    Button8Click(Sender);
	end;

procedure TXSIDToMIDIMainForm.vstInstrumentsGetText(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
		var CellText: string);
	var
	i: Integer;
	s: string;

	function WaveformsToString(const AWaveforms: TSIDWaveformTypes): string;
		begin
		if  AWaveforms = [] then
			Result:= '[]'
		else
			Result:= '';

		if  swtTest in AWaveforms then
            Result:= Result + 'x';

		if  swtTriangle in AWaveforms then
			Result:= Result + 'T';
		if  swtSawtooth in AWaveforms then
			Result:= Result + 'S';
		if  swtPulse in AWaveforms then
			Result:= Result + 'P';
		if  swtNoise in AWaveforms then
			Result:= Result + 'N';
		end;

	function EffectsToString(const AEffects: TSIDEffectTypes): string;
		begin
		if  AEffects = [] then
			Result:= '[]'
		else
			Result:= '';

		if  setSync in AEffects then
			Result:= Result + 'S';
		if  setRing in AEffects then
			Result:= Result + 'R';
		end;

	begin
	case Column of
		0:
			CellText:= IntToStr(Node^.Index + 1);
		1:
            CellText:= string(FMIDIMapping[Node^.Index].Name);
		2:
			CellText:= IntToStr(FInstruments[Node^.Index].Voice + 1);
		3:
			CellText:= IntToStr(FInstruments[Node^.Index].Attack);
		4:
			CellText:= IntToStr(FInstruments[Node^.Index].Decay);
		5:
			CellText:= IntToStr(FInstruments[Node^.Index].Release);
		6:
			begin
			s:= WaveformsToString(FInstruments[Node^.Index].WaveformMap[0].Waveform);
			i:= 1;
			while  i < Length(FInstruments[Node^.Index].WaveformMap) do
				begin
				s:= s + ', ' + WaveformsToString(
						FInstruments[Node^.Index].WaveformMap[i].Waveform) +
						'(' + IntToStr(FInstruments[Node^.Index].WaveformMap[i].Offset) + ')';
				Inc(i);
				end;

			CellText:= s;
			end;
		7:
			begin
			s:= EffectsToString(FInstruments[Node^.Index].EffectMap[0].Effect);
			i:= 1;
			while  i < Length(FInstruments[Node^.Index].EffectMap) do
				begin
				s:= s + ', ' + EffectsToString(
						FInstruments[Node^.Index].EffectMap[i].Effect) +
						'(' + IntToStr(FInstruments[Node^.Index].EffectMap[i].Offset) + ')';
				Inc(i);
				end;

			CellText:= s;
			end;
		8:
			CellText:= IntToStr(FInstruments[Node^.Index].HitCount);
		9:
			CellText:= IntToStr(FInstruments[Node^.Index].NotesCount);
		10:
			CellText:= Format('%d.%2.2d', [FInstruments[Node^.Index].BendRangeNotes,
					FInstruments[Node^.Index].BendRangeCents]);
		else
			CellText:= '';
		end;
	end;

end.
