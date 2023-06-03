pragma solidity ^0.8.0;
import "./QuireStorage.sol";


/** @title Contract Registry Contract
  * @notice This contract manages contract name to contract address mapping of contracts deployed on the network. 
  * These are the contracts with READ and WRITE access to the Quire Storage contract. 
  */
contract QuireContracts {

    address private quireUpgradeable;
    QuireStorage private quireStorage;

    event ContractRegistered(string contractName_, address contractAddress_);
    event ContractUnRegistered(string contractName_);

    constructor (address _quireUpgradeable, address _quireStorage) {
        quireUpgradeable = _quireUpgradeable;
        quireStorage = QuireStorage(_quireStorage);
    }

    /** @dev The value of KEY should never be updated after first deployment
      */
    string constant KEY = "QUIRE_CONTRACTS";

    /** @notice Modifier to allow function call only PermissionsUpgradable.sol.
      */
    modifier onlyUpgradeable {
        require(msg.sender == quireUpgradeable, "invalid caller");
        _;
    }

    /** @notice Only unregistered contract addresses
      */
    modifier unregisteredContract (string memory _contractName) {
        require(quireStorage.getAddress(keccak256(abi.encodePacked(KEY, _contractName)))==address(0), "Contract already registered");
        _;
    }

    /** @notice Only registered contract addresses
      */
    modifier registeredContract (string memory _contractName) {
        require(quireStorage.getAddress(keccak256(abi.encodePacked(KEY, _contractName)))!=address(0), "Contract not registered");
        _;
    }

    /** @notice Registers a contract by contract name
      * @param _contractName Name of account contract to be registered
      * @param _contractAddress Address of account contract to be registered
      */
    function registerContract (string memory _contractName, address _contractAddress) external 
    onlyUpgradeable
    unregisteredContract(_contractName) {
        quireStorage.setAddress(keccak256(abi.encodePacked(KEY, _contractName)), _contractAddress);
        emit ContractRegistered(_contractName, _contractAddress);
    }

    /** @notice Unregisters a contract by contract name
      * @param _contractName Name of account contract to be unregistered
      */
    function unregisterContract (string memory _contractName) external 
    onlyUpgradeable
    registeredContract(_contractName) {
        quireStorage.deleteAddress(keccak256(abi.encodePacked(KEY, _contractName)));
        emit ContractUnRegistered(_contractName);
    }

    /** @notice Gets address of a registered contract by its name
      * @param _contractName Name of account contract
      */
    function getRegisteredContract (string memory _contractName) public view 
    returns(address) {
        return quireStorage.getAddress(keccak256(abi.encodePacked(KEY, _contractName)));
    }

}