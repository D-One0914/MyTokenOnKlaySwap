// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/klaytn/klaytn-contracts/blob/master/contracts/KIP/token/KIP7/IKIP7.sol";

/*
    단위 변환기(클레이튼 사용가능) : https://eth-converter.com/

    Decimal : 18 
    10000 Token = 10000 * 10^18 = 10^22 = 1000000000000000000000 
    1000 Token = 1000 * 10^18 = 10^21 = 1000000000000000000000 
    100 Token = 100 * 10^18 = 10^20 = 100000000000000000000 
    10 Token = 10 * 10^18 = 10^19 = 10000000000000000000 
    1 Token =  1 * 10^18 = 10^18 = 1000000000000000000 
    0.1 Token =0.1 * 18^18 = 10^17 = 100000000000000000

    이더리움
    1 Ether = 10^18 = 1000000000000000000 wei
    1 Gwei = 10^9 = 10000000 wei
    1 Wei = 1 wei

    클레이튼
    1 Klay = 10^18 = 1000000000000000000 peb
    1 Gpeb = 10^9 = 10000000 peb
    1 Peb = 1 peb

    _Amount = 1 Token (1000000000000000000) <-> _Price = 10 klay (10 * 10^18)
    _Maximumnumber = 2 번만 구매

    1차: A ( 0x12..bc) -> 10 klay -> 1 token 
    2차: A ( 0x12..bc) -> 10 klay -> 1 token 

    3차: A ( 0x12..bc) -> 10 klay -> 1 token 구매 불가.  _Maximumnumber = 2  


    0x73CB7c373F73E4e635Dd75837B8e2aDaF5247e7E
    1klay - > 1D 토큰  

*/

/*

    klay : 클레이 주소
    myToken: 현재 판매하는 토큰 주소
    price: 판매 가격
    amount: 회차 당 판매되는 토큰의 수
    maximumNumber: 토큰 구매 가능 횟수  
    stop: 판매 시작 여부
       - false : 시작 (기본값)
       - true : 정지
    balance: 토큰 잔액 조회


    setPrice : Price(토큰의 판매 가격) 변경
    setAmount : Amount(회차 당 판매되는 토큰의 수) 변경
    setMaximumNumber : maximumNumber(토큰 구매 가능 횟수) 변경
    setStop: 판매 시작 여부 변경 
       - false : 시작 (기본값)
       - true : 정지
    reset : 리셋 하기 
        - 이전에 토큰을 횟수만큼 구매해서 현재 구매 못하는 사람도 다시 구매 가능
   
    withdraw: 토큰 출금


*/

contract MyPreSale is Ownable {
    
    //Event
    event Sale(address indexed buyer, uint256 price ,uint256 amount);

    //ERROR
    error StopSale();
    error InsufficeintBalanceToSell(uint256 _currentBalance);
    error IncorrectPrice(uint256 _currentPrice, uint256 _receivedValue);
    error AlreadyPurchased();

    address public constant klay = address(0);
    IKIP7 public immutable myToken;
     
    bool public stop=true;
    uint256 public price;
    uint256 public amount;
    uint256 public maximumNumber;
    uint256 public round;
    mapping(uint256 => mapping(address=>uint))  public userInfo;

    constructor(address _myToken, uint256 _price, uint256 _amount, uint256 _maximumNumber) {
        myToken = IKIP7(_myToken);
        price = _price;
        amount = _amount;
        maximumNumber = _maximumNumber;
    }

    receive() payable external {
        purchaseToken();
    }   

    function purchaseToken() public payable {
        if(stop) {
            revert StopSale();
        }
        address _currentUser = msg.sender;
        uint256 _price = price;
        uint256 _amount = amount;
        uint256 currentBalance = myToken.balanceOf(address(this));
        mapping(uint256 => mapping(address=>uint)) storage _userInfo = userInfo;
        
        if(currentBalance < amount) {
            revert InsufficeintBalanceToSell(currentBalance);
        }

        if(_price!=msg.value) {
            revert IncorrectPrice(_price, msg.value);
        }

        if(_userInfo[round][_currentUser]==maximumNumber) {
            revert AlreadyPurchased();
        }
        ++_userInfo[round][_currentUser];
        myToken.transfer(_currentUser, _amount);
        emit Sale(_currentUser, _price, _amount);
    }

    function setStop(bool _stop) external onlyOwner() {
        stop = _stop;
    }

    function setPrice(uint256 _price) external onlyOwner() {
        price = _price;
    }

    function setAmount(uint256 _amount) external onlyOwner() {
        amount = _amount;
    }

    function setMaximumNumber(uint256 _maximumNumber) external onlyOwner() {
        maximumNumber = _maximumNumber;
    }

    function reset() external onlyOwner() {
        ++round;
    }

    function withdraw(address _token) external onlyOwner() {
        if(_token == address(0)) {
            (bool _result, ) = msg.sender.call{value:address(this).balance}("");
            require(_result, "Failed To withdraw");
        }else{
            myToken.transfer(msg.sender, myToken.balanceOf(address(this)));
        }
    }

    function balance(address _token) external view returns(uint256) {
        return _token == address(0) ? address(this).balance : myToken.balanceOf(address(this));
    }

}