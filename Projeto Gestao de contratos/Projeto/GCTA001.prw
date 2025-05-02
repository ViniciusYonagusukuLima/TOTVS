#include "totvs.ch"

/*/{Protheus.doc} U_GCTA001
    
    Cadastro de tipos de contratos (Modelo 1).

    @see https://tdn.totvs.com/pages/viewpage.action?pageId=24346981 (mBrowse   )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889143 (axPesqui  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889145 (axVisual  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889141 (axInclui  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889132 (axAltera  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889138 (axDeleta  )
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=23889136 (axCadastro)
    /*/

Function U_GCTA001

    Local nOpcPad     := 4
    Local aLegenda    := {}

    Private cCadastro := 'Cadastro de tipos de contratos'
    Private aRotina   := {}

    aadd(aLegenda,{"Z50_TIPO == 'V'", "BR_AMARELO" })
    aadd(aLegenda,{"Z50_TIPO == 'C'", "BR_LARANJA"})
    aadd(aLegenda,{"Z50_TIPO == 'S'", "BR_CINZA"})

    aadd(aRotina,{"Pesquisar" ,"axPesqui"  ,0,1})
    aadd(aRotina,{"Visualizar","axVisual"  ,0,2})
    aadd(aRotina,{"Incluir"   ,"axInclui"  ,0,3})
    aadd(aRotina,{"Alterar"   ,"axAltera"  ,0,4})
    aadd(aRotina,{"Excluir"   ,"axDeleta"  ,0,5})
    aadd(aRotina,{"Legendas"  ,"U_GCTA001L",0,6})

    dbSelectArea("Z50")
    dbSetOrder(1)

    mBrowse(,,,,alias(),,,,,nOpcPad,aLegenda)

Return

// Funcao auxiliar para descricao das legendas
Function U_GCTA001L

    Local aLegenda := array(0)

    aadd(aLegenda,{"BR_AMARELO","Contrato de Vendas" })
    aadd(aLegenda,{"BR_LARANJA","Contrato de Compras"})
    aadd(aLegenda,{"BR_CINZA"  ,"Sem integração"     })

Return brwLegenda("Tipos de contratos","Legenda",aLegenda)
