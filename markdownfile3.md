## Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace
It might be solved using indexers like The Graph, Envio, Goldsky.
We need to listen all mint operations building internal statistic of all minters, maintaining address - uint256 on web2 layer
