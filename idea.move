module idea::idea {
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};

    struct IDEA has key,store {
        id:UID,
        author:String,
        content:String,
        father_idea:address
    }
    // publish an idea
    public fun publish(author:String,content:String,father_idea:address,ctx: &mut TxContext):IDEA{
        IDEA {
            id: object::new(ctx),
            author: author,
            content: content,
            father_idea:father_idea
        }
    }
}