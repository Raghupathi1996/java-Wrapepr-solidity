pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./VendorManager.sol";
import "./BankModel.sol";
import "./UidUtils.sol";

contract BankManager is BankStructs {

    string constant private BANKS_SUBORG = "BANKS";

    address private permIntfAddress;
    address private permImplementation;
    address private accountManager;
    BankModel private bankModel;
    UidUtils private uidUtils;

    event BankRegistered(string _bankGid, string _bankName, string _bankCountry, string _representativeAccountName);

    constructor (address _permIntf, address _permImpl, address _accountManager, address _bankModel, address _uidUtils) {
        permIntfAddress = _permIntf;
        permImplementation = _permImpl;
        accountManager = _accountManager;
        bankModel = BankModel(_bankModel);
        uidUtils = UidUtils(_uidUtils);
    }

    modifier networkAdmin() {
        (bool success, bytes memory data) = permIntfAddress.call(
            abi.encodeWithSignature("isNetworkAdmin(address)", msg.sender)
        );
        require(abi.decode(data, (bool)), "account is not a network admin account");
        _;
    }

    modifier validateBanksAccount(string memory _accountName) {
        (bool success, bytes memory data) = permIntfAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                _getAccountAddress(_accountName),
                string(abi.encodePacked(_getAdminOrg(),".",BANKS_SUBORG))
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account doesn't belong to VENDORS suborg"
        );
        _;
    }

    modifier gidExists(string memory _gid) {
        require(0!=bankModel.getBankIndex(_gid), "GID does not exist");
        _;
    }

    function registerBank(string memory _bankName, string memory _bankCountry, string memory _representativeAccountName) public 
    networkAdmin
    validateBanksAccount(_representativeAccountName) {
        string memory gid = uidUtils.bytes32ToAlphanumeric7(keccak256(abi.encodePacked(_bankName, _bankCountry, _representativeAccountName)));
        gid = uidUtils.addLuhnCheckDigit(gid);
        require(0==bankModel.getBankIndex(gid),"Bank already registered");
        uint id = bankModel.getBankListLength();
        bankModel.setBankIndex(gid, 1+id);
        bankModel.incBankListLength();
        bankModel.setBankGid(id, gid);
        bankModel.setBankBankName(id, _bankName);
        bankModel.setBankBankCountry(id, _bankCountry);
        bankModel.setBankRepresentativeAccountName(id, _representativeAccountName);
        bankModel.setBankVersion(id);
        emit BankRegistered(gid, _bankName, _bankCountry, _representativeAccountName);
    }

    function getAllBanks(uint _toExcluded, uint _count) public view
    returns(Bank[] memory banks_, uint fromIncluded_, uint length_) {
        (banks_,fromIncluded_, length_) = bankModel.getAllBanks(_toExcluded, _count);
    }

    function getBankForGid(string memory _gid) public view 
    gidExists(_gid)
    returns(Bank memory bank_) {
        bank_ = bankModel.getBankByIndex(_getBankIndex(_gid));
    }

    function isGidExists(string memory _gid) external view 
    returns (bool) {
        return (0!=bankModel.getBankIndex(_gid));
    }

    function _getBankIndex (string memory _gid) internal view
    returns(uint) {
        return bankModel.getBankIndex(_gid)-1;
    }

    function _getAdminOrg() private returns (string memory adminOrg_) {
        (bool success, bytes memory data) = permImplementation.call(
            abi.encodeWithSignature("getPolicyDetails()")
        );
        require(success, "Cannot fetch AdminOrg Details");
        (adminOrg_,,,) = abi.decode(data, (string, string, string, bool));
    }

    function _getAccountAddress(string memory _accountName) private returns(address) {
        (bool success, bytes memory data) = accountManager.call(
            abi.encodeWithSignature(
                "getAccountAddress(string)",
                _accountName
            )
        );
        require(success, "Cannot fetch Account Details");
        return abi.decode(data,(address));
    }

}