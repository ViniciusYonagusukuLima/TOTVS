#include 'protheus.ch'
#include 'FwMVCDef.ch'

/*/------------------------------------------------------>
    Função:    MVC001
    Descrição: Função principal para criar um Browser do estacionamento
    Tipo:      Function
    Autor:     Vinícius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
User Function MVC001()
    
    Private aRotina   := MenuDef()
    Private oBrowse   := FwMBrowse():New()

    oBrowse:setAlias('SZ0')
    oBrowse:setDescription('Cadastro de Estacionamento')
    oBrowse:setExecuteDef(4)
    oBrowse:Activate()
    
Return

/*/------------------------------------------------------>
    Função:    MenuDef
    Descrição: Adiciona os botoes no menu do Browse
    Tipo:      Static Function
    Autor:     Vinícius Lima
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

/*/------------------------------------------------------>
    Função:    ViewDef
    Descrição: Construcao da interface gráfica
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
Static Function ViewDef()
    
    Local oView
    Local oModel
    Local oStruSZ0
    Local oStruSZ1

    oView     := FWFormView():New()
    oModel    := FWLoadModel('MVC001')
    oStruSZ0  := FwFormStruct(2,'SZ0')
    oStruSZ1  := FwFormStruct(2,'SZ1',{|cCampo| .not. alltrim(cCampo) $ 'Z1_CODIGO'})

    oView:SetModel(oModel)
    oView:AddField('VIEW_SZ0',oStruSZ0,'SZ0MASTER')
    oView:AddGrid( 'VIEW_SZ1',oStruSZ1,'SZ1DETAIL')
    oView:AddIncrementView('VIEW_SZ1','Z1_ITEM')
    oView:CreateHorizontalBox('TELA1',45)
    oView:CreateHorizontalBox('TELA2',55)
    oView:SetOwnerView('VIEW_SZ0','TELA1')
    oView:SetOwnerView('VIEW_SZ1','TELA2')

Return oView

/*/------------------------------------------------------>
    Função:    ModelDef
    Descrição: Construcao da regra de negocio
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    27/05/2025
<------------------------------------------------------/*/
Static Function ModelDef()
    
    Local oModel
    Local oStruSZ0
    Local oStruSZ1
    Local bModelPre := {|oModel| .T.}
    Local bModelPos := {|oModel| .T.}
    Local bCommit   := {|oModel| FWFormCommit(oModel)}
    Local bCancel   := {|oModel| fCancel(oModel)}
    Local bLinePre  := {|oGridModel,nLine,cAction,cField,xValue,xCurrentValue| vGridPre(oGridModel,nLine,cAction,cField,xValue,xCurrentValue,1)}
    Local bGridPre  := {|oGridModel,nLine,cAction,cField,xValue,xCurrentValue| vGridPre(oGridModel,nLine,cAction,cField,xValue,xCurrentValue,2)}
    Local bLinePos  := {|oGridModel,nLine| vGridPos(oGridModel,nLine,1)}
    Local bGridPos  := {|oGridModel,nLine| vGridPos(oGridModel,nLine,2)}
    Local bGridLoad := {|oGridModel,lCopy| vGridLoad(oGridModel,lCopy )}

    oStruSZ0 := FwFormStruct(1,'SZ0')
    oStruSZ1 := FwFormStruct(1,'SZ1')

    bModelWhen := {|| oModel:getOperation() == 3 .or. oModel:getOperation() == 9}
    bModelInit := {|| getSxeNum("SZ0","Z0_CODIGO")}
    bValid     := {|| vValid()}


    oStruSZ0:setProperty('Z0_CODIGO',MODEL_FIELD_INIT ,bModelInit)
    oStruSZ0:setProperty('Z0_TIPO'  ,MODEL_FIELD_WHEN ,bModelWhen)
    oStruSZ0:setProperty('Z0_CGC'   ,MODEL_FIELD_WHEN ,bModelWhen)
    oStruSZ1:setProperty('*'        ,MODEL_FIELD_VALID,bValid    )

    oModel   := MPFormModel():New('MVC001M',bModelPre,bModelPos,bCommit,bCancel)
    oModel:AddFields('SZ0MASTER',/*cOwner*/, oStruSZ0)
    oModel:SetPrimaryKey({'Z0_FILIAL','Z0_CODIGO'})
    oModel:SetDescription('Modelo de dados do Estacionamento')
    oModel:GetModel('SZ0MASTER'):setDescription('Dados do Estacionamento')
    oModel:AddGrid('SZ1DETAIL','SZ0MASTER',oStruSZ1,bLinePre,bLinePos,bGridPre,bGridPos,bGridLoad)
    oModel:GetModel('SZ1DETAIL'):setUniqueLine({'Z1_ITEM'})
    oModel:SetOptional('SZ1DETAIL',.T.)
    oModel:SetRelation('SZ1DETAIL',{{'Z1_FILIAL','xFilial("SZ1")'},{"Z1_CODIGO","Z0_CODIGO"}},SZ1->(IndexKey(1)))

Return oModel

/*/------------------------------------------------------>
    Função:    vValid
    Descrição: Valida a duplicidade de dados na Grid
    Tipo:      Static Function
    Autor:     Vinícius Lima
    Criado:    05/06/2025
<------------------------------------------------------/*/
Static Function vValid()
    
    Local lValid  := .T.
    Local oModel  := fwModelActive()
    Local oDetail := oModel:GetModel("SZ1DETAIL")
    Local cCampo  := strtran(readvar(),"M->","")
    Local xValue  := NIL
    Local yValue  := NIL
    Local xTipo   := NIL
    Local xPorte  := NIL
    Local nIndex  := 0
    Local nTotal  := oDetail:Length()
    Local nAtual  := nTotal - 1
    Local nLine   := 0

    DO CASE

        CASE cCampo == "Z1_TIPO"

            xValue := oDetail:getValue('Z1_TIPO')
            yValue := oDetail:getValue('Z1_PORTE')

            IF (xValue != " " .AND. yValue != " ")
                
                For nIndex := 1 To nAtual

                    nLine  := oDetail:goLine(nIndex)
                    xTipo  := oDetail:getValue("Z1_TIPO")
                    xPorte := oDetail:getValue("Z1_PORTE")

                    If xTipo == xValue .AND. xPorte == yValue
                        FWAlertWarning("Já existe um cadastro com essa combinação de Tipo e Porte.", "Atenção")
                        lValid := .F.
                        nLine  := oDetail:goLine(nTotal)
                        Exit
                    EndIf

                    nLine  := oDetail:goLine(nTotal)

                Next

            EndIF

        CASE cCampo == "Z1_PORTE"

            xValue := oDetail:getValue('Z1_TIPO')
            yValue := oDetail:getValue('Z1_PORTE')

            IF (xValue != " " .AND. yValue != " ")
                
                For nIndex := 1 To nAtual

                    nLine  := oDetail:goLine(nIndex)
                    xTipo  := oDetail:getValue("Z1_TIPO")
                    xPorte := oDetail:getValue("Z1_PORTE")
            
                    If xTipo == xValue .AND. xPorte == yValue
                        FWAlertWarning("Já existe um cadastro com essa combinação de Tipo e Porte.", "Atenção")
                        lValid := .F.
                        nLine  := oDetail:goLine(nTotal)
                        Exit
                    EndIf

                    nLine  := oDetail:goLine(nTotal)

                Next

            EndIF

    END CASE
Return lValid


Static Function fCancel(oModel)
    
    Local lCancel := FWFormCancel(oModel)

    IF lCancel

        IF __lSX8
            rollbackSX8()
        EndIF

    EndIF

Return lCancel


Static Function vGridPre(oGridModel,nLine,cAction,cField,xValue,xCurrentValue,nOpc)

    Local lValid

Return lValid


Static Function vGridPos(oGridModel,nLine,nOpc)

    Local lValid := .T.

Return lValid


Static Function vGridLoad(oGridModel,lCopy)

    Local aRetorno := formLoadGrid(oGridModel,lCopy)

Return aRetorno
