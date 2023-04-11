// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract erc20Sample is ERC20{

    constructor() ERC20("Token", "TKN") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external {
        require(to!=address(0),"Zero address sent");
        _mint(to, amount);
    }

    function decimals() public view virtual override(ERC20) returns (uint8) {
        return 18;
    }

}
