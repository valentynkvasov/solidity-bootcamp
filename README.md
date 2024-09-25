# Practice

- [X]  **Markdown file 1:** Answer these questions
   - [X]  How does ERC721A save gas?
   - [X]  Where does it add cost?
- [X]  **Markdown file 2:** Besides the examples listed in the code and the reading, what might the wrapped NFT pattern be used for?
- [X]  **Markdown file 3:** Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace
- [X]  **Smart contract ecosystem 1:** Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract
   - [X]  Create an ERC721 NFT with a supply of 1000.
   - [X]  Include ERC 2918 royalty in your contract to have a reward rate of 2.5% for any NFT in the collection. Use the openzeppelin implementation.
   - [X]  Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
   - [X]  Create an ERC20 contract that will be used to reward staking
   - [X]  Create and a third smart contract that can mint new ERC20 tokens and receive ERC721 tokens. A classic feature of NFTs is being able to receive them to stake tokens. Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours. Don’t forget about decimal places! The user can withdraw the NFT at any time. The smart contract must take possession of the NFT and only the user should be able to withdraw it. **IMPORTANT**: your staking mechanism must follow the sequence suggested in https://www.rareskills.io/post/erc721 under “Gas efficient staking, bypassing approval”
   - [X]  Make the funds from the NFT sale in the contract withdrawable by the owner. Use Ownable2Step.
   - [X]  **Important:** Use a combination of unit tests and the gas profiler in foundry or hardhat to measure the gas cost of the various operations.
- [ ]  **Smart contract ecosystem 2:** NFT Enumerable Contracts
   - [ ]  Create a new NFT collection with 100 items using ERC721Enumerable. The token ids should be [1..100] inclusive.
   - [ ]  Create a second smart contract that has a function which accepts an address and returns how many NFTs are owned by that address which have tokenIDs that are prime numbers. For example, if an address owns tokenIds 10, 11, 12, 13, it should return 2. In a real blockchain game, these would refer to special items, but we only care about the abstract functionality for this exercise. Don’t hardcode the prime values, this should work for numbers arbitrarily larger than 20. **There is a lot of opportunity to gas optimize this routine. Read tricks in our gas optimization book:** https://www.rareskills.io/post/gas-optimization
- [ ]  **CTFs**
   - [ ]  Solve solidity riddles Overmint1 ([link](https://github.com/RareSkills/solidity-riddles))
   - [ ]  Solve solidity riddles Overmint2 ([link](https://github.com/RareSkills/solidity-riddles))
   - 
# Run Tests
``
forge test --fork-url https://rpc.ankr.com/eth
``