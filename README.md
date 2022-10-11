# ✨ So you want to sponsor a contest

This `README.md` contains a set of checklists for our contest collaboration.

Your contest will use two repos: 
- **a _contest_ repo** (this one), which is used for scoping your contest and for providing information to contestants (wardens)
- **a _findings_ repo**, where issues are submitted (shared with you after the contest) 

Ultimately, when we launch the contest, this contest repo will be made public and will contain the smart contracts to be reviewed and all the information needed for contest participants. The findings repo will be made public after the contest report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the contest sponsor (⭐️)**.

---

# Contest setup

## ⭐️ Sponsor: Provide contest details

Under "SPONSORS ADD INFO HERE" heading below, include the following:

- [ ] Create a PR to this repo with the below changes:
- [ ] Name of each contract and:
  - [ ] source lines of code (excluding blank lines and comments) in each
  - [ ] external contracts called in each
  - [ ] libraries used in each
- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [ ] Describe anything else that adds any special logic that makes your approach unique
- [ ] Identify any areas of specific concern in reviewing the code
- [ ] Add all of the code to this repo that you want reviewed


---

# Contest prep

## ⭐️ Sponsor: Contest prep
- [ ] Provide a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2021-06-gro/blob/main/README.md))
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 24 hours prior to contest start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the contest — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the contest. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)
- [ ] Promote the contest on Twitter (optional: tag in relevant protocols, etc.)
- [ ] Share it with your own communities (blog, Discord, Telegram, email newsletters, etc.)
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# Trader Joe v2 contest details
- $95,000 USDC main award pot
- $5,000 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-10-trader-joe-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 12, 2022 20:00 UTC
- Ends October 21, 2022 20:00 UTC

## Description

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