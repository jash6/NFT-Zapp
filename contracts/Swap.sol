// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./NFTMarketplace.sol";

contract Swap is NFTMarketplace{
    address payable party1;
    address payable party2;

    struct LockContract {
        uint256 contractId;
        address Sender;
        address receiver;
        address tokenContract;
        address requestedcontract;
    }

    event HTLCERC721New(
        uint256 indexed contractId,
        address indexed sender,
        address indexed receiver,
        address tokenContract,
        uint256 tokenId,
        string hashlock,
        address requestedcontract,
        uint256 requestedid
    );
    struct SwapNFT {
        uint256 sendertokenId;
        uint256 tokenId;
        address payable party1;
        address payable party2;
        bool swapped;
    }
    
    event SwapNFTCreated(
        uint256 indexed tokenId,
        address payable sender,
        address payable receiver,
        bool swapped
    );

    function createSwap(uint256 tokenId1,uint256 tokenId2) public payable {
        idToMarketItem[tokenId1].owner = party2;
        idToMarketItem[tokenId2].owner = party1;
    }


}