// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {Domain, ZkSyncDomain} from "xchain-helpers/testing/ZkSyncDomain.sol";
import {XChainForwarders} from "xchain-helpers/XChainForwarders.sol";

import {ZkSyncBridgeExecutor} from "../src/executors/ZkSyncBridgeExecutor.sol";

import {IPayload} from "./interfaces/IPayload.sol";

import {CrosschainPayload, CrosschainTestBase} from "./CrosschainTestBase.sol";

contract ZkSyncCrosschainPayload is CrosschainPayload {
    constructor(
        IPayload _targetPayload,
        address _bridgeExecutor
    ) CrosschainPayload(_targetPayload, _bridgeExecutor) {}

    function execute() external override {
        XChainForwarders.sendMessageZkSyncEraMainnet(
            bridgeExecutor,
            encodeCrosschainExecutionMessage(),
            10_000_000,
            800
        );
    }
}

contract ZkSyncCrosschainTest is CrosschainTestBase {
    function deployCrosschainPayload(
        IPayload targetPayload,
        address bridgeExecutor
    ) public override returns (IPayload) {
        return
            IPayload(
                new ZkSyncCrosschainPayload(targetPayload, bridgeExecutor)
            );
    }

    function setUp() public {
        hostDomain = new Domain(getChain("mainnet"));
        setChain(
            "zksync_era",
            ChainData("zkSync Era", 324, "https://mainnet.era.zksync.io")
        );
        bridgedDomain = new ZkSyncDomain(getChain("zksync_era"), hostDomain);

        bridgedDomain.selectFork();
        bridgeExecutor = address(
            new ZkSyncBridgeExecutor(
                defaultL2BridgeExecutorArgs.ethereumGovernanceExecutor,
                defaultL2BridgeExecutorArgs.delay,
                defaultL2BridgeExecutorArgs.gracePeriod,
                defaultL2BridgeExecutorArgs.minimumDelay,
                defaultL2BridgeExecutorArgs.maximumDelay,
                defaultL2BridgeExecutorArgs.guardian
            )
        );

        hostDomain.selectFork();
        vm.deal(L1_EXECUTOR, 10 ether);
    }
}
