#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE DEF_TITULO_DO_CAMPO		01	//-- Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//-- ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//-- identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//-- Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//-- Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//-- Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//-- Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//-- Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//-- Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//-- Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//-- Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//-- Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//-- Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//-- Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//-- Valid do usuario
#DEFINE DEF_ORDEM				16	//-- Ordem do campo
#DEFINE DEF_HELP				17	//-- Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//-- Picture do campo
#DEFINE DEF_PICT_VAR			19	//-- Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//-- Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//-- Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//-- Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//-- Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//-- Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//-- Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//-- Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//-- Picture variavel
#DEFINE DEF_INSERT_LINE			28	//-- Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//-- Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//-- Tipo do campo

#DEFINE QUANTIDADE_DEFS         30  //-- Quantidade de DEFs



/*/
---------------------------------------------------------------------------
{Protheus.doc} DS2UA021.prw
ROTINA PARA APURACAO DE FT CASH

@author  DS2U (VR)
@since   mai-2021
@version 1.0
@type    function
---------------------------------------------------------------------------
/*/
User Function DS2UA021(cOption, uParams)
	Local uRet      :=  NIL

	If cOption == 'MARK'
		//------------------------------------------------------
		// FUNCAO 'DEFAULT' PARA CHAMADA DO BRWOSE
		//------------------------------------------------------
		uRet := markData(uParams)

	EndIf

Return(uRet)


// -------------------------------------------------------------------------------------------------------
//
// TRATAMENTO DAS FUNCOES
//
// -------------------------------------------------------------------------------------------------------


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} ModelDef
	DEFINICAO DO MODELO DE DADOS

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function ModelDef()
	Local oModel      := NIL
	Local oStructFake := NIL
	Local oStructAA1  := NIL
	Local oStructPA1  := NIL
	Local aTrigger    := {}
	Local bCommit     := {|| grvApurac(oModel)}

	// --------------------------------------------------
	// ESTRUTURA DE DADOS
	// --------------------------------------------------

	//--ESTRUTURA DE DADOS "FAKE" P/ CABECALHO
	oStructFake := FWFormModelStruct():New()
	oStructFake:addTable('', {'C_STRING1'}, 'Apuracao Horas - Diaristas', {|| ''})
	oStructFake:addField('String 01', 'Campo de texto fake', 'C_STRING1', 'C', 15)

	//--GRID "ATENDENTES"
	oStructAA1 := getStruct('AA1', 1)


	//--GRID "DADOS APURADOS"
	oStructPA1 := getStruct('PA1', 1)
	aTrigger := FwStruTrigger('MARCA', 'MARCA', 'u_DS2UA021("MARK", 1)', .F.)
	oStructPA1:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])


	// --------------------------------------------------
	// CRIA MODEL
	// --------------------------------------------------
	oModel := MPFormModel():New('A021MDL',,, bCommit)
	oModel:SetDescription('Apuração Horas - Diaristas')

	//--CABECALHO "FAKE"
	oModel:addFields('CABID',, oStructFake,,, {|oMdl| {""}})
	oModel:getModel('CABID'):setOnlyQuery(.T.)

	//--GRID "ATENDENTES"
	oModel:addGrid('AA1DETAIL', 'CABID', oStructAA1)
	oModel:getModel('AA1DETAIL'):setOnlyQuery(.T.)
	oModel:getModel('AA1DETAIL'):setOptional(.T.)
	oModel:getModel('AA1DETAIL'):setDescription('Atendentes')

	//--GRID "DADOS APURADOS"
	oModel:addGrid('PA1DETAIL', 'AA1DETAIL', oStructPA1)
	oModel:getModel('PA1DETAIL'):setOnlyQuery(.T.)
	oModel:getModel('PA1DETAIL'):setOptional(.T.)
	oModel:getModel('PA1DETAIL'):setDescription('Dados Apuração')


	oModel:setVldActivate({|oMoel| preLoadData(oModel)})
	oModel:setActivate({|oModel| Processa({|| loadData(oModel)}, 'Aguarde...', 'Carregando dados...')})


Return(oModel)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} ViewDef
	DEFINICAO DA VIEW

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function ViewDef()
	Local oView       := NIL
	Local oModel      := ModelDef()
	Local oStructFake := NIL
	Local oStructAA1  := NIL
	Local oStructPA1  := NIL

	// --------------------------------------------------
	// ESTRUTURA DE DADOS
	// --------------------------------------------------

	//--ESTRUTURA DE DADOS "FAKE" P/ CABECALHO
	oStructFake := FWFormViewStruct():New()
	oStructFake:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

	//--GRID "ATENDENTES"
	oStructAA1 := getStruct('AA1', 2)


	//--GRID "DADOS APURADOS"
	oStructPA1 := getStruct('PA1', 2)
	oStructPA1:removeField('FILABB')
	oStructPA1:removeField('CODABB')

	// --------------------------------------------------
	// CRIA VIEW
	// --------------------------------------------------
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('TOHIDE'  , 00)
	oView:CreateHorizontalBox('SPACE'   , 02)
	oView:CreateHorizontalBox('GRIDAA1' , 35)
	oView:CreateHorizontalBox('SPACE'   , 02)
	oView:CreateHorizontalBox('BUTTON'  , 12)
	oView:CreateHorizontalBox('SPACE'   , 02)
	oView:CreateHorizontalBox('GRIDPA1' , 45)


	//-- CABECALHO
	oView:addField('CABEC', oStructFake, 'CABID')
	oView:setOwnerView('CABEC', 'TOHIDE')

	//--GRID "ATENDENTES"
	oView:addGrid('GRID_AA1', oStructAA1, 'AA1DETAIL')
	oView:SetOwnerView('GRID_AA1', 'GRIDAA1')
	oView:EnableTitleView('GRID_AA1', oModel:GetModel('AA1DETAIL'):GetDescription())
	oView:setNoInsertLine('AA1DETAIL')
	oView:setNoDeleteLine('AA1DETAIL')

	//--GRID "DADOS APURACAO"
	oView:AddOtherObject('BTN', {|oPanel| addButtons(oPanel) })
	oView:EnableTitleView('BTN', oModel:GetModel('PA1DETAIL'):GetDescription())
	oView:SetOwnerView('BTN', 'BUTTON')

	oView:addGrid('GRID_PA1', oStructPA1, 'PA1DETAIL')
	oView:SetOwnerView('GRID_PA1', 'GRIDPA1')
	oView:setNoInsertLine('PA1DETAIL')
	oView:setNoDeleteLine('PA1DETAIL')


	oView:SetCloseOnOk({|| .T.})

Return(oView)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} addButtons
	CRIA BOTOES ESPECIFICOS NA VIEW

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function addButtons(oPanel)
	TButton():New((oPanel:nHeight / 2) - 15, 2,;
		'Marcar/Demarcar Todos',;
		oPanel,;
		{|| u_DS2UA021('MARK', 2)},;
		90, 15,,, .F., .T., .F.,, .F.,,, .F.)
Return


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} preLoadData
	CARREGA PARAMETROS PARA PROCESSAMENTO (PRE LOAD)

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function preLoadData(oModel)
	Local cPerg   := PadR('DS2UA021', Len(SX1->X1_GRUPO))
	Local lRet   := .T.

	If Pergunte(cPerg, .T.)
		lRet := .T.

	Else
		lRet := .F.
		oModel:GetModel():SetErrorMessage(,, oModel:GetId(),, 'DS2UA021',;
			'Processo cancelado pelo usuário',;
			'')

	EndIf

Return(lRet)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} LSAA021Load
	CARREGA DADOS DO MODELO

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function loadData(oModel)
	Local oGridAA1  := oModel:getModel('AA1DETAIL')
	Local oGridPA1  := oModel:getModel('PA1DETAIL')
	Local cAliasQry := ''
	Local cQuebra   := ''
	Local lAddAA1   := .F.
	Local lAddPA1   := .F.
	Local lRet      := .T.
	Local nTotReg   := 0


	// ----------------------------------------------------------
	// PARAMETROS
	// ----------------------------------------------------------
	// MV_PAR01: Da Data
	// MV_PAR02: Ate a Data
	// MV_PAR03: Do Atendente
	// MV_PAR04: Ate Atendente
	// MV_PAR05: Do Contrato
	// MV_PAR06: Ate o Contrato
	// MV_PAR07: Do Local de Atendimento
	// MV_PAR08: Ate o Local de Atendimento
	// MV_PAR09: Do Posto
	// MV_PAR10: Ate o Posto
	// MV_PAR11: Da Escala
	// MV_PAR12: Ate a Escala
	// ----------------------------------------------------------
	cAliasQry := getNextAlias()
	BeginSQL Alias cAliasQry
        SELECT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_VALOR, AA1.AA1_CODFOR, AA1.AA1_LOJFOR, ABB.ABB_CODIGO, ABB.ABB_FILIAL, 
               SA2.A2_NOME, SA2.A2_NREDUZ, SA2.A2_BANCO, SA2.A2_AGENCIA, SA2.A2_NUMCON, TDV.TDV_DTREF, ABB.ABB_HRTOT, ABB.ABB_HRINI, 
               ABB.ABB_HRFIM, TFF.TFF_CONTRT, SA1.A1_NREDUZ, ABB.ABB_LOCAL, ABS.ABS_DESCRI, TFF.TFF_COD, TFF.TFF_ESCALA, TDW.TDW_DESC, 
               ABB.ABB_TIPOMV, TCU.TCU_DESC

          FROM %Table:ABB% ABB

          JOIN %Table:TDV% TDV
            ON TDV.TDV_FILIAL = ABB.ABB_FILIAL
           AND TDV.TDV_CODABB = ABB.ABB_CODIGO
           AND TDV.TDV_DTREF BETWEEN %Exp:DtoS(MV_PAR01)% AND %Exp:DtoS(MV_PAR02)%
           AND TDV.%notDEL%

          JOIN %Table:ABQ% ABQ
            ON ABQ.ABQ_FILIAL = ' '
           AND ABQ.ABQ_FILTFF = ABB.ABB_FILIAL
           AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL           
           AND ABQ.ABQ_CONTRT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
           AND ABQ.ABQ_CODTFF BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
           AND ABQ.%notDEL%

          JOIN %Table:TFF% TFF
            ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF
           AND TFF.TFF_COD = ABQ.ABQ_CODTFF
           AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%
           AND TFF.%notDEL%

          JOIN %Table:TDW% TDW
            ON TDW.TDW_FILIAL = %xFilial:TDW%
           AND TDW.TDW_COD = TFF.TFF_ESCALA
           AND TDW.%notDEL%

          JOIN %Table:AA1% AA1
            ON AA1.AA1_FILIAL = %xFilial:AA1%
           AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
           AND AA1.%notDEL%

          JOIN %Table:SA2% SA2
            ON SA2.A2_FILIAL = %xFilial:SA2%
           AND SA2.A2_COD = AA1.AA1_CODFOR
           AND SA2.A2_LOJA = AA1.AA1_LOJFOR
           AND SA2.%notDEL%

          JOIN %Table:ABS% ABS
            ON ABS.ABS_FILIAL = %xFilial:ABS%
           AND ABS.ABS_LOCAL = ABB.ABB_LOCAL
           AND ABS.%notDEL%

          JOIN %Table:TCU% TCU
            ON TCU.TCU_FILIAL = %xFilial:TCU%
           AND TCU.TCU_COD = ABB.ABB_TIPOMV
           AND TCU.%notDEL%

          JOIN %Table:TFJ% TFJ
            ON TFJ.TFJ_FILIAL = ABB.ABB_FILIAL 
           AND TFJ.TFJ_CONTRT = TFF.TFF_CONTRT 
           AND TFJ.TFJ_CONREV = TFF.TFF_CONREV 
           AND TFJ.%notDEL%

          JOIN %Table:SA1% SA1
            ON SA1.A1_FILIAL = %xFilial:SA1%
           AND SA1.A1_COD = TFJ.TFJ_CODENT
           AND SA1.A1_LOJA = TFJ.TFJ_LOJA
           AND SA1.%notDEL%

         WHERE ABB.ABB_FILIAL = %xFilial:ABB%
           AND ABB.ABB_CODTEC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
           AND ABB.ABB_LOCAL BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
           AND ABB.ABB_APURFT = ' '
           AND ABB.%notDEL%

         ORDER BY TDV.TDV_DTREF, ABB.ABB_HRINI

	EndSQL


	If !(cAliasQry)->(Eof())
		// ----------------------------------------------------------
		// CARREGA GRID COM OS ATENDENTES E AGENDAS
		// ----------------------------------------------------------

		//--"DESTRAVA" EDICAO NOS GRIDS
		oGridAA1:setNoInsertLine(.F.)
		oGridAA1:setNoDeleteLine(.F.)

		oGridPA1:setNoInsertLine(.F.)
		oGridPA1:setNoDeleteLine(.F.)

		nTotReg := Contar(cAliasQry, '!Eof()')
		ProcRegua(nTotReg)

		(cAliasQry)->(dbGoTop())
		While !(cAliasQry)->(Eof())
			If lAddAA1
				oGridAA1:addLine()
				lAddPA1 := .F.
			Else
				lAddAA1 := .T.
			EndIf
			oGridAA1:loadValue('AA1_CODTEC' , (cAliasQry)->AA1_CODTEC)
			oGridAA1:loadValue('AA1_NOMTEC' , (cAliasQry)->AA1_NOMTEC)
			oGridAA1:loadValue('AA1_VALOR'  , (cAliasQry)->AA1_VALOR)
			oGridAA1:loadValue('AA1_CODFOR' , (cAliasQry)->AA1_CODFOR)
			oGridAA1:loadValue('AA1_LOJFOR' , (cAliasQry)->AA1_LOJFOR)
			oGridAA1:loadValue('A2_NOME'    , (cAliasQry)->A2_NOME)
			oGridAA1:loadValue('A2_NREDUZ'  , (cAliasQry)->A2_NREDUZ)
			oGridAA1:loadValue('A2_BANCO'   , (cAliasQry)->A2_BANCO)
			oGridAA1:loadValue('A2_AGENCIA' , (cAliasQry)->A2_AGENCIA)
			oGridAA1:loadValue('A2_NUMCON'  , (cAliasQry)->A2_NUMCON)

			cQuebra := (cAliasQry)->AA1_CODTEC
			While !(cAliasQry)->(Eof()) .And. cQuebra == (cAliasQry)->AA1_CODTEC
				If lAddPA1
					oGridPA1:addLine()
				Else
					lAddPA1 := .T.
				EndIf
				oGridPA1:loadValue('MARCA'      , .F.)
				oGridPA1:loadValue('DTREF'      , StoD((cAliasQry)->TDV_DTREF))
				oGridPA1:loadValue('HRINI'      , (cAliasQry)->ABB_HRINI)
				oGridPA1:loadValue('HRFIM'      , (cAliasQry)->ABB_HRFIM)
				oGridPA1:loadValue('QTDHRS'     , Val(StrTran(Right((cAliasQry)->ABB_HRTOT, 5), ':', '.')))
				oGridPA1:loadValue('CONTRATO'   , (cAliasQry)->TFF_CONTRT)
				oGridPA1:loadValue('NREDUZ'     , (cAliasQry)->A1_NREDUZ)
				oGridPA1:loadValue('LOCAL'      , (cAliasQry)->ABB_LOCAL)
				oGridPA1:loadValue('DESCLOC'    , (cAliasQry)->ABS_DESCRI)
				oGridPA1:loadValue('POSTO'      , (cAliasQry)->TFF_COD)
				oGridPA1:loadValue('ESCALA'     , (cAliasQry)->TFF_ESCALA)
				oGridPA1:loadValue('DESCESCALA' , (cAliasQry)->TDW_DESC)
				oGridPA1:loadValue('TPMOVTO'    , (cAliasQry)->ABB_TIPOMV)
				oGridPA1:loadValue('DESTPMOVTO' , (cAliasQry)->TCU_DESC)
				oGridPA1:loadValue('FILABB'     , (cAliasQry)->ABB_FILIAL)
				oGridPA1:loadValue('CODABB'     , (cAliasQry)->ABB_CODIGO)

				(cAliasQry)->(dbSkip())
				IncProc()
			End

		End

		//--"TRAVA" EDICOES NOS GRIDS
		oGridAA1:setNoInsertLine(.T.)
		oGridAA1:setNoDeleteLine(.T.)

		oGridPA1:setNoInsertLine(.T.)
		oGridPA1:setNoDeleteLine(.T.)

		oGridAA1:goLine(1)
		oGridPA1:goLine(1)

	Else
		lRet := .F.
		oModel:GetModel():SetErrorMessage(,, oModel:GetId(),, 'DS2UA021',;
			'Nao existem dados para os parâmetros informados',;
			'Vefique os parâmetros informados e tente novamente')

	EndIf

Return(lRet)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} markData
	TRATA MARCACAO DOS REGISTROS NO GRID

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function markData(nOpc)
	Local lRet     := .T.
	Local oModel   := NIL
	Local oGridAA1 := NIL
	Local oGridPA1 := NIL
	Local nTotHrs  := 0
	Local nValor   := 0
	Local oView    := NIL
	Local nCounta  := 0
	Default nOpc   := 1

	If nOpc == 1
		If IsInCallStack('RUNTRIGGER')
			oView    := FWViewActive()
			oModel   := FWModelActive()
			oGridAA1 := oModel:getModel('AA1DETAIL')
			oGridPA1 := oModel:getModel('PA1DETAIL')


			If oGridPA1:getValue('MARCA')
				nTotHrs := SomaHoras(oGridAA1:getValue('PA1_HRSAPU'), oGridPA1:getValue('QTDHRS'))  //oGridAA1:getValue('PA1_HRSAPU') + oGridPA1:getValue('QTDHRS')
				nValor  := (Hrs2Min(nTotHrs)/60) * oGridAA1:getValue('AA1_VALOR')

				oGridAA1:loadValue('PA1_HRSAPU', nTotHrs)
				oGridAA1:loadValue('PA1_VLAPUR', nValor)
				oGridAA1:loadValue('PA1_VLPAGO', nValor)

			Else
				nTotHrs := SubHoras( oGridAA1:getValue('PA1_HRSAPU') , oGridPA1:getValue('QTDHRS')) //oGridAA1:getValue('PA1_HRSAPU') - oGridPA1:getValue('QTDHRS')
				nValor  := (Hrs2Min(nTotHrs)/60)  * oGridAA1:getValue('AA1_VALOR')

				oGridAA1:loadValue('PA1_HRSAPU', nTotHrs)
				oGridAA1:loadValue('PA1_VLAPUR', nValor)
				oGridAA1:loadValue('PA1_VLPAGO' ,nValor)

			EndIf

		EndIf

	ElseIf nOpc == 2
		oView    := FWViewActive()
		oModel   := FWModelActive()
		oGridAA1 := oModel:getModel('AA1DETAIL')
		oGridPA1 := oModel:getModel('PA1DETAIL')

		For nCountA := 1 To oGridPA1:Length()
			oGridPA1:goLine(nCountA)

			If oGridPA1:getValue('MARCA')
				nTotHrs := SubHoras( oGridAA1:getValue('PA1_HRSAPU') , oGridPA1:getValue('QTDHRS')) //oGridAA1:getValue('PA1_HRSAPU') - oGridPA1:getValue('QTDHRS')
				nValor  := (Hrs2Min(nTotHrs)/60)  * oGridAA1:getValue('AA1_VALOR')

				oGridPA1:loadValue('MARCA'      , .F.)
				oGridAA1:loadValue('PA1_HRSAPU' , nTotHrs)
				oGridAA1:loadValue('PA1_VLAPUR' , nValor)
				oGridAA1:loadValue('PA1_VLPAGO' , nValor)

			Else
				nTotHrs := SomaHoras(oGridAA1:getValue('PA1_HRSAPU'), oGridPA1:getValue('QTDHRS'))  // oGridAA1:getValue('PA1_HRSAPU') + oGridPA1:getValue('QTDHRS')
				nValor  := (Hrs2Min(nTotHrs)/60)  * oGridAA1:getValue('AA1_VALOR')

				oGridPA1:loadValue('MARCA'      , .T.)
				oGridAA1:loadValue('PA1_HRSAPU' , nTotHrs)
				oGridAA1:loadValue('PA1_VLAPUR' , nValor)
				oGridAA1:loadValue('PA1_VLPAGO' , nValor)

			EndIf

		Next nCountA

		oGridPA1:goLine(1)
		oView:Refresh()

	EndIf


Return(lRet)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} grvApurac
	GRAVACAO DA APURACAO

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function grvApurac(oModel)
	Local lRet       := .F.
	Local oGridAA1   := oModel:getModel('AA1DETAIL')
	Local oGridPA1   := oModel:getModel('PA1DETAIL')
	Local nCountA    := 0
	Local nCountB    := 0
	Local cCodApur   := ''
	Local aAreaABB   := ABB->(getArea())


	For nCountA := 1 To oGridAA1:Length()
		oGridAA1:goLine(nCountA)

		If oGridAA1:getValue('PA1_HRSAPU') > 0
			lRet     := .T.
			cCodApur := GetSXENum('PA1', 'PA1_CODAPU')

			Begin Transaction
				RecLock('PA1', .T.)
				PA1->PA1_FILIAL  := xFilial('PA1')
				PA1->PA1_CODAPU  := cCodApur
				PA1->PA1_DTAPUR  := dDataBase
				PA1->PA1_FORNEC  := oGridAA1:getValue('AA1_CODFOR')
				PA1->PA1_LOJA    := oGridAA1:getValue('AA1_LOJFOR')
				PA1->PA1_VLAPUR  := oGridAA1:getValue('PA1_VLAPUR')
				PA1->PA1_VLPAGO  := oGridAA1:getValue('PA1_VLPAGO')
				PA1->PA1_HRSAPU  := oGridAA1:getValue('PA1_HRSAPU')
				PA1->PA1_VLRHR   := oGridAA1:getValue('AA1_VALOR')
				PA1->PA1_CODTEC  := oGridAA1:getValue('AA1_CODTEC')
				PA1->PA1_STATUS  := '0' //-- NAO INTEGRADO
				PA1->(MsUnLock())

				ABB->(dbSetOrder(08)) //--ABB_FILIAL+ABB_CODIGO
				For nCountB := 1 To oGridPA1:Length()
					oGridPA1:goLine(nCountB)
					If oGridPA1:getValue('MARCA')
						If ABB->(dbSeek(oGridPA1:getValue('FILABB')+oGridPA1:getValue('CODABB')))
							RecLock('ABB', .F.)
							ABB->ABB_APURFT := cCodApur
							ABB->(MsUnLock())
						EndIf
					EndIf
				Next nCountB
			End Transaction

			ConfirmSX8()

		EndIf
	Next nCountA


	If !lRet
		oModel:GetModel():SetErrorMessage(,, oModel:GetId(),, 'DS2UA021',;
			'Você precisa apurar dados de pelo menos um atendente para salvar a apuração',;
			'Selecione as ordens de serviço que devem compor a apuração')
	EndIf


	//--RESTAURA AMBIENTE:
	RestArea(aAreaABB)


Return(lRet)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} getStruct
	RETORNA ESTRUTURA DE DADOS PARA O MODELO DE DADOS/VIEW

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function getStruct(cAlias, nTipo)
	Local oStructRet := NIL
	Local aCampos    := getFields(cAlias)
	Local nCountA    := 0

	If nTipo == 1 //--MODEL
		oStructRet := FWFormModelStruct():New()
		oStructRet:addTable('', {}, '')

	ElseIf nTipo == 2 //--VIEW
		oStructRet := FWFormViewStruct():New()

	EndIf

	For nCountA := 1 To Len(aCampos)
		If nTipo == 1 //--MODEL
			oStructRet:AddField( aCampos[nCountA][DEF_TITULO_DO_CAMPO],;
				aCampos[nCountA][DEF_TOOLTIP_DO_CAMPO],;
				aCampos[nCountA][DEF_IDENTIFICADOR	],;
				aCampos[nCountA][DEF_TIPO_DO_CAMPO	],;
				aCampos[nCountA][DEF_TAMANHO_DO_CAMPO],;
				aCampos[nCountA][DEF_DECIMAL_DO_CAMPO],;
				aCampos[nCountA][DEF_CODEBLOCK_VALID],;
				aCampos[nCountA][DEF_CODEBLOCK_WHEN],;
				aCampos[nCountA][DEF_LISTA_VAL],;
				aCampos[nCountA][DEF_OBRIGAT],;
				aCampos[nCountA][DEF_CODEBLOCK_INIT],;
				aCampos[nCountA][DEF_CAMPO_CHAVE],;
				aCampos[nCountA][DEF_RECEBE_VAL],;
				aCampos[nCountA][DEF_VIRTUAL],;
				aCampos[nCountA][DEF_VALID_USER])

		ElseIf nTipo == 2 //--VIEW
			oStructRet:addField( aCampos[nCountA][DEF_IDENTIFICADOR],;
				aCampos[nCountA][DEF_ORDEM],;
				aCampos[nCountA][DEF_TITULO_DO_CAMPO],;
				aCampos[nCountA][DEF_TOOLTIP_DO_CAMPO],;
				aCampos[nCountA][DEF_HELP],;
				aCampos[nCountA][DEF_TIPO_CAMPO_VIEW],;
				aCampos[nCountA][DEF_PICTURE],;
				aCampos[nCountA][DEF_PICT_VAR],;
				aCampos[nCountA][DEF_LOOKUP],;
				aCampos[nCountA][DEF_CAN_CHANGE],;
				aCampos[nCountA][DEF_ID_FOLDER],;
				aCampos[nCountA][DEF_ID_GROUP],;
				aCampos[nCountA][DEF_COMBO_VAL],;
				aCampos[nCountA][DEF_TAM_MAX_COMBO],;
				aCampos[nCountA][DEF_INIC_BROWSE],;
				aCampos[nCountA][DEF_VIRTUAL],;
				aCampos[nCountA][DEF_PICTURE_VARIAVEL],;
				aCampos[nCountA][DEF_INSERT_LINE],;
				aCampos[nCountA][DEF_WIDTH] )

		EndIf
	Next nCountA

Return(oStructRet)


/*/
	---------------------------------------------------------------------------
	{Protheus.doc} getFields
	RETORNA CAMPOS P/ MONTAR ESTRUTURA DE DADOS DO MODEL/VIEW

	@author  DS2U (VR)
	@since   abr.2021
	@version 1.0
	@type    function
	---------------------------------------------------------------------------
/*/
Static Function getFields(cAlias)
	Local aCpos    := {}
	Local aRetCpos := {}
	Local nCountA  := 0

	If cAlias == 'AA1'
		aCpos := {  'AA1_CODTEC',;
			'AA1_NOMTEC',;
			'AA1_VALOR',;
			'PA1_HRSAPU',;
			'PA1_VLAPUR',;
			{'PA1_VLPAGO',;
			GetSX3Cache('PA1_VLPAGO', 'X3_DESCRIC'),;  //--[02] TITULO CAMPO
		GetSX3Cache('PA1_VLPAGO', 'X3_DESCRIC'),;  //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('PA1_VLPAGO', 'X3_TIPO'),;     //--[04] TIPO DO CAMPO
		GetSX3Cache('PA1_VLPAGO', 'X3_TAMANHO'),;  //--[05] TAMANHO DO CAMPO
		GetSX3Cache('PA1_VLPAGO', 'X3_DECIMAL'),;  //--[06] DECIMAIS
		{|| CriaVar('PA1_VLPAGO', .F.)},;          //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('PA1_VLPAGO', 'X3_PICTURE'),;  //--[08] PICTURE
		GetSX3Cache('PA1_VLPAGO', 'X3_TIPO'),;     //--[09] TIPO DO CAMPO "VIEW"
		.T. },;                                    //--[10] PERMITE EDICAO
		'AA1_CODFOR',;
			'AA1_LOJFOR',;
			'A2_NOME',;
			'A2_NREDUZ',;
			'A2_BANCO',;
			'A2_AGENCIA',;
			'A2_NUMCON'}

	ElseIf cAlias == 'PA1'
		aAdd(aCpos, {   'MARCA',;       //--[01] ID CAMPO
		'',;            //--[02] TITULO CAMPO
		'',;            //--[03] DESCRICAO (TOOLTIP) CAMPO
		'L',;           //--[04] TIPO DO CAMPO
		1,;             //--[05] TAMANHO DO CAMPO
		0,;             //--[06] DECIMAIS
		{|| .F.},;      //--[07] INICIALIZADOR PADRAO
		'',;            //--[08] PICTURE
		'CHECK',;       //--[09] TIPO CAMPO "VIEW"
		.T. })          //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'DTREF',;                                   //--[01] ID CAMPO
		GetSX3Cache('TDV_DTREF', 'X3_TITULO'),;     //--[02] TITULO CAMPO
		GetSX3Cache('TDV_DTREF', 'X3_DESCRIC'),;    //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TDV_DTREF', 'X3_TIPO'),;       //--[04] TIPO DO CAMPO
		GetSX3Cache('TDV_DTREF', 'X3_TAMANHO'),;    //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TDV_DTREF', 'X3_DECIMAL'),;    //--[06] DECIMAIS
		{|| CriaVar('TDV_DTREF', .F.)},;            //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TDV_DTREF', 'X3_PICTURE'),;    //--[08] PICTURE
		GetSX3Cache('TDV_DTREF', 'X3_TIPO'),;       //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'HRINI',;                                   //--[01] ID CAMPO
		GetSX3Cache('ABB_HRINI', 'X3_TITULO'),;     //--[02] TITULO CAMPO
		GetSX3Cache('ABB_HRINI', 'X3_DESCRIC'),;    //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('ABB_HRINI', 'X3_TIPO'),;       //--[04] TIPO DO CAMPO
		GetSX3Cache('ABB_HRINI', 'X3_TAMANHO'),;    //--[05] TAMANHO DO CAMPO
		GetSX3Cache('ABB_HRINI', 'X3_DECIMAL'),;    //--[06] DECIMAIS
		{|| CriaVar('ABB_HRINI', .F.)},;            //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('ABB_HRINI', 'X3_PICTURE'),;    //--[08] PICTURE
		GetSX3Cache('ABB_HRINI', 'X3_TIPO'),;       //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO


		aAdd(aCpos, {   'HRFIM',;                                   //--[01] ID CAMPO
		GetSX3Cache('ABB_HRFIM', 'X3_TITULO'),;     //--[02] TITULO CAMPO
		GetSX3Cache('ABB_HRFIM', 'X3_DESCRIC'),;    //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('ABB_HRFIM', 'X3_TIPO'),;       //--[04] TIPO DO CAMPO
		GetSX3Cache('ABB_HRFIM', 'X3_TAMANHO'),;    //--[05] TAMANHO DO CAMPO
		GetSX3Cache('ABB_HRFIM', 'X3_DECIMAL'),;    //--[06] DECIMAIS
		{|| CriaVar('ABB_HRFIM', .F.)},;            //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('ABB_HRFIM', 'X3_PICTURE'),;    //--[08] PICTURE
		GetSX3Cache('ABB_HRFIM', 'X3_TIPO'),;       //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'QTDHRS',;                                  //--[01] ID CAMPO
		GetSX3Cache('PA1_HRSAPU', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('PA1_HRSAPU', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('PA1_HRSAPU', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('PA1_HRSAPU', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('PA1_HRSAPU', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('PA1_HRSAPU', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('PA1_HRSAPU', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('PA1_HRSAPU', 'X3_TIPO'),;       //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'CONTRATO',;                                //--[01] ID CAMPO
		GetSX3Cache('TFF_CONTRT', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('TFF_CONTRT', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TFF_CONTRT', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('TFF_CONTRT', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TFF_CONTRT', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('TFF_CONTRT', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TFF_CONTRT', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('TFF_CONTRT', 'X3_TIPO'),;      //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'NREDUZ',;                                  //--[01] ID CAMPO
		GetSX3Cache('A1_NREDUZ', 'X3_TITULO'),;     //--[02] TITULO CAMPO
		GetSX3Cache('A1_NREDUZ', 'X3_DESCRIC'),;    //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('A1_NREDUZ', 'X3_TIPO'),;       //--[04] TIPO DO CAMPO
		GetSX3Cache('A1_NREDUZ', 'X3_TAMANHO'),;    //--[05] TAMANHO DO CAMPO
		GetSX3Cache('A1_NREDUZ', 'X3_DECIMAL'),;    //--[06] DECIMAIS
		{|| CriaVar('A1_NREDUZ', .F.)},;            //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('A1_NREDUZ', 'X3_PICTURE'),;    //--[08] PICTURE
		GetSX3Cache('A1_NREDUZ', 'X3_TIPO'),;       //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'LOCAL',;                                   //--[01] ID CAMPO
		GetSX3Cache('TFL_LOCAL', 'X3_TITULO'),;     //--[02] TITULO CAMPO
		GetSX3Cache('TFL_LOCAL', 'X3_DESCRIC'),;    //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TFL_LOCAL', 'X3_TIPO'),;       //--[04] TIPO DO CAMPO
		GetSX3Cache('TFL_LOCAL', 'X3_TAMANHO'),;    //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TFL_LOCAL', 'X3_DECIMAL'),;    //--[06] DECIMAIS
		{|| CriaVar('TFL_LOCAL', .F.)},;            //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TFL_LOCAL', 'X3_PICTURE'),;    //--[08] PICTURE
		GetSX3Cache('TFL_LOCAL', 'X3_TIPO'),;       //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'DESCLOC',;                                 //--[01] ID CAMPO
		GetSX3Cache('ABS_DESCRI', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('ABS_DESCRI', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('ABS_DESCRI', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('ABS_DESCRI', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('ABS_DESCRI', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('ABS_DESCRI', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('ABS_DESCRI', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('ABS_DESCRI', 'X3_TIPO'),;      //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'POSTO',;                                   //--[01] ID CAMPO
		'Posto',;                                   //--[02] TITULO CAMPO
		'Código do Posto',;                         //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TFF_COD', 'X3_TIPO'),;         //--[04] TIPO DO CAMPO
		GetSX3Cache('TFF_COD', 'X3_TAMANHO'),;      //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TFF_COD', 'X3_DECIMAL'),;      //--[06] DECIMAIS
		{|| CriaVar('TFF_COD', .F.)},;              //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TFF_COD', 'X3_PICTURE'),;      //--[08] PICTURE
		GetSX3Cache('TFF_COD', 'X3_TIPO'),;         //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'ESCALA',;                                  //--[01] ID CAMPO
		GetSX3Cache('TFF_ESCALA', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('TFF_ESCALA', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TFF_ESCALA', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('TFF_ESCALA', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TFF_ESCALA', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('TFF_ESCALA', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TFF_ESCALA', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('TFF_ESCALA', 'X3_TIPO'),;      //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'DESCESCALA',;                              //--[01] ID CAMPO
		GetSX3Cache('TDW_DESC', 'X3_TITULO'),;      //--[02] TITULO CAMPO
		GetSX3Cache('TDW_DESC', 'X3_DESCRIC'),;     //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TDW_DESC', 'X3_TIPO'),;        //--[04] TIPO DO CAMPO
		GetSX3Cache('TDW_DESC', 'X3_TAMANHO'),;     //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TDW_DESC', 'X3_DECIMAL'),;     //--[06] DECIMAIS
		{|| CriaVar('TDW_DESC', .F.)},;             //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TDW_DESC', 'X3_PICTURE'),;     //--[08] PICTURE
		GetSX3Cache('TDW_DESC', 'X3_TIPO'),;        //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'TPMOVTO',;                                 //--[01] ID CAMPO
		GetSX3Cache('ABB_TIPOMV', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('ABB_TIPOMV', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('ABB_TIPOMV', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('ABB_TIPOMV', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('ABB_TIPOMV', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('ABB_TIPOMV', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('ABB_TIPOMV', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('ABB_TIPOMV', 'X3_TIPO'),;      //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'DESTPMOVTO',;                              //--[01] ID CAMPO
		GetSX3Cache('TCU_DESC', 'X3_TITULO'),;      //--[02] TITULO CAMPO
		GetSX3Cache('TCU_DESC', 'X3_DESCRIC'),;     //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('TCU_DESC', 'X3_TIPO'),;        //--[04] TIPO DO CAMPO
		GetSX3Cache('TCU_DESC', 'X3_TAMANHO'),;     //--[05] TAMANHO DO CAMPO
		GetSX3Cache('TCU_DESC', 'X3_DECIMAL'),;     //--[06] DECIMAIS
		{|| CriaVar('TCU_DESC', .F.)},;             //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('TCU_DESC', 'X3_PICTURE'),;     //--[08] PICTURE
		GetSX3Cache('TCU_DESC', 'X3_TIPO'),;        //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

		aAdd(aCpos, {   'FILABB',;                                  //--[01] ID CAMPO
		GetSX3Cache('ABB_FILIAL', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('ABB_FILIAL', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('ABB_FILIAL', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('ABB_FILIAL', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('ABB_FILIAL', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('ABB_FILIAL', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('ABB_FILIAL', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('ABB_FILIAL', 'X3_TIPO'),;      //--[09] TIPO DO CAMPO "VIEW"
		.F. })

		aAdd(aCpos, {   'CODABB',;                                  //--[01] ID CAMPO
		GetSX3Cache('ABB_CODIGO', 'X3_TITULO'),;    //--[02] TITULO CAMPO
		GetSX3Cache('ABB_CODIGO', 'X3_DESCRIC'),;   //--[03] DESCRICAO (TOOLTIP) CAMPO
		GetSX3Cache('ABB_CODIGO', 'X3_TIPO'),;      //--[04] TIPO DO CAMPO
		GetSX3Cache('ABB_CODIGO', 'X3_TAMANHO'),;   //--[05] TAMANHO DO CAMPO
		GetSX3Cache('ABB_CODIGO', 'X3_DECIMAL'),;   //--[06] DECIMAIS
		{|| CriaVar('ABB_CODIGO', .F.)},;           //--[07] INICIALIZADOR PADRAO
		GetSX3Cache('ABB_CODIGO', 'X3_PICTURE'),;   //--[08] PICTURE
		GetSX3Cache('ABB_CODIGO', 'X3_TIPO'),;      //--[09] TIPO DO CAMPO "VIEW"
		.F. })                                      //--[10] PERMITE EDICAO

	EndIf

	For nCountA := 1 To Len(aCpos)
		If ValType(aCpos[nCountA]) == 'C'
			aAdd(aRetCpos, Array(QUANTIDADE_DEFS))
			aTail(aRetCpos)[DEF_TITULO_DO_CAMPO]  := GetSX3Cache(aCpos[nCountA], 'X3_DESCRIC')
			aTail(aRetCpos)[DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache(aCpos[nCountA], 'X3_DESCRIC')
			aTail(aRetCpos)[DEF_IDENTIFICADOR]    := aCpos[nCountA]
			aTail(aRetCpos)[DEF_TIPO_DO_CAMPO]    := GetSX3Cache(aCpos[nCountA], 'X3_TIPO')
			aTail(aRetCpos)[DEF_TIPO_CAMPO_VIEW]  := GetSX3Cache(aCpos[nCountA], 'X3_TIPO')
			aTail(aRetCpos)[DEF_TAMANHO_DO_CAMPO] := GetSX3Cache(aCpos[nCountA], 'X3_TAMANHO')
			aTail(aRetCpos)[DEF_DECIMAL_DO_CAMPO] := GetSX3Cache(aCpos[nCountA], 'X3_DECIMAL')
			aTail(aRetCpos)[DEF_CODEBLOCK_WHEN]   := {|| .F.}
			aTail(aRetCpos)[DEF_OBRIGAT]          := .F.
			aTail(aRetCpos)[DEF_CODEBLOCK_INIT]   := &("{|| CriaVar('" + aCpos[nCountA] + "', .F.)}")
			aTail(aRetCpos)[DEF_RECEBE_VAL]       := .T.
			aTail(aRetCpos)[DEF_VIRTUAL]          := .T.
			aTail(aRetCpos)[DEF_ORDEM]            := StrZero(nCountA, 2)
			aTail(aRetCpos)[DEF_PICTURE]          := GetSX3Cache(aCpos[nCountA], 'X3_PICTURE')
			aTail(aRetCpos)[DEF_CAN_CHANGE]       := .T.

		ElseIf ValType(aCpos[nCountA]) == 'A'
			aAdd(aRetCpos, Array(QUANTIDADE_DEFS))
			aTail(aRetCpos)[DEF_TITULO_DO_CAMPO]  := aCpos[nCountA, 2]
			aTail(aRetCpos)[DEF_TOOLTIP_DO_CAMPO] := aCpos[nCountA, 3]
			aTail(aRetCpos)[DEF_IDENTIFICADOR]    := aCpos[nCountA, 1]
			aTail(aRetCpos)[DEF_TIPO_DO_CAMPO]    := aCpos[nCountA, 4]
			aTail(aRetCpos)[DEF_TIPO_CAMPO_VIEW]  := aCpos[nCountA, 9]
			aTail(aRetCpos)[DEF_TAMANHO_DO_CAMPO] := aCpos[nCountA, 5]
			aTail(aRetCpos)[DEF_DECIMAL_DO_CAMPO] := aCpos[nCountA, 6]
			aTail(aRetCpos)[DEF_CODEBLOCK_WHEN]   := {|| .T.}
			aTail(aRetCpos)[DEF_OBRIGAT]          := .F.
			aTail(aRetCpos)[DEF_CODEBLOCK_INIT]   := aCpos[nCountA, 7]
			aTail(aRetCpos)[DEF_RECEBE_VAL]       := .T.
			aTail(aRetCpos)[DEF_VIRTUAL]          := .T.
			aTail(aRetCpos)[DEF_ORDEM]            := StrZero(nCountA, 2)
			aTail(aRetCpos)[DEF_PICTURE]          := aCpos[nCountA, 8]
			aTail(aRetCpos)[DEF_CAN_CHANGE]       := aCpos[nCountA, 10]

		EndIf

	Next nCountA


Return(aRetCpos)
