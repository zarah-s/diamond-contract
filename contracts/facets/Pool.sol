// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8;
import "../libraries/PoolAppStorage.sol";
import "../interfaces/IERC20.sol";

contract Pool {
    function list_user(address user, uint8 amount) external {
        require(msg.sender == poolStorage().owner, "UNAUTHORIZED");

        poolStorage().users[user] = amount;
    }

    function disburse() external {
        for (uint i = 0; i < poolStorage().eligible_users.length; i++) {
            uint amount = poolStorage().users[poolStorage().eligible_users[i]];
            bool success = IERC20(poolStorage().token).transfer(
                poolStorage().eligible_users[i],
                amount
            );

            require(success);
        }
    }

    function poolStorage()
        internal
        returns (PoolAppStorage.Layout storage lll)
    {
        lll = PoolAppStorage.storaged();
    }
}
