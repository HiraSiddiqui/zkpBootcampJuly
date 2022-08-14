%lang starknet
from starkware.cairo.common.uint256 import Uint256, uint256_sub
@contract_interface
namespace IERC721:    

    func balanceOf(account: felt) -> (res : Uint256):
    end

    func ownerOf(tokenId: Uint256) -> (owner: felt):
    end

    func getApproved(tokenId: Uint256) -> (approved: felt):
    end

    func isApprovedForAll(owner: felt, operator: felt) -> (isApproved: felt):
    end

    func tokenURI(tokenId: Uint256) -> (tokenURI: felt):
    end

    func owner() -> (owner: felt):
    end

    func approve(to: felt, tokenId: Uint256):
    end

    func setApprovalForAll(operator: felt, approved: felt):
    end

    func transferFrom(from_:felt, to: felt, tokenId: Uint256):
    end

    func safeTransferFrom(from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*):
    end

    func mint(to: felt):
    end

    func burn(tokenId: Uint256) -> (level_granted: felt):
    end

    func setTokenURI(tokenId: Uint256, tokenURI: felt):
    end

    func transferOwnership(newOwner: felt):
    end

    func renounceOwnership():
    end

    func getCounter() -> (count: Uint256):
    end

    func getOriginalOwner(tokenId: Uint256) -> (originalOwner: felt):
    end

    func setErc20_pay(address: felt):
    end

    func mintBuy():
    end
end
