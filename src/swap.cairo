#[starknet::contract]
pub mod swap {
    use ekubo::types::delta::Delta;
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use ekubo::interfaces::core as ekubo_core;
    use ekubo::types::keys::PoolKey;
    use ekubo::interfaces::core::{ICoreDispatcherTrait, SwapParameters};

    #[storage]
    struct Storage {
        core: ekubo_core::ICoreDispatcher,
        owner: ContractAddress,
    }

    #[derive(Copy, Drop, Serde)]
    pub struct SwapData {
        pub params: SwapParameters,
        pub pool_key: PoolKey,
        pub caller: ContractAddress,
    }

    #[starknet::interface]
    pub trait ISwap<TContractState> {
        fn swap(ref self: TContractState, swap_data: SwapData) -> SwapResult;
    }

    #[derive(Copy, Drop, Serde)]
    struct SwapResult {
        delta: Delta,
    }

    #[constructor]
    fn constructor(ref self: ContractState, core: ContractAddress) {
        let core = ekubo_core::ICoreDispatcher { contract_address: core };
        self.core.write(core);
    }

    #[abi(embed_v0)]
    impl LockerImpl of ekubo_core::ILocker<ContractState> {
        fn locked(ref self: ContractState, id: u32, data: Span<felt252>) -> Span<felt252> {
            let core = self.core.read();
            let SwapData {
                pool_key, params, caller,
            } = ekubo::components::shared_locker::consume_callback_data::<SwapData>(core, data);
            let delta = core.swap(pool_key, params);
            println!("Delta: {:?}", delta);
            ekubo::components::shared_locker::handle_delta(
                core, pool_key.token0, delta.amount0, caller,
            );
            ekubo::components::shared_locker::handle_delta(
                core, pool_key.token1, delta.amount1, caller,
            );
            let swap_result = SwapResult { delta };

            let mut arr: Array<felt252> = ArrayTrait::new();
            Serde::serialize(@swap_result, ref arr);
            arr.span()
        }
    }

    #[abi(embed_v0)]
    impl SwapImpl of ISwap<ContractState> {
        fn swap(ref self: ContractState, swap_data: SwapData) -> SwapResult {
            ekubo::components::shared_locker::call_core_with_callback(self.core.read(), @swap_data)
        }
    }
}
