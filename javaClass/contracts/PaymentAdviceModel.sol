pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract PaymentAdviceStructs{

    uint16 constant internal __VERSION__ = 1;

    enum PaymentType {OPEN, ENCRYPTED}

    enum FormStatus {OUTDATED, ACTIVE}

    struct PaymentAdvice {
        bytes8 uid;
        string egpSystemId;
        PaymentType paymentType;
        string paymentAdviceReferenceNumber;
        uint validityPeriodDays;
        uint bankGuaranteeClaimExpiryDate;
        string currency;
        uint bankGuaranteeAmount;
        string vendorGid;
        string vendorName;
        string procuringEntityGid;
        string procuringEntityName;
        uint amendment;
        FormStatus formStatus;
        uint16 version;
    }

    string constant internal propNamePaymentAdviceUid = "uid";
    string constant internal propNamePaymentAdviceEgpSystemId = "egpSystemId";
    string constant internal propNamePaymentAdvicePaymentType = "paymentType";
    string constant internal propNamePaymentAdvicePaymentAdviceReferenceNumber = "paymentAdviceReferenceNumber";
    string constant internal propNamePaymentAdviceValidityPeriodDays = "validityPeriodDays";
    string constant internal propNamePaymentAdviceBankGuaranteeClaimExpiryDate = "bankGuaranteeClaimExpiryDate";
    string constant internal propNamePaymentAdviceBankGuaranteeCurrency  = "currency";
    string constant internal propNamePaymentAdviceBankGuaranteeAmount = "bankGuaranteeAmount";
    string constant internal propNamePaymentAdviceVendorGid = "vendorGid";
    string constant internal propNamePaymentAdviceVendorName = "vendorName";
    string constant internal propNamePaymentAdviceProcuringEntityGid = "procuringEntityGid";
    string constant internal propNamePaymentAdviceProcuringEntityName = "procuringEntityName";
    string constant internal propNamePaymentAdviceAmendment = "amendment";
    string constant internal propNamePaymentAdviceFormStatus = "formStatus";
    string constant internal propNamePaymentAdviceVersion = "version";

}


contract PaymentAdviceModel is PaymentAdviceStructs {
    
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

    string constant internal KEY = "PAYMENT_ADVICE_MANAGER";
    string constant internal keyListLength = "__length";


    string constant internal paymentAdviceList = "list__paymentAdviceList";
    string constant internal amendmentPaymentAdviceList = "list__amendmentPaymentAdviceList";
    string constant internal paymentAdviceIndex = "map__paymentAdviceIndex";
    string constant internal amendmentPaymentAdviceIndex = "map__amendmentPaymentAdviceIndex";
    string constant internal paymentAdviceRefNumber = "map__paymentAdviceRefNumber";
    string constant internal paymentAdviceRefNumberByEgpId = "map__paymentAdviceRefNumberByEgpId";
    string constant internal paymentAdviceIndexListByPaymentAdviceAndEgpId = "map__paymentAdviceIndexListByPaymentAdviceAndEgpId";
    string constant internal paymentAdviceIndexListByVendorGid = "map__paymentAdviceIndexListByVendorGid";
    string constant internal paymentAdviceIndexListByEgpId = "map__paymentAdviceIndexListByEgpId";
    string constant internal paymentAdviceIndexListByProcuringEntityGid = "map__paymentAdviceIndexListByProcuringEntityGid";


    modifier onlyPaymentAdviceManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validPaymentAdviceListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, paymentAdviceList);
        require(_index < length, "Index Invalid");
        _;
    }

   // Payment Advice 

    function getPaymentAdviceIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, paymentAdviceIndex, _uid);
    }

    function getPaymentAdviceIndexListLengthByPaymentAdviceAndEgpId(bytes8 _uid) public view 
    returns(uint) {
        return Map.getByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(keyListLength));
    }

    function getPaymentAdviceIndexListByPaymentAdviceAndEgpId(bytes8 _uid, uint _toExcluded, uint _count) public view 
    returns (uint256[] memory indexList_, uint fromIncluded_, uint length_) {
        uint length = Map.getByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        indexList_ = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            indexList_[indexList_.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getPaymentAdviceIndexListByVendorGid(string memory _uid, uint _toExcluded, uint _count) public view 
    returns (uint256[] memory indexList_, uint fromIncluded_, uint length_) {
        uint length = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByVendorGid, _uid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        indexList_ = new uint256[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            indexList_[indexList_.length-itr-1] = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByVendorGid, _uid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getPaymentAdviceIndexListByEgpId(string memory _uid, uint _toExcluded, uint _count) public view 
    returns (uint256[] memory indexList_, uint fromIncluded_, uint length_) {
        uint length = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByEgpId, _uid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        indexList_ = new uint256[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            indexList_[indexList_.length-itr-1] = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByEgpId, _uid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getPaymentAdviceIndexListByProcuringEntityGid(string memory _gid, uint _toExcluded, uint _count) public view 
    returns (uint256[] memory indexList_, uint fromIncluded_, uint length_) {
        uint length = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByProcuringEntityGid, _gid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        indexList_ = new uint256[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            indexList_[indexList_.length-itr-1] = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByProcuringEntityGid, _gid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getPaymentAdviceListLength() public view returns (uint256) {
        return List.getLength(KEY, paymentAdviceList);
    }

    function getPaymentAdviceByIndex(uint256 _index)
    public
    view
    validPaymentAdviceListIndex(_index)
    returns (PaymentAdvice memory paymentAdvice_)
    {
        paymentAdvice_.uid = getPaymentAdviceUid(_index);
        paymentAdvice_.egpSystemId = getPaymentAdviceEgpSystemId(_index);
        paymentAdvice_.paymentType = getPaymentAdvicePaymentType(_index);
        paymentAdvice_.paymentAdviceReferenceNumber = getPaymentAdvicePaymentAdviceReferenceNumber(_index);
        paymentAdvice_.validityPeriodDays = getPaymentAdviceValidityPeriodDays(_index);
        paymentAdvice_.bankGuaranteeClaimExpiryDate = getPaymentAdviceBankGuaranteeClaimExpiryDate(_index);
        paymentAdvice_.currency = getPaymentAdviceBankGuaranteeCurrency(_index);
        paymentAdvice_.bankGuaranteeAmount = getPaymentAdviceBankGuaranteeAmount(_index);
        paymentAdvice_.vendorGid = getPaymentAdviceVendorGid(_index);
        paymentAdvice_.vendorName = getPaymentAdviceVendorName(_index);
        paymentAdvice_.procuringEntityGid = getPaymentAdviceProcuringEntityGid(_index);
        paymentAdvice_.procuringEntityName = getPaymentAdviceProcuringEntityName(_index);
        paymentAdvice_.amendment = getPaymentAdviceAmendment(_index);
        paymentAdvice_.formStatus = getPaymentAdviceFormStatus(_index);
        paymentAdvice_.version = getPaymentAdviceVersion(_index);
    }

    function getAllPaymentAdvice(uint _toExcluded, uint _count) external view 
    returns(PaymentAdvice[] memory _paymentAdvice, uint fromIncluded_, uint length_) {
        uint length = getPaymentAdviceListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _paymentAdvice = new PaymentAdvice[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _paymentAdvice[_paymentAdvice.length-itr-1] = getPaymentAdviceByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getPaymentAdviceUid(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, paymentAdviceList, _index, propNamePaymentAdviceUid);
    }

    function getPaymentAdviceEgpSystemId(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceEgpSystemId);
    }

    function getPaymentAdvicePaymentType(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(PaymentType) {
        return PaymentType(List.getPropUint8(KEY, paymentAdviceList, _index, propNamePaymentAdvicePaymentType));
    }

    function getPaymentAdvicePaymentAdviceReferenceNumber(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdvicePaymentAdviceReferenceNumber);
    }

    function getPaymentAdviceValidityPeriodDays(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceValidityPeriodDays);
    }

    function getPaymentAdviceBankGuaranteeClaimExpiryDate(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceBankGuaranteeClaimExpiryDate);
    }

    function getPaymentAdviceBankGuaranteeCurrency(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceBankGuaranteeCurrency);
    }

    function getPaymentAdviceBankGuaranteeAmount(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceBankGuaranteeAmount);
    }

    function getPaymentAdviceVendorGid(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceVendorGid);
    }

    function getPaymentAdviceVendorName(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceVendorName);
    }

    function getPaymentAdviceProcuringEntityGid(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceProcuringEntityGid);
    }

    function getPaymentAdviceProcuringEntityName(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceProcuringEntityName);
    }

    function getPaymentAdviceAmendment(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceAmendment);
    }

    function getPaymentAdviceFormStatus(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(FormStatus) {
        return FormStatus(List.getPropUint8(KEY, paymentAdviceList, _index, propNamePaymentAdviceFormStatus));
    }


    function getPaymentAdviceVersion(uint256 _index) public view 
    validPaymentAdviceListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, paymentAdviceList, _index, propNamePaymentAdviceVersion);
    }

    function getMapPaymentAdviceReferenceNumber (string memory _paymentAdviceReferenceNumber) public view
    returns(uint)
    {
        return (Map.getStringToUint(KEY, paymentAdviceRefNumber, _paymentAdviceReferenceNumber));
    }

    function getMapPaymentAdviceReferenceNumberToEgpId (string memory _paymentAdviceReferenceNumber) public view
    returns(string memory)
    {
        return (Map.getStringToString(KEY, paymentAdviceRefNumberByEgpId, _paymentAdviceReferenceNumber));
    }

    function getPreviousIndex(string memory _paymentAdviceReferenceNumber, string memory _egpSystemId) public view 
    returns (uint256) {
        bytes8 _uid = bytes8(keccak256(abi.encodePacked(_paymentAdviceReferenceNumber,_egpSystemId)));
        uint _len = Map.getByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(keyListLength));
        uint256 _index = Map.getByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(_len-1));
        return _index;  
    }



    // Payment Advice
    function setPaymentAdviceIndex(bytes8 _uid, uint _value) public 
    onlyPaymentAdviceManager
    {
        Map.setBytes8ToUint(KEY, paymentAdviceIndex, _uid, _value);
    }


    function updatePreviousPAtoOutdated(uint256 _index) public
    onlyPaymentAdviceManager 
    validPaymentAdviceListIndex(_index) {
        // setPaymentAdviceFormStatus(_index, FormStatus.OUTDATED);
        List.setPropUint8(KEY, paymentAdviceList, _index, propNamePaymentAdviceFormStatus, uint8(FormStatus.OUTDATED));


    }


    function addPaymentAdviceIndexListByPaymentAdviceAndEgpId(bytes8 _uid, uint _value) public 
    onlyPaymentAdviceManager{
        uint length = Map.getByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(length), _value);
        Map.setByKeyBytes8ToUint(KEY, paymentAdviceIndexListByPaymentAdviceAndEgpId, _uid, abi.encodePacked(keyListLength), 1+length);
    }

    function addPaymentAdviceIndexListByVendorGid(string memory _vendorGid, uint _value) public 
    onlyPaymentAdviceManager {
        uint length = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByVendorGid, _vendorGid, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, paymentAdviceIndexListByVendorGid, _vendorGid, abi.encodePacked(length), _value);
        Map.setByKeyStringToUint(KEY, paymentAdviceIndexListByVendorGid, _vendorGid, abi.encodePacked(keyListLength), 1+length);
    }

    function addPaymentAdviceIndexListByEgpId(string memory _egpId, uint _value) public 
    onlyPaymentAdviceManager {
        uint length = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByEgpId, _egpId, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, paymentAdviceIndexListByEgpId, _egpId, abi.encodePacked(length), _value);
        Map.setByKeyStringToUint(KEY, paymentAdviceIndexListByEgpId, _egpId, abi.encodePacked(keyListLength), 1+length);
    }

    function addPaymentAdviceIndexListByProcuringEntityGid(string memory _gid, uint _value) public 
    onlyPaymentAdviceManager {
        uint length = Map.getByKeyStringToUint(KEY, paymentAdviceIndexListByProcuringEntityGid, _gid, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, paymentAdviceIndexListByProcuringEntityGid, _gid, abi.encodePacked(length), _value);
        Map.setByKeyStringToUint(KEY, paymentAdviceIndexListByProcuringEntityGid, _gid, abi.encodePacked(keyListLength), 1+length);
    }

    function incPaymentAdviceListLength() public
    onlyPaymentAdviceManager 
    {
        List.incLength(KEY, paymentAdviceList);
    }
    

    function addPaymentAdvice(uint _index, PaymentAdvice memory _paymentAdvice) public
    onlyPaymentAdviceManager
    validPaymentAdviceListIndex(_index) {
        setPaymentAdviceUid(_index, _paymentAdvice.uid);
        setPaymentAdviceEgpSystemId(_index, _paymentAdvice.egpSystemId);
        setPaymentAdvicePaymentType(_index, _paymentAdvice.paymentType);
        setPaymentAdvicePaymentAdviceReferenceNumber(_index, _paymentAdvice.paymentAdviceReferenceNumber);
        setPaymentAdviceValidityPeriodDays(_index, _paymentAdvice.validityPeriodDays);
        setPaymentAdviceBankGuaranteeClaimExpiryDate(_index, _paymentAdvice.bankGuaranteeClaimExpiryDate);
        setPaymentAdviceBankGuaranteeCurrency(_index, _paymentAdvice.currency);
        setPaymentAdviceBankGuaranteeAmount(_index, _paymentAdvice.bankGuaranteeAmount);
        setPaymentAdviceVendorGid(_index, _paymentAdvice.vendorGid);
        setPaymentAdviceVendorName(_index, _paymentAdvice.vendorName);
        setPaymentAdviceProcuringEntityGid(_index, _paymentAdvice.procuringEntityGid);
        setPaymentAdviceProcuringEntityName(_index, _paymentAdvice.procuringEntityName);
        setPaymentAdviceAmendment(_index, _paymentAdvice.amendment);
        setPaymentAdviceFormStatus(_index, FormStatus.ACTIVE);
        setPaymentAdviceVersion(_index);
    }


    function generatePaymentAdvice (PaymentAdvice memory _paymentAdvice) public view
    onlyPaymentAdviceManager 
    returns (PaymentAdvice memory, uint) {
        uint256 _PrevIndex = getPreviousIndex(_paymentAdvice.paymentAdviceReferenceNumber,_paymentAdvice.egpSystemId);
        _paymentAdvice.paymentType = getPaymentAdvicePaymentType(_PrevIndex);
        _paymentAdvice.vendorGid = getPaymentAdviceVendorGid(_PrevIndex);
        _paymentAdvice.vendorName = getPaymentAdviceVendorName(_PrevIndex);
        _paymentAdvice.procuringEntityGid = getPaymentAdviceProcuringEntityGid(_PrevIndex);
        _paymentAdvice.procuringEntityName = getPaymentAdviceProcuringEntityName(_PrevIndex);
        _paymentAdvice.amendment = getPaymentAdviceIndexListLengthByPaymentAdviceAndEgpId(bytes8(keccak256(abi.encodePacked(_paymentAdvice.paymentAdviceReferenceNumber,_paymentAdvice.egpSystemId))));
        _paymentAdvice.formStatus = FormStatus.ACTIVE;
        return (_paymentAdvice, _PrevIndex);
    }

    function setPaymentAdviceUid(uint256 _index, bytes8 _uid) public 
    onlyPaymentAdviceManager {
        List.setPropBytes8(KEY, paymentAdviceList, _index, propNamePaymentAdviceUid, _uid);
    }

    function setPaymentAdviceEgpSystemId(uint256 _index, string memory _egpSystemId) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceEgpSystemId, _egpSystemId);
    }

    function setPaymentAdvicePaymentType(uint256 _index, PaymentType _paymentType) public 
    onlyPaymentAdviceManager {
        List.setPropUint8(KEY, paymentAdviceList, _index, propNamePaymentAdvicePaymentType, uint8(_paymentType));
    }

    function setPaymentAdvicePaymentAdviceReferenceNumber(uint256 _index, string memory _paymentAdviceReferenceNumber) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdvicePaymentAdviceReferenceNumber, _paymentAdviceReferenceNumber);
    }

    function setPaymentAdviceValidityPeriodDays(uint256 _index, uint _validityPeriodDays) public 
    onlyPaymentAdviceManager {
        if(0==_validityPeriodDays){
            _validityPeriodDays = 180;
        }
        List.setPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceValidityPeriodDays, _validityPeriodDays);
    }

    function setPaymentAdviceBankGuaranteeClaimExpiryDate(uint256 _index, uint _bankGuaranteeClaimExpiryDate) public 
    onlyPaymentAdviceManager {
        List.setPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceBankGuaranteeClaimExpiryDate, _bankGuaranteeClaimExpiryDate);
    }

    function setPaymentAdviceBankGuaranteeCurrency(uint256 _index, string memory _currency) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceBankGuaranteeCurrency, _currency);
    }

    function setPaymentAdviceBankGuaranteeAmount(uint256 _index, uint _bankGuaranteeAmount) public 
    onlyPaymentAdviceManager {
        List.setPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceBankGuaranteeAmount, _bankGuaranteeAmount);
    }

    function setPaymentAdviceVendorGid(uint256 _index, string memory _vendorGid) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceVendorGid, _vendorGid);
    }

    function setPaymentAdviceVendorName(uint256 _index, string memory _vendorName) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceVendorName, _vendorName);
    }

    function setPaymentAdviceProcuringEntityGid(uint256 _index, string memory _procuringEntityGid) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceProcuringEntityGid, _procuringEntityGid);
    }

    function setPaymentAdviceProcuringEntityName(uint256 _index, string memory _procuringEntityName) public 
    onlyPaymentAdviceManager {
        List.setPropString(KEY, paymentAdviceList, _index, propNamePaymentAdviceProcuringEntityName, _procuringEntityName);
    }

    function setPaymentAdviceAmendment(uint256 _index, uint _amendment) public
    onlyPaymentAdviceManager 
    {
        List.setPropUint(KEY, paymentAdviceList, _index, propNamePaymentAdviceAmendment, _amendment);
    }

    function setPaymentAdviceFormStatus(uint256 _index, FormStatus _formStatus) public 
    onlyPaymentAdviceManager
    {
        List.setPropUint8(KEY, paymentAdviceList, _index, propNamePaymentAdviceFormStatus, uint8(_formStatus));
    }

    function setPaymentAdviceVersion(uint256 _index) public
    onlyPaymentAdviceManager 
    {
        List.setPropUint16(KEY, paymentAdviceList, _index, propNamePaymentAdviceVersion, __VERSION__);
    }

    function addMapPaymentAdviceReferenceNumber (string memory _paymentAdviceReferenceNumber, string memory _egpSystemId) public
    onlyPaymentAdviceManager
    {
        Map.setStringToUint(KEY, paymentAdviceRefNumber, _paymentAdviceReferenceNumber, 1);
        Map.setStringToString(KEY, paymentAdviceRefNumberByEgpId, _paymentAdviceReferenceNumber, _egpSystemId);
    }

}
