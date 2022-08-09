## I AM NOT DONE

%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_le, uint256_unsigned_div_rem, uint256_sub
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import unsigned_div_rem, assert_le_felt, assert_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash_state import hash_init, hash_update 
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor

struct Square:    
    member square_commit: felt
    member square_reveal: felt
    member shot: felt
end

struct Player:    
    member address: felt
    member points: felt
    member revealed: felt
end

struct Game:        
    member player1: Player
    member player2: Player
    member next_player: felt
    member last_move: (felt,felt)
    member winner: felt
end

@storage_var
func grid(game_idx : felt, player : felt, x : felt, y : felt) -> (square : Square):
end

@storage_var
func games(game_idx : felt) -> (game_struct : Game):
end

@storage_var
func game_counter() -> (game_counter : felt):
end

func hash_numb{pedersen_ptr : HashBuiltin*}(numb : felt) -> (hash : felt):

    alloc_locals
    
    let (local array : felt*) = alloc()
    assert array[0] = numb
    assert array[1] = 1
    let (hash_state_ptr) = hash_init()
    let (hash_state_ptr) = hash_update{hash_ptr=pedersen_ptr}(hash_state_ptr, array, 2)   
    tempvar pedersen_ptr :HashBuiltin* = pedersen_ptr       
    return (hash_state_ptr.current_hash)
end


## Provide two addresses
@external
func set_up_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(player1 : felt, player2 : felt):
    let p1 = Player(player1,0,0)
    let p2 = Player(player2,0,0)
    let (gameCounter) = game_counter.read()
    let newGame = Game(p1,p2,0,(0,0),0)
    games.write(gameCounter,newGame)
    game_counter.write(gameCounter+1)

    return ()
end

@view 
func check_caller{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(caller : felt, game : Game) -> (valid : felt):
    let player1 = game.player1.address
    let player2 = game.player2.address
    
    if player1 == caller:    
        return (1)
    end
    if player2 == caller:    
        return (1)
    end
    return(0)  
end

@view
func check_hit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(square_commit : felt, square_reveal : felt) -> (hit : felt):
   alloc_locals
   #let (hash_square_commit) = hash_numb(square_commit)
   let (hash_square_reveal) = hash_numb(square_reveal)
    if square_commit == hash_square_reveal:
        let (q, r) = unsigned_div_rem(square_reveal,2)
        #Return 1 for a hit, and 0 for a miss.
        if r == 1:
            return (1)
        end
        return (0)
    end
    return (0)
end

@external
func bombard{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(game_idx : felt, x : felt, y : felt, square_reveal : felt):
    # read the game
    
    alloc_locals
    let (game) = games.read(game_idx)
    let (caller) = get_caller_address()

    # check if the caller is one of the players
    let (valid_caller) = check_caller(caller,game)
    assert valid_caller = 0


    #check who is the caller
    let player1 = game.player1.address
    let player2 = game.player2.address
    let current_player = 0
    if caller == player1:
        current_player = player1
    end
    if caller == player2:
        current_player = player2
    end

    #checks whether it is their move (first move can be by anyone).
    #Then it will check whether this is the very first move and whether it needs to process the square_reveal argument,
    if game.last_move[0] == 0:
        if game.last_move[1] == 0:
            #TODO
            let (square) = grid.read(game_idx, caller, x, y)
            let new_square = Square(square.square_commit, square.square_reveal, 1)
            grid.write(game_idx, caller, x, y, new_square)
        end
    end

    # if it is not first move it will assert that is the right player and call check_hit. 
    if game.last_move[0] != 0:

        if game.last_move[1] != 0:
            # This is not the first move, need to check if this is the current player's move
            let next_player = game.next_player

            if next_player != current_player:

                # player1 is not the next player - invalid call
                #return ()
            end
        end
    end



    #If the player has accumulated four points, they are declared a winner.


    #If hit has been made, score for the previous player will be incremented.
    # here do check hit

    # The next player will be set to the opposite player depending on what current caller is.


    #The game struct under this particular game index will be updated to reflect changes in:

    #player points
    #next player
    #potential winner
    #last move
    return ()
end

## Check malicious call

func add_squares{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(idx : felt, game_idx : felt, hashes_len : felt, hashes : felt*, player : felt, x: felt, y: felt):
    # read the game
    let (game) = games.read(game_idx)
    
    # check if the caller is one of the players
    let valid_caller = check_caller(game)
    if valid_caller == 0:
        #invalid caller
        return ()
    end
    load_hashes(0,game_idx,hashes_len,hashes,player,x,y)

    return ()
end

## loops until array length

func load_hashes{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(idx : felt, game_idx : felt, hashes_len : felt, hashes : felt*, player : felt, x: felt, y: felt):
    if hashes_len == 0:
        return()
    end

    let (square) = grid.read(game_idx, player, x, y)
    let updated_square = Square([hashes], square.square_reveal, square.shot)
    grid.write(game_idx, player, x, y, updated_square)

    if x == 4:
        load_hashes(idx, game_idx, hashes_len - 1, hashes + 1, player, x = 0, y = y + 1)
    end

    if x != 4:
        load_hashes(idx, game_idx, hashes_len - 1, hashes + 1, player, x = x + 1, y = y)
    end
end