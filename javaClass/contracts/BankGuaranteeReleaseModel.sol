pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract BankGuaranteeReleaseStructs{

    uint16 constant internal __VERSION__ = 1;

    struct BankGuaranteeRelease {
        bytes8 uid;
        bytes8 bankGuaranteeUid;
        string paymentReference;
        string procuringEntityGid;
        string egpSystemId;
        string vendorGid;
        string bankGid;
        string branchName;
        uint releaseDate;
        string currency;
        uint amountReleased;
        string bgReleaseFileHash;
        uint16 version;
    }

    string constant internal propNameBgReleaseUid = "uid";
    string constant internal propNameBgReleaseBankGuaranteeUid = "bankGuaranteeUid";
    string constant internal propNameBgReleasePaymentReference = "paymentReference";
    string constant internal propNameBgReleaseProcuringEntityGid = "procuringEntityGid";
    string constant internal propNameBgReleaseEgpSystemId = "egpSystemId";
    string constant internal propNameBgReleaseVendorGid = "vendorGid";
    string constant internal propNameBgReleaseBankGid = "bankGid";
    string constant internal propNameBgReleaseBranchName = "branchName";
    string constant internal propNameBgReleaseReleaseDate = "releaseDate";
    string constant internal propNameBgReleaseCurrencyType = "releasecurrency";
    string constant internal propNameBgReleaseAmountReleased = "amountReleased";
    string constant internal propNameBgReleaseBgReleaseFileHash = "bgReleaseFileHash";
    string constant internal propNameBgReleaseVersion = "version";

    

}

contract BankGuaranteeReleaseModel is BankGuaranteeReleaseStructs {
    
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


    string constant internal bankGuaranteeReleaseList = "list__bankGuaranteeReleaseList";
    string constant internal bankGuaranteeReleaseIndex = "map__bankGuaranteeReleaseIndex";
    string constant internal bgReleaseIndexListByBgUid = "map__bgReleaseIndexListByBgUid";
    string constant internal bgReleaseListByBankGID = "map__bgReleaseListByBankGID";
    string constant internal bgReleaseListByEgpID = "map__bgReleaseListByEgpID";
    string constant internal bgReleaseListByBgRefAndBankGid = "map__bgReleaseListByBgRefAndBankGid";
    string constant internal bgReleaseListByPaRefAndBankGid = "map__bgReleaseListByPaRefAndBankGid";


    string constant internal bgReleaseAndInvokeListByBgUid = "map__bgReleaseAndInvokeListByBgUid";
    string constant internal mapBgReleaseAndInvokeByUid = "map__mapBgReleaseAndInvokeByUid";

    

    modifier onlyBankGuaranteeReleaseManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validBankGuaranteeReleaseListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, bankGuaranteeReleaseList);
        require(_index < length, "Index Invalid");
        _;
    }

    

    //RELEASE

    function getBankGuaranteeReleaseIndex(bytes8 _uid) public view returns (uint256) {
        return Map.getBytes8ToUint(KEY, bankGuaranteeReleaseIndex, _uid);
    }

    function getBgReleaseIndexListByBgUid(bytes8 _uid) public view returns (uint[] memory bgReleaseIndexList_) {
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseIndexListByBgUid, _uid, abi.encodePacked(keyListLength));
        bgReleaseIndexList_ = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            bgReleaseIndexList_[i] = Map.getByKeyBytes8ToUint(KEY, bgReleaseIndexListByBgUid, _uid, abi.encodePacked(i));
        }
    }

    function getBankGuaranteeReleaseListLength() public view returns (uint256) {
        return List.getLength(KEY, bankGuaranteeReleaseList);
    }

    function getBankGuaranteeReleaseByIndex(uint256 _index)
        public
        view
        validBankGuaranteeReleaseListIndex(_index)
        returns (BankGuaranteeRelease memory bankGuaranteeRelease_)
    {
        bankGuaranteeRelease_.uid = getBgReleaseUid(_index);
        bankGuaranteeRelease_.bankGuaranteeUid = getBgReleaseBankGuaranteeUid(_index);
        bankGuaranteeRelease_.paymentReference = getBgReleasePaymentReference(_index);
        bankGuaranteeRelease_.procuringEntityGid = getBgReleaseProcuringEntityGid(_index);
        bankGuaranteeRelease_.egpSystemId = getBgReleaseEgpSystemId(_index);
        bankGuaranteeRelease_.vendorGid = getBgReleaseVendorGid(_index);
        bankGuaranteeRelease_.bankGid = getBgReleaseBankGid(_index);
        bankGuaranteeRelease_.branchName = getBgReleaseBranchName(_index);
        bankGuaranteeRelease_.releaseDate = getBgReleaseReleaseDate(_index);
        bankGuaranteeRelease_.currency = getBgReleaseCurrencyType(_index);
        bankGuaranteeRelease_.amountReleased = getBgReleaseAmountReleased(_index);
        bankGuaranteeRelease_.bgReleaseFileHash = getBgReleaseBgReleaseFileHash(_index);
        bankGuaranteeRelease_.version = getBgReleaseVersion(_index);
    }

    function getAllBankGuaranteeRelease(uint _toExcluded, uint _count) external view 
    returns(BankGuaranteeRelease[] memory _bankGuaranteeRelease, uint fromIncluded_, uint length_) {
        uint length = getBankGuaranteeReleaseListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bankGuaranteeRelease = new BankGuaranteeRelease[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bankGuaranteeRelease[_bankGuaranteeRelease.length-itr-1] = getBankGuaranteeReleaseByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getBgReleaseUid(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseUid);
    }

    function getBgReleaseBankGuaranteeUid(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(bytes8) {
        return List.getPropBytes8(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBankGuaranteeUid);
    }

    function getBgReleasePaymentReference(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleasePaymentReference);
    }

    function getBgReleaseProcuringEntityGid(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseProcuringEntityGid);
    }

    function getBgReleaseEgpSystemId(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseEgpSystemId);
    }

    function getBgReleaseVendorGid(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseVendorGid);
    }

    function getBgReleaseBankGid(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBankGid);
    }

    function getBgReleaseBranchName(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBranchName);
    }

    function getBgReleaseReleaseDate(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseReleaseDate);
    }

    function getBgReleaseCurrencyType(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseCurrencyType);
    }

    function getBgReleaseAmountReleased(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(uint) {
        return List.getPropUint(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseAmountReleased);
    }

    function getBgReleaseBgReleaseFileHash(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBgReleaseFileHash);
    }

    function getBgReleaseVersion(uint256 _index) public view 
    validBankGuaranteeReleaseListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseVersion);
    }


    /** @dev Listing out the Bank Guarantee Releases against the Bank Gid.
      * @param _bankGid Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByBankGID List of Bank Guarantee Releases against the Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Bank Gid.
      */
    function getBgReleaseListByBankGID(string memory _bankGid, uint _toExcluded, uint _count) public view returns(uint[] memory _bgReleaseListByBankGID, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, bgReleaseListByBankGID, _bankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgReleaseListByBankGID = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgReleaseListByBankGID[_bgReleaseListByBankGID.length-itr-1] = Map.getByKeyStringToUint(KEY, bgReleaseListByBankGID, _bankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Bank Guarantee Releases against the EgpSystem Id.
      * @param _egpSystemId e-GP system Id registered with the network.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByEgpID List of Bank Guarantee Releases against the EgpSystem Id.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the EgpSystem Id.
      */
    function getBgReleaseListByEgpID(string memory _egpSystemId, uint _toExcluded, uint _count) public view returns(uint[] memory _bgReleaseListByEgpID, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyStringToUint(KEY, bgReleaseListByEgpID, _egpSystemId, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgReleaseListByEgpID = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgReleaseListByEgpID[_bgReleaseListByEgpID.length-itr-1] = Map.getByKeyStringToUint(KEY, bgReleaseListByEgpID, _egpSystemId, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    
    /** @dev Listing out the Bank Guarantee Releases against the Bank Guarantee Reference Number and Bank Gid.
      * @param _bgReleaseBgRefBankGid Reference number of bank Guarantee and Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByBgRefAndBankGid List of Bank Guarantee Releases against the Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Bank Guarantee Reference Number and Bank Gid.
      */
    function getBgReleaseListByBgRefAndBankGid(bytes8 _bgReleaseBgRefBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bgReleaseListByBgRefAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgReleaseBgRefBankGid = bytes8(keccak256(abi.encodePacked(_bgReferenceNumber, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseListByBgRefAndBankGid, _bgReleaseBgRefBankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgReleaseListByBgRefAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgReleaseListByBgRefAndBankGid[_bgReleaseListByBgRefAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bgReleaseListByBgRefAndBankGid, _bgReleaseBgRefBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    /** @dev Listing out the Bank Guarantee Releases against the Payment Advice Reference Number and Bank Gid.
      * @param _bgReleasePaRefBankGid Reference number of Payment Advice and Global id of bank.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseListByPaRefAndBankGid List of Bank Guarantee Releases against the Payment Advice Reference Number and Bank Gid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the Payment Advice Reference Number and Bank Gid.
      */
    function getBgReleaseListByPaRefAndBankGid(bytes8 _bgReleasePaRefBankGid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bgReleaseListByPaRefAndBankGid, uint fromIncluded_, uint length_)  {
        //bytes8 _bgReleasePaRefBankGid = bytes8(keccak256(abi.encodePacked(_paReferenceNumber, _bankGid)));
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseListByPaRefAndBankGid, _bgReleasePaRefBankGid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgReleaseListByPaRefAndBankGid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgReleaseListByPaRefAndBankGid[_bgReleaseListByPaRefAndBankGid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bgReleaseListByPaRefAndBankGid, _bgReleasePaRefBankGid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    //WRITE

    function setBankGuaranteeReleaseIndex(bytes8 _uid, uint _value) public 
    onlyBankGuaranteeReleaseManager {
        Map.setBytes8ToUint(KEY, bankGuaranteeReleaseIndex, _uid, _value);
    }

    function addBgReleaseIndexListByBgUid(bytes8 _uid, uint _index) public 
    onlyBankGuaranteeReleaseManager {
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseIndexListByBgUid, _uid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgReleaseIndexListByBgUid, _uid, abi.encodePacked(length), _index);
        Map.setByKeyBytes8ToUint(KEY, bgReleaseIndexListByBgUid, _uid, abi.encodePacked(keyListLength), 1 + length);
    }

    function incBankGuaranteeReleaseListLength() public 
    onlyBankGuaranteeReleaseManager {
        List.incLength(KEY, bankGuaranteeReleaseList);
    }

    function addBankGuaranteeRelease(uint _index, BankGuaranteeRelease memory _BankGuaranteeRelease) public
    onlyBankGuaranteeReleaseManager
    validBankGuaranteeReleaseListIndex(_index) {
        List.setPropBytes8(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseUid,  _BankGuaranteeRelease.uid);
        List.setPropBytes8(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBankGuaranteeUid,  _BankGuaranteeRelease.bankGuaranteeUid);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleasePaymentReference,  _BankGuaranteeRelease.paymentReference);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseProcuringEntityGid,  _BankGuaranteeRelease.procuringEntityGid);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseEgpSystemId,  _BankGuaranteeRelease.egpSystemId);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseVendorGid,  _BankGuaranteeRelease.vendorGid);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBankGid,  _BankGuaranteeRelease.bankGid);  
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBranchName,  _BankGuaranteeRelease.branchName);
        List.setPropUint(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseReleaseDate,  _BankGuaranteeRelease.releaseDate);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseCurrencyType,  _BankGuaranteeRelease.currency);
        List.setPropUint(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseAmountReleased,  _BankGuaranteeRelease.amountReleased);
        List.setPropString(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseBgReleaseFileHash,  _BankGuaranteeRelease.bgReleaseFileHash);
        List.setPropUint16(KEY, bankGuaranteeReleaseList, _index, propNameBgReleaseVersion, __VERSION__);
    }



    /** @dev Setting the Bank Guarantee Releases against the Bank Gid, Setting the Bank Guarantee Releases against the EgpSystem Id , Setting the Bank Guarantee Releases against the Bank Guarantee Reference Number and Bank Gid, Setting the Bank Guarantee Releases against the Payment Advice Reference Number and Bank Gid.
      * @param _BankGuaranteeRelease Bank guarantee Release details.
      * @param _value Index of Bank guarantee Release.
      * @param _bgReferenceNumber Bank Guarantee Reference Number.
      */
    function setBankGuaranteeReleaseIndices(BankGuaranteeRelease memory _BankGuaranteeRelease, uint _value, string memory _bgReferenceNumber) public 
    onlyBankGuaranteeReleaseManager
    {
        // set bgReleaseListByBankGID
        uint length = Map.getByKeyStringToUint(KEY, bgReleaseListByBankGID, _BankGuaranteeRelease.bankGid, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, bgReleaseListByBankGID, _BankGuaranteeRelease.bankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyStringToUint(KEY, bgReleaseListByBankGID, _BankGuaranteeRelease.bankGid, abi.encodePacked(length), _value);
        
        // set bgReleaseListByEgpID
        length = Map.getByKeyStringToUint(KEY, bgReleaseListByEgpID, _BankGuaranteeRelease.egpSystemId, abi.encodePacked(keyListLength));
        Map.setByKeyStringToUint(KEY, bgReleaseListByEgpID, _BankGuaranteeRelease.egpSystemId, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyStringToUint(KEY, bgReleaseListByEgpID, _BankGuaranteeRelease.egpSystemId, abi.encodePacked(length), _value);
        
        // set bgReleaseListByBgRefAndBankGid
        bytes8 _bgReleaseBgRefBankGid = bytes8(keccak256(abi.encodePacked(_bgReferenceNumber, _BankGuaranteeRelease.bankGid)));
        length = Map.getByKeyBytes8ToUint(KEY, bgReleaseListByBgRefAndBankGid, _bgReleaseBgRefBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgReleaseListByBgRefAndBankGid, _bgReleaseBgRefBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bgReleaseListByBgRefAndBankGid, _bgReleaseBgRefBankGid, abi.encodePacked(length), _value);
        
        // set bgReleaseListByPaRefAndBankGid
        bytes8 _bgReleasePaRefBankGid = bytes8(keccak256(abi.encodePacked(_BankGuaranteeRelease.paymentReference, _BankGuaranteeRelease.bankGid)));
        length = Map.getByKeyBytes8ToUint(KEY, bgReleaseListByPaRefAndBankGid, _bgReleasePaRefBankGid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgReleaseListByPaRefAndBankGid, _bgReleasePaRefBankGid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bgReleaseListByPaRefAndBankGid, _bgReleasePaRefBankGid, abi.encodePacked(length), _value);

        _setBgReleaseAndInvokeListByBgUid(_BankGuaranteeRelease.bankGuaranteeUid, _value);
    }
    


    //RELEASE AND INVOKE
    
    /** @dev Listing out the Bank Guarantee Releases and Invokes against the BG Uid.
      * @param _bgUid unique id value of Bank Guarantee.
      * @param _toExcluded The length till where the uint indexes has to be fetched.
      * @param _count The number of indexes that has to be fetched. 
      * @return _bgReleaseAndInvokeListByBgUid List of Bank Guarantee Releases and Invokes against the BG Uid.
      * @return fromIncluded_ _toExcluded - _count.
      * @return length_ The length of the index present for the BG Uid.
      */
    //Get all the invokes and release associated with particular BG
    function getBgReleaseAndInvokeListByBgUid(bytes8 _bgUid,  uint _toExcluded, uint _count) public view returns(uint[] memory _bgReleaseAndInvokeListByBgUid, uint fromIncluded_, uint length_)  {
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _bgUid, abi.encodePacked(keyListLength));
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        _bgReleaseAndInvokeListByBgUid = new uint[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            _bgReleaseAndInvokeListByBgUid[_bgReleaseAndInvokeListByBgUid.length-itr-1] = Map.getByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _bgUid, abi.encodePacked(_toExcluded));
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }



    /** @dev Setting the Bank Guarantee Releases and Bank Guarantee Invokes against the Bank Guarantee Uid.
      * @param _Uid PA reference number and Bank Gid.
      * @param _value Index of Bank Guarantee Releases and Bank Guarantee Invokes.
      */
    function _setBgReleaseAndInvokeListByBgUid(bytes8 _Uid, uint _value) internal
    {
        // set bgReleaseAndInvokeListByBgUid
        uint length = Map.getByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _Uid, abi.encodePacked(keyListLength));
        Map.setByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _Uid, abi.encodePacked(keyListLength), 1+length);
        Map.setByKeyBytes8ToUint(KEY, bgReleaseAndInvokeListByBgUid, _Uid, abi.encodePacked(length), _value);
        Map.setByKeyBytes8ToUint(KEY, mapBgReleaseAndInvokeByUid, _Uid, abi.encodePacked(_value), 0);
    }

}