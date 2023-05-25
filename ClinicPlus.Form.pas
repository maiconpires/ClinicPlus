unit ClinicPlus.Form;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.MultiView, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Objects, FMX.TabControl, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Data.Bind.Components, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.DBScope,
  System.JSON, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, FireDAC.DApt, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid;

type
  TClinicPlusForm = class(TForm)
    TopRCT: TRectangle;
    Label1: TLabel;
    MenuBTN: TButton;
    MultiView1: TMultiView;
    MenuLST: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ButtonsRCT: TRectangle;
    HomePTH: TPath;
    HomeLYT: TLayout;
    ScheduleLYT: TLayout;
    Path1: TPath;
    HistoryLYT: TLayout;
    Path2: TPath;
    AnimeLYT: TLayout;
    AnimeRCT: TRectangle;
    ContentTBC: TTabControl;
    ScheduleTBC: TTabItem;
    HomeTBC: TTabItem;
    HistoryTBC: TTabItem;
    Layout1: TLayout;
    Circle1: TCircle;
    NameLBL: TLabel;
    CPFLBL: TLabel;
    ScheduleLTV: TListView;
    ClienteMTB: TFDMemTable;
    ClienteMTBidcliente: TFDAutoIncField;
    ClienteMTBnome: TStringField;
    ClienteMTBcpf: TStringField;
    ClienteMTBnascimento: TDateTimeField;
    ClienteMTBfoto: TBlobField;
    AgendamentoMTB: TFDMemTable;
    AgendamentoMTBidagendamento: TFDAutoIncField;
    AgendamentoMTBidfuncionario: TIntegerField;
    AgendamentoMTBidcliente: TIntegerField;
    AgendamentoMTBidlocal: TIntegerField;
    AgendamentoMTBidadmin: TIntegerField;
    AgendamentoMTBdata_confirmacao: TDateTimeField;
    AgendamentoMTBdata_cadastro: TDateTimeField;
    AgendamentoMTBfg_status: TStringField;
    AgendamentoMTBprofissional: TStringField;
    AgendamentoMTBpaciente: TStringField;
    AgendamentoMTBlocal: TStringField;
    HistoricoMTB: TFDMemTable;
    FDAutoIncField1: TFDAutoIncField;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    IntegerField3: TIntegerField;
    IntegerField4: TIntegerField;
    DateTimeField3: TDateTimeField;
    DateTimeField4: TDateTimeField;
    StringField1: TStringField;
    StringField2: TStringField;
    StringField3: TStringField;
    StringField4: TStringField;
    HistoryLTV: TListView;
    AgendamentoMTBdata_agendamento: TDateField;
    AgendamentoMTBhora_agendamento: TTimeField;
    AgendamentoMTBdata_atendimento: TDateField;
    AgendamentoMTBhora_atendimento: TTimeField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    HistoricoMTBdata_agendamento: TDateField;
    HistoricoMTBhora_agendamento: TTimeField;
    HistoricoMTBdata_atendimento: TDateField;
    HistoricoMTBhora_atendimento: TTimeField;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    AtualizarBTN: TButton;
    procedure HomeLYTClick(Sender: TObject);
    procedure ScheduleLYTClick(Sender: TObject);
    procedure HistoryLYTClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ScheduleLTVButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure ScheduleLTVUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure AtualizarBTNClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetAgendamentoAtivo(const User: Integer); // requisição de agendamentos
    procedure GetHistorico(const User: Integer); // requisição de historico com todos agendamentos

    procedure GetCliente(const ID: Integer);  // requisição de nome, cpf e foto do usuario.
    procedure LoadCliente(const ID: Integer); // carrega nome, cpf e foto do usuario

    procedure ChangeSchedule(const AID: Integer; JSON: TJSONObject);
  end;

const
//  EnderecoServidor =  'http://192.168.0.110:9000/';
  EnderecoServidor =  'http://localhost:9000/';
var
  ClinicPlusForm: TClinicPlusForm;
  UserID: Integer; // usado para facilitar os testes.


implementation

uses FMX.Ani, RESTRequest4D, DataSet.Serialize, System.threading;

{$R *.fmx}

procedure TClinicPlusForm.AtualizarBTNClick(Sender: TObject);
begin
// Atualiza registros em Thread separada
  TTask.Run(procedure
  begin
    GetAgendamentoAtivo(UserID);
    GetHistorico(UserID);
  end);
end;

procedure TClinicPlusForm.ChangeSchedule(const AID: Integer; JSON: TJSONObject);
begin
  TRequest.New.BaseURL(EnderecoServidor+'agendamento') // URL da API
    .ResourceSuffix(AID.ToString)   // ID do registro
    .AddBody(JSON, False)           // JSON com registro atualizado
    .Accept('application/json')     // tipo de dados da resposta que esperamos
    .Put;                           // Verbo da requisição
end;

procedure TClinicPlusForm.FormCreate(Sender: TObject);
begin
// configura DatasetSerialize para manter todos os nomes dos campos em minusculas
// data_confirmacao ao invés de dataConfirmacao
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := TCaseNameDefinition.cndLower;

// Ajusta posicionamento do retangulo animado
  AnimeRCT.Position.X := HomeLYT.Position.X;

// grava temporariamente nosso usuário de teste,
// até criarmos a parte que identifica o usuario no APP
  UserID := 1;

  TTask.Run(procedure
  begin
    LoadCliente(UserID);
    GetAgendamentoAtivo(UserID);
    GetHistorico(UserID);
  end);

end;

procedure TClinicPlusForm.GetAgendamentoAtivo(const User: Integer);
begin
  TRequest.New.BaseURL(EnderecoServidor+'agendamento') // URL da API
    .AddParam('fg_status','a') // QueryParam - Filtra apenas status Ativo
    .AddParam('idcliente',User.ToString) // QueryParam - Filtra apenas pertencente ao usuario
    .Accept('application/json')  // tipo de dados da resposta que esperamos
    .DataSetAdapter(AgendamentoMTB)  // Conversão de JSON para DATASET
    .Get;                            // Verbo da requisição
end;

procedure TClinicPlusForm.GetCliente(const ID: Integer);
begin
  TRequest.New.BaseURL(EnderecoServidor+'cliente') // URL da API
    .ResourceSuffix(ID.ToString) // diciona /1 na url
    .Accept('application/json')  // tipo de dados da resposta que esperamos
    .DataSetAdapter(ClienteMTB)  // Conversão de JSON para DATASET
    .Get;                        // Verbo da requisição
end;

procedure TClinicPlusForm.GetHistorico(const User: Integer);
begin
  TRequest.New.BaseURL(EnderecoServidor+'agendamento') // URL da API
  .AddParam('idcliente',User.ToString) // QueryParam - apenas pertencente ao usuario
  .Accept('application/json')  // tipo de dados da resposta que esperamos
  .DataSetAdapter(HistoricoMTB)  // Conversão de JSON para DATASET
  .Get;                        // Verbo da requisição
end;

procedure TClinicPlusForm.HistoryLYTClick(Sender: TObject);
begin
// Animação do retangulo de navegação
  TAnimator
    .AnimateFloat( AnimeRCT, // Componente do formulario a ser animado
                   'position.x', // Propriedade do componente a ser animado
                   HistoryLYT.Position.X, // Valor da prop. ao final da animação
                   0.5, // Duração da animação
                   TAnimationType.Out, // Tipo da animação (entrada/saida ou ambos)
                   TInterpolationType.Bounce // Tipo da interpolação da animação
                 );
// Animação do Tabcontrol
  ContentTBC
    .SetActiveTabWithTransitionAsync(
      HistoryTBC, // Aba que será exibida
      TTabTransition.Slide, // Transição estilo escorrega
      TTabTransitionDirection.Normal, // Animação da direita para esquerda (normal)
      nil // ponteiro para execução de função ao terminar transição.
    );
end;

procedure TClinicPlusForm.HomeLYTClick(Sender: TObject);
var
  TabDirection: TTabTransitionDirection;
begin
// APENAS PARA O BOTÃO DO CENTRO SERÁ NECESSARIO
// AJUSTAR O SENTIDO DA ANIMAÇÃO DE ACORDO COM
// A PAGINA ATUAL (direita p/esquerda ou
// da esquerda p/ direita)
  if ContentTBC.ActiveTab.Index > HomeTBC.Index then
    TabDirection := TTabTransitionDirection.Reversed
  else
    TabDirection := TTabTransitionDirection.normal;

// animação do retangulo de animação
  TAnimator
    .AnimateFloat( AnimeRCT, // Componente do formulario a ser animado
                   'position.x', // Propriedade do componente a ser animado
                   HomeLYT.Position.X, // Valor da prop. ao final da animação
                   0.5, // Duração da animação
                   TAnimationType.Out, // Tipo da animação (entrada/saida ou ambos)
                   TInterpolationType.Bounce // Tipo da interpolação da animação
                 );
// animação do tabcontrol
  ContentTBC
    .SetActiveTabWithTransitionAsync(
      HomeTBC, // Aba que será exibida
      TTabTransition.Slide, // Transição estilo escorrega
      TabDirection, // Animação normal ou reversa, depende do IF acima
      nil // Ponteiro para execução de função ao terminar transição
    );
end;

procedure TClinicPlusForm.LoadCliente(const ID: Integer);
var
  FotoStream: TMemoryStream;
  BrushBmp: TBrushBitmap;
begin
  GetCliente(ID); // requisição no Backend (API)

  // usar synchronize apenas com a certeza de que LoadCliente será chamando dentro de
  // uma thread diferente da thread principal.
  TThread.Synchronize(TThread.CurrentThread, procedure
  begin
    NameLBL.Text := ClienteMTBnome.AsString; // grava nome no formulario
    CPFLBL.Text := ClienteMTBCPF.AsString;   // grava CPF no formulario

    FotoStream := TMemoryStream.Create; // Cria stream para ler foto
    BrushBmp := TBrushBitmap.Create; // Cria Brush para desenhar foto no TCircle

    try
      ClienteMTBFoto.SaveToStream(FotoStream); // Lê a foto do campo
      BrushBmp.Bitmap.LoadFromStream(FotoStream); // Desenha a foto no brush
      BrushBmp.WrapMode := TWrapMode.TileStretch; // Ajusta imagem ao tamanho do componente
      Circle1.Fill.Bitmap.Assign(BrushBmp); // Desenha imagem no componente.
    finally
    // libera variáveis temporarias utilizadas no processo de exibir a foto.
      FotoStream.Free;
      BrushBmp.Free;
    end;

  end);
end;

procedure TClinicPlusForm.ScheduleLTVButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  JSON: TJSONObject;
begin
  if AObject.Name.ToLower = 'confirmabutton' then
  begin
    AgendamentoMTB.Edit; // muda dataset para modo de edição
    AgendamentoMTBfg_status.AsString := 'C'; // altera valor do status
    AgendamentoMTBdata_confirmacao.Value := Now; // altera para data/hora atual
    AgendamentoMTB.Post;  // salva dados no dataset local
    JSON := AgendamentoMTB.ToJSONObject(); // converte registro para JSON
    ChangeSchedule(AgendamentoMTBidagendamento.Value, JSON); // envia mudanças para back-end
    JSON.Free; // libera memoria
  end;

  if AObject.Name.ToLower = 'cancelabutton' then
  begin
    AgendamentoMTB.Edit; // muda dataset para modo de edição
    AgendamentoMTBfg_status.AsString := 'I'; // altera valor do status
    AgendamentoMTBdata_confirmacao.Value := Now; // altera para data/hora atual
    AgendamentoMTB.Post; // salva dados no dataset local
    JSON := AgendamentoMTB.ToJSONObject(); // converte registro para JSON
    ChangeSchedule(AgendamentoMTBidagendamento.Value, JSON); // envia mudanças para back-end
    JSON.Free; // libera memoria
  end;

  // Atualiza os registros em thread separadas.
  TTask.Run(procedure
  begin
    Sleep(50);
    AgendamentoMTB.EmptyDataSet; // limpa dataset
    HistoricoMTB.EmptyDataSet;   // limpa dataset
    GetAgendamentoAtivo(UserID); // carrega dados atualizados do back-end
    GetHistorico(UserID);        // carrega dados atualizados do back-end
  end);

end;

procedure TClinicPlusForm.ScheduleLTVUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
// Ajusta altura dos botões no item do listview
  AItem.Objects.DrawableByName('ConfirmaButton').Height := 37;
  AItem.Objects.DrawableByName('CancelaButton').Height := 37;
end;

procedure TClinicPlusForm.ScheduleLYTClick(Sender: TObject);
begin
// Animação do retangulo de navegação
  TAnimator
    .AnimateFloat( AnimeRCT, // Componente do formulário a ser animado
                   'position.x', // Propriedade do componente a ser animado
                   ScheduleLYT.Position.X, // Valor da prop. ao final da animação
                   0.5, // Duração da animação
                   TAnimationType.Out, // tipo da animação (entrada/saida ou ambos)
                   TInterpolationType.Bounce // tipo da interpolação da animação
                 );
// Animação do Tabcontrol
  ContentTBC
    .SetActiveTabWithTransitionAsync(
      ScheduleTBC, // Aba que será exibida
      TTabTransition.Slide, // transição estilo escorrega
      TTabTransitionDirection.Reversed, // Animação da esquerda para direita (reversa)
      nil // ponteiro para execução de função ao terminar transição.
    );
end;

end.
