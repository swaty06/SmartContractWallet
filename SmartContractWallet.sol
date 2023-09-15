//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartContractWallet{

    address payable owner;
    mapping (address => uint ) public allowance;
    mapping(address => bool ) public isAllowedTosend;
    mapping(address=>bool) public guardians;

    address payable nextOwner;
    mapping(address => mapping(address =>bool)) nextOwnerGuardian;
    uint guardianCount;
    uint public constant confirmationFromGuard=3;

    constructor(){
        owner = payable(msg.sender);
    }

    function setGuardian(address guardian,bool isguard)public{
        require(msg.sender == owner ,"you are not owner");
        guardians[guardian] = isguard;
    }

    function proposedOwner(address payable newOwner)public{
        require(guardians[msg.sender],"aborting");
        require(nextOwnerGuardian[newOwner][msg.sender]==false,"aborting you voted");
        if(nextOwner!= nextOwner){
            nextOwner=newOwner;
            guardianCount=0;
        }
        guardianCount++;

        if(guardianCount>=confirmationFromGuard){
            owner=nextOwner;
            nextOwner=payable (address(0));
        }
    }
    function setAllowance(address to,uint amount)public{
        require(msg.sender ==owner ," you are not owner aborting");
        allowance[to] = amount;
        if(amount>0){
            isAllowedTosend[to] = true;
        }else{
            isAllowedTosend[to] = false;
        }

    }
    function transfer(address payable to,uint amount,bytes memory payload)public returns(bytes memory){
       // require(msg.sender==owner, "You are not the owner");
        if(msg.sender != owner){
            require(allowance[msg.sender]>= amount,"youre trying to send more");
            require(isAllowedTosend[msg.sender],"youre trying to send more");

            allowance[msg.sender]-= amount;
        }
        (bool success,bytes memory returnData) = to.call{value:amount}(payload);
       return returnData;
    }

    receive() external payable {}

}
