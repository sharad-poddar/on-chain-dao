//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./cryptoDevsNFT.sol";

contract MarketPlace is CryptoDevsNFT{

    ///@dev maintains an owner of nft
    mapping(uint256 => address) public tokens;

    ///@dev purchasing price of an nft
    uint256 nftPrice = 0.1 ether;

    ///@dev purchasing and marking the owner of tokenId
    function purchase(uint256 _tokenId) public payable{
        require(msg.value == nftPrice, "This NFT costs 0.1 ether");
        tokens[_tokenId] = msg.sender;
    }

    ///@dev getting price of nft
    function getPrice() external view returns(uint256){
        return nftPrice;
    }

    ///@dev check if the tokenId is available for sold or not
    // address(0) = 0x0000000000000000000000000000000000000000
    // This is the default value for addresses in Solidity
    function available(uint256 _tokenId) external view returns(bool){
        if(tokens[_tokenId] == address(0)){
            return true;
        }
        return false;
    }

}
