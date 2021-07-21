## Simple Playing Card Lottery Game

Players can pick one card with paying 0.01 eth(fee), card is determined by randomic method.
Then he will get one playing-card immediately, but not public to someone else until game over.
After time-limit (or all cards were picked), all picked-up cards will be shared as public as the order of picking-up.
The winner (heart-3) will get 90% of the income as a bonus.

### Smart Contracts Description
* Public accessible interface has the following functions
    - configuration
        fee
        winning card
        pickup-limit
        time-limit period
    - latest game status
        start / stop status
        started time
        end time
        left time
        progress, just number of picked-up cards
        pickedup cards list
    - winners list
* Owner have the authority of the following features:
    - Start / Stop / Cancel game
        Start: resets game status
        Stop: it will refund all pending balances to the card holders
    - Configuration
        fee
        winning card
        pickup-limit
        time-limit period
    - Withdraw balances
* Player
    - pickup (with paying fixed amount of fee) [if already started]
    - picked-up card [if already started and picked]
    - withdraw (withdraw bonus only if winned) [if after winned]

### License
MIT

Thanks for leaving a tip for one cup of coffee!

ETH: ```0x620dc94C842817d5d8b8207aa2DdE4f8C8b73415```
