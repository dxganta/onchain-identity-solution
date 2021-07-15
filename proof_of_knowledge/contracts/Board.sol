// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

import "../deps/UniformRandomNumber.sol";

/*
A slight modification of the Ownable contract.
Instead of one owner, there will be multiple board members and
A member of the board will be chosen as owner randomly after every POK test is finished
And it will be the job of that member to design the upcoming test
*/

contract Board {
    address[] private _members;
    address private _owner;

    mapping(bytes32 => bool) voteNewMemberMap;

    event NewOwner(address owner, uint time);
    event NewMemberAdded(address member, uint time);
    event MemberVote(address fromMember, address toNewMember, uint time);

    constructor(address[] memory _boardMembers) public {
        _members = _boardMembers;
        _owner = _members[0];
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function members() public view virtual returns (address[] memory) {
        return _members;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Transfers ownership of the contract to a new account which is chosen randomly from the set of members.
     * Can only be called by the current owner.
     */
    function transferOwnership() public virtual onlyOwner {
        _setNewOwner();
    }

    function _setNewOwner() internal {
        uint rand =  uint(keccak256(abi.encodePacked(now, _owner)));
        uint ind = UniformRandomNumber.uniform(rand, _members.length);
        _owner = _members[ind];
        emit NewOwner(_owner, now);
    }

    /*
        sends out a vote from msg.sender to include _newMember in the _members array
        callable by anyone
        only makes a sense if a board member calls this function
        else you are just wasting gas fees because when calling the addNewMember function
        we only check the votes by board members
    */
    function voteNewMember(address _newMember) external {
        bytes32 b = keccak256(abi.encodePacked(_newMember, msg.sender));
        voteNewMemberMap[b] = true;
        emit MemberVote(msg.sender, _newMember, now);
    }

    /*
        adds a new member to that vote
        callable by anyone
        the new member must first be voted true by all members of the board
        using the voteNewMember() function
    */
    function addNewMember(address _newMember) public {
        bool isVotedByAll = true;
        bytes32 b;
        for (uint i =0; i < _members.length; i++) {
            b = keccak256(abi.encodePacked(_newMember, _members[i]));
            if (!voteNewMemberMap[b]) {
                isVotedByAll = false;
            }
        }
        if (isVotedByAll) {
            _members.push(_newMember);
            emit NewMemberAdded(_newMember, now);
        }
    }
}