pragma solidity ^0.8.7;

interface IPerpsMarketProxy {
    /**
     * @notice Modify the collateral delegated to the account.
     * @param accountId Id of the account.
     * @param synthMarketId Id of the synth market used as collateral. Synth market id, 0 for snxUSD.
     * @param amountDelta requested change in amount of collateral delegated to the account.
     */
    function modifyCollateral(
        uint128 accountId,
        uint128 synthMarketId,
        int256 amountDelta
    ) external;
}
