// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/ERC721_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_check, uint256_eq
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

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

//Storage variable to map the breeder address to 0 or 1
@storage_var
func whitelisted_breeders(breeder : felt) -> (is_whitelisted : felt) {
}

//Storing the tokens of each owner by index
@storage_var
func token_owner_by_index(account : felt, index : felt) -> (token_id : Uint256){
    
}

//Mapping to store the number of tokens an account holds
@storage_var
func account_token_map(account : felt) -> (index: felt) {
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

//Get if a given breeder is whitelisted or not
@view
func is_breeder_whitelisted{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(breeder : felt) -> (is_whitelisted : felt) {
    alloc_locals;
    let (local whitelisted) = whitelisted_breeders.read(breeder);
    with_attr error_message("ERC721: Breeder is not whitelisted") {
        assert_not_zero(whitelisted);
    }
    return (whitelisted,);
}

@view
func token_of_owner_by_index{
    pedersen_ptr : HashBuiltin*, 
    syscall_ptr : felt*, 
    range_check_ptr}(account : felt, index : felt) -> (token_id : Uint256){
    let (token_id_index) = token_owner_by_index.read(account, index);
    return (token_id=token_id_index);
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

//Only owner can whitelist the breeder
@external
func whitelist_breeder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    breeder : felt
) {
    alloc_locals;
    Ownable.assert_only_owner();
    whitelisted_breeders.write(breeder,1);
    return ();
}

@external
func declare_animal{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(sex : felt, legs : felt, wings : felt) -> (token_id : Uint256){
    alloc_locals;
    let (sender_address) = get_caller_address();
    // Ownable.assert_only_owner();
    let (breeder_status,) = whitelisted_breeders.read(sender_address);
    with_attr error_message("ERC721: Breeder is not whitelisted"){
        assert_not_zero(breeder_status);
    }

    //Create token IDs for minting
    let current_token_id : Uint256 = latest_token_id.read();
    let one_as_uint256 = Uint256(1, 0);
    let zero_as_uint256 = Uint256(0, 0);
    let (local new_token_id, _) = uint256_add(current_token_id, one_as_uint256);
 
    //Minting the new token
    ERC721._mint(sender_address, new_token_id);

    //Write new token -> animal mapping to the struct variable
    animals.write(new_token_id, Animal(sex=sex, legs=legs, wings=wings));
    //Update the latest token ID
    latest_token_id.write(new_token_id);

    //Update the number of tokens for an account 
    let (token_num) = account_token_map.read(sender_address);
    let token_num_uint : Uint256 = account_token_map.read(sender_address);
    let (is_token_0) = uint256_eq(token_num_uint, zero_as_uint256);
    if(is_token_0 == 1) {
        account_token_map.write(sender_address, 1);
        token_owner_by_index.write(sender_address, 0, new_token_id);
    } else {
        token_owner_by_index.write(sender_address, token_num, new_token_id);
        account_token_map.write(sender_address, token_num+1);
    }

    return (token_id=new_token_id);
}

@external
func declare_dead_animal {
    syscall_ptr: felt*, 
    pedersen_ptr: HashBuiltin*, 
    range_check_ptr} (token_id : Uint256) {
    alloc_locals;
    let (sender_address) = get_caller_address();
    // Checking if the caller is a breeder
    let (breeder_status,) = whitelisted_breeders.read(sender_address);
    with_attr error_message("ERC721: Breeder is not whitelisted"){
        assert_not_zero(breeder_status);
    }
    let zero_as_uint256 = Uint256(0, 0);
    //Burn the token and nullify the mapping
    ERC721._burn(token_id);
    animals.write(token_id, Animal(sex=0, legs=0, wings=0));
    //0th index is being called by the Evaluator contract - so currently
    //removing the token ID from 0th index
    // But overall this doesn't make that much sense, since there is no
    // specified action on how it expects the burn to happen(does the empty index now need to be shifted?)
    token_owner_by_index.write(sender_address, 0, zero_as_uint256);
    return ();
    
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