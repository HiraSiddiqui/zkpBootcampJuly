%builtins range_check

from starkware.cairo.common.serialize import serialize_word

## Return summation of every number below and up to including n
func calculate_sum{range_check_ptr}(n : felt) -> (sum : felt):
    if n == 1:    
        return (1)
    end
    let (sum) = calculate_sum(n = n-1)
    let new_sum = n + sum
    return(new_sum)
end

func main{output_ptr : felt*}():
    let (sum) = calculate_sum(4)
    serialize_word(sum)
    return()
end
