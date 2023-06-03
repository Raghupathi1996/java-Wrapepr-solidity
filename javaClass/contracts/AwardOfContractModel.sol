pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract AwardOfContractStructs {
    uint16 constant internal __VERSION__ = 1;

    enum AOCStatus {EvaluationComplete, Awarded, Cancelled}
    
    struct AOC {
        bytes8 uid;
        string vendorGid;
        string vendorName;
        string tenderReference;
        string awardReference;
        string title;
        AOCStatus aocStatus;
        string contractAwardValue;
        string[] lotName;
        uint awardOfContractDate;
        string procuringEntityGid;
        string procuringEntityName;
        string remarks;
        string awardOfContractLink;
        string orgId;
        uint16 version;
    }
    string constant internal propKeyAocUid = "uid";
    string constant internal propKeyAocVendorGid = "vendorGid";
    string constant internal propKeyAocVendorName = "vendorName";
    string constant internal propKeyAocTenderReference = "tenderReference";
    string constant internal propKeyAocAwardReference = "awardReference";
    string constant internal propKeyAocTitle = "title";
    string constant internal propKeyAocStatus = "aocStatus";
    string constant internal propKeyAocContractAwardValue = "contractAwardValue";
    string constant internal propKeyAocLotName = "lotName";
    string constant internal propKeyAocAwardOfContractDate = "awardOfContractDate";
    string constant internal propKeyAocProcuringEntityGid = "procuringEntityGid";
    string constant internal propKeyAocProcuringEntityName = "procuringEntityName";
    string constant internal propKeyAocRemarks = "remarks";
    string constant internal propKeyAocAwardOfContractLink = "awardOfContractLink";
    string constant internal propKeyAocOrgId = "orgId";
    string constant internal propKeyAocVersion = "version";
}

contract AwardOfContractModel is AwardOfContractStructs {

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


    string constant internal KEY = "AWARD_OF_CONTRACT_MANAGER";
    string constant internal propLength = "__length";
    string constant internal aocList = "list__aocList";
    string constant internal vendorAOCsMap = "map__vendorAOCs";
    string constant internal aocIndexMap = "map__aocIndex";
    string constant internal aocStatusList = "list__aocStatusList";
    string constant internal aocsIndexByAwardRefOrgIdMap = "map__aocsIndexByAwardRefOrgId";
    string constant internal aocsByPeGid = "map__aocsByPeGid";
    string constant internal aocsByOrgId = "map__aocsByOrgId";
    string constant internal aocsByVendorGidAndOrgId = "map__aocsByVendorGidAndOrgId";
    string constant internal aocsByTenderRefAndOrgId = "map__aocsByTenderRefAndOrgId";
    string constant internal aocsByPeAndVendorGid= "map__aocsByPeAndVendorGid";
    
    modifier onlyAocManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }
    
    modifier validAocListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, aocList);
        require(_index < length, "Index Invalid");
        _;
    }

    function getAocIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, aocIndexMap, _uid);
    }

    function getAocsIndexByAwardRefOrgId(bytes8 _uid) public view returns (uint256[] memory indexList_) {
        uint length = Map.getByKeyBytes8ToUint(KEY, aocsIndexByAwardRefOrgIdMap, _uid, abi.encodePacked(propLength));
        indexList_ = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            indexList_[i] = Map.getByKeyBytes8ToUint(KEY, aocsIndexByAwardRefOrgIdMap, _uid, abi.encodePacked(i));
        }
    }

    function getVendorAocIndices(string memory _gid) public view returns(uint[] memory vendorAocs_) {
        uint length = Map.getByKeyStringToUint(KEY, vendorAOCsMap, _gid, abi.encodePacked(propLength));
        vendorAocs_ = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            vendorAocs_[i] = Map.getByKeyStringToUint(KEY, vendorAOCsMap, _gid, abi.encodePacked(i));
        }
    }

    function getAocListLength() public view returns (uint256) {
        return List.getLength(KEY, aocList);
    }

    function getAocByIndex(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(AOC memory aoc_) {
        aoc_.uid = getAocUid(_index);
        aoc_.vendorGid = getAocVendorGid(_index);
        aoc_.vendorName = getAocVendorName(_index);
        aoc_.tenderReference = getAocTenderReference(_index);
        aoc_.awardReference = getAocAwardReference(_index);
        aoc_.aocStatus = getAocStatus(_index);
        aoc_.title = getAocTitle(_index);
        aoc_.contractAwardValue = getAocCavTender(_index);
        aoc_.lotName = getAocLotName(_index);
        aoc_.awardOfContractDate = getAocContractDate(_index);
        aoc_.procuringEntityGid = getAocProcEntityGid(_index);
        aoc_.procuringEntityName = getAocProcEntityName(_index);
        aoc_.remarks = getAocRemarks(_index);
        aoc_.awardOfContractLink = getAocAocLink(_index);
        aoc_.orgId = getAocOrgId(_index);
        aoc_.version = getAocVersion(_index);
    }

    function getAllAoc(uint _toExcluded, uint _count) external view 
    returns(AOC[] memory _aoc, uint fromIncluded_, uint length_) {
        uint length = getAocListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aoc = new AOC[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aoc[_aoc.length-itr-1] = getAocByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getAocUid(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, aocList, _index, propKeyAocUid);
    }

    function getAocVendorGid(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocVendorGid);
    }

    function getAocVendorName(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocVendorName);
    }

    function getAocTenderReference(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocTenderReference);
    }

    function getAocAwardReference(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocAwardReference);
    }

    function getAocStatus(uint256 _index) public view
    validAocListIndex(_index) 
    returns(AOCStatus) {
        return AOCStatus(List.getPropUint8(KEY, aocStatusList, _index, propKeyAocStatus));
    }

    function getAocTitle(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocTitle);
    }

    function getAocCavTender(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocContractAwardValue);
    }

    function getAocLotName(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string[] memory lotName_) {
        uint length = List.getPropByKeyUint(KEY, aocList, _index, bytes(propKeyAocLotName), abi.encodePacked(propLength));
        lotName_ = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            lotName_[i] = List.getPropByKeyString(KEY, aocList, _index, bytes(propKeyAocLotName), abi.encodePacked(i));
        }
    }

    function getAocContractDate(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, aocList, _index, propKeyAocAwardOfContractDate);
    }

    function getAocProcEntityGid(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocProcuringEntityGid);
    }

    function getAocProcEntityName(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocProcuringEntityName);
    }

    function getAocRemarks(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocRemarks);
    }

    function getAocAocLink(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocAwardOfContractLink);
    }

    function getAocOrgId(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, aocList, _index, propKeyAocOrgId);
    }

    function getAocVersion(uint256 _index) public view 
    validAocListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, aocList, _index, propKeyAocVersion);
    }

    
    /** @dev Listing out the Aocs against the PE Gid.
      * @param _procuringEntityGid GID assigned to Procuring Entity.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByPeGid List of Aocs against the PE Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE Gid.
      */
    function getAocsByPeGid(string memory _procuringEntityGid, uint _toExcluded, uint _count) public view returns(uint[] memory _aocsByPeGid, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, aocsByPeGid, _procuringEntityGid, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aocsByPeGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aocsByPeGid[_aocsByPeGid.length-itr-1] = Map.getByKeyStringToUint(KEY, aocsByPeGid, _procuringEntityGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }


    /** @dev Listing out the Aocs against the EgpSystem Id.
      * @param _orgId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByOrgId List of Aocs against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getAocsByOrgId(string memory _orgId, uint _toExcluded, uint _count) public view returns(uint[] memory _aocsByOrgId, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, aocsByOrgId, _orgId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aocsByOrgId = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aocsByOrgId[_aocsByOrgId.length-itr-1] = Map.getByKeyStringToUint(KEY, aocsByOrgId, _orgId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }


    /** @dev Listing out the Aocs against the Vendor Gid and EgpSystem Id.
      * @param _aocVendorOrgId GID of the vendor and e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByVendorGidAndOrgId List of Aocs against the Vendor Gid and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Vendor Gid and EgpSystem Id.
      */
    function getAocsByVendorGidAndOrgId(bytes8 _aocVendorOrgId, uint _toExcluded, uint _count) public view returns(uint[] memory _aocsByVendorGidAndOrgId, uint fromIncluded_, uint length_)  {
        //bytes8 _aocVendorOrgId = bytes8(keccak256(abi.encodePacked(_vendorGid, _orgId)));
        uint length = Map.getByKeyBytes8ToUint(KEY, aocsByVendorGidAndOrgId, _aocVendorOrgId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aocsByVendorGidAndOrgId = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aocsByVendorGidAndOrgId[_aocsByVendorGidAndOrgId.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, aocsByVendorGidAndOrgId, _aocVendorOrgId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }


    /** @dev Listing out the Aocs against the Tender Reference and EgpSystem Id.
      * @param _aocTenderRefOrgId Tender Reference and e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByTenderRefAndOrgId List of Aocs against the Tender Reference and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Tender Reference and EgpSystem Id.
      */
    function getAocsByTenderRefAndOrgId(bytes8 _aocTenderRefOrgId, uint _toExcluded, uint _count) public view returns(uint[] memory _aocsByTenderRefAndOrgId, uint fromIncluded_, uint length_)  {
        //bytes8 _aocTenderRefOrgId = bytes8(keccak256(abi.encodePacked(_tenderReference, _orgId)));
        uint length = Map.getByKeyBytes8ToUint(KEY, aocsByTenderRefAndOrgId, _aocTenderRefOrgId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aocsByTenderRefAndOrgId = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aocsByTenderRefAndOrgId[_aocsByTenderRefAndOrgId.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, aocsByTenderRefAndOrgId, _aocTenderRefOrgId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }


    /** @dev Listing out the Aocs against the PE GID and Vendor Gid.
      * @param _aocPeVendorGid GID assigned to Procuring Entity and GID of the vendor.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByPeAndVendorGid List of Aocs against the PE GID and Vendor Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE GID and Vendor Gid.
      */
    function getAocsByPeAndVendorGid(bytes8 _aocPeVendorGid, uint _toExcluded, uint _count) public view returns(uint[] memory _aocsByPeAndVendorGid, uint fromIncluded_, uint length_)  {
        //bytes8 _aocPeVendorGid = bytes8(keccak256(abi.encodePacked(_procuringEntityGid, _vendorGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, aocsByPeAndVendorGid, _aocPeVendorGid, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aocsByPeAndVendorGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aocsByPeAndVendorGid[_aocsByPeAndVendorGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, aocsByPeAndVendorGid, _aocPeVendorGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }



    // ------------- SETTERS ------------- //
    
    function addAocIndexByAwardRefOrgId(bytes8 _uid, uint _value) public 
    onlyAocManager
    {
        uint length = Map.getByKeyBytes8ToUint(KEY, aocsIndexByAwardRefOrgIdMap, _uid, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, aocsIndexByAwardRefOrgIdMap, _uid, abi.encodePacked(propLength), 1 + length);
        Map.setByKeyBytes8ToUint(KEY, aocsIndexByAwardRefOrgIdMap, _uid, abi.encodePacked(length), _value);
    }

    function setAocIndex(bytes8 _uid, uint _value) public 
    onlyAocManager
    {
        return Map.setBytes8ToUint(KEY, aocIndexMap, _uid, _value);
    }

    function addVendorAocIndex(string memory _gid, uint _value) public 
    onlyAocManager
    {
        uint length = Map.getByKeyStringToUint(KEY, vendorAOCsMap, _gid, abi.encodePacked(propLength));
        Map.setByKeyStringToUint(KEY, vendorAOCsMap, _gid, abi.encodePacked(propLength), 1+length);
        Map.setByKeyStringToUint(KEY, vendorAOCsMap, _gid, abi.encodePacked(length), _value);
    }

    function incAocListLength() public 
    onlyAocManager {
        List.incLength(KEY, aocList);
    }

    function addAwardOfContract(uint _index, AOC memory _aoc) public
    onlyAocManager
    validAocListIndex(_index) {
        setAocUid(_index, _aoc.uid);
        setAocVendorGid(_index, _aoc.vendorGid);
        setAocVendorName(_index, _aoc.vendorName);
        setAocTenderReference(_index, _aoc.tenderReference);
        setAocAwardReference(_index, _aoc.awardReference);
        setAocStatus(_index,_aoc.aocStatus);
        setAocTitle(_index, _aoc.title);
        setAocCavTender(_index, _aoc.contractAwardValue);
        setAocLotName(_index, _aoc.lotName);
        setAocContractDate(_index, _aoc.awardOfContractDate);
        setAocProcEntityGid(_index, _aoc.procuringEntityGid);
        setAocProcEntityName(_index, _aoc.procuringEntityName);
        setAocRemarks(_index, _aoc.remarks);
        setAocAocLink(_index, _aoc.awardOfContractLink);
        setAocOrgId(_index, _aoc.orgId);
        setAocVersion(_index);
    }

    function setAocUid(uint256 _index, bytes8 _uid) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropBytes8(KEY, aocList, _index, propKeyAocUid, _uid);
    }

    function setAocVendorGid(uint256 _index, string memory _gid) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocVendorGid, _gid);
    }

    function setAocVendorName(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocVendorName, _value);
    }

    function setAocTenderReference(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocTenderReference, _value);
    }

    function setAocAwardReference(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocAwardReference, _value);
    }

    function setAocStatus(uint256 _index, AOCStatus _value) public
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropUint8(KEY, aocStatusList, _index, propKeyAocStatus, uint8(_value));
    }

    function setAocTitle(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocTitle, _value);
    }

    function setAocCavTender(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocContractAwardValue, _value);
    }

    function setAocLotName(uint256 _index, string[] memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropByKeyUint(KEY, aocList, _index, bytes(propKeyAocLotName), bytes(propLength), _value.length);
        for (uint256 i = 0; i < _value.length; i++) {
            List.setPropByKeyString(KEY, aocList, _index, bytes(propKeyAocLotName), abi.encodePacked(i), _value[i]);
        }
    }

    function setAocContractDate(uint256 _index, uint _awardOfContractDate) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropUint(KEY, aocList, _index, propKeyAocAwardOfContractDate, _awardOfContractDate);
    }

    function setAocProcEntityGid(uint256 _index, string memory _gid) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocProcuringEntityGid, _gid);
    }

    function setAocProcEntityName(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocProcuringEntityName, _value);
    }

    function setAocRemarks(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocRemarks, _value);
    }

    function setAocAocLink(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocAwardOfContractLink, _value);
    }

    function setAocOrgId(uint256 _index, string memory _value) public 
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropString(KEY, aocList, _index, propKeyAocOrgId, _value);
    }

    function setAocVersion(uint256 _index) public
    onlyAocManager
    validAocListIndex(_index) 
    {
        List.setPropUint16(KEY, aocList, _index, propKeyAocVersion, __VERSION__);
    }

    function awardedAocStatus(AOC memory _aoc) public
    onlyAocManager
    {
        uint256 _index = getAocIndex(_aoc.uid);
        setAocVendorGid(_index-1, _aoc.vendorGid);
        setAocVendorName(_index-1, _aoc.vendorName);
        setAocAwardReference(_index-1, _aoc.awardReference);
        setAocTitle(_index-1, _aoc.title);
        setAocStatus(_index-1, AOCStatus.Awarded);
        setAocCavTender(_index-1, _aoc.contractAwardValue);
        setAocLotName(_index-1, _aoc.lotName);
        setAocContractDate(_index-1, _aoc.awardOfContractDate);
        setAocRemarks(_index-1, _aoc.remarks);
        setAocAocLink(_index-1, _aoc.awardOfContractLink);
    }

    function cancelAocStatus(bytes8 _uid) public
    onlyAocManager
    {
        uint256 _index = getAocIndex(_uid);
        setAocStatus(_index-1, AOCStatus.Cancelled);
    }


    
    /** @dev Setting the Aocs against the PE GID, Setting the Aocs against the EgpSystem Id , Setting the Aocs against the Vendor Gid and EgpSystem Id, Setting the Aocs against the Tender Reference Number and EgpSystem Id, Setting the Aocs against the PE Gid and Vendor Gid.
      * @param _aoc Award of contract details.
      * @param _value .
      */
    function setAocIndices(AOC memory _aoc, uint _value) public 
    onlyAocManager
    {
        // set aocsByPeGid
        uint length = Map.getByKeyStringToUint(KEY, aocsByPeGid, _aoc.procuringEntityGid, abi.encodePacked(propLength));
        Map.setByKeyStringToUint(KEY, aocsByPeGid, _aoc.procuringEntityGid, abi.encodePacked(propLength), 1+length);
        Map.setByKeyStringToUint(KEY, aocsByPeGid, _aoc.procuringEntityGid, abi.encodePacked(length), _value);


        //set aocsByOrgId
        length = Map.getByKeyStringToUint(KEY, aocsByOrgId, _aoc.orgId, abi.encodePacked(propLength));
        Map.setByKeyStringToUint(KEY, aocsByOrgId, _aoc.orgId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyStringToUint(KEY, aocsByOrgId, _aoc.orgId, abi.encodePacked(length), _value);

        //set aocsByVendorGidAndOrgId
        bytes8 _aocVendorOrgId = bytes8(keccak256(abi.encodePacked(_aoc.vendorGid, _aoc.orgId)));
        length = Map.getByKeyBytes8ToUint(KEY, aocsByVendorGidAndOrgId, _aocVendorOrgId, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, aocsByVendorGidAndOrgId, _aocVendorOrgId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, aocsByVendorGidAndOrgId, _aocVendorOrgId, abi.encodePacked(length), _value);

        //set aocsByTenderRefAndOrgId
        bytes8 _aocTenderRefOrgId = bytes8(keccak256(abi.encodePacked(_aoc.tenderReference, _aoc.orgId)));
        length = Map.getByKeyBytes8ToUint(KEY, aocsByTenderRefAndOrgId, _aocTenderRefOrgId, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, aocsByTenderRefAndOrgId, _aocTenderRefOrgId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, aocsByTenderRefAndOrgId, _aocTenderRefOrgId, abi.encodePacked(length), _value);

        //set aocsByPeAndVendorGid
        bytes8 _aocPeVendorGid = bytes8(keccak256(abi.encodePacked(_aoc.procuringEntityGid, _aoc.vendorGid)));
        length = Map.getByKeyBytes8ToUint(KEY, aocsByPeAndVendorGid, _aocPeVendorGid, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, aocsByPeAndVendorGid, _aocPeVendorGid, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, aocsByPeAndVendorGid, _aocPeVendorGid, abi.encodePacked(length), _value);
        


    }

}