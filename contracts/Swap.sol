// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./NFTMarketplace.sol";

contract Swap is NFTMarketplace{
    address payable party1;
    address payable party2;


    function createSwap(uint256 tokenId1,uint256 tokenId2) public payable {
        idToMarketItem[tokenId1].owner = party2;
        idToMarketItem[tokenId2].owner = party1;
    }


}