pragma solidity ^0.8.0;

import "./QuireStorage.sol";
import "./QuireContracts.sol";

/** @title Quire Upgradable Contract
  * @notice This contract holds the address of current quire proxy
    contract. The contract is owned by a guardian account. Only the
    guardian account can change the proxy contract address as
    business needs.
  */
contract QuireUpgradable {

    address private guardian;
    address private quireStorage;
    address private quireContracts;
    // initDone ensures that init can be called only once
    bool private initDone;

    /** @notice constructor
      */
    constructor () {
        guardian = msg.sender;
        initDone = false;
    }

    /** @notice confirms that the caller is the guardian account
    */
    modifier onlyGuardian {
        require(msg.sender == guardian, "invalid caller");
        _;
    }

    /** @notice Registers a contract in storage and proxy contract
      * @param _contractAddress Address of contract whose access needs to be updated
      * @param _contractName Name of the contract in Capital Snake Case
      */
    function registerContract (string calldata _contractName, address _contractAddress) external 
    onlyGuardian {
      QuireStorage(quireStorage).registerAddress(_contractAddress);
      QuireContracts(quireContracts).registerContract(_contractName, _contractAddress);
    }

    /** @notice UnRegisters a contract in storage and proxy contract
      * @param _contractAddress Address of contract whose access needs to be updated
      * @param _contractName Name of the contract in Capital Snake Case
      */
    function unRegisterContract (string calldata _contractName, address _contractAddress) external 
    onlyGuardian {
      QuireContracts(quireContracts).unregisterContract(_contractName);
      QuireStorage(quireStorage).unregisterAddress(_contractAddress);
    }

    /** @notice Registers an account for storage access
      * @param _account Address of account whose access needs to be updated
      */
    function registerAccount (address _account) external 
    onlyGuardian {
      QuireStorage(quireStorage).registerAddress(_account);
    }

    /** @notice UnRegisters an account for storage access
      * @param _account Address of account whose access needs to be updated
      */
    function unRegisterAccount (address _account) external 
    onlyGuardian {
      QuireStorage(quireStorage).unregisterAddress(_account);
    }

    /** @notice Registers another storage contract in case of unfortunate upgrade
      * This new contract will be able to fetch all the keys from the current storage
      * @param _proposedStorage Address of the new storage account
      */
    function registerSecondaryStorage(address _proposedStorage) external 
    onlyGuardian {
      QuireStorage(quireStorage).registerSecondaryStorage(_proposedStorage);
    }

    /** @notice executed by guardian. Starts the proxy and Quire contracts.
      * Can be executed by guardian account only.
      * @param _quireContracts proxy contract address
      * @param _quireStorage quire storage contract address
      */
    function init(address _quireContracts, address _quireStorage) external
    onlyGuardian {
        require(!initDone, "can be executed only once");
        quireContracts = _quireContracts;
        quireStorage = _quireStorage;
        initDone = true;
    }

    /** @notice changes the proxy contract address to the new address.
        Can be executed by guardian account only
      * @param _proposedProxy address of the new contract registry contract
      */
    function changeProxyContract(address _proposedProxy) public 
    onlyGuardian {
      quireContracts = _proposedProxy;
    }

    /** @notice changes the upgradable contract address in storage contract.
        Can be executed by guardian account only
      * @param _proposedUpgradable address for the existing storage contract
      * @dev this function should be prevented from being executed accidentally, 
      * as this could stop future updates
      */
    function changeUpgradable(address _proposedUpgradable) public 
    onlyGuardian {
      QuireStorage(quireStorage).changeQuireUpgradable(_proposedUpgradable);
    }

    /** @notice function to fetch the guardian account address
      * @return _guardian guardian account address
      */
    function getGuardian() public view returns (address) {
        return guardian;
    }
    
    /** @notice function to fetch the eternal storage address
      * @return eternal storage contract address
      */
    function getQuireStorage() public view returns (address) {
      return quireStorage;
    }

    /** @notice function to fetch the contract registry address
      * @return contract registry contract address
      */
    function getProxyContract() public view returns (address) {
      return quireContracts;
    }

}
