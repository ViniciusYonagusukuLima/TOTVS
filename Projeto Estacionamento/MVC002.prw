#include 'protheus.ch'
#include 'FwMVCDef.ch'

/*/------------------------------------------------------>
    Função:    MVC002
    Descrição: Função para criar um Browser
    Tipo:      User Function
    Autor:     Vinícius Lima
    Criado:    29/05/2025
<------------------------------------------------------/*/
User Function MVC002()
    
    Private aRotina := MenuDef()
    Private oBrowse := FwMBrowse():New()

    oBrowse:setAlias('SZ2')
    oBrowse:setDescription('Cadastro da Marca')
    oBrowse:setExecuteDef(4)
    oBrowse:Activate()

Return

/*/------------------------------------------------------>
    Função:    MenuDef
    Descrição: Adiciona os botoes no Browse
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    29/05/2025
<------------------------------------------------------/*/
Static Function MenuDef()
    
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MVC002' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MVC002' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MVC002' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MVC002' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.MVC002' OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.MVC002' OPERATION 9 ACCESS 0

Return aRotina

/*/------------------------------------------------------>
    Função:    ModelDef
    Descrição: 
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    29/05/2025
<------------------------------------------------------/*/
Static Function ModelDef()
    
    Local oModel
    Local oStruSZ2

    oModel   := MPFormModel():New('MVC002M',,,,)
    oStruSZ2 := FwFormStruct(1,'SZ2')

    oModel:addFields('SZ2MASTER',,oStruSZ2)
    oModel:setPrimaryKey({'Z2_FILIAL','Z2_CODIGO'})
    oModel:setDescription('Modelo de dados da Marca')
    oModel:getModel('SZ2MASTER'):setDescription('Dados da Marca')

Return oModel

/*/------------------------------------------------------>
    Função:    ViewDef
    Descrição: 
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    29/05/2025
<------------------------------------------------------/*/
Static Function ViewDef()
    
    Local oView    
    Local oModel
    Local oStruSZ2

    oView    := fwFormView():New()
    oModel   := fwLoadModel('MVC002')
    oStruSZ2 := fwFormStruct(2,'SZ2')

    oView:setModel(oModel)
    oView:addField('VIEW_SZ2',oStruSZ2,'SZ2MASTER')
    oView:createHorizontalBox('TELA1',100)
    oView:setOwnerView('VIEW_SZ2','TELA1')

Return oView
