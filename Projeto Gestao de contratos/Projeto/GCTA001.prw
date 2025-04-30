#include "totvs.ch"

/*/{Protheus.doc} U_GCTA001
    
    Cadastro de tipos de contratos (Modelo 1).

    @see https://tdn.totvs.com/pages/viewpage.action?pageId=24346981 (mBrowse   )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889143 (axPesqui  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889145 (axVisual  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889141 (axInclui  )
    @see https://t
    n.totvs.com/pages/viewpage.action?pageId=23889132 (axAltera  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889138 (axDeleta  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889136 (axCadastro)
    /*/

Function U_GCTA001

    Private cCadastro := 'Cadastro de tipos de contratos'
    Private aRotina   := {}

    aadd(aRotina,{"Pesquisar" ,"axPesqui",0,1})
    aadd(aRotina,{"Visualizar","axVisual",0,2})
    aadd(aRotina,{"Incluir"   ,"axInlcui",0,3})
    aadd(aRotina,{"Alterar"   ,"axAltera",0,4})
    aadd(aRotina,{"Excluir"   ,"axDeleta",0,5})

    dbSelectArea("Z50")
    dbSetOrder(1)

    mBrowse(,,,,alias(),)

Return
