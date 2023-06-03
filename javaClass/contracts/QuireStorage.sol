pragma solidity ^0.8.0;

/** @title Quire Storage contract
  * @notice This contract holds all the data on behalf of other contracts.
  * There is a mapping to store data for each data type.
  * Not all contracts/accounts can fetch/push data to this contract.
  * Some contracts/accounts will be given access via the QuireUpgradable.sol contract
  * and only they can execute the READ and WRITE in this contract.
  * Look at the method updateContractDatabaseAccess() for more details.
  */
contract QuireStorage {

    address private quireUpgradable;

    event AddressRegistered(address account_);
    event AddressUnRegistered(address account_);

    mapping(bytes32 => bool) private isKeyExists;

    // uint
    bytes32[] private uInt8Keys;
    bytes32[] private uInt16Keys;
    bytes32[] private uInt32Keys;
    bytes32[] private uInt64Keys;
    bytes32[] private uInt128Keys;
    bytes32[] private uIntKeys; // uint256
    //int
    bytes32[] private int8Keys;
    bytes32[] private int16Keys;
    bytes32[] private int32Keys;
    bytes32[] private int64Keys;
    bytes32[] private int128Keys;
    bytes32[] private intKeys; // int256
    // bytes
    bytes32[] private bytes1Keys;
    bytes32[] private bytes2Keys;
    bytes32[] private bytes4Keys;
    bytes32[] private bytes8Keys;
    bytes32[] private bytes16Keys;
    bytes32[] private bytes20Keys;
    bytes32[] private bytes32Keys;
    bytes32[] private bytesKeys;
    // other
    bytes32[] private stringKeys;
    bytes32[] private addressKeys;
    bytes32[] private boolKeys;

    constructor (address _quireUpgradable) {
        quireUpgradable = _quireUpgradable;
    }

    // uint
    mapping(bytes32 => uint8) private uInt8Storage;
    mapping(bytes32 => uint16) private uInt16Storage;
    mapping(bytes32 => uint32) private uInt32Storage;
    mapping(bytes32 => uint64) private uInt64Storage;
    mapping(bytes32 => uint128) private uInt128Storage;
    mapping(bytes32 => uint256) private uIntStorage; // uint256
    //int
    mapping(bytes32 => int8) private int8Storage;
    mapping(bytes32 => int16) private int16Storage;
    mapping(bytes32 => int32) private int32Storage;
    mapping(bytes32 => int64) private int64Storage;
    mapping(bytes32 => int128) private int128Storage;
    mapping(bytes32 => int256) private intStorage; // int256
    // bytes
    mapping(bytes32 => bytes1) private bytes1Storage;
    mapping(bytes32 => bytes2) private bytes2Storage;
    mapping(bytes32 => bytes4) private bytes4Storage;
    mapping(bytes32 => bytes8) private bytes8Storage;
    mapping(bytes32 => bytes16) private bytes16Storage;
    mapping(bytes32 => bytes20) private bytes20Storage;
    mapping(bytes32 => bytes32) private bytes32Storage;
    mapping(bytes32 => bytes) private bytesStorage;
    // other
    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bool) private boolStorage;

    /** @dev The value of KEY should never be updated after first deployment
      */
    string constant KEY = "ALLOWED_CONTRACTS";

    /** @notice Modifier to revert transaction if a contract is not allowed access.
      * Look at the method updateContractDatabaseAccess() to understand how access is granted and revoked.
      */
    modifier onlyAllowedContract(address _sender) {
        require(boolStorage[keccak256(abi.encodePacked(KEY, _sender))]==true, "invalid caller");
        _;
    }

    /** @notice Modifier used for updateContractDatabaseAccess() method.
      * So that only QuireUpgradable.sol is allowed to grant and revoke access.
      */
    modifier onlyUpgradeable {
        require(msg.sender == quireUpgradable, "invalid caller");
        _;
    }

    /** @notice Modifier used for getting keys list.
      * The keys list will be used for backing up the data
      */
    modifier onlyRegisteredStorage {
        require(msg.sender == addressStorage[keccak256(abi.encodePacked(KEY))], "invalid caller");
        _;
    }

    /** @notice Gives access to the methods of this contract to an account
      * @param _account Address of account or contract whose access needs to be updated
      */
    function registerAddress(address _account) external 
    onlyUpgradeable {
        bytes32 storageKey = keccak256(abi.encodePacked(KEY, _account));
        if(!isKeyExists[storageKey]){
            boolKeys.push(storageKey);
            isKeyExists[storageKey] = true;
        }
        boolStorage[storageKey] = true;
        emit AddressRegistered(_account);
    }

    /** @notice Revokes access to the methods of this contract to an account
      * @param _account Address of account or contract whose access needs to be updated
      */
    function unregisterAddress(address _account) external 
    onlyUpgradeable {
        boolStorage[keccak256(abi.encodePacked(KEY, _account))] = false;
        emit AddressUnRegistered(_account);
    }

    /** @notice Registers another storage contract. 
      * This new contract will be able to fetch all the keys in this contract and replicate the storage of this contract.
      * @param _storage Address of the new storage contract
      */
    function registerSecondaryStorage(address _storage) external 
    onlyUpgradeable {
        addressStorage[keccak256(abi.encodePacked(KEY))] = _storage;
    }

    /** @notice changes the upgradable contract address to the new address.
        Can be executed by guardian account only
      * @param _proposedUpgradable address of the new storage contract
      * @dev this function should be prevented from being executed accidentally, 
      * as this could stop future updates
      */
    function changeQuireUpgradable(address _proposedUpgradable) public 
    onlyUpgradeable {
      quireUpgradable = _proposedUpgradable;
    }

    /** @notice Returns true if an account/contract is allowed access to this contract's methods
      * @param _accountAddress Address of account contract whose access needs to be checked
      */
    function isContractAuthorized(address _accountAddress) external view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked(KEY, _accountAddress))];
    }


    // ------------------------------------ READS ------------------------------------ //
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }
    function getString(bytes32 _key) external view returns (string memory) {
        return stringStorage[_key];
    }
    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }
    // uint
    function getUint8(bytes32 _key) external view returns (uint8) {
        return uInt8Storage[_key];
    }
    function getUint16(bytes32 _key) external view returns (uint16) {
        return uInt16Storage[_key];
    }
    function getUint32(bytes32 _key) external view returns (uint32) {
        return uInt32Storage[_key];
    }
    function getUint64(bytes32 _key) external view returns (uint64) {
        return uInt64Storage[_key];
    }
    function getUint128(bytes32 _key) external view returns (uint128) {
        return uInt128Storage[_key];
    }
    function getUint(bytes32 _key) external view returns (uint) { 
        return uIntStorage[_key];
    }
    // int
    function getInt8(bytes32 _key) external view returns (int8) {
        return int8Storage[_key];
    }
    function getInt16(bytes32 _key) external view returns (int16) {
        return int16Storage[_key];
    }
    function getInt32(bytes32 _key) external view returns (int32) {
        return int32Storage[_key];
    }
    function getInt64(bytes32 _key) external view returns (int64) {
        return int64Storage[_key];
    }
    function getInt128(bytes32 _key) external view returns (int128) {
        return int128Storage[_key];
    }
    function getInt(bytes32 _key) external view returns (int) { 
        return intStorage[_key];
    }
    // bytes
    function getBytes1(bytes32 _key) external view returns (bytes1) {
        return bytes1Storage[_key];
    }
    function getBytes2(bytes32 _key) external view returns (bytes2) {
        return bytes2Storage[_key];
    }
    function getBytes4(bytes32 _key) external view returns (bytes4) {
        return bytes4Storage[_key];
    }
    function getBytes8(bytes32 _key) external view returns (bytes8) {
        return bytes8Storage[_key];
    }
    function getBytes16(bytes32 _key) external view returns (bytes16) {
        return bytes16Storage[_key];
    }
    function getBytes20(bytes32 _key) external view returns (bytes20) {
        return bytes20Storage[_key];
    }
    function getBytes32(bytes32 _key) external view returns (bytes32) {
        return bytes32Storage[_key];
    }
    function getBytes(bytes32 _key) external view returns (bytes memory) {
        return bytesStorage[_key];
    }

    // ------------------------------------ WRITES ------------------------------------ //
    function setAddress(bytes32 _key, address _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            addressKeys.push(_key);
            isKeyExists[_key] = true;
        }
        addressStorage[_key] = _value;
    }
    function setString(bytes32 _key, string memory _value) public onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            stringKeys.push(_key);
            isKeyExists[_key] = true;
        }
        stringStorage[_key] = _value;
    }
    function setBool(bytes32 _key, bool _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            boolKeys.push(_key);
            isKeyExists[_key] = true;
        }
        boolStorage[_key] = _value;
    }
    // uint
    function setUint8(bytes32 _key, uint8 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            uInt8Keys.push(_key);
            isKeyExists[_key] = true;
        }
        uInt8Storage[_key] = _value;
    }
    function setUint16(bytes32 _key, uint16 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            uInt16Keys.push(_key);
            isKeyExists[_key] = true;
        }
        uInt16Storage[_key] = _value;
    }
    function setUint32(bytes32 _key, uint32 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            uInt32Keys.push(_key);
            isKeyExists[_key] = true;
        }
        uInt32Storage[_key] = _value;
    }
    function setUint64(bytes32 _key, uint64 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            uInt64Keys.push(_key);
            isKeyExists[_key] = true;
        }
        uInt64Storage[_key] = _value;
    }
    function setUint128(bytes32 _key, uint128 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            uInt128Keys.push(_key);
            isKeyExists[_key] = true;
        }
        uInt128Storage[_key] = _value;
    }
    function setUint(bytes32 _key, uint _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            uIntKeys.push(_key);
            isKeyExists[_key] = true;
        }
        uIntStorage[_key] = _value;
    }
    // int
    function setInt8(bytes32 _key, int8 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            int8Keys.push(_key);
            isKeyExists[_key] = true;
        }
        int8Storage[_key] = _value;
    }
    function setInt16(bytes32 _key, int16 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            int16Keys.push(_key);
            isKeyExists[_key] = true;
        }
        int16Storage[_key] = _value;
    }
    function setInt32(bytes32 _key, int32 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            int32Keys.push(_key);
            isKeyExists[_key] = true;
        }
        int32Storage[_key] = _value;
    }
    function setInt64(bytes32 _key, int64 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            int64Keys.push(_key);
            isKeyExists[_key] = true;
        }
        int64Storage[_key] = _value;
    }
    function setInt128(bytes32 _key, int128 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            int128Keys.push(_key);
            isKeyExists[_key] = true;
        }
        int128Storage[_key] = _value;
    }
    function setInt(bytes32 _key, int _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            intKeys.push(_key);
            isKeyExists[_key] = true;
        }
        intStorage[_key] = _value;
    }
    // bytes
    function setBytes1(bytes32 _key, bytes1 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes1Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes1Storage[_key] = _value;
    }
    function setBytes2(bytes32 _key, bytes2 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes2Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes2Storage[_key] = _value;
    }
    function setBytes4(bytes32 _key, bytes4 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes4Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes4Storage[_key] = _value;
    }
    function setBytes8(bytes32 _key, bytes8 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes8Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes8Storage[_key] = _value;
    }
    function setBytes16(bytes32 _key, bytes16 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes16Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes16Storage[_key] = _value;
    }
    function setBytes20(bytes32 _key, bytes20 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes20Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes20Storage[_key] = _value;
    }
    function setBytes32(bytes32 _key, bytes32 _value) external onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytes32Keys.push(_key);
            isKeyExists[_key] = true;
        }
        bytes32Storage[_key] = _value;
    }
    function setBytes(bytes32 _key, bytes memory _value) public onlyAllowedContract(msg.sender) {
        if(!isKeyExists[_key]){
            bytesKeys.push(_key);
            isKeyExists[_key] = true;
        }
        bytesStorage[_key] = _value;
    }

    // ------------------------------------ DELETE ------------------------------------ //
    function deleteAddress(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete addressStorage[_key];
    }
    function deleteString(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete stringStorage[_key];
    }
    function deleteBool(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete boolStorage[_key];
    }
    // uint
    function deleteUint8(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete uInt8Storage[_key];
    }
    function deleteUint16(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete uInt16Storage[_key];
    }
    function deleteUint32(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete uInt32Storage[_key];
    }
    function deleteUint64(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete uInt64Storage[_key];
    }
    function deleteUint128(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete uInt128Storage[_key];
    }
    function deleteUint(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete uIntStorage[_key];
    }
    // int
    function deleteint8(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete int8Storage[_key];
    }
    function deleteint16(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete int16Storage[_key];
    }
    function deleteint32(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete int32Storage[_key];
    }
    function deleteint64(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete int64Storage[_key];
    }
    function deleteint128(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete int128Storage[_key];
    }
    function deleteint(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete intStorage[_key];
    }
    // bytes
    function deleteBytes1(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes1Storage[_key];
    }
    function deleteBytes2(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes2Storage[_key];
    }
    function deleteBytes4(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes4Storage[_key];
    }
    function deleteBytes8(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes8Storage[_key];
    }
    function deleteBytes16(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes16Storage[_key];
    }
    function deleteBytes20(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes20Storage[_key];
    }
    function deleteBytes32(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytes32Storage[_key];
    }
    function deleteBytes(bytes32 _key) external onlyAllowedContract(msg.sender) {
        delete bytesStorage[_key];
    }


    // Get Keys List
    function getKeysListAddress(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(addressKeys.length>0, "No keys found");
        require(_from<addressKeys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = addressKeys.length;
        }
        if(_to>addressKeys.length){
            toIndex = addressKeys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = addressKeys[index];
        }
    }

    function getKeysListString(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(stringKeys.length>0, "No keys found");
        require(_from<stringKeys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = stringKeys.length;
        }
        if(_to>stringKeys.length){
            toIndex = stringKeys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = stringKeys[index];
        }
    }

    function getKeysListBool(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(boolKeys.length>0, "No keys found");
        require(_from<boolKeys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = boolKeys.length;
        }
        if(_to>boolKeys.length){
            toIndex = boolKeys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = boolKeys[index];
        }
    }

    function getKeysListUint8(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(uInt8Keys.length>0, "No keys found");
        require(_from<uInt8Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = uInt8Keys.length;
        }
        if(_to>uInt8Keys.length){
            toIndex = uInt8Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = uInt8Keys[index];
        }
    }

    function getKeysListUint16(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(uInt16Keys.length>0, "No keys found");
        require(_from<uInt16Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = uInt16Keys.length;
        }
        if(_to>uInt16Keys.length){
            toIndex = uInt16Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = uInt16Keys[index];
        }
    }

    function getKeysListUint32(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(uInt32Keys.length>0, "No keys found");
        require(_from<uInt32Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = uInt32Keys.length;
        }
        if(_to>uInt32Keys.length){
            toIndex = uInt32Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = uInt32Keys[index];
        }
    }

    function getKeysListUint64(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(uInt64Keys.length>0, "No keys found");
        require(_from<uInt64Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = uInt64Keys.length;
        }
        if(_to>uInt64Keys.length){
            toIndex = uInt64Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = uInt64Keys[index];
        }
    }

    function getKeysListUint128(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(uInt128Keys.length>0, "No keys found");
        require(_from<uInt128Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = uInt128Keys.length;
        }
        if(_to>uInt128Keys.length){
            toIndex = uInt128Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = uInt128Keys[index];
        }
    }
    
    function getKeysListUint(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(uIntKeys.length>0, "No keys found");
        require(_from<uIntKeys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = uIntKeys.length;
        }
        if(_to>uIntKeys.length){
            toIndex = uIntKeys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = uIntKeys[index];
        }
    }

    function getKeysListInt8(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(int8Keys.length>0, "No keys found");
        require(_from<int8Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = int8Keys.length;
        }
        if(_to>int8Keys.length){
            toIndex = int8Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = int8Keys[index];
        }
    }

    function getKeysListInt16(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(int16Keys.length>0, "No keys found");
        require(_from<int16Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = int16Keys.length;
        }
        if(_to>int16Keys.length){
            toIndex = int16Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = int16Keys[index];
        }
    }

    function getKeysListInt32(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(int32Keys.length>0, "No keys found");
        require(_from<int32Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = int32Keys.length;
        }
        if(_to>int32Keys.length){
            toIndex = int32Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = int32Keys[index];
        }
    }

    function getKeysListInt64(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(int64Keys.length>0, "No keys found");
        require(_from<int64Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = int64Keys.length;
        }
        if(_to>int64Keys.length){
            toIndex = int64Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = int64Keys[index];
        }
    }

    function getKeysListInt128(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(int128Keys.length>0, "No keys found");
        require(_from<int128Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = int128Keys.length;
        }
        if(_to>int128Keys.length){
            toIndex = int128Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = int128Keys[index];
        }
    }
    
    function getKeysListInt(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(intKeys.length>0, "No keys found");
        require(_from<intKeys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = intKeys.length;
        }
        if(_to>intKeys.length){
            toIndex = intKeys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = intKeys[index];
        }
    }
    
    function getKeysListBytes1(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes1Keys.length>0, "No keys found");
        require(_from<bytes1Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes1Keys.length;
        }
        if(_to>bytes1Keys.length){
            toIndex = bytes1Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes1Keys[index];
        }
    }
    
    function getKeysListBytes2(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes2Keys.length>0, "No keys found");
        require(_from<bytes2Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes2Keys.length;
        }
        if(_to>bytes2Keys.length){
            toIndex = bytes2Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes2Keys[index];
        }
    }
    
    function getKeysListBytes4(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes4Keys.length>0, "No keys found");
        require(_from<bytes4Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes4Keys.length;
        }
        if(_to>bytes4Keys.length){
            toIndex = bytes4Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes4Keys[index];
        }
    }
    
    function getKeysListBytes8(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes8Keys.length>0, "No keys found");
        require(_from<bytes8Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes8Keys.length;
        }
        if(_to>bytes8Keys.length){
            toIndex = bytes8Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes8Keys[index];
        }
    }
    
    function getKeysListBytes16(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes16Keys.length>0, "No keys found");
        require(_from<bytes16Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes16Keys.length;
        }
        if(_to>bytes16Keys.length){
            toIndex = bytes16Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes16Keys[index];
        }
    }
    
    function getKeysListBytes20(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes20Keys.length>0, "No keys found");
        require(_from<bytes20Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes20Keys.length;
        }
        if(_to>bytes20Keys.length){
            toIndex = bytes20Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes20Keys[index];
        }
    }
    
    function getKeysListBytes32(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytes32Keys.length>0, "No keys found");
        require(_from<bytes32Keys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytes32Keys.length;
        }
        if(_to>bytes32Keys.length){
            toIndex = bytes32Keys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytes32Keys[index];
        }
    }
    
    function getKeysListBytes(uint _from, uint _to) external view 
    onlyRegisteredStorage 
    returns(bytes32[] memory keysList_) {
        require(bytesKeys.length>0, "No keys found");
        require(_from<bytesKeys.length, "Invalid From Index");
        uint toIndex = _to;
        if(_from==0 && _to==0){
            toIndex = bytesKeys.length;
        }
        if(_to>bytesKeys.length){
            toIndex = bytesKeys.length;
        }
        keysList_ = new bytes32[](toIndex-_from);
        for (uint256 index = _from; index < toIndex; index++) {
            keysList_[index-_from] = bytesKeys[index];
        }
    }

}