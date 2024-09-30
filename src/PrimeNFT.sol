// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts@v4.9.6/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@v4.9.6/access/Ownable.sol";

contract PrimeNFT is ERC721Enumerable, Ownable {

    uint public constant MAX_SUPPLY = 100;

    constructor() ERC721("PrimeNFT", "PNFT") {
        mintInitialCollection();
    }

    function mintInitialCollection() internal onlyOwner {
        for (uint i = 1; i <= MAX_SUPPLY; i++) {
            _safeMint(msg.sender, i);
        }
    }
}

contract PrimeChecker {

    PrimeNFT public primeNFTContract;
    mapping(uint => bool) private isPrimeCache;

    constructor(address _primeNFTAddress) {
        primeNFTContract = PrimeNFT(_primeNFTAddress);
    }

    function isPrime(uint number) private returns (bool) {
        if (isPrimeCache[number]) {
            return isPrimeCache[number] == true;
        }

        if (number <= 1) {
            isPrimeCache[number] = false;
            return false;
        }

        for (uint i = 2; i * i <= number; i++) {
            if (number % i == 0) {
                isPrimeCache[number] = false;
                return false;
            }
        }

        isPrimeCache[number] = true;
        return true;
    }

    function countPrimeTokens(address owner) external returns (uint) {
        uint count = 0;
        uint balance = primeNFTContract.balanceOf(owner);

        for (uint i = 0; i < balance; i++) {
            uint tokenId = primeNFTContract.tokenOfOwnerByIndex(owner, i);
            if (isPrime(tokenId)) {
                count++;
            }
        }

        return count;
    }
}

