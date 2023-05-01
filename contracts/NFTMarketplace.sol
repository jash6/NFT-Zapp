// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;
    Counters.Counter public _itemsSold;
    
    uint256 listingPrice = 0.00089 ether;
    address payable owner;

    mapping(uint256 => MarketItem) public idToMarketItem;
   
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        bool isSwap;
    }

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold,
        bool isSwap
    );

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "only owner of the marketplace can change the listing price"
        );
        _;
    }

    modifier tokensTransferable(address _token, uint256 _tokenId) {
        // ensure this contract is approved to transfer the designated token
        // so that it is able to honor the claim request later
        require(
            ERC721(_token).getApproved(_tokenId) == address(this),
            "The HTLC must have been designated an approved spender for the tokenId"
        );
        _; 
    }
    constructor() ERC721("Metaverse Tokens", "METT") {
        owner = payable(msg.sender);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint256 _listingPrice)
        public
        payable
        onlyOwner
    {
        require(
            owner == msg.sender,
            "Only marketplace owner can update listing price."
        );
        listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false,
            false
        );
        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false,
            false
        );
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(
            idToMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    function swapTokentoMarketPlace(uint256 tokenId) public payable {
        require(
            idToMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();
        _transfer(msg.sender, address(this), tokenId);
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = idToMarketItem[tokenId].price;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        approve(address(this), tokenId);
        payable(owner).transfer(listingPrice);
        payable(idToMarketItem[tokenId].seller).transfer(msg.value);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this) && !idToMarketItem[i + 1].sold) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }




    event HTLCERC721New(
        uint256 indexed contractId,
        address indexed sender,
        address indexed receiver,
        uint256 tokenId,
        uint256 requestedid
    );
    event HTLCERC721Withdraw(uint256 indexed contractId);
    event HTLCERC721Refund(uint256 indexed contractId);

    struct LockContract {
        address sender;
        address receiver;
        uint256 tokenId;
        uint256 requestedid;
        bool withdrawn;
        bool refunded;
    }

    modifier contractExists(uint256 _contractId) {
        require(haveContract(_contractId), "contractId does not exist");
        _;
    }
    
    uint256 contractId = 0;
    uint256 verificatonfees;
    uint256 ExchangeFees = 0.00069 ether;
    mapping (uint256 => LockContract) public contracts;
    
    function newContract(
        address _receiver,
        uint256 _tokenId,
        uint256 _requestedid
    )
        external
        payable
        returns (uint256 _contractId)
    {
       _contractId = contractId;
        _transfer(msg.sender, address(this), _tokenId);
        contracts[contractId] = LockContract(
            msg.sender,
            _receiver,
            _tokenId,
            _requestedid,
            false,
            false
        );
        contractId++;
        emit HTLCERC721New(
            _contractId,
            msg.sender,
            _receiver,
            _tokenId,
            _requestedid
        );
    }

    function withdraw(uint256 _tokenId, uint256 _requestedid)
        external
        payable
        returns (bool)
    {
        uint256 _contractId;
        for (uint256 i=0; i<=contractId; i++){
            if(contracts[i].tokenId == _tokenId && contracts[i].requestedid == _requestedid)
            {
                _contractId = i;
                LockContract storage c = contracts[_contractId];
                idToMarketItem[_tokenId].owner = payable(msg.sender);
                idToMarketItem[_requestedid].owner = payable(c.sender);
                idToMarketItem[_requestedid].seller = payable(address(0));
                idToMarketItem[_requestedid].sold = true;
                _transfer(address(this), c.sender, _requestedid);
                _transfer(address(this), msg.sender, _tokenId);
                c.withdrawn = true;
                emit HTLCERC721Withdraw(contractId);
            }
            else if(contracts[i].requestedid == _requestedid && contracts[i].withdrawn == false && contracts[i].refunded == false)
            {
                refund(i);
            }
        }
        return true;
    }

    function refund(uint256 _contractId)
        public
        contractExists(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.refunded = true;
        _transfer(address(this), c.sender, c.tokenId);
        emit HTLCERC721Refund(_contractId);
        return true;
    }

    function refund2(uint256 _tokenId, uint256 _requestedid) public returns (bool) {
        uint256 _contractId;
        for (uint256 i=0; i<=contractId; i++){
            if(contracts[i].tokenId == _tokenId && contracts[i].requestedid == _requestedid && contracts[i].withdrawn == false && contracts[i].refunded == false)
            {
                _contractId = i;
                break;
            }
        }
        LockContract storage c = contracts[_contractId];
        _transfer(address(this), c.sender, _tokenId);
        c.refunded = true;
        emit HTLCERC721Refund(_contractId);
        return true;
    }
    
    function SetverificationFees(uint256 _Amount)public{
        verificatonfees = _Amount;
    }
    
    function SubmitContract(address _collectibleAddress)public payable{
        require(msg.value >= verificatonfees);
        if (msg.sender !=Owner(_collectibleAddress)){
            revert("you are not the Owner of this coolectible");
        }
    }

    function haveContract(uint256 _contractId)
        internal
        view
        returns (bool exists)
    {
        exists = (contracts[_contractId].sender != address(0));
    }
    
    
    function MyTradesSender() public view returns(LockContract[]memory){
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i <contractId; i++) {
            if (contracts[i].sender == msg.sender) {
                itemCount += 1;
            }
        }
        LockContract[] memory items = new LockContract[](itemCount);
        for (uint256 i = 0; i < contractId; i++) {
            if (contracts[i].sender == msg.sender && contracts[i].refunded == false && contracts[i].withdrawn == false) {
                uint256 currentId = i;
                LockContract storage currentItem = contracts[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function MyTradesReceiver() public view returns(LockContract[]memory){
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i <contractId; i++) {
            if (contracts[i].receiver == msg.sender) {
                itemCount += 1;
            }
        }
        LockContract[] memory items = new LockContract[](itemCount);
        for (uint256 i = 0; i < contractId; i++) {
            if (contracts[i].receiver == msg.sender && contracts[i].refunded == false && contracts[i].withdrawn == false) {
                uint256 currentId = i;
                LockContract storage currentItem = contracts[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
     
    function Owner(address _CollectibleAddress)internal view returns(address){
        return Ownable(_CollectibleAddress).owner();
    }
}
