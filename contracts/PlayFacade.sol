pragma solidity ^0.4.21;

import {RockPaperScissors} from './RockPaperScissors.sol';

contract PlayFacade {
    uint idGamePlay;
    mapping(address => Balances) public balances;
    mapping(uint256 => Obj) public playList;
    PlaySuggest[] public suggests;
    event Expose(address play, address player);
    event PullOut(address player, uint256 count);
    
    struct Balances {
        uint256 fix;
        uint256 cur;
    }

    struct Obj {
        RockPaperScissors play;
        uint256 stake;
        bool pd;
    }

    struct PlaySuggest {
        address playerFirst;
        address playerSecond;

        uint256 stake;

        bool accepte;
        bool create;
    }

    function PlayFacade() public {
        idGamePlay = 0;
    }

    function charge() public payable {
        balances[msg.sender].cur += msg.value;
    }

    function pullOut() public {
        uint256 count = balances[msg.sender].cur;
        balances[msg.sender].cur = 0;
        PullOut(msg.sender, count);
        msg.sender.transfer(count);
    }

    function suggest(address playerSecond, uint256 stake) public returns (uint256){
        require(balances[msg.sender].cur >= stake);
        suggests.push(playSuggest(msg.sender, playerSecond, uint256(block.number), stake, false, false));
        return uint256(suggests.length);
    }

    function accept(uint256 id) public {
        PlaySuggest curr = suggests[id];
        require(msg.sender == curr.playerSecond);
        require(balances[msg.sender].cur >= curr.stake);
        curr.accepte = true;
    }

    function create(uint256 suggest) public returns (address, uint256){
        PlaySuggest curr = suggests[suggest];
        require(curr.accepte);
        
        require(balances[curr.playerFirst].cur >= curr.stake);
        require(balances[curr.playerSecond].cur >= curr.stake);
        
        balances[curr.playerFirst].cur -= curr.stake;
        balances[curr.playerSecond].cur -= curr.stake;
        
        balances[curr.playerFirst].fix += curr.stake;
        balances[curr.playerSecond].fix += curr.stake;
        
        RockPaperScissors play = new RockPaperScissors(curr.playerFirst, curr.playerSecond);
        curr.create = true;

        idGamePlay++;

        playList[idGamePlay] = PlayInstance(g, curr.stake, false);

        return (play, idGamePlay);
    }

    function collector(uint256 idPlay) public {
        Obj storage match = playList[idPlay];
        require(match.pd == false);

        int res = match.play.winner();
        
        address playerFirst = address(match.play.playerFirst());
        address playerSecond = address(match.play.playerSecond());

        uint256 stake = match.stake;
        match.pd = true;

        if (res == 0) {
            balances[playerFirst].fix -= stake;
            balances[playerSecond].fix -= stake;

            balances[playerSecond].cur += stake;
            balances[playerFirst].cur += stake;

            Expose(address(match.play), address(match.play));

        } else if (res == - 1) {
            balances[playerFirst].fix -= stake;
            balances[playerSecond].fix -= stake;

            balances[playerSecond].cur += 2 * stake;

            Expose(address(match.play), playerSecond);

        } else if (res == 1) {
            balances[playerFirst].fix -= stake;
            balances[playerSecond].fix -= stake;
            
            balances[playerFirst].cur += 2 * stake;
            
            Expose(address(match.play), playerFirst);
        }                
    }
}