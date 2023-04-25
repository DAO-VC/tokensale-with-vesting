pragma solidity ^0.8.17;
import "../interfaces/IMarket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Migrator is Ownable{

    IMarket private Market;

    constructor(address _Market){
        Market = IMarket(_Market);
    }

    function MigrateUsersList(uint256[] calldata marketsIndex, uint256[] calldata _amountList, address[] calldata _beneficiary) public onlyOwner{
        require(marketsIndex.length == _amountList.length, "Arrays size didn't match");
        require(_amountList.length == _beneficiary.length, "Arrays size didn't match");
        uint256 i = 0;
        for (i = 0; i < _beneficiary.length; i++){
            Market.migrateUser(marketsIndex[i], _amountList[i], _beneficiary[i]);
        }
    }
}
