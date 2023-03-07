// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyModifier{

    bool private IS_LOCKED;
    uint private count = 0;

    constructor (){
        IS_LOCKED = false;
    }

    function lock() private{
        IS_LOCKED = true;
    }
    
    function unLock() private{
        IS_LOCKED = false;
    }

    modifier guard {
            require(!IS_LOCKED);
            lock();
            // uint x =0;
            count++;
            _;
            assert(count == 1);
            count = 0;
            unLock();
        }

}