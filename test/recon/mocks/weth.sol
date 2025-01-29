pragma solidity >=0.8.0;

import {IWETH} from "./IWETH.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is IWETH, ERC20("Wrapped Ether", "WETH") {
    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    receive() external payable virtual {
        deposit();
    }
}
