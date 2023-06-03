pragma solidity ^0.8.0;

contract UidUtils {

    uint8 private allowedCharsLength = 36;

    // To not include letters or digits in the Generated UID, add them in disallowedChars array like below
    // [uint8(bytes1('8')), uint8(bytes1('B'))];
    uint8[] private disallowedChars = new uint8[](0);

    // For all alphanumerics, 0 maps to 48, 9 to 57, 10 to 65 i.e A, 35 to 90, i.e. Z
    mapping(uint8 => uint8) private utfCharAtIndex;

    constructor(){
        allowedCharsLength = 36 - (uint8)(disallowedChars.length);
        _fillCharMap();
    }

    function _fillCharMap() private {
        utfCharAtIndex[0] = 48;
        while(!isUtfCharAllowed(utfCharAtIndex[0])){
            utfCharAtIndex[0] = 1 + utfCharAtIndex[0];
        }
        for (uint8 i = 1; i < allowedCharsLength; i++) {
            utfCharAtIndex[i] = utfCharAtIndex[i-1] + 1;
            while(!isUtfCharAllowed(utfCharAtIndex[i])){
                utfCharAtIndex[i] = 1 + utfCharAtIndex[i];
            }
        }
    }

    function isUtfCharAllowed(uint8 _inputChar) public view 
    returns(bool) {
        if(_inputChar<48 || _inputChar >90 || (_inputChar>57&&_inputChar<65)){
            return false;
        }
        for (uint8 i = 0; i < disallowedChars.length; i++) {
            if(disallowedChars[i]==_inputChar) {
                return false;
            }
        }
        return true;
    }

    function utfToUintDomain(uint8 _input) public view 
    returns(uint8 output_) {
        for (uint8 i = 0; i < allowedCharsLength; i++) {
            if(utfCharAtIndex[i]==_input){
                return i;
            }
        }
        require(false, "Char Not Allowed");
    }


    function bytes32ToAlphanumeric7(bytes32 _input) public view 
    returns(string memory alphanumeric7_) {
        alphanumeric7_ = string(abi.encodePacked(''));
        uint8 digit;
        for (uint8 i = 0; i < 7; i++) {
            digit = uint8((bytes1)(_input<<(4*i*8)))%allowedCharsLength;
            alphanumeric7_ = string(abi.encodePacked(alphanumeric7_,bytes1(utfCharAtIndex[digit])));
        }
    }

    function addLuhnCheckDigit(string memory _input) public view 
    returns(string memory _output) {
        uint length = bytes(_input).length;
        uint8[] memory chars = new uint8[](length);
        uint sum = 0;
        for(uint i=0; i<length; i++){
            chars[length-1-i] = utfToUintDomain(uint8(bytes(_input)[length-1-i]));
            if(i%2==0){
                sum += (2*chars[length-1-i]/allowedCharsLength) + ((2*chars[length-1-i])%allowedCharsLength);
            }
            else{
                sum += (chars[length-1-i]/allowedCharsLength) + ((chars[length-1-i])%allowedCharsLength);
            }
        }
        sum = (allowedCharsLength - (sum % allowedCharsLength)) % allowedCharsLength;
        _output = string(abi.encodePacked(_input,bytes1(uint8(utfCharAtIndex[uint8(sum)]))));
    }

}