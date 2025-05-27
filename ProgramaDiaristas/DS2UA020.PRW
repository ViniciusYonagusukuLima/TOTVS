#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
---------------------------------------------------------------------------
{Protheus.doc} DS2UA020.prw
ROTINA PARA TRATAMENTO/APURACAO FT CASH

@author  DS2U (VR)
@since   dez.2023
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
User Function DS2UA020(cOption, uParams)
    Local uRet      :=  NIL
    Default cOption := 'BROWSE'


    If cOption == 'BROWSE'
        //------------------------------------------------------
        // FUNCAO 'DEFAULT' PARA CHAMADA DO BRWOSE
        //------------------------------------------------------
        uRet := browseDef()

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
BROWSE PRINCIPAL PARA INICIO DO PROCESSO DE APURACAO

@author  DS2U (VR)
@since   mai-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function browseDef()
    Local oDlg          :=  NIL
    Local oBrowse       :=  NIL
    Local aSize         := FWGetDialogSize(oMainWnd)
    Local cAliasQry     := 'DS2UA020'
    Local cQuery        := ''
    Local aColumns      := {}
    Local aIndex        := {}
    Local aSeek         := {}

    Local bActionApur   := {|| doApurac()}
    Local bActionCons   := {|| viewApurac((cAliasQry)->AA1_CODTEC)}
    Local bActionPrint  := {|| u_DS2UR020()}
    Local bActionNewTit := {|| genPayable()}


    //--MONTA QUERY:
    cQuery := getApurQry()


    //--TRATA COLUNAS DO BROWSE:
    aColumns := getColumns()


    //--TRATA PESQUISA
    aIndex := {'AA1_CODTEC', 'AA1_NOMTEC'}
    aAdd(aSeek, {'Cod. Atendente', {{'', 'C', getSX3Cache('AA1_CODTEC', 'X3_TAMANHO'), 0, 'Cod. Atendente',,}}})
    aAdd(aSeek, {'Nome Atendente', {{'', 'C', getSX3Cache('AA1_NOMTEC', 'X3_TAMANHO'), 0, 'Nome Atendente',,}}})

    //--MONTA JANELA + BROWSE
    DEFINE DIALOG oDlg TITLE 'Apuração Horas - Diaristas' FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL STYLE WS_DLGFRAME

        oBrowse := FWFormBrowse():New()
        
        oBrowse:setOwner(oDlg)
        oBrowse:setDataQuery(.T.)
        oBrowse:setAlias(cAliasQry)
        oBrowse:setQueryIndex(aIndex)
        oBrowse:setQuery(cQuery)
        oBrowse:setColumns(aColumns[1])
        oBrowse:setUseFilter(.T.)
        oBrowse:setFieldFilter(aColumns[2])
    	oBrowse:setSeek(, aSeek)
        oBrowse:setMenuDef('')

        oBrowse:addButton('Realizar Apuração'   , bActionApur,,,, .F., 1)
        oBrowse:addButton('Consultar Apurações' , bActionCons,,,, .F., 1)
        oBrowse:addButton('Listar Apuracoes'    , bActionPrint,,,, .F., 1)
        oBrowse:addButton('Gerar Titulo Avulso' , bActionNewTit,,,, .F., 1)
        
        oBrowse:disableDetails()
        oBrowse:setDescription('Apuração Horas - Diaristas')
        
        oBrowse:Activate()

    ACTIVATE DIALOG oDlg CENTERED


Return


/*/
---------------------------------------------------------------------------
{Protheus.doc} doApurac
REALIZA O PROCESSO DE APURACAO

@author  DS2U (VR)
@since   mai-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function doApurac()
    Local aButtons    := {  {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL},;
                            {.T., 'Salvar Apuração'}, {.T., 'Cancelar'}, {.F., NIL}, {.F., NIL},; 
                            {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL} }

    FWExecView('Apuração de Horas - Diaristas', 'VIEWDEF.DS2UA021', MODEL_OPERATION_UPDATE,,,, 40, aButtons)

Return


/*/
---------------------------------------------------------------------------
{Protheus.doc} viewApurac
CONSULTA APURACOES E REALIZA A INTEGRACAO FINANCEIRA

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function viewApurac(cCodTec)
    u_DS2UA022('BROWSE', cCodTec)

Return


/*/
---------------------------------------------------------------------------
{Protheus.doc} getApurQry
MONTA QUERY PARA EXIBICAO DOS DADOS NO BROWSE PRINCIPAL

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function getApurQry()
    Local cQuery := ''

    cQuery := "SELECT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_FUNCAO, SRJ.RJ_DESC, AA1.AA1_CODFOR, AA1.AA1_LOJFOR, SA2.A2_NOME, SA2.A2_NREDUZ "
    cQuery += "  FROM " + RetSQLTab('AA1')
    cQuery += "  JOIN " + RetSQLTab('SRJ')
    cQuery += "    ON SRJ.RJ_FILIAL = '" + xFilial('SRJ') + "'
    cQuery += "   AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO "
    cQuery += "   AND SRJ.D_E_L_E_T_ = ' ' "
    cQuery += "  JOIN " + RetSQLTab('SA2')
    cQuery += "    ON SA2.A2_FILIAL = '" + xFilial('SA2') + "' "
    cQuery += "   AND SA2.A2_COD = AA1.AA1_CODFOR "
    cQuery += "   AND SA2.A2_LOJA = AA1.AA1_LOJFOR "
    cQuery += "   AND SA2.D_E_L_E_T_=  ' ' "
    cQuery += " WHERE AA1.AA1_FILIAL = '" + xFilial('AA1') + "' "
    cQuery += "   AND AA1.AA1_CDFUNC = ' ' "
    cQuery += "   AND AA1.AA1_CODFOR <> ' ' "
    cQuery += "   AND AA1.AA1_LOJFOR <> ' ' "
    cQuery += "   AND AA1.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY AA1.AA1_NOMTEC "

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
    Local aCampos  := {'AA1_CODTEC', 'AA1_NOMTEC', 'AA1_FUNCAO', 'RJ_DESC', 'AA1_CODFOR', 'AA1_LOJFOR', 'A2_NOME', 'A2_NREDUZ'}
    Local nCountA  := 0

    For nCountA := 1 To Len(aCampos)
        aAdd(aColumns, FWBrwColumn():New())
        aTail(aColumns):setType(getSX3Cache(aCampos[nCountA], 'X3_TIPO'))
        aTail(aColumns):setTitle(getSX3Cache(aCampos[nCountA], 'X3_TITULO'))
        aTail(aColumns):setSize(getSX3Cache(aCampos[nCountA], 'X3_TAMANHO'))
        aTail(aColumns):setDecimal(getSX3Cache(aCampos[nCountA], 'X3_DECIMAL'))
        aTail(aColumns):setPicture(getSX3Cache(aCampos[nCountA], 'X3_PICTURE'))
        aTail(aColumns):setData(&("{||" + aCampos[nCountA] + "}"))

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
{Protheus.doc} genPayable
REALIZA A GERACAO DE UM TITULO AVULSO CONTRA O ATENDENTE
(S/ VINCULO COM CONTRATO)

@author  DS2U (VR)
@since   abr-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
Static Function genPayable()
    Local aParams   := {}
    Local aDados    := {}
    Local cNumTit   := ''
    Local cPIXType  := ''
    Local cPIXKey   := ''
    Local cAliasQry := ''


    aAdd(aParams, { 1,; 
                    'Prefixo Titulo',; 
                    PadR('FTA', TamSX3('E2_PREFIXO')[1]),;
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

    aAdd(aParams, { 1,; 
                    'Valor Titulo',; 
                    0,;
                    PesqPict('SE2', 'E2_VALOR'),; 
                    'positivo()',;
                    '',;
                    '',; 
                    70,; 
                    .T. }) //-- MV_PAR05

    aAdd(aParams, { 1,; 
                    'Historico',; 
                    PadR('', TamSX3('E2_HIST')[1]),;
                    PesqPict('SE2', 'E2_HIST'),; 
                    '',;
                    '',;
                    '',; 
                    90,; 
                    .T. }) //-- MV_PAR06


    If paramBox(aParams, 'Parâmetros') .And. FWAlertYesNo('Confirma geracao do título?', 'Título Avulso')

        //--GERA Nro DO TITULO
        cAliasQry := getNextAlias()
        beginSQL alias cAliasQry
            SELECT MAX(SE2.E2_NUM) E2_NUM
              FROM %Table:SE2% SE2
             WHERE SE2.E2_FILIAL = %xFilial:SE2%
               AND SE2.E2_PREFIXO = 'FTA'
               AND SE2.E2_FORNECE = %Exp:DS2UA020->AA1_CODFOR%
               AND SE2.E2_LOJA = %Exp:DS2UA020->AA1_LOJFOR%
               AND SE2.%notDEL%
        endSQL

        cNumTit := If(empty((cAliasQry)->E2_NUM), '000000001', soma1((cAliasQry)->E2_NUM))

        (cAliasQry)->(dbCloseArea())


        //--OBTEM A CHAVE PIX DO ATENDENTE
        F72->(dbSetOrder(3)) //--F72_FILIAL+F72_ACTIVE+F72_COD+F72_LOJA
        If F72->(dbSeek(xFilial('F72')+'1'+DS2UA020->(AA1_CODFOR+AA1_LOJFOR)))
            cPIXType := F72->F72_TPCHV
            cPIXKey  := F72->F72_CHVPIX
        EndIf


        //--MONTA DADOS P/ EXECAUTO
        aDados := { {'E2_FILIAL'    , FWxFilial("SE2")          , NIL},;
                    {'E2_PREFIXO'   , MV_PAR01                  , NIL},;
                    {'E2_NUM'       , cNumTit                   , NIL},;
                    {'E2_PARCELA'   , CriaVar('E2_PARCELA', .F.), NIL},;
                    {'E2_TIPO'      , MV_PAR02                  , NIL},;
                    {'E2_NATUREZ'   , MV_PAR03                  , NIL},;
                    {'E2_FORNECE'   , DS2UA020->AA1_CODFOR       , NIL},;
                    {'E2_LOJA'      , DS2UA020->AA1_LOJFOR       , NIL},;
                    {'E2_EMISSAO'   , dDataBase                 , NIL},;
                    {'E2_VENCTO'    , MV_PAR04                  , NIL},;
                    {'E2_VALOR'     , MV_PAR05                  , NIL},;
                    {'E2_PIXTIPO'   , cPIXType                  , NIL},;
                    {'E2_PIXKEY'    , cPIXKey                   , NIL},;
                    {'E2_HIST'      , allTrim(MV_PAR06)         , NIL} }


        lMSErroauto := .F.
        MsgRun('Processando Integraçãoo...', 'Aguarde...', {|| MSExecAuto({|x,y,z| FINA050(x,y,z)}, aDados, NIL, 3)})
        If lMSErroauto
            FWAlertError('Ocorreu um erro ao tentar realizar a Integração Financeira. Detalhes do erro serão apresentados a seguir...', 'Erro na Integração')
            mostraErro()
        Else
            FWAlertSuccess('Título gerado com sucesso! Nro. do Título FTA/' + cNumTit)
        
        EndIf

    Else
        FWAlertWarning('Processo cancelado pelo usuário!', 'Título Avulso')

    EndIf


Return
