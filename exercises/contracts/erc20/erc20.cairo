## I AM NOT DONE

%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_le, uint256_unsigned_div_rem, uint256_sub, uint256_mul
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import unsigned_div_rem, assert_le_felt

from starkware.cairo.common.math import (
    assert_not_zero,
    assert_not_equal,
    assert_nn,
    assert_le,
    assert_lt,    
    assert_in_range,
)


from exercises.contracts.erc20.ERC20_base import (
    ERC20_name,
    ERC20_symbol,
    ERC20_totalSupply,
    ERC20_decimals,
    ERC20_balanceOf,
    ERC20_allowance,
    ERC20_mint,

    ERC20_initializer,       
    ERC20_transfer,    
    ERC20_burn
)
@storage_var
func admin_address() -> (admin_address: felt):
end

@storage_var
func whitelist(whitelist_address:felt) -> (allowed: felt):
end

#
# Constructor
#

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt,
        initial_supply: Uint256,
        recipient: felt
    ):
    admin_address.write(recipient)
    ERC20_initializer(name, symbol, initial_supply, recipient)    
    return ()
end

#
# Getters
#

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC20_name()
    return (name)
end

@view
func get_admin{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (admin_address: felt):
    let (owner) = admin_address.read()
    return (owner)
end

@view
func check_whitelist{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(whitelist_address:felt) -> (allowed: felt):
    let (allowed) = whitelist.read(whitelist_address)
    return (allowed)
end


@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20_symbol()
    return (symbol)
end

@view
func totalSupply{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC20_totalSupply()
    return (totalSupply)
end

@view
func decimals{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20_decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC20_balanceOf(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20_allowance(owner, spender)
    return (remaining)
end

#
# Externals
#


@external
func transfer{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(recipient: felt, amount: Uint256) -> (success: felt):
    #assert_not_equal(amount.low%2, 1)
    let (quotient,remainder) = unsigned_div_rem (amount.low,2)
    assert remainder = 0
    ERC20_transfer(recipient, amount)    
    return (1)
end

@external
func request_whitelist{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (allowed: felt):
    let (caller) = get_caller_address()
    whitelist.write(caller,1)
    let (allowed) = whitelist.read(caller)
    return (allowed)
end

@external
func faucet{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(amount:Uint256) -> (success: felt):
    assert_le(amount.low, 10000)
    let (caller) = get_caller_address()
    ERC20_mint(caller, amount)
    return (1)
end

@external
func exclusive_faucet{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(amount:Uint256) -> (success: felt):
    let (caller) = get_caller_address()
    let (isWhitelisted) = check_whitelist(caller)
    assert isWhitelisted = 1
    ERC20_mint(caller, amount)
    return (1)
end

@external
func burn{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(amount: Uint256) -> (success: felt):   
    alloc_locals 
    let (caller) = get_caller_address()
    let (admin) = get_admin() 

    let (ten_percent, _) = uint256_unsigned_div_rem(amount, Uint256(10,0))
    let (amount_to_burn, _) = uint256_mul(ten_percent, Uint256(9,0))
    #let ten_percent = amount.low/10
    #let amount_to_burn = ten_percent*9
    #ERC20_transfer(admin, Uint256(ten_percent,0)) # amount increased in admin's balance
    #ERC20_burn(caller, Uint256(amount_to_burn,0)) # amount burned

    ERC20_transfer(admin, ten_percent) # amount increased in admin's balance
    ERC20_burn(caller, amount_to_burn) # amount burned
    
    return (1)
end
