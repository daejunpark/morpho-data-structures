// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/LogarithmicBuckets.sol";

contract TestLogarithmicBucketsGas is Test {
    using LogarithmicBuckets for LogarithmicBuckets.BucketList;

    LogarithmicBuckets.BucketList internal bucketList;

    // Gas accounting.
    uint256 internal insertCost;
    uint256 internal insertCount;
    uint256 internal updateValueCost;
    uint256 internal updateValueCount;
    uint256 internal removeCost;
    uint256 internal removeCount;
    uint256 internal getHeadCost;
    uint256 internal getHeadCount;

    function testGasUsage() public noGasMetering {
        for (uint256 i; i <= 10000; i++) {
            // Get a random amount.
            uint96 amount = uint96(uint256(keccak256(abi.encode(i))));

            // Reset the free memory pointer.
            assembly {
                mstore(0x40, 0x80)
            }

            // Insert into DS (p=1/2).
            if (amount % 4 < 2) {
                // Measure insert.
                startGasMetering();
                bucketList.update(address(uint160(amount)), amount);
                insertCost += stopGasMetering();
                insertCount++;
            }
            // Update value in same bucket (p=1/4).
            else if (amount % 4 == 2) {
                // Get an account to update its value.
                address toUpdate = bucketList.getMatch(amount, true);

                if (toUpdate != address(0)) {
                    // Measure updateValue.
                    startGasMetering();
                    bucketList.update(toUpdate, amount);
                    updateValueCost += stopGasMetering();
                    updateValueCount++;
                }
            }
            // Remove from DS (p=1/4).
            else {
                // Measure getMatch.
                startGasMetering();
                address toUpdate = bucketList.getMatch(amount, true);
                getHeadCost += stopGasMetering();
                getHeadCount++;

                if (toUpdate != address(0)) {
                    // Measure remove.
                    startGasMetering();
                    bucketList.update(bucketList.getMatch(amount, true), 0);
                    removeCost += stopGasMetering();
                    removeCount++;
                }
            }
        }

        // Print average cost of insert, updateValue, remove and getMatch.
        console.log(insertCost / insertCount);
        console.log(updateValueCost / updateValueCount);
        console.log(removeCost / removeCount);
        console.log(getHeadCost / getHeadCount);
    }
}
