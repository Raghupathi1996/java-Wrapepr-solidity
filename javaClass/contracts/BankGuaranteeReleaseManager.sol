pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./BankGuaranteeReleaseModel.sol";
import "./BankGuaranteeInvokeModel.sol";
import "./BankGuaranteeManager.sol";
import "./VcnFunctionalManager.sol";

contract BankGuaranteeReleaseManager is BankGuaranteeReleaseStructs, BankGuaranteeInvokeStructs {

    address private permInterfaceAddress;
    BankGuaranteeReleaseModel private bankGuaranteeReleaseModel;
    BankGuaranteeInvokeModel private bankGuaranteeInvokeModel;
    BankGuaranteeManager private bankGuaranteeManager;
    VcnFunctionalManager private vcnFunctionalManager;


    event BankGuaranteeReleased(bytes8 _bgReleaseUid, bytes8 _bgUid, string _paymentAdviceReferenceNumber, 
        string _procuringEntityGid, string _egpSystemId, string _bankGid);

    event BankGuaranteeInvoked(bytes8 _bgInvokeUid, bytes8 _bgUid, string _paymentAdviceReferenceNumber, 
        string _procuringEntityGid, string _egpSystemId, string _bankGid);

    constructor (address _bankGuaranteeReleaseModel, address _bankGuaranteeInvokeModel,  address _bankGuaranteeManager, address _permInterfaceAddress, address _vcnFunctionalManager) {
        bankGuaranteeReleaseModel = BankGuaranteeReleaseModel(_bankGuaranteeReleaseModel);
        bankGuaranteeInvokeModel = BankGuaranteeInvokeModel(_bankGuaranteeInvokeModel);
        bankGuaranteeManager = BankGuaranteeManager(_bankGuaranteeManager);
        vcnFunctionalManager = VcnFunctionalManager(_vcnFunctionalManager);
        permInterfaceAddress = _permInterfaceAddress;
    }


    modifier onlyEgpRepresentative(string memory _egpSystemId) {
        (bool success, bytes memory data) = permInterfaceAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                msg.sender,
                _egpSystemId
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account does not exists or exists but doesn't belong to passed egp system id"
        );
        _;
    }

    modifier bankGuaranteeReleaseExists(bytes8 _uid) {
        require(0 != bankGuaranteeReleaseModel.getBankGuaranteeReleaseIndex(_uid), "BG Release does not exist");
        _;
    }

    modifier bankGuaranteeInvokeExists(bytes8 _uid) {
        require(0 != bankGuaranteeInvokeModel.getBankGuaranteeInvokeIndex(_uid), "BG Invoke does not exist");
        _;
    }

    modifier validCallerAndDataForRelease(BankGuaranteeRelease memory _bankGuaranteeRelease) {
        (bool success, bytes memory data) = permInterfaceAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                msg.sender,
                _bankGuaranteeRelease.egpSystemId
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account does not exists or exists but doesn't belong to passed egp system id"
        );
        require(bankGuaranteeManager.isUidExists(_bankGuaranteeRelease.bankGuaranteeUid), "Bank gurantee doesn't exist");
        require( keccak256(abi.encodePacked(bankGuaranteeManager.getBankGid(_bankGuaranteeRelease.bankGuaranteeUid))) == keccak256(abi.encodePacked(_bankGuaranteeRelease.bankGid)), "Release request can be made only to the Bank who had submitted the Bank Guarantee");
        string memory _BGcurrency = bankGuaranteeManager.getBankGuaranteeCurrencyType(_bankGuaranteeRelease.bankGuaranteeUid);
        require(vcnFunctionalManager.checkCurrencyVersion(_BGcurrency, _bankGuaranteeRelease.currency), "Currency doesn't match as per the Bank Guarantee");
        require(_bankGuaranteeRelease.amountReleased <= getBankGuaranteeBalance(_bankGuaranteeRelease.bankGuaranteeUid), "The amount requested to be released is more than the Balance amount");
        require(_bankGuaranteeRelease.releaseDate <= bankGuaranteeManager.getBankGuaranteeClaimExpiryDate(_bankGuaranteeRelease.bankGuaranteeUid), "The Bank Guarantee has expired"); //Then should be able to submit an other bankgurantee to the PA
        _;
    }

    modifier validCallerAndDataForInvoke(BankGuaranteeInvoke memory _bankGuaranteeInvoke) {
        (bool success, bytes memory data) = permInterfaceAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                msg.sender,
                _bankGuaranteeInvoke.egpSystemId
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account does not exists or exists but doesn't belong to passed egp system id"
        );
        require(bankGuaranteeManager.isUidExists(_bankGuaranteeInvoke.bankGuaranteeUid));
        require( keccak256(abi.encodePacked(bankGuaranteeManager.getBankGid(_bankGuaranteeInvoke.bankGuaranteeUid))) == keccak256(abi.encodePacked(_bankGuaranteeInvoke.bankGid)), "Invoke request can be made only to the Bank who had submitted the Bank Guarantee");
        string memory _BGcurrency = bankGuaranteeManager.getBankGuaranteeCurrencyType(_bankGuaranteeInvoke.bankGuaranteeUid);
        require(vcnFunctionalManager.checkCurrencyVersion(_BGcurrency, _bankGuaranteeInvoke.currency), "Currency doesn't match as per the Bank Guarantee");
        require(_bankGuaranteeInvoke.revocationAmount <= getBankGuaranteeBalance(_bankGuaranteeInvoke.bankGuaranteeUid), "The amount requested to be Invoked is more than the Balance amount");
        require(_bankGuaranteeInvoke.revocationDate <= bankGuaranteeManager.getBankGuaranteeClaimExpiryDate(_bankGuaranteeInvoke.bankGuaranteeUid), "The Bank Guarantee has expired");
        _;
    }

   
    function publishBankGuaranteeRelease(BankGuaranteeRelease memory _bankGuaranteeRelease) public 
    validCallerAndDataForRelease(_bankGuaranteeRelease) {
        if(getBankGuaranteeBalance(_bankGuaranteeRelease.bankGuaranteeUid) == _bankGuaranteeRelease.amountReleased){
            bankGuaranteeManager.setBgReleaseStatusPaUid(_bankGuaranteeRelease.bankGid, _bankGuaranteeRelease.bankGuaranteeUid);
        }
        _generateBgReleaseUid(_bankGuaranteeRelease);
        uint id = bankGuaranteeReleaseModel.getBankGuaranteeReleaseListLength();
        bankGuaranteeReleaseModel.setBankGuaranteeReleaseIndex(_bankGuaranteeRelease.uid, 1+id);
        bankGuaranteeReleaseModel.incBankGuaranteeReleaseListLength();
        bankGuaranteeReleaseModel.addBankGuaranteeRelease(id, _bankGuaranteeRelease);
        bankGuaranteeReleaseModel.addBgReleaseIndexListByBgUid(_bankGuaranteeRelease.bankGuaranteeUid, id);
        string memory _bgReferenceNumber = bankGuaranteeManager.getBankGuaranteeReferenceNumberbybgUid(_bankGuaranteeRelease.bankGuaranteeUid);
        bankGuaranteeReleaseModel.setBankGuaranteeReleaseIndices(_bankGuaranteeRelease, id, _bgReferenceNumber);
        emit BankGuaranteeReleased(_bankGuaranteeRelease.uid, _bankGuaranteeRelease.bankGuaranteeUid, 
        _bankGuaranteeRelease.paymentReference, _bankGuaranteeRelease.procuringEntityGid, 
        _bankGuaranteeRelease.egpSystemId, _bankGuaranteeRelease.bankGid);
    }

    function publishBankGuaranteeInvoke(BankGuaranteeInvoke memory _bankGuaranteeInvoke) public 
    validCallerAndDataForInvoke(_bankGuaranteeInvoke) {
        _generateBgInvokeUid(_bankGuaranteeInvoke);
        uint id = bankGuaranteeInvokeModel.getBankGuaranteeInvokeListLength();
        bankGuaranteeInvokeModel.setBankGuaranteeInvokeIndex(_bankGuaranteeInvoke.uid, 1+id);
        bankGuaranteeInvokeModel.incBankGuaranteeInvokeListLength();
        bankGuaranteeInvokeModel.addBankGuaranteeInvoke(id, _bankGuaranteeInvoke);
        bankGuaranteeInvokeModel.addBgInvokeIndexListByBgUid(_bankGuaranteeInvoke.bankGuaranteeUid, id);
        string memory _bgReferenceNumber = bankGuaranteeManager.getBankGuaranteeReferenceNumberbybgUid(_bankGuaranteeInvoke.bankGuaranteeUid);
        bankGuaranteeInvokeModel.setBankGuaranteeInvokeIndices(_bankGuaranteeInvoke, id, _bgReferenceNumber);
        emit BankGuaranteeInvoked(_bankGuaranteeInvoke.uid, _bankGuaranteeInvoke.bankGuaranteeUid, 
        _bankGuaranteeInvoke.paymentReference, _bankGuaranteeInvoke.procuringEntityGid, 
        _bankGuaranteeInvoke.egpSystemId, _bankGuaranteeInvoke.bankGid);
    }

    function getAllBankGuaranteeRelease(uint _toExcluded, uint _count) external view 
    returns(BankGuaranteeRelease[] memory _bankGuaranteeRelease, uint fromIncluded_, uint length_) {
        (_bankGuaranteeRelease, fromIncluded_, length_) = bankGuaranteeReleaseModel.getAllBankGuaranteeRelease(_toExcluded, _count);
    }

    function getAllBankGuaranteeInvoke(uint _toExcluded, uint _count) external view 
    returns(BankGuaranteeInvoke[] memory _bankGuaranteeInvoke, uint fromIncluded_, uint length_) {
        (_bankGuaranteeInvoke, fromIncluded_, length_) = bankGuaranteeInvokeModel.getAllBankGuaranteeInvoke(_toExcluded, _count);
    }


    function getBankGuaranteeBalance(bytes8 _bgUid) public view 
    returns (uint) {
        uint[] memory bgReleaseUids = bankGuaranteeReleaseModel.getBgReleaseIndexListByBgUid(_bgUid);
        uint[] memory bgInvokeUids = bankGuaranteeInvokeModel.getBgInvokeIndexListByBgUid(_bgUid);
        uint releaseAndInvokeSum = 0;
        for (uint256 i = 0; i < bgReleaseUids.length; i++) {
            releaseAndInvokeSum += bankGuaranteeReleaseModel.getBgReleaseAmountReleased(bgReleaseUids[i]);
        }
        for (uint256 j = 0; j < bgInvokeUids.length; j++) {
            releaseAndInvokeSum += bankGuaranteeInvokeModel.getBgInvokeRevocationAmount(bgInvokeUids[j]);
        }
        uint totalBgAmount = bankGuaranteeManager.getBankGuaranteeAmount(_bgUid);
        require(releaseAndInvokeSum < totalBgAmount, "Total Release till date Equal or Exceeding BG Amount");
        return totalBgAmount-releaseAndInvokeSum;
    }

    function getBankGuaranteeRelease(bytes8 _uid) public view 
    bankGuaranteeReleaseExists(_uid) 
    returns (BankGuaranteeRelease memory bankGuaranteeRelease_) {
        bankGuaranteeRelease_ = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(_getBankGuaranteeReleaseIndex(_uid));
    }

    function isReleaseUidExists(bytes8 _uid) public view 
    returns(bool) {
        return (0 != bankGuaranteeReleaseModel.getBankGuaranteeReleaseIndex(_uid));
    }

    
    /** @dev Listing out the Bank Guarantee Releases against the Bank Gid.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByBankGID List of Bank Guarantee Releases against the Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Bank Gid.
      */
    function getBgReleasesListByBankGID(string memory _bankGid, uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeRelease[] memory _bgReleaseListByBankGID, uint fromIncluded_, uint length_)  {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeReleaseModel.getBgReleaseListByEgpID(_bankGid, _toExcluded, _count);
        _bgReleaseListByBankGID = new BankGuaranteeRelease[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgReleaseListByBankGID[i] = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(indexList[i]);
        }

    }
    
    
    /** @dev Listing out the Bank Guarantee Releases against the EgpSystem Id.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByEgpID List of Bank Guarantee Releases against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getBgReleasesListByEgpID(string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeRelease[] memory _bgReleaseListByEgpID, uint fromIncluded_, uint length_)  {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeReleaseModel.getBgReleaseListByEgpID(_egpSystemId, _toExcluded, _count);
        _bgReleaseListByEgpID = new BankGuaranteeRelease[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgReleaseListByEgpID[i] = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(indexList[i]);
        }

    } 

    
    /** @dev Listing out the Bank Guarantee Releases against the Bank Guarantee Reference Number and Bank Gid.
      * @param _bgReferenceNumber Reference number of bank Guarantee.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByBgRefAndBankGid List of Bank Guarantee Releases against the Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Bank Guarantee Reference Number and Bank Gid.
      */
    function getBgReleasesListByBgRefAndBankGid(string memory _bgReferenceNumber, string memory _bankGid,  uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeRelease[] memory _bgReleaseListByBgRefAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgReleaseBgRefBankGid = bytes8(keccak256(abi.encodePacked(_bgReferenceNumber, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeReleaseModel.getBgReleaseListByBgRefAndBankGid(_bgReleaseBgRefBankGid, _toExcluded, _count);
        _bgReleaseListByBgRefAndBankGid = new BankGuaranteeRelease[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgReleaseListByBgRefAndBankGid[i] = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(indexList[i]);
        }
    }    

    
    /** @dev Listing out the Bank Guarantee Releases against the Payment Advice Reference Number and Bank Gid.
      * @param _paymentReference Reference number of Payment Advice.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByPaRefAndBankGid List of Bank Guarantee Releases against the Payment Advice Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Payment Advice Reference Number and Bank Gid.
      */
    function getBgReleasesListByPaRefAndBankGid(string memory _paymentReference, string memory _bankGid,  uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeRelease[] memory _bgReleaseListByPaRefAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgReleasePaRefBankGid = bytes8(keccak256(abi.encodePacked(_paymentReference, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeReleaseModel.getBgReleaseListByPaRefAndBankGid(_bgReleasePaRefBankGid, _toExcluded, _count);
        _bgReleaseListByPaRefAndBankGid = new BankGuaranteeRelease[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgReleaseListByPaRefAndBankGid[i] = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(indexList[i]);
        }
    }    




    function getBgReleaseListByBgUid(bytes8 _bgUid, uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeRelease[] memory bgReleaseList_, uint fromIncluded_, uint length_) {
        uint[] memory bgReleaseUids = bankGuaranteeReleaseModel.getBgReleaseIndexListByBgUid(_bgUid);
        if (_toExcluded > bgReleaseUids.length) {
            _toExcluded = bgReleaseUids.length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        bgReleaseList_ = new BankGuaranteeRelease[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            bgReleaseList_[bgReleaseList_.length-itr-1] = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(bgReleaseUids[_toExcluded]);
        }
        fromIncluded_ = _toExcluded;
        length_ = bgReleaseUids.length;
    }

    function getBgInvokeListByBgUid(bytes8 _bgUid, uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeInvoke[] memory bgInvokeList_, uint fromIncluded_, uint length_) {
        uint[] memory bgInvokeUids = bankGuaranteeInvokeModel.getBgInvokeIndexListByBgUid(_bgUid);
        if (_toExcluded > bgInvokeUids.length) {
            _toExcluded = bgInvokeUids.length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        bgInvokeList_ = new BankGuaranteeInvoke[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            bgInvokeList_[bgInvokeList_.length-itr-1] = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(bgInvokeUids[_toExcluded]);
        }
        fromIncluded_ = _toExcluded;
        length_ = bgInvokeUids.length;
    }

    function getBankGuaranteeInvoke(bytes8 _uid) public view 
    bankGuaranteeInvokeExists(_uid) 
    returns (BankGuaranteeInvoke memory bankGuaranteeInvoke_) {
        bankGuaranteeInvoke_ = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(_getBankGuaranteeInvokeIndex(_uid));
    }

    function isInvokeUidExists(bytes8 _uid) public view 
    returns(bool) {
        return (0 != bankGuaranteeInvokeModel.getBankGuaranteeInvokeIndex(_uid));
    }

    
    
    /** @dev Listing out the Bank Guarantee Invokes against the Bank Gid.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByBankGID List of Bank Guarantee Invokes against the Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Bank Gid.
      */
    function getBgInvokesListByBankGID(string memory _bankGid, uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeInvoke[] memory _bgInvokeListByBankGID, uint fromIncluded_, uint length_)  {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeInvokeModel.getBgInvokeListByEgpID(_bankGid, _toExcluded, _count);
        _bgInvokeListByBankGID = new BankGuaranteeInvoke[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgInvokeListByBankGID[i] = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(indexList[i]);
        }

    }
    
    /** @dev Listing out the Bank Guarantee Invokes against the EgpSystem Id.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByEgpID List of Bank Guarantee Invokes against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getBgInvokesListByEgpID(string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeInvoke[] memory _bgInvokeListByEgpID, uint fromIncluded_, uint length_)  {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeInvokeModel.getBgInvokeListByEgpID(_egpSystemId, _toExcluded, _count);
        _bgInvokeListByEgpID = new BankGuaranteeInvoke[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgInvokeListByEgpID[i] = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(indexList[i]);
        }

    } 

    
    /** @dev Listing out the Bank Guarantee Invokes against the Reference Number and Bank Gid.
      * @param _bgReferenceNumber Reference number of bank Guarantee.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByBgRefAndBankGid List of Bank Guarantee Invokes against the Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Reference Number and Bank Gid.
      */
    function getBgInvokesListByBgRefAndBankGid(string memory _bgReferenceNumber, string memory _bankGid,  uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeInvoke[] memory _bgInvokeListByBgRefAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgInvokeBgRefBankGid = bytes8(keccak256(abi.encodePacked(_bgReferenceNumber, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeInvokeModel.getBgInvokeListByBgRefAndBankGid(_bgInvokeBgRefBankGid, _toExcluded, _count);
        _bgInvokeListByBgRefAndBankGid = new BankGuaranteeInvoke[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgInvokeListByBgRefAndBankGid[i] = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(indexList[i]);
        }
    }    

    
    /** @dev Listing out the Bank Guarantee Invokes against the Payment Advice Reference Number and Bank Gid.
      * @param _paymentReference Reference number of Payment Advice.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByPaRefAndBankGid List of Bank Guarantee Invokes against the Payment Advice Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Payment Advice Reference Number and Bank Gid.
      */
    function getBgInvokesListByPaRefAndBankGid( string memory _paymentReference, string memory _bankGid,  uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeInvoke[] memory _bgInvokeListByPaRefAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgInvokePaRefBankGid = bytes8(keccak256(abi.encodePacked(_paymentReference, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeInvokeModel.getBgInvokeListByPaRefAndBankGid(_bgInvokePaRefBankGid, _toExcluded, _count);
        _bgInvokeListByPaRefAndBankGid = new BankGuaranteeInvoke[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bgInvokeListByPaRefAndBankGid[i] = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(indexList[i]);
        }
    }

    function _generateBgReleaseUid (BankGuaranteeRelease memory _bankGuaranteeRelease) internal pure {
        _bankGuaranteeRelease.uid = bytes8(keccak256(abi.encodePacked(_bankGuaranteeRelease.bankGuaranteeUid, 
        _bankGuaranteeRelease.paymentReference, _bankGuaranteeRelease.egpSystemId, _bankGuaranteeRelease.vendorGid, 
        _bankGuaranteeRelease.bankGid, _bankGuaranteeRelease.releaseDate, _bankGuaranteeRelease.amountReleased, 
        _bankGuaranteeRelease.bgReleaseFileHash)));
    }

    function _generateBgInvokeUid (BankGuaranteeInvoke memory _bankGuaranteeInvoke) internal pure {
        _bankGuaranteeInvoke.uid = bytes8(keccak256(abi.encodePacked(_bankGuaranteeInvoke.bankGuaranteeUid, 
        _bankGuaranteeInvoke.paymentReference, _bankGuaranteeInvoke.egpSystemId, _bankGuaranteeInvoke.vendorGid, 
        _bankGuaranteeInvoke.bankGid, _bankGuaranteeInvoke.revocationAmount, _bankGuaranteeInvoke.beneficiaryName, 
        _bankGuaranteeInvoke.bgInvokeFileHash)));
    }

    function _getBankGuaranteeReleaseIndex(bytes8 _uid) internal view 
    returns(uint) {
        return bankGuaranteeReleaseModel.getBankGuaranteeReleaseIndex(_uid)-1;
    }

    function _getBankGuaranteeInvokeIndex(bytes8 _uid) internal view 
    returns(uint) {
        return bankGuaranteeInvokeModel.getBankGuaranteeInvokeIndex(_uid)-1;
    }

    /** @dev Listing out the Bank Guarantee Invokes and Release against the Payment Advice Reference Number and Bank Gid.
      * @param _paReferenceNumber Reference number of Payment Advice and Global id of bank.
      * @param _bankGid Reference number of Payment Advice and Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByUid List of Bank Guarantee Release against the Payment Advice Reference Number and Bank Gid.
      * @return _bgInvokeListByUid List of Bank Guarantee Invokes against the Payment Advice Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Payment Advice Reference Number and Bank Gid.
      */

    function getBgReleasesAndInvokesListByPaBankGid(string memory _paReferenceNumber, string memory _bankGid,  uint _toExcluded, uint _count) public view 
    returns(BankGuaranteeRelease[] memory _bgReleaseListByUid, BankGuaranteeInvoke[] memory _bgInvokeListByUid, uint fromIncluded_, uint length_)  {
        bytes8 _bgReleaseInvokePaRefBankGid = bytes8(keccak256(abi.encodePacked(_paReferenceNumber, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeReleaseModel.getBgReleaseAndInvokeListByBgUid(_bgReleaseInvokePaRefBankGid, _toExcluded, _count);
        _bgReleaseListByUid = new BankGuaranteeRelease [](indexList.length);
        _bgInvokeListByUid = new BankGuaranteeInvoke [](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            if(bankGuaranteeInvokeModel.getReleaseInvokeStatus(_bgReleaseInvokePaRefBankGid, indexList[i]) == 1)
            {
                _bgInvokeListByUid[i] = bankGuaranteeInvokeModel.getBankGuaranteeInvokeByIndex(indexList[i]);
            } else {
                _bgReleaseListByUid[i] = bankGuaranteeReleaseModel.getBankGuaranteeReleaseByIndex(indexList[i]);
            }          
        }
    }
}