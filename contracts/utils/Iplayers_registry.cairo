%lang starknet

////////////////////////////////////////
// INTERFACE
////////////////////////////////////////

@contract_interface
namespace Iplayers_registry {
    func has_validated_exercice(account : felt, workshop : felt, exercise : felt) -> (
        has_validated_exercice : felt
    ){ 
    }
    func is_exercise_or_admin(account : felt) -> (permission : felt){
    }
    func next_player_rank() -> (next_player_rank : felt){
    }
    func players_registry(rank : felt) -> (account : felt){
    }
    func player_ranks(account : felt) -> (rank : felt){
    }
    func set_exercise_or_admin(account : felt, permission : felt){
    }
    func set_exercises_or_admins(accounts_len : felt, accounts : felt*){
    }
    func validate_exercice(account : felt, workshop : felt, exercise : felt){
    }
}
