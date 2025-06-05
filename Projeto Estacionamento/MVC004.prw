#include 'protheus.ch'
#include 'FwMVCDef.ch'

/*/------------------------------------------------------>
    Fun��o:    MVC004
    Descri��o: 
    Tipo:      User Function
    Autor:     Vin�cius Lima
    Criado:    30/05/2025
<------------------------------------------------------/*/
User Function MVC004()

    Private aRotina := MenuDef()
    Private oBrowse := FwMBrowse():New()

    oBrowse:setAlias('SZ4')
    oBrowse:setDescription('Entrada/Sa�da de Ve�culos')
    oBrowse:setExecuteDef(4)
    oBrowse:Activate()

Return

/*/------------------------------------------------------>
    Fun��o:    MenuDef
    Descri��o: 
    Tipo:      Static Function
    Autor:     Vin�cius Lima
    Criado:    30/05/2025
<------------------------------------------------------/*/
Static Function MenuDef()
    
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MVC004' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MVC004' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MVC004' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MVC004' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.MVC004' OPERATION 8 ACCESS 0    
    ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.MVC004' OPERATION 9 ACCESS 0

Return aRotina

/*/------------------------------------------------------>
    Fun��o:    ModelDef
    Descri��o: 
    Tipo:      Static Function
    Autor:     Vin�cius Lima
    Criado:    30/05/2025
<------------------------------------------------------/*/
Static Function ModelDef()
    
Return oModel

/*/------------------------------------------------------>
    Fun��o:    ViewDef
    Descri��o: 
    Tipo:      Static Function
    Autor:     Vin�cius Lima
    Criado:    30/05/2025
<------------------------------------------------------/*/
Static Function ViewDef()
    
Return oView
