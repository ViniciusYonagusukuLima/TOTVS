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

    Local oDlg,oGet
    Local aAdvSize  := msAdvSize()
    Local aInfo     := {aAdvSize[1],aAdvSize[2],aAdvSize[3],aAdvSize[4],3,3}
    Local aObj      := {{100,120,.T.,.F.},{100,100,.T.,.T.},{100,010,.T.,.F.}}
    Local aPObj     := msObjSize(aInfo,aObj)
    Local nSalvar   := 0
    Local nStyle    := GD_INSERT+GD_UPDATE+GD_DELETE
    Local bSalvar   := {|| if(obrigatorio(aGets,aTela),(nSalvar := 1, oDlg:end()),nil)}
    Local bCancelar := {|| (nSalvar := 0, oDlg:end())}
    Local aButtons  := array(0)
    Local aHeader   := fnGetHeader()
    Local aCols     := fnGetCols(nOpc,aHeader)

    Private aGets   := array(0)
    Private aTela   := array(0)

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

    //-- Area do Cabecalho
    regToMemory(cAlias,if(nOpc == 3,.T.,.F.),.T.)
    M->Z51_NUMERO := getSxeNum('Z51','Z51_NUMERO')
    msmGet():new(cAlias,nReg,nOpc,,,,,aPObj[1])
    enchoicebar(oDlg,bSalvar,bCancelar,,aButtons)

    //-- Area de Itens
    oGet := msNewGetDados():new(aPObj[2,1]      ,; //-- Cordanada inicial, Linha inicial
                                aPObj[2,2]      ,; //-- Cordanada inicial, Coluna inicial
                                aPObj[2,3]      ,; //-- Cordanada final, Coluna final
                                aPObj[2,4]      ,; //-- Cordanada final, Linha final
                                nStyle          ,; //-- Opcoes que podem ser executadas
                                'allWaysTrue()' ,; //-- Validacao de mudanca de linha
                                'allWaysTrue()' ,; //-- Validacao final
                                '+Z52_ITEM'     ,; //-- Definicao do campo incremental
                                NIL             ,; //-- Lista dos campos que podem ser alterados
                                0               ,; //-- Fixo
                                9999            ,; //-- Total de linhas
                                'allWaysTrue()' ,; //-- Funcao que validara cada campo preenchido
                                NIL             ,; //-- Fixo
                                'allWaysTrue()' ,; //-- Funcao que ira validar se a linha pode ser deletada
                                oDlg            ,; //-- Objeto proprietario
                                aHeader         ,; //-- Vetor com as configuracoes dos campos
                                aCols           )  //-- Vetor com os conteudos dos campos

    oDlg:activate()

    IF nSalvar = 1

        fnGravar(nOpc)

        IF __lSX8
            confirmSX8()
        EndIF

    Else
        
        IF __lSX8
            rollbbackSX8()
        EndIF

    EndIF

Return

/*/{Protheus.doc} fnGravar
    Funcao auxiliar para gravacao
    @type  Static Function
/*/
Static Function fnGravar(nOpc)

Return 

/*/{Protheus.doc} fnGetHeader
    Funcao que gera as configuracoes dos campos da msNewGetDados
    @type  Static Function
/*/
Static Function fnGetHeader

	Local aHeader := array(0)
	Local aAux	  := array(0)

	SX3->(dbSetOrder(1),dbSeek("Z52"))

	While .not. SX3->(eof()) .and. SX3->X3_ARQUIVO == 'Z52'

        IF alltrim(SX3->X3_CAMPO) $ 'Z52_FILIAL|Z52_NUMERO'
            SX3->(dbSkip())
            Loop
        EndIF

		aAux := {}
		aadd(aAux,SX3->X3_TITULO	)
		aadd(aAux,SX3->X3_CAMPO 	)
		aadd(aAux,SX3->X3_PICTURE	)
		aadd(aAux,SX3->X3_TAMANHO	)
		aadd(aAux,SX3->X3_DECIMAL	)
		aadd(aAux,SX3->X3_VALID		)
		aadd(aAux,SX3->X3_USADO		)
		aadd(aAux,SX3->X3_TIPO		)
		aadd(aAux,SX3->X3_F3		)
		aadd(aAux,SX3->X3_CONTEXT	)
		aadd(aAux,SX3->X3_CBOX		)
		aadd(aAux,SX3->X3_RELACAO	)
		aadd(aAux,SX3->X3_WHEN		)
		aadd(aAux,SX3->X3_VISUAL	)
		aadd(aAux,SX3->X3_VLDUSER	)
		aadd(aAux,SX3->X3_PICTVAR	)
		aadd(aAux,SX3->X3_OBRIGAT	)

		aadd(aHeader,aAux)
		SX3->(dbSkip())

	Enddo
	
Return aHeader

/*/{Protheus.doc} fnGetCols
    Retorna o conteudo do vetor aCols
    @type  Static Function
/*/
Static Function fnGetCols(nOpc,aHeader)

    Local aCols := array(0)
    Local aAux  := array(0)

    IF nOpc == 3 //-- Operacao de inclusao
        aEval(aHeader,{|x| aadd(aAux,criavar(x[2],.T.))})
        aAux[1] := '001'
        aadd(aAux,.F.)
        aadd(aCols,aAux)
        return aCols
    EndIF

    //-- Alteracao + Visualizacao + Exclusao
    Z52->(dbSetOrder(1),dbSeek(Z51->(Z51_FILIAL+Z51_NUMERO)))

    While .not. Z52->(eof()) .and. Z52->(Z52_FILIAL+Z52_NUMERO) == Z51->(Z51_FILIAL+Z51_NUMERO)
        aAux := {}
        aEval(aHeader,{|x| aadd(aAux,Z52->&(x[2]))})
        aadd(aAux,.F.)
        aadd(aCols,aAux)
        Z52->(dbSkip())
    Enddo

Return aCols
