pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";


contract BankGuaranteeInvokeStructs{

    uint16 constant internal __InvokeVERSION__ = 1;


    struct BankGuaranteeInvoke {
        bytes8 uid;
        bytes8 bankGuaranteeUid;
        string paymentReference;
        string procuringEntityGid;
        string egpSystemId;
        string vendorGid;
        string bankGid;
        string branchName;
        uint revocationDate;
        string currency;
        uint revocationAmount;
        string beneficiaryName;
        string beneficiaryBankAccountNumber;
        string beneficiaryBankName;
        string beneficiaryBranchName;
        string beneficiaryIfscCode;
        string bgInvokeFileHash;
        uint16 version;
    }

    string constant internal propNameBgInvokeUid = "uid";
    string constant internal propNameBgInvokeBankGuaranteeUid = "bankGuaranteeUid";
    string constant internal propNameBgInvokePaymentReference = "paymentReference";
    string constant internal propNameBgInvokeProcuringEntityGid = "procuringEntityGid";
    string constant internal propNameBgInvokeEgpSystemId = "egpSystemId";
    string constant internal propNameBgInvokeVendorGid = "vendorGid";
    string constant internal propNameBgInvokeBankGid = "bankGid";
    string constant internal propNameBgInvokeBranchName = "branchName";
    string constant internal propNameBgInvokeRevocationDate = "revocationDate";
    string constant internal propNameBgInvokeRevocationCurrencyType = "invokecurrency";
    string constant internal propNameBgInvokeRevocationAmount = "revocationAmount";
    string constant internal propNameBgInvokeBeneficiaryName = "beneficiaryName";
    string constant internal propNameBgInvokeBeneficiaryBankAccountNumber = "beneficiaryBankAccountNumber";
    string constant internal propNameBgInvokeBeneficiaryBankName = "beneficiaryBankName";
    string constant internal propNameBgInvokeBeneficiaryBranchName = "beneficiaryBranchName";
    string constant internal propNameBgInvokeBeneficiaryIfscCode = "beneficiaryIfscCode";
    string constant internal propNameBgInvokeBgInvokeFileHash = "bgInvokeFileHash";
    string constant internal propNameBgInvokeVersion = "version";


}    


contract BankGuaranteeInvokeModel is BankGuaranteeInvokeStructs {

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

    string constant internal KEY = "BANK_GUARANTEE_RELEASE_MANAGER";
    string constant internal keyListLength = "__length";


    string constant internal bankGuaranteeInvokeList = "list__bankGuaranteeInvokeList";
    string constant internal bankGuaranteeInvokeIndex = "map__bankGuaranteeInvokeIndex";
    string constant internal bgInvokeIndexListByBgUid = "map__bgInvokeIndexListByBgUid";
    string constant internal bgInvokeListByBankGID = "map__bgInvokeListByBankGID";
    string constant internal bgInvokeListByEgpID = "map__bgInvokeListByEgpID";
    string constant internal bgInvokeListByBgRefAndBankGid = "map__bgInvokeListByBgRefAndBankGid";
    string constant internal bgInvokeListByPaRefAndBankGid = "map__bgInvokeListByPaRefAndBankGid";
    string constant internal bgReleaseIndexListByBgUid = "map__bgReleaseIndexListByBgUid";


    string constant internal bgReleaseAndInvokeListByBgUid = "map__bgReleaseAndInvokeListByBgUid";
    string constant internal mapBgReleaseAndInvokeByUid = "map__mapBgReleaseAndInvokeByUid";

    modifier onlyBankGuaranteeInvokeManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validBankGuaranteeInvokeListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, bankGuaranteeInvokeList);
        require(_index < length, "Index Invalid");
        _;
    }


    function getBankGuaranteeInvokeIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, bankGuaranteeInvokeIndex, _uid);
    }

    function getBgInvokeIndexListByBgUid(bytes8 _uid) public view returns (uint[] memory bgInvokeIndexList_) {
        uint length = Map.getByKeyBytes8ToUint(KEY, bgInvokeIndexListByBgUid, _uid, abi.encodePacked(keyListLength));
        bgInvokeIndexList_ = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            bgInvokeIndexList_[i] = Map.getByKeyBytes8ToUint(KEY, bgInvokeIndexListByBgUid, _uid, abi.encodePacked(i));
        }
    }


    function getBankGuaranteeInvokeListLength() public view returns (uint256) {
        return List.getLength(KEY, bankGuaranteeInvokeList);
    }

    function getBankGuaranteeInvokeByIndex(uint256 _index)
        public
        view
        validBankGuaranteeInvokeListIndex(_index)
        returns (BankGuaranteeInvoke memory bankGuaranteeInvoke_)
    {
        bankGuaranteeInvoke_.uid = getBgInvokeUid(_index);
        bankGuaranteeInvoke_.bankGuaranteeUid = getBgInvokeBankGuaranteeUid(_index);
        bankGuaranteeInvoke_.paymentReference = getBgInvokePaymentReference(_index);
        bankGuaranteeInvoke_.procuringEntityGid = getBgInvokeProcuringEntityGid(_index);
        bankGuaranteeInvoke_.egpSystemId = getBgInvokeEgpSystemId(_index);
        bankGuaranteeInvoke_.vendorGid = getBgInvokeVendorGid(_index);
        bankGuaranteeInvoke_.bankGid = getBgInvokeBankGid(_index);
        bankGuaranteeInvoke_.branchName = getBgInvokeBranchName(_index);
        bankGuaranteeInvoke_.revocationDate = getBgInvokeRevocationDate(_index);
        bankGuaranteeInvoke_.currency = getBgInvokeRevocationCurrencyType(_index);
        bankGuaranteeInvoke_.revocationAmount = getBgInvokeRevocationAmount(_index);
        bankGuaranteeInvoke_.beneficiaryName = getBgInvokeBeneficiaryName(_index);
        bankGuaranteeInvoke_.beneficiaryBankAccountNumber = getBgInvokeBeneficiaryBankAccountNumber(_index);
        bankGuaranteeInvoke_.beneficiaryBankName = getBgInvokeBeneficiaryBankName(_index);
        bankGuaranteeInvoke_.beneficiaryBranchName = getBgInvokeBeneficiaryBranchName(_index);
        bankGuaranteeInvoke_.beneficiaryIfscCode = getBgInvokeBeneficiaryIfscCode(_index);
        bankGuaranteeInvoke_.bgInvokeFileHash = getBgInvokeBgInvokeFileHash(_index);
        bankGuaranteeInvoke_.version = getBgInvokeVersion(_index);
    }

    function getAllBankGuaranteeInvoke(uint _toExcluded, uint _count) external view 
    returns(BankGuaranteeInvoke[] memory _bankGuaranteeInvoke, uint fromIncluded_, uint length_) {
        uint length = getBankGuaranteeInvokeListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bankGuaranteeInvoke = new BankGuaranteeInvoke[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bankGuaranteeInvoke[_bankGuaranteeInvoke.length-itr-1] = getBankGuaranteeInvokeByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getBgInvokeUid(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeUid);
    }

    function getBgInvokeBankGuaranteeUid(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBankGuaranteeUid);
    }

    function getBgInvokePaymentReference(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokePaymentReference);
    }

    function getBgInvokeProcuringEntityGid(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeProcuringEntityGid);
    }

    function getBgInvokeEgpSystemId(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeEgpSystemId);
    }

    function getBgInvokeVendorGid(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeVendorGid);
    }

    function getBgInvokeBankGid(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBankGid);
    }

    function getBgInvokeBranchName(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBranchName);
    }

    function getBgInvokeRevocationDate(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeRevocationDate);
    }

    function getBgInvokeRevocationCurrencyType(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeRevocationCurrencyType);
    }

    function getBgInvokeRevocationAmount(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeRevocationAmount);
    }

    function getBgInvokeBeneficiaryName(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryName);
    }

    function getBgInvokeBeneficiaryBankAccountNumber(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryBankAccountNumber);
    }

    function getBgInvokeBeneficiaryBankName(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryBankName);
    }

    function getBgInvokeBeneficiaryBranchName(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryBranchName);
    }

    function getBgInvokeBeneficiaryIfscCode(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryIfscCode);
    }

    function getBgInvokeBgInvokeFileHash(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBgInvokeFileHash);
    }

    function getBgInvokeVersion(uint256 _index) public view 
    validBankGuaranteeInvokeListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeVersion);
    }

    function getReleaseInvokeStatus (bytes8 _Uid, uint _value) public view
    returns (uint) {
        return Map.getByKeyBytes8ToUint(KEY, mapBgReleaseAndInvokeByUid, _Uid, abi.encodePacked(_value));
    }




    /** @dev Listing out the Bank Guarantee Invokes against the Bank Gid.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByBankGID List of Bank Guarantee Invokes against the Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Bank Gid.
      */
    function getBgInvokeListByBankGID(string memory _bankGid, uint _toExcluded, uint _count) public view returns(uint[] memory _bgInvokeListByBankGID, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, bgInvokeListByBankGID, _bankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgInvokeListByBankGID = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgInvokeListByBankGID[_bgInvokeListByBankGID.length-itr-1] = Map.getByKeyStringToUint(KEY, bgInvokeListByBankGID, _bankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }
    
    
    /** @dev Listing out the Bank Guarantee Invokes against the EgpSystem Id.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByEgpID List of Bank Guarantee Invokes against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getBgInvokeListByEgpID(string memory _egpSystemId, uint _toExcluded, uint _count) public view returns(uint[] memory _bgInvokeListByEgpID, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, bgInvokeListByEgpID, _egpSystemId, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgInvokeListByEgpID = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgInvokeListByEgpID[_bgInvokeListByEgpID.length-itr-1] = Map.getByKeyStringToUint(KEY, bgInvokeListByEgpID, _egpSystemId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Bank Guarantee Invokes against the Reference Number and Bank Gid.
      * @param _bgInvokeBgRefBankGid Reference number of bank Guarantee AND Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByBgRefAndBankGid List of Bank Guarantee Invokes against the Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Reference Number and Bank Gid.
      */
    function getBgInvokeListByBgRefAndBankGid(bytes8 _bgInvokeBgRefBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bgInvokeListByBgRefAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgInvokeBgRefBankGid = bytes8(keccak256(abi.encodePacked(_bgReferenceNumber, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bgInvokeListByBgRefAndBankGid, _bgInvokeBgRefBankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgInvokeListByBgRefAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgInvokeListByBgRefAndBankGid[_bgInvokeListByBgRefAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bgInvokeListByBgRefAndBankGid, _bgInvokeBgRefBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    /** @dev Listing out the Bank Guarantee Invokes against the Payment Advice Reference Number and Bank Gid.
      * @param _bgInvokePaRefBankGid Reference number of Payment Advice and Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgInvokeListByPaRefAndBankGid List of Bank Guarantee Invokes against the Payment Advice Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Payment Advice Reference Number and Bank Gid.
      */
    function getBgInvokeListByPaRefAndBankGid(bytes8 _bgInvokePaRefBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bgInvokeListByPaRefAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgInvokePaRefBankGid = bytes8(keccak256(abi.encodePacked(_paReferenceNumber, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bgInvokeListByPaRefAndBankGid, _bgInvokePaRefBankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgInvokeListByPaRefAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgInvokeListByPaRefAndBankGid[_bgInvokeListByPaRefAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bgInvokeListByPaRefAndBankGid, _bgInvokePaRefBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }



    //WRITE

    function setBankGuaranteeInvokeIndex(bytes8 _uid, uint _value) public 
    onlyBankGuaranteeInvokeManager {
        Map.setBytes8ToUint(KEY, bankGuaranteeInvokeIndex, _uid, _value);
    }

    function addBgInvokeIndexListByBgUid(bytes8 _uid, uint _index) public 
    onlyBankGuaranteeInvokeManager {
        uint length = Map.getByKeyBytes8ToUint(KEY, bgInvokeIndexListByBgUid, _uid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgInvokeIndexListByBgUid, _uid, abi.encodePacked(length), _index);
        Map.setByKeyBytes8ToUint(KEY, bgInvokeIndexListByBgUid, _uid, abi.encodePacked(keyListLength), 1 + length);
    }

    function incBankGuaranteeInvokeListLength() public 
    onlyBankGuaranteeInvokeManager {
        List.incLength(KEY, bankGuaranteeInvokeList);
    }

    function addBankGuaranteeInvoke(uint _index, BankGuaranteeInvoke memory _BankGuaranteeInvoke) public
    onlyBankGuaranteeInvokeManager
    validBankGuaranteeInvokeListIndex(_index) {
        List.setPropBytes8(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeUid,  _BankGuaranteeInvoke.uid);
        List.setPropBytes8(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBankGuaranteeUid,  _BankGuaranteeInvoke.bankGuaranteeUid);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokePaymentReference,  _BankGuaranteeInvoke.paymentReference);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeProcuringEntityGid,  _BankGuaranteeInvoke.procuringEntityGid);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeEgpSystemId,  _BankGuaranteeInvoke.egpSystemId);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeVendorGid,  _BankGuaranteeInvoke.vendorGid);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBankGid,  _BankGuaranteeInvoke.bankGid);  
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBranchName,  _BankGuaranteeInvoke.branchName);
        List.setPropUint(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeRevocationDate,  _BankGuaranteeInvoke.revocationDate);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeRevocationCurrencyType,  _BankGuaranteeInvoke.currency);
        List.setPropUint(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeRevocationAmount,  _BankGuaranteeInvoke.revocationAmount);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryName,  _BankGuaranteeInvoke.beneficiaryName);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryBankAccountNumber,  _BankGuaranteeInvoke.beneficiaryBankAccountNumber);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryBankName,  _BankGuaranteeInvoke.beneficiaryBankName);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryBranchName,  _BankGuaranteeInvoke.beneficiaryBranchName);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBeneficiaryIfscCode,  _BankGuaranteeInvoke.beneficiaryIfscCode);
        List.setPropString(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeBgInvokeFileHash,  _BankGuaranteeInvoke.bgInvokeFileHash);
        List.setPropUint16(KEY, bankGuaranteeInvokeList, _index, propNameBgInvokeVersion, __InvokeVERSION__);
    }

    
    /** @dev Setting the Bank Guarantee Invokes against the Bank Gid, Setting the Bank Guarantee Invokes against the EgpSystem Id , Setting the Bank Guarantee Invokes against the Bank Guarantee Reference Number and Bank Gid, Setting the Bank Guarantee Invokes against the Payment Advice Reference Number and Bank Gid.
      * @param _BankGuaranteeInvoke Bank guarantee Invoke details.
      * @param _value Index of Bank guarantee Invoke.
      * @param _referenceNumber Bank Guarantee Reference Number.
      */
    function setBankGuaranteeInvokeIndices(BankGuaranteeInvoke memory _BankGuaranteeInvoke, uint _value, string memory _referenceNumber) public 
    onlyBankGuaranteeInvokeManager
    {
        // set bgInvokeListByBankGID
        uint length = Map.getByKeyStringToUint(KEY, bgInvokeListByBankGID, _BankGuaranteeInvoke.bankGid, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, bgInvokeListByBankGID, _BankGuaranteeInvoke.bankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyStringToUint(KEY, bgInvokeListByBankGID, _BankGuaranteeInvoke.bankGid, abi.encodePacked(length), _value);
        
        // set bgInvokeListByEgpID
        length = Map.getByKeyStringToUint(KEY, bgInvokeListByEgpID, _BankGuaranteeInvoke.egpSystemId, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, bgInvokeListByEgpID, _BankGuaranteeInvoke.egpSystemId, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyStringToUint(KEY, bgInvokeListByEgpID, _BankGuaranteeInvoke.egpSystemId, abi.encodePacked(length), _value);
        
        // set bgInvokeListByBgRefAndBankGid
        bytes8 _bgInvokeBgRefBankGid = bytes8(keccak256(abi.encodePacked(_referenceNumber, _BankGuaranteeInvoke.bankGid)));
        length = Map.getByKeyBytes8ToUint(KEY, bgInvokeListByBgRefAndBankGid, _bgInvokeBgRefBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgInvokeListByBgRefAndBankGid, _bgInvokeBgRefBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bgInvokeListByBgRefAndBankGid, _bgInvokeBgRefBankGid, abi.encodePacked(length), _value);
        

        // set BgInvokeListByPaRefAndBankGid
        bytes8 _bgInvokePaRefBankGid = bytes8(keccak256(abi.encodePacked(_BankGuaranteeInvoke.paymentReference, _BankGuaranteeInvoke.bankGid)));
        length = Map.getByKeyBytes8ToUint(KEY, bgInvokeListByPaRefAndBankGid, _bgInvokePaRefBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgInvokeListByPaRefAndBankGid, _bgInvokePaRefBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bgInvokeListByPaRefAndBankGid, _bgInvokePaRefBankGid, abi.encodePacked(length), _value);

        _setBgReleaseAndInvokeListByBgUid(_BankGuaranteeInvoke.bankGuaranteeUid, _value);  
        
    }

    function _setBgReleaseAndInvokeListByBgUid(bytes8 _Uid, uint _value) internal
    {
        // set bgReleaseAndInvokeListByBgUid
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _Uid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _Uid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _Uid, abi.encodePacked(length), _value);
        Map.setByKeyBytes8ToUint(KEY, mapBgReleaseAndInvokeByUid, _Uid, abi.encodePacked(_value), 1);
    }

}