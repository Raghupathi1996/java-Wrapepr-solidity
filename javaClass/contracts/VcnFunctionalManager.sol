pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./VcnFunctionalModel.sol";
contract VcnFunctionalManager is VcnFunctionalStructs {
    address private permIntfAddress;
    VcnFunctionalModel private vcnFunctionalModel;
    uint private testVariable;

    constructor(address _permIntf, address _vcnFunctionalModel) {
        permIntfAddress = _permIntf;
        vcnFunctionalModel = VcnFunctionalModel(_vcnFunctionalModel);
    }
    
    modifier networkAdmin() {
        (bool success, bytes memory data) = permIntfAddress.call(
            abi.encodeWithSignature("isNetworkAdmin(address)", msg.sender)
        );
        require(
            abi.decode(data, (bool)),
            "account is not a network admin account"
        );
        _;
    }

    modifier currencyExists(string memory _currency) {
        if (
            keccak256(
                bytes(vcnFunctionalModel.getCurrencyNameIndexMember(_currency))
            ) == keccak256(bytes(""))
        ) {
            require(
                vcnFunctionalModel.getIndexByCurrencyName(_currency) == 0,
                "Currency already exist"
            );
            _;
        } else {
            string memory indexMember = vcnFunctionalModel
                .getCurrencyNameIndexMember(_currency);
            require(
                vcnFunctionalModel.getIndexByCurrencyName(indexMember) == 0,
                "Currency already exist"
            );
            _;
        }
    }
    

    modifier checkIfLatestCurrency(string memory _currency) {
        require(vcnFunctionalModel.checkLatestCurrency(_currency), "Not a valid currency, enter the latest one");
        _;
    }
    

    event VcnCurrency(string _newCurrency, string[] _latestCurrencyArray);
    event ModifyCurrency(string _oldVersionCurrency, string _newVersionCurrency);
    event DeletedCurrency(string _deletedCurrency);

    
    function getCurrencyListLength() public view returns (uint256) {
        uint256 totalListLength = vcnFunctionalModel
            .getCurrencyTotalListLength();
        uint256 deletedListLength = vcnFunctionalModel
            .getCurrencyDeleteListLength();
        return (totalListLength - deletedListLength);
    }


    function getCurrencyList() public view returns (string[] memory) {
        return vcnFunctionalModel.getAllCurrencyType();
    }


    function getLatestCurrencyVersion(string memory currencyName)
        public
        view
        returns (string memory latestCurrency)
    {
        if (
            keccak256(
                bytes(
                    vcnFunctionalModel.getCurrencyNameIndexMember(currencyName)
                )
            ) == keccak256(bytes(""))
        ) {
            return
                vcnFunctionalModel.getLatestCurrencyOfIndexCurrency(
                    currencyName
                );
        } else {
            string memory indexMember = vcnFunctionalModel
                .getCurrencyNameIndexMember(currencyName);
            vcnFunctionalModel.getLatestCurrencyOfIndexCurrency(indexMember);
        }
    }



    function setCurrency(string memory _currency) 
    public
    currencyExists(_currency)
    networkAdmin
    {
        uint256 id = vcnFunctionalModel.getCurrencyTotalListLength();
        vcnFunctionalModel.addCurrencyType(_currency,id+1);
        vcnFunctionalModel.setIndexByCurrencyName(_currency, id+1);
        vcnFunctionalModel.inCurrencyTotalLength();
        emit VcnCurrency(_currency, getCurrencyList());
    }


    function modifycurrency(string memory _currency1, string memory _currency2)
    public
    checkIfLatestCurrency(_currency1)
    networkAdmin
    {
        if (
            keccak256(
                bytes(vcnFunctionalModel.getCurrencyNameIndexMember(_currency1))
            ) == keccak256(bytes(""))
        ) {
            vcnFunctionalModel.addNewVersionCurrencyName(
                _currency1,
                _currency2
            );
        } else {
            string memory indexMember = vcnFunctionalModel
                .getCurrencyNameIndexMember(_currency1);
            vcnFunctionalModel.addNewVersionCurrencyName(
                indexMember,
                _currency2
            );
        }
        emit ModifyCurrency(_currency1, _currency2);
    }

    
    function deleteCurrency (string memory _currency)
    public
    checkIfLatestCurrency(_currency)
    networkAdmin
    {
        vcnFunctionalModel.deleteAllCurrecnyVersion(_currency);  
        vcnFunctionalModel.deleteIndexByCurrencyName(_currency);
        vcnFunctionalModel.inCurrencyDeleteLength();
        emit DeletedCurrency(_currency);
    }


    function isCurrencyExists(string memory _currency) public view 
    returns (bool)
    {
        return vcnFunctionalModel.checkLatestCurrency(_currency);
    }

    function checkCurrencyVersion (string memory _currency1, string memory _currency2) public view
    returns (bool)
    {
        return vcnFunctionalModel.validateCurrencyVersion(_currency1, _currency2);
    }

    function getAllCurrencyVersion(string memory currency) public view
    checkIfLatestCurrency(currency)
    returns (string[] memory)
    {
        return vcnFunctionalModel.getAllCurrencyVersions(currency);
    }
}
