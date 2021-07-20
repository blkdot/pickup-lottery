// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

/**
    Playing Card

    01 ~ 13: Heart A - K
    14 ~ 26: Spade A - K
    27 ~ 39: Diamond A - K
    40 ~ 52: Club A - K
    53: Black Joker
    54: Red Joker
 */

contract WithCards {
    uint8[54] private _cardsList;

    modifier onlyValidCard(uint8 _card) {
        require(_card > 0 && _card < 55, "Card should be between 1 and 54");
        _;
    }

    function initCardsList() private {

    }

    function generateCardsList() private {

    }
}