## How does ERC721A save gas + Where does it add cost??
ERC721A intoduces several optimizations
* Removing duplicate storage from OpenZeppelin’s (OZ) ERC721Enumerable
* Updating the owner’s balance once per batch mint request, instead of per minted NFT
* Updating the owner data once per batch mint request, instead of per minted NFT