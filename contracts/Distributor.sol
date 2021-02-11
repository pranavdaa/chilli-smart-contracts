pragma solidity 0.7.5;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";


contract Distributor {
    using SafeERC20 for IERC20;

    event Distributed(address[] receivers, uint256[] amounts);

    function distribute(
        address token,
        address[] calldata receivers,
        uint256[] calldata amounts
    )
        external
    {
        require(receivers.length == amounts.length, "Invalid data!!");
        for (uint256 i = 0; i < receivers.length; i++) {
            IERC20(token).safeTransferFrom(
                msg.sender,
                receivers[i],
                amounts[i]
            );
        }

        emit Distributed(receivers, amounts);
    }
}
