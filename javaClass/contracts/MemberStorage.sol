pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

import "./QuireStorage.sol";

/** @title Member Helper Contract
  * @notice This contract acts as a helper contract to interact with the Quire Storage contract
  * on behalf of other smart contracts. 
  * A contract can store and retreive its member variables of basic data types (excluding list, mapping, structs) by using the name of the variable
  */
contract MemberStorage {

    QuireStorage quireStorage;

    constructor(address _quireStorage) {
        quireStorage = QuireStorage(_quireStorage);
    }

    modifier onlyNetworkContracts {
      require(quireStorage.isContractAuthorized(msg.sender), "Storage Access Not Authorized");
      _;
    }

    // ----------------------------- uint ----------------------------- //
    function getUint(string memory _KEY, string memory _member) public view
    returns(uint) {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _member)));
    }
    function incUint(string memory _KEY, string memory _member) public {
        uint value = quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _member)));
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _member)), value+1);
    }
    function setUint(string memory _KEY, string memory _member, uint _value) public {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _member)), _value);
    }

    // ----------------------------- uint16 ----------------------------- //
    function getUint16(string memory _KEY, string memory _member) public view
    returns(uint16) {
        return quireStorage.getUint16(keccak256(abi.encodePacked(_KEY, _member)));
    }
    function incUint16(string memory _KEY, string memory _member) public 
    onlyNetworkContracts {
        uint16 value = quireStorage.getUint16(keccak256(abi.encodePacked(_KEY, _member)));
        quireStorage.setUint16(keccak256(abi.encodePacked(_KEY, _member)), value+1);
    }
    function setUint16(string memory _KEY, string memory _member, uint16 _value) public 
    onlyNetworkContracts {
        quireStorage.setUint16(keccak256(abi.encodePacked(_KEY, _member)), _value);
    }
    
    // ----------------------------- string ----------------------------- //
    function getString(string memory _KEY, string memory _member) public view
    returns(string memory) {
        return quireStorage.getString(keccak256(abi.encodePacked(_KEY, _member)));
    }
    function setString(string memory _KEY, string memory _member, string memory _value) public 
    onlyNetworkContracts {
        quireStorage.setString(keccak256(abi.encodePacked(_KEY, _member)), _value);
    }

}