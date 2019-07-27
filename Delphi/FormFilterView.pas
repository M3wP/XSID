unit FormFilterView;

interface

uses
	Winapi.Windows, Winapi.Messages, System.Types, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	Vcl.ExtCtrls;

type
	TFilterViewForm = class(TForm)
		PaintBox1: TPaintBox;
		ScrollBar1: TScrollBar;
		Panel1: TPanel;
		ComboBox1: TComboBox;
		Label1: TLabel;
		Shape1: TShape;
		procedure PaintBox1Paint(Sender: TObject);
		procedure ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
				var ScrollPos: Integer);
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure ComboBox1Change(Sender: TObject);
		procedure FormResize(Sender: TObject);
	private
		FBuffer: TBitmap;
		FLastIndx: Integer;
	public
		procedure Sync;
		procedure TrackNow(const AInit: Boolean = False);
        procedure TrackStart;
	end;


var
	FilterViewForm: TFilterViewForm;


implementation


{$R *.dfm}

uses
	XSIDTypes, DModXSIDListMain;


const
	ARR_VAL_SIZ_ZOOM: array[0..8] of Single =
			(0.10, 0.25, 0.33333333, 0.50, 0.66666666, 0.75, 1, 2, 4);



{ TFilterViewForm }

procedure TFilterViewForm.ComboBox1Change(Sender: TObject);
	begin
	Sync;
	end;

procedure TFilterViewForm.FormCreate(Sender: TObject);
	begin
	FBuffer:= TBitmap.Create;
	end;

procedure TFilterViewForm.FormDestroy(Sender: TObject);
	begin
	FBuffer.Free;
	end;

procedure TFilterViewForm.FormResize(Sender: TObject);
	begin
	Sync;
	end;

procedure TFilterViewForm.PaintBox1Paint(Sender: TObject);
	type
	TFiltMixFlag = (fmfFILT1, fmfFILT2, fmfFILT3, fmfFILTEX, fmfLP, fmfBP, fmfHP, fmf3OFF);
	TFiltMixFlags = set of TFiltMixFlag;

	const
	ARR_VAL_CLR_FILTMIXON: array[fmfFILT1..fmfFILTEX] of TColor = (
			TColor($0C30CF), TColor($46B46F), TColor($E77884), TColor($10F3FF));
	ARR_VAL_CLR_FILTMIXOFF: array[fmfFILT1..fmfFILTEX] of TColor = (
			TColor($061866), TColor($235937), TColor($733C42), TColor($043D40));

	var
	offs: Integer;
	indx: Integer;
	pixr,
	pixd,
	step,
	cntr,
	taly: Integer;
	zoom,
	maxe: Integer;
	outp: Boolean;
	temp: ShortInt;
	colr,
	volm,
	lvol: Byte;
	mfrq,
	mvol,
	freq,
	fres: Word;
	fmf1,
	fmf0: TFiltMixFlags;

	procedure TestMixMod(var ATally, ACounter: Integer; var AMVol: Word;
			const AIndex: Integer);
		begin
		if  PXSIDEvent(XSIDListMainDMod.Events[AIndex])^.data.reg = $18 then
			begin
//			All bits
			Inc(ATally, PXSIDEvent(XSIDListMainDMod.Events[AIndex])^.data.val);

//			Just volume bits
			Inc(AMVol, PXSIDEvent(XSIDListMainDMod.Events[AIndex])^.data.val and $0F);

			Inc(ACounter);
			end;
		end;

	procedure TestFreqRes(var AFreq, ARes: Word; const AIndex: Integer);
		var
		ev: PXSIDEvent;

		begin
		ev:= PXSIDEvent(XSIDListMainDMod.Events[AIndex]);

		if  ev^.data.reg = $15 then
			AFreq:= (AFreq and $7F8) or (ev^.data.val and $07)
		else if ev^.data.reg = $16 then
			AFreq:= (AFreq and $07) or (ev^.data.val shl 3)
		else if ev^.data.reg = $17 then
			ARes:= ev^.data.val shr 4;
		end;

	procedure TestFlags(var AFMFOn, AFMFOff: TFiltMixFlags; const AIndex: Integer);
		var
		ev: PXSIDEvent;

		begin
		ev:= PXSIDEvent(XSIDListMainDMod.Events[AIndex]);

		if  ev^.data.reg = $17 then
			begin
			if  (ev^.data.val and $01) = 0 then
				Include(AFMFOff, fmfFILT1)
			else
				Include(AFMFOn, fmfFILT1);

			if  (ev^.data.val and $02) = 0 then
				Include(AFMFOff, fmfFILT2)
			else
				Include(AFMFOn, fmfFILT2);

			if  (ev^.data.val and $04) = 0 then
				Include(AFMFOff, fmfFILT3)
			else
				Include(AFMFOn, fmfFILT3);

			if  (ev^.data.val and $08) = 0 then
				Include(AFMFOff, fmfFILTEX)
			else
				Include(AFMFOn, fmfFILTEX);
			end
		else if ev^.data.reg = $18 then
			begin
			if  (ev^.data.val and $10) = 0 then
				Include(AFMFOff, fmfLP)
			else
				Include(AFMFOn, fmfLP);

			if  (ev^.data.val and $20) = 0 then
				Include(AFMFOff, fmfBP)
			else
				Include(AFMFOn, fmfBP);

			if  (ev^.data.val and $40) = 0 then
				Include(AFMFOff, fmfHP)
			else
				Include(AFMFOn, fmfHP);

			if  (ev^.data.val and $80) = 0 then
				Include(AFMFOff, fmf3OFF)
			else
				Include(AFMFOn, fmf3OFF);
			end;
		end;

	procedure ProcEvent(var ATally: Integer; var AMVol: Word; var ACounter: Integer;
			var AFreq: Word; var ARes: Word; var AFMFOn, AFMFOff: TFiltMixFlags;
			var AIndex: Integer);
		begin
		TestMixMod(ATally, ACounter, AMVol, AIndex);
		TestFreqRes(AFreq, ARes, AIndex);
		TestFlags(AFMFOn, AFMFOff, AIndex);

		Inc(AIndex);
		end;

	procedure ProcessOutput;
		var
		i: Integer;
		f: TFiltMixFlag;

		begin
		freq:= 0;
		fres:= 0;
		lvol:= 0;
		for i:= 0 to indx - 1 do
			begin
			TestFreqRes(freq, fres, i);
			if  PXSIDEvent(XSIDListMainDMod.Events[i])^.data.reg = $18 then
				lvol:= PXSIDEvent(XSIDListMainDMod.Events[i])^.data.val and $0F;
			end;

		step:= 0;
		fmf0:= [];
		fmf1:= [];

		while (offs < PaintBox1.Width) and (indx < maxe) do
			begin
			ProcEvent(taly, mvol, cntr, freq, fres, fmf1, fmf0, indx);
			Inc(step);

			case zoom of
				0:
					outp:= (step = 10) or (indx >= maxe);
				1:
					outp:= (step = 4) or (indx >= maxe);
				2:
					outp:= (step = 3) or (indx >= maxe);
				3:
					outp:= (step = 2) or (indx >= maxe);
				4:
					begin
					if  pixr = 1 then
						begin
						ProcEvent(taly, mvol, cntr, freq, fres, fmf1, fmf0, indx);
						Inc(step);
						pixr:= 0;
						end;

					outp:= True;
					end;
				5:
					begin
					if  pixr = 3 then
						begin
						ProcEvent(taly, mvol, cntr, freq, fres, fmf1, fmf0, indx);
						Inc(step);
						pixr:= 0;
						end;

					outp:= True;
					end;
				else
					begin
					outp:= True;
					pixd:= 1 shl (zoom - 6);
					end;
				end;

			if  outp then
				begin
				if  cntr > 0 then
					begin
					colr:= Trunc(taly / cntr);
					volm:= Trunc(mvol / cntr);
					lvol:= volm;
					end
				else
					begin
					colr:= 0;
					volm:= lvol;
					end;

				mfrq:= ((colr and $0F) * 3 + ((colr and $F0) shr 4)) shl 2;

				temp:= ShortInt(colr);
				if  temp < 0 then
					temp:= temp + 1;

				if  temp <> 0 then
					colr:= Byte(temp + 128)
				else
					colr:= 0;

				Inc(pixd);
				while pixd > 0 do
					begin
					FBuffer.Canvas.Pen.Color:= TColor(colr or (colr shl 8) or (colr shl 16));
					FBuffer.Canvas.Pen.Style:= psSolid;

					temp:= 64 - (mfrq shr 2);

					FBuffer.Canvas.PenPos:= Point(offs, temp);
					FBuffer.Canvas.LineTo(offs, temp + mfrq shr 1);

//					Cheat because its -128 to 127 and we need 128?
					temp:= -(freq shr 4);
					FBuffer.Canvas.Pixels[offs, 127 + temp]:= TColor($0872D1);

					for f:= fmfLP to fmfHP do
						if  f in fmf1 then
							begin
							FBuffer.Canvas.Pixels[offs,
									128 + 15 - ((Ord(f) - Ord(fmfLP)) * 2)]:= TColor($A746B4);
							FBuffer.Canvas.Pixels[offs,
									128 + 14 - ((Ord(f) - Ord(fmfLP)) * 2)]:= TColor($A746B4);
							end
						else if f in fmf0 then
							begin
							FBuffer.Canvas.Pixels[offs,
									128 + 15 - ((Ord(f) - Ord(fmfLP)) * 2)]:= TColor($532359);
							FBuffer.Canvas.Pixels[offs,
									128 + 14 - ((Ord(f) - Ord(fmfLP)) * 2)]:= TColor($532359);
							end;

					if  fmf3OFF in fmf1 then
						begin
						FBuffer.Canvas.Pixels[offs,
								128 + 15 - ((Ord(fmf3OFF) - Ord(fmfLP)) * 2)]:= TColor($10F3FF);
						FBuffer.Canvas.Pixels[offs,
								128 + 14 - ((Ord(fmf3OFF) - Ord(fmfLP)) * 2)]:= TColor($10F3FF);
						end
					else if fmf3OFF in fmf0 then
						begin
						FBuffer.Canvas.Pixels[offs,
								128 + 15 - ((Ord(fmf3OFF) - Ord(fmfLP)) * 2)]:= TColor($087A80);
						FBuffer.Canvas.Pixels[offs,
								128 + 14 - ((Ord(fmf3OFF) - Ord(fmfLP)) * 2)]:= TColor($087A80);
						end;

					FBuffer.Canvas.Pixels[offs, 128 + 15 - fres]:= TColor($0C30CF);

					for f:= fmfFILT1 to fmfFILTEX do
						if  f in fmf1 then
							begin
							FBuffer.Canvas.Pixels[offs,
									144 + 15 - (Ord(f) * 2)]:= ARR_VAL_CLR_FILTMIXON[f];
							FBuffer.Canvas.Pixels[offs,
									144 + 14 - (Ord(f) * 2)]:= ARR_VAL_CLR_FILTMIXON[f];
							end
						else if f in fmf0 then
							begin
							FBuffer.Canvas.Pixels[offs,
									144 + 15 - (Ord(f) * 2)]:= ARR_VAL_CLR_FILTMIXOFF[f];
							FBuffer.Canvas.Pixels[offs,
									144 + 14 - (Ord(f) * 2)]:= ARR_VAL_CLR_FILTMIXOFF[f];
							end;

					FBuffer.Canvas.Pixels[offs, 144 + 15 - volm]:= clWhite;

					Inc(pixr);
					Inc(offs);

					Dec(pixd);
					end;

//				outp:= False;
				step:= 0;
				taly:= 0;
				mvol:= 0;
				cntr:= 0;
				fmf0:= [];
				fmf1:= [];
				end;
			end;
		end;

	begin
	offs:= 0;

	FBuffer.Width:= PaintBox1.Width;
	FBuffer.Height:= PaintBox1.Height;

	if  Assigned(XSIDListMainDMod.Events)
	and (XSIDListMainDMod.Events.Count > 0) then
		begin
		cntr:= 0;
		taly:= 0;
		mvol:= 0;
		pixr:= 0;
		pixd:= 0;
//		outp:= False;
		maxe:= XSIDListMainDMod.Events.Count;
		zoom:= ComboBox1.ItemIndex;

		indx:= Trunc(ScrollBar1.Position * 1 / ARR_VAL_SIZ_ZOOM[zoom]);

		if  FLastIndx <> indx then
			begin
			FBuffer.Canvas.Brush.Color:= clBlack;
			FBuffer.Canvas.Brush.Style:= bsSolid;
			FBuffer.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, 160));

			ProcessOutput;
			FLastIndx:= indx;
			end
		else
			offs:= PaintBox1.Width;
		end
	else
		begin
		FBuffer.Canvas.Brush.Color:= clBlack;
		FBuffer.Canvas.Brush.Style:= bsSolid;
		FBuffer.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, 160));
		end;

	if  offs < PaintBox1.Width then
		begin
		FBuffer.Canvas.Brush.Color:= clBlack;
		FBuffer.Canvas.Brush.Style:= bsSolid;

		FBuffer.Canvas.FillRect(Rect(offs, 0, PaintBox1.Width, PaintBox1.Height));
		end;

	PaintBox1.Canvas.CopyRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height),
			FBuffer.Canvas, Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
	end;

procedure TFilterViewForm.ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
		var ScrollPos: Integer);
	begin
	if  not XSIDListMainDMod.Playing then
		begin
		if  ScrollCode = scPageDown then
			Inc(ScrollPos, PaintBox1.Width)
		else if ScrollCode = scPageUp then
			Dec(ScrollPos, PaintBox1.Width);

		if  not XSIDListMainDMod.Playing then
			TrackStart;

		PaintBox1.Invalidate;
		end;
	end;

procedure TFilterViewForm.Sync;
	begin
	if  not Assigned(XSIDListMainDMod.Events)
	or  (XSIDListMainDMod.Events.Count = 0) then
		begin
		ScrollBar1.PageSize:= 0;
		ScrollBar1.SetParams(0, 0, 0);
		end
	else
		begin
		ScrollBar1.PageSize:= 0;
		ScrollBar1.SetParams(0, 0, Trunc(XSIDListMainDMod.Events.Count *
				ARR_VAL_SIZ_ZOOM[ComboBox1.ItemIndex] - 1));
		ScrollBar1.PageSize:= PaintBox1.Width;
		end;

	FLastIndx:= -1;

	TrackStart;

	PaintBox1.Invalidate;
	end;

procedure TFilterViewForm.TrackNow(const AInit: Boolean);
	var
	zoom,
	sind,
	offs,
	span: Integer;

	begin
	if  AInit then
		begin
		FLastIndx:= -1;
		ScrollBar1.Position:= Trunc(XSIDListMainDMod.NowNode^.Index *
				ARR_VAL_SIZ_ZOOM[ComboBox1.ItemIndex]);
		PaintBox1.Invalidate;
		Shape1.Left:= PaintBox1.Left;
		end
	else
		begin
		zoom:= ComboBox1.ItemIndex;

		sind:= Trunc(ScrollBar1.Position * 1 / ARR_VAL_SIZ_ZOOM[zoom]);
		offs:= Trunc((Integer(XSIDListMainDMod.NowNode^.Index) - sind) * ARR_VAL_SIZ_ZOOM[zoom]);

		if  offs > Trunc(PaintBox1.Width * 0.75) then
			begin
			span:= Trunc(PaintBox1.Width / ARR_VAL_SIZ_ZOOM[zoom] * 0.125);
			sind:= Integer(XSIDListMainDMod.NowNode^.Index) - span;

			FLastIndx:= -1;
			ScrollBar1.Position:= Trunc(sind * ARR_VAL_SIZ_ZOOM[ComboBox1.ItemIndex]);
			PaintBox1.Invalidate;

			sind:= Trunc(ScrollBar1.Position * 1 / ARR_VAL_SIZ_ZOOM[zoom]);
			offs:= Trunc((Integer(XSIDListMainDMod.NowNode^.Index) - sind) * ARR_VAL_SIZ_ZOOM[zoom]);
			end;

		Shape1.Left:= offs;
		end;
	end;

procedure TFilterViewForm.TrackStart;
	var
	zoom,
	sind,
	offs: Integer;

	begin
	if  not XSIDListMainDMod.Playing
	and Assigned(XSIDListMainDMod.StartNode) then
		begin
		zoom:= ComboBox1.ItemIndex;

		sind:= Trunc(ScrollBar1.Position * 1 / ARR_VAL_SIZ_ZOOM[zoom]);
		offs:= Trunc((Integer(XSIDListMainDMod.StartNode^.Index) - sind) * ARR_VAL_SIZ_ZOOM[zoom]);

		if  (offs >= 0)
		or  (offs <= PaintBox1.Width) then
			begin
			Shape1.Visible:= True;
			Shape1.Left:= offs;
			end
		else
			begin
			Shape1.Visible:= False;
			Shape1.Left:= 0;
			end;
		end
	else
		begin
		Shape1.Visible:= False;
		Shape1.Left:= 0;
		end;
	end;
end.
