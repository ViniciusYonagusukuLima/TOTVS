#include 'protheus.ch'
#include 'FwMVCDef.ch'

/*/------------------------------------------------------>
    Fun��o:    MVC001
    Descri��o: Cria os menus do sistema de estacionamento
    Tipo:      Function
    Autor:     Vin�cius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
User Function MVC001()
    
    Private oBrowse   := FwMBrowse():New()

    oBrowse:setAlias('SZ0')
    oBrowse:setDescription('Cadastro de Estacionamento')
    oBrowse:Activate()
    
Return

/*/------------------------------------------------------>
    Fun��o:    ModelDef
    Descri��o: Modelo de Dados
    Tipo:      Static Function
    Autor:     Vin�cius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
Static Function ModelDef()
    
    Local oStruSZ0 := FwFormStruct(1,'SZ0')
    Local oModel

    oModel := MPFormModel():New('SZ0MODEL')
    oModel:AddFields('SZ0MASTER',/*cOwner*/, oStruSZ0)
    oModel:setDescription('Modelo de dados do Estacionamento')
    oModel:GetModel('SZ0MASTER'):setDescription('Dados do Estacionamento')

Return oModel

/*/------------------------------------------------------>
    Fun��o:    ViewDef
    Descri��o: Interface do usu�rio
    Tipo:      Static Function
    Autor:     Vin�cius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
Static Function ViewDef()
    
    Local oView
    Local oModel
    Local oStruSZ0
    Local oStruSZ1

    oView     := FWFormView():New()
    oModel    := FWLoadModel( 'MV001')
    oStruSZ0  := FwFormStruct(2,'SZ0')
    oStruSZ1  := FwFormStruct(2,'SZ1')

    oView:SetModel(oModel)
    oView:AddField('VIEW_SZ0',oStruSZ0,'SZ0MASTER')
    oView:AddGrid( 'VIEW_SZ1',oStruSZ1,'SZ1DETAIL')
    oView:CreateHorizontalBox('TELA1',40)
    oView:CreateHorizontalBox('TELA2',60)
    oView:SetOwnerView('VIEW_SZ0','TELA1')
    oView:SetOwnerView('VIEW_SZ1','TELA2')

Return oView


/*/------------------------------------------------------>
    Fun��o:    MenuDef
    Descri��o: Menu de opera��es da tela principal
    Tipo:      Static Function
    Autor:     Vin�cius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.MVC001' OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.MVC001' OPERATION 4 ACCESS 0
    ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.MVC001' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.MVC001' OPERATION 5 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.MVC001' OPERATION 8 ACCESS 0
    ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.MVC001' OPERATION 9 ACCESS 0

Return aRotina
