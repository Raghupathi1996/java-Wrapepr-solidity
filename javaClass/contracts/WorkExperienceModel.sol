pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract WorkExperienceStructs {

    uint16 constant internal __VERSION__ = 1;

    enum WorkStatus {UNASSIGNED,ONGOING,COMPLETED,CANCELLED,SUSPENDED}
    enum SupplierRating {UNASSIGNED,ONE,TWO,THREE,FOUR,FIVE}

    struct WorkExperience {
        bytes8 uid;
        string awardReference;
        uint workExperienceCertificateIssuanceDate;
        string contractCompletedValue;
        WorkStatus workStatus;
        string remarks;
        SupplierRating supplierRating;
        string workExperienceFileHash;
        string egpSystemId;
        string procuringEntityGid;
        string procuringEntityName;
        string procuringEntityRepresentativeName;
        string procuringEntityRepresentativeDesignation;
        string subject;
        bytes8 awardOfContractId;
        uint16 version;
    }
    string constant internal propKeyUid = "uid";
    string constant internal propKeyAwardReference = "awardReference";
    string constant internal propKeyWorkExperienceCertificateIssuanceDate = "workExperienceCertificateIssuanceDate";
    string constant internal propKeyContractCompletedValue = "contractCompletedValue";
    string constant internal propKeyWorkStatus = "workStatus";
    string constant internal propKeyRemarks = "remarks";
    string constant internal propKeySupplierRating = "supplierRating";
    string constant internal propKeyWorkExperienceFileHash = "workExperienceFileHash";
    string constant internal propKeyWorkExperienceEgpSystemId = "egpSystemId";
    string constant internal propKeyProcuringEntityGid = "procuringEntityGid";
    string constant internal propKeyProcuringEntityName = "procuringEntityName";
    string constant internal propKeyProcuringEntityRepresentativeName = "procuringEntityRepresentativeName";
    string constant internal propKeyProcuringEntityRepresentativeDesignation = "procuringEntityRepresentativeDesignation";
    string constant internal propKeySubject = "subject";
    string constant internal propKeyAwardOfContractId = "awardOfContractId";
    string constant internal propKeyVersion = "version";
}

contract WorkExperienceModel is WorkExperienceStructs {
    
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


    string constant internal KEY = "WORK_EXPERIENCE_MANAGER";
    string constant internal propLength = "__length";
    string constant internal workExperienceList = "list__workExperienceList";
    string constant internal workExperienceIndex = "map__workExperienceIndex";
    string constant internal aocWorkExps = "map__aocWorkExperiences";
    string constant internal peWorkExps = "map__peWorkExperiences";
    string constant internal orgIDWorkExps = "map__orgIDWorkExperiences";
    string constant internal vendorWorkExps = "map__vendorWorkExperiences";
    string constant public workExperiencebyTenderRefAndOrgId = "map__workExperiencebyTenderRefAndOrgId";
    string constant internal workExperiencebyVendorAndOrgId = "map__workExperiencebyVendorAndOrgId";
    string constant internal workExperiencebyPEAndVendorGid = "map__workExperiencebyPEAndVendorGid";
    


    modifier onlyWorkExManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validWorkExperienceListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, workExperienceList);
        require(_index < length, "Index Invalid");
        _;
    }

    // ------------- GETTERS ------------- //

    function getWorkExperienceListLength() public view returns (uint256) {
        return List.getLength(KEY, workExperienceList);
    }

    function getWorkExperienceByIndex(uint256 _index)
        public
        view
        validWorkExperienceListIndex(_index)
        returns (WorkExperience memory workExperience_)
    {
        workExperience_.uid = getWorkExperienceUid(_index);
        workExperience_.awardReference = getWorkExperienceAwardReference(_index);
        workExperience_.workExperienceCertificateIssuanceDate = getWorkExperienceWorkExperienceCertificateIssuanceDate(_index);
        workExperience_.contractCompletedValue = getWorkExperienceContractCompletedValue(_index);
        workExperience_.workStatus = getWorkExperienceWorkStatus(_index);
        workExperience_.remarks = getWorkExperienceRemarks(_index);
        workExperience_.supplierRating = SupplierRating(getWorkExperienceSupplierRating(_index));
        workExperience_.workExperienceFileHash = getWorkExperienceWorkExperienceFileHash(_index);
        workExperience_.egpSystemId = getWorkExperienceEgpSystemId(_index);
        workExperience_.procuringEntityGid = getWorkExperienceProcuringEntityGid(_index);
        workExperience_.procuringEntityName = getWorkExperienceProcuringEntityName(_index);
        workExperience_.procuringEntityRepresentativeName = getWorkExperienceProcuringEntityRepresentativeName(_index);
        workExperience_.procuringEntityRepresentativeDesignation = getWorkExperienceProcuringEntityRepresentativeDesignation(_index);
        workExperience_.subject = getWorkExperienceSubject(_index);
        workExperience_.awardOfContractId = getWorkExperienceAwardOfContractId(_index);
        workExperience_.version = getWorkExperienceVersion(_index);
    }

    function getAllWorkExperience(uint _toExcluded, uint _count) public view 
    returns (WorkExperience[] memory _workExperience, uint fromIncluded_, uint length_) {
        uint length = getWorkExperienceListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _workExperience = new WorkExperience[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _workExperience[_workExperience.length-itr-1] = getWorkExperienceByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getWorkExperienceUid(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, workExperienceList, _index, propKeyUid);
    }

    function getWorkExperienceAwardReference(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyAwardReference);
    }

    function getWorkExperienceWorkExperienceCertificateIssuanceDate(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, workExperienceList, _index, propKeyWorkExperienceCertificateIssuanceDate);
    }

    function getWorkExperienceContractCompletedValue(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyContractCompletedValue);
    }

    function getWorkExperienceWorkStatus(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(WorkStatus) {
        return WorkStatus(List.getPropUint8(KEY, workExperienceList, _index, propKeyWorkStatus));
    }

    function getWorkExperienceRemarks(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyRemarks);
    }

    function getWorkExperienceSupplierRating(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(uint8) {
        return List.getPropUint8(KEY, workExperienceList, _index, propKeySupplierRating);
    }

    function getWorkExperienceWorkExperienceFileHash(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyWorkExperienceFileHash);
    }

    function getWorkExperienceEgpSystemId(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyWorkExperienceEgpSystemId);
    }

    function getWorkExperienceProcuringEntityGid(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyProcuringEntityGid);
    }

    function getWorkExperienceProcuringEntityName(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyProcuringEntityName);
    }

    function getWorkExperienceProcuringEntityRepresentativeName(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyProcuringEntityRepresentativeName);
    }

    function getWorkExperienceProcuringEntityRepresentativeDesignation(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeyProcuringEntityRepresentativeDesignation);
    }

    function getWorkExperienceSubject(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, workExperienceList, _index, propKeySubject);
    }

    function getWorkExperienceAwardOfContractId(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, workExperienceList, _index, propKeyAwardOfContractId);
    }

    function getWorkExperienceVersion(uint256 _index) public view 
    validWorkExperienceListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, workExperienceList, _index, propKeyVersion);
    }

    function getWorkExperienceIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, workExperienceIndex, _uid);
    }

    
    /** @dev Listing out the Work Experiences against the Aoc Id.
      * @param _aocId unique id value of Aoc.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocWorkExperiences List of Work Experiences against the Aoc Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the banks GID.
      */
    function getAocWorkExperienceIndices(bytes8 _aocId, uint _toExcluded, uint _count) public view returns(uint[] memory _aocWorkExperiences, uint fromIncluded_, uint length_) {
        uint length = Map.getByKeyBytes8ToUint(KEY, aocWorkExps, _aocId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _aocWorkExperiences = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _aocWorkExperiences[_aocWorkExperiences.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, aocWorkExps, _aocId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Work Experiences against the PE GID.
      * @param _peGid unique id value of PE.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _peWorkExperiences List of Work Experiences against the PE GID.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE GID.
      */
    function getPEWorkExperienceIndices(string memory _peGid, uint _toExcluded, uint _count) public view returns(uint[] memory _peWorkExperiences, uint fromIncluded_, uint length_) {
        uint length = Map.getByKeyStringToUint(KEY, peWorkExps, _peGid, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _peWorkExperiences = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _peWorkExperiences[_peWorkExperiences.length-itr-1] = Map.getByKeyStringToUint(KEY, peWorkExps, _peGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }


    /** @dev Listing out the Work Experiences against the EgpSystem Id.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _orgIDWorkExperiences List of Work Experiences against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getWeIndicesByOrgId(string memory _egpSystemId, uint _toExcluded, uint _count) public view returns(uint[] memory _orgIDWorkExperiences, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, orgIDWorkExps, _egpSystemId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _orgIDWorkExperiences = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _orgIDWorkExperiences[_orgIDWorkExperiences.length-itr-1] = Map.getByKeyStringToUint(KEY, orgIDWorkExps, _egpSystemId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Work Experiences against the Tender Reference and EgpSystem Id.
      * @param _workExperienceTenderRefOrgId Tender reference and e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _workExperiencebyTenderRefAndOrgId List of Work Experiences against the Tender Reference and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Tender Reference and EgpSystem Id.
      */
    function getWorkExperiencebyTenderRefAndOrgId(bytes8 _workExperienceTenderRefOrgId, uint _toExcluded, uint _count) public view returns(uint[] memory _workExperiencebyTenderRefAndOrgId, uint fromIncluded_, uint length_)  {
        //bytes8 _workExperienceTenderRefOrgId = bytes8(keccak256(abi.encodePacked(_getTenderRef, _getEgpSystemId)));
        uint length = Map.getByKeyBytes8ToUint(KEY, workExperiencebyTenderRefAndOrgId, _workExperienceTenderRefOrgId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _workExperiencebyTenderRefAndOrgId = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _workExperiencebyTenderRefAndOrgId[_workExperiencebyTenderRefAndOrgId.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, workExperiencebyTenderRefAndOrgId, _workExperienceTenderRefOrgId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Work Experiences against the Vendor Gid and EgpSystem Id.
      * @param _workExperienceVendorOrgId GID of the vendor and e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _workExperiencebyVendorAndOrgId List of Work Experiences against the Vendor Gid and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Vendor Gid and EgpSystem Id.
      */
    function getWorkExperiencebyVendorAndOrgId(bytes8 _workExperienceVendorOrgId, uint _toExcluded, uint _count) public view returns(uint[] memory _workExperiencebyVendorAndOrgId, uint fromIncluded_, uint length_)  {
        //bytes8 _workExperienceVendorOrgId = bytes8(keccak256(abi.encodePacked(_vendorGid, _getEgpSystemId)));
        uint length = Map.getByKeyBytes8ToUint(KEY, workExperiencebyVendorAndOrgId, _workExperienceVendorOrgId, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _workExperiencebyVendorAndOrgId = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _workExperiencebyVendorAndOrgId[_workExperiencebyVendorAndOrgId.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, workExperiencebyVendorAndOrgId, _workExperienceVendorOrgId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Work Experiences against the PE GID and Vendor Gid.
      * @param _workExperiencePEVendorGid GID assigned to Procuring Entity and GID of the vendor.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _workExperiencebyPEAndVendorGid List of Work Experiences against the PE GID and Vendor Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the  PE GID and Vendor Gid.
      */
    function getWorkExperiencebyPEAndVendorGid(bytes8 _workExperiencePEVendorGid, uint _toExcluded, uint _count) public view returns(uint[] memory _workExperiencebyPEAndVendorGid, uint fromIncluded_, uint length_)  {
        //bytes8 _workExperiencePEVendorGid = bytes8(keccak256(abi.encodePacked(_procuringEntityGid, _vendorGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, workExperiencebyPEAndVendorGid, _workExperiencePEVendorGid, abi.encodePacked(propLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _workExperiencebyPEAndVendorGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _workExperiencebyPEAndVendorGid[_workExperiencebyPEAndVendorGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, workExperiencebyPEAndVendorGid, _workExperiencePEVendorGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    


    // ------------- SETTERS ------------- //

    function setWorkExperienceIndex(bytes8 _uid, uint _value) public 
    onlyWorkExManager {
        Map.setBytes8ToUint(KEY, workExperienceIndex, _uid, _value);
    }

    function incWorkExperienceListLength() public 
    onlyWorkExManager {
        List.incLength(KEY, workExperienceList);
    }

    function setWorkExperienceUid(uint256 _index, bytes8 _value) public 
    onlyWorkExManager {
        List.setPropBytes8(KEY, workExperienceList, _index, propKeyUid, _value);
    }

    function setWorkExperienceAwardReference(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyAwardReference, _value);
    }

    function setWorkExperienceWorkExperienceCertificateIssuanceDate(uint256 _index, uint _value) public 
    onlyWorkExManager {
        List.setPropUint(KEY, workExperienceList, _index, propKeyWorkExperienceCertificateIssuanceDate, _value);
    }

    function setWorkExperienceContractCompletedValue(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyContractCompletedValue, _value);
    }

    function setWorkExperienceWorkStatus(uint256 _index, WorkStatus _value) public 
    onlyWorkExManager {
        List.setPropUint8(KEY, workExperienceList, _index, propKeyWorkStatus, uint8(_value));
    }

    function setWorkExperienceRemarks(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyRemarks, _value);
    }

    function setWorkExperienceSupplierRating(uint256 _index, uint8 _value) public 
    onlyWorkExManager {
        List.setPropUint8(KEY, workExperienceList, _index, propKeySupplierRating, _value);
    }

    function setWorkExperienceWorkExperienceFileHash(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyWorkExperienceFileHash, _value);
    }

    function setWorkExperienceEgpSystemId(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyWorkExperienceEgpSystemId, _value);
    }

    function setWorkExperienceProcuringEntityGid(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyProcuringEntityGid, _value);
    }


    function setWorkExperienceProcuringEntityName(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyProcuringEntityName, _value);
    }

    function setWorkExperienceProcuringEntityRepresentativeName(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyProcuringEntityRepresentativeName, _value);
    }

    function setWorkExperienceProcuringEntityRepresentativeDesignation(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeyProcuringEntityRepresentativeDesignation, _value);
    }

    function setWorkExperienceSubject(uint256 _index, string memory _value) public 
    onlyWorkExManager {
        List.setPropString(KEY, workExperienceList, _index, propKeySubject, _value);
    }

    function setWorkExperienceAwardOfContractId(uint256 _index, bytes8 _value) public 
    onlyWorkExManager {
        List.setPropBytes8(KEY, workExperienceList, _index, propKeyAwardOfContractId, _value);
    }

    function setWorkExperienceVersion(uint256 _index) public 
    onlyWorkExManager {
        List.setPropUint16(KEY, workExperienceList, _index, propKeyVersion, __VERSION__);
    }

    function pushWorkExperience(WorkExperience memory _workExperience) public 
    onlyWorkExManager 
    {
        uint index = getWorkExperienceListLength();
        incWorkExperienceListLength();
        setWorkExperienceUid(index,_workExperience.uid);
        setWorkExperienceAwardReference(index,_workExperience.awardReference);
        setWorkExperienceWorkExperienceCertificateIssuanceDate(index,_workExperience.workExperienceCertificateIssuanceDate);
        setWorkExperienceContractCompletedValue(index,_workExperience.contractCompletedValue);
        setWorkExperienceWorkStatus(index,_workExperience.workStatus);
        setWorkExperienceRemarks(index,_workExperience.remarks);
        setWorkExperienceSupplierRating(index,uint8(_workExperience.supplierRating));
        setWorkExperienceWorkExperienceFileHash(index,_workExperience.workExperienceFileHash);
        setWorkExperienceEgpSystemId(index, _workExperience.egpSystemId);
        setWorkExperienceProcuringEntityGid(index, _workExperience.procuringEntityGid);
        setWorkExperienceProcuringEntityName(index, _workExperience.procuringEntityName);
        setWorkExperienceProcuringEntityRepresentativeName(index, _workExperience.procuringEntityRepresentativeName);
        setWorkExperienceProcuringEntityRepresentativeDesignation(index, _workExperience.procuringEntityRepresentativeDesignation);
        setWorkExperienceSubject(index, _workExperience.subject);
        setWorkExperienceAwardOfContractId(index,_workExperience.awardOfContractId);   
        setWorkExperienceVersion(index);
    }

    
    /** @dev Setting the Work Experiences against the Aoc Id, Setting the Work Experiences against the PE GID, Setting the Work Experiences against the EgpSystem Id,  Setting the Work Experiences against the Tender Reference and EgpSystem Id, Setting the Work Experiences against the Vendor Gid and EgpSystem Id, Setting the Work Experiences against the PE GID and Vendor Gid.
      * @param _workExperience Work Experience details.
      * @param _value Index of Work Experience.
      * @param _getTenderRef Tender Reference Number. 
      * @param _vendorGid Unique GId for Vendor.
      */
    function addAocWorkExperienceIndex(WorkExperience memory _workExperience, uint _value, string memory _getTenderRef, string memory _vendorGid) public 
    onlyWorkExManager
    {
        // set function for list of WE against the aocID.
        uint length = Map.getByKeyBytes8ToUint(KEY, aocWorkExps, _workExperience.awardOfContractId, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, aocWorkExps, _workExperience.awardOfContractId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, aocWorkExps, _workExperience.awardOfContractId, abi.encodePacked(length), _value);
        
        // set function for list of WE against the procuringEntityGid.
        length = Map.getByKeyStringToUint(KEY, peWorkExps, _workExperience.procuringEntityGid, abi.encodePacked(propLength));
        Map.setByKeyStringToUint(KEY, peWorkExps, _workExperience.procuringEntityGid, abi.encodePacked(propLength), 1+length);
        Map.setByKeyStringToUint(KEY, peWorkExps, _workExperience.procuringEntityGid, abi.encodePacked(length), _value);
        
        // set function for list of WE against the egpSystemId.
        length = Map.getByKeyStringToUint(KEY, orgIDWorkExps, _workExperience.egpSystemId, abi.encodePacked(propLength));
        Map.setByKeyStringToUint(KEY, orgIDWorkExps, _workExperience.egpSystemId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyStringToUint(KEY, orgIDWorkExps, _workExperience.egpSystemId, abi.encodePacked(length), _value);

        //set WorkExperiencebyTenderRefAndOrgId
        bytes8 _workExperienceTenderRefOrgId = bytes8(keccak256(abi.encodePacked(_getTenderRef, _workExperience.egpSystemId)));
        length = Map.getByKeyBytes8ToUint(KEY, workExperiencebyTenderRefAndOrgId, _workExperienceTenderRefOrgId, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, workExperiencebyTenderRefAndOrgId, _workExperienceTenderRefOrgId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, workExperiencebyTenderRefAndOrgId, _workExperienceTenderRefOrgId, abi.encodePacked(length), _value);

        //set WorkExperiencebyVendorAndOrgId
        bytes8 _workExperienceVendorOrgId = bytes8(keccak256(abi.encodePacked(_vendorGid, _workExperience.egpSystemId)));
        length = Map.getByKeyBytes8ToUint(KEY, workExperiencebyVendorAndOrgId, _workExperienceVendorOrgId, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, workExperiencebyVendorAndOrgId, _workExperienceVendorOrgId, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, workExperiencebyVendorAndOrgId, _workExperienceVendorOrgId, abi.encodePacked(length), _value);

        //set WorkExperiencebyPEAndVendorGid
        bytes8 _workExperiencePEVendorGid = bytes8(keccak256(abi.encodePacked(_workExperience.procuringEntityGid, _vendorGid)));
        length = Map.getByKeyBytes8ToUint(KEY, workExperiencebyPEAndVendorGid, _workExperiencePEVendorGid, abi.encodePacked(propLength));
        Map.setByKeyBytes8ToUint(KEY, workExperiencebyPEAndVendorGid, _workExperiencePEVendorGid, abi.encodePacked(propLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, workExperiencebyPEAndVendorGid, _workExperiencePEVendorGid, abi.encodePacked(length), _value);

        
    }
    
   
}

