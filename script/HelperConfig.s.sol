// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.t.sol";
contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthPriceFeed();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthPriceFeed();
        }
    }

    function getSepoliaEthPriceFeed()
        public
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
    function getOrCreateAnvilEthPriceFeed()
        public
        returns (NetworkConfig memory)
    {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        return NetworkConfig(address(mockV3Aggregator));
    }
}
