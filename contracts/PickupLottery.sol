// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./WithCards.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

/**
    [[[ Simple Playing Card Lottery Game ]]]
*/
contract PickupLottery is WithCards, Ownable {
    using SafeMath for uint256;
    
    uint256 public fee = 0.01 * (10**18);
    uint8 public winningCard = 3;
    uint8 public pickupLimit = 40;
    // 1 week limit for single game
    uint256 public timeLimit = 7 * 24 * 60 * 60 * 1000;
    uint256 public bonusPercentage = 90;

    uint256 private constant MAX_TIME_LIMIT = 6 * 30 * 24 * 60 * 60 * 1000;
    uint256 private constant MIN_TIME_LIMIT = 5 * 60 * 1000;
    uint256 private constant MAX_BONUS_PERCENTAGE = 95;

    bool public started = false;
    uint256 public startedTime;
    uint256 public endTime;

    address private _winner;

    address [] private players;

    // player address + picked-up card
    mapping (address => uint8) private pickupStatus;

    // player address + paid fee
    mapping (address => uint256) private balances;

    // player address + nick name
    mapping (address => bytes) private nicknames;

    // player address + awarded bonus amount
    mapping (address => uint256) private bonuses;

    bytes[] public winners;

    modifier onlyStopped() {
        require (!started);
        _;
    }

    modifier onlyStarted() {
        require (
            started && 
            (block.timestamp < startedTime + timeLimit) && 
            (pickupStatus.length < pickupLimit)
        );
        _;
    }

    event GameStarted(uint256 startedTime);
    event GameStopped(uint256 startedTime, uint256 stoppedTime);

    event FeeChanged(uint256 oldFee, uint256 newFee);
    event WinningCardChanged(uint8 oldCard, uint8 newCard);
    event PickupLimitChanged(uint8 oldLimit, uint8 newLimit);
    event TimeLimitChanged(uint256 oldLimit, uint256 newLimit);
    event BonusPercentageChanged(uint256 oldBonus, uint256 newBonus);

    event CardPicked(uint256 numberOfPicks);

    /**
        Owner's role
     */
    function updateFee(uint256 _fee) external onlyOwner onlyStopped {
        require(_fee > 0, "Fee should not be zero.");
        emit FeeChanged(fee, _fee);
        fee = _fee;
    }

    function updateWinningCard(uint8 _card) external onlyOwner onlyStopped onlyValidCard(_card) {
        emit WinningCardChanged(winningCard, _card);
        winningCard = _card;
    }

    function updatePickupLimit(uint8 _limit) external onlyOwner onlyStopped {
        require(_limit > 0 && _limit < 55, "Pickup limit should be less than 54.");
        emit PickupLimitChanged(pickupLimit, _limit);
        pickupLimit = _limit;
    }

    function updateTimeLimit(uint256 _limit) external onlyOwner onlyStopped {
        require(
            _limit > MIN_TIME_LIMIT && _limit < MAX_TIME_LIMIT,
            "Time limit should be between 5 minutes and 6 months."
        );
        emit TimeLimitChanged(timeLimit, _limit);

        timeLimit = _limit;
    }

    function updateBonusPercentage(uint256 _bonus) external onlyOwner onlyStopped {
        require(
            _bonus > 0 && _bonus < MAX_BONUS_PERCENTAGE,
            "Winner's bonus should be less than 95% of all incomes."
        );
        emit BonusPercentageChanged(bonusPercentage, _bonus);
        bonusPercentage = _bonus;
    }

    // startGame()
    // generate randomized cards list
    // and record start time
    function startGame() external onlyOwner onlyStopped {
        // clear previous status
        for (uint i; i < players.length; i++) {
            delete balances[palyers[i]];
            delete pickupStatus[players[i]];
        }
        _winner = address(0);
        delete endTime;

        // reset new game
        generateCardsList();
        started = true;
        startedTime = block.timestamp;

        emit GameStarted(startedTime);
    }

    function stopGame() external onlyOwner onlyStarted {
        _stopGame();
    }

    function _stopGame() internal onlyStarted {
        started = false;
        endTime = block.timestamp;

        // calculate total income, and find winner
        uint256 totalIncome;
        for (uint i = 0; i < players.length; i++) {
            address player = players[i];
            totalIncome += balances[player];

            uint8 card = pickupStatus[player];
            if (card == winningCard) {
                _winner = player;
            }
        }

        if (_winner != address(0)) {
            bonuses[_winner] += totalIncome.mul(bonusPercentage).div(100);
            winners.push(nicknames[_winner]);
        }

        emit GameStopped(startedTime, endTime);
    }

    // This will finish the game unexpectedly, so it will refund all balances to card holders
    // and reset all status
    function cancel() external onlyOwner onlyStarted {

    }

    function transfer(address payable recipient, uint256 amount) external onlyOwner{
        require(address(this).balance > amount, "Insufficient balance.");
        recipient.transfer(amount);
    }

    /**
        Player's role
     */
    function pick(bytes nickName) external payable onlyStarted returns (uint8 card) {
        require(!pickupStatus[msg.sender], "Player can pick up card at once.");
        require(msg.value >= fee, "Player must pay to pick up a card.");

        // upgrade nick name
        if (nickName.length > 0) {
            nicknames[msg.sender] = nickName;
        }

        pickupStatus[msg.sender] = _cardsList[players.length];
        players.push(msg.sender);
        balances[msg.sender] = msg.value;
        emit CardPicked(players.length);

        if (players.length == pickupLimit) {
            _stopGame();
        }
        card = pickupStatus[msg.sender];
    }

    function picked() external view returns (uint8 card) {
        return pickupStatus[msg.sender];
    }

    function withdraw(uint256 amount) external {
        require(bonuses[msg.sender] > amount, "Insufficient funds.");
        bonuses[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    /**
        Public role
     */
    function leftTime() external view returns (uint256) {
        return (startedTime.add(timeLimit) > block.timestamp) ? 
            startedTime.add(timeLimit).sub(block.timestamp) :
            0;
    }

    function progress() external view returns (uint) {
        return players.length;
    }

    // returns all picked-up cards, without holders address
    function allPickedUp() external view onlyStopped returns (uint8[] memory cards) {
        for (uint i; i<players.length; i++) {
            cards.push(pickupStatus[players[i]]);
        }
    }

    function winner() external view onlyStopped returns (bytes) {
        return nicknames[_winner];
    }
}
