// SPDX-License-Identifier: Mozilla Public License 2.0

// IMPORTANT! Sui module names are always in CamelCase format.
// Ref: https://github.com/MystenLabs/sui/blob/main/doc/src/build/move/index.md
module mini_miners::mine_nft {
    use sui::object::{Self, UID};
    // use sui::object_bag::{Self, ObjectBag};
    // use sui::object_table::{Self, ObjectTable};
    // use sui::dynamic_object_field;
    // use sui::typed_id::{Self, TypedID};
    use sui::tx_context::{Self, TxContext};
    // use std::option::{Self, Option};
    use sui::transfer;
    // use std::ascii::{Self, String};
    // use std::vector;

    const ENotFactory: u64 = 1;

    struct Mine has key, store {
        id: UID,
        generation: u64,
        quality: u64
    }

    // The permissioned to mint
    struct Factory has key {
        id: UID,
        permissioned: bool,
    }

    fun init(ctx: &mut TxContext) {
        let minter = Factory {
            id: object::new(ctx),
            permissioned: true,
        };
        // smartcontracts could be minted by the owner
        transfer::transfer(minter, tx_context::sender(ctx))
    }

    // mint a new nft
    public entry fun mint(factory: &Factory, to: address, generation: u64, quality: u64, ctx: &mut TxContext) {
        assert!(factory.permissioned == true, ENotFactory);

        let mine = Mine {
            id: object::new(ctx),
            generation: generation,
            quality: quality
        };

        transfer::transfer(mine, to);
    }

    // transfer minted nft
    public entry fun transfer(mine: Mine, recipient: address, _ctx: &mut TxContext) {
        use sui::transfer;
        // transfer the MineNFT
        transfer::transfer(mine, recipient);
    }

    public fun generation(mine: &Mine): u64 {
        mine.generation
    }
    
    public fun quality(mine: &Mine): u64 {
        mine.quality
    }

    #[test]
    public fun test_mint() {
        use sui::tx_context;

        let ctx = tx_context::dummy();

        // generation and quality
        let g: u64 = 0;
        let q: u64 = 1;
        let id = object::new(&mut ctx);

        let mine = Mine {
            id: id,
            generation: g,
            quality: q,
        };

        assert!(generation(&mine) == g && quality(&mine) == q, 1);

        transfer::transfer(mine, tx_context::sender(&mut ctx));
    }
}
