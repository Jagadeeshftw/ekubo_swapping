use snforge_std::{
    declare, DeclareResultTrait, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address
};
use starknet::{ContractAddress};
use ekubo::types::keys::PoolKey;
use ekubo::types::i129::i129;
use ekubo::interfaces::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
use ekubo_swap::swap::swap::{ISwapDispatcher, ISwapDispatcherTrait, SwapData};
use ekubo::interfaces::core::{SwapParameters};
use ekubo_swap::constants::{contracts, tokens, HYPOTHETICAL_OWNER_ADDR, pool_key};


fn declare_and_deploy() -> ISwapDispatcher {

    let contract = declare("swap").unwrap().contract_class();

    let (contract_address, _) = contract
        .deploy(@array![contracts::EKUBO_CORE_MAINNET.try_into().unwrap()])
        .unwrap();

    ISwapDispatcher { contract_address }
}

#[test]
#[fork("MAINNET_FORK")]
fn test_usdc_for_strk_swap() {

    let usdc_addr: ContractAddress = tokens::USDC.try_into().unwrap();
    let strk_addr: ContractAddress = tokens::STRK.try_into().unwrap();
    let user: ContractAddress = HYPOTHETICAL_OWNER_ADDR.try_into().unwrap();

    let pool_key = PoolKey {
        token0: strk_addr,
        token1: usdc_addr,
        fee: pool_key::FEE,
        tick_spacing: pool_key::TICK_SPACING,
        extension: pool_key::EXTENSION.try_into().unwrap()
    };

    let amount = i129 { mag: 1_000_000_000_000_000_000, sign: false }; // 1 STRK
    let swap_params = SwapParameters {
        amount,
        sqrt_ratio_limit: pool_key::SQRT_RATIO_LIMIT,
        is_token1: false,
        skip_ahead: 0
    };

    let swap_data = SwapData {
        params: swap_params,
        pool_key,
        caller: user
    };

    let strk = IERC20Dispatcher { contract_address: strk_addr };

    start_cheat_caller_address(strk.contract_address, user);
    let dispatcher = declare_and_deploy();
    strk.transfer(dispatcher.contract_address, 1_000_000_000_000_000_000);
    stop_cheat_caller_address(strk.contract_address);

    let usdc = IERC20Dispatcher { contract_address: usdc_addr};

    let balance_before = usdc.balanceOf(user);

    dispatcher.swap(swap_data);

    let balance_after = usdc.balanceOf(user);

    assert_ge!(balance_after,balance_before);

}


#[test]
#[fork("MAINNET_FORK")]
fn test_eth_for_strk_swap() {

    let eth_addr: ContractAddress = tokens::ETH.try_into().unwrap();
    let strk_addr: ContractAddress = tokens::STRK.try_into().unwrap();
    let user: ContractAddress = HYPOTHETICAL_OWNER_ADDR.try_into().unwrap();

    let pool_key = PoolKey {
        token0: strk_addr,
        token1: eth_addr,
        fee: pool_key::FEE,
        tick_spacing: pool_key::TICK_SPACING,
        extension: pool_key::EXTENSION.try_into().unwrap()
    };

    let amount = i129 { mag: 1_000_000_000_000_000_000, sign: false }; // 1 STRK
    let swap_params = SwapParameters {
        amount,
        sqrt_ratio_limit: pool_key::SQRT_RATIO_LIMIT,
        is_token1: false,
        skip_ahead: 0
    };

    let swap_data = SwapData {
        params: swap_params,
        pool_key,
        caller: user
    };

    let strk = IERC20Dispatcher { contract_address: strk_addr };

    start_cheat_caller_address(strk.contract_address, user);
    let dispatcher = declare_and_deploy();
    strk.transfer(dispatcher.contract_address, 1_000_000_000_000_000_000);
    stop_cheat_caller_address(strk.contract_address);

    let eth = IERC20Dispatcher { contract_address: eth_addr};

    let balance_before = eth.balanceOf(user);

    dispatcher.swap(swap_data);

    let balance_after = eth.balanceOf(user);

    assert_ge!(balance_after,balance_before);

}