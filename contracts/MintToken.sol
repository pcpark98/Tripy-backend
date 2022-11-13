// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "SaleToken.sol";

contract MintToken is ERC721Enumerable{
    constructor() ERC721("Tripy", "Tri"){}

    SaleToken public saleToken;

    mapping(uint256 => uint256) public destinationTypes;
    // 토큰 아이디를 입력하면 목적지 타입이 나옴.

    struct TokenData {
        uint256 tokenId;
        uint256 destinationType;
        uint256 price;
    }

    function mintToken() public {
        uint256 tokenId = totalSupply() + 1;
        uint256 destinationType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId))) % 5 + 1;

        destinationTypes[tokenId] = destinationType;

        _mint(msg.sender, tokenId);
    }

    function getTokens(address _tokenOwner) view public returns(TokenData[] memory) {
        uint256 balanceLength = balanceOf(_tokenOwner);

        require(balanceLength != 0, "Owner did not have token.");
        // 0이면 토큰을 안 갖고있는 것.

        TokenData[] memory tokenData = new TokenData[](balanceLength);

        for(uint256 i = 0; i < balanceLength; i++){
            uint256 tokenId = tokenOfOwnerByIndex(_tokenOwner, i);
            uint256 destinationType = destinationTypes[tokenId];
            uint256 price = saleToken.getTokenPrice(tokenId);

            tokenData[i] = TokenData(tokenId, destinationType, price);
        }
        return tokenData;
    }

    function setSaleToken(address _saleToken) public {
        saleToken = SaleToken(_saleToken);
    }
}