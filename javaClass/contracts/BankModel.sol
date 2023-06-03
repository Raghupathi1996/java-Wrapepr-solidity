pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract BankStructs{

    uint16 constant internal __VERSION__ = 1;

    struct Bank {
        string gid;
        string bankName;
        string bankCountry;
        string representativeAccountName;
        uint16 version;
    }

    string constant internal propNameBankGid = "gid";
    string constant internal propNameBankBankName = "bankName";
    string constant internal propNameBankBankCountry = "bankCountry";
    string constant internal propNameBankRepresentativeAccountName = "representativeAccountName";
    string constant internal propNameBankVersion = "version";
}


contract BankModel is BankStructs {
    
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

    string constant internal KEY = "BANK_MANAGER";
    string constant internal keyListLength = "__length";


    string constant internal bankList = "list__bankList";
    string constant internal bankIndex = "map__bankIndex";

    modifier onlyBankManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier validBankListIndex(uint256 _index){
        uint256 length = List.getLength(KEY, bankList);
        require(_index < length, "Index Invalid");
        _;
    }

    //Bank

    function getBankIndex(string memory _gid) public view returns (uint256) {
        return Map.getStringToUint(KEY, bankIndex, _gid);
    }

    function getBankListLength() public view returns (uint256) {
        return List.getLength(KEY, bankList);
    }

    function getAllBanks(uint _toExcluded, uint _count) public view 
    returns (Bank[] memory banks_, uint fromIncluded_, uint length_) {
        uint length = getBankListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        banks_ = new Bank[](itr);
        while (itr>0) {
            itr--;
            _toExcluded--;
            banks_[banks_.length-itr-1] = getBankByIndex(_toExcluded);
        }
        fromIncluded_ = _toExcluded;
        length_ = length;
    }

    function getBankByIndex(uint256 _index)
        public
        view
        validBankListIndex(_index)
        returns (Bank memory bank_)
    {
        bank_.gid = getBankGid(_index);
        bank_.bankName = getBankBankName(_index);
        bank_.bankCountry = getBankBankCountry(_index);
        bank_.representativeAccountName = getBankRepresentativeAccountName(_index);
    }

    function getBankGid(uint256 _index) public view 
    validBankListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankList, _index, propNameBankGid);
    }

    function getBankBankName(uint256 _index) public view 
    validBankListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankList, _index, propNameBankBankName);
    }

    function getBankBankCountry(uint256 _index) public view 
    validBankListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankList, _index, propNameBankBankCountry);
    }

    function getBankRepresentativeAccountName(uint256 _index) public view 
    validBankListIndex(_index) 
    returns(string memory) {
        return List.getPropString(KEY, bankList, _index, propNameBankRepresentativeAccountName);
    }

    function getBankVersion(uint256 _index) public view 
    validBankListIndex(_index) 
    returns(uint16) {
        return List.getPropUint16(KEY, bankList, _index, propNameBankVersion);
    }


    //Bank

    function setBankIndex(string memory _gid, uint _value) public 
    onlyBankManager {
        Map.setStringToUint(KEY, bankIndex, _gid, _value);
    }

    function incBankListLength() public 
    onlyBankManager {
        List.incLength(KEY, bankList);
    }

    function setBankGid(uint256 _index, string memory _gid) public 
    onlyBankManager {
        List.setPropString(KEY, bankList, _index, propNameBankGid, _gid);
    }

    function setBankBankName(uint256 _index, string memory _bankName) public 
    onlyBankManager {
        List.setPropString(KEY, bankList, _index, propNameBankBankName, _bankName);
    }

    function setBankBankCountry(uint256 _index, string memory _bankCountry) public 
    onlyBankManager {
        List.setPropString(KEY, bankList, _index, propNameBankBankCountry, _bankCountry);
    }

    function setBankRepresentativeAccountName(uint256 _index, string memory _representativeAccountName) public 
    onlyBankManager {
        List.setPropString(KEY, bankList, _index, propNameBankRepresentativeAccountName, _representativeAccountName);
    }

    function setBankVersion(uint256 _index) public
    onlyBankManager 
    {
        List.setPropUint16(KEY, bankList, _index, propNameBankVersion, __VERSION__);
    }

}
