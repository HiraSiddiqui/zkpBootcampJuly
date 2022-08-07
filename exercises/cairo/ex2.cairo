%builtins range_check # add output builtin if you want to run on cairo browser compiler to check results

from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.cairo.common.serialize import serialize_word

## Modify both functions so that they increment
## supplied value and return it
func add_one(y : felt) -> (val : felt):   
   return (val=y+1) 
end

func add_one_U256{range_check_ptr}(y : Uint256) -> (val : Uint256): 

    let one : Uint256 = Uint256(low=1,high=0)
    let (res,_) = uint256_add(y,one)
    return (val=res) 
end

func main{output_ptr : felt*,range_check_ptr}():
    let (res1) = add_one(y=1)
    serialize_word(res1)

    let val =  cast((0, 2), Uint256)
    let (res2) = add_one_U256(y=val)
    serialize_word(res2.high) # Taking most significant bits # numbers greater than 2^128 will have a problem # need to fix 
    return()
end
