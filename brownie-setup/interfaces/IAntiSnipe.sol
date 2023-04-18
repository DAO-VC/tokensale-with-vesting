// SPDX-License-Identifier: MIT
/// @author KRogLA (https://github.com/krogla)
pragma solidity ^0.8.0;



interface IAntiSnipe {

    function check(address _msgSender, bytes calldata _msgData) external view returns (bool);
}
