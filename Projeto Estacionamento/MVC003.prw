#include 'protheus.ch'
#include 'FwMVCDef.ch'

/*/------------------------------------------------------>
    Função:    MVC003
    Descrição: 
    Tipo:      User Function
    Autor:     Vinícius Lima
    Criado:    29/05/2025
<------------------------------------------------------/*/
User Function MVC003()
    
    Private aRotina := MenuDef()
    Private oBrowse := FwMBrowse():New()

    oBrowse:setAlias('SZ3')
    oBrowse:setDescription('Cadastro do Modelo')
    oBrowse:setExecuteDef(4)
    oBrowse:Activate()

Return

/*/------------------------------------------------------>
    Função:    MenuDef
    Descrição: 
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    29/05/2025
<------------------------------------------------------/*/
Static Function MenuDef()

    aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.MVC003" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.MVC003" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MVC003" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.MVC003" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.MVC003" OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar"     ACTION "VIEWDEF.MVC003" OPERATION 9 ACCESS 0
    
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
    Local oStruSZ3

    oModel   := MPFormModel():New('MVC003M',,,,)
    oStruSZ3 := fwFormStruct(1,'SZ3')

    oModel:addFields('SZ3MASTER',,oStruSZ3)
    oModel:setPrimaryKey({'Z3_FILIAL','Z3_CODIGO'})
    oModel:setDescription('Modelo de dados do Modelo')
    oModel:getModel('SZ3MASTER'):setDescription('Dados do Modelo')

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
    Local oStruSZ3

    oView    := fwFormView():New()
    oModel   := fwLoadModel('MVC003')
    oStruSZ3 := fwFormStruct(2,'SZ3')

    oView:setModel(oModel)
    oView:addField('VIEW_SZ3',oStruSZ3,'SZ3MASTER')
    oView:createHorizontalBox('TELA1',100)
    oView:setOwnerView('VIEW_SZ3','TELA1')

Return oView
