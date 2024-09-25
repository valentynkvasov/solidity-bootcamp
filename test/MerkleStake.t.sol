// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts@v4.9.6/utils/cryptography/MerkleProof.sol";

import {NFTToken} from "../src/MerkleStake.sol";
import {NFTStaking} from "../src/MerkleStake.sol";

contract MerkleTreeTest is Test {

    bytes32 public root;
    bytes32[] public leaves;

    NFTToken public nftToken;
    NFTStaking public nftStaking;

    function setUp() public {
        address addr1 = vm.addr(1);
        address addr2 = vm.addr(2);
        address addr3 = vm.addr(3);
        address addr4 = vm.addr(4);

        leaves = new bytes32[](4);
        leaves[0] = keccak256(abi.encodePacked(addr1));
        leaves[1] = keccak256(abi.encodePacked(addr2));
        leaves[2] = keccak256(abi.encodePacked(addr3));
        leaves[3] = keccak256(abi.encodePacked(addr4));

        root = buildMerkleTree(leaves);

        nftToken = new NFTToken(root);
        nftStaking = new NFTStaking(address(nftToken));
    }

    function testMerkleTree() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = leaves[1];
        proof[1] = hashPair(leaves[2], leaves[3]);

        bool isValid = MerkleProof.verify(proof, root, leaves[0]);
        assertTrue(isValid, "Merkle proof verification failed for leaves[0]!");

        proof[0] = leaves[0];
        proof[1] = hashPair(leaves[2], leaves[3]);
        isValid = MerkleProof.verify(proof, root, leaves[1]);
        assertTrue(isValid, "Merkle proof verification failed for leaves[1]!");

        proof[0] = leaves[3];
        proof[1] = hashPair(leaves[0], leaves[1]);
        isValid = MerkleProof.verify(proof, root, leaves[2]);
        assertTrue(isValid, "Merkle proof verification failed for leaves[2]!");

        proof[0] = leaves[2];
        proof[1] = hashPair(leaves[0], leaves[1]);
        console.logBytes32(proof[0]);
        console.logBytes32(proof[1]);
        isValid = MerkleProof.verify(proof, root, leaves[3]);
        assertTrue(isValid, "Merkle proof verification failed for leaves[3]!");
    }

    function stakeNFT() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = leaves[0];
        proof[1] = hashPair(leaves[2], leaves[3]);

        vm.prank(vm.addr(1));
        nftToken.mintNFT(proof);

        assertEq(nftToken.ownerOf(1), vm.addr(1), "Owner is wrong");
        nftToken.safeTransferFrom(vm.addr(1), address(nftStaking), 1);

        assertEq(nftStaking.getStaker(1), vm.addr(1), "Stake is wrong");

        vm.expectRevert();
        vm.prank(vm.addr(1));
        nftStaking.claimRewards(1);
    }

    function buildMerkleTree(bytes32[] memory _leaves) internal pure returns (bytes32) {
        require(_leaves.length > 0, "No leaves to build the tree");

        while (_leaves.length > 1) {
            uint256 n = (_leaves.length + 1) / 2;
            bytes32[] memory newLevel = new bytes32[](n);

            for (uint256 i = 0; i < n; i++) {
                bytes32 left = _leaves[2 * i];
                bytes32 right = (2 * i + 1 < _leaves.length) ? _leaves[2 * i + 1] : left;
                newLevel[i] = hashPair(left, right);
            }

            _leaves = newLevel;
        }

        return _leaves[0];
    }

    function hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

}