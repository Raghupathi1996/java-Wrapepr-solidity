pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract ProcuringEntityStructs {
    uint16 constant internal __VERSION__ = 1;
    struct ProcuringEntity {
        string gid;
        string name;
        string externalId;
        string orgId;
        uint16 version;
    }
    string constant internal propKeyPEntityGid = "gid";
    string constant internal propKeyPEntityName = "name";
    string constant internal propKeyPEntityExternalId = "externalId";
    string constant internal propKeyPEntityOrgId = "orgId";
    string constant internal propKeyPEntityVersion = "version";
}

contract ProcuringEntityModel is ProcuringEntityStructs {
    
    MemberStorage private Member;
    ListStorage private List;
    MapStorage private Map;
    QuireContracts private quireContracts;
    
    constructor(
        address _Member,
        address _List,
        address _Map,
        address _quireContracts
    ){
        Member = MemberStorage(_Member);
        List = ListStorage(_List);
        Map = MapStorage(_Map);
        quireContracts = QuireContracts(_quireContracts);
    }


    string constant internal KEY = "PROCURING_ENTITY_MANAGER"; 
    string constant internal procuringEntityList = "list__procuringEntityList";
    string constant internal procuringEntityIndex = "map__procuringEntityIndex";

    modifier onlyProcuringEntityManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validProcuringEntityListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, procuringEntityList);
        require(_index < length, "Index Invalid");
        _;
    }

    // ------------- GETTERS ------------- //

    function getProcuringEntityIndex(string memory _gid) public view returns (uint256) {
        return Map.getStringToUint(KEY, procuringEntityIndex, _gid);
    }

    function getProcuringEntityListLength() public view returns (uint256) {
        return List.getLength(KEY, procuringEntityList);
    }

    function getProcuringEntityByIndex(uint256 _index)
        public
        view
        validProcuringEntityListIndex(_index)
        returns (ProcuringEntity memory procuringEntity_)
    {
        procuringEntity_.gid = getProcuringEntityGid(_index);
        procuringEntity_.name = getProcuringEntityName(_index);
        procuringEntity_.externalId = getProcuringEntityExternalId(_index);
        procuringEntity_.orgId = getProcuringEntityOrgId(_index);
        procuringEntity_.version = getProcuringEntityVersion(_index);
    }

    function getAllProcuringEntities(uint _toExcluded, uint _count) external view 
    returns(ProcuringEntity[] memory procuringEntities_, uint fromIncluded_, uint length_) {
        uint length = getProcuringEntityListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        procuringEntities_ = new ProcuringEntity[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            procuringEntities_[procuringEntities_.length-itr-1] = getProcuringEntityByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getProcuringEntityGid(uint256 _index) public view 
    validProcuringEntityListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, procuringEntityList, _index, propKeyPEntityGid);
    }

    function getProcuringEntityName(uint256 _index) public view 
    validProcuringEntityListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, procuringEntityList, _index, propKeyPEntityName);
    }

    function getProcuringEntityExternalId(uint256 _index) public view 
    validProcuringEntityListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, procuringEntityList, _index, propKeyPEntityExternalId);
    }

    function getProcuringEntityOrgId(uint256 _index) public view 
    validProcuringEntityListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, procuringEntityList, _index, propKeyPEntityOrgId);
    }

    function getProcuringEntityVersion(uint256 _index) public view 
    validProcuringEntityListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, procuringEntityList, _index, propKeyPEntityVersion);
    }

    // ------------- SETTERS ------------- //

    function setProcuringEntityIndex(string memory _gid, uint _value) public 
    onlyProcuringEntityManager {
        Map.setStringToUint(KEY, procuringEntityIndex, _gid, _value);
    }

    function incProcuringEntityListLength() public 
    onlyProcuringEntityManager {
        List.incLength(KEY, procuringEntityList);
    }

    function setProcuringEntityGid(uint256 _index, string memory _value) public 
    onlyProcuringEntityManager {
        List.setPropString(KEY, procuringEntityList, _index, propKeyPEntityGid, _value);
    }

    function setProcuringEntityName(uint256 _index, string memory _value) public 
    onlyProcuringEntityManager {
        List.setPropString(KEY, procuringEntityList, _index, propKeyPEntityName, _value);
    }

    function setProcuringEntityExternalId(uint256 _index, string memory _value) public 
    onlyProcuringEntityManager {
        List.setPropString(KEY, procuringEntityList, _index, propKeyPEntityExternalId, _value);
    }

    function setProcuringEntityOrgId(uint256 _index, string memory _value) public 
    onlyProcuringEntityManager {
        List.setPropString(KEY, procuringEntityList, _index, propKeyPEntityOrgId, _value);
    }

    function setProcuringEntityVersion(uint256 _index) public 
    onlyProcuringEntityManager {
        List.setPropUint16(KEY, procuringEntityList, _index, propKeyPEntityVersion, __VERSION__);
    }

    function pushProcuringEntity(ProcuringEntity memory _procuringEntity) public  
    onlyProcuringEntityManager
    {
        uint index = getProcuringEntityListLength();
        incProcuringEntityListLength();
        setProcuringEntityGid(index,_procuringEntity.gid);
        setProcuringEntityName(index,_procuringEntity.name);
        setProcuringEntityExternalId(index,_procuringEntity.externalId);
        setProcuringEntityOrgId(index,_procuringEntity.orgId);   
        setProcuringEntityVersion(index);
    }
   
}