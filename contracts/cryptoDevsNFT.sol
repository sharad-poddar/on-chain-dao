//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

///@notice standard NFT contract ERC721
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CryptoDevsNFT is ERC721Enumerable{

    ///@dev sending name and symbol to NFT contract
    constructor() ERC721('CryptoDevs','CD'){}

    ///@notice _safeMint function in ERC721 to mint NFT
    ///@dev  totalSupply() Returns the total amount of tokens stored by the contract.
    function mint() public{
        _safeMint(msg.sender, totalSupply());
    }

}