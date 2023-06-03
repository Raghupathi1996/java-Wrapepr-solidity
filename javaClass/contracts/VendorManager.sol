pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./VendorModel.sol";
import "./UidUtils.sol";

contract VendorManager is VendorStructs {

    string constant private VENDORS_SUBORG = "VENDORS";

    address private permIntfAddress; //TODO: How to update this address if PermImplementation is updated
    address private permImplementation;
    address private accountManager;
    VendorModel private vendorModel;
    UidUtils private uidUtils;

    event VendorRegistered(string _vendorGid, string _vendorSystemName, string _vendorExternalName,
        string _egpExternalId, string _egpSystemId);
        
    event MergeRequestInitiated(string _gid1, string _gid2);
    event MergeRequestSubmitted(string _gid1, string _gid2);
    event MergeRequestApproved(string _gid1, string _gid2);
    event MergeRequestRejected(string _gid1, string _gid2);
    event MergeRequestExpired(string _gid1, string _gid2);

    event SeedRequestSubmitted(string _gid, string _egpExternalId, string _egpSystemId);
    event SeedRequestApproved(string _gid, string _egpExternalId, string _egpSystemId);
    event SeedRequestRejected(string _gid, string _egpExternalId, string _egpSystemId);
    event SeedRequestExpired(string _gid, string _egpExternalId, string _egpSystemId);
    
    constructor (address _permIntf, address _permImpl, address _accountManager, address _vendorModel, address _uidUtils) {
        permIntfAddress = _permIntf;
        permImplementation = _permImpl;
        accountManager = _accountManager;
        vendorModel = VendorModel(_vendorModel);
        uidUtils = UidUtils(_uidUtils);
    }

    modifier networkAdmin() {
        (bool success, bytes memory data) = permIntfAddress.call(
            abi.encodeWithSignature("isNetworkAdmin(address)", msg.sender)
        );
        require(abi.decode(data, (bool)), "account is not a network admin account");
        _;
    }

    modifier validateVendorsAccount(string memory _accountName) {
        (bool success, bytes memory data) = permIntfAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                _getAccountAddress(_accountName),
                string(abi.encodePacked(_getAdminOrg(),".",VENDORS_SUBORG))
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account doesn't belong to VENDORS suborg"
        );
        _;
    }

    modifier gidOwner(string memory _gid){
        (bool success, bytes memory data) = accountManager.call(
            abi.encodeWithSignature("getAccountAddress(string)", vendorModel.getVendorAccountName(_getVendorIndex(_gid)))
        );
        require(msg.sender==abi.decode(data, (address)), "Caller not GID owner");
        _;
    }

    modifier vendorExists(string memory _gid){
        require(vendorModel.getVendorIndex(_gid)>0, "Vendor not registered");
        _;
    }

    modifier gidExists(string memory _gid){
        require(vendorModel.getGidIndex(_gid)>0, "GID not registered");
        _;
    }

    modifier gidNotExists(string memory _gid){
        require(vendorModel.getGidIndex(_gid)==0, "GID already registered");
        _;
    }

    modifier gidActive(string memory _gid){
        require(vendorModel.getGidIndex(_gid)>0, "GID not registered");
        require(vendorModel.getGidActive(_getGidIndex(_gid)), "GID not active");
        _;
    }

    modifier mergeRequestActive(string memory _gid1, string memory _gid2){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        require(vendorModel.getMergeIndex(uid)>0, "Merge Request does not exist");
        uint id = _getMergeRequestIndex(uid);
        MergeRequestState state = vendorModel.getMergeRequestState(id);
        require((state==MergeRequestState.INITIATED) || (state==MergeRequestState.SUBMITTED), "Merge Request in incorrect state");
        _;
    }

    modifier mergeRequestInitiatable(string memory _gid1, string memory _gid2){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        if(vendorModel.getMergeIndex(uid)>0){
            MergeRequestState state = vendorModel.getMergeRequestState(_getMergeRequestIndex(uid));
            require((state==MergeRequestState.REJECTED||(state==MergeRequestState.EXPIRED)), "Merge Request already exists");
        }
        _;
    }

    modifier mergeRequestSubmittable(string memory _gid1, string memory _gid2){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        require(vendorModel.getMergeIndex(uid)>0, "Merge Request does not exist");
        uint id = _getMergeRequestIndex(uid);
        require(vendorModel.getMergeRequestState(id)==MergeRequestState.INITIATED, "Merge Request in incorrect state");
        _;
    }
    
    modifier mergeRequestApprovable(string memory _gid1, string memory _gid2){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        require(vendorModel.getMergeIndex(uid)>0, "Merge Request does not exist");
        uint id = _getMergeRequestIndex(uid);
        require(vendorModel.getMergeRequestState(id)==MergeRequestState.SUBMITTED, "Merge Request in incorrect state");
        _;
    }

    modifier seedRequestSubmittable(string memory _gid, string memory vendorEgpId, string memory vendorEgpOrgId){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid, vendorEgpId, vendorEgpOrgId)));
        if(vendorModel.getSeedRequestIndex(uid)>0){
            SeedRequestState state = vendorModel.getSeedRequestState(_getSeedRequestIndex(uid));
            require((state==SeedRequestState.REJECTED)||(state==SeedRequestState.EXPIRED), "Seed Request already exists");
        }
        _;
    }

    modifier seedRequestApprovable(string memory _gid, string memory vendorEgpId, string memory vendorEgpOrgId){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid, vendorEgpId, vendorEgpOrgId)));
        require(vendorModel.getSeedRequestIndex(uid)>0, "Seed Request does not exist");
        uint id = _getSeedRequestIndex(uid);
        require(vendorModel.getSeedRequestState(id)==SeedRequestState.SUBMITTED, "Seed Request in Incorrect State");
        _;
    } 

    function registerVendor(string memory _vendorName, string memory _externalId, string memory _orgId, string memory _accountName) public 
    networkAdmin
    validateVendorsAccount(_accountName) {
        require(keccak256(abi.encodePacked(getGidForVendor(_accountName)))==keccak256(abi.encodePacked('')),"GID already registered for given account name");
        string memory gid = uidUtils.bytes32ToAlphanumeric7(keccak256(abi.encodePacked(_vendorName, _externalId, _orgId, _accountName)));
        gid = uidUtils.addLuhnCheckDigit(gid);
        uint id = vendorModel.getVendorListLength();
        vendorModel.setVendorIndex(gid, 1+id);
        vendorModel.incVendorListLength();
        vendorModel.setVendorGidMap(_accountName, gid);
        vendorModel.setVendorGid(id, gid);
        vendorModel.setVendorAccountName(id, _accountName);
        vendorModel.setVendorVendorEgpName(id, _vendorName);
        vendorModel.addVendorVendorEgpId(id, _externalId);
        vendorModel.addVendorVendorEgpOrgId(id, _orgId);
        vendorModel.setVendorVersion(id);
        emit VendorRegistered(gid, _accountName, _vendorName, _externalId, _orgId);
        _registerGID(gid);
    }

    function getAllVendors(uint _toExcluded, uint _count) public view
    returns(Vendor[] memory _vendor, uint fromIncluded_, uint length_) {
        (_vendor,fromIncluded_, length_) = vendorModel.getAllVendors(_toExcluded, _count);
    }

    function getVendorByGid(string memory _gid) public view 
    vendorExists(_gid)
    returns (Vendor memory) {
        require(vendorModel.getVendorIndex(_gid)>0,"GID does not exist");
        uint id = _getVendorIndex(_gid);
        return vendorModel.getVendorByIndex(id);
    }

    function getGidForVendor(string memory _accountName) public view 
    returns(string memory) {
        return vendorModel.getVendorGidMap(_accountName);
    }
    
    function initiateGidMerge(string memory _gid1, string memory _gid2) public 
    gidActive(_gid1)
    gidActive(_gid2)
    gidOwner(_gid1) 
    mergeRequestInitiatable(_gid1, _gid2) {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        if (vendorModel.getMergeIndex(uid)>0) {
            vendorModel.setMergeRequestState(_getMergeRequestIndex(uid), MergeRequestState.INITIATED);
        } else {
            uint id = vendorModel.getMergeListLength();
            vendorModel.setMergeIndex(uid, 1+id);
            vendorModel.incMergeRequestListLength();
            vendorModel.setMergeRequestGid1(id, _gid1);
            vendorModel.setMergeRequestGid2(id, _gid2);
            vendorModel.setMergeRequestState(id, MergeRequestState.INITIATED);
            vendorModel.setMergeRequestVersion(id);
        }
        emit MergeRequestInitiated(_gid1, _gid2);
    }

    function submitGidMerge(string memory _gid1, string memory _gid2, bool _approval) public 
    gidActive(_gid1)
    gidActive(_gid2)
    gidOwner(_gid2) 
    mergeRequestSubmittable(_gid1, _gid2){
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        uint id = _getMergeRequestIndex(uid);
        if(!_approval){
            vendorModel.setMergeRequestState(id, MergeRequestState.REJECTED);
            emit MergeRequestRejected(_gid1, _gid2);
            return;
        }
        vendorModel.setMergeRequestState(id, MergeRequestState.SUBMITTED);
        emit MergeRequestSubmitted(_gid1, _gid2);
    }

    function approveGidMerge(string memory _gid1, string memory _gid2, bool _approval) public 
    mergeRequestApprovable(_gid1, _gid2)
    networkAdmin {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        uint id = _getMergeRequestIndex(uid);
        if(!_approval){
            vendorModel.setMergeRequestState(id, MergeRequestState.REJECTED);
            emit MergeRequestRejected(_gid1, _gid2);
            return;
        }
        _mergeGIDs(_gid2, _gid1);  
        vendorModel.setMergeRequestState(id, MergeRequestState.APPROVED);
        emit MergeRequestApproved(_gid1, _gid2);
    }

    function expireGidMerge(string memory _gid1, string memory _gid2) public
    mergeRequestActive(_gid1, _gid2) 
    networkAdmin {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid1, _gid2)));
        uint id = _getMergeRequestIndex(uid);
        vendorModel.setMergeRequestState(id, MergeRequestState.EXPIRED);
        emit MergeRequestExpired(_gid1, _gid2);
    }

    function getAllMergeRequests(uint _toExcluded, uint _count) public view 
    returns (MergeRequest[] memory, uint fromIncluded_, uint length_){
        return vendorModel.getAllMergeRequests(_toExcluded,_count);
    }

    function getActiveMergeRequests(uint _toExcluded, uint _count) public view 
    returns (MergeRequest[] memory activeMergeRequests_, uint fromIncluded_){
        uint length = vendorModel.getMergeListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint filteredLength = 0;
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        uint[] memory filteredIndexes = new uint[](itr);
        while (_toExcluded>0 && filteredLength<itr) {
            _toExcluded--;
            MergeRequestState mergeState = vendorModel.getMergeRequestState(_toExcluded);
            if((mergeState==MergeRequestState.INITIATED)
                    ||(mergeState==MergeRequestState.SUBMITTED)){
                filteredIndexes[filteredLength] = _toExcluded;
                filteredLength++;
            }
        }
        fromIncluded_ = _toExcluded;
        activeMergeRequests_ = new MergeRequest[](filteredLength);
        for(uint i=0;i<filteredLength;i++) {
            activeMergeRequests_[i]=vendorModel.getMergeRequestByIndex(filteredIndexes[i]);
        }
    }


    function submitGidSeedRequest(string memory _gid, string memory _vendorEgpId, string memory _vendorEgpOrgId) public  
    gidActive(_gid) 
    gidOwner(_gid) 
    seedRequestSubmittable(_gid, _vendorEgpId, _vendorEgpOrgId)
    {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid, _vendorEgpId, _vendorEgpOrgId)));
        uint256 id = vendorModel.getSeedListLength();
        vendorModel.incSeedRequestListLength();
        vendorModel.setSeedRequestIndex(uid, 1+id);
        vendorModel.setSeedRequestGid(id, _gid);
        vendorModel.setSeedRequestVendorEgpId(id, _vendorEgpId);
        vendorModel.setSeedRequestVendorEgpOrgId(id, _vendorEgpOrgId);
        vendorModel.setSeedRequestState(id, SeedRequestState.SUBMITTED);
        vendorModel.setSeedRequestVersion(id);
        emit SeedRequestSubmitted(_gid, _vendorEgpId, _vendorEgpOrgId);
    }

    function approveGidSeedRequest(string memory _gid, string memory _vendorEgpId, string memory _vendorEgpOrgId, bool approval) public 
    networkAdmin
    gidActive(_gid)
    seedRequestApprovable(_gid, _vendorEgpId, _vendorEgpOrgId) {
        uint id = _getSeedRequestIndex(bytes8(keccak256(abi.encodePacked(_gid, _vendorEgpId, _vendorEgpOrgId))));
        if (!approval) {
            vendorModel.setSeedRequestState(id, SeedRequestState.REJECTED);
            emit SeedRequestRejected(_gid, _vendorEgpId, _vendorEgpOrgId);
            return;
        }
        uint vendorId = _getVendorIndex(_gid);
        vendorModel.addVendorVendorEgpId(vendorId, _vendorEgpId);
        vendorModel.addVendorVendorEgpOrgId(vendorId, _vendorEgpOrgId);
        vendorModel.setSeedRequestState(id, SeedRequestState.APPROVED);
        vendorModel.incSeedApprovedListLength();
        emit SeedRequestApproved(_gid, _vendorEgpId, _vendorEgpOrgId);
    }

    function expireGidSeedRequest(string memory _gid, string memory _vendorEgpId, string memory _vendorEgpOrgId) public 
    networkAdmin
    seedRequestApprovable(_gid, _vendorEgpId, _vendorEgpOrgId) {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_gid, _vendorEgpId, _vendorEgpOrgId)));
        uint id = _getSeedRequestIndex(uid);
        vendorModel.setSeedRequestState(id, SeedRequestState.EXPIRED);
        emit SeedRequestExpired(_gid, _vendorEgpId, _vendorEgpOrgId);
    }

    function getAllSeedRequests(uint _toExcluded, uint _count) public view 
    returns(GidSeedRequest[] memory, uint fromIncluded_, uint length_) {
        return vendorModel.getAllGidSeedRequests(_toExcluded, _count);
    }

    function getActiveSeedRequests(uint _toExcluded, uint _count) public view 
    returns(GidSeedRequest[] memory activeSeedRequests_, uint fromIncluded_) {
        uint length = vendorModel.getSeedListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint filteredCount = 0;
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        uint[] memory filteredIndexes = new uint[](itr);
        while (_toExcluded>0 && filteredCount<itr) {
            _toExcluded--;
            if(vendorModel.getSeedRequestState(_toExcluded)==SeedRequestState.SUBMITTED){
                filteredIndexes[filteredCount] = _toExcluded;
                filteredCount++;
            }
        }
        fromIncluded_ = _toExcluded;
        activeSeedRequests_ = new GidSeedRequest[](filteredCount);
        for (uint256 j = 0; j < filteredCount; j++) {
            activeSeedRequests_[j] = vendorModel.getSeedRequestByIndex(filteredIndexes[j]);
        }
    }

    function getSeedRequestsForVendor(string memory _gid, uint _toExcluded, uint _count) public view 
    returns(GidSeedRequest[] memory vendorSeedRequests_, uint fromIncluded_) {
        uint length = vendorModel.getSeedListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint filteredCount = 0;
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        uint[] memory filteredIndexes = new uint[](itr);
        while (_toExcluded>0 && filteredCount<itr) {
            _toExcluded--;
            if(keccak256(abi.encodePacked(vendorModel.getSeedRequestGid(_toExcluded)))==keccak256(abi.encodePacked(_gid))){
                filteredIndexes[filteredCount] = _toExcluded;
                filteredCount++;
            }
        }
        fromIncluded_ = _toExcluded;
        vendorSeedRequests_ = new GidSeedRequest[](filteredCount);
        for (uint256 j = 0; j < filteredCount; j++) {
            vendorSeedRequests_[j] = vendorModel.getSeedRequestByIndex(filteredIndexes[j]);
        }
    }
    
    function _registerGID (string memory _gid) internal 
    gidNotExists(_gid){
        uint id = vendorModel.getGidListLength();
        vendorModel.setGidIndex(_gid, 1+id);
        vendorModel.incGidListLength();
        vendorModel.setGidGid(id, _gid);
        vendorModel.setGidVersion(id);
        vendorModel.setGidActive(id, true);
    }

    function _mergeGIDs(string memory _gidP, string memory _gidC) internal 
    gidExists(_gidP) 
    gidExists(_gidC)
    gidActive(_gidP)
    gidActive(_gidC) {
        uint pId = _getGidIndex(_gidP);
        uint cId = _getGidIndex(_gidC);
        vendorModel.setGidParentGid(cId, _gidP);
        vendorModel.setGidActive(cId, false);
        vendorModel.setGidVersion(cId);
        vendorModel.addGidChildrenGids(pId, _gidC);
    }

    function getUltimateParentGID(string memory _gid) external view returns (string memory) {
        return _getUltParent(_gid);
    }

    function getParentGID(string memory _gid) external view returns (string memory) {
        return vendorModel.getGidParentGid(_getGidIndex(_gid));
    }

    function getAllChildrenGIDs(string memory _gid) external view 
    gidExists(_gid) 
    returns (string[] memory) {
        return _getAllChildrenGIDs(_gid);
    }

    function getChildrenGIDs(string memory _gid) external view returns (string[] memory) {
        return vendorModel.getGidChildrenGids(_getGidIndex(_gid));
    }

    function isGidExists(string memory _gid) external view returns(bool){
        return (vendorModel.getGidIndex(_gid)>0);
    }

    function isGidActive(string memory _gid) external view returns(bool){
        require(vendorModel.getGidIndex(_gid)>0, "GID does not exist");
        return vendorModel.getGidActive(_getGidIndex(_gid));
    }

    function _getUltParent(string memory _gid) private view returns(string memory){
        if(vendorModel.getGidActive(_getGidIndex(_gid))) {
            return _gid;
        }
        return _getUltParent(vendorModel.getGidParentGid(_getGidIndex(_gid)));
    }

    function _getAllChildrenGIDs(string memory _gid) private view returns (string [] memory gidList_) {
        gidList_ = new string[](1);
        gidList_[0] = _gid;
        string [] memory childrenGids = vendorModel.getGidChildrenGids(_getGidIndex(_gid));
        string [] memory cGids;
        string [] memory concatArr;
        for (uint256 i = 0; i < childrenGids.length; i++) {
            cGids = _getAllChildrenGIDs(childrenGids[i]);
            concatArr = new string[](gidList_.length + cGids.length);
            for (uint256 j = 0; j < gidList_.length; j++) {
                concatArr[j] = gidList_[i];
            }
            for (uint256 k = 0; k < cGids.length; k++) {
                concatArr[k+gidList_.length] = cGids[k];
            }
            gidList_ = concatArr;
        }
    }

    function _getVendorIndex(string memory _gid) private view returns (uint){
        return vendorModel.getVendorIndex(_gid) - 1;
    }

    function _getGidIndex(string memory _gid) private view returns (uint){
        return vendorModel.getGidIndex(_gid) - 1;
    }

    function _getMergeRequestIndex(bytes8 _uid) private view returns (uint){
        return vendorModel.getMergeIndex(_uid) - 1;
    }

    function _getSeedRequestIndex(bytes8 _uid) private view returns (uint){
        return vendorModel.getSeedRequestIndex(_uid) - 1;
    }

    function _getAdminOrg() private returns (string memory adminOrg_) {
        (bool success, bytes memory data) = permImplementation.call(
            abi.encodeWithSignature("getPolicyDetails()")
        );
        require(success, "Cannot fetch AdminOrg Details");
        (adminOrg_,,,) = abi.decode(data, (string, string, string, bool));
    }

    function _getAccountAddress(string memory _accountName) private returns(address) {
        (bool success, bytes memory data) = accountManager.call(
            abi.encodeWithSignature(
                "getAccountAddress(string)",
                _accountName
            )
        );
        require(success, "Cannot fetch Account Details");
        return abi.decode(data,(address));
    }


    function getActiveVendorListLength() public view returns(uint256)
    {
        uint256 length = vendorModel.getVendorListLength() - vendorModel.getMergeApprovedListLength() - vendorModel.getSeedApprovedListLength();
        return length;
    }

    function getMergeApprovedListLength() public view returns(uint256)
    {
        return vendorModel.getMergeApprovedListLength();
    }

    function getSeedApprovedListLength() public view returns(uint256)
    {
        return vendorModel.getSeedApprovedListLength();
    }
    
    function getTotalVendorListLength() public view returns(uint256)
    {
        return vendorModel.getVendorListLength();
    }

}