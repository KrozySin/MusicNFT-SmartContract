// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ExchangeV1 is Ownable {
    using SafeMath for uint;
    
    mapping (address => mapping (address => mapping (uint256 => uint256))) public sellRequests;     // owner => tokenAddress => tokenId => arcadePrice
    
    address public wethAddress = address(0x0);
    
    /**
     * @dev Exchange ERC721 token and WETH token(ERC20)
     * Transfer ERC721 token from `owner` to `buyer`.
     * Transfer WETH token from `buyer` to `owner`.
     */
    function exchange(
        address sellToken, uint256 sellTokenId,
        address owner,
        uint256 buyValue, 
        address buyer
    ) external {
        validateBuyRequest(owner, sellToken, sellTokenId, buyValue);
        
        IERC20(wethAddress).transferFrom(buyer, owner, buyValue);
        IERC721(sellToken).safeTransferFrom(owner, buyer, sellTokenId);
        
        delete sellRequests[owner][sellToken][sellTokenId];
    }
    
    /**
     * @dev List ERC721 token on market(This service).
     * List ERC721 token with wEthPrice
     */
    function sellRequest(
        address token, 
        uint256 tokenId, 
        uint256 wethPrice
    ) external {
        require(IERC721(token).getApproved(tokenId) == address(this), "Not approved yet.");
        require(IERC721(token).ownerOf(tokenId) == msg.sender, "Only owner can request.");
        
        sellRequests[_msgSender()][token][tokenId] = wethPrice;
    }
    
    /**
     * @dev Remove ERC721 token from market(This service).
     */
    function cancelSellRequest(
        address token, 
        uint256 tokenId
    ) external {
        require(IERC721(token).getApproved(tokenId) == address(this), "Not approved yet.");
        require(IERC721(token).ownerOf(tokenId) == msg.sender, "Only owner can request.");
        
        delete sellRequests[_msgSender()][token][tokenId];
    }
    
    /**
     * @dev Check the validation of buy request.
     * check if the wEthPrice is correct.
     */
    function validateBuyRequest(
        address owner, 
        address token, 
        uint256 tokenId, 
        uint256 wEthPrice
    ) private view {
        require(
            sellRequests[owner][token][tokenId] == wEthPrice, 
            "Amount is incorrect."
        );
    }
    
    /**
     * @dev Set WEth Address
     */
    function setwethAddress(address _address) public onlyOwner {
        wethAddress = _address;
    }
}