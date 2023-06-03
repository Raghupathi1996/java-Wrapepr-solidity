pragma solidity ^0.8.0;

import "./QuireStorage.sol";

/** @title Map Helper Contract
  * @notice This contract acts as a helper contract to interact with the Quire Storage contract
  * on behalf of other smart contracts. 
  * A contract can store and retreive a mapping involving different data types by using the map name and key
  */
contract MapStorage {

    QuireStorage quireStorage;

   constructor(address _quireStorage) {
        quireStorage = QuireStorage(_quireStorage);
    }
    
    modifier onlyNetworkContracts {
      require(quireStorage.isContractAuthorized(msg.sender), "Storage Access Not Authorized");
      _;
    }

    // ----------------------------- READS ----------------------------- //

    function getAddressToUint(string memory _KEY, string memory _map, address _mapKey) public view
    returns (uint) {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }
    function getStringToUint(string memory _KEY, string memory _map, string memory _mapKey) public view
    returns (uint)  {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }
    function getStringToBytes8(string memory _KEY, string memory _map, string memory _mapKey) public view
    returns (bytes8)  {
        return quireStorage.getBytes8(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }
    function getStringToString(string memory _KEY, string memory _map, string memory _mapKey) public view
    returns (string memory)  {
        return quireStorage.getString(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }
    function getBytes8ToUint(string memory _KEY, string memory _map, bytes8 _mapKey) public view
    returns (uint)  {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }
    function getBytes32ToUint(string memory _KEY, string memory _map, bytes32 _mapKey) public view
    returns (uint)  {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }
    function getBytes32ToAddress(string memory _KEY, string memory _map, bytes32 _mapKey) public view
    returns (address)  {
        return quireStorage.getAddress(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    }

    // function getBytes8ToBool(string memory _KEY, string memory _map, bytes8 _mapKey) public view
    // returns (bool) {
    //     return quireStorage.getBool(keccak256(abi.encodePacked(_KEY, _map, _mapKey)));
    // }
    

    /** @notice returns map item complex property
      * @dev if one of the properties of a map item is a complex data type (object, list or map), 
      * we pass a _propKey along with the _map, _mapKey.
      * @param _map Name of the map
      * @param _mapKey Key of the map
      * @param _propKey For object, it is abi.encodePacked(_objPropName, _innerPropKey);
      * For list, it is abi.encodePacked(_index, _innerPropKey)
      * For map, it is abi.encodePacked(_mapKey, _innerPropKey)
      * If another complex data type (obj, list, map) is stored inside, we pass its _innerPropKey which is the same as
      * the propKey for the inner complex data type. We do this until we find the required uint 
      */
    function getByKeyBytes8ToUint(string memory _KEY, string memory _map, bytes8 _mapKey, bytes memory _propKey) public view
    returns (uint)  {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey,_propKey)));
    }


    /** @notice returns map item complex property
      * @dev if one of the properties of a map item is a complex data type (object, list or map), 
      * we pass a _propKey along with the _map, _mapKey.
      * @param _map Name of the map
      * @param _mapKey Key of the map
      * @param _propKey For object, it is abi.encodePacked(_objPropName, _innerPropKey);
      * For list, it is abi.encodePacked(_index, _innerPropKey)
      * For map, it is abi.encodePacked(_mapKey, _innerPropKey)
      * If another complex data type (obj, list, map) is stored inside, we pass its _innerPropKey which is the same as
      * the propKey for the inner complex data type. We do this until we find the required uint 
      */
    function getByKeyStringToUint(string memory _KEY, string memory _map, string memory _mapKey, bytes memory _propKey) public view
    returns (uint)  {
        return quireStorage.getUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey,_propKey)));
    }

    // ----------------------------- WRITES ----------------------------- //

    function setAddressToUint(string memory _KEY, string memory _map, address _mapKey, uint _value) public 
    onlyNetworkContracts {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }
    function setStringToUint(string memory _KEY, string memory _map, string memory _mapKey, uint _value) public 
    onlyNetworkContracts {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }
    function setStringToBytes8(string memory _KEY, string memory _map, string memory _mapKey, bytes8 _value) public 
    onlyNetworkContracts {
        quireStorage.setBytes8(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }
    function setStringToString(string memory _KEY, string memory _map, string memory _mapKey, string memory _value) public 
    onlyNetworkContracts {
        quireStorage.setString(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }
    function setBytes8ToUint(string memory _KEY, string memory _map, bytes8 _mapKey, uint _value) public 
    onlyNetworkContracts {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }
    function setBytes32ToUint(string memory _KEY, string memory _map, bytes32 _mapKey, uint _value) public 
    onlyNetworkContracts {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }
    function setBytes32ToAddress(string memory _KEY, string memory _map, bytes32 _mapKey, address _value) public 
    onlyNetworkContracts {
        quireStorage.setAddress(keccak256(abi.encodePacked(_KEY, _map, _mapKey)), _value);
    }

    /** @notice sets map item complex property
      * @dev if one of the properties of a map item is a complex data type like list or map, 
      * we pass a _propKey along with the _map, _mapKey.
      * @param _map Name of the map
      * @param _mapKey Key of the map
      * @param _propKey For object, it is abi.encodePacked(_innerObjPropName, _innerPropKey);
      * For list, it is abi.encodePacked(_index, _innerPropKey)
      * For map, it is abi.encodePacked(_mapKey, _innerPropKey)
      * If another complex data type (obj, list, map) is stored inside, we pass its _innerPropKey which is the same as
      * the propKey for the inner complex data type. We do this until we locate the final uint 
      * @param _value value to be stored
      */
    function setByKeyBytes8ToUint(string memory _KEY, string memory _map, bytes8 _mapKey, bytes memory _propKey, uint _value) public 
    onlyNetworkContracts {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey, _propKey)), _value);
    }

    /** @notice sets map item complex property
      * @dev if one of the properties of a map item is a complex data type like list or map, 
      * we pass a _propKey along with the _map, _mapKey.
      * @param _map Name of the map
      * @param _mapKey Key of the map
      * @param _propKey For object, it is abi.encodePacked(_innerObjPropName, _innerPropKey);
      * For list, it is abi.encodePacked(_index, _innerPropKey)
      * For map, it is abi.encodePacked(_mapKey, _innerPropKey)
      * If another complex data type (obj, list, map) is stored inside, we pass its _innerPropKey which is the same as
      * the propKey for the inner complex data type. We do this until we locate the final uint 
      * @param _value value to be stored
      */
    function setByKeyStringToUint(string memory _KEY, string memory _map, string memory _mapKey, bytes memory _propKey, uint _value) public 
    onlyNetworkContracts {
        quireStorage.setUint(keccak256(abi.encodePacked(_KEY, _map, _mapKey, _propKey)), _value);
    }

}