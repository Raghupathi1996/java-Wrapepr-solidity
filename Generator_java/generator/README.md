
Pre-requisite 
1) Java version must be 11
2) Maven version must be 3.3.3 or above.

Steps:
1) Unzip generator.zip
2) place all solidity files under generator/src/main/solidity/
3) run "mvn web3j:generate-sources"  command to generate java files from solodity files.
Output:  All generated file can be found under generator/src/main/java/com/quorum/web3j/ folder.
Please zip generator/src/main/java folder and share with us. 