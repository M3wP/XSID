unit FormXSIDConfig;

{$INCLUDE XSID.inc}

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
	C64Types, XSIDTypes;

type

{ TXSIDConfigForm }

	TXSIDConfigForm = class(TForm)
		Panel1: TPanel;
		Button1: TButton;
		Button2: TButton;
		Button3: TButton;
		Panel2: TPanel;
		Bevel2: TBevel;
		Label2: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		Label12: TLabel;
		Label13: TLabel;
		Label14: TLabel;
		ComboBox3: TComboBox;
		ComboBox4: TComboBox;
		ComboBox5: TComboBox;
		ComboBox6: TComboBox;
		Button5: TButton;
		Edit2: TEdit;
		PnlOverrides: TPanel;
		Label16: TLabel;
		Bevel3: TBevel;
		Label17: TLabel;
		Label18: TLabel;
		Label19: TLabel;
		CheckBox3: TCheckBox;
		CheckBox4: TCheckBox;
		CheckBox5: TCheckBox;
		Panel4: TPanel;
		Bevel1: TBevel;
		Label1: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label9: TLabel;
		Label10: TLabel;
		Label11: TLabel;
		Label5: TLabel;
		Label15: TLabel;
		ComboBox1: TComboBox;
		ComboBox2: TComboBox;
		CheckBox1: TCheckBox;
		CheckBox2: TCheckBox;
		ComboBox7: TComboBox;
		ComboBox8: TComboBox;
		procedure CheckBox1Change(Sender: TObject);
		procedure CheckBox2Change(Sender: TObject);
		procedure ComboBox1Change(Sender: TObject);
		procedure ComboBox2Change(Sender: TObject);
		procedure ComboBox3Change(Sender: TObject);
		procedure ComboBox4Change(Sender: TObject);
		procedure ComboBox5Change(Sender: TObject);
		procedure ComboBox6Change(Sender: TObject);
		procedure Edit2Change(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure ComboBox7Change(Sender: TObject);
		procedure ComboBox8Change(Sender: TObject);
		procedure CheckBox3Click(Sender: TObject);
		procedure CheckBox4Click(Sender: TObject);
		procedure CheckBox5Click(Sender: TObject);

	private
		FConfig: TXSIDConfig;
//		FRenderer: TXSIDRendererClass;

		FPopulating: Boolean;

		procedure PopulateDialog;
		procedure DoSetupRenderParam;

	public
		property  Config: TXSIDConfig read FConfig;
	end;

var
	XSIDConfigForm: TXSIDConfigForm;

implementation

uses
	FormXSIDFilterConfig;

{$R *.dfm}

{ TXSIDConfigForm }

procedure TXSIDConfigForm.ComboBox3Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.SampleRate:= TXSIDSampleRate(ComboBox3.ItemIndex);
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox1Change(Sender: TObject);
	var
	b: Boolean;
	t3: TXSIDModelType3;
	t4: TXSIDModelType4;

	begin
	if not FPopulating then
		begin
		FConfig.Model:= TC64SIDModel(ComboBox1.ItemIndex + 1);

		FPopulating:= True;
		try
			ComboBox7.ItemIndex:= -1;

			ComboBox7.Items.BeginUpdate;
			try
				ComboBox7.Items.Clear;
				if FConfig.Model = csmMOS6581 then
					for t3:= Low(TXSIDModelType3) to High(TXSIDModelType3) do
						ComboBox7.Items.Add(ARR_STR_MODELTYPE3[t3])
				else
					for t4:= Low(TXSIDModelType4) to High(TXSIDModelType4) do
						ComboBox7.Items.Add(ARR_STR_MODELTYPE4[t4]);

				ComboBox7.Items.Add('Custom...');

				finally
				ComboBox7.Items.EndUpdate;
				end;

			b:= FConfig.Model = csmMOS8580;
			Label11.Enabled:= b;
			CheckBox2.Enabled:= b;

			CheckBox2.Checked:= FConfig.DigiBoostEnable;

			finally
			FPopulating:= False;
			end;

		ComboBox7.ItemIndex:= 0;
		ComboBox7Change(Sender);

		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.CheckBox1Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.FilterEnable:= CheckBox1.Checked;
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.CheckBox2Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.DigiBoostEnable:= CheckBox2.Checked;
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.CheckBox3Click(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.ModelOverride:= CheckBox3.Checked;
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.CheckBox4Click(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.SystemOverride:= CheckBox4.Checked;
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.CheckBox5Click(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.UpdateRateOverride:= CheckBox5.Checked;
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox2Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.System:= TC64SystemType(ComboBox2.ItemIndex + 1);

		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox4Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.BufferSize:= TXSIDBufferSize(ComboBox4.ItemIndex);
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox5Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.Interpolation:= TXSIDInterpolation(ComboBox5.ItemIndex + 1);
		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox6Change(Sender: TObject);
	begin
	if not FPopulating then
		begin
		FConfig.Renderer:= GlobalRenderers[ComboBox6.ItemIndex].GetName;
		DoSetupRenderParam;

		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox7Change(Sender: TObject);
	var
	r: Integer;
	b: Boolean;
	t3: TXSIDModelType3;
	t4: TXSIDModelType4;

	begin
	if not FPopulating then
		begin
		if  (ComboBox7.ItemIndex > -1)
		and (ComboBox7.ItemIndex < (ComboBox7.Items.Count - 1)) then
			if  FConfig.Model = csmMOS6581 then
				FConfig.Filter6581:=
						ARR_VAL_TYPE3PROPS[TXSIDModelType3(ComboBox7.ItemIndex)]
			else
				FConfig.Filter8580:=
						ARR_VAL_TYPE4PROPS[TXSIDModelType4(ComboBox7.ItemIndex)]
		else
			begin
			XSIDFilterConfigForm:= TXSIDFilterConfigForm.Create(Self);
			try
				XSIDFilterConfigForm.PopupParent:= Self;
				XSIDFilterConfigForm.Model:= FConfig.Model;
				if  FConfig.Model = csmMOS6581 then
					XSIDFilterConfigForm.Filter:= FConfig.Filter6581
				else
					XSIDFilterConfigForm.Filter:= FConfig.Filter8580;

				r:= XSIDFilterConfigForm.ShowModal;

				if  r <> mrOk then
					begin
					FPopulating:= True;
					try
						b:= False;
						if  FConfig.Model = csmMOS6581 then
							begin
							for t3:= Low(TXSIDModelType3) to High(TXSIDModelType3) do
								if  FConfig.Filter6581 = ARR_VAL_TYPE3PROPS[t3] then
									begin
									ComboBox7.ItemIndex:= Ord(t3);
									b:= True;
									end;
							end
						else
							begin
							for t4:= Low(TXSIDModelType4) to High(TXSIDModelType4) do
								if  FConfig.Filter8580 = ARR_VAL_TYPE4PROPS[t4] then
									begin
									ComboBox7.ItemIndex:= Ord(t4);
									b:= True;
									end;
							end;

						if  not b then
							ComboBox7.ItemIndex:= ComboBox7.Items.Count - 1;

						finally
						FPopulating:= False;
						end;
					end
				else
					begin
					if  FConfig.Model = csmMOS6581 then
						FConfig.Filter6581:= XSIDFilterConfigForm.Filter
					else
						FConfig.Filter8580:= XSIDFilterConfigForm.Filter;
					end;

				finally
				XSIDFilterConfigForm.Release;
				end;
			end;

		if  FConfig.Model = csmMOS6581 then
			Label5.Caption:= FormatFloat('0.00', FConfig.Filter6581)
		else
			Label5.Caption:= FormatFloat('0', FConfig.Filter8580) + 'Hz';

		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.ComboBox8Change(Sender: TObject);
	begin
	if  not FPopulating then
		begin
		FConfig.UpdateRate:= TC64UpdateRate(ComboBox8.ItemIndex);

		Button2.Enabled:= FConfig.Changed;
		end;
	end;

procedure TXSIDConfigForm.Edit2Change(Sender: TObject);
	begin
	if  not FPopulating then
		if FConfig.GetRenderParams.Count > 0 then
			begin
			FConfig.GetRenderParams.ValueFromIndex[0]:= Edit2.Text;
			Button2.Enabled:= True;
			end;
	end;

procedure TXSIDConfigForm.FormCreate(Sender: TObject);
	begin
	FConfig:= TXSIDConfig.Create;
	FConfig.Assign(GlobalConfig);

	PnlOverrides.Visible:= FConfig.AllowOverrides;

	if  not FConfig.AllowOverrides then
		Top:= Top + PnlOverrides.Height div 2;

	PopulateDialog;
	end;

procedure TXSIDConfigForm.FormDestroy(Sender: TObject);
	begin
	FConfig.Free;
	end;

procedure TXSIDConfigForm.PopulateDialog;
	var
	i: Integer;
	r: TXSIDAudioRendererClass;
	b: Boolean;
	t3: TXSIDModelType3;
	t4: TXSIDModelType4;

	begin
	FPopulating:= True;
	FConfig.Lock;
	try
		ComboBox1.ItemIndex:= Ord(FConfig.Model) - 1;
		ComboBox2.ItemIndex:= Ord(FConfig.System) - 1;
		ComboBox8.ItemIndex:= Ord(FConfig.UpdateRate);

		CheckBox3.Checked:= FConfig.ModelOverride;
		CheckBox4.Checked:= FConfig.SystemOverride;
		CheckBox5.Checked:= FConfig.UpdateRateOverride;

		CheckBox1.Checked:= FConfig.FilterEnable;
		CheckBox2.Checked:= FConfig.DigiBoostEnable;

		ComboBox7.ItemIndex:= -1;

		ComboBox7.Items.BeginUpdate;
		try
			ComboBox7.Items.Clear;
			if  FConfig.Model = csmMOS6581 then
				for t3:= Low(TXSIDModelType3) to High(TXSIDModelType3) do
					ComboBox7.Items.Add(ARR_STR_MODELTYPE3[t3])
			else
				for t4:= Low(TXSIDModelType4) to High(TXSIDModelType4) do
					ComboBox7.Items.Add(ARR_STR_MODELTYPE4[t4]);

			ComboBox7.Items.Add('Custom...');

			finally
			ComboBox7.Items.EndUpdate;
			end;

		b:= False;
		if  FConfig.Model = csmMOS6581 then
			begin
			for t3:= Low(TXSIDModelType3) to High(TXSIDModelType3) do
				if  FConfig.Filter6581 = ARR_VAL_TYPE3PROPS[t3] then
					begin
					ComboBox7.ItemIndex:= Ord(t3);
					b:= True;
					end;

			Label5.Caption:= FormatFloat('0.00', FConfig.Filter6581)
			end
		else
			begin
			for t4:= Low(TXSIDModelType4) to High(TXSIDModelType4) do
				if  FConfig.Filter8580 = ARR_VAL_TYPE4PROPS[t4] then
					begin
					ComboBox7.ItemIndex:= Ord(t4);
					b:= True;
					end;

			Label5.Caption:= FormatFloat('0', FConfig.Filter8580) + 'Hz';
			end;

		if  not b then
			ComboBox7.ItemIndex:= ComboBox7.Items.Count - 1;

		b:= FConfig.Model = csmMOS8580;
		Label11.Enabled:= b;
		CheckBox2.Enabled:= b;

		ComboBox6.Items.Clear;
		for i:= 0 to GlobalRenderers.Count - 1 do
			ComboBox6.Items.Add(string(GlobalRenderers[i].GetName));

		r:= GlobalRenderers.ItemByName(FConfig.Renderer);
		i:= GlobalRenderers.IndexOf(r);
		ComboBox6.ItemIndex:= i;

		DoSetupRenderParam;

		ComboBox3.ItemIndex:= Ord(FConfig.SampleRate);
		ComboBox4.ItemIndex:= Ord(FConfig.BufferSize);
		ComboBox5.ItemIndex:= Ord(FConfig.Interpolation) - 1;

		Button2.Enabled:= FConfig.Changed;

		finally
		FConfig.Unlock;
		FPopulating:= False;
		end;
	end;

procedure TXSIDConfigForm.DoSetupRenderParam;
	begin
//	We own the FConfig so no need to lock it here.  This API needs a fix.
	if  FConfig.GetRenderParams.Count > 0 then
		begin
		Label13.Caption:= FConfig.GetRenderParams.Names[0] + ':';
		Edit2.Text:= FConfig.GetRenderParams.ValueFromIndex[0];
		Label13.Visible:= True;
		Label14.Visible:= False;
		Edit2.Visible:= True;
		Button5.Enabled:= FConfig.GetRenderParams.Count > 1;
		end
	else
		begin
		Label13.Visible:= False;
		Label14.Visible:= True;
		Edit2.Visible:= False;
		Button5.Enabled:= False;
		end;
	end;

end.

