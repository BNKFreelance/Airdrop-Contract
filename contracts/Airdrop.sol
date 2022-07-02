//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Airdrop is ReentrancyGuard {
    address public owner;
    IERC20 public token;
    uint256 public rewardAmountPerAddress;
    uint256 public cooldownTime = 1 minutes;

    mapping(address => bool) public whitelistByAddress;
    mapping(address => uint256) public pendingBalanceByAddress;
    mapping(address => uint256) public claimReadyByAddress;

    constructor(address _token, uint256 _rewardAmountPerAddress) {
        owner = msg.sender;
        token = IERC20(_token);
        rewardAmountPerAddress = _rewardAmountPerAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'You must be the owner.');
        _;
    }

    /**
     * @notice Calculate the percentage of a number.
     * @param x Number.
     * @param y Percentage of number.
     * @param scale Division.
     */
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    /**
     * @notice Function that allows to add investors to the whitelist.
     * @param _users Array of addresses to be added to the whitelist.
     */
    function addWhitelist(address[] memory _users) public onlyOwner {
        for(uint16 i = 0; i < _users.length; i++) {
            require(_users[i] != address(0), 'Invalid address.');
            whitelistByAddress[_users[i]] = true;
            claimReadyByAddress[_users[i]] = block.timestamp + cooldownTime;
            pendingBalanceByAddress[_users[i]] = rewardAmountPerAddress;
        }
    }

    /**
     * @notice Function that allows users to claim their available tokens.
     */
    function claimTokens() public nonReentrant {
        require(whitelistByAddress[msg.sender], "You must be on the whitelist.");
        require(claimReadyByAddress[msg.sender] <= block.timestamp, "You can't claim now.");
        require(pendingBalanceByAddress[msg.sender] > 0, "Insufficient pending balance.");

        uint256 _withdrawableTokensBalance = mulScale(rewardAmountPerAddress, 1000, 10000); // 1000 basis points = 10%.
        uint256 _contractBalance = token.balanceOf(address(this));
        require(_contractBalance >= _withdrawableTokensBalance, "Insufficient contract balance.");

        claimReadyByAddress[msg.sender] += cooldownTime;
        pendingBalanceByAddress[msg.sender] -= _withdrawableTokensBalance;

        token.transfer(msg.sender, _withdrawableTokensBalance);
    }
}
