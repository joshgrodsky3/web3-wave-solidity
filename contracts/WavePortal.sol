// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint totalWaves;
    uint256 private seed;
    mapping(address => uint) public waveAmount;
    uint totalAccounts;

    event NewWave(address indexed from, uint256 timestamp);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved. 
        uint256 timestamp; // The timestamp when the user waved.
    }

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;
    /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

      constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
      }

    function getAccountWaves(address sender) public view returns (uint256) {
         return waveAmount[sender];
     }

    //uint waveAmt = waveAmount[msg.sender];
    function wave() public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30 seconds"
        );
        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        
        console.log("%s has waved with message %s!", msg.sender);
        if(waveAmount[msg.sender] > 0) {
            //console.log("They have waved %d times before", waveAmount[msg.sender]);
        }
        else {
            //console.log("This is their first time waving!");
            totalAccounts += 1;
        }
        /*
         * This is where I actually store the wave data in the array.
         */
         console.log('block num: %s', block.number);
        waves.push(Wave(msg.sender, block.timestamp));
        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 20) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        emit NewWave(msg.sender, block.timestamp);
        waveAmount[msg.sender] = waveAmount[msg.sender] + 1;
    }

    /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalAccounts() public view returns(uint256){
        return totalAccounts;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}