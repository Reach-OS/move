module reach::member {
    use std::vector;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    // save address of members
    struct Member has key,store {
        id: UID,
        addr: address,
        vote: u64
    }

    struct Members has key,store {
        id: UID,
        members: vector<Member>,
    }
    public fun get_addr(self: &Member) : address {
        self.addr
    }
    public fun get_member_amount(self: &Members) : u64 {
        let vec_mem = vec_members_immut(self);
        vector::length(vec_mem)
    }

    public fun from_vec_members(member_vec: vector<Member>, ctx: &mut TxContext): Members {
        Members { id: object::new(ctx), members: member_vec }
    }

    public fun into_vec_members(members: Members): vector<Member> {
        let Members { id, members } = members;
        object::delete(id);
        members
    }

    public fun vec_members_mut(members: &mut Members): &mut vector<Member> {
        &mut members.members
    }

    public fun vec_members_immut(members: & Members): & vector<Member> {
        & members.members
    }

    public fun new_member(addr: address, vote: u64, ctx: &mut TxContext): Member{
        Member{id: object::new(ctx), addr: addr, vote: vote}
    }

    public fun new_members(addr: address, vote: u64, ctx: &mut TxContext): Members {
        Members{id: object::new(ctx), members: vector::singleton(new_member(addr, vote, ctx))}
    }

    public fun add_member(members: &mut Members, addr: address, vote: u64, ctx: &mut TxContext) {
        let member_vec = vec_members_mut(members);
        vector::push_back(member_vec, new_member(addr, vote, ctx));
    }

    public fun member_exist(members: &Members, addr: address): bool {
        let immut_member_vec = vec_members_immut(members);
        let i = 0;
        let length = vector::length(immut_member_vec);
        while(i < length) {
            let member = vector::borrow(immut_member_vec, i);
            let addr_m = get_addr(member);
            if(addr_m == addr) return true;
            i=i+1;
        };
        false
    }
}
