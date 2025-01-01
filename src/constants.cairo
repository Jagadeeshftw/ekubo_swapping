
pub mod tokens {
    pub const ETH: felt252 = 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
    pub const USDC: felt252 = 0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8;
    pub const STRK: felt252 = 0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d;
}

pub mod contracts {
    pub const EKUBO_CORE_MAINNET: felt252 =
        0x00000005dd3d2f4429af886cd1a3b08289dbcea99a294197e9eb43b0e0325b4b;
}

pub mod pool_key {
    pub const FEE: u128 = 170141183460469235273462165868118016;
    pub const TICK_SPACING: u128 = 1000;
    pub const EXTENSION: felt252 = 0;
    pub const SQRT_RATIO_LIMIT: u256 = 18446748437148339061; // min sqrt ratio limit
}

pub const HYPOTHETICAL_OWNER_ADDR: felt252 =
    0x059a943ca214c10234b9a3b61c558ac20c005127d183b86a99a8f3c60a08b4ff;