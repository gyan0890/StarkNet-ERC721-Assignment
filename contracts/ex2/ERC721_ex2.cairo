// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/ERC721_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_check
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.introspection.erc165.library import ERC165

from openzeppelin.access.ownable.library import Ownable

// Variables 
struct Animal {
    sex: felt,
    legs: felt,
    wings: felt,
}

@storage_var
func animals(token_id : Uint256) -> (animal : Animal) {
}

@storage_var
func latest_token_id() -> (token_id: Uint256) {
}

//
// Constructor
//

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt,
        owner: felt
    ){
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);
    token_id_initializer();
    return ();
}

//
// Getters
//

@view
func supportsInterface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(interfaceId: felt) -> (success: felt){
    let (success) = ERC165.supports_interface(interfaceId);
    return (success,);
}

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt){
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt){
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256){
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (owner: felt){
    let (owner: felt) = ERC721.owner_of(tokenId);
    return (owner,);
}

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (approved: felt){
    let (approved: felt) = ERC721.get_approved(tokenId);
    return (approved,);
}

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (isApproved: felt){
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved,);
}

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (tokenURI: felt){
    let (tokenURI: felt) = ERC721.token_uri(tokenId);
    return (tokenURI,);
}

@view
func owner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt){
    let (owner: felt) = Ownable.owner();
    return (owner,);
}

@view
func get_animal_characteristics{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id : Uint256) -> (sex : felt, legs : felt, wings : felt) {
    with_attr error_message("ERC721: token_id is not a valid Uint256") {
        uint256_check(token_id);
    }
    let animal = animals.read(token_id);
    let animal_ptr = cast(&animal, Animal*);
    return (sex=animal_ptr.sex, legs=animal_ptr.legs, wings=animal_ptr.wings);
}

//Initialize the token ID
func token_id_initializer{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}() {
    let zero_as_uint256 : Uint256 = Uint256(0, 0);
    latest_token_id.write(zero_as_uint256);
    return ();
}

//
// Externals
//

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, tokenId: Uint256){
    ERC721.approve(to, tokenId);
    return ();
}

@external
func declare_animal{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(sex : felt, legs : felt, wings : felt) -> (token_id : Uint256){
    alloc_locals;
    Ownable.assert_only_owner();

    //Create token IDs for minting
    let current_token_id : Uint256 = latest_token_id.read();
    let one_as_uint256 = Uint256(1, 0);
    let (local new_token_id, _) = uint256_add(current_token_id, one_as_uint256);
 
    //Minting the new token
    let (sender_address) = get_caller_address();
    ERC721._mint(sender_address, new_token_id);

    //Write new token -> animal mapping to the struct variable
    animals.write(new_token_id, Animal(sex=sex, legs=legs, wings=wings));
    
    //Update the latest token ID
    latest_token_id.write(new_token_id);
    return (token_id=new_token_id);
}

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt){
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256
    ){
    ERC721.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256,
        data_len: felt,
        data: felt*
    ){
    ERC721.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

//NOT REQUIRED FOR EX2
// @external
// func mint{
//         pedersen_ptr: HashBuiltin*,
//         syscall_ptr: felt*,
//         range_check_ptr
//     }(to: felt, tokenId: Uint256){
//     Ownable.assert_only_owner();
//     ERC721._mint(to, tokenId);
//     return ();
// }

@external
func burn{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256){
    ERC721.assert_only_token_owner(tokenId);
    ERC721._burn(tokenId);
    return ();
}

@external
func setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256, tokenURI: felt){
    Ownable.assert_only_owner();
    ERC721._set_token_uri(tokenId, tokenURI);
    return ();
}

@external
func transferOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(newOwner: felt){
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(){
    Ownable.renounce_ownership();
    return ();
}