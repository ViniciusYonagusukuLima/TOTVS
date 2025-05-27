#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/* ---------------------------------------------------
Nome: DS2UA030
Rotina para cadastro de Grupos Economicos.
Autor: DN [DS2U]
Data: 14/05/2025
---------------------------------------------------- */

Static cTitulo   := "Cadastro de Grupos Economicos"
Static cAlias    := "PA2"

User Function DS2UA030()
    Local aArea := GetArea()
    Local oBrowse := Nil
    Private aRotina := {}

    //--DEFINIÇÃO DOS MENUS
    aRotina := MenuDef()

    //--INSTANCIA O BROWSE
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    oBrowse:Activate()

    RestArea(aArea)
Return

//--DEFINE OS MENUS DO BROWSE
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.DS2UA030" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.DS2UA030" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.DS2UA030" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluír"      ACTION "VIEWDEF.DS2UA030" OPERATION 5 ACCESS 0
    
Return aRotina

//--DIFINIÇÃO DO MODELO DE DADOS
Static Function ModelDef()
    Local oModel  := Nil
    Local oStruct := FWFormStruct(1, cAlias)
    Local bPre    := Nil
    Local bPos    := Nil
    Local bCommit := Nil
    Local bCancel := Nil

    oModel := MPFormModel():New("GRPECONM", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("PA2MASTER", /*cOwner*/, oStruct)
    oModel:SetDescription("Cadastro de Grupos Economicos")
    oModel:GetModel("PA2MASTER"):SetDescription("Cadastro de Grupos Economicos")
    oModel:SetPrimaryKey({})
Return oModel

//--CAMADA VISUAL DA TABELA
Static Function ViewDef()
    Local oModel  := FWLoadModel("DS2UA030")
    Local oStruct := FWFormStruct(2, cAlias)
    Local oView   := Nil

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_PA2", oStruct, "PA2MASTER")
    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_PA2", "TELA")
Return oView
