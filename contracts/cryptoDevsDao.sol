//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IMarketPlace {
    /// @dev getPrice() returns the price of an NFT from the FakeNFTMarketplace
    /// @return Returns the price in Wei for an NFT
    function getPrice() external view returns (uint256);

    /// @dev available() returns whether or not the given _tokenId has already been purchased
    /// @return Returns a boolean value - true if available, false if not
    function available(uint256 _tokenId) external view returns (bool);

    /// @dev purchase() purchases an NFT from the FakeNFTMarketplace
    /// @param _tokenId - the fake NFT tokenID to purchase
    function purchase(uint256 _tokenId) external payable;
}

interface ICryptoDevsNFT {
    /// @dev balanceOf returns the number of NFTs owned by the given address
    /// @param owner - address to fetch number of NFTs for
    /// @return Returns the number of NFTs owned
    function balanceOf(address owner) external view returns (uint256);

    /// @dev tokenOfOwnerByIndex returns a tokenID at given index for owner
    /// @param owner - address to fetch the NFT TokenID for
    /// @param index - index of NFT in owned tokens array to fetch
    /// @return Returns the TokenID of the NFT
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}



contract CryptoDevsDao is Ownable{

    struct Proposal{
        // nft to be buy
        uint256 nftTokenId;
        // deadline
        uint256 deadline;
        // no of yes votes
        uint256 yseVotes;
        // no of no votes
        uint256 noVotes;
        // isExecuted
        bool executed;
        // voters, nft is used or not
        mapping(uint256 => bool) voters;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    IMarketPlace marketPlace;
    ICryptoDevsNFT cryptoDevs;

    enum Vote{
        YAY,
        NAY
    }
    
    constructor(address _marketPlaceAddress, address _cryptoDevsAddress) Ownable(msg.sender) payable{
        marketPlace = IMarketPlace(_marketPlaceAddress);
        cryptoDevs = ICryptoDevsNFT(_cryptoDevsAddress);
    }

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 CryptoDevsNFT
    modifier nftHolderOnly(){
        require(cryptoDevs.balanceOf(msg.sender) > 0, 'you dont have any community NFTs');
        _;
    }

    function createProposal(uint256 _subjectNFTTokenId) external nftHolderOnly returns(uint256){ 
        require(marketPlace.available(_subjectNFTTokenId), 'NFT already sold');
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _subjectNFTTokenId;
        proposal.deadline = block.timestamp + 5 minutes;
        numProposals++;
        return numProposals -1;
    }

    // Create a modifier which only allows a function to be
    // called if the given proposal's deadline has not been exceeded yet
    modifier activePropsal(uint256 _propsalIndex){
        require(proposals[_propsalIndex].deadline > block.timestamp, "DEADLINE_EXCEEDED");
        _;
    }

    function voteOnProposal(uint256 _proposalIndex) external nftHolderOnly() activePropsal(_proposalIndex){

        Proposal storage proposal = proposals[proposalIndex];
        uint256 voterNFTBalance = cryptoDevs.balanceOf(msg.sender);
        uint256 numVotes;

        // checking if the voter is already voted or not
        for(uint256 i=0; i<voterNFTBalance; i++){
            uint256 tokenId = cryptoDevs.tokenOfOwnerByIndex(msg.sender, i);
            if(proposal.voters[tokenId] == false){
                numVotes++;
                proposal.voters[tokenId] == true;
            }
        }

        // selection of votes
        require(numVotes > 0, 'you have already voted');
        if(vote == vote.YAY){
            proposal.yseVotes+=numVotes;
        }else{
            proposal.noVotes+=numVotes;
        }

    }


    // Create a modifier which only allows a function to be
    // called if the given proposals' deadline HAS been exceeded
    // and if the proposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex){
        require(proposals[proposalIndex].deadline <= block.timestamp, 'there is time in proposal deadline');
        require(proposals[proposalIndex].executed == false, 'already executed');
        _;
    }

    /// @dev executeProposal allows any CryptoDevsNFT holder to execute a proposal after it's deadline has been exceeded
    function executeProposal(uint256 _proposalIndex) external nftHolderOnly() inactiveProposalOnly(_proposalIndex){
        Proposal storage proposal = proposals[_proposalIndex];

        // If the proposal has more YAY votes than NAY votes
        // purchase the NFT from the FakeNFTMarketplace
        if(proposal.yseVotes > proposal.noVotes){
            uint256 nftPrice = marketPlace.getPrice();
            require(address(this).balance >= nftPrice, 'community dont have enough fund');
            marketPlace.purchase{value: nftPrice}(proposal.nftTokenId);
        }

        proposal.executed = true;
    }

    /// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
    function withdrawEther() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        (bool sent, ) = payable(owner()).call{value: amount}("");
        require(sent, "FAILED_TO_WITHDRAW_ETHER");
    }


    // The following two functions allow the contract to accept ETH deposits
    // directly from a wallet without calling a function
    receive() external payable {}
    fallback() external payable {}
}