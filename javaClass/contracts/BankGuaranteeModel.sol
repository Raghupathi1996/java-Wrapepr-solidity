pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract BankGuaranteeStructs{

    uint16 constant internal __VERSION__ = 1;
 
    enum FormStatus {OUTDATED, ACTIVE}
    
    struct BankGuarantee {
        bytes8 uid;
        string bankGid;
        string paymentAdviceNumber;
        bytes8 paymentAdviceUid;
        string referenceNumber;
        string branchName;
        string bankRepresentativeName;
        uint issuanceDate;
        uint validityPeriod;
        uint claimExpiryDate;
        uint validFrom;
        uint validTill;
        string currency;
        uint amount;
        string beneficiaryName;
        string fileHash;
        string bankEncryptedKey;
        string egpEncryptedKey;
        string vendorEncryptedKey;
        uint amendment;
        FormStatus formStatus;
        uint16 version;        
    }

    string constant internal propNameBankGuaranteeUid = "uid";
    string constant internal propNameBankGuaranteeBankGid = "bankGid";
    string constant internal propNameBankGuaranteePaymentAdviceNumber = "paymentAdviceNumber";
    string constant internal propNameBankGuaranteePaymentAdviceUid = "paymentAdviceUid";
    string constant internal propNameBankGuaranteeReferenceNumber = "ReferenceNumber";
    string constant internal propNameBankGuaranteeBranchName = "branchName";
    string constant internal propNameBankGuaranteeBankRepresentativeName = "bankRepresentativeName";
    string constant internal propNameBankGuaranteeIssuanceDate = "issuanceDate";
    string constant internal propNameBankGuaranteeValidityPeriod = "validityPeriod";
    string constant internal propNameBankGuaranteeClaimExpiryDate = "claimExpiryDate";
    string constant internal propNameBankGuaranteeValidFrom = "validFrom";
    string constant internal propNameBankGuaranteeValidTill = "validTill";
    string constant internal propNameBankGuaranteeCurrency = "currency"; 
    string constant internal propNameBankGuaranteeAmount = "amount";    
    string constant internal propNameBankGuaranteeBeneficiaryName = "beneficiaryName";
    string constant internal propNameBankGuaranteeFileHash = "fileHash";
    string constant internal propNameBankGuaranteeBankEncryptedKey = "bankEncryptedKey";
    string constant internal propNameBankGuaranteeEgpEncryptedKey = "egpEncryptedKey";
    string constant internal propNameBankGuaranteeVendorEncryptedKey = "vendorEncryptedKey";
    string constant internal propNameBankGuaranteeAmendment = "amendment";
    string constant internal propNameBankGuaranteeFormStatus = "formStatus";
    string constant internal propNameBankGuaranteeVersion = "version";

}


contract BankGuaranteeModel is BankGuaranteeStructs {
    
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

    string constant internal KEY = "BANK_GUARANTEE_MANAGER";
    string constant internal keyListLength = "__length";


    string constant internal bankGuaranteeList = "list__bankGuaranteeList";
    string constant internal amendmentBankGuaranteeList = "list__amendmentBankGuaranteeList";
    string constant internal bankGuaranteeIndex = "map__bankGuaranteeIndex";
    string constant internal amendmentBankGuaranteeIndex = "map__amendmentBankGuaranteeIndex";
    string constant internal bankGuaranteeRefNumber = "map__bankGuaranteeRefNumber";
    string constant internal bankGuaranteeByBankGid = "map__bankGuaranteeByBankGid";
    string constant internal bankGuaranteeIndexListByPaymentAdviceAndBankGid = "map__bankGuaranteeIndexListByPaymentAdviceAndBankGid";
    string constant internal bankGuaranteeByPaymentAdviceUid = "map__bankGuaranteeByPaymentAdviceUid";
    string constant internal bankGuaranteeByBankGidAndPaymentAdviceUid = "map__bankGuaranteeByBankGidAndPaymentAdviceUid";
    string constant internal bankGuaranteeByBgReferenceAndBankGid = "map__bankGuaranteeByBgReferenceAndBankGid";
    string constant internal bankGuaranteeByVendorAndBankGid = "map__bankGuaranteeByVendorAndBankGid";
    string constant internal bankGuaranteeByPEAndBankGid = "map__bankGuaranteeByPEAndBankGid";
    string constant internal bankGuaranteeStatusByBgUid = "map__bankGuaranteeStatusByBgUid";

    modifier onlyBankGuaranteeManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validBankGuaranteeListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, bankGuaranteeList);
        require(_index < length, "Index Invalid");
        _;
    }

    // Bank Gurantee

    function getBankGuaranteeIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, bankGuaranteeIndex, _uid);
    }

    function getBankGuaranteeIndexListLengthByPaymentAdviceAndBankGid(bytes8 _uid) public view returns(uint) {
        return Map.getByKeyBytes8ToUint(KEY, bankGuaranteeIndexListByPaymentAdviceAndBankGid, _uid, abi.encodePacked(keyListLength));
    }

    function getAmendmentBankGuaranteeIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, amendmentBankGuaranteeIndex, _uid);
    }

    function getBankGuaranteeByBankGidAndPaymentAdviceUidListLength(string memory _bankGid, bytes8 _paymentAdviceUid) public view returns (uint256) {
        bytes8 _key = bytes8(keccak256(abi.encodePacked(_paymentAdviceUid, _bankGid)));
        return Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBankGidAndPaymentAdviceUid, _key, abi.encodePacked(keyListLength));
    }

    function getBankGuaranteeListLength() public view returns (uint256) {
        return List.getLength(KEY, bankGuaranteeList);
    }

    function getBankGuaranteeByIndex(uint256 _index)
        public
        view
        validBankGuaranteeListIndex(_index)
        returns (BankGuarantee memory bankGuarantee_)
    {
        bankGuarantee_.uid = getBankGuaranteeUid(_index);
        bankGuarantee_.bankGid = getBankGuaranteeBankGid(_index);
        bankGuarantee_.paymentAdviceNumber = getBankGuaranteePaymentAdviceNumber(_index);
        bankGuarantee_.paymentAdviceUid = getBankGuaranteePaymentAdviceUid(_index);
        bankGuarantee_.referenceNumber = getBankGuaranteeReferenceNumber(_index);
        bankGuarantee_.branchName = getBankGuaranteeBranchName(_index);
        bankGuarantee_.bankRepresentativeName = getBankGuaranteeBankRepresentativeName(_index);
        bankGuarantee_.issuanceDate = getBankGuaranteeIssuanceDate(_index);
        bankGuarantee_.validityPeriod = getBankGuaranteeValidityPeriod(_index);
        bankGuarantee_.claimExpiryDate = getBankGuaranteeClaimExpiryDate(_index);
        bankGuarantee_.validFrom = getBankGuaranteeValidFrom(_index);
        bankGuarantee_.validTill = getBankGuaranteeValidTill(_index);
        bankGuarantee_.currency = getBankGuaranteeCurrency(_index);
        bankGuarantee_.amount = getBankGuaranteeAmount(_index);
        bankGuarantee_.beneficiaryName = getBankGuaranteeBeneficiaryName(_index);
        bankGuarantee_.fileHash = getBankGuaranteeFileHash(_index);
        bankGuarantee_.bankEncryptedKey = getBankGuaranteeBankEncryptedKey(_index);
        bankGuarantee_.egpEncryptedKey = getBankGuaranteeEgpEncryptedKey(_index);
        bankGuarantee_.vendorEncryptedKey = getBankGuaranteeVendorEncryptedKey(_index);
        bankGuarantee_.amendment = getBankGuaranteeAmendment(_index);
        bankGuarantee_.formStatus = getBankGuaranteeFormStatus(_index);
        bankGuarantee_.version = getBankGuaranteeVersion(_index);
    }

    function getAllBankGuarantee(uint _toExcluded, uint _count) external view 
    returns(BankGuarantee[] memory _bankGuarantee, uint fromIncluded_, uint length_) {
        uint length = getBankGuaranteeListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bankGuarantee = new BankGuarantee[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bankGuarantee[_bankGuarantee.length-itr-1] = getBankGuaranteeByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getBankGuaranteeUid(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, bankGuaranteeList, _index, propNameBankGuaranteeUid);
    }

    function getBankGuaranteeBankGid(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBankGid);
    }

    function getBankGuaranteePaymentAdviceNumber(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteePaymentAdviceNumber);
    }

    function getBankGuaranteePaymentAdviceUid(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, bankGuaranteeList, _index, propNameBankGuaranteePaymentAdviceUid);
    }

    function getBankGuaranteeReferenceNumber(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeReferenceNumber);
    }

    function getBankGuaranteeBranchName(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBranchName);
    }

    function getBankGuaranteeBankRepresentativeName(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBankRepresentativeName);
    }

    function getBankGuaranteeIssuanceDate(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeIssuanceDate);
    }

    function getBankGuaranteeValidityPeriod(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeValidityPeriod);
    }

    function getBankGuaranteeClaimExpiryDate(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeClaimExpiryDate);
    }

    function getBankGuaranteeValidFrom(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeValidFrom);
    }

    function getBankGuaranteeValidTill(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeValidTill);
    }

    function getBankGuaranteeCurrency(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeCurrency);
    }

    function getBankGuaranteeAmount(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeAmount);
    }

    function getBankGuaranteeBeneficiaryName(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBeneficiaryName);
    }

    function getBankGuaranteeFileHash(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeFileHash);
    }

    function getBankGuaranteeBankEncryptedKey(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBankEncryptedKey);
    }

    function getBankGuaranteeEgpEncryptedKey(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeEgpEncryptedKey);
    }

    function getBankGuaranteeVendorEncryptedKey(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeVendorEncryptedKey);
    }

    function getBankGuaranteeAmendment(uint256 _index) public view
    validBankGuaranteeListIndex(_index)
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeAmendment);
    }

    function getBankGuaranteeFormStatus(uint256 _index) public view
    validBankGuaranteeListIndex(_index)
    returns(FormStatus) {
        return FormStatus(List.getPropUint8(KEY, bankGuaranteeList, _index, propNameBankGuaranteeFormStatus));
    }

    function getBankGuaranteeVersion(uint256 _index) public view 
    validBankGuaranteeListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, bankGuaranteeList, _index, propNameBankGuaranteeVersion);
    }


    function getBankGuaranteeIndexesByBankGid(string memory _bankGid, uint _toExcluded, uint _count) public view 
    returns (uint256[] memory indexList_, uint fromIncluded_, uint length_) {
        bytes8 key = bytes8(keccak256(abi.encodePacked(_bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBankGid, key, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        indexList_ = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            indexList_[indexList_.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBankGid, key, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getBankGuaranteeIndexByPaymentAdviceUid(bytes8 _paymentAdviceUid) public view returns (uint256 indexList_) {
        return Map.getBytes8ToUint(KEY, bankGuaranteeByPaymentAdviceUid, _paymentAdviceUid);
    }

    function getBankGuaranteforPaymentAdviceBankGid(string memory _bankGid, bytes8 _paymentAdviceUid) public view returns (uint) {
        bytes8 _key = bytes8(keccak256(abi.encodePacked(_paymentAdviceUid, _bankGid)));
        return Map.getBytes8ToUint(KEY,bankGuaranteeByBankGidAndPaymentAdviceUid, _key);
    }

    
    /** @dev Listing out the Bank Guarantees against the Reference Number and Bank Gid.
      * @param _bgRefBankGid Reference number of bank Guarantee and Global id of bank.     
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bankGuaranteeByBgReferenceAndBankGid List of Bank Guarantees against the Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Reference Number and Bank Gid.
      */
    function getBankGuaranteeByBgReferenceAndBankGid(bytes8 _bgRefBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bankGuaranteeByBgReferenceAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgRefBankGid = bytes8(keccak256(abi.encodePacked(_referenceNumber, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBgReferenceAndBankGid, _bgRefBankGid, abi.encodePacked(keyListLength)); 
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bankGuaranteeByBgReferenceAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bankGuaranteeByBgReferenceAndBankGid[_bankGuaranteeByBgReferenceAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBgReferenceAndBankGid, _bgRefBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Bank Guarantees against the Vendor Gid and Bank Gid.
      * @param _bgVendorBankGid Global id of the Vendor and Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bankGuaranteeByVendorAndBankGid List of Bank Guarantees against the Vendor Gid and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Vendor Gid and Bank Gid.
      */
    function getBankGuaranteeByVendorAndBankGid(bytes8 _bgVendorBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bankGuaranteeByVendorAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgVendorBankGid = bytes8(keccak256(abi.encodePacked(_vendorGid, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgVendorBankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bankGuaranteeByVendorAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bankGuaranteeByVendorAndBankGid[_bankGuaranteeByVendorAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgVendorBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Bank Guarantees against the PE Gid and Bank Gid.
      * @param _bgPeBankGid Global id of Procuring Entity and Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bankGuaranteeByPEAndBankGid List of Bank Guarantees against the PE Gid and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the PE Gid and Bank Gid.
      */
    function getBankGuaranteeByPEAndBankGid(bytes8 _bgPeBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bankGuaranteeByPEAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgPeBankGid = bytes8(keccak256(abi.encodePacked(_peGid, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByPEAndBankGid, _bgPeBankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bankGuaranteeByPEAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bankGuaranteeByPEAndBankGid[_bankGuaranteeByPEAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByPEAndBankGid, _bgPeBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getMapBankGuaranteeReferenceNumber (string memory _referenceNumber, string memory _bankGid) public view
    returns(uint)
    {
        bytes8 _bgPABankGid = bytes8(keccak256(abi.encodePacked(_referenceNumber, _bankGid)));
        return (Map.getBytes8ToUint(KEY, bankGuaranteeRefNumber, _bgPABankGid));
    }

    function _getPreviousIndex(bytes8 _uid) internal view 
    returns (uint) {
        uint _len = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeIndexListByPaymentAdviceAndBankGid, _uid, abi.encodePacked(keyListLength));
        uint _index = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeIndexListByPaymentAdviceAndBankGid, _uid, abi.encodePacked(_len-1));
        return _index;  
    }

    
    
    // ------------- SETTERS ------------- //
    // Bank Guarantee

    function setBankGuaranteeIndex(bytes8 _uid, uint _value) public 
    onlyBankGuaranteeManager {
        Map.setBytes8ToUint(KEY, bankGuaranteeIndex, _uid, _value);
    }

    function setAmendmentBankGuaranteeIndex(bytes8 _uid, uint _value) public 
    onlyBankGuaranteeManager {
        Map.setBytes8ToUint(KEY, amendmentBankGuaranteeIndex, _uid, _value);
    }

    function updatePreviousBgtoOutdated(uint _index) public 
    onlyBankGuaranteeManager
    {
        // _setBankGuaranteeFormStatus(_index, FormStatus.OUTDATED);
        List.setPropUint8(KEY, bankGuaranteeList, _index, propNameBankGuaranteeFormStatus, uint8(FormStatus.OUTDATED));

    }

    function addBankGuaranteeIndexListByPaymentAdviceAndBankGid(bytes8 _uid, uint _value) public 
    onlyBankGuaranteeManager {
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeIndexListByPaymentAdviceAndBankGid, _uid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeIndexListByPaymentAdviceAndBankGid, _uid, abi.encodePacked(length), _value);
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeIndexListByPaymentAdviceAndBankGid, _uid, abi.encodePacked(keyListLength), 1+length);
    }

    function incBankGuaranteeListLength() public 
    onlyBankGuaranteeManager {
        List.incLength(KEY, bankGuaranteeList);
    }

    function addBankGuarantee(uint _index, BankGuarantee memory _BankGuarantee) public
    onlyBankGuaranteeManager
    validBankGuaranteeListIndex(_index) {
        List.setPropBytes8(KEY, bankGuaranteeList, _index, propNameBankGuaranteeUid,  _BankGuarantee.uid);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBankGid,  _BankGuarantee.bankGid);       
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteePaymentAdviceNumber,  _BankGuarantee.paymentAdviceNumber);
        List.setPropBytes8(KEY, bankGuaranteeList, _index, propNameBankGuaranteePaymentAdviceUid,  _BankGuarantee.paymentAdviceUid);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeReferenceNumber,  _BankGuarantee.referenceNumber);        
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBranchName,  _BankGuarantee.branchName);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBankRepresentativeName,  _BankGuarantee.bankRepresentativeName);
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeIssuanceDate,  _BankGuarantee.issuanceDate);
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeValidityPeriod,  _BankGuarantee.validityPeriod);
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeClaimExpiryDate,  _BankGuarantee.claimExpiryDate);       
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeValidFrom,  _BankGuarantee.validFrom);
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeValidTill,  _BankGuarantee.validTill);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeCurrency,  _BankGuarantee.currency);
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeAmount,  _BankGuarantee.amount);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBeneficiaryName,  _BankGuarantee.beneficiaryName);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeFileHash,  _BankGuarantee.fileHash);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeBankEncryptedKey,  _BankGuarantee.bankEncryptedKey);
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeEgpEncryptedKey,  _BankGuarantee.egpEncryptedKey);        
        List.setPropString(KEY, bankGuaranteeList, _index, propNameBankGuaranteeVendorEncryptedKey,  _BankGuarantee.vendorEncryptedKey);
        List.setPropUint(KEY, bankGuaranteeList, _index, propNameBankGuaranteeAmendment,  _BankGuarantee.amendment);
        List.setPropUint8(KEY, bankGuaranteeList, _index, propNameBankGuaranteeFormStatus,  uint8(FormStatus.ACTIVE));
        List.setPropUint16(KEY, bankGuaranteeList, _index, propNameBankGuaranteeVersion, __VERSION__);
    }

    function generateBankGuarantee (BankGuarantee memory _bankGuarantee) public view
    onlyBankGuaranteeManager
    returns (BankGuarantee memory, uint) {
        uint _PrevIndex = _getPreviousIndex(bytes8(keccak256(abi.encodePacked(_bankGuarantee.paymentAdviceNumber,_bankGuarantee.bankGid))));
        _bankGuarantee.bankGid = getBankGuaranteeBankGid(_PrevIndex);
        _bankGuarantee.paymentAdviceNumber = getBankGuaranteePaymentAdviceNumber(_PrevIndex);
        _bankGuarantee.beneficiaryName = getBankGuaranteeBeneficiaryName(_PrevIndex);
        _bankGuarantee.amendment = getBankGuaranteeIndexListLengthByPaymentAdviceAndBankGid(bytes8(keccak256(abi.encodePacked(_bankGuarantee.paymentAdviceNumber,_bankGuarantee.bankGid))));
        _bankGuarantee.formStatus = FormStatus.ACTIVE;
        return (_bankGuarantee, _PrevIndex);
    }

    function addBankGuaranteeIndexByBankGid(string memory _bankGid, uint _value) public 
    onlyBankGuaranteeManager
    {
        bytes8 key = bytes8(keccak256(abi.encodePacked(_bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBankGid, key, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByBankGid, key, abi.encodePacked(keyListLength), 1 + length);
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByBankGid, key, abi.encodePacked(length), _value);
    }

    function setBankGuaranteeIndexByPaymentAdviceUid(bytes8 _paymentAdviceUid, uint _value) public 
    onlyBankGuaranteeManager
    {
        Map.setBytes8ToUint(KEY, bankGuaranteeByPaymentAdviceUid, _paymentAdviceUid, _value);
    }

    function addBankGuaranteforPaymentAdviceBankGid(bytes8 _paymentAdviceUid, string memory _bankGid) public 
    onlyBankGuaranteeManager
    {
        bytes8 _key = bytes8(keccak256(abi.encodePacked(_paymentAdviceUid, _bankGid)));
        Map.setBytes8ToUint(KEY,bankGuaranteeByBankGidAndPaymentAdviceUid, _key, 1);
    }
    
    /** @dev Setting the Bank Guarantees against the Reference Number and Bank Gid.
      * @param _bankGuarantee Bank guarantee struct.
      * @param _value index of the bank guarantee .
      */
    function setBankGuaranteeByBgReferenceAndBankGid(BankGuarantee memory _bankGuarantee, uint _value) public
    onlyBankGuaranteeManager
    {
        bytes8 _bgRefBankGid = bytes8(keccak256(abi.encodePacked(_bankGuarantee.referenceNumber, _bankGuarantee.bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByBgReferenceAndBankGid, _bgRefBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByBgReferenceAndBankGid, _bgRefBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByBgReferenceAndBankGid, _bgRefBankGid, abi.encodePacked(length), _value);
    }
    
    
    
    
    
    /** @dev Setting the Bank Guarantees against  Vendor Gid and Bank Gid , Setting the Bank Guarantees against the PE Gid and Bank Gid.
      * @param _bankGuarantee Bank guarantee struct.
      * @param _value index of the bank guarantee .
      * @param _vendorGid Unique GId for Vendor.
      * @param _peGid Unique GId for Procuring Entity.
      */
    function setBankGuaranteeIndices(BankGuarantee memory _bankGuarantee, uint _value, string memory _vendorGid, string memory _peGid) public 
    onlyBankGuaranteeManager
    {
       
       //set BankGuaranteeByVendorAndBankGid
       bytes8 _bgVendorBankGid = bytes8(keccak256(abi.encodePacked(_vendorGid, _bankGuarantee.bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgVendorBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgVendorBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgVendorBankGid, abi.encodePacked(length), _value);

       //set BankGuaranteeByPEAndBankGid
       bytes8 _bgPeBankGid = bytes8(keccak256(abi.encodePacked(_peGid, _bankGuarantee.bankGid)));
        length = Map.getByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgPeBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgPeBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bankGuaranteeByVendorAndBankGid, _bgPeBankGid, abi.encodePacked(length), _value);

    }

    function addMapBankGuaranteeReferenceNumber (string memory _referenceNumber, string memory _bankGid) public
    onlyBankGuaranteeManager
    {   
        bytes8 _bgRefBankGid = bytes8(keccak256(abi.encodePacked(_referenceNumber, _bankGid)));
        Map.setBytes8ToUint(KEY, bankGuaranteeRefNumber, _bgRefBankGid, 1); //should change and add it in the manager 
    }

    function setBgReleaseStatus (bytes8 _paymentAdviceUid, string memory _bankGid) public
    onlyBankGuaranteeManager 
    {
        bytes8 _key = bytes8(keccak256(abi.encodePacked(_paymentAdviceUid,_bankGid)));
        Map.setBytes8ToUint(KEY,bankGuaranteeByBankGidAndPaymentAdviceUid, _key, 0);
    }

}
