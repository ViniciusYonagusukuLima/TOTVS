#include "totvs.ch"
#include "topconn.ch"

Function U_A101VAL()

// Prepara o ambiente
rpcSetEnv('99','01','vinicius',123,'TEC','U_A101VAL')

    Local lRet  := .T.
    Local cTipo := ""
    Local cPix := ""

    IF Select("SA1") == 0
        DbSelectArea("SA1")
        DbUseArea(.T.,"TOPCONN","SA1","SA1",.F.,.T.)
    EndIF

    // Verifica se o campo existe na tabela SA1
    IF Type("SA1->A1_ZTPIX") == "C" .And. Type("SA1->A1_ZPIX") == "C"

        cTipo := AllTrim(SA1->A1_ZTPIX)
        cPix  := AllTrim(SA1->A1_ZPIX)

        Do Case
            Case cTipo == "CPF"
                lRet := ValidaMascara(cPix, "@R 999.999.999-99")
            
            Case cTipo == "CNPJ"
                lRet := ValidaMascara(cPix, "@R 99.999.999/9999-99")
            
            Case cTipo == "Telefone"
                lRet := ValidaMascara(cPix, "@R (99) 99999-9999")

            Case cTipo == "E-Mail"
                lRet := "@" $ cPix .AND. "." $ cPix
            
            Case cTipo == "Chave Aleatoria"
                lRet := Len(cPix) >= 32 //UUID
        EndCase

        IF !lRet
            MsgAlert("Valor do campo PIX inválido para o tipo '" + cTipo + "'")
        EndIF

    EndIF

rpcClearEnv()    

Return lRet

Static Function ValidaMascara(cValor, cMasc)
    Local oMask := FWMask():New(cMasc)
Return oMask:Eval(cValor)
