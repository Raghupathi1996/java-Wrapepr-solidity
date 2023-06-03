pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract VendorStructs {

    uint16 constant internal __VERSION__ = 1;

    enum MergeRequestState {INITIATED, SUBMITTED, APPROVED, REJECTED, EXPIRED}
    enum SeedRequestState {SUBMITTED, APPROVED, REJECTED, EXPIRED}

    struct Vendor {
        string gid;
        string accountName; // Vendor's blockchain username 
        string vendorEgpName; // Name of registered Vendor 
        string[] vendorEgpId;  // External Id of the EGPs 
        string[] vendorEgpOrgId; // Organization Id of the EGPs 


        uint16 version;
    }
    string constant internal propNameVendorGid = "gid";
    string constant internal propNameVendorAccountName = "accountName";
    string constant internal propNameVendorVendorEgpName = "vendorEgpName";
    string constant internal propNameVendorVendorEgpIds = "list__vendorEgpIds";
    string constant internal propNameVendorVendorEgpOrgIds = "list__vendorEgpOrgIds";
    string constant internal propNameVendorVendorVersion = "version";

    struct MergeRequest {
        string gid1;
        string gid2;
        MergeRequestState state;
        uint16 version;
    }
    string constant internal propKeyMergeGid1 = "gid1";
    string constant internal propKeyMergeGid2 = "gid2";
    string constant internal propKeyMergeState = "state";
    string constant internal propKeyMergeVersion = "version";

    struct GID {
        string gid;
        string parentGid;
        string [] childrenGids;
        string [] associateGids;
        bool active;
        uint16 version;
    }
    string constant internal propKeyGidGid = "gid";
    string constant internal propKeyGidParentGid = "parentGid";
    string constant internal propKeyGidChildrenGids = "childrenGids";
    string constant internal propKeyGidAssociateGids = "associateGids";
    string constant internal propKeyGidActive = "active";
    string constant internal propKeyGidVersion = "version";

    struct GidSeedRequest {
        string gid;
        string vendorEgpId;
        string vendorEgpOrgId;
        SeedRequestState state;
        uint16 version;
    }
    string constant internal propKeySeedGid = "gid";
    string constant internal propKeySeedVendorEgpId = "vendorEgpId";
    string constant internal propKeySeedVendorEgpOrgId = "vendorEgpOrgId";
    string constant internal propKeySeedState = "state";
    string constant internal propKeySeedVersion = "version";
}

contract VendorModel is VendorStructs {
    
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


    string constant internal KEY = "VENDOR_MANAGER";
    string constant internal keyListLength = "__length";
    string constant internal vendorList = "list__vendorList";
    string constant internal vendorIndex = "map__vendorIndex";
    string constant internal vendorGid = "map__vendorGid";
    string constant internal egpIDVendors = "map__egpIDVendors";
    string constant internal activeVendorListLengthByEgp = "map__activeVendorListLengthByEgp";



    string constant internal mergeRequestList = "list__mergeRequestList";
    string constant internal mergeRequestIndex = "map__mergeRequestIndex";

    string constant internal mergeApprovedList = "list__mergeApprovedList";
    string constant internal mergeApprovedIndex = "map__mergeApprovedIndex";


    string constant internal gidList = "list__gidList";
    string constant internal gidIndex = "map__gidIndex";


    string constant internal seedRequestList = "list__seedRequestList";
    string constant internal seedRequestIndex = "map__seedRequestIndex";

    string constant internal seedApprovedList = "list__seedApprovedList";
    string constant internal seedApprovedIndex = "map__seedApprovedIndex";

    modifier onlyVendorManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validVendorListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, vendorList);
        require(_index < length, "Index Invalid");
        _;
    }

    modifier validMergeListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, mergeRequestList);
        require(_index < length, "Index Invalid");
        _;
    }

    modifier validGidListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, gidList);
        require(_index < length, "Index Invalid");
        _;
    }

    modifier validSeedListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, seedRequestList);
        require(_index < length, "Index Invalid");
        _;
    }

    function getVendorIndex(string memory _gid) public view returns (uint256) {
        return Map.getStringToUint(KEY, vendorIndex, _gid);
    }

    function getVendorGidMap(string memory _name) public view returns (string memory) {
        return Map.getStringToString(KEY, vendorGid, _name);
    }

    function getMergeIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, mergeRequestIndex, _uid);
    }

    function getGidIndex(string memory _gid) public view returns (uint256) {
        return Map.getStringToUint(KEY, gidIndex, _gid);
    }

    function getSeedRequestIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, seedRequestIndex, _uid);
    }

    function getVendorListLength() public view returns (uint256) {
        return List.getLength(KEY, vendorList);
    }

    function getMergeListLength() public view returns (uint256) {
        return List.getLength(KEY, mergeRequestList);
    }

    function getMergeApprovedListLength() public view returns (uint256) {
        return List.getLength(KEY, mergeApprovedList);
    }

    function getGidListLength() public view returns (uint256) {
        return List.getLength(KEY, gidList);
    }

    function getSeedListLength() public view returns (uint256) {
        return List.getLength(KEY, seedRequestList);
    }

    function getSeedApprovedListLength() public view returns (uint256) {
        return List.getLength(KEY, seedApprovedList);
    }


    function getVendorByIndex(uint256 _index)
        public
        view
        validVendorListIndex(_index)
        returns (Vendor memory vendor_)
    {
        vendor_.gid = getVendorGid(_index);
        vendor_.accountName = getVendorAccountName(_index);
        vendor_.vendorEgpName = getVendorVendorEgpName(_index);
        vendor_.vendorEgpId = getVendorVendorEgpIds(_index);
        vendor_.vendorEgpOrgId = getVendorVendorEgpOrgIds(_index);
        vendor_.version = getVendorVersion(_index);
    }

    function getAllVendors(uint _toExcluded, uint _count) public view 
    returns (Vendor[] memory _vendor, uint fromIncluded_, uint length_) {
        uint length = getVendorListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _vendor = new Vendor[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _vendor[_vendor.length-itr-1] = getVendorByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getVendorGid(uint256 _index) public view 
    validVendorListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, vendorList, _index, propNameVendorGid);
    }

    function getVendorAccountName(uint256 _index) public view
    validVendorListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, vendorList, _index, propNameVendorAccountName);
    }

    function getVendorVendorEgpName(uint256 _index) public view 
    validVendorListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, vendorList, _index, propNameVendorVendorEgpName);
    }

    function getVendorVendorEgpIds(uint256 _index) public view 
    validVendorListIndex(_index) 
    returns(string[] memory vendorEgpIds_) {
        uint length = List.getPropByKeyUint(KEY, vendorList, _index, bytes(propNameVendorVendorEgpIds), abi.encodePacked(keyListLength));
        vendorEgpIds_ = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            vendorEgpIds_[i] = List.getPropByKeyString(KEY, vendorList, _index, bytes(propNameVendorVendorEgpIds), abi.encodePacked(i));
        }
    }

    function getVendorVendorEgpOrgIds(uint256 _index) public view 
    validVendorListIndex(_index) 
    returns(string[] memory vendorEgpOrgIds_) {
        uint length = List.getPropByKeyUint(KEY, vendorList, _index, bytes(propNameVendorVendorEgpOrgIds), abi.encodePacked(keyListLength));
        vendorEgpOrgIds_ = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            vendorEgpOrgIds_[i] = List.getPropByKeyString(KEY, vendorList, _index, bytes(propNameVendorVendorEgpOrgIds), abi.encodePacked(i));
        }
    }

    function getVendorVersion(uint256 _index) public view 
    validVendorListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, vendorList, _index, propNameVendorVendorVersion);
    }

    function getAllMergeRequests(uint _toExcluded, uint _count) public view 
    returns(MergeRequest[] memory mergeRequests_, uint fromIncluded_, uint length_) {
        uint length = getMergeListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        mergeRequests_ = new MergeRequest[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            mergeRequests_[mergeRequests_.length-itr-1] = getMergeRequestByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getMergeRequestByIndex(uint256 _index) public view 
    validMergeListIndex(_index)
    returns(MergeRequest memory mergeRequest_) {
        mergeRequest_.gid1 = getMergeRequestGid1(_index);
        mergeRequest_.gid2 = getMergeRequestGid2(_index);
        mergeRequest_.state = getMergeRequestState(_index);
        mergeRequest_.version = getMergeRequestVersion(_index);
    }

    function getMergeRequestGid1(uint256 _index) public view 
    validMergeListIndex(_index)
    returns(string memory) {
        return List.getPropString(KEY, mergeRequestList, _index, propKeyMergeGid1);
    }

    function getMergeRequestGid2(uint256 _index) public view 
    validMergeListIndex(_index)
    returns(string memory) {
        return List.getPropString(KEY, mergeRequestList, _index, propKeyMergeGid2);
    }

    function getMergeRequestState(uint256 _index) public view 
    validMergeListIndex(_index)
    returns(MergeRequestState) {
        return MergeRequestState(List.getPropUint(KEY, mergeRequestList, _index, propKeyMergeState));
    }

    function getMergeRequestVersion(uint256 _index) public view 
    validMergeListIndex(_index)
    returns(uint16) {
        return List.getPropUint16(KEY, mergeRequestList, _index, propKeyMergeVersion);
    }

    function getGidByIndex(uint256 _index) public view 
    returns(GID memory gid_) {
        gid_.gid = getGidGid(_index);
        gid_.parentGid = getGidParentGid(_index);
        gid_.childrenGids = getGidChildrenGids(_index);
        gid_.associateGids = getGidAssociateGid(_index);
        gid_.version = getGidVersion(_index);
    }

    function getGidGid(uint256 _index) public view 
    returns(string memory) {
        return List.getPropString(KEY, gidList, _index, propKeyGidGid);
    }

    function getGidParentGid(uint256 _index) public view 
    returns(string memory) {
        return List.getPropString(KEY, gidList, _index, propKeyGidParentGid);
    }

    function getGidChildrenGids(uint256 _index) public view 
    returns(string [] memory childrenGids_) {
        uint length = List.getPropByKeyUint(KEY, gidList, _index, bytes(propKeyGidChildrenGids), abi.encodePacked(keyListLength));
        childrenGids_ = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            childrenGids_[i] = List.getPropByKeyString(KEY, gidList, _index, bytes(propKeyGidChildrenGids), abi.encodePacked(i));
        }
    }

    function getGidAssociateGid(uint256 _index) public view 
    returns(string [] memory associateGids_) {
        uint length = List.getPropByKeyUint(KEY, gidList, _index, bytes(propKeyGidAssociateGids), abi.encodePacked(keyListLength));
        associateGids_ = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            associateGids_[i] = List.getPropByKeyString(KEY, gidList, _index, bytes(propKeyGidAssociateGids), abi.encodePacked(i));
        }
    }

    function getGidActive(uint256 _index) public view 
    returns(bool) {
        return List.getPropBool(KEY, gidList, _index, propKeyGidActive);
    }

    function getGidVersion(uint256 _index) public view 
    returns(uint16) {
        return List.getPropUint16(KEY, gidList, _index, propKeyGidVersion);
    }

    function getAllGidSeedRequests(uint _toExcluded, uint _count) public view 
    returns(GidSeedRequest[] memory gidSeedRequests_, uint fromIncluded_, uint length_) {
        uint length = getSeedListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        gidSeedRequests_ = new GidSeedRequest[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            gidSeedRequests_[gidSeedRequests_.length-itr-1] = getSeedRequestByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getSeedRequestByIndex(uint256 _index) public view 
    validSeedListIndex(_index)
    returns(GidSeedRequest memory gidSeedRequest_) {
        gidSeedRequest_.gid = getSeedRequestGid(_index);
        gidSeedRequest_.vendorEgpId = getSeedRequestVendorEgpId(_index);
        gidSeedRequest_.vendorEgpOrgId = getSeedRequestVendorEgpOrgId(_index);
        gidSeedRequest_.state = getSeedRequestState(_index);
        gidSeedRequest_.version = getSeedRequestVersion(_index);
    }

    function getSeedRequestGid(uint256 _index) public view 
    validSeedListIndex(_index)
    returns(string memory) {
        return List.getPropString(KEY, seedRequestList, _index, propKeySeedGid);
    }

    function getSeedRequestVendorEgpId(uint256 _index) public view 
    validSeedListIndex(_index)
    returns(string memory) {
        return List.getPropString(KEY, seedRequestList, _index, propKeySeedVendorEgpId);
    }

    function getSeedRequestVendorEgpOrgId(uint256 _index) public view 
    validSeedListIndex(_index)
    returns(string memory) {
        return List.getPropString(KEY, seedRequestList, _index, propKeySeedVendorEgpOrgId);
    }

    function getSeedRequestState(uint256 _index) public view 
    validSeedListIndex(_index)
    returns(SeedRequestState) {
        return SeedRequestState(List.getPropUint8(KEY, seedRequestList, _index, propKeySeedState));
    }

    function getSeedRequestVersion(uint256 _index) public view 
    validSeedListIndex(_index)
    returns(uint16) {
        return List.getPropUint16(KEY, seedRequestList, _index, propKeySeedVersion);
    }


    // ------------- SETTERS ------------- //

    
    function setVendorIndex(string memory _gid, uint _value) public 
    onlyVendorManager {
        Map.setStringToUint(KEY, vendorIndex, _gid, _value);
    }

    function setVendorGidMap(string memory _name, string memory _gid) public 
    onlyVendorManager {
        Map.setStringToString(KEY, vendorGid, _name, _gid);
    }

    function setMergeIndex(bytes8 _uid, uint _value) public 
    onlyVendorManager {
        Map.setBytes8ToUint(KEY, mergeRequestIndex, _uid, _value);
    }

    function setGidIndex(string memory _gid, uint _value) public 
    onlyVendorManager {
        Map.setStringToUint(KEY, gidIndex, _gid, _value);
    }

    function setSeedRequestIndex(bytes8 _uid, uint _value) public 
    onlyVendorManager {
        Map.setBytes8ToUint(KEY, seedRequestIndex, _uid, _value);
    }

    function incVendorListLength() public 
    onlyVendorManager {
        List.incLength(KEY, vendorList);
    }

    function incMergeRequestListLength() public 
    onlyVendorManager {
        List.incLength(KEY, mergeRequestList);
    }

    function incMergeApprovedListLength() public 
    onlyVendorManager {
        List.incLength(KEY, mergeApprovedList);
    }

    function incSeedApprovedListLength() public 
    onlyVendorManager {
        List.incLength(KEY, seedApprovedList);
    }

    function incGidListLength() public 
    onlyVendorManager {
        List.incLength(KEY, gidList);
    }

    function incSeedRequestListLength() public 
    onlyVendorManager {
        List.incLength(KEY, seedRequestList);
    }

    function setVendorGid(uint256 _index, string memory _gid) public 
    onlyVendorManager {
        List.setPropString(KEY, vendorList, _index, propNameVendorGid, _gid);
    }

    function setVendorAccountName(uint256 _index, string memory _value) public 
    onlyVendorManager {
        List.setPropString(KEY, vendorList, _index, propNameVendorAccountName, _value);
    }

    function setVendorVendorEgpName(uint256 _index, string memory _value) public 
    onlyVendorManager {
        List.setPropString(KEY, vendorList, _index, propNameVendorVendorEgpName, _value);
    }

    function addVendorVendorEgpId(uint256 _index, string memory _value) public 
    onlyVendorManager {
        uint length = List.getPropByKeyUint(KEY, vendorList, _index, bytes(propNameVendorVendorEgpIds), abi.encodePacked(keyListLength));
        List.setPropByKeyUint(KEY, vendorList, _index, bytes(propNameVendorVendorEgpIds), abi.encodePacked(keyListLength), 1+length);
        List.setPropByKeyString(KEY, vendorList, _index, bytes(propNameVendorVendorEgpIds), abi.encodePacked(length), _value);
    }

    function addVendorVendorEgpOrgId(uint256 _index, string memory _value) public 
    onlyVendorManager {
        uint length = List.getPropByKeyUint(KEY, vendorList, _index, bytes(propNameVendorVendorEgpOrgIds), abi.encodePacked(keyListLength));
        List.setPropByKeyUint(KEY, vendorList, _index, bytes(propNameVendorVendorEgpOrgIds), abi.encodePacked(keyListLength), 1+length);
        List.setPropByKeyString(KEY, vendorList, _index, bytes(propNameVendorVendorEgpOrgIds), abi.encodePacked(length), _value);
    }

    function setVendorVersion(uint256 _index) public
    onlyVendorManager 
    {
        List.setPropUint16(KEY, vendorList, _index, propNameVendorVendorVersion, __VERSION__);
    }

    function setMergeRequestGid1(uint256 _index, string memory _gid1) public 
    onlyVendorManager 
    validMergeListIndex(_index) {
        List.setPropString(KEY, mergeRequestList, _index, propKeyMergeGid1, _gid1);
    }

    function setMergeRequestGid2(uint256 _index, string memory _gid2) public 
    onlyVendorManager 
    validMergeListIndex(_index) {
        List.setPropString(KEY, mergeRequestList, _index, propKeyMergeGid2, _gid2);
    }

    function setMergeRequestState(uint256 _index, MergeRequestState _value) public 
    onlyVendorManager 
    validMergeListIndex(_index) {
        List.setPropUint(KEY, mergeRequestList, _index, propKeyMergeState, uint8(_value));
    }

    function setMergeRequestVersion(uint256 _index) public 
    onlyVendorManager 
    validMergeListIndex(_index) {
        List.setPropUint16(KEY, mergeRequestList, _index, propKeyMergeVersion, __VERSION__);
    }

    function setGidGid(uint256 _index, string memory _gid) public 
    onlyVendorManager  
    {
        List.setPropString(KEY, gidList, _index, propKeyGidGid, _gid);
    }

    function setGidParentGid(uint256 _index, string memory _parentGid) public 
    onlyVendorManager  
    {
        List.setPropString(KEY, gidList, _index, propKeyGidParentGid, _parentGid);
    }

    function addGidChildrenGids(uint256 _index, string memory _gid) public 
    onlyVendorManager  
    {
        uint length = List.getPropByKeyUint(KEY, gidList, _index, bytes(propKeyGidChildrenGids), abi.encodePacked(keyListLength));
        List.setPropByKeyUint(KEY, gidList, _index, bytes(propKeyGidChildrenGids), abi.encodePacked(keyListLength), 1+length);
        List.setPropByKeyString(KEY, gidList, _index, bytes(propKeyGidChildrenGids), abi.encodePacked(length), _gid);
    }

    function addGidAssociateGid(uint256 _index, string memory _gid) public 
    onlyVendorManager  
    {
        uint length = List.getPropByKeyUint(KEY, gidList, _index, bytes(propKeyGidAssociateGids), abi.encodePacked(keyListLength));
        List.setPropByKeyUint(KEY, gidList, _index, bytes(propKeyGidAssociateGids), abi.encodePacked(keyListLength), 1+length);
        List.setPropByKeyString(KEY, gidList, _index, bytes(propKeyGidAssociateGids), abi.encodePacked(length), _gid);
    }

    function setGidActive(uint256 _index, bool _value) public 
    onlyVendorManager  
    {
        List.setPropBool(KEY, gidList, _index, propKeyGidActive, _value);
    }

    function setGidVersion(uint256 _index) public 
    onlyVendorManager  
    {
        List.setPropUint16(KEY, gidList, _index, propKeyGidVersion, __VERSION__);
    }

    function setSeedRequestGid(uint256 _index, string memory _gid) public 
    onlyVendorManager 
    validSeedListIndex(_index) {
        List.setPropString(KEY, seedRequestList, _index, propKeySeedGid, _gid);
    }

    function setSeedRequestVendorEgpId(uint256 _index, string memory _value) public  
    onlyVendorManager 
    validSeedListIndex(_index) {
        List.setPropString(KEY, seedRequestList, _index, propKeySeedVendorEgpId, _value);
    }

    function setSeedRequestVendorEgpOrgId(uint256 _index, string memory _value) public  
    onlyVendorManager 
    validSeedListIndex(_index) {
        List.setPropString(KEY, seedRequestList, _index, propKeySeedVendorEgpOrgId, _value);
    }

    function setSeedRequestState(uint256 _index, SeedRequestState _value) public  
    onlyVendorManager 
    validSeedListIndex(_index) {
        List.setPropUint8(KEY, seedRequestList, _index, propKeySeedState, uint8(_value));
    }

    function setSeedRequestVersion(uint256 _index) public  
    onlyVendorManager 
    validSeedListIndex(_index) {
        List.setPropUint16(KEY, seedRequestList, _index, propKeySeedVersion, __VERSION__);
    }

    
}