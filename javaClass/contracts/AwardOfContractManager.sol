pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./VendorManager.sol";
import "./AwardOfContractModel.sol";
import "./ProcuringEntityManager.sol";

contract AwardOfContractManager is AwardOfContractStructs {

    VendorManager private vendorManager;
    ProcuringEntityManager private procuringEntityManager;
    address private permInterfaceAddress;
    AwardOfContractModel private aocModel;

    constructor (address _permIntf, address _vendorManager, address _procEntityManager, address _aocModel) {
        permInterfaceAddress = _permIntf;
        vendorManager = VendorManager(_vendorManager);
        procuringEntityManager = ProcuringEntityManager(_procEntityManager);
        aocModel = AwardOfContractModel(_aocModel);
    }

     modifier VendorGidExistsAndActive(string memory _gid){
        require(vendorManager.isGidActive(_gid), "Vendor GID not active");
        _;
    }

    modifier ProcEntityGidExists(string memory _gid){
        require(procuringEntityManager.isGidExists(_gid), "Procuring Entity GID not exists");
        _;
    }

    modifier uidExists(bytes8 _uid){
        require(aocModel.getAocIndex(_uid)>0, "Award Of Contract Id not exists");
        _;
    }

    modifier validateOrgAndAccount(address _account, string memory _orgId) {
        (bool success, bytes memory data) = permInterfaceAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                _account,
                _orgId
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account does not exists or exists but doesn't belong to passed orgId"
        );
        _;
    }


    modifier TenderReferenceValidation (AOC memory _aoc) {
        require( keccak256(abi.encodePacked(_aoc.tenderReference)) == keccak256(abi.encodePacked(aocModel.getAocTenderReference(_getIndex(_aoc.uid)))), "Tender reference number doesn't match");
        require(aocModel.getAocStatus(_getIndex(_aoc.uid)) == AOCStatus.EvaluationComplete, "The Status of the AOC cannot be changed");
        require(_aoc.aocStatus == AOCStatus.Awarded, "Invalid status request");
        _;
    }

    modifier StatusValidation (bytes8 _uid) {
        require(aocModel.getAocStatus(_getIndex(_uid)) == AOCStatus.EvaluationComplete, "The Status of the AOC cannot be changed");
        _;
    }

    event AwardOfContractPublished(bytes8 _aocUid, string _awardOfContractReferenceNumber, string _tenderReferenceNumber);

    event AwardedStatus(bytes8 _aocUid, AOCStatus _status);

    function publishAwardOfContract(AOC memory _aoc) public 
    validateOrgAndAccount(msg.sender, _aoc.orgId)
    VendorGidExistsAndActive(_aoc.vendorGid)
    ProcEntityGidExists(_aoc.procuringEntityGid)
    {
        require(_aoc.aocStatus != AOCStatus.Cancelled, "The initial copy of the AOC status cannot be set cancelled");
        uint id = aocModel.getAocListLength();
        bytes8 uid = _generateUID(_aoc);
        bytes8 uidAwardRefOrgId = bytes8(keccak256(abi.encodePacked(_aoc.awardReference, _aoc.orgId)));
        require(aocModel.getAocIndex(uid)==0, "AOC already published");
        _aoc.uid = uid;
        aocModel.setAocIndex(uid, 1+id);
        aocModel.addAocIndexByAwardRefOrgId(uidAwardRefOrgId, id);
        aocModel.incAocListLength();
        aocModel.addAwardOfContract(id, _aoc);
        aocModel.addVendorAocIndex(_aoc.vendorGid, id);
        aocModel.setAocIndices(_aoc, id);
        emit AwardOfContractPublished(uid,_aoc.awardReference,_aoc.tenderReference);
    }


    function getAllAoc(uint _toExcluded, uint _count) external view 
    returns(AOC[] memory _aoc, uint fromIncluded_, uint length_) {
        (_aoc, fromIncluded_, length_) = aocModel.getAllAoc(_toExcluded, _count);
    }


    /** @dev Listing out the Aocs against the PE Gid.
      * @param _procuringEntityGid GID assigned to Procuring Entity.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByPeGid List of Aocs against the PE Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE Gid.
      */
    function getAocListByPeGid(string memory _procuringEntityGid, uint _toExcluded, uint _count) public view
    returns (AOC[] memory _aocsByPeGid, uint fromIncluded_, uint length_) {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = aocModel.getAocsByPeGid(_procuringEntityGid, _toExcluded, _count);
        _aocsByPeGid = new AOC[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _aocsByPeGid[i] = aocModel.getAocByIndex(indexList[i]);
        }
    }
    

    /** @dev Listing out the Aocs against the EgpSystem Id.
      * @param _orgId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByOrgId List of Aocs against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getAocListByOrgId(string memory _orgId, uint _toExcluded, uint _count) public view
    returns(AOC[] memory _aocsByOrgId, uint fromIncluded_, uint length_)  {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = aocModel.getAocsByOrgId(_orgId, _toExcluded, _count);
        _aocsByOrgId = new AOC[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _aocsByOrgId[i] = aocModel.getAocByIndex(indexList[i]);
        }
    }

    
    
    /** @dev Listing out the Aocs against the Vendor Gid and EgpSystem Id.
      * @param _vendorGid GID of the vendor.
      * @param _orgId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByVendorGidAndOrgId List of Aocs against the Vendor Gid and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Vendor Gid and EgpSystem Id.
      */
    function getAocListByVendorGidOrgId(string memory _vendorGid, string memory _orgId, uint _toExcluded, uint _count) public view 
    returns(AOC[] memory _aocsByVendorGidAndOrgId, uint fromIncluded_, uint length_)  {
        bytes8 _aocVendorOrgId = bytes8(keccak256(abi.encodePacked(_vendorGid, _orgId)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = aocModel.getAocsByVendorGidAndOrgId(_aocVendorOrgId, _toExcluded, _count);
        _aocsByVendorGidAndOrgId = new AOC[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _aocsByVendorGidAndOrgId[i] = aocModel.getAocByIndex(indexList[i]);
        }

    }

    
    /** @dev Listing out the Aocs against the Tender Reference and EgpSystem Id.
      * @param _tenderReference Tender Reference.
      * @param _orgId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByTenderRefAndOrgId List of Aocs against the Tender Reference and EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Tender Reference and EgpSystem Id.
      */
    function getAocListByTenderRefAndOrgId(string memory _tenderReference, string memory _orgId, uint _toExcluded, uint _count) public view 
    returns(AOC[] memory _aocsByTenderRefAndOrgId, uint fromIncluded_, uint length_)  {
        bytes8 _aocTenderRefOrgId = bytes8(keccak256(abi.encodePacked(_tenderReference, _orgId)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = aocModel.getAocsByTenderRefAndOrgId(_aocTenderRefOrgId, _toExcluded, _count);
        _aocsByTenderRefAndOrgId = new AOC[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _aocsByTenderRefAndOrgId[i] = aocModel.getAocByIndex(indexList[i]);
        }

    }    

    
    /** @dev Listing out the Aocs against the PE GID and Vendor Gid.
      * @param _procuringEntityGid GID assigned to Procuring Entity.
      * @param _vendorGid GID of the vendor.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _aocsByPeAndVendorGid List of Aocs against the PE GID and Vendor Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE GID and Vendor Gid.
      */
    function getAocListByPeAndVendorGid(string memory _procuringEntityGid, string memory _vendorGid, uint _toExcluded, uint _count) public view 
    returns(AOC[] memory _aocsByPeAndVendorGid, uint fromIncluded_, uint length_)  {
        bytes8 _aocPeVendorGid = bytes8(keccak256(abi.encodePacked(_procuringEntityGid, _vendorGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = aocModel.getAocsByPeAndVendorGid(_aocPeVendorGid, _toExcluded, _count);
        _aocsByPeAndVendorGid = new AOC[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _aocsByPeAndVendorGid[i] = aocModel.getAocByIndex(indexList[i]);
        }

    }    



    function updateAocStatustoAwarded(AOC memory _aoc) public
    uidExists(_aoc.uid)
    TenderReferenceValidation(_aoc)
    validateOrgAndAccount(msg.sender, aocModel.getAocOrgId(_getIndex(_aoc.uid))) 
    {  
        aocModel.awardedAocStatus(_aoc);
        emit AwardedStatus(_aoc.uid, aocModel.getAocStatus(_getIndex(_aoc.uid)));       
    }

    function updateAocStatustoCancel(bytes8 _uid) public
    uidExists(_uid)
    StatusValidation(_uid)
    validateOrgAndAccount(msg.sender, aocModel.getAocOrgId(_getIndex(_uid)))
    {
        aocModel.cancelAocStatus(_uid);
        emit AwardedStatus(_uid, aocModel.getAocStatus(_getIndex(_uid)));
    }

    function getAwardOfContract(bytes8 _uid) public view 
    uidExists(_uid)
    returns(AOC memory awardOfContract_){
        awardOfContract_ = aocModel.getAocByIndex(_getIndex(_uid));
    }

    function getAwardOfContractsForVendor(string memory _gid, uint _toExcluded, uint _count) public view 
    returns(AOC [] memory awardOfContracts_, uint fromIncluded_, uint length_){
        uint[] memory ids = _getAOCs(_gid);
        if (_toExcluded > ids.length) {
            _toExcluded = ids.length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        awardOfContracts_ = new AOC[](itr); 
        while (itr>0) {
            itr--;
            _toExcluded--;
            awardOfContracts_[awardOfContracts_.length-itr-1] = aocModel.getAocByIndex(ids[_toExcluded]);
        }
        fromIncluded_ = _toExcluded;
        length_ = ids.length;
    }

    function getAocByAwardRefOrgId(string memory _awardReference, string memory _orgId, uint _toExcluded, uint _count) public view 
    returns(AOC[] memory awardOfContracts_, uint fromIncluded_, uint length_){
        uint[] memory indexList = aocModel.getAocsIndexByAwardRefOrgId(bytes8(keccak256(abi.encodePacked(_awardReference, _orgId))));
        if (_toExcluded > indexList.length) {
            _toExcluded = indexList.length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        awardOfContracts_ = new AOC[](itr); 
        while (itr>0) {
            itr--;
            _toExcluded--;
            awardOfContracts_[awardOfContracts_.length-itr-1] = aocModel.getAocByIndex(indexList[_toExcluded]);
        }
        fromIncluded_ = _toExcluded;
        length_ = indexList.length;
    }

    function getAocVendorGID (bytes8 _uid) public view returns(string memory){
        uint256 _index = _getIndex(_uid);
        return aocModel.getAocVendorGid(_index);
    }

    function getEgpIdByAocUid (bytes8 _uid) public view returns(string memory _orgId)
    {
        uint256 _index = _getIndex(_uid);
        string memory _gid = aocModel.getAocProcEntityGid(_index);
        return procuringEntityManager.getProcuringEntityOrgIdByGid(_gid);
    }

    function isUidExists(bytes8 _uid) external view returns(bool){
        return (aocModel.getAocIndex(_uid)>0);
    }

    function isProcuringEntityGidForAocUid(bytes8 _uid, string memory _procuringEntityGid) public view returns(bool){
        return (keccak256(abi.encodePacked(getAwardOfContract(_uid).procuringEntityGid)) ==
            keccak256(abi.encodePacked(_procuringEntityGid)));
    }

    function _getAOCs(string memory _gid) internal view returns(uint [] memory) {
        uint [] memory ids = aocModel.getVendorAocIndices(_gid);
        string [] memory childrenGIDs = vendorManager.getChildrenGIDs(_gid);
        uint [] memory cIds;
        uint [] memory concatArr;
        for (uint256 i = 0; i < childrenGIDs.length; i++) {
            cIds = _getAOCs(childrenGIDs[i]);
            concatArr = new uint[](ids.length+cIds.length);
            for (uint256 k = 0; k < ids.length; k++) {
                concatArr[k] = ids[k];
            }
            for (uint256 j = 0; j < cIds.length; j++) {
                concatArr[j+ids.length] = cIds[j];
            }
            ids = concatArr;
        }
        return ids;
    }

    function _getIndex(bytes8 _uid) private view returns (uint){
        return aocModel.getAocIndex(_uid) - 1;
    }

    function _generateUID(AOC memory _aoc) private pure returns (bytes8){
        return bytes8(keccak256(abi.encodePacked(_aoc.vendorGid,_aoc.tenderReference,_aoc.awardReference,
            _aoc.title,_aoc.contractAwardValue,string(abi.encode(_aoc.lotName)),
            _aoc.awardOfContractDate,_aoc.procuringEntityGid,_aoc.orgId)));
    }

    function getAocTenderRefNo(bytes8 _uid) public view returns(string memory)
    {
        uint256 _index = _getIndex(_uid);
        return aocModel.getAocTenderReference(_index);

    }
    

}