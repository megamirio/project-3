pragma solidity ^0.4.21;

contract RockPaperScissors {

    address public playerFirst;
    address public playerSecond;

    uint public playersUnited = 0;
    uint public maxPlayers = 2;
    bool public stage = false;

    event Step(address, uint);

    mapping(address => Chosen) public movement;

    struct Chosen {
        bytes32 insecure;
        bytes32 encrypt;
    }

    modifier stageFirst() {
        require(stage == false);
        require(playersUnited < maxPlayers);
        _;
    }

    modifier stageSecond() {
        require(stage == true);
        require(playersUnited < maxPlayers);
        _;
    }

    modifier onlyPlayer() {
        require(msg.sender == playerFirst || msg.sender == playerSecond);
        _;
    }

    function RockPaperScissors(address playerFirst, address playerSecond) public {

        require(playerFirst != 0);
        require(playerSecond != 0);

        playerFirst = playerFirst;
        playerSecond = playerSecond;
    }

    function play(bytes32 hash) public payable stageFirst onlyPlayer {
        movement[msg.sender] = PlayersChoise(hash, '');

        playersUnited++;
        
        if (playersUnited == maxPlayers) {
            stage = true;
            playersUnited = 0;
        }
    }

    function expose(bytes32 decision) public payable stageSecond onlyPlayer {
        require(movement[msg.sender].encrypt == keccak256(decision));
        movement[msg.sender].insecure = decision;
        
        Step(msg.sender, uint(movement[msg.sender].insecure[0]));
        
        playersUnited++;
    }

    function winner() public view returns (int) {
        if (stage && (maxPlayers == playersUnited)) {
            uint[2] memory res;

            address[2] memory players = [playerFirst, playerSecond];
            int[3] memory sol = [int(0), - 1, 1];

            for (uint i = 0; i <= 1; i++) {
                res[i] = uint(movement[players[i]].insecure[0]);
            }

            return sol[(res[0] + res[1]) % 3];
        }
    }
}
