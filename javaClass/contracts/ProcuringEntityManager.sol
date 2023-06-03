pragma solidity ^0.8.0;
import "./ProcuringEntityModel.sol";
import "./UidUtils.sol";

contract ProcuringEntityManager is ProcuringEntityStructs {

    address private permInterfaceAddress;
    ProcuringEntityModel private procuringEntityModel;
    UidUtils private uidUtils;

    constructor(address _permIntf, address _procuringEntityModel, address _uidUtils) {
        permInterfaceAddress = _permIntf;
        procuringEntityModel = ProcuringEntityModel(_procuringEntityModel);
        uidUtils = UidUtils(_uidUtils);
    }

    event procuringEntityRegistered(
        string  _peGid,
        string _peName,
        string _peExternalId,
        string _egpSystemId,
        uint16 _version
    );

    modifier validateOrgAndAccount(address _account, string memory _orgId) {
        (bool success, bytes memory data) = permInterfaceAddress.call(
            abi.encodeWithSignature(
                "validateOrgAndAccount(address,string)",
                _account,
                _orgId
            )
        );
        require(
            success,
            "permissions call failed"
        );
        bool isValid = abi.decode(data, (bool));
        require(
            isValid,
            "account does not exists or exists but doesn't belong to passed orgId"
        );
        _;
    }

    function registerProcuringEntity(
        string memory _name,
        string memory _externalId,
        string memory _orgId
    )
        public        
        validateOrgAndAccount(msg.sender, _orgId)
    {
        string memory gid = uidUtils.bytes32ToAlphanumeric7(
            keccak256(abi.encodePacked(_name, _externalId, _orgId))
        );
        gid = uidUtils.addLuhnCheckDigit(gid);
        ProcuringEntity memory proc = ProcuringEntity(gid, _name, _externalId, _orgId, 0);
        uint id = procuringEntityModel.getProcuringEntityListLength();
        procuringEntityModel.setProcuringEntityIndex(gid, id+1);
        procuringEntityModel.pushProcuringEntity(proc);
        emit procuringEntityRegistered(
            gid,
            procuringEntityModel.getProcuringEntityName(id),
            procuringEntityModel.getProcuringEntityExternalId(id),
            procuringEntityModel.getProcuringEntityOrgId(id),
            procuringEntityModel.getProcuringEntityVersion(id)
        );
    }

    function getProcuringEntityByGid(string memory _gid)
        public
        view
        returns (
            string memory gid,
            string memory name,
            string memory externalId,
            string memory orgId,
            uint16 version
        )
    {
        uint256 id = procuringEntityModel.getProcuringEntityIndex(_gid);
        if (id == 0) {
            return ("", "", "", "", 0);
        } else {
            id--;
            return (
                procuringEntityModel.getProcuringEntityGid(id),
                procuringEntityModel.getProcuringEntityName(id),
                procuringEntityModel.getProcuringEntityExternalId(id),
                procuringEntityModel.getProcuringEntityOrgId(id),
                procuringEntityModel.getProcuringEntityVersion(id)
            );
        }
    }

    function getAllProcuringEntity(uint _toExcluded, uint _count) public view
    returns(ProcuringEntity [] memory banks_, uint fromIncluded_, uint length_) {
        (banks_,fromIncluded_, length_) = procuringEntityModel.getAllProcuringEntities(_toExcluded, _count);
    }

    function getProcuringEntitiesForOrgId(string memory _orgId, uint _toExcluded, uint _count) external view 
    returns(ProcuringEntity[] memory procuringEntities_, uint fromIncluded_) {
        uint length = procuringEntityModel.getProcuringEntityListLength();
        if (_toExcluded > length) {
            _toExcluded = length;
        }
        uint filteredLength = 0;
        uint itr = _count>_toExcluded ? _toExcluded:_count;
        uint[] memory filteredIndices = new uint[](itr);
        while (_toExcluded>0 && filteredLength<itr) {
            _toExcluded--;
            if(keccak256(abi.encodePacked(procuringEntityModel.getProcuringEntityOrgId(_toExcluded)))==keccak256(abi.encodePacked(_orgId))){
                filteredIndices[filteredLength]=_toExcluded;
                filteredLength++;
            }
        }
        fromIncluded_ = _toExcluded;
        procuringEntities_ = new ProcuringEntity[](filteredLength);
        for (uint256 index = 0; index < filteredLength; index++) {
            procuringEntities_[index] = procuringEntityModel.getProcuringEntityByIndex(filteredIndices[index]);
        }
    }

    function getProcuringEntityOrgIdByGid(string memory _gid) external view returns (string memory orgId_) {
        uint256 id = procuringEntityModel.getProcuringEntityIndex(_gid);
        require(0!=id, "Procuring Entity Does not Exist");
        id--;
        orgId_ = procuringEntityModel.getProcuringEntityOrgId(id);
    }

    function isGidExists(string memory _gid) external view returns(bool){
        return (procuringEntityModel.getProcuringEntityIndex(_gid)>0);
    }

}
