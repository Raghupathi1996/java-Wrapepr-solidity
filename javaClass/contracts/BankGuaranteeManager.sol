pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./BankManager.sol";
import "./PaymentAdviceManager.sol";
import "./BankGuaranteeModel.sol";
import "./VcnFunctionalManager.sol";

contract BankGuaranteeManager is BankGuaranteeStructs {

    address private accountManager;
    BankManager private bankManager;
    PaymentAdviceManager private paymentAdviceManager;
    BankGuaranteeModel private bankGuaranteeModel;
    VcnFunctionalManager private vcnFunctionalManager;

    event BankGuaranteeRegistered(bytes8 _bgUid, string _bgReferenceNumber, bytes8 _paUid, string _paymentAdviceReferenceNumber);

    event AmendedBankGuaranteeRegistered(bytes8 _bgUid, string _bgReferenceNumber, string paymentAdviceNumber, uint _bgAmendment);

    constructor (address _bankManager, address _paymentAdviceManager, address _bankGuaranteeModel, address _accountManager, address _vcnFunctionalManager) {
        bankManager = BankManager(_bankManager);
        paymentAdviceManager = PaymentAdviceManager(_paymentAdviceManager);
        bankGuaranteeModel = BankGuaranteeModel(_bankGuaranteeModel);
        accountManager = _accountManager;
        vcnFunctionalManager = VcnFunctionalManager(_vcnFunctionalManager);
    }



    modifier bankGidExists(string memory _gid) {
        require(bankManager.isGidExists(_gid), "Bank Gid not exists");
        _;
    }

    modifier validatePaymentAdvice(BankGuarantee memory _bankGuarantee) {
        require(paymentAdviceManager.getPaymentAdviceReferenceNumberExist(_bankGuarantee.paymentAdviceNumber) == 1, "PA reference number doesn't exist in the system" );
        require(paymentAdviceManager.isUidExists(_bankGuarantee.paymentAdviceUid), "Payment Advice does not exist");
        require(paymentAdviceManager.getLatestPaUidByReferenceNumber(_bankGuarantee.paymentAdviceNumber) == _bankGuarantee.paymentAdviceUid, "The amendment copy of the PA is been uploaded, submit BG against the latest amended PA");
        require(bankGuaranteeModel.getBankGuaranteforPaymentAdviceBankGid(_bankGuarantee.bankGid, _bankGuarantee.paymentAdviceUid) == 0, "Bank has already submitted BG for the PA");
        require(vcnFunctionalManager.checkCurrencyVersion(paymentAdviceManager.getPaymentAdviceCurrencyType(_bankGuarantee.paymentAdviceUid), _bankGuarantee.currency), "Currency doesn't match as per the Payment Advice");
        require(paymentAdviceManager.getPaymentAdviceBGAmount(_bankGuarantee.paymentAdviceUid) <= (_bankGuarantee.amount), "Bank Guarantee amount should be more or equal to the Payment Advice Amount");
        require(bankGuaranteeModel.getBankGuaranteeIndexListLengthByPaymentAdviceAndBankGid(
            bytes8(keccak256(abi.encodePacked(_bankGuarantee.referenceNumber, _bankGuarantee.bankGid)))) == 0, "BG number already exists in the system" );
        _;
    }

    modifier onlyBankRepresentative(string memory _bankGid) {
        (bool success, bytes memory data) = accountManager.call(
            abi.encodeWithSignature(
                "getAccountAddress(string)",
                bankManager.getBankForGid(_bankGid).representativeAccountName
            )
        );
        require(
            success,
            "permissions call failed"
        );
        address accAddress = abi.decode(data, (address));
        require(
            msg.sender == accAddress,
            "unauthorized caller"
        );
        _;
    }

    modifier checkPaReferenceNumberByBankGid (string memory _referenceNumber, string memory _bankGid, bytes8 _paymentAdviceUid, string memory _currency) {
        require(bankGuaranteeModel.getBankGuaranteeIndexListLengthByPaymentAdviceAndBankGid(
            bytes8(keccak256(abi.encodePacked(_referenceNumber, _bankGid)))) > 0, "Initial BG is not been submitted or BG Ref Number not found in the system to submit amendment");
        require(paymentAdviceManager.getLatestPaUidByReferenceNumber(_referenceNumber) == _paymentAdviceUid, "Submit the BG against the latest PA pushed by the Egp system");
        require(bankGuaranteeModel.getBankGuaranteforPaymentAdviceBankGid(_bankGid, _paymentAdviceUid) == 0, "Bank has already submitted BG for the PA");
        require(vcnFunctionalManager.checkCurrencyVersion(paymentAdviceManager.getPaymentAdviceCurrencyType(_paymentAdviceUid), _currency), "Currency doesn't match as per the Payment Advice");
        _;
    }


    function publishBankGuarantee(BankGuarantee memory _bankGuarantee) public 
    bankGidExists(_bankGuarantee.bankGid) 
    onlyBankRepresentative(_bankGuarantee.bankGid)
    validatePaymentAdvice(_bankGuarantee)
    {
        bytes8 uid = _generateUID(_bankGuarantee);
        require(bankGuaranteeModel.getBankGuaranteeIndex(uid)==0, "Bank Guarantee already published");
        _bankGuarantee.uid = uid;
        _publishBankGuarantee(_bankGuarantee);
        emit BankGuaranteeRegistered(_bankGuarantee.uid, _bankGuarantee.referenceNumber, _bankGuarantee.paymentAdviceUid, _bankGuarantee.paymentAdviceNumber);
    }


    function _publishBankGuarantee(BankGuarantee memory _bankGuarantee) internal
    {
        uint id = bankGuaranteeModel.getBankGuaranteeListLength();
        bankGuaranteeModel.setBankGuaranteeIndex(_bankGuarantee.uid, 1+id);
        bankGuaranteeModel.incBankGuaranteeListLength();
        bankGuaranteeModel.addBankGuarantee(id, _bankGuarantee);
        bankGuaranteeModel.addBankGuaranteeIndexByBankGid(_bankGuarantee.bankGid, id);
        bankGuaranteeModel.setBankGuaranteeIndexByPaymentAdviceUid(_bankGuarantee.paymentAdviceUid, 1+id);
        bankGuaranteeModel.addBankGuaranteforPaymentAdviceBankGid(_bankGuarantee.paymentAdviceUid, _bankGuarantee.bankGid);
        bankGuaranteeModel.addBankGuaranteeIndexListByPaymentAdviceAndBankGid(
            bytes8(keccak256(abi.encodePacked(_bankGuarantee.paymentAdviceNumber,_bankGuarantee.bankGid))), id
        );
        string memory _vendorGid = paymentAdviceManager.getPaymentAdviceVendorGidbyUid(_bankGuarantee.paymentAdviceUid);
        string memory _peGid = paymentAdviceManager.getPaymentAdviceProcuringEntityGidyUid(_bankGuarantee.paymentAdviceUid);
        bankGuaranteeModel.setBankGuaranteeIndices(_bankGuarantee, id, _vendorGid, _peGid);
        bankGuaranteeModel.setBankGuaranteeByBgReferenceAndBankGid(_bankGuarantee, id);
    }

    function amendedBankGuarantee (BankGuarantee memory _bankGuarantee) public
    onlyBankRepresentative(_bankGuarantee.bankGid)
    checkPaReferenceNumberByBankGid (_bankGuarantee.paymentAdviceNumber, _bankGuarantee.bankGid, _bankGuarantee.paymentAdviceUid, _bankGuarantee.currency)
    {
        uint id = bankGuaranteeModel.getBankGuaranteeListLength();
        uint _PrevIndex;
        (_bankGuarantee, _PrevIndex) = bankGuaranteeModel.generateBankGuarantee(_bankGuarantee);
        bytes8 uid = _generateUID(_bankGuarantee);
        require(bankGuaranteeModel.getBankGuaranteeIndex(uid) == 0, "Bank Guarantee already submiited in the system");
        _bankGuarantee.uid = uid;
        bankGuaranteeModel.setBankGuaranteeIndex(uid, 1+id);
        bankGuaranteeModel.addBankGuaranteeIndexListByPaymentAdviceAndBankGid(
            bytes8(keccak256(abi.encodePacked(_bankGuarantee.paymentAdviceNumber,_bankGuarantee.bankGid))), id);
        bankGuaranteeModel.incBankGuaranteeListLength();
        bankGuaranteeModel.updatePreviousBgtoOutdated(_PrevIndex);
        bankGuaranteeModel.addBankGuarantee(id, _bankGuarantee);
        emit AmendedBankGuaranteeRegistered(_bankGuarantee.uid, _bankGuarantee.referenceNumber, 
        _bankGuarantee.paymentAdviceNumber, _bankGuarantee.amendment);
        
    }

    function setBgReleaseStatusPaUid(string memory _bankGid, bytes8 _bankGuaranteeUid) public
    {
        uint _index = bankGuaranteeModel.getBankGuaranteeIndex(_bankGuaranteeUid) - 1; 
        bytes8 _paymentAdviceUid = bankGuaranteeModel.getBankGuaranteePaymentAdviceUid(_index);
        bankGuaranteeModel.setBgReleaseStatus(_paymentAdviceUid, _bankGid);
    }

    function getAllBankGuarantee(uint _toExcluded, uint _count) external view 
    returns(BankGuarantee[] memory _bankGuarantee, uint fromIncluded_, uint length_) {
        (_bankGuarantee, fromIncluded_, length_) = bankGuaranteeModel.getAllBankGuarantee(_toExcluded, _count);
    }


    function getBankGuarantee(bytes8 _uid) public view returns (BankGuarantee memory bankGuarantee_){
        require(0!=bankGuaranteeModel.getBankGuaranteeIndex(_uid), "Bank Guarantee does not exist");
        bankGuarantee_ = bankGuaranteeModel.getBankGuaranteeByIndex(_getBankGuaranteeIndex(_uid));
    }

    
    
    /** @dev Listing out the Bank Guarantees against the Reference Number and Bank Gid.
      * @param _referenceNumber Reference number of bank Guarantee.
      * @param _bankGid Global id of bank.     
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bankGuaranteeByBgReferenceAndBankGid List of Bank Guarantees against the Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Reference Number and Bank Gid.
      */
    function getBankGuaranteeListByBgReferenceAndBankGid(string memory _referenceNumber, string memory _bankGid, uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory _bankGuaranteeByBgReferenceAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgRefBankGid = bytes8(keccak256(abi.encodePacked(_referenceNumber, _bankGid))); 
        uint256[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeModel.getBankGuaranteeByBgReferenceAndBankGid(_bgRefBankGid, _toExcluded, _count);
        _bankGuaranteeByBgReferenceAndBankGid = new BankGuarantee[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bankGuaranteeByBgReferenceAndBankGid[i] = bankGuaranteeModel.getBankGuaranteeByIndex(indexList[i]);
        }
    }

    
    /** @dev Listing out the Bank Guarantees against the Vendor Gid and Bank Gid.
      * @param _vendorGid Global id of the Vendor.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bankGuaranteeByVendorAndBankGid List of Bank Guarantees against the Vendor Gid and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Vendor Gid and Bank Gid.
      */
    function getBankGuaranteeListByVendorAndBankGid(string memory _vendorGid, string memory _bankGid,  uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory _bankGuaranteeByVendorAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgVendorBankGid = bytes8(keccak256(abi.encodePacked(_vendorGid, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeModel.getBankGuaranteeByVendorAndBankGid(_bgVendorBankGid, _toExcluded, _count);
        _bankGuaranteeByVendorAndBankGid = new BankGuarantee[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bankGuaranteeByVendorAndBankGid[i] = bankGuaranteeModel.getBankGuaranteeByIndex(indexList[i]);
        }
    } 

      
      /** @dev Listing out the Bank Guarantees against the PE Gid and Bank Gid.
      * @param _peGid Global id of Procuring Entity.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bankGuaranteeByPEAndBankGid List of Bank Guarantees against the PE Gid and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE Gid and Bank Gid.
      */
      function getBankGuaranteeListByPEAndBankGid(string memory _peGid, string memory _bankGid,  uint _toExcluded, uint _count) public view 
      returns(BankGuarantee[] memory _bankGuaranteeByPEAndBankGid, uint fromIncluded_, uint length_)  {
        bytes8 _bgPeBankGid = bytes8(keccak256(abi.encodePacked(_peGid, _bankGid)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeModel.getBankGuaranteeByPEAndBankGid(_bgPeBankGid, _toExcluded, _count);
        _bankGuaranteeByPEAndBankGid = new BankGuarantee[] (indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            _bankGuaranteeByPEAndBankGid[i] = bankGuaranteeModel.getBankGuaranteeByIndex(indexList[i]);
        }

      }

    function getBankGuaranteesByBankGid(string memory _bankGid, uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory bankGuarantees_, uint fromIncluded_, uint length_){
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = bankGuaranteeModel.getBankGuaranteeIndexesByBankGid(_bankGid, _toExcluded, _count);
        bankGuarantees_ = new BankGuarantee[](indexList.length);
        for (uint256 index = 0; index < indexList.length; index++) {
            bankGuarantees_[index] = bankGuaranteeModel.getBankGuaranteeByIndex(indexList[index]);
        }
    }

    function getBankGuaranteesByPaymentAdviceRefAndEgpId(string memory _paymentAdviceReferenceNumber, string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory bankGuarantees_, uint fromIncluded_, uint length_){
        bytes8[] memory paymentAdviceUidList;
        (paymentAdviceUidList,fromIncluded_, length_) = paymentAdviceManager.getPaymentAdviceUidsByPaymentAdviceRefAndEgpId(_paymentAdviceReferenceNumber, _egpSystemId, _toExcluded, _count);
        bankGuarantees_ = new BankGuarantee[](paymentAdviceUidList.length);
        for(uint i=0;i<paymentAdviceUidList.length;i++) {
            if(isBgExistsForPaymentAdviceUid(paymentAdviceUidList[i])){
                bankGuarantees_[i] =  _getBankGuaranteeByPaymentAdviceUid(paymentAdviceUidList[i]);
            }
        }
    } 

    function getBankGuaranteesByVendorGid(string memory _vendorGid, uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory bankGuarantees_, uint fromIncluded_, uint length_){
        bytes8[] memory paymentAdviceUidList;
        (paymentAdviceUidList, fromIncluded_, length_) = paymentAdviceManager.getPaymentAdviceUidsByVendorGid(_vendorGid, _toExcluded, _count);
        bankGuarantees_ = new BankGuarantee[](paymentAdviceUidList.length);
        for(uint i=0;i<paymentAdviceUidList.length;i++) {
            if(isBgExistsForPaymentAdviceUid(paymentAdviceUidList[i])){
                bankGuarantees_[i] =  _getBankGuaranteeByPaymentAdviceUid(paymentAdviceUidList[i]);
            }
        }
    } 

    function getBankGuaranteesByEgpId(string memory _egpId, uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory bankGuarantees_, uint fromIncluded_, uint length_){
        bytes8[] memory paymentAdviceUidList;
        (paymentAdviceUidList, fromIncluded_, length_) = paymentAdviceManager.getPaymentAdviceUidsByEgpId(_egpId, _toExcluded, _count);
        bankGuarantees_ = new BankGuarantee[](paymentAdviceUidList.length);
        for(uint i=0;i<paymentAdviceUidList.length;i++) {
            if(isBgExistsForPaymentAdviceUid(paymentAdviceUidList[i])){
                bankGuarantees_[i] =  _getBankGuaranteeByPaymentAdviceUid(paymentAdviceUidList[i]);
            }
        }
    } 

    function getBankGuaranteesByPeGid(string memory _gid, uint _toExcluded, uint _count) public view 
    returns(BankGuarantee[] memory bankGuarantees_, uint fromIncluded_, uint length_){
        bytes8[] memory paymentAdviceUidList;
        (paymentAdviceUidList, fromIncluded_, length_) = paymentAdviceManager.getPaymentAdviceUidsByProcuringEntityGid(_gid, _toExcluded, _count);
        bankGuarantees_ = new BankGuarantee[](paymentAdviceUidList.length);
        for(uint i=0;i<paymentAdviceUidList.length;i++) {
            if(isBgExistsForPaymentAdviceUid(paymentAdviceUidList[i])){
                bankGuarantees_[i] =  _getBankGuaranteeByPaymentAdviceUid(paymentAdviceUidList[i]);
            }
        }
    }

    function getBankGid(bytes8 _uid) external view
    returns (string memory) {
        return bankGuaranteeModel.getBankGuaranteeBankGid(_getBankGuaranteeIndex(_uid));
    }

    function getBankGuaranteeCurrencyType(bytes8 _uid) external view 
    returns (string memory) {
        require(0!=bankGuaranteeModel.getBankGuaranteeIndex(_uid), "Bank Guarantee does not exist");
        return bankGuaranteeModel.getBankGuaranteeCurrency(_getBankGuaranteeIndex(_uid));
    } 

    function getBankGuaranteeAmount(bytes8 _uid) external view 
    returns (uint) {
        return bankGuaranteeModel.getBankGuaranteeAmount(_getBankGuaranteeIndex(_uid));
    }

    function getBankGuaranteeClaimExpiryDate(bytes8 _uid) external view 
    returns (uint) {
        return bankGuaranteeModel.getBankGuaranteeClaimExpiryDate(_getBankGuaranteeIndex(_uid));
    }

    function getBankGuaranteeReferenceNumberbybgUid (bytes8 _uid) external view
    returns (string memory) {
        return bankGuaranteeModel.getBankGuaranteeReferenceNumber(_getBankGuaranteeIndex(_uid));
    }

    function isUidExists(bytes8 _uid) external view 
    returns (bool) {
        return 0 != bankGuaranteeModel.getBankGuaranteeIndex(_uid);
    }

    function isBgExistsForPaymentAdviceUid(bytes8 _paymentAdviceUid) public view 
    returns (bool) {
        return 0 != bankGuaranteeModel.getBankGuaranteeIndexByPaymentAdviceUid(_paymentAdviceUid);
    }

    function _getBankGuaranteeByPaymentAdviceUid(bytes8 _paymentAdviceUid) private view returns(BankGuarantee memory bankGuarantee_){
        return bankGuaranteeModel.getBankGuaranteeByIndex(_getBankGuaranteeIndexByPaymentAdviceUid(_paymentAdviceUid));
    } 

    function _getBankGuaranteeIndex(bytes8 _uid) private view returns(uint){
        return bankGuaranteeModel.getBankGuaranteeIndex(_uid)-1;
    }

    function _getBankGuaranteeIndexByPaymentAdviceUid(bytes8 _uid) private view returns(uint){
        require(isBgExistsForPaymentAdviceUid(_uid), "BG does not exist for given PA uid");
        return bankGuaranteeModel.getBankGuaranteeIndexByPaymentAdviceUid(_uid)-1;
    }

    function _generateUID(BankGuarantee memory _bankGuarantee) private pure returns (bytes8){
        return bytes8(keccak256(abi.encodePacked(_bankGuarantee.bankGid, _bankGuarantee.paymentAdviceNumber, _bankGuarantee.paymentAdviceUid, _bankGuarantee.referenceNumber, 
        _bankGuarantee.claimExpiryDate, _bankGuarantee.validFrom, _bankGuarantee.validTill, 
        _bankGuarantee.currency, _bankGuarantee.amount, _bankGuarantee.fileHash, _bankGuarantee.amendment)));
    } 

    function _mergeBankGuarantees(BankGuarantee[] memory arr, BankGuarantee[] memory arr2) private pure returns(BankGuarantee[] memory) {
        BankGuarantee[] memory returnArr = new BankGuarantee[](arr.length + arr2.length);
        uint i=0;
        for (; i < arr.length; i++) {
            returnArr[i] = arr[i];
        }
        uint j=0;
        while (j < arr2.length) {
            returnArr[i++] = arr2[j++];
        }
        return returnArr;
    }

}