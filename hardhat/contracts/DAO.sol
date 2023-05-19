// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/MultiSignature.sol";

contract DAO {
    enum StageSection {
        NON_STAGE,
        PROJECT_CREATION_STAGE,
        PROJECT_FUNDING_STAGE,
        PROJECT_EXECUTION_STAGE
    }

    struct Stage {
        uint16 id;
        uint256 moneyPool;
        StageSection stage;
        uint64 projectCount;
    }

    struct MultiSignatureWallet {
        uint16 id;
        address contractAddress;
        address[] owners;
        bool approved;
        uint16 executedProjectCounts;
        uint16 rejectedProjectCounts;
    }

    struct Project {
        uint16 stageId;
        uint16 id;
        address ownerContractAddress;
        uint256 totalFunds;
        uint64 totalVotes;
    }

    uint16 public stageCount;
    uint16 public multiWalletCount;

    mapping(uint16 => mapping(uint16 => Project)) stagesToProject;
    mapping(address => MultiSignatureWallet) public multiWallets;
    mapping(uint16 => Stage) public stages;

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier approvedAccount(address contractAddress) {
        require(multiWallets[contractAddress].approved == true);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /*
     *  Contrat should be verified, so we can check it's appropriate or not.
     */
    function requestForMultiSignature(address multiSignatureContract) external {
        if (
            MultiSignature(multiSignatureContract).getDaoContractAddress() ==
            address(this)
        ) {
            MultiSignatureWallet storage _wallet = multiWallets[
                multiSignatureContract
            ];
            if (_wallet.id == 0) {
                multiWalletCount++;
                _wallet.id = multiWalletCount;
                _wallet.contractAddress = multiSignatureContract;
                _wallet.owners = MultiSignature(multiSignatureContract)
                    .getOwners();
            }
        }
    }

    function approveRequest(address multiSignatureContract) external onlyOwner {
        multiWallets[multiSignatureContract].approved = true;
    }

    // STAGE, APPROVED
    function createProject(address contractAddress) external {}

    function fund(address contractAddress) external payable {}

    function distributeFunds() external onlyOwner {}

    function withdraw(address contractAddress) external {}

    function getProject(
        uint16 stageId,
        uint16 projectId
    ) external view returns (Project memory) {
        return stagesToProject[stageId][projectId];
    }
}
