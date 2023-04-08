module reach::proposal {
    use sui::object::{Self, UID};
    use std::vector;
    use sui::tx_context::{TxContext};
    use std::string;
    use reach::member::{Self,Members,Member};

    // save proposal
    struct Proposal has key,store{
        id: UID,
        recipient: address,
        amount: u64,
        description: string::String,
        executed: bool,
        votes: u64,
        voted: vector<MemberVotedInfo>
    }

    struct MemberVotedInfo has key,store {
        id: UID,
        addr: address,
        if_voted: bool
    }

    public fun new_proposal(recipient: address, amount: u64, description: string::String, members: &Members , ctx: &mut TxContext) : Proposal{
        let voted_info_vec: vector<MemberVotedInfo> = vector::empty<MemberVotedInfo>();
        let vec_immut_member = reach::member::vec_members_immut(members);
        let length = vector::length(vec_immut_member);
        let i = 0;
        while (i < length) {
            let member = vector::borrow(vec_immut_member, i);
            let member_address = reach::member::get_addr(member);
            vector::push_back(&mut voted_info_vec, MemberVotedInfo{id: object::new(ctx),addr: member_address,if_voted: false });
            i=i+1;
        };
        Proposal {
            id: object::new(ctx),
            recipient: recipient,
            amount: amount,
            description: description,
            executed: false,
            votes: 0,
            voted: voted_info_vec
        }
    }

    public fun if_executed(proposal: &Proposal): bool {
        proposal.executed
    }

    public fun set_vote_conclusion(proposal: &mut Proposal, members: &Members, voter: address, approve: bool) {
        
        // todo;
    }





}