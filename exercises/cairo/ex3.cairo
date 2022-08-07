%builtins range_check # add output builtin if you want to run on cairo browser compiler to check results
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math import unsigned_div_rem

## Perform and log output of simple arithmetic operations
func simple_math{range_check_ptr}():
    let a = 13
    let b = 14
    ## adding 13 +  14
    let sum = a + b
    #serialize_word(sum)

    ## multiplying 3 * 6
    let a = 3
    let b = 6
    let mul = a * b
    #serialize_word(mul)

    ## dividing 6 by 2
    let a = 6
    let b = 2
    let div = a / b
    
    #serialize_word(div)

    ## dividing 70 by 2
    let a = 70
    let b = 2
    let div = a / b
    #serialize_word(div)

    ## dividing 7 by 2 
    let a = 7
    let b = 2
    let (q,r) = unsigned_div_rem(7, 2)
    #serialize_word(q)
    #serialize_word(r)
    return ()
end

func main{output_ptr : felt*, range_check_ptr}():
    simple_math()
    return()
end
