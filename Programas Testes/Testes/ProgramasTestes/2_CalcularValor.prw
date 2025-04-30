#include "totvs.ch"
    
    User Function Calculo(uNumber)

        Local cNumber := 5
        Default uNumber := 0

        IF uNumber > cNumber
            Alert("O número digitado é maior")
        Else
            Alert("O número digitado é menor ou igual")
        EndIF

    Return
