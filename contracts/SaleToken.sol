// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintToken.sol";

contract SaleToken{
    MintToken public mintTokenAddress;

    constructor(address _mintTokenAddress){
        mintTokenAddress = MintToken(_mintTokenAddress);
    }

    mapping(uint256 => uint256) public tokenPrices;
    // 가격들을 관리하는 매핑. 토큰 아이디를 입력하면 가격을 출력.

    uint256[] public onSaleTokenArray;
    // 프론트에서 어떤게 판매중인 토큰인지 확인할 수 있게 하기 위함.

    function setForSaleToken(uint256 _tokenId, uint256 _price) public {
        // (무엇을, 얼마에) 팔건지
        address tokenOwner = mintTokenAddress.ownerOf(_tokenId);

        require(tokenOwner == msg.sender, "Caller is not token owner");
        // 함수를 실행하는 사람이 토큰의 주인인가?

        require(_price>0, "Price is zero or lower.");
        // 값이 0원보다 큰지.

        require(tokenPrices[_tokenId] == 0, "This token is already on sale.");
        // 값이 0원이 아니면 이미 판매 등록된 것.

        require(mintTokenAddress.isApprovedForAll(tokenOwner, address(this)), "token owner did not approve token.");
        // 토큰의 주인이 판매 계약서(스마트 컨트랙트)에 판매 권한을 넘겼는지를 확인하는 함수. true false로 나옴.

        tokenPrices[_tokenId] = _price;
        // 토큰 아이디에 해당하는 값을 넣어줌.

        onSaleTokenArray.push(_tokenId);
    }

    function purchaseToken(uint256 _tokenId) public payable{
        uint256 price = tokenPrices[_tokenId];
        address tokenOwner = mintTokenAddress.ownerOf(_tokenId);

        require(price > 0, "Token not sale.");
        // 가격이 0보다 커야함. 0이면 판매 등록이 되어있지 않은 것.

        require(price <= msg.value, "Caller sent lower than price.");
        // 지불되는 매틱의 양이 적음.

        require(tokenOwner != msg.sender, "Caller is token owner.");
        // 토큰의 주인이 구매하려고 하는 경우.

        payable(tokenOwner).transfer(msg.value);
        // 토큰 주인에게 돈이 감.
        
        mintTokenAddress.safeTransferFrom(tokenOwner, msg.sender, _tokenId);
        // (보내는 사람, 받는 사람, 무엇을)

        // 배열과 매핑에서 제거.
        tokenPrices[_tokenId] = 0;
        for(uint256 i = 0; i < onSaleTokenArray.length; i++){
            if(tokenPrices[onSaleTokenArray[i]]==0){
                onSaleTokenArray[i] = onSaleTokenArray[onSaleTokenArray.length-1];
                onSaleTokenArray.pop();
            }
        }
    }

    function getOnSaleTokenArrayLength() view public returns(uint256) {
        return onSaleTokenArray.length;
    }

    function getTokenPrice(uint256 _tokenId) view public returns(uint256) {
        return tokenPrices[_tokenId];
    }
}