//------------------------------------------------------------------------------
//MIDIToSIDClasses
//================
//Class declarations for the MIDI To SID application.
//
//
//Copyright (C) 2017, Daniel England.
//All Rights Reserved.  Released under the GPL.
//
//This program is free software: you can redistribute it and/or modify it under
//the terms of the GNU General Public License as published by the Free Software
//Foundation, either version 3 of the License, or (at your option) any later
//version.
//
//This program is distributed in the hope that it will be useful, but WITHOUT
//ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//details.
//
//You should have received a copy of the GNU General Public License along with
//this program.  If not, see <http://www.gnu.org/licenses/>.
//
//------------------------------------------------------------------------------
unit MIDIToSIDClasses;

interface

uses
	Generics.Collections, XML.XMLIntf, XML.XMLDoc, SMFTypes, MIDIToSIDTypes, Forms;

type
	TMIDIToSIDProject = class;

	TMIDIToSIDConvertor = class(TObject)
	public
		class function  GetName: string; virtual; abstract;

		procedure Configure; virtual; abstract;

		procedure Initialise(const AProject: TMIDIToSIDProject); virtual; abstract;
		procedure Finalise; virtual; abstract;

		procedure ProcessEvent(const AEvent: PSMFMTev); virtual; abstract;
	end;

	TMIDIToSIDConvertorClass = class of TMIDIToSIDConvertor;

	TSIDPatchBand = class;

	TSIDPatch = record
	private
		FBands: array of TSIDPatchBand;
	public
		Default: Boolean;
		Name: string;
		Attack,
		Decay,
		Sustain,
		Release: TNybble;
		Waveforms: TSIDWaveforms;
		Effects: TSIDEffects;
		PulseWidth: TSIDPWidth;
		Filter: Boolean;
		NtOnHardSync: Boolean;

		procedure Initialise(const AName: string);
		procedure Finalise;
		procedure Assign(APatch: TSIDPatch);

		function  BandByIndex(const AIndex: Integer): TSIDPatchBand;
		function  BandByName(const AName: string): TSIDPatchBand;
		function  BandCount: Integer;

		procedure SaveToXML(const ADoc: IXMLDocument; const ANode: IXMLNode);
		procedure LoadFromXML(const ANode: IXMLNode);
	end;

	TSIDPatches = array[TMIDISmall] of TSIDPatch;

	TFrameClass = class of TFrame;

	TSIDPatchBand = class(TObject)
	public
		class function  GetName: string; virtual; abstract;
		class function  GetFrame: TFrameClass; virtual; abstract;

		procedure Initialise(const APatch: TSIDPatch); virtual; abstract;
		procedure Finalise(const APatch: TSIDPatch); virtual; abstract;
		procedure Assign(const APatch: TSIDPatch); virtual; abstract;

		procedure SaveToXML(const ADoc: IXMLDocument;
				const ANode: IXMLNode); virtual; abstract;
		procedure LoadFromXML(const ANode: IXMLNode); virtual; abstract;
	end;

	TSIDPatchBandClass = class of TSIDPatchBand;

	TMIDIToSIDProject = class(TObject)
	protected
		procedure DoFullInit;

	public
		Dirty,
		HasSaved: Boolean;
		ProjFileName,
		SMFFileName: string;
		SMF: PSMF;
		SIDPatches: TSIDPatches;
		SIDChannelMap: TSIDChannelMap;
		ConvertorClass: TMIDIToSIDConvertorClass;

		MIDIChannelInfo: TMIDIChannelInfos;
		MIDICurrentTempo: Cardinal;

		constructor Create;
		destructor  Destroy; override;

		procedure InitialiseMIDIChannelInfo;
		procedure SaveToXML;
		procedure LoadFromXML(const AFileName: string);
	end;


	procedure RegisterConvertorClass(const AClass: TMIDIToSIDConvertorClass);
	procedure RegisterPatchBandClass(const AClass: TSIDPatchBandClass);

	procedure ProcessSMF(const AProject: TMIDIToSIDProject);

var
	ConvertorClasses: TList<TMIDIToSIDConvertorClass>;
	PatchBandClasses: TList<TSIDPatchBandClass>;


implementation


uses
	SysUtils;


procedure RegisterConvertorClass(const AClass: TMIDIToSIDConvertorClass);
	begin
	if  ConvertorClasses.IndexOf(AClass) = -1 then
		ConvertorClasses.Add(AClass);
	end;

procedure RegisterPatchBandClass(const AClass: TSIDPatchBandClass);
	begin
	if  PatchBandClasses.IndexOf(AClass) = -1 then
		PatchBandClasses.Add(AClass);
	end;

procedure ProcessSMF(const AProject: TMIDIToSIDProject);
	var
	proc: TMIDIToSIDConvertor;
	trk: PSMFMTrk;
	evt: PSMFMTev;
//	i: Integer;

	procedure DoProcessTempoEvent(const AEvent: PSMFMTev);
		var
		t: Cardinal;

		begin
		if  AEvent^.Data[2] = $03 then
			begin
			t:= AEvent^.Data[3] shl 16;
			t:= t or AEvent^.Data[4] shl 8;
			t:= t or AEvent^.Data[5];

			AProject.MIDICurrentTempo:= t;
			end;
		end;

	begin
	proc:= AProject.ConvertorClass.Create;
	try
		proc.Initialise(AProject);

		trk:= PSMFMTrk(AProject.SMF^.First^.Next^.Data);

//		i:= 0;
		evt:= trk^.First;
		while  Assigned(evt) do
			begin
			if  evt^.Family = sefSystem then
				if  (evt^.Data[0] = $FF)
				and (evt^.Data[1] = $51) then
					DoProcessTempoEvent(evt);

			proc.ProcessEvent(evt);
			evt:= evt^.Next;
//			Inc(i);
			end;

		proc.Finalise;

		finally
		proc.Free;
		end;
	end;


{ TSIDPatch }

procedure TSIDPatch.Assign(APatch: TSIDPatch);
	var
	i: Integer;

	begin
    Default:= APatch.Default;
	Name:= APatch.Name;
	Attack:= APatch.Attack;
	Decay:= APatch.Decay;
	Sustain:= APatch.Sustain;
	Release:= APatch.Release;
	Waveforms:= APatch.Waveforms;
	Effects:= APatch.Effects;
	PulseWidth:= APatch.PulseWidth;
	Filter:= APatch.Filter;
	NtOnHardSync:= APatch.NtOnHardSync;

	for i:= 0 to High(FBands) do
		FBands[i].Assign(APatch);
	end;

function TSIDPatch.BandByIndex(const AIndex: Integer): TSIDPatchBand;
	begin
	Result:= FBands[AIndex];
	end;

function TSIDPatch.BandByName(const AName: string): TSIDPatchBand;
	var
	i: Integer;

	begin
	Result:= nil;
	for i:= 0 to High(FBands) do
		if  FBands[i].GetName = AName then
			begin
			Result:= FBands[i];
			Break;
			end;
	end;

function TSIDPatch.BandCount: Integer;
	begin
	Result:= Length(FBands);
	end;

procedure TSIDPatch.Finalise;
	var
	i: Integer;

	begin
	for i:= PatchBandClasses.Count - 1 downto 0 do
		begin
		FBands[i].Finalise(Self);
		FBands[i].Free;
		end;

	SetLength(FBands, 0);
	end;

procedure TSIDPatch.Initialise(const AName: string);
	var
	i: Integer;
	n: Boolean;

	begin
	Default:= True;
	Name:= AName;
	Attack:= 1;
	Decay:= 3;
	Sustain:= 12;
	Release:= 9;
	Waveforms:= [swvSaw];
	Effects:= [];
	PulseWidth:= 0;
	Filter:= False;
	NtOnHardSync:= True;

	n:= Length(FBands) = 0;
	if  n then
		SetLength(FBands, PatchBandClasses.Count);

	for i:= 0 to PatchBandClasses.Count - 1 do
		begin
		if  n then
			FBands[i]:= PatchBandClasses[i].Create;

		FBands[i].Initialise(Self);
		end;
	end;

procedure TSIDPatch.LoadFromXML(const ANode: IXMLNode);
	var
	i: Integer;
	d: Byte;
	w: TSIDWaveform;
	e: TSIDEffect;
	cn,
	en: IXMLNode;
	b: TSIDPatchBand;

	begin
	Name:= ANode.Attributes['name'];

	Attack:= ANode.ChildNodes.FindNode('attack').NodeValue;
	Decay:= ANode.ChildNodes.FindNode('decay').NodeValue;
	Sustain:= ANode.ChildNodes.FindNode('sustain').NodeValue;
	Release:= ANode.ChildNodes.FindNode('release').NodeValue;

	i:= 1;
	d:= ANode.ChildNodes.FindNode('waveforms').NodeValue;
	for w:= Low(TSIDWaveform) to High(TSIDWaveform) do
		begin
		if  (d and i) <> 0 then
			Include(Waveforms, w)
		else
			Exclude(Waveforms, w);

		i:= i shl 1;
		end;

	i:= 1;
	d:= ANode.ChildNodes.FindNode('effects').NodeValue;
	for e:= Low(TSIDEffect) to High(TSIDEffect) do
		begin
		if  (d and i) <> 0 then
			Include(Effects, e)
		else
			Exclude(Effects, e);

		i:= i shl 1;
		end;

	PulseWidth:= ANode.ChildNodes.FindNode('pulsewidth').NodeValue;
	Filter:= ANode.ChildNodes.FindNode('filter').NodeValue;
	NtOnHardSync:= ANode.ChildNodes.FindNode('ntonhsync').NodeValue;

	cn:= ANode.ChildNodes.FindNode('bands');
	for i:= 0 to cn.ChildNodes.Count - 1 do
		begin
		en:= cn.ChildNodes[i];

		b:= BandByName(en.Attributes['name']);
		b.LoadFromXML(en);
		end;
	end;

procedure TSIDPatch.SaveToXML(const ADoc: IXMLDocument; const ANode: IXMLNode);
	var
	i: Integer;
	d: Byte;
	w: TSIDWaveform;
	e: TSIDEffect;
	cn,
	en: IXMLNode;

	procedure DoAddNode(const ANodeName: string; const ANodeValue: OLEVariant);
		begin
		en:= ADoc.CreateElement(ANodeName, '');
		en.NodeValue:= ANodeValue;
		ANode.ChildNodes.Add(en);
		end;

	begin
	ANode.SetAttribute('name', Name);

	DoAddNode('attack', Attack);
	DoAddNode('decay', Decay);
	DoAddNode('sustain', Sustain);
	DoAddNode('release', Release);

	i:= 1;
	d:= 0;
	for w:= Low(TSIDWaveform) to High(TSIDWaveform) do
		begin
		if  w in Waveforms then
			d:= d or i;

		i:= i shl 1;
		end;

	DoAddNode('waveforms', d);

	i:= 1;
	d:= 0;
	for e:= Low(TSIDEffect) to High(TSIDEffect) do
		begin
		if  e in Effects then
			d:= d or i;

		i:= i shl 1;
		end;

	DoAddNode('effects', d);

	DoAddNode('pulsewidth', PulseWidth);
	DoAddNode('filter', Filter);
	DoAddNode('ntonhsync', NtOnHardSync);

	cn:= ADoc.CreateElement('bands', '');

	for i:= 0 to High(FBands) do
		begin
		en:= ADoc.CreateElement('band', '');
		en.SetAttribute('name', FBands[i].GetName);

		FBands[i].SaveToXML(ADoc, en);

		cn.ChildNodes.Add(en);
		end;

	ANode.ChildNodes.Add(cn);
	end;


{ TMIDIToSIDProject }

constructor TMIDIToSIDProject.Create;
	begin
	inherited Create;

	DoFullInit;
	end;

destructor TMIDIToSIDProject.Destroy;
	var
	i: Integer;

	begin
	if  Assigned(SMF) then
		DisposeSMF(SMF);

	for i:= 0 to High(SIDPatches) do
		SIDPatches[i].Finalise;

	inherited;
	end;

procedure TMIDIToSIDProject.DoFullInit;
	var
	i: Integer;

	begin
	for i:= Low(TSIDChannelMap) to High(TSIDChannelMap) do
		SIDChannelMap[i]:= TSIDVoice(((i - 1) mod 3) + 1);

	for i:= Low(TSIDPatches) to High(TSIDPatches) do
		SIDPatches[i].Initialise(IntToHex(i, 2));

	InitialiseMIDIChannelInfo;

	ConvertorClass:= ConvertorClasses[0];

	ProjFileName:= EmptyStr;
	SMFFileName:= EmptyStr;

	if  Assigned(SMF) then
		DisposeSMF(SMF);

	Dirty:= False;
	HasSaved:= False;
	end;

procedure TMIDIToSIDProject.InitialiseMIDIChannelInfo;
	var
	i: Integer;

	begin
	for i:= Low(TMIDIChannelInfos) to High(TMIDIChannelInfos) do
		MIDIChannelInfo[i].Initialise;

	MIDICurrentTempo:= 500000;
	end;

procedure TMIDIToSIDProject.LoadFromXML(const AFileName: string);
	var
	i,
	idx: Integer;
	s: string;
	doc: IXMLDocument;
	rn,
	cn,
	en: IXMLNode;

	begin
	doc:= TXMLDocument.Create(nil);
	try
		doc.LoadFromFile(AFileName);

		doc.Active:= True;

		rn:= doc.ChildNodes[0];
		if  rn.NodeName <> 'MIDIToSID' then
			raise Exception.Create('Invalid MIDI To SID Project File.');

		DoFullInit;

		ProjFileName:= AFileName;
        HasSaved:= True;

		cn:= rn.ChildNodes.FindNode('smf');
		SMFFileName:= cn.NodeValue;

		cn:= rn.ChildNodes.FindNode('sidpatches');
		for i:= 0 to cn.ChildNodes.Count - 1 do
			begin
			en:= cn.ChildNodes[i];
			idx:= en.Attributes['index'];

			SIDPatches[idx].LoadFromXML(en);
			end;

		cn:= rn.ChildNodes.FindNode('channelmap');
		for i:= 0 to High(SIDChannelMap) do
			begin
			en:= cn.ChildNodes[i];
			SIDChannelMap[i]:= en.NodeValue;
			end;

		cn:= rn.ChildNodes.FindNode('convertor');
		s:= cn.NodeValue;
		ConvertorClass:= nil;
		for i:= 0 to ConvertorClasses.Count - 1 do
			if  ConvertorClasses[i].GetName = s then
				begin
				ConvertorClass:= ConvertorClasses[i];
				Break;
				end;

		doc.Active:= False;

		finally
		doc:= nil;
		end;
	end;

procedure TMIDIToSIDProject.SaveToXML;
	var
	i: Integer;
	doc: IXMLDocument;
	rn,
	cn,
	en: IXMLNode;

	begin
	doc:= TXMLDocument.Create(nil);
	try
		doc.Active:= True;

		rn:= doc.CreateElement('MIDIToSID', '');
		rn.SetAttribute('version', '0.0');
		doc.ChildNodes.Add(rn);

		cn:= doc.CreateElement('smf', '');
		cn.NodeValue:= SMFFileName;
		rn.ChildNodes.Add(cn);

		cn:= doc.CreateElement('sidpatches', '');

		for i:= 0 to High(SIDPatches) do
			if  not SIDPatches[i].Default then
				begin
				en:= doc.CreateElement('sidpatch', '');
				en.SetAttribute('index', i);

				SIDPatches[i].SaveToXML(doc, en);

				cn.ChildNodes.Add(en);
				end;
		rn.ChildNodes.Add(cn);

		cn:= doc.CreateElement('channelmap', '');

		for i:= 0 to High(SIDChannelMap) do
			begin
			en:= doc.CreateElement('channel', '');
			en.SetAttribute('index', i);
			en.NodeValue:= SIDChannelMap[i];

			cn.ChildNodes.Add(en);
			end;
		rn.ChildNodes.Add(cn);

		cn:= doc.CreateElement('convertor', '');
		cn.NodeValue:= ConvertorClass.GetName;
		rn.ChildNodes.Add(cn);

		doc.SaveToFile(ProjFileName);
		Dirty:= False;

		doc.Active:= False;

		finally
		doc:= nil;
		end;
	end;


initialization
	ConvertorClasses:= TList<TMIDIToSIDConvertorClass>.Create;
	PatchBandClasses:= TList<TSIDPatchBandClass>.Create;

finalization
	PatchBandClasses.Free;
	ConvertorClasses.Free;

end.
