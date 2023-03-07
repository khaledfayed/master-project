// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

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