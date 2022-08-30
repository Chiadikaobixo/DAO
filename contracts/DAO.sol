// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ICxoNFT.sol";
import "../interfaces/IFakeNFTMarketplace.sol";

contract DAO is Ownable {
    IFakeNFTMarketplace nftMarketplace;
    ICxoNFT cxoNft;

    struct Proposal {
        // describes the purpose of the proposal
        string description;
        // nftTokenId - the tokenID of the NFT to purchase from FakeNFTMarketplace if the proposal passes
        uint256 nftTokenId;
        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
        uint256 deadline;
        // yesVotes - number of yes votes for this proposal
        uint256 yesVotes;
        // noVotes - number of no votes for this proposal
        uint256 noVotes;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping of CxoNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
        mapping(uint256 => bool) voters;
    }

    // Mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals;

    /**
     * @dev cxoNftHoldersOnly is a modifier that allows a function to be called only by those
     * who owns at least 1 CxoNft
     */
    modifier cxoNftHoldersOnly() {
        require(cxoNft.balanceOf(msg.sender) > 0, "NOT A DAO MEMBER");
        _;
    }

    /**
     * @dev Creates a payable constructor which initializes the contract instances
     * for FakeNFTMarketplace and CxoNFT and allows this constructor
     * to accept an ETH deposit when it is being deployed
     */
    constructor(address _nftMarketplace, address _cxoNFT) payable {
        nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
        cxoNft = ICxoNFT(_cxoNFT);
    }

    /**  
     * @dev createProposal allows a CxoNFT holder to create a new proposal in the DAO
     * @param _nftTokenId - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
     * @return Returns the proposal index for the newly created proposal
     */
    function createProposal(uint256 _nftTokenId) external cxoNftHoldersOnly returns (uint256){
        require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        // Set the proposal's voting deadline to be (current time + 5 minutes)
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }
}
