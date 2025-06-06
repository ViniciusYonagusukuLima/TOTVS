#include 'totvs.ch'

/*/{Protheus.doc} U_GCTA004
    Exemplo de funcao markbrow
    @type  Function
    @see https://tdn.totvs.com/display/framework/MarkBrow
    /*/
Function U_GCTA004

    Local aCamposTmp := array(0)

    Private cAliasTmp := getNextAlias()
    Private cAliasSQL := getNextAlias()
    Private cMarca    := getMark()
    Private oTempTable

    Private cCadastro := 'Encerramento de medi��es'
    Private aRotina   := array(0)

    aadd(aRotina,{"Processar","U_PROCESSA_ENCERRAMENTO_MEDICOES()",0,3})

    aadd(aCamposTmp,{"MARK"      ,"C",2                      ,0                      })
    aadd(aCamposTmp,{"Z53_NUMERO","C",tamSX3("Z53_NUMERO")[1],tamSX3("Z53_NUMERO")[2]})
    aadd(aCamposTmp,{"Z53_TIPO"  ,"C",tamSX3("Z53_TIPO"  )[1],tamSX3("Z53_TIPO"  )[2]})
    aadd(aCamposTmp,{"Z53_NUMMED","C",tamSX3("Z53_NUMMED")[1],tamSX3("Z53_NUMMED")[2]})
    aadd(aCamposTmp,{"Z53_EMISSA","D",tamSX3("Z53_EMISSA")[1],tamSX3("Z53_EMISSA")[2]})
    aadd(aCamposTmp,{"Z53_ITEM"  ,"C",tamSX3("Z53_ITEM"  )[1],tamSX3("Z53_ITEM"  )[2]})
    aadd(aCamposTmp,{"Z53_CODPRD","C",tamSX3("Z53_CODPRD")[1],tamSX3("Z53_CODPRD")[2]})
    aadd(aCamposTmp,{"Z53_DESPRD","C",tamSX3("Z53_DESPRD")[1],tamSX3("Z53_DESPRD")[2]})
    aadd(aCamposTmp,{"Z53_QTD"   ,"N",tamSX3("Z53_QTD"   )[1],tamSX3("Z53_QTD"   )[2]})
    aadd(aCamposTmp,{"Z53_VALOR" ,"N",tamSX3("Z53_VALOR" )[1],tamSX3("Z53_VALOR" )[2]})
    aadd(aCamposTmp,{"Z53_PEDIDO","C",tamSX3("Z53_PEDIDO")[1],tamSX3("Z53_PEDIDO")[2]})
    aadd(aCamposTmp,{"Z53_STATUS","C",tamSX3("Z53_STATUS")[1],tamSX3("Z53_STATUS")[2]})

    oTempTable := fwTemporaryTable():new(cAliasTmp,aCamposTmp)
    oTempTable:create()

    BeginSQL alias cAliasSQL
        COLUMN Z53_EMISSA AS DATE
        SELECT * FROM %table:Z53% Z53
        WHERE Z53.%notdel%
        AND Z53_FILIAL = %exp:xFilial("Z53")%
        AND Z53_STATUS <> 'E'
        ORDER BY Z53_FILIAL, Z53_NUMERO, Z53_NUMMED, Z53_ITEM
    EndSQL

    While .not. (cAliasSQL)->(eof())
        
        (cAliasTmp)->(dbAppend())
        (cAliasTmp)->MARK           := cMarca  
        (cAliasTmp)->Z53_NUMERO     := (cAliasSQL)->Z53_NUMERO
        (cAliasTmp)->Z53_TIPO       := (cAliasSQL)->Z53_TIPO
        (cAliasTmp)->Z53_NUMMED     := (cAliasSQL)->Z53_NUMMED
        (cAliasTmp)->Z53_EMISSA     := (cAliasSQL)->Z53_EMISSA
        (cAliasTmp)->Z53_ITEM       := (cAliasSQL)->Z53_ITEM
        (cAliasTmp)->Z53_CODPRD     := (cAliasSQL)->Z53_CODPRD
        (cAliasTmp)->Z53_DESPRD     := (cAliasSQL)->Z53_DESPRD
        (cAliasTmp)->Z53_QTD        := (cAliasSQL)->Z53_QTD
        (cAliasTmp)->Z53_VALOR      := (cAliasSQL)->Z53_VALOR
        (cAliasTmp)->Z53_PEDIDO     := (cAliasSQL)->Z53_PEDIDO
        (cAliasTmp)->Z53_STATUS     := (cAliasSQL)->Z53_STATUS
        (cAliasTmp)->(dbCommit())

        (cAliasSQL)->(dbSkip())

    Enddo

    (cAliasSQL)->(dbCloseArea())
    (cAliasTmp)->(dbGoTop())

    aCampos := array(0)
    aadd(aCampos,{"Z53_NUMERO",,"Contrato"  ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_TIPO"  ,,"Tipo Ctr"  ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_NUMMED",,"Medicao"   ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_EMISSA",,"Dt Emiss"  ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_ITEM"  ,,"Item"      ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_CODPRD",,"Produto"   ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_DESPRD",,"Descricao" ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_QTD"   ,,"Quantidade",getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_VALOR" ,,"Valor"     ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_PEDIDO",,"Pedido"    ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})
    aadd(aCampos,{"Z53_STATUS",,"Status"    ,getSx3Cache("Z53_NUMERO","X3_PICTURE")})    

    markbrow(cAliasTmp,"MARK","U_GCTA004S()",aCampos,.F.,cMarca)

    oTempTable:delete()

return

/*/{Protheus.doc} U_GCTA004S
    Funcao de status
    @type  Function
    /*/
Function U_GCTA004S

    IF (cAliasTmp)->Z53_STATUS == 'E'
        return .T.
    EndIF

Return .F.
