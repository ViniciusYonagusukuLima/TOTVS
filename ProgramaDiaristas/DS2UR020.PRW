#INCLUDE 'PROTHEUS.CH'

/*/
--------------------------------------------------------------------------------
{Protheus.doc} DS2UR020
LISTA DADOS DA APURACAO HORAS DIARISTAS

@author DS2U [V. Raspa]
@since mai.2021
@version 1.0
@type function
--------------------------------------------------------------------------------
/*/
User Function DS2UR020()
    Local oReport := NIL
    Local aArea   := GetArea()

    If FindFunction("TRepInUse") .And. TRepInUse()
        oReport := ReportDef()
        oReport:PrintDialog()
    EndIf

    //--RESTAURA AMBIENTE
    RestArea(aArea)

Return


/*/
--------------------------------------------------------------------------------
{Protheus.doc} ReportDef()
Funcao responsavel pelas celulas do relatorio TReport
@author DS2U [VR]
@since mai.2020
@version 1.0
@type function
--------------------------------------------------------------------------------
/*/
Static Function ReportDef()
    Local oReport    := NIL
    Local oSecApur   := NIL
    Local oSecAgenda := NIL
    Local cPerg      := PadR('DS2UR020', Len(SX1->X1_GRUPO))
    Local aCamposPA1 := {}
    Local aCamposABB := {}
    Local nCountA    := 0
    Local cAliasQry  := GetNextAlias()

    oReport := TReport():New('DS2UR020', 'Apurações FT Cash', cPerg, {|oReport| ReportPrint(@oReport, cAliasQry)},; 
                                'Este relatório irá listar os dados da Apuração de Horas (Diaristas) posicionada no Browse')

    oReport:SetTotalInLine(.F.)
    oReport:SetLandscape()


    // -------------------------------------------------------
    // PARAMETROS
    // -------------------------------------------------------
    // MV_PAR01 : DA APURCAO
    // MV_PAR02 : ATE A APURACAO
    // MV_PAR03 : DA DATA DE APURACAO
    // MV_PAR04 : ATE A DATA DE APURACAO
    // MV_PAR05 : DO ATENDENTE
    // MV_PAR06 : ATE O ATENDENTE
    // ------------------------------------------------------- 
    Pergunte(cPerg, .F.)


    aCamposPA1 := { {'PA1', 'PA1_STATUS'    , 15                        , {|| If((cAliasQry)->PA1_STATUS == '0', 'NAO INTEGRADO', 'INTEGRADO')}},;
                    {'PA1', 'PA1_CODAPU'    , TamSX3('PA1_CODAPU')[1]   , {|| (cAliasQry)->PA1_CODAPU}},;
                    {'PA1', 'PA1_DTAPUR'    , TamSX3('PA1_DTAPUR')[1]   , {|| (cAliasQry)->PA1_DTAPUR}},;
                    {'PA1', 'PA1_CODTEC'    , TamSX3('PA1_CODTEC')[1]   , {|| (cAliasQry)->PA1_CODTEC}},;
                    {'AA1', 'AA1_NOMTEC'    , TamSX3('AA1_NOMTEC')[1]   , {|| (cAliasQry)->AA1_NOMTEC}},;
                    {'AA1', 'AA1_FUNCAO'    , TamSX3('AA1_FUNCAO')[1]   , {|| (cAliasQry)->AA1_FUNCAO}},;
                    {'SRJ', 'RJ_DESC'       , TamSX3('RJ_DESC')[1]      , {|| (cAliasQry)->RJ_DESC}},;
                    {'PA1', 'PA1_FORNEC'    , TamSX3('PA1_FORNEC')[1]   , {|| (cAliasQry)->PA1_FORNEC}},;
                    {'PA1', 'PA1_LOJA'      , TamSX3('PA1_LOJA')[1]     , {|| (cAliasQry)->PA1_LOJA}},;
                    {'SA2', 'A2_NREDUZ'     , TamSX3('A2_NREDUZ')[1]    , {|| (cAliasQry)->A2_NREDUZ}},;
                    {'SA2', 'A2_BANCO'      , TamSX3('A2_BANCO')[1]     , {|| (cAliasQry)->A2_BANCO}},;
                    {'SA2', 'A2_AGENCIA'    , TamSX3('A2_AGENCIA')[1]   , {|| (cAliasQry)->A2_AGENCIA}},;
                    {'SA2', 'A2_NUMCON'     , TamSX3('A2_NUMCON')[1]    , {|| (cAliasQry)->A2_NUMCON}},;
                    {'F72', 'F72_TPCHV'     , 25                        , {|| (cAliasQry)->F72_TPCHV}},;
                    {'F72', 'F72_CHVPIX'    , TamSX3('F72_CHVPIX')[1]   , {|| (cAliasQry)->F72_CHVPIX}},;
                    {'PA1', 'PA1_PRFTIT'    , TamSX3('PA1_PRFTIT')[1]   , {|| (cAliasQry)->PA1_PRFTIT}},;
                    {'PA1', 'PA1_NUMTIT'    , TamSX3('PA1_NUMTIT')[1]   , {|| (cAliasQry)->PA1_NUMTIT}},;
                    {'PA1', 'PA1_PRCTIT'    , TamSX3('PA1_PRCTIT')[1]   , {|| (cAliasQry)->PA1_PRCTIT}},;
                    {'PA1', 'PA1_TPTIT'     , TamSX3('PA1_TPTIT')[1]    , {|| (cAliasQry)->PA1_TPTIT}},;
                    {'PA1', 'PA1_NATTIT'    , TamSX3('PA1_NATTIT')[1]   , {|| (cAliasQry)->PA1_NATTIT}},;
                    {'PA1', 'ED_DESCRIC'    , TamSX3('ED_DESCRIC')[1]   , {|| (cAliasQry)->ED_DESCRIC}},;
                    {'PA1', 'PA1_VLRHR'     , TamSX3('PA1_VLRHR')[1]    , {|| (cAliasQry)->PA1_VLRHR}},;
                    {'PA1', 'PA1_HRSAPU'    , TamSX3('PA1_HRSAPU')[1]   , {|| (cAliasQry)->PA1_HRSAPU}},;
                    {'PA1', 'PA1_VLAPUR'    , TamSX3('PA1_VLAPUR')[1]   , {|| (cAliasQry)->PA1_VLAPUR}},;
                    {'PA1', 'PA1_VLPAGO'    , TamSX3('PA1_VLPAGO')[1]   , {|| (cAliasQry)->PA1_VLPAGO}} }

    aCamposABB := { {'TDV', 'TDV_DTREF'     , TamSX3('TDV_DTREF')[1]    , {|| (cAliasQry)->TDV_DTREF}},;
                    {'ABB', 'ABB_HRINI'     , TamSX3('ABB_HRINI')[1]    , {|| (cAliasQry)->ABB_HRINI}},;
                    {'ABB', 'ABB_HRFIM'     , TamSX3('ABB_HRFIM')[1]    , {|| (cAliasQry)->ABB_HRFIM}},;
                    {'ABB', 'ABB_HRTOT'     , TamSX3('ABB_HRTOT')[1]    , {|| (cAliasQry)->ABB_HRTOT}},;
                    {'ABQ', 'ABQ_CONTRT'    , TamSX3('ABQ_CONTRT')[1]   , {|| (cAliasQry)->ABQ_CONTRT}},;
                    {'SA1', 'A1_NREDUZ'     , TamSX3('A1_NREDUZ')[1]    , {|| (cAliasQry)->A1_NREDUZ}},;
                    {'ABB', 'ABB_LOCAL'     , TamSX3('ABB_LOCAL')[1]    , {|| (cAliasQry)->ABB_LOCAL}},;
                    {'ABS', 'ABS_DESCRI'    , TamSX3('ABS_DESCRI')[1]   , {|| (cAliasQry)->ABS_DESCRI}},;
                    {'TFF', 'TFF_ESCALA'    , TamSX3('TFF_ESCALA')[1]   , {|| (cAliasQry)->TFF_ESCALA}},;
                    {'TDW', 'TDW_DESC'      , TamSX3('TDW_DESC')[1]     , {|| (cAliasQry)->TDW_DESC}},;
                    {'ABB', 'ABB_TIPOMV'    , TamSX3('ABB_TIPOMV')[1]   , {|| (cAliasQry)->ABB_TIPOMV}},;
                    {'TCU', 'TCU_DESC'      , TamSX3('TCU_DESC')[1]     , {|| (cAliasQry)->TCU_DESC}},;
                    {'ABB', 'ABB_FILIAL'    , TamSX3('ABB_FILIAL')[1]   , {|| (cAliasQry)->ABB_FILIAL}} }

    // -------------------------------------------------------
    // SECAO 01: DADOS DA APURACAO
    // -------------------------------------------------------
    oSecApur := TRSection():New(oReport, 'Apurações', {}, {}, .F., .F.,,, .F.,,, .T.,, .T., 2)
    For nCountA := 1 To Len(aCamposPA1)
        TRCell():New( oSecApur,; 
                    aCamposPA1[nCountA, 2],; 
                    '',; 
                    RetSX3Tit(aCamposPA1[nCountA, 2]),; 
                    PesqPict(aCamposPA1[nCountA, 1], aCamposPA1[nCountA, 2]),; 
                    aCamposPA1[nCountA, 3],; 
                    NIL,; 
                    aCamposPA1[nCountA, 4] )
    Next nCountA
    oSecApur:SetPageBreak(.T.)

    // -------------------------------------------------------
    // SECAO 03: AGENDAS
    // -------------------------------------------------------
    oSecAgenda := TRSection():New(oSecApur, 'Agendas', {}, {}, .F., .F.,,, .F.)
    For nCountA := 1 To Len(aCamposABB)
        TRCell():New( oSecAgenda,; 
                    aCamposABB[nCountA, 2],; 
                    '',; 
                    RetSX3Tit(aCamposABB[nCountA, 2]),; 
                    PesqPict(aCamposABB[nCountA, 1], aCamposABB[nCountA, 2]),; 
                    aCamposABB[nCountA, 3],; 
                    NIL,; 
                    aCamposABB[nCountA, 4] )
    Next nCountA

Return(oReport)


/*/
--------------------------------------------------------------------------------
{Protheus.doc} ReportPrint()
Rotina impressao dos dados do relatorio
@author DS2U [VR]
@since out.2020
@version 1.0
@type function
--------------------------------------------------------------------------------
/*/
Static Function ReportPrint(oReport, cAliasQry)
    Local oSecApur   := oReport:Section(1)
    Local oSecAgenda := oSecApur:Section(1)

    oSecApur:BeginQuery()
    BeginSQL Alias cAliasQry
        SELECT PA1.*, AA1.AA1_NOMTEC, AA1.AA1_FUNCAO, SRJ.RJ_DESC, SA2.A2_NREDUZ, SA2.A2_BANCO, SA2.A2_AGENCIA, SA2.A2_NUMCON, 
               CASE WHEN F72.F72_TPCHV = '01' THEN 'TELEFONE'
                    WHEN F72.F72_TPCHV = '02' THEN 'E-MAIL'
                    WHEN F72.F72_TPCHV = '03' THEN 'CPF/CNPJ'
                    WHEN F72.F72_TPCHV = '04' THEN 'CHAVE ALEATORIA' END F72_TPCHV,
               F72.F72_CHVPIX,
               SED.ED_DESCRIC, TDV.TDV_DTREF, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_HRTOT, ABQ.ABQ_CONTRT, SA1.A1_NREDUZ,
               ABB.ABB_LOCAL, ABS.ABS_DESCRI, TFF.TFF_ESCALA, TDW.TDW_DESC, ABB.ABB_TIPOMV, TCU.TCU_DESC, ABB.ABB_FILIAL
        
          FROM %Table:PA1% PA1

          JOIN %Table:AA1% AA1
            ON AA1.AA1_FILIAL = %xFilial:AA1%
           AND AA1.AA1_CODTEC = PA1.PA1_CODTEC
           AND AA1.%notDEL%

          JOIN %Table:SRJ% SRJ
            ON SRJ.RJ_FILIAL = ' '
           AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
           AND SRJ.%notDEL%
        
          JOIN %Table:SA2% SA2
            ON SA2.A2_FILIAL = %xFilial:SA2%
           AND SA2.A2_COD = PA1.PA1_FORNEC
           AND SA2.A2_LOJA = PA1.PA1_LOJA
           AND SA2.%notDEL%

          LEFT JOIN %Table:F72% F72
            ON F72.F72_FILIAL = %xFilial:F72%
           AND F72.F72_COD = SA2.A2_COD
           AND F72.F72_LOJA = SA2.A2_LOJA
           AND F72.F72_ACTIVE = '1'
           AND F72.%notDEL%

          LEFT JOIN %Table:SED% SED
            ON SED.ED_FILIAL = %xFilial:SED%
           AND SED.ED_CODIGO = PA1.PA1_NATTIT
           AND SED.%notDEL%

          JOIN %Table:ABB% ABB
            ON ABB.ABB_APURFT = PA1.PA1_CODAPU
           AND ABB.%notDEL%

          JOIN %Table:TDV% TDV
            ON TDV.TDV_FILIAL = ABB.ABB_FILIAL
           AND TDV.TDV_CODABB = ABB.ABB_CODIGO
           AND TDV.%notDEL%

          JOIN %Table:ABQ% ABQ
            ON ABQ.ABQ_FILIAL = ' '
           AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL           
           AND ABQ.%notDEL%

          JOIN %Table:TFF% TFF
            ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
           AND TFF.TFF_COD = ABQ.ABQ_CODTFF
           AND TFF.%notDEL%

          JOIN %Table:TDW% TDW
            ON TDW.TDW_FILIAL = %xFilial:TDW%
           AND TDW.TDW_COD = TFF.TFF_ESCALA
           AND TDW.%notDEL%

          JOIN %Table:ABS% ABS
            ON ABS.ABS_FILIAL = %xFilial:ABS%
           AND ABS.ABS_LOCAL = ABB.ABB_LOCAL
           AND ABS.%notDEL%

          JOIN %Table:TCU% TCU
            ON TCU.TCU_FILIAL = %xFilial:TCU%
           AND TCU.TCU_COD = ABB.ABB_TIPOMV
           AND TCU.%notDEL%

          JOIN %Table:TFL% TFL
            ON TFL.TFL_FILIAL = TFF.TFF_FILIAL
           AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
           AND TFL.%notDEL%
        
          JOIN %Table:TFJ% TFJ
            ON TFJ.TFJ_FILIAL = TFL.TFL_FILIAL
           AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
           AND TFJ.%notDEL%

          JOIN %Table:SA1% SA1
            ON SA1.A1_FILIAL = ' '
           AND SA1.A1_COD = TFJ.TFJ_CODENT
           AND SA1.A1_LOJA = TFJ.TFJ_LOJA
           AND SA1.%notDEL%
        
         WHERE PA1.PA1_FILIAL = %xFilial:PA1%
           AND PA1.PA1_CODAPU BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
           AND PA1.PA1_DTAPUR BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)%
           AND PA1.PA1_CODTEC BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
           AND PA1.%notDEL%
        
         ORDER BY PA1.PA1_CODTEC, TDV.TDV_DTREF, ABB.ABB_HRINI, ABB.ABB_HRFIM
    EndSQL
    oSecApur:EndQuery()

    //-- Relaciona as secoes do relatorio
    oSecAgenda:SetParentQuery()
    oSecAgenda:SetParentFilter({|cParam| (cAliasQry)->(PA1_CODAPU) == cParam}, {|| (cAliasQry)->PA1_CODAPU})


    //-- Realiza a impressao
    oSecApur:Print()


Return

/*/
--------------------------------------------------------------------------------
{Protheus.doc} RetSX3Tit()
Retorna o Titulo do Campo
@author DS2U [VR]
@since 17.fev.2020
@version 1.0
@type function
--------------------------------------------------------------------------------
/*/
Static Function RetSX3Tit(cCampo)
    Local cTitulo  := ''
    Local aAreaSX3 := SX3->(GetArea())

    SX3->(DbSetOrder(2))
    If SX3->(DbSeek(cCampo))
        cTitulo := AllTrim(X3Titulo())
    EndIf

    RestArea(aAreaSX3)


Return(cTitulo)

