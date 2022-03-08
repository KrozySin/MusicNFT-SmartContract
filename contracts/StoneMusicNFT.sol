// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StoneMusicNFT is ERC721 {
    mapping(uint256 => string) private _tokenURIs;
    
    constructor() ERC721("StoneMusicNFT", "SMUSNFT") {
    }
    
    /**
     * @notice Get Token URI
     * @param tokenId NFT TokenID for getting tokenURI
     * @return string return metadata of NFT token by tokenId
     */
    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }
    
    /**
     * @notice Mint one token
     * @param tokenId Token Id for new token
     * @param metadata Json Metadata string for new token
     */
    function mint(
        uint256 tokenId, 
        string memory metadata
    ) public  {
        _safeMint(msg.sender, tokenId);
        
        _tokenURIs[tokenId] = metadata;
    }
    
    /**
     * @notice Burn token
     * @param tokenId Token Id to burn
     */
    function burn(
        uint256 tokenId
    ) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner.");
        
        _burn(tokenId);
    }
}