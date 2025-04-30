#include 'totvs.ch'

User Function VALPIX()

    Local Formato := AllTrim(M->A1_TPIX)

    Do Case
        Case Formato == "CPF"
            Return "@R 999.999.999-99"
        
        Case Formato == "CNPJ"
            Return "@R 99.999.999/9999-99"

        Case Formato == "Telefone"
            Return "@R (99)99999-9999"
        
        Case Formato == "E-Mail"
            Return "@!"
        
        Case Formato == "Chave Aleatoria"
            Return "@!"
    EndCase

Return .F.
