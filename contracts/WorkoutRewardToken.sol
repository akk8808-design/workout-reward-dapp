// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WorkoutRewardToken is ERC20, Ownable {

    struct WorkoutRecord {
        address user;
        string workoutType;
        uint256 duration;
        string intensity;
        uint256 rewardAmount;
        uint256 timestamp;
        bool photoVerified;
    }

    mapping(address => uint256) public lastClaimTime;
    mapping(address => WorkoutRecord[]) public userRecords;

    event WorkoutRecorded(
        address indexed user,
        string workoutType,
        uint256 duration,
        string intensity,
        uint256 rewardAmount,
        bool photoVerified
    );

    constructor() ERC20("Workout Reward Token", "WKT") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function recordWorkout(
        string memory workoutType,
        uint256 duration,
        string memory intensity,
        bool photoVerified
    ) public {
        require(duration >= 10, "Minimum 10 minutes required");
        require(
            block.timestamp >= lastClaimTime[msg.sender] + 1 days,
            "Already claimed today"
        );

        uint256 reward = 0;

        if (duration >= 60) {
            reward = 20 * 10 ** decimals();
        } else if (duration >= 30) {
            reward = 10 * 10 ** decimals();
        } else if (duration >= 10) {
            reward = 5 * 10 ** decimals();
        }

        if (keccak256(bytes(intensity)) == keccak256(bytes("hard"))) {
            reward += 5 * 10 ** decimals();
        }

        if (photoVerified) {
            reward += 3 * 10 ** decimals();
        }

        lastClaimTime[msg.sender] = block.timestamp;

        userRecords[msg.sender].push(WorkoutRecord({
            user: msg.sender,
            workoutType: workoutType,
            duration: duration,
            intensity: intensity,
            rewardAmount: reward,
            timestamp: block.timestamp,
            photoVerified: photoVerified
        }));

        _transfer(owner(), msg.sender, reward);

        emit WorkoutRecorded(msg.sender, workoutType, duration, intensity, reward, photoVerified);
    }

    function getMyRecords() public view returns (WorkoutRecord[] memory) {
        return userRecords[msg.sender];
    }

    function getRecordCount() public view returns (uint256) {
        return userRecords[msg.sender].length;
    }
}
