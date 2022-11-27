// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/KIP/token/KIP7/extensions/KIP7Burnable.sol";
/*
    Decimal : 18 
    10 Token = 10^19 = 10000000000000000000 
    1 Token = 10^18 = 1000000000000000000 
    0.1 Token = 10^17 = 100000000000000000

    이더리움
    1 Ether = 10^18 = 1000000000000000000 wei
    1 Gwei = 10^9 = 10000000 wei
    1 Wei = 1 wei

    클레이튼
    1 Klay = 10^18 = 1000000000000000000 peb
    1 Gpeb = 10^9 = 10000000 peb
    1 Peb = 1 peb
*/

contract MyToken is KIP7Burnable {
    
    address public owner; 
    constructor(string memory _name, string memory _symbol, uint256 _initialAmount) KIP7(_name,_symbol) {
        owner = _msgSender();
        _mint(_msgSender(),_initialAmount);

    }

    function mint(address _receiver, uint256 _amount) external onlyOwner(){
        _mint(_receiver,_amount);
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    

}