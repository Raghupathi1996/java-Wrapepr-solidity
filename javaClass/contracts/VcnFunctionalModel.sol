pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./MemberStorage.sol";
import "./ListStorage.sol";
import "./MapStorage.sol";
import "./QuireContracts.sol";

contract VcnFunctionalStructs {
    uint16 constant internal VERSION = 1;
    struct VcnFunctional {
        string[] _currencyType;
        uint16 version;
    }
    
    string constant internal propNameVcnFunctionalCurrencyType= "currencyType";
    string constant internal propNameVcnFunctionalVersion = "version";

}

contract VcnFunctionalModel is VcnFunctionalStructs {
    
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

    string constant internal KEY = "VCN_FUNCTIONAL_MANAGER";
    string constant internal keyCurrencyVersion = "currencyVersion__length";
    string constant internal currencyList = "list__currecnyList";
    string constant internal currencyDeleteList = "list__currecnyDeleteList";
    string constant internal VcnFunctionalIndexMap = "map__VcnFunctionalIndex";
    string constant internal propNameVcnFunctionalIndexByCurrencyName = "map__accountIndexByCurrencyName";
    string constant internal propNameCurrencyVersion = "List__versionOfSpecificCurrency";


    modifier onlyVcnFunctionalManager() {
        require(msg.sender==quireContracts.getRegisteredContract(KEY), "Unauthorized Contract Call");
        _;
    }

    modifier checkIfLatestCurrency(string memory _currency) {
        require(checkLatestCurrency(_currency), "Not a valid currency, enter the latest one");
        _;
    }


    //At present we consider the VCNfunctional to be a single struct and not an array
    //so could consider the index to be 0 and incase if the VCNfunctionl wanted to made
    //an array based on business need we can make it an array and enable index property
    //by uncommenting the function getVcnFunctionalIndex and replace 0 with the index this function returns


    //To check the length of the currency array

    function getCurrencyTotalListLength() public view returns (uint256) {
        return List.getLength(KEY, currencyList);
    }

    function getCurrencyDeleteListLength() public view returns (uint256) {
        return List.getLength(KEY, currencyDeleteList);
    }


    //To check wheather a currency exist are not in the smart Contract

    function getIndexByCurrencyName(string memory currencyName_) public view
    returns (uint256)
    {
        return Map.getStringToUint(KEY, propNameVcnFunctionalIndexByCurrencyName, currencyName_);
    }

    function getCurrencyNameIndexMember(string memory currencyName_) public view
    returns(string memory)
    {
        return Member.getString(KEY, currencyName_);
    }


//  Try new get all currency type 

    function getAllCurrencyType() public view 
    returns(string[] memory currency_) {
        uint256 totalLength = getCurrencyTotalListLength();
        uint256 deleteLength = getCurrencyDeleteListLength();
        uint256 length = totalLength - deleteLength;
        // uint length = List.getPropByKeyUint(KEY, currencyList, _versionIndex, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(keyListLength));
        currency_ = new string[](length);
        uint256 j = 0;
        for (uint256 i = 1; i <= totalLength; i++) {
            // currency_[i] = List.getPropByKeyString(KEY, currencyList, _versionIndex, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(i));
            string memory tempCurrency = List.getPropByKeyString(KEY, currencyList, 1, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(i));
            if(getIndexByCurrencyName(tempCurrency) != 0){
                uint versionLength = Member.getUint(KEY, tempCurrency);
                if(versionLength == 0)
                {
                    currency_[j] = tempCurrency;
                    j++;
                } else {
                    currency_[j] = List.getPropString(KEY, tempCurrency, versionLength, propNameCurrencyVersion);
                    j++;
                }
            }
        }
    }

    function checkLatestCurrency(string memory _currency) public view 
    returns(bool) {
        uint256 totalLength = getCurrencyTotalListLength();
        for (uint256 i = 1; i <= totalLength; i++) {
            string memory tempCurrency = List.getPropByKeyString(KEY, currencyList, 1, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(i));
            if(getIndexByCurrencyName(tempCurrency) != 0){
                uint versionLength = Member.getUint(KEY, tempCurrency);
                if(versionLength == 0)
                {
                    if(keccak256(bytes(tempCurrency)) == keccak256(bytes(_currency))) return true;
                } else {
                    string memory latestCurrency = List.getPropString(KEY, tempCurrency, versionLength, propNameCurrencyVersion);
                    if(keccak256(bytes(latestCurrency)) == keccak256(bytes(_currency))) return true;
                }
            }
        }
        return false;
    }

    function validateCurrencyVersion(string memory _currency1, string memory _currency2) public view
    returns (bool)
    {

        if(keccak256(bytes(getCurrencyNameIndexMember(_currency1))) == keccak256(bytes(""))) //currency1 is a index currency
        {
            if(keccak256(bytes(_currency1)) == keccak256(bytes(Member.getString(KEY, _currency2)))) return true;

            if(keccak256(bytes(_currency1)) == keccak256(bytes(_currency2))) return true;
        } 
        if (keccak256(bytes(getCurrencyNameIndexMember(_currency1))) != keccak256(bytes("")))
        {
            if(keccak256(bytes(Member.getString(KEY, _currency1))) == keccak256(bytes(Member.getString(KEY, _currency2)))) {
                return true;
            }
        }

        return false;
    }

    // Test purpose

    function getAllCurrencyVersions(string memory currencyName) public view
    returns(string[] memory)
    {
        string memory indexCurrency = Member.getString(KEY, currencyName);
        if(keccak256(bytes(indexCurrency)) == keccak256(bytes("")))
        {
            string[] memory currencyVersion_ = new string[](1);
            currencyVersion_[0] = currencyName;
            return currencyVersion_;
        } else {
            uint versionLength = Member.getUint(KEY, indexCurrency);
            string[] memory currencyVersion_ = new string[](versionLength+1);
            currencyVersion_[0] = indexCurrency;
            for (uint256 i = 1; i <= versionLength; i++) {
                string memory latestCurrency = List.getPropString(KEY, indexCurrency, i, propNameCurrencyVersion);
                currencyVersion_[i] = latestCurrency;
            }
            return currencyVersion_;
        }
    }


    function getLatestCurrencyOfIndexCurrency(string memory currencyName) public view
    returns(string memory latestCurrency)
    {
        uint versionLength = Member.getUint(KEY, currencyName);
        latestCurrency = List.getPropString(KEY, currencyName, versionLength, propNameCurrencyVersion);
        return latestCurrency;
    }


    // onlyVcnFunctionalManager
    function addCurrencyType( string memory currencyName, uint256 _index) public 
    onlyVcnFunctionalManager
    {

        List.setPropByKeyString(KEY, currencyList, 1, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(_index), currencyName);

    }

    // Test addCurrencyType

    function getCurrencyTypegetPropByKeyString() public view
    returns(string[] memory currency_)
    {
        currency_ = new string[](5);
        for (uint256 i = 1; i <= 5; i++) {
            string memory tempCurrency = List.getPropByKeyString(KEY, currencyList, 1, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(i));
            currency_[i-1] = tempCurrency;
        }

    }

    // onlyVcnFunctionalManager
    function setIndexByCurrencyName(string memory currencyname, uint256 _index) public 
    onlyVcnFunctionalManager
    {
        Map.setStringToUint(KEY, propNameVcnFunctionalIndexByCurrencyName, currencyname, _index);
    }


    // adding a new version of currency to the existing currency type

    function addNewVersionCurrencyName(string memory currencyName_0, string memory currencyName_latest) public
    onlyVcnFunctionalManager{
        Member.incUint(KEY, currencyName_0);
        uint versionLength = Member.getUint(KEY, currencyName_0);
        List.setPropString(KEY, currencyName_0, versionLength, propNameCurrencyVersion, currencyName_latest);
        Member.setString(KEY, currencyName_latest, currencyName_0);
    }
    
    // onlyVcnFunctionalManager
    function deleteIndexByCurrencyName(string memory currencyname) public 
    onlyVcnFunctionalManager{
        Map.setStringToUint(KEY, propNameVcnFunctionalIndexByCurrencyName, currencyname, 0);
    }

    // onlyVcnFunctionalManager
    function deleteAllCurrecnyVersion(string memory currencyname) public
    onlyVcnFunctionalManager{
        string memory currencyName_0 = getCurrencyNameIndexMember(currencyname);
        uint versionLength = Member.getUint(KEY, currencyName_0);
        for (uint256 i = 1; i <= versionLength; i++) {
            string memory latestCurrency = List.getPropString(KEY, currencyName_0, i, propNameCurrencyVersion);
            Member.setString(KEY, latestCurrency, "");
            List.setPropString(KEY, currencyName_0, i, propNameCurrencyVersion,"");
        }
        Member.setUint(KEY, currencyName_0, 0);
        uint256 currencyIndex = getIndexByCurrencyName(currencyName_0);
        List.setPropByKeyString(KEY, currencyList, 1, bytes(propNameVcnFunctionalCurrencyType), abi.encodePacked(currencyIndex),"");

    }

    // onlyVcnFunctionalManager
    function inCurrencyTotalLength() public  
    onlyVcnFunctionalManager{
        List.incLength(KEY, currencyList);
    }

    // onlyVcnFunctionalManager
    function inCurrencyDeleteLength() public  
    onlyVcnFunctionalManager{
        List.incLength(KEY, currencyDeleteList);
    }
        
}