// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC721{
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

contract NftSwap{
    IERC721 public  nft;
    uint256 public  nftId1;
    uint256 public  nftId2;
    address payable public  seller;
    address payable public owner;
  
  constructor(
    address _nft,
    uint256 _nftId1,
    uint256 _nftId2
  ) {
     seller = payable(msg.sender);
     nft = IERC721(_nft);
     nftId1 = _nftId1;
     nftId2 = _nftId2;
  }

function buy() external payable{
    nft.transferFrom(seller, msg.sender, nftId1);
    nft.transferFrom(msg.sender, seller, nftId2);
}
}