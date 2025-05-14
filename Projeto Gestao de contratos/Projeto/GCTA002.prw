#include 'totvs.ch'

Function U_GCTA002

    Private cTitulo := 'Cadastro de Contratos - Prototipo Modelo 3'
    Private aRotina[0]

    // Montagem do array de intens de menu
    aadd(aRotina,{"Pesquisar" ,"axPesqui"  ,0,1})
    aadd(aRotina,{"Visualizar","U_GCTA002M",0,2})
    aadd(aRotina,{"Incluir"   ,"U_GCTA002M",0,3})
    aadd(aRotina,{"Alterar"   ,"U_GCTA002M",0,4})
    aadd(aRotina,{"Excluir"   ,"U_GCTA002M",0,5})

    Z51->(dbSetOrder(1),mBrowse(,,,,alias()))

Return

Function U_GCTA002M(cAlias,nReg,nOpc)

    Local oDlg
    Local aAdvSize  := msAdvSize()
    Local aInfo     := {aAdvSize[1],aAdvSize[2],aAdvSize[3],aAdvSize[4],3,3}
    Local aObj      := {{100,120,.T.,.F.},{100,100,.T.,.T.},{100,010,.T.,.F.}}
    Local aPObj     := msObjSize(aInfo,aObj)
    Local nSalvar   := 0
    Local bSalvar   := {|| (nSalvar := 1, oDlg:end())}
    Local bCancelar := {|| (nSalvar := 0, oDlg:end())}
    Local aButtons  := array(0)

    //-- Tela de dialog principal
    oDlg        := tDialog():new(0           ,;           // Cordenada Inicial, Linha inicial (Pixels)
                                 0           ,;           // Cordenada Inicial, Coluna inicial 
                                 aAdvSize[6] ,;           // Cordenada Final, Linha inicial
                                 aAdvSize[5] ,;           // Cordenada Final, Coluna inicial
                                 cTitulo     ,;           // Titulo da janela
                                 Nil         ,;           // Fixo
                                 Nil         ,;           // Fixo
                                 Nil         ,;           // Fixo
                                 Nil         ,;           // Fixo
                                 CLR_BLACK   ,;           // Cor do Texto
                                 CLR_WHITE   ,;           // Cor do fundo da tela
                                 Nil         ,;           // Fixo
                                 Nil         ,;           //
                                 .T.          )           // Indica que as coodernadas serao em pixel

    regToMemory(cAlias,if(nOpc == 3,.T.,.F.),.T.)
    msmGet():new(cAlias,nReg,nOpc,,,,,aPObj[1])
    enchoicebar(oDlg,bSalvar,bCancelar,,aButtons)

    oDlg:activate()

Return
