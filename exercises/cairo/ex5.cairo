%builtins range_check
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math import abs_value

## Implement a funcion that returns: 
## - 1 when magnitudes of inputs are equal
## - 0 otherwise
func abs_eq{range_check_ptr}(x : felt, y : felt) -> (bit : felt):
    let (absX) = abs_value(x) 
    let (absY) = abs_value(y) 

    if absX == absY:
        return (1)
    end
    return (0)    
end

func main{output_ptr : felt*, range_check_ptr}():
    let (res) = abs_eq(3,5)    # should return 0
    serialize_word(res)
    
    let (res) = abs_eq(5,5)    # should return 1
    serialize_word(res)
    
    let (res) = abs_eq(0,0)    # should return 1
    serialize_word(res)
    
    let (res) = abs_eq(-5,5)    # should return 1 because absolute value is same
    serialize_word(res)
    
    return()
    
end
