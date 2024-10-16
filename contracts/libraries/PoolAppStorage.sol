// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8;

library PoolAppStorage {
    struct Layout {
        mapping(address => uint) users;
        address[] eligible_users;
        address owner;
        address token;
    }

    function storaged() external pure returns (Layout storage l) {
        assembly {
            l.slot := 1
        }
    }
}
