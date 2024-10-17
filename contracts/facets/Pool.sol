// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8;
import "../libraries/PoolAppStorage.sol";
import "../interfaces/IERC20.sol";

error UNAUTHORIZED();
error UNAUTHORIZEDD();
uint8 constant poolcont = 5;

contract Pool {
    uint256 i;
    PoolAppStorage.Layout p;

    function list_user(address user, uint8 amount) external {
        require(msg.sender == p.owner, UNAUTHORIZED());

        p.users[user] = amount;
    }

    function disburse() external {
        for (uint i = 0; i < p.eligible_users.length; i++) {
            uint amount = p.users[p.eligible_users[i]];
            bool success = IERC20(p.token).transfer(
                p.eligible_users[i],
                amount
            );

            require(success);
        }
    }
}
