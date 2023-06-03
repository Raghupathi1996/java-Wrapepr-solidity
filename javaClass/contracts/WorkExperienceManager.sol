pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./VendorManager.sol";
import "./AwardOfContractManager.sol";
import "./WorkExperienceModel.sol";
import "./ProcuringEntityManager.sol";

contract WorkExperienceManager is WorkExperienceStructs {

    address private permIntfAddress;
    address private accountManagerAddress;
    AwardOfContractManager private aocManager;
    VendorManager private vendorManager;
    WorkExperienceModel private workExperienceModel;
    ProcuringEntityManager private procuringEntityManager;

    constructor (address _permIntfAddress, address _accountManagerAddress, address _procuringEntityManager, address _vendorManager, address _aocManager, address _workExperienceModel) {
        permIntfAddress = _permIntfAddress;
        accountManagerAddress = _accountManagerAddress;
        procuringEntityManager = ProcuringEntityManager(_procuringEntityManager);
        vendorManager = VendorManager(_vendorManager);
        aocManager = AwardOfContractManager(_aocManager);
        workExperienceModel = WorkExperienceModel(_workExperienceModel);
    }

    modifier AocIdExists(bytes8 _uid){
        require(aocManager.isUidExists(_uid), "Award Of Contract Id not exists");
        _;
    }

    modifier uidExists(bytes8 _uid){
        require(workExperienceModel.getWorkExperienceIndex(_uid)>0, "Work Experience UID not exists");
        _;
    }

    modifier AocProcuringEntityGidMatch(bytes8 _uid, string memory _procuringEntityGid){
        require(aocManager.isProcuringEntityGidForAocUid(_uid, _procuringEntityGid), "Procuring entity GID not valid for given AOC");
        _;
    }

    modifier ValidateSenderAccount(string memory _peGid) {
        (bool success, bytes memory data) = accountManagerAddress.call(
            abi.encodeWithSignature(
                "getAccountOrgRole(address)",
                msg.sender
            )
        );
        (string memory senderOrgId,) = abi.decode(data,(string,string));
        string memory orgIdEgp = procuringEntityManager.getProcuringEntityOrgIdByGid(_peGid);
        if(keccak256(abi.encodePacked(senderOrgId))!=keccak256(abi.encodePacked(orgIdEgp))){
            (bool successAdmin, bytes memory dataAdmin) = permIntfAddress.call(
                abi.encodeWithSignature("isNetworkAdmin(address)", msg.sender)
            );
            require(successAdmin, "Permissions call failed");
            require(abi.decode(dataAdmin,(bool)), "Sender not authorized to add Work Experience");
        }
        _;
    }

    event WorkExperienceAdded(
        bytes8 _weUid,
        string _aocReferenceNumber,
        string _egpSystemId,
        string _peGid,
        string _peName
    );

    function addWorkExperience(WorkExperience memory _workEx) public
    AocIdExists(_workEx.awardOfContractId)
    AocProcuringEntityGidMatch(_workEx.awardOfContractId, _workEx.procuringEntityGid)
    ValidateSenderAccount(_workEx.procuringEntityGid)
    {
        uint id = workExperienceModel.getWorkExperienceListLength();
        bytes8 uid = _generateUID(_workEx);
        require(workExperienceModel.getWorkExperienceIndex(uid)==0, "Work Experience already added");
        _workEx.uid = uid;
        workExperienceModel.pushWorkExperience(_workEx);
        workExperienceModel.setWorkExperienceIndex(uid, id+1);
        string memory _getTenderRef = aocManager.getAocTenderRefNo(_workEx.awardOfContractId);
        string memory _vendorGid = aocManager.getAocVendorGID(_workEx.awardOfContractId);
        workExperienceModel.addAocWorkExperienceIndex(_workEx, id, _getTenderRef, _vendorGid);
        emit WorkExperienceAdded(
            uid, 
            workExperienceModel.getWorkExperienceAwardReference(id),
            workExperienceModel.getWorkExperienceEgpSystemId(id),
            workExperienceModel.getWorkExperienceProcuringEntityGid(id),
            workExperienceModel.getWorkExperienceProcuringEntityName(id)
        );
    }

    function getAllWorkExperience(uint _toExcluded, uint _count) public view
    returns(WorkExperience[] memory _workEx, uint fromIncluded_, uint length_) {
        (_workEx,fromIncluded_, length_) = workExperienceModel.getAllWorkExperience(_toExcluded, _count);
    }

    function getWorkExperience(bytes8 _uid) public view 
    uidExists(_uid)
    returns(WorkExperience memory workExperience){
        workExperience = workExperienceModel.getWorkExperienceByIndex(_getIndex(_uid));
    }

    
    /** @dev Listing out the Work Experiences against the Aoc Id.
      * @param _aocId unique id value of Aoc.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocWorkExperiences List of Work Experiences against the Aoc Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the banks GID.
      */
    function getAocWorkExperienceListIndices(bytes8 _aocId, uint _toExcluded, uint _count) public view 
    returns(WorkExperience[] memory _aocWorkExperiences, uint fromIncluded_, uint length_) {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = workExperienceModel.getAocWorkExperienceIndices(_aocId, _toExcluded, _count);
        _aocWorkExperiences = new WorkExperience[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _aocWorkExperiences[i] = workExperienceModel.getWorkExperienceByIndex(indexList[i]);
        }
    }

    
    /** @dev Listing out the Work Experiences against the PE GID.
      * @param _peGid unique id value of PE.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _peWorkExperiences List of Work Experiences against the PE GID.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE GID.
      */
    function getPEWorkExperienceListIndices(string memory _peGid, uint _toExcluded, uint _count) public view 
    returns(WorkExperience[] memory _peWorkExperiences, uint fromIncluded_, uint length_) {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = workExperienceModel.getPEWorkExperienceIndices(_peGid, _toExcluded, _count);
        _peWorkExperiences = new WorkExperience[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _peWorkExperiences[i] = workExperienceModel.getWorkExperienceByIndex(indexList[i]);
        }
    }

    
    /** @dev Listing out the Work Experiences against the EgpSystem Id.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _orgIDWorkExperiences List of Work Experiences against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getWeIndicesListByOrgId(string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns(WorkExperience[] memory _orgIDWorkExperiences, uint fromIncluded_, uint length_)  {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = workExperienceModel.getWeIndicesByOrgId(_egpSystemId, _toExcluded, _count);
        _orgIDWorkExperiences = new WorkExperience[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _orgIDWorkExperiences[i] = workExperienceModel.getWorkExperienceByIndex(indexList[i]);
        }

    }

    
    /** @dev Listing out the Work Experiences against the Tender Reference and EgpSystem Id.
      * @param _tenderReference Tender reference.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _workExperiencebyTenderRefAndOrgId List of Work Experiences against the Tender Reference and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Tender Reference and EgpSystem Id.
      */
    function getWorkExperienceListbyTenderRefAndOrgId(string memory _tenderReference, string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns(WorkExperience[] memory _workExperiencebyTenderRefAndOrgId, uint fromIncluded_, uint length_)  {
        bytes8 _workExperienceTenderRefOrgId = bytes8(keccak256(abi.encodePacked(_tenderReference, _egpSystemId)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = workExperienceModel.getWorkExperiencebyTenderRefAndOrgId(_workExperienceTenderRefOrgId, _toExcluded, _count);
        _workExperiencebyTenderRefAndOrgId = new WorkExperience[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _workExperiencebyTenderRefAndOrgId[i] = workExperienceModel.getWorkExperienceByIndex(indexList[i]);
        }

    }    

    
    /** @dev Listing out the Work Experiences against the Vendor Gid and EgpSystem Id.
      * @param _vendorGid GID of the vendor.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _workExperiencebyVendorAndOrgId List of Work Experiences against the Vendor Gid and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Vendor Gid and EgpSystem Id.
      */
    function getWorkExperienceListbyVendorAndOrgId(string memory _vendorGid, string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns(WorkExperience[] memory _workExperiencebyVendorAndOrgId, uint fromIncluded_, uint length_)  {
        bytes8 _workExperienceVendorOrgId = bytes8(keccak256(abi.encodePacked(_vendorGid, _egpSystemId)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = workExperienceModel.getWorkExperiencebyVendorAndOrgId(_workExperienceVendorOrgId, _toExcluded, _count);
        _workExperiencebyVendorAndOrgId = new WorkExperience[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _workExperiencebyVendorAndOrgId[i] = workExperienceModel.getWorkExperienceByIndex(indexList[i]);
        }

    }  

    
    /** @dev Listing out the Work Experiences against the PE GID and Vendor Gid.
      * @param _procuringEntityGid GID assigned to Procuring Entity.
      * @param _vendorGid GID of the vendor.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _workExperiencebyPEAndVendorGid List of Work Experiences against the PE GID and Vendor Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the  PE GID and Vendor Gid.
      */
    function getWorkExperiencebyPEAndVendorGid(string memory _procuringEntityGid, string memory _vendorGid, uint _toExcluded, uint _count) public view 
    returns(WorkExperience[] memory _workExperiencebyPEAndVendorGid, uint fromIncluded_, uint length_)  {
        bytes8 _workExperiencePEVendorGid = bytes8(keccak256(abi.encodePacked(_procuringEntityGid, _vendorGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = workExperienceModel.getWorkExperiencebyPEAndVendorGid(_workExperiencePEVendorGid, _toExcluded, _count);
        _workExperiencebyPEAndVendorGid = new WorkExperience[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _workExperiencebyPEAndVendorGid[i] = workExperienceModel.getWorkExperienceByIndex(indexList[i]);
        }


    }    

    function getWorkExperiencesForAwardOfContract(bytes8 _aocId, uint _toExcluded, uint _count) public view 
    AocIdExists(_aocId)
    returns(WorkExperience [] memory workExperiences_, uint fromIncluded_, uint length_){
        uint [] memory ids;
        (ids, fromIncluded_, length_) = workExperienceModel.getAocWorkExperienceIndices(_aocId, _toExcluded, _count);
        workExperiences_ = new WorkExperience[](ids.length);
        for(uint i=0;i<ids.length;i++) {
            workExperiences_[i] = workExperienceModel.getWorkExperienceByIndex(ids[i]);
        }
    }

    function getWorkExperienceForPE(string memory _procuringEntityGid, uint _toExcluded, uint _count) public view 
    returns(WorkExperience [] memory workExperiences_, uint fromIncluded_, uint length_){
        uint [] memory ids;
        (ids, fromIncluded_, length_) = workExperienceModel.getPEWorkExperienceIndices(_procuringEntityGid, _toExcluded, _count);
        workExperiences_ = new WorkExperience[](ids.length);
        for(uint i=0;i<ids.length;i++) {
            workExperiences_[i] = workExperienceModel.getWorkExperienceByIndex(ids[i]);
        }        
    }

    function getWorkExperiencesAocVendorGID(bytes8 _uid) public view returns(string memory){
        return aocManager.getAocVendorGID(_uid);
    }

    function isUidExists(bytes8 _uid) external view returns(bool){
        return (workExperienceModel.getWorkExperienceIndex(_uid)>0);
    }

    function _getIndex(bytes8 _uid) private view returns (uint){
        return workExperienceModel.getWorkExperienceIndex(_uid)-1;
    }

    function _generateUID(WorkExperience memory _workEx) private pure returns (bytes8){
        return bytes8(keccak256(abi.encodePacked(_workEx.awardReference, _workEx.workExperienceCertificateIssuanceDate,
            _workEx.procuringEntityRepresentativeName, _workEx.procuringEntityRepresentativeDesignation, _workEx.awardOfContractId)));
    }

    function _getVendorGid(bytes8 _aocUid) private view returns (string memory){
        return aocManager.getAwardOfContract(_aocUid).vendorGid;
    }

}