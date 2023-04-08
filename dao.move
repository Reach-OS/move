module reach::dao {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self,TxContext};
    use std::vector;
    use std::string;
    use reach::member::{Members,Member};


    const CreatorVotes: u64 = 40;

    const ErrMemberToAddIsSelf: u64 = 66;

    const ErrMemberAlreadyExist: u64 = 66;

    const ErrMemberToRemoveIsSelf: u64 = 68;

    const ErrMemberNotExist: u64 = 69;

    struct MemberManageCap has key,store { 
        id: UID
    }
    struct ProposalManageCap has key,store { 
        id: UID
    }

    struct VoteConclusion has drop {
        recipient: address,
        amount : u64,
        description : string::String
    }

    // init dao, add sender as administrator
    fun init(ctx: &mut TxContext) {
        let memberCap = MemberManageCap{id:object::new(ctx)};
        let proposalCap = ProposalManageCap{id:object::new(ctx)};
        transfer::public_transfer(memberCap,tx_context::sender(ctx));
        transfer::public_transfer(proposalCap,tx_context::sender(ctx));
        let members = reach::member::new_members(tx_context::sender(ctx), CreatorVotes, ctx);
        transfer::public_transfer(members, tx_context::sender(ctx));
    }

    
    public entry fun add_member(_: &MemberManageCap, members: &mut Members, new_member: address, votes: u64, ctx: &mut TxContext) {
        let new_member_addr = copy new_member;
        assert!(tx_context::sender(ctx) == new_member, ErrMemberToAddIsSelf);
        assert!(reach::member::member_exist(members, new_member_addr), ErrMemberAlreadyExist);
        reach::member::add_member(members, new_member, votes, ctx);
        let memberCap = MemberManageCap{id:object::new(ctx)};
        let proposalCap = ProposalManageCap{id:object::new(ctx)};
        transfer::public_transfer(memberCap, new_member);
        transfer::public_transfer(proposalCap, new_member);
    }

    // create proposal
    public entry fun create_transfer_proposal(_: &ProposalManageCap, recipient: address, amount: u64, description: string::String, members: &Members, ctx: &mut TxContext) {
        let new_proposal = reach::proposal::new_proposal(recipient, amount, description, members, ctx);
        transfer::public_transfer(new_proposal, tx_context::sender(ctx));
    }


        // member call to vote
    public entry fun vote(proposals: &mut ProposalList, members: &mut Members, proposal_index: u64, approve: bool, ctx: &mut TxContext) {
        assert(member_exists(members, tx_context::sender(ctx)), 70);
        let proposal = Vector::borrow(proposals.proposals, proposal_index);
        assert(!proposal.executed, 71);
        // let member_index = get_member_index(members.members, tx_context::sender(ctx));
        let member_index = 0;
        assert!(vector::borrow(&proposal.voted,&member_index),72);

        let voted: vector<MemberVotedInfo> = proposal.voted;
        let i = 0;
        let length = vector::length(&voted);
        let new_voted_vec = vector::empty();
        while(i < length) {
            let member_voted_info: &MemberVotedInfo = vector::borrow(&voted, i);
            let cp_member_voted_info = copy member_voted_info;
            if(vector::borrow(&voted, i).address == tx_context::sender(ctx)) {
                vector::push_back(&mut new_voted_vec,MemberVotedInfo{address:tx_context::sender(ctx),if_voted:true});
            } else {
                vector::push_back(&mut new_voted_vec, cp_member_voted_info);
            }
        };
        

        proposal.voted[member_index] = true;
        // if (approve) {
        //     proposal.votes += members[member_index].votes;
        // } else {
        //     proposal.votes -= members[member_index].votes;
        // }
    }


    // public entry fun remove_member(_: &MemberManageCap, members: Members, member_to_remove: address, ctx: &mut TxContext) {
    //     assert(tx_context::sender(ctx) != address, ErrMemberToRemoveIsSelf);
    //     let i = 0;
    //     let length = Vector::length(members.members);
    //     let new_members = Vector::empty();
    //     while(i < length) {
    //         let element = Vector::borrow(members.members, i);
    //         if(element.address != member) {
    //             Vector::push_back(&mut new_members, element);
    //         }
    //     };
    //     Members{members: new_members}
    // }

    // public fun get_member_index(members: &vector<Member>, member: &address) : u64 {
    //     let i = 0;
    //     let length = Vector::length(members);
    //     let index = 0;
    //     while (i < length) {
    //         let element = Vector::borrow(members, i);
    //         if (element.address == member) {
    //             index = i;
    //             break;
    //         }
    //     }
    //     index
    // }


    // execute proposal
    public fun execute_proposal(proposals: &mut ProposalList, members: &vector<Member>, proposal_index: u64) {
        assert(tx_context::sender(ctx) == members[0].address, 73);
        let proposal = &mut proposals.proposals[proposal_index];
        assert(!proposal.executed, 74);
        assert(proposal.votes  > 0, 75);
        proposal.executed = true;
        // send event to execute
        event::emit(
            VoteConclusion{
                recipient: proposal.recipient,
                amount : proposal.amount,
                description : proposal.description
            }
        );
    }
}
