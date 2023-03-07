// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lock {
    bool internal locked;

    modifier reentancyLock() {
        require(!locked, "No re-entrancy");
        locked = true;
        bool lockedInitial = locked;
        _;
        assert(lockedInitial == locked);
        locked = false;
    }
}