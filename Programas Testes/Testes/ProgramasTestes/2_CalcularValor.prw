#include "totvs.ch"
    
    User Function Calculo(uNumber)

        Local cNumber := 5
        Default uNumber := 0

        IF uNumber > cNumber
            Alert("O n�mero digitado � maior")
        Else
            Alert("O n�mero digitado � menor ou igual")
        EndIF

    Return
