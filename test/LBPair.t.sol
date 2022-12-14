// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./TestHelper.sol";

contract LiquidityBinPairTest is TestHelper {
    function setUp() public {
        token6D = new ERC20MockDecimals(6);
        token18D = new ERC20MockDecimals(18);

        factory = new LBFactory(DEV, 8e14);
        ILBPair _LBPairImplementation = new LBPair(factory);
        factory.setLBPairImplementation(address(_LBPairImplementation));
        setDefaultFactoryPresets(DEFAULT_BIN_STEP);
        addAllAssetsToQuoteWhitelist(factory);
        router = new LBRouter(ILBFactory(DEV), IJoeFactory(DEV), IWAVAX(DEV));

        pair = createLBPairDefaultFees(token6D, token18D);
    }

    function testPendingFeesNotIncreasingReverts() public {
        uint256[] memory _ids = new uint256[](2);
        _ids[0] = uint256(ID_ONE);
        _ids[1] = uint256(ID_ONE) - 1;
        vm.expectRevert(LBPair__OnlyStrictlyIncreasingId.selector);
        pair.pendingFees(DEV, _ids);
    }

    function testMintWrongLengthsReverts() public {
        uint256[] memory _deltaIds;
        uint256[] memory _distributionX;
        uint256[] memory _distributionY;
        uint256 _numberBins = 0;
        _deltaIds = new uint256[](_numberBins);
        _distributionX = new uint256[](_numberBins);
        _distributionY = new uint256[](_numberBins);

        vm.expectRevert(LBPair__WrongLengths.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);
        _numberBins = 2;
        _deltaIds = new uint256[](_numberBins);
        _distributionX = new uint256[](_numberBins - 1);
        _distributionY = new uint256[](_numberBins);
        vm.expectRevert(LBPair__WrongLengths.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);
        _distributionX = new uint256[](_numberBins);
        _distributionY = new uint256[](_numberBins - 1);
        vm.expectRevert(LBPair__WrongLengths.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);
    }

    function testDistributionOverflowReverts() public {
        uint256 amount = 10e18;
        token6D.mint(address(pair), amount);
        token18D.mint(address(pair), amount);
        uint256[] memory _deltaIds;
        uint256[] memory _distributionX;
        uint256[] memory _distributionY;
        uint256 _numberBins = 1;
        _deltaIds = new uint256[](_numberBins);
        _distributionX = new uint256[](_numberBins);
        _distributionY = new uint256[](_numberBins);
        _distributionX[0] = Constants.PRECISION + 1;
        vm.expectRevert(LBPair__DistributionsOverflow.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);

        _distributionX[0] = 0;
        _distributionY[0] = Constants.PRECISION + 1;
        vm.expectRevert(LBPair__DistributionsOverflow.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);

        _numberBins = 2;
        _deltaIds = new uint256[](_numberBins);
        _deltaIds[0] = ID_ONE;
        _deltaIds[1] = ID_ONE + 1;
        _distributionX = new uint256[](_numberBins);
        _distributionY = new uint256[](_numberBins);
        _distributionX[0] = Constants.PRECISION / 2;
        _distributionX[1] = Constants.PRECISION / 2 + 1;
        vm.expectRevert(LBPair__DistributionsOverflow.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);

        _distributionX[0] = 0;
        _distributionX[1] = 0;
        _distributionY[0] = Constants.PRECISION / 2;
        _distributionY[1] = Constants.PRECISION / 2 + 1;
        vm.expectRevert(LBPair__DistributionsOverflow.selector);
        pair.mint(_deltaIds, _distributionX, _distributionY, DEV);
    }

    function testInsufficientLiquidityBurnedReverts() public {
        uint256 _numberBins = 2;
        uint256[] memory _deltaIds;
        uint256[] memory _amounts;
        _deltaIds = new uint256[](_numberBins);
        _amounts = new uint256[](_numberBins);
        _deltaIds[0] = ID_ONE;
        _deltaIds[1] = ID_ONE + 1;
        _amounts[0] = 0;
        _amounts[1] = 0;
        vm.expectRevert(abi.encodeWithSelector(LBPair__InsufficientLiquidityBurned.selector, _deltaIds[0]));
        pair.burn(_deltaIds, _amounts, DEV);
    }

    function testCollectingFeesOnlyFeeRecipient() public {
        vm.prank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(LBPair__OnlyFeeRecipient.selector, DEV, ALICE));
        pair.collectProtocolFees();
    }
}
