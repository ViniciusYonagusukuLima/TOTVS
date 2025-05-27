#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
---------------------------------------------------------------------------
{Protheus.doc} LSAA022.prw
CONSULTA E INTEGRACAO FINANCEIRA DAS APURACOES FT CASH

@author  DS2U (VR)
@since   mai-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
User Function DS2UA022(cOption, uParams)
    Local uRet      :=  NIL
    Default cOption := 'BROWSE'


    If cOption == 'BROWSE'
        //------------------------------------------------------
        // FUNCAO 'DEFAULT' PARA CHAMADA DO BRWOSE
        //------------------------------------------------------
        uRet := browseDef(uParams)

    EndIf

Return(uRet)


// -------------------------------------------------------------------------------------------------------
//
// TRATAMENTO DAS FUNCOES
//
// -------------------------------------------------------------------------------------------------------


/*/
---------------------------------------------------------------------------
{Protheus.doc} browseDef
BROWSE PRINCIPAL PARA INICIO DO PROCESSO DE INTEGRACAO FINANCEIRA

@author  DS2U (VR)
@since   mai-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function browseDef(cCodTec)
    Local oDlg         :=  NIL
    Local oBrowse      :=  NIL
    Local aSize        := {00, 00, 700, 1200}
    Local cAliasQry    := getNextAlias()
    Local cQuery       := ''
    Local aColumns     := {}
    Local bLegenda     := {|| If((cAliasQry)->PA1_STATUS == '0', 'BR_VERDE', 'BR_VERMELHO')}

    Local bActionCanc  := {|| cancelApurac((cAliasQry)->PA1Recno, oBrowse)}
    Local bActionInteg := {|| integrApurac((cAliasQry)->PA1Recno, oBrowse)}
    Local bActionLeg   := {|| showLegend()}


    //--MONTA QUERY:
    cQuery := getApuracQry(cCodTec)


    //--TRATA COLUNAS DO BROWSE:
    aColumns := getColumns()


    //--MONTA JANELA + BROWSE
    DEFINE DIALOG oDlg TITLE 'Consulta & Integração Financeira - Apuracao Horas - Diaristas' FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL

        oBrowse := FWFormBrowse():New()
        
        oBrowse:setOwner(oDlg)
        oBrowse:setDataQuery(.T.)
        oBrowse:setAlias(cAliasQry)
        oBrowse:setQuery(cQuery)
        oBrowse:addStatusColumns(bLegenda, {|| showLegend()})
        oBrowse:setColumns(aColumns[1])
        oBrowse:setUseFilter(.T.)
        oBrowse:setFieldFilter(aColumns[2])
        
        oBrowse:addButton('Cancelar Apuração', bActionCanc,,,, .F., 1)
        oBrowse:addButton('Integrar/Cancelar Integração Financeira', bActionInteg,,,, .F., 1)
        oBrowse:addButton('Legenda', bActionLeg,,,, .F., 1)
        
        oBrowse:disableDetails()
        oBrowse:setDescription('Consulta & Integração Financeira')
        
        oBrowse:Activate()

    ACTIVATE DIALOG oDlg CENTERED


Return


/*/
---------------------------------------------------------------------------
{Protheus.doc} getApuracQry
MONTA QUERY PARA EXIBICAO DOS DADOS NO BROWSE PRINCIPAL

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function getApuracQry(cCodTec)
    Local cQuery := ''

    cQuery := "SELECT PA1.PA1_STATUS, PA1.PA1_CODAPU, PA1.PA1_DTAPUR, PA1.PA1_CODTEC, AA1.AA1_NOMTEC, PA1.PA1_PRFTIT, "
    cQuery += "       PA1.PA1_NUMTIT, PA1.PA1_PRCTIT, PA1.PA1_TPTIT, PA1.PA1_FORNEC, PA1.PA1_LOJA, SA2.A2_NOME, "
    cQuery += "       SA2.A2_NREDUZ, PA1.PA1_NATTIT, PA1.PA1_HRSAPU, PA1.PA1_VLRHR, PA1.PA1_VLAPUR, " 
    cQuery += "       PA1.PA1_VLPAGO, PA1.R_E_C_N_O_ PA1Recno "

    cQuery += "  FROM " + RetSQLTab('PA1')

    cQuery += "  JOIN " + RetSQLTab('AA1')
    cQuery += "    ON AA1.AA1_FILIAL = '" + xFilial('AA1') + "' "
    cQuery += "   AND AA1.AA1_CODTEC = PA1.PA1_CODTEC "
    cQuery += "   AND AA1.D_E_L_E_T_ = ' ' "

    cQuery += "  JOIN " + RetSQLTab('SA2') 
    cQuery += "    ON SA2.A2_FILIAL = '" + xFilial('SA2') + "' "
    cQuery += "   AND SA2.A2_COD = PA1.PA1_FORNEC "
    cQuery += "   AND SA2.A2_LOJA = PA1.PA1_LOJA "
    cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE PA1.PA1_FILIAL = '" + xFilial('PA1') + "' "
    cQuery += "   AND PA1.PA1_CODTEC = '" + cCodTec + "' "
    cQuery += "   AND PA1.D_E_L_E_T_ = ' ' "

    cQuery += " ORDER BY PA1.PA1_STATUS"

    cQuery := ChangeQuery(cQuery)


Return(cQuery)


/*/
---------------------------------------------------------------------------
{Protheus.doc} getColumns
RETORNA COLUNAS PARA SEREM CONSIDERADAS NO BROWSE

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function getColumns()
    Local aColumns := {}
    Local aFilter  := {}
    Local aRet     := {}
    Local aCampos  := {}
    Local nCountA  := 0


    aCampos := { 'PA1_CODAPU', 'PA1_DTAPUR', 'PA1_CODTEC', 'AA1_NOMTEC', 'PA1_PRFTIT', 'PA1_NUMTIT',; 
                'PA1_PRCTIT', 'PA1_TPTIT', 'PA1_NATTIT', 'PA1_FORNEC', 'PA1_LOJA', 'A2_NOME',;
                'A2_NREDUZ', 'PA1_HRSAPU', 'PA1_VLRHR', 'PA1_VLAPUR', 'PA1_VLPAGO' } 


    For nCountA := 1 To Len(aCampos)
        aAdd(aColumns, FWBrwColumn():New())
        aTail(aColumns):setType(getSX3Cache(aCampos[nCountA], 'X3_TIPO'))
        aTail(aColumns):setTitle(getSX3Cache(aCampos[nCountA], 'X3_TITULO'))
        aTail(aColumns):setSize(getSX3Cache(aCampos[nCountA], 'X3_TAMANHO'))
        aTail(aColumns):setDecimal(getSX3Cache(aCampos[nCountA], 'X3_DECIMAL'))
        aTail(aColumns):setPicture(getSX3Cache(aCampos[nCountA], 'X3_PICTURE'))
        aTail(aColumns):setData(&("{|| " + aCampos[nCountA] + "}"))

        aAdd(aFilter, { aCampos[nCountA],;
                        getSX3Cache(aCampos[nCountA], 'X3_TITULO'),;
                        getSX3Cache(aCampos[nCountA], 'X3_TIPO'),;
                        getSX3Cache(aCampos[nCountA], 'X3_TAMANHO'),;
                        getSX3Cache(aCampos[nCountA], 'X3_DECIMAL'),;
                        getSX3Cache(aCampos[nCountA], 'X3_PICTURE') })

    Next nCountA

    aRet := {aColumns, aFilter}

Return(aRet)


/*/
---------------------------------------------------------------------------
{Protheus.doc} showLegend
EXIBE INFORMACOES REFERENTE A LEGENDAS

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function showLegend()
    Local oLegenda	:= FWLegend():New()

    oLegenda:Add("", "BR_VERDE",    'Não Integrado')
    oLegenda:Add("", "BR_VERMELHO", 'Integrado')

    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()

Return


/*/
---------------------------------------------------------------------------
{Protheus.doc} cancelApurac
CANCELA A APURACAO

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function cancelApurac(nPA1Recno, oBrowse)
    Local cAliasQry := ''
    Local aAreaABB  := ABB->(getArea())

    PA1->(dbGoTo(nPA1Recno))
    If PA1->PA1_STATUS == '0' .And. MsgYesNo('Deseja cancelar a Apuração posicionada? (Esta ação não poderá ser desfeita)')
        cAliasQry := getNextAlias()
        BeginSQL Alias cAliasQry
            SELECT ABB.R_E_C_N_O_ ABBRecno
              FROM %Table:ABB% ABB
             WHERE ABB.ABB_APURFT = %Exp:PA1->PA1_CODAPU%
               AND ABB.%notDEL%
        EndSQL

        Begin Transaction
            While !(cAliasQry)->(Eof())
                ABB->(dbGoTo((cAliasQry)->ABBRecno))
                RecLock('ABB', .F.)
                ABB->ABB_APURFT := ''
                ABB->(MsUnLock())

                (cAliasQry)->(dbSkip())
            End

            RecLock('PA1', .F.)
            PA1->(dbDelete())
            PA1->(MsUnLock())
        End Transaction

        (cAliasQry)->(dbCloseArea())
        
        MsgInfo('Apuração cancelada com sucesso!')


    ElseIf PA1->PA1_STATUS == '1'
        MsgAlert('É necessário que seja realizado o cancelamento da Integração Financeira ates de cancelar a apuração')

    EndIf


    //-- ATUALIZA BROWSE
    oBrowse:Refresh()
    oBrowse:ExecuteFilter(.T.)
    oBrowse:UpdateBrowse()

    RestArea(aAreaABB)

Return


/*/
---------------------------------------------------------------------------
{Protheus.doc} integrApurac
REALIZA OU CANCELA A INTEGRACAO FINANCEIRA

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function integrApurac(nPA1Recno, oBrowse)
    Local aDados    := {}
    Local aParams   := {}
    Local cHist     := ''
    Local cAliasQry := ''
    Local nOpc      := 0
    Local lContinua := .T.

    PA1->(dbGoTo(nPA1Recno))
    If PA1->PA1_STATUS == '0'
        aAdd(aParams, { 1,; 
                        'Prefixo Titulo',; 
                        PadR('FT', TamSX3('E2_PREFIXO')[1]),;
                        PesqPict('SE2', 'E2_PREFIXO'),;
                        '',;
                        '',;
                        '',; 
                        40,; 
                        .T. }) //-- MV_PAR01

        aAdd(aParams, { 1,; 
                        'Tipo Titulo',; 
                        PadR('DP', TamSX3('E2_TIPO')[1]),; 
                        PesqPict('SE2', 'E2_TIPO'),;
                        'ExistCpo("SX5", "05" + MV_PAR02)',;
                        '05',;
                        '',; 
                        35,; 
                        .T. }) //-- MV_PAR02

        aAdd(aParams, { 1,; 
                        'Natureza',; 
                        PadR('', TamSX3('E2_NATUREZ')[1]),; 
                        PesqPict('SE2', 'E2_NATUREZ'),; 
                        'ExistCpo("SED", MV_PAR03)',; 
                        'SED',;
                        '',; 
                        80,;
                        .T. }) //-- MV_PAR03

        aAdd(aParams, { 1,; 
                        'Vencimento',; 
                        StoD(Space(10)),;
                        '',;
                        'MV_PAR04 >= dDataBase',;
                        '',;
                        '',; 
                        70,; 
                        .T. }) //-- MV_PAR04

        lContinua := ParamBox(aParams, 'Parâmetros')

    ElseIf PA1->PA1_STATUS == '1'
        lContinua := MsgYesNo('Cancelar a Integração Financeira vinculada à esta apuração?')

    EndIf


    If lContinua
        If PA1->PA1_STATUS == '0'
            cAliasQry := getNextAlias()
            BeginSQL Alias cAliasQry
                SELECT DISTINCT ABB.ABB_APURFT, ABQ.ABQ_CONTRT, ABB.ABB_LOCAL, ABS.ABS_DESCRI
                  FROM %Table:ABB% ABB
                  JOIN %Table:ABQ% ABQ
                    ON SUBSTRING(ABQ.ABQ_FILIAL , 1 , 4) = SUBSTRING(ABB.ABB_FILIAL , 1 , 4)
                   AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
                   AND ABQ.%notDEL%
                  JOIN %Table:ABS% ABS
                    ON ABS.ABS_FILIAL = %xFilial:ABS%
                   AND ABS.ABS_LOCAL = ABB.ABB_LOCAL
                   AND ABS.%notDEL%
                 WHERE ABB.ABB_APURFT = %Exp:PA1->PA1_CODAPU%
                   AND ABB.%notDEL%
            EndSQL

            While !(cAliasQry)->(Eof())
                cHist += 'CONTRATO: ' + (cAliasQry)->ABQ_CONTRT + ' - LOCAL: ' + AllTrim(ABS_DESCRI)
                (cAliasQry)->(dbSkip())
                If !(cAliasQry)->(Eof())
                    cHist += ' | '
                EndIf
            End

            (cAliasQry)->(dbCloseArea())


            nOpc := 3
            aDados := { {'E2_FILIAL'    , FWxFilial("SE2")          , NIL},;
                        {'E2_PREFIXO'   , MV_PAR01                  , NIL},;
                        {'E2_NUM'       , PA1->PA1_CODAPU           , NIL},;
                        {'E2_PARCELA'   , CriaVar('E2_PARCELA', .F.), NIL},;
                        {'E2_TIPO'      , MV_PAR02                  , NIL},;
                        {'E2_NATUREZ'   , MV_PAR03                  , NIL},;
                        {'E2_FORNECE'   , PA1->PA1_FORNEC           , NIL},;
                        {'E2_LOJA'      , PA1->PA1_LOJA             , NIL},;
                        {'E2_EMISSAO'   , dDataBase                 , NIL},;
                        {'E2_VENCTO'    , MV_PAR04                  , NIL},;
                        {'E2_VALOR'     , PA1->PA1_VLPAGO           , NIL},;
                        {'E2_HIST'      , cHist                     , NIL} }

        ElseIf PA1->PA1_STATUS == '1'
            nOpc   := 5
            aDados := { {'E2_FILIAL'    , FWxFilial("SE2")  , NIL},;
                        {'E2_PREFIXO'   , PA1->PA1_PRFTIT   , NIL},;
                        {'E2_NUM'       , PA1->PA1_CODAPU   , NIL},;
                        {'E2_PARCELA'   , PA1->PA1_PRCTIT   , NIL},;
                        {'E2_TIPO'      , PA1->PA1_TPTIT    , NIL},;
                        {'E2_FORNECE'   , PA1->PA1_FORNEC   , NIL},;
                        {'E2_LOJA'      , PA1->PA1_LOJA     , NIL} }

        EndIf

        lMsErroauto := .F.
        MsgRun('Processando Integraçãoo...', 'Aguarde...', {|| MsExecAuto({|x,y,z| FINA050(x,y,z)}, aDados, NIL, nOpc)})
        If lMsErroauto
            If PA1->PA1_STATUS == '0'
                MsgAlert('Ocorreu um erro ao tentar realizar a Integração Financeira. Detalhes do erro serão apresentados a seguir...')
            Else
                MsgAlert('Ocorreu um erro ao tentar realizar o cancelamento da Integração Financeira. Detalhes do erro serão apresentados a seguir...')
            EndIf
            MostraErro()
        
        Else
            If PA1->PA1_STATUS == '0'
                RecLock('PA1', .F.)
                PA1->PA1_STATUS := '1'
                PA1->PA1_PRFTIT := MV_PAR01
                PA1->PA1_NUMTIT := PA1->PA1_CODAPU
                PA1->PA1_PRCTIT := CriaVar('E2_PARCELA', .F.)
                PA1->PA1_TPTIT  := MV_PAR02
                PA1->PA1_NATTIT := MV_PAR03
                PA1->(MsUnLock())
        
                MsgInfo('Integração Financeira realizada com sucesso!')
            
            ElseIf PA1->PA1_STATUS == '1'
                RecLock('PA1', .F.)
                PA1->PA1_STATUS := '0'
                PA1->PA1_PRFTIT := ''
                PA1->PA1_NUMTIT := ''
                PA1->PA1_PRCTIT := ''
                PA1->PA1_TPTIT  := ''
                PA1->PA1_NATTIT := ''
                PA1->(MsUnLock())
        
                MsgInfo('Integração Financeira cancelada com sucesso!')

            EndIf        
            
        EndIf

    EndIf

    //-- ATUALIZA BROWSE
    oBrowse:Refresh()
    oBrowse:ExecuteFilter(.T.)
    oBrowse:UpdateBrowse()


Return
