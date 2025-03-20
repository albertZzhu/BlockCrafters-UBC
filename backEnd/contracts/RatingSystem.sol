// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RatingSystem {
    struct RatingInfo {
        uint256 totalRating;
        uint256 ratingCount;
        string commentIPFSHash; // TODO: IPFS hash for long stirngs
    }

    // startup address => rating info
    mapping(address => RatingInfo) public startupRatings;

    event StartupRated(
        address indexed startup,
        address indexed rater,
        uint8 rating
    );

    /**
     * @dev rating score [1,5].
     */
    function rateStartup(address startup, uint8 rating) external {
        require(rating >= 1 && rating <= 5, "Rating must be 1-5");
        require(startup != address(0), "Invalid startup address");

        RatingInfo storage info = startupRatings[startup];
        info.totalRating += rating;
        info.ratingCount += 1;

        emit StartupRated(startup, msg.sender, rating);
    }

    function getAverageRating(address startup) external view returns (uint256) {
        RatingInfo storage info = startupRatings[startup];
        if (info.ratingCount == 0) {
            return 0; // no ratings yet
        }
        return info.totalRating / info.ratingCount;
    }
}
