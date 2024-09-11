# ERC777
Pros:
* Operator Model - introduces the concept of operators, which are addresses that can be approved to send tokens on behalf of other users.
* Hooks and Receiving Mechanism - uses the idea of send/receive hooks, allowing tokens to interact with smart contracts in a more automated and standardized manner
* Prevent Token Loss in Smart Contracts - allow contracts to have hooks to receive tokens and handle them appropriately.
* Token burns as part of the standard

Cons:
* Potential reentrancy attacks
* Gas Costs
* As of v4.9, OpenZeppelin’s implementation of ERC-777 is deprecated and will be removed in the next major release.

# ERC1363
Pros:
* Enable direct payments and approval in a single transaction
* Reduces transaction costs and gas fees by avoiding the need for two separate transactions

Cons:
* Week mass adoption

# Summary
While ERC777 improved token handling in terms of flexibility and security with hooks and operators, it didn’t fully solve the problem of streamlining token approvals and transfers for user-friendly applications such as e-commerce. In ERC777, users still often needed to approve tokens before a contract could transfer them, which creates friction in user experience. ERC1363 directly solves this issue by combining approval and payment into one step.