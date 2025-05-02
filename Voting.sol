// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting{
    address immutable owner;
    struct Election{
        uint electionId;
        string electionName;
        bool isActive;
        uint startTime; 
        uint endTime;
        uint totalCandidates;
        uint totalVoters;
        uint totalVotes;
        uint winnerId;
        bool registrationPhase;
        bool votingPhase;
        bool isCompleted;   
    }
    struct Candidate{
        uint candidateId;
        address candidateAddress;
        string candidateName;
        uint electionId;
        uint voteCount;
    }
    struct Voter{
        uint voterId;
        string voterName;
        address voterAddress;
        uint electionId;
        uint candidateId;
        bool isVoted;
        bool isRegistered;
    }
    mapping(uint => Election) public  elections;
    mapping(uint => mapping(uint => Candidate)) public candidates;
    mapping(uint => mapping(address => bool)) public isCandidateRegistered;
    mapping(uint => mapping (address => Voter)) public voters;

    event electionCreated(uint indexed electionId, string electionName, uint startTime, uint endTime);
    event addCandidateEvent(uint candidateId,string message);
    event regVoterEvent(uint voterId, string message);
    event castVoteEvent(uint voterId, string message);
    event activeElectionEvent(uint indexed electionId,string message);
    event deactiveElectionEvent(uint indexed electionId,string message);
    event activeRegistrationEvent(uint indexed electionId,string message);
    event deactiveRegistrationEvent(uint indexed electionId,string message);
    event activeVotingEvent(uint indexed electionId,string message);
    event deactiveVotingEvent(uint indexed electionId,string message);
    event completeElectionEvent(uint indexed electionId,string message);
    event getWinnerEvent(uint indexed electionId,string message, uint winnerId);

    uint electionCount;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyAdmin(){
        require(owner==msg.sender,"only admin");
        _;
    }
    modifier isValidString(string memory _string){
        require(bytes(_string).length > 0,"Invalid");
        _;
    }
    modifier isValidNumber(uint _number){
        require(_number > 0,"Invalid");
        _;
    }
    modifier isValidAddress(address _address){
        require(_address != address(0),"Invalid");
        _;
    }
    function getOwner() public view  returns (address){
        return owner;
    }
    function getBlockTimestamp() public view returns(uint){
        return block.timestamp;
    }
    function createElection(string memory _electionName,uint _startTime, uint _endTime) onlyAdmin isValidString(_electionName) public {
        require(block.timestamp <= _endTime, "Invalid end time!");
        // require(elections[_electionId]._electionName != _electionName);
        require(_startTime<=_endTime,"Start time must be before end time");
        elections[electionCount] = Election({
                        electionId: electionCount, 
                        electionName: _electionName, 
                        isActive: false,
                        startTime: _startTime,
                        endTime: _endTime,
                        totalCandidates: 0,
                        totalVoters: 0,
                        totalVotes: 0,
                        winnerId: 0,
                        registrationPhase: false,
                        votingPhase: false,
                        isCompleted: false
                    });
        emit electionCreated(electionCount, _electionName, _startTime, _endTime);
        electionCount++;
    }
    function addCandidate(uint _electionId, string memory _candidateName, address _candidateAddress) 
        onlyAdmin 
        isValidString(_candidateName)
        isValidAddress(_candidateAddress) public{
            require(_electionId<electionCount, "Invalid Election Id");
            require(!isCandidateRegistered[_electionId][_candidateAddress], "Candidate Already added!");
            require(elections[_electionId].registrationPhase, "Registration phase not active!");
            uint candidateCount = elections[_electionId].totalCandidates++;
            candidates[_electionId][candidateCount] = Candidate({
                        candidateId: candidateCount,
                        candidateAddress: _candidateAddress,
                        candidateName: _candidateName,
                        electionId: _electionId,
                        voteCount: 0 });
            isCandidateRegistered[_electionId][_candidateAddress] = true;
        emit addCandidateEvent(candidateCount,"Candidate added successfully");
    }
    function getElection(uint _electionId) public view returns( 
            uint electionId, string memory electionName,
            bool isActive, uint startTime, uint endTime,
            uint totalCandidates, uint totalVoters,
            uint totalVotes, uint winnerId, bool isCompleted    
        ){
        require(_electionId < electionCount, "Invalid election id!");
        Election memory election = elections[_electionId];  
        return ( 
            election.electionId,
            election.electionName,
            election.isActive,
            election.startTime, 
            election.endTime,
            election.totalCandidates,
            election.totalVoters,
            election.totalVotes,
            election.winnerId, 
            election.isCompleted);    
    }
    function getCandidate(uint _electionId, uint _candidateId) public view returns (
                uint candidateId, address candidateAddress,
                string memory candidateName, uint electionId, uint voteCount){
        uint candidateCount = elections[_electionId].totalCandidates;
        require(_electionId < electionCount, "Invalid candidate id!");
        require(_candidateId <= candidateCount, "Invalid candidate id!");
        Candidate memory candidate = candidates[_electionId][_candidateId];  
        return ( 
            candidate.candidateId, 
            candidate.candidateAddress,
            candidate.candidateName, 
            candidate.electionId, 
            candidate.voteCount);
    }

    function getAllElections() public view returns (Election[] memory) {
        Election[] memory allElections = new Election[](electionCount);

        for (uint i = 0; i < electionCount; i++) {
            allElections[i] = elections[i];
        }

        return allElections;
    }
    function getAllCandidates(uint _electionId) public view 
    returns(Candidate[] memory){
        require(_electionId < electionCount,"Invalid election id!");
        uint candidateCount = elections[_electionId].totalCandidates;
        Candidate[] memory allCandidates = new Candidate[](candidateCount);
        for(uint i=0; i< candidateCount; i++){
            allCandidates[i] = candidates[_electionId][i];
        }
        return (allCandidates);
    }
    function regVoter(string memory _voterName, uint _electionId, uint _candidateId, address _voterAddress) onlyAdmin
                 isValidString(_voterName) isValidAddress(_voterAddress) public{
        uint candidateCount = elections[_electionId].totalCandidates;
        require(!voters[_electionId][_voterAddress].isRegistered, "voter is already registered!");
        uint voterCount = elections[_electionId].totalVoters++;
        require(_electionId < electionCount,"Invalid election id");
        require(_candidateId < candidateCount,"invalid candidate id");
        uint newVoterId = voterCount;
        require(elections[_electionId].isActive, "election is not active!");
        require(elections[_electionId].registrationPhase, "Registration phase is not active!");
        // require(candidates[_electionId][_candidateId].electionId == _electionId,"Invalid Candidate Id");
        voters[_electionId][_voterAddress] = Voter({ 
                    voterId: newVoterId,
                    voterName: _voterName,
                    voterAddress: _voterAddress,
                    electionId: _electionId,
                    candidateId: 0,
                    isVoted: false,
                    isRegistered: true
                });
        emit regVoterEvent(newVoterId,"New voter registered");
    }

    function castVote(uint _electionId, uint _candidateId) public{
        require(voters[_electionId][msg.sender].isRegistered, "voter is not registered!");
        uint candidateCount = elections[_electionId].totalCandidates;
        require(_electionId < electionCount,"Invalid election id");
        require(_candidateId < candidateCount,"invalid candidate id");
        require(!voters[_electionId][msg.sender].isVoted, "you already voted for this election!)");
        require(elections[_electionId].isActive, "election is not active!");
        require(elections[_electionId].votingPhase, "Voting is not active!");
        require(elections[_electionId].startTime <= block.timestamp &&
                elections[_electionId].endTime >= block.timestamp,"Invalid time for voting");
        require(candidates[_electionId][_candidateId].electionId == _electionId,"Invalid Candidate Id");
        voters[_electionId][msg.sender].candidateId= _candidateId;
        voters[_electionId][msg.sender].isVoted = true;
        elections[_electionId].totalVotes++;
        candidates[_electionId][_candidateId].voteCount++;
        emit castVoteEvent(voters[_electionId][msg.sender].voterId,"voter casted vote");
    }
    function getVoter(uint _electionId, address _voterAddress) isValidNumber(_electionId) public view returns (
                    uint voterId, string memory voterName,
                    address voterAddress, uint electionId, uint candidateId, bool isVoted )
    {
        require(_electionId < electionCount,"Invalid election Id");
        if(_voterAddress == address(0))
            _voterAddress=msg.sender;
        Voter memory voter = voters[_electionId][_voterAddress];
        return(
            voter.voterId, 
            voter.voterName,
            voter.voterAddress,
            voter.electionId,    
            voter.candidateId,      
            voter.isVoted
        );
    }
    function verifyVoter(uint _electionId) public view returns(bool isRegistered){
        require(_electionId< electionCount, "Invalid Election Id");
        return voters[_electionId][msg.sender].isRegistered;
    }
    function activeElection(uint _electionId) onlyAdmin public{
        require(_electionId < electionCount, "Invalid Election Id");
        require(!elections[_electionId].isCompleted, "election is already completed!");
        require(!elections[_electionId].isActive, "election is already active!");
        elections[_electionId].isActive = true;
        emit activeElectionEvent(_electionId,"Election is Active");
    }
    function deactiveElection(uint _electionId) onlyAdmin public{
        require(_electionId <= electionCount, "Invalid Election Id");
        require(elections[_electionId].isActive, "Election is already deactiveted!");
        elections[_electionId].isActive = false;
        elections[_electionId].registrationPhase = false;
        elections[_electionId].votingPhase = false;
        emit deactiveElectionEvent(_electionId, "Election is Deactive");
    }
    function activeRegistration(uint _electionId) onlyAdmin public {
        require(_electionId < electionCount, "Invalid Election Id");
        require(elections[_electionId].isActive, "election is deactivated!");
        require(!elections[_electionId].registrationPhase, "registration is already activated!");
        elections[_electionId].registrationPhase = true;
        emit activeRegistrationEvent(_electionId, "Now registration phase is Active");
    }
    function deactiveRegistration(uint _electionId) onlyAdmin public{
        require(_electionId < electionCount, "Invalid Election Id");
        require(elections[_electionId].isActive, "election is deactivated!");
        require(elections[_electionId].registrationPhase, "registration is already deactivated!");
        elections[_electionId].registrationPhase = false;
        emit deactiveRegistrationEvent(_electionId,"Now registration phase is Deactivated");
    }
    function activeVoting(uint _electionId) onlyAdmin public{
        require(_electionId < electionCount, "Invalid Election Id");
        require(elections[_electionId].isActive, "election is deactivated!");
        require(!elections[_electionId].registrationPhase, "registration is active!");
        require(!elections[_electionId].votingPhase, "Voting phase is already activeted!");
        require(elections[_electionId].totalCandidates>1,"Must have more than one candidate!");
        require(elections[_electionId].totalVoters>1,"Must have more than one voter!");
        elections[_electionId].votingPhase = true;
        emit activeVotingEvent(_electionId, "Now voting phase is activated");
    }
    function deactiveVoting(uint _electionId) onlyAdmin public {
        require(_electionId < electionCount, "Invalid Election Id");
        require(elections[_electionId].isActive, "election is deactivated!");
        require(!elections[_electionId].registrationPhase, "registration is already activated!");
        require(elections[_electionId].votingPhase, "Voting already deactivated@");
        elections[_electionId].votingPhase = false;
        emit deactiveVotingEvent(_electionId, "Now voting phase is Deactivated");
    }
    function completeElection(uint _electionId) onlyAdmin public {
        require(_electionId <= electionCount, "Invalid Election Id");
        require(!elections[_electionId].isActive, "election is already active!");        
        require(!elections[_electionId].isCompleted, "election is already completed!");
        elections[_electionId].isCompleted = true;
        emit completeElectionEvent(_electionId,"election is completed");
    }
    function getWinner(uint _electionId) onlyAdmin public returns(uint, uint){
        require(_electionId < electionCount, "Invalid Election Id");
        require(elections[_electionId].isCompleted,"election is not completed yet");
        require(!elections[_electionId].isActive, "election is already active!");
        uint candidateCount = elections[_electionId].totalCandidates;
        uint maxVote;
        uint winnerId;
        for(uint i = 0 ; i < candidateCount; i++){
            if(candidates[_electionId][i].electionId == _electionId){
                if(maxVote < candidates[_electionId][i].voteCount){
                    maxVote = candidates[_electionId][i].voteCount;
                    winnerId = i;
                }
            }
        }
        elections[_electionId].winnerId = winnerId;
        emit getWinnerEvent(_electionId,"The election is completed", winnerId);
        return (maxVote, winnerId);
    }
}