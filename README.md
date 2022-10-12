# Trader Joe v2 contest details
- $95,000 USDC main award pot
- $5,000 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-10-trader-joe-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 14, 2022 20:00 UTC
- Ends October 23, 2022 20:00 UTC

## Description

This repository contains the Liquidity Book contracts, as well as tests and deploy scripts.

- The [LBPair](https://github.com/code-423n4/2022-10-traderjoe/blob/main//src/LBPair.sol) is the contract that contains all the logic of the actual pair for swaps, adds, removals of liquidity and fee claiming. This contract should never be deployed directly, and the factory should always be used for that matter.

- The [LBToken](https://github.com/code-423n4/2022-10-traderjoe/blob/main//src/LBToken.sol) is the contract that is used to calculate the shares of a user. The LBToken is a new token standard that is similar to ERC-1155, but without any callbacks (for safety reasons) and any functions or variables relating to ERC-721. To make liquidity management easier, helper functions were added to return user's positions.

- The [LBFactory](https://github.com/code-423n4/2022-10-traderjoe/blob/main//src/LBPair.sol) is the contract used to deploy the different pairs and acts as a registry for all the pairs already created. There are also privileged functions such as setting the parameters of the fees, the flashloan fee, setting the pair implementation, set if a pair should be ignored by the quoter and add new presets. Unless the `creationUnlocked` is `true`, only the owner of the factory can create pairs.

- The [LBRouter](https://github.com/code-423n4/2022-10-traderjoe/blob/main//src/LBRouter.sol) is the main contract that user will interact with as it adds security checks. Most users shouldn't interact directly with the pair.

- The [LBQuoter](https://github.com/code-423n4/2022-10-traderjoe/blob/main//src/LBQuoter.sol) is a contract that is used to return the best route of all those given. This should be used before a swap to get the best return on a swap.

For more information, go to the [documentation](https://docs.traderjoexyz.com/) and the [whitepaper](https://github.com/traderjoe-xyz/LB-Whitepaper/blob/main/Joe%20v2%20Liquidity%20Book%20Whitepaper.pdf).

Describe any novel or unique curve logic or mathematical models implemented in the contracts:
* Price curve is discretized into constant sum bins
* We use 128x128 fixed-point binary numbers to cover the entire price range
* The max number of bins is 2**24
* Each pair has a three-level trie that tracks the presence of liquidity in each bin

Does the token conform to the ERC-20 standard? In what specific ways does it differ?
* The token doesn't conform to the ERC-20 standard, but it's closer to the ERC-1155 standard.
* The token can only be used for sets of ERC-20, and thus, can't create any ERC721. It also removes the callbacks for safety reasons.

Identify any areas of specific concern in reviewing the code:
* The volatility accumulator formula has changed since the whitepaper was published, reviewers should refer to the docs for the most up to date version.
* One area of concern is whether users can "steal" tokens, i.e. they get more than expected. For example:
  * Receiving more tokens than expected during a swap
  * Performing a successful flash loan without repaying back the loaned tokens or the fee
  * Receiving more liquidity tokens than expected when adding liquidity
  * Receiving more tokens than expected when liquidity is removed
  * Receiving more fees than expected when fees are claimed
* Math rounding should never favour the user. For example, when liquidity is removed, token amounts should be rounded down to ensure they don't get more than expected and when an user swaps, it should round up the amountIn, while rounding down the amountOut to make sure they don't get more than expected.
* Ensuring invariants hold. For example:
  * When adding liquidity, reserves should only increase
  * When doing a flashLoan, fees should only increase
  * When removing liquidity, reserves should only decrease
  * When swapping tokens, `L` should remain constant, while `x` and `y` should follow `L = p * x + y` and fees should only increase
  * When adding liquidity to the active bin, if the tokens are not added with the same ratio as the reserve of the active bin, the fees should only increase
  * When claiming fees, the fees should only decrease and the reserves should stay constant

## Contracts

All contracts under `src` are in Scope for this contest, including `src/libraries` and `src/interfaces`. Contracts under `lib` are not in Scope.

### Core

##### LBToken

- 227 sloc
- External contracts called: None
- Libraries used: LBErrors, EnumerableSet

##### LBPair

- 837 sloc
- External contracts called: ERC20, LBFactory, ILBFlashLoanCallback
- Libraries used: LBToken, BinHelper, Math512Bits, SafeCast, SafeMath, TreeMath, Constants, ReentrancyGuardUpgradeable, Oracle, Decoder, SwapHelper, FeeDistributionHelper, TokenHelper

##### LBFactory

- 507 sloc
- External contracts called: LBPair
- Libraries used: EnumerableSet, Clones, LBErrors, PendingOwnable, Constants, Decoder, SafeCast

##### LBRouter

- 837 sloc
- External contracts called: LBPair, JoePair
- Libraries used: LBErrors, BinHelper, FeeHelper, TokenHelper, Math512Bits, SwapHelper, Constants

##### LBQuoter

- 214 sloc
- External contracts called: LBPair, JoeFactory, LBFactory, LBRouter
- Libraries used: JoeLibrary, BinHelper, Math512Bits

##### LBErrors

- 148 sloc
- External contracts called: None
- Libraries used: None

### Libraries

##### BinHelper

- 48 sloc
- External contracts called: None
- Libraries used: Math128x128, LBErrors

##### BitMath

- 133 sloc
- External contracts called: None
- Libraries used: None

##### Buffer

- 24 sloc
- External contracts called: None
- Libraries used: None

##### Constants

- 11 sloc
- External contracts called: None
- Libraries used: None

##### Decoder

- 22 sloc
- External contracts called: None
- Libraries used: None

##### Encoder

- 22 sloc
- External contracts called: None
- Libraries used: None

##### FeeDistributionHelper

- 52 sloc
- External contracts called: ERC20
- Libraries used: LBErrors, FeeHelper, Constants, TokenHelper, SafeCast

##### FeeHelper

- 145 sloc
- External contracts called: None
- Libraries used: SafeCast, SafeMath, Constants

##### JoeLibrary

- 50 sloc
- External contracts called: None
- Libraries used: LBErrors

##### Math128x128

- 183 sloc
- External contracts called: None
- Libraries used: LBErrors, Math512Bits, BitMath, Constants

##### Math512Bits

- 229 sloc
- External contracts called: None
- Libraries used: LBErrors, BitMath

##### Oracle

- 166 sloc
- External contracts called: None
- Libraries used: LBErrors, Samples, Buffer

##### PendingOwnable

- 91 sloc
- External contracts called: None
- Libraries used: LBErrors

##### ReentrancyGuardUpgradeable

- 43 sloc
- External contracts called: None
- Libraries used: LBErrors

##### SafeCast

- 194 sloc
- External contracts called: None
- Libraries used: LBErrors

##### SafeMath

- 16 sloc
- External contracts called: None
- Libraries used: None

##### Samples

- 103 sloc
- External contracts called: None
- Libraries used: Encoder, Decoder

##### SwapHelper

- 120 sloc
- External contracts called: None
- Libraries used: FeeHelper, Constants, BinHelper, SafeMath, FeeDistributionHelper, Math512Bits

##### TokenHelper

- 75 sloc
- External contracts called: None
- Libraries used: LBErrors, Samples, Buffer

##### TreeMath

- 101 sloc
- External contracts called: None
- Libraries used: LBErrors, BitMath

## Install foundry

Foundry documentation can be found [here](https://book.getfoundry.sh/forge/index.html).

### On Linux and macOS

Open your terminal and type in the following command:

```
curl -L https://foundry.paradigm.xyz | bash
```

This will download foundryup. Then install Foundry by running:

```
foundryup
```

To update foundry after installation, simply run `foundryup` again, and it will update to the latest Foundry release.
You can also revert to a specific version of Foundry with `foundryup -v $VERSION`.

### On Windows

If you use Windows, you need to build from source to get Foundry.

Download and run `rustup-init` from [rustup.rs](https://rustup.rs/). It will start the installation in a console.

After this, run the following to build Foundry from source:

```
cargo install --git https://github.com/foundry-rs/foundry foundry-cli anvil --bins --locked
```

To update from source, run the same command again.

## Install dependencies

To install dependencies, run the following to install dependencies:

```
forge install
```

___

## Tests

To run tests, run the following command:

```
forge test
```
