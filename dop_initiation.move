module idea::ctrl {
    use idea::idea;
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    // publish an idea
    public entry fun publish(author:String,content:String,ctx: &mut TxContext):Content{
        let content = idea::publish(author,content,ctx);
        // Emit Currency metadata as an event.
        transfer::public_freeze_object(content);
    }
}