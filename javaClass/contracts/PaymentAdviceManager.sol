pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./VendorManager.sol";
import "./ProcuringEntityManager.sol";
import "./PaymentAdviceModel.sol";
import "./VcnFunctionalManager.sol";

contract PaymentAdviceManager is PaymentAdviceStructs {

    address private permIntfAddress;
    VendorManager private vendorManager;
    ProcuringEntityManager private procuringEntityManager;
    PaymentAdviceModel private paymentAdviceModel;
    VcnFunctionalManager private vcnFunctionalManager;

    event PaymentAdviceRegistered(bytes8 _paUid, string _paymentAdviceReferenceNumber, string _peGid);
    
    event AmendmentPaymentAdviceRegistered(bytes8 _paUid, string _paymentAdviceReferenceNumber, string _peGid, uint _paAmendment);

    constructor (address _permIntf, address _vendorManager, address _procuringEntityManager, address _paymentAdviceModel, address _vcnFunctionalManager) {
        permIntfAddress = _permIntf;
        vendorManager = VendorManager(_vendorManager);
        procuringEntityManager = ProcuringEntityManager(_procuringEntityManager);
        paymentAdviceModel = PaymentAdviceModel(_paymentAdviceModel);
        vcnFunctionalManager = VcnFunctionalManager(_vcnFunctionalManager);
    }

    modifier validCurrency(string memory _currency){
        require(vcnFunctionalManager.isCurrencyExists(_currency), "The currency doesn't exists in the latest list");
        _;
    }

    modifier onlyEgpAccount(string memory _orgId) {
        (bool success, bytes memory data) = permIntfAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                msg.sender,
                _orgId
            )
        );
        require(
            success,
            "permissions call failed"
        );
        require(
            abi.decode(data, (bool)),
            "account does not exists or exists but doesn't belong to passed orgId"
        );
        _;
    }

    modifier paymentAdviceExists(bytes8 _uid) {
        require(0!=paymentAdviceModel.getPaymentAdviceIndex(_uid), "UID does not exist");
        _;
    }

    modifier validatePeAndVendorGids(PaymentAdvice memory _paymentAdvice) {
        require(vendorManager.isGidActive(_paymentAdvice.vendorGid), "Vendor GID not active");
        require(procuringEntityManager.isGidExists(_paymentAdvice.procuringEntityGid), "Procuring Entity GID does not exist");
        _;
    }


    modifier checkPaReferenceNumberByEgpAccount (string memory _paymentAdviceReferenceNumber, string memory _egpSystemId) {
        require(paymentAdviceModel.getPaymentAdviceIndexListLengthByPaymentAdviceAndEgpId(
            bytes8(keccak256(abi.encodePacked(_paymentAdviceReferenceNumber,_egpSystemId)))) > 0, "Initial PA is not been submitted or PaymentAdvice Ref Number not found in the system to submit amendment" );
        _;
    }

    modifier checkPaReferenceNumberExists (string memory _paymentAdviceReferenceNumber) {
        require(paymentAdviceModel.getMapPaymentAdviceReferenceNumber(_paymentAdviceReferenceNumber) == 0, "PA with this reference number already exists in the system" );
        _;
    }

    function registerPaymentAdvice(PaymentAdvice memory _paymentAdvice) public 
    onlyEgpAccount(_paymentAdvice.egpSystemId)
    validatePeAndVendorGids(_paymentAdvice)
    checkPaReferenceNumberExists(_paymentAdvice.paymentAdviceReferenceNumber)
    validCurrency(_paymentAdvice.currency) {
        uint id = paymentAdviceModel.getPaymentAdviceListLength();
        bytes8 uid = _generateUID(_paymentAdvice);
        require(paymentAdviceModel.getPaymentAdviceIndex(uid)==0, "Payment Advice already published");
        _paymentAdvice.uid = uid;
        paymentAdviceModel.setPaymentAdviceIndex(uid, 1+id);
        _addPaymentAdvideIndexes(id, _paymentAdvice);
        paymentAdviceModel.incPaymentAdviceListLength();
        paymentAdviceModel.addPaymentAdvice(id, _paymentAdvice);
        emit PaymentAdviceRegistered(_paymentAdvice.uid, _paymentAdvice.paymentAdviceReferenceNumber, 
        _paymentAdvice.procuringEntityGid);
    }


    function amendedPaymentAdvice(PaymentAdvice memory _paymentAdvice) public
    onlyEgpAccount(_paymentAdvice.egpSystemId)
    checkPaReferenceNumberByEgpAccount(_paymentAdvice.paymentAdviceReferenceNumber,_paymentAdvice.egpSystemId)
    validCurrency(_paymentAdvice.currency) {
        uint id = paymentAdviceModel.getPaymentAdviceListLength();
        uint _PrevIndex;
        (_paymentAdvice, _PrevIndex) = paymentAdviceModel.generatePaymentAdvice(_paymentAdvice);
        bytes8 uid = _generateUID(_paymentAdvice);
        require(paymentAdviceModel.getPaymentAdviceIndex(uid)==0,"Payment Advice already published");
        _paymentAdvice.uid = uid;
        paymentAdviceModel.setPaymentAdviceIndex(uid, 1+id);
        paymentAdviceModel.addPaymentAdviceIndexListByPaymentAdviceAndEgpId(
            bytes8(keccak256(abi.encodePacked(_paymentAdvice.paymentAdviceReferenceNumber,_paymentAdvice.egpSystemId))), id);
        paymentAdviceModel.incPaymentAdviceListLength();
        paymentAdviceModel.updatePreviousPAtoOutdated(_PrevIndex);
        paymentAdviceModel.addPaymentAdvice(id, _paymentAdvice);
        emit AmendmentPaymentAdviceRegistered(_paymentAdvice.uid, _paymentAdvice.paymentAdviceReferenceNumber, 
        _paymentAdvice.procuringEntityGid, _paymentAdvice.amendment);
    }

    function getAllPaymentAdvice(uint _toExcluded, uint _count) external view 
    returns(PaymentAdvice[] memory _paymentAdvice, uint fromIncluded_, uint length_) {
        (_paymentAdvice, fromIncluded_, length_) = paymentAdviceModel.getAllPaymentAdvice(_toExcluded, _count);
    }

    function getLatestPaUidByReferenceNumber (string memory _paymentAdviceReferenceNumber) public view 
    returns (bytes8){
        string memory _egpSystemId = paymentAdviceModel.getMapPaymentAdviceReferenceNumberToEgpId(_paymentAdviceReferenceNumber);
        uint _prevIndex = paymentAdviceModel.getPreviousIndex(_paymentAdviceReferenceNumber, _egpSystemId);
        return paymentAdviceModel.getPaymentAdviceUid(_prevIndex);
    }

    function getLatestPaByReferenceNumber (string memory _paymentAdviceReferenceNumber) public view 
    returns (PaymentAdvice memory _pa){
        bytes8 _paUid = getLatestPaUidByReferenceNumber(_paymentAdviceReferenceNumber);
        _pa = getPaymentAdvice(_paUid);
    }

    function getPaymentAdviceListByPaymentAdviceRefAndEgpId(string memory _paymentAdviceReferenceNumber, string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns (PaymentAdvice[] memory paymentAdvices_, uint fromIncluded_, uint length_) {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_paymentAdviceReferenceNumber,_egpSystemId)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = paymentAdviceModel.getPaymentAdviceIndexListByPaymentAdviceAndEgpId(uid, _toExcluded, _count);
        paymentAdvices_ = new PaymentAdvice[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            paymentAdvices_[i] = paymentAdviceModel.getPaymentAdviceByIndex(indexList[i]);
        }
    }

    function getPaymentAdviceUidsByPaymentAdviceRefAndEgpId(string memory _paymentAdviceReferenceNumber, string memory _egpSystemId, uint _toExcluded, uint _count) public view 
    returns (bytes8[] memory uids_, uint fromIncluded_, uint length_) {
        bytes8 uid = bytes8(keccak256(abi.encodePacked(_paymentAdviceReferenceNumber,_egpSystemId)));
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = paymentAdviceModel.getPaymentAdviceIndexListByPaymentAdviceAndEgpId(uid, _toExcluded, _count);
        uids_ = new bytes8[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            uids_[i] = paymentAdviceModel.getPaymentAdviceUid(indexList[i]);
        }
    }

    function getPaymentAdviceUidsByVendorGid(string memory _vendorGid, uint _toExcluded, uint _count) public view 
    returns (bytes8[] memory uids_, uint fromIncluded_, uint length_) {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = paymentAdviceModel.getPaymentAdviceIndexListByVendorGid(_vendorGid, _toExcluded, _count);
        uids_ = new bytes8[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            uids_[i] = paymentAdviceModel.getPaymentAdviceUid(indexList[i]);
        }
    }

    function getPaymentAdviceUidsByEgpId(string memory _egpId, uint _toExcluded, uint _count) public view 
    returns (bytes8[] memory uids_, uint fromIncluded_, uint length_) {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = paymentAdviceModel.getPaymentAdviceIndexListByEgpId(_egpId, _toExcluded, _count);
        uids_ = new bytes8[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            uids_[i] = paymentAdviceModel.getPaymentAdviceUid(indexList[i]);
        }
    }

    function getPaymentAdviceUidsByProcuringEntityGid(string memory _gid, uint _toExcluded, uint _count) public view 
    returns (bytes8[] memory uids_, uint fromIncluded_, uint length_) {
        uint[] memory indexList;
        (indexList, fromIncluded_, length_) = paymentAdviceModel.getPaymentAdviceIndexListByProcuringEntityGid(_gid, _toExcluded, _count);
        uids_ = new bytes8[](indexList.length);
        for (uint256 i = 0; i < indexList.length; i++) {
            uids_[i] = paymentAdviceModel.getPaymentAdviceUid(indexList[i]);
        }
    }

    function getPaymentAdvice(bytes8 _uid) public view 
    paymentAdviceExists(_uid) 
    returns (PaymentAdvice memory paymentAdvice_) {
        paymentAdvice_ = paymentAdviceModel.getPaymentAdviceByIndex(_getPaymentAdviceIndex(_uid));
    }

    function getPaymentAdviceVendorGidbyUid (bytes8 _uid) public view
    paymentAdviceExists(_uid) 
    returns (string memory _gid)
    {
        uint256 _index = paymentAdviceModel.getPaymentAdviceIndex(_uid) - 1;
        return paymentAdviceModel.getPaymentAdviceVendorGid(_index); 
    }

    function getPaymentAdviceProcuringEntityGidyUid (bytes8 _uid) public view
    paymentAdviceExists(_uid) 
    returns (string memory _gid)
    {
        uint256 _index = paymentAdviceModel.getPaymentAdviceIndex(_uid) - 1;
        return paymentAdviceModel.getPaymentAdviceProcuringEntityGid(_index); 
    }


    function isUidExists(bytes8 _uid) external view 
    returns (bool) {
        return 0!=paymentAdviceModel.getPaymentAdviceIndex(_uid);
    }

    function _generateUID(PaymentAdvice memory _paymentAdvice) public pure returns (bytes8){
        return bytes8(keccak256(abi.encodePacked(_paymentAdvice.egpSystemId,_paymentAdvice.paymentAdviceReferenceNumber,
        _paymentAdvice.validityPeriodDays, _paymentAdvice.bankGuaranteeClaimExpiryDate, _paymentAdvice.currency,
        _paymentAdvice.bankGuaranteeAmount, _paymentAdvice.vendorGid, _paymentAdvice.vendorName, _paymentAdvice.procuringEntityGid, 
        _paymentAdvice.procuringEntityName, _paymentAdvice.amendment)));
    }

    function _addPaymentAdvideIndexes(uint _id, PaymentAdvice memory _paymentAdvice) internal {
        paymentAdviceModel.addPaymentAdviceIndexListByPaymentAdviceAndEgpId(
            bytes8(keccak256(abi.encodePacked(_paymentAdvice.paymentAdviceReferenceNumber,_paymentAdvice.egpSystemId))), _id);
        paymentAdviceModel.addPaymentAdviceIndexListByEgpId(_paymentAdvice.egpSystemId, _id);
        paymentAdviceModel.addPaymentAdviceIndexListByVendorGid(_paymentAdvice.vendorGid, _id);
        paymentAdviceModel.addPaymentAdviceIndexListByProcuringEntityGid(_paymentAdvice.procuringEntityGid, _id);
        paymentAdviceModel.addMapPaymentAdviceReferenceNumber(_paymentAdvice.paymentAdviceReferenceNumber, _paymentAdvice.egpSystemId);
    }


    function _getPaymentAdviceIndex(bytes8 _uid) internal view 
    returns (uint) {
        return paymentAdviceModel.getPaymentAdviceIndex(_uid) - 1;
    }
    
    function getPaymentAdviceCurrencyType (bytes8 _uid) public view
    paymentAdviceExists(_uid)
    returns (string memory currency_)
    {
        currency_ = paymentAdviceModel.getPaymentAdviceBankGuaranteeCurrency(_getPaymentAdviceIndex(_uid));
    }

    function getPaymentAdviceBGAmount(bytes8 _uid) public view
    returns(uint) {

        uint256 _index = paymentAdviceModel.getPaymentAdviceIndex(_uid) - 1;
        return paymentAdviceModel.getPaymentAdviceBankGuaranteeAmount(_index);
    }

    function getPaymentAdviceReferenceNumberExist (string memory _paymentAdviceReferenceNumber) public view
    returns(uint)
    {
        return paymentAdviceModel.getMapPaymentAdviceReferenceNumber(_paymentAdviceReferenceNumber);
    }

}