pragma solidity ^0.4.24;

// import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
// pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Owned {
	address public owner;

	function Owned() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		owner = newOwner;
	}
}

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
	// Public variables of the token
	string public name;
	string public symbol;
	// uint8 public decimals = 18;
	uint8 public decimals = 4;
	// 18 decimals is the strongly suggested default, avoid changing it
	uint256 public totalSupply;

	// This creates an array with all balances
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);

	// This notifies clients about the amount burnt
	event Burn(address indexed from, uint256 value);

	/**
	 * Constrctor function
	 *
	 * Initializes contract with initial supply tokens to the creator of the contract
	 */
	function TokenERC20(uint256 initialSupply) public {
	    
		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
		balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
		name = "AXLCoin";                                   // Set the name for display purposes
		symbol = "axl";                               // Set the symbol for display purposes
	}


	/**
	 * Transfer tokens from other address
	 *
	 * Send `_value` tokens to `_to` in behalf of `_from`
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(_value <= allowance[_from][msg.sender]);     // Check allowance
		allowance[_from][msg.sender] -= _value;
		//_transfer(_from, _to, _value);
		return true;
	}

	/**
	 * Set allowance for other address
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 */
	function approve(address _spender, uint256 _value) public
		returns (bool success) {
			allowance[msg.sender][_spender] = _value;
			return true;
		}

	/**
	 * Set allowance for other address and notify
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 * @param _extraData some extra information to send to the approved contract
	 */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData)
		public
		returns (bool success) {
			tokenRecipient spender = tokenRecipient(_spender);
			if (approve(_spender, _value)) {
				spender.receiveApproval(msg.sender, _value, this, _extraData);
				return true;
			}
		}

	/**
	 * Destroy tokens
	 *
	 * Remove `_value` tokens from the system irreversibly
	 *
	 * @param _value the amount of money to burn
	 */
	function burn(uint256 _value) public returns (bool success) {
		require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
		balanceOf[msg.sender] -= _value;            // Subtract from the sender
		totalSupply -= _value;                      // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	/**
	 * Destroy tokens from other account
	 *
	 * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
	 *
	 * @param _from the address of the sender
	 * @param _value the amount of money to burn
	 */
	function burnFrom(address _from, uint256 _value) public returns (bool success) {
		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
		require(_value <= allowance[_from][msg.sender]);    // Check allowance
		balanceOf[_from] -= _value;                         // Subtract from the targeted balance
		allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
		totalSupply -= _value;                              // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}
}

/******************************************/
/*        AXLTOKEN STARTS HERE       */
/******************************************/

contract AXLCoin is Owned, TokenERC20 {
	using SafeMath for uint256;

	uint256 public sellPrice;
	uint256 public buyPrice;
    address public migrationAgent;
    uint256 public totalMigrated;
    address public migrationMaster;
    
    address public crowdAddress;

    mapping(address => bytes32[]) public lockReason;
	mapping(address => mapping(bytes32 => lockToken)) public locked;
    
	struct lockToken {
        uint256 amount;
        uint256 validity;
    }
    
    // event Lock(
    //     address indexed _of,
    //     bytes32 indexed _reason,
    //     uint256 _amount,
    //     uint256 _validity
    // );

	/* This generates a public event on the blockchain that will notify clients */
	event Migrate(address indexed _from, address indexed _to, uint256 _value);
    
    modifier onlyCrowd() { require(crowdAddress == msg.sender); _;}
    
	/* Initializes contract with initial supply tokens to the creator of the contract */
	// function MyAdvancedToken(
	function AXLCoin( uint256 _initialSupply) TokenERC20(_initialSupply) public {
// 		initialSupply = _initialSupply;
// 		tokenName = _tokenName;
// 		tokenSymbol = _tokenSymbol;
	}

	/// @notice Create `mintedAmount` tokens and send it to `target`
	/// @param target Address to receive the tokens
	/// @param mintedAmount the amount of tokens it will receive
	function mintToken(address target, uint256 mintedAmount) onlyOwner public {
		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}

	/// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
	/// @param newSellPrice Price the users can sell to the contract
	/// @param newBuyPrice Price users can buy from the contract
	function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
		sellPrice = newSellPrice;
		buyPrice = newBuyPrice;
	}
    
    /**
	 * Internal transfer, only can be called by this contract
	 */
	function _transfer(address _from, address _to, uint _value) internal {
	    
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != 0x0);
		// Check if the sender has enough
		require(transferableBalanceOf(_from) >= _value);
		// Check for overflows
		require(balanceOf[_to] + _value > balanceOf[_to]);
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		// Subtract from the sender
		balanceOf[_from] -= _value;
		// Add the same to the recipient
		balanceOf[_to] += _value;
		emit Transfer(_from, _to, _value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	/**
	 * Transfer tokens
	 *
	 * Send `_value` tokens to `_to` from your account
	 *
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);
	}
    
	/**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     */
    
    function lock(address _of, bytes32 _reason, uint256 _amount, uint256 _time)
        onlyCrowd
        public
        returns (bool)
    {
        uint256 validUntil = block.timestamp.add(_time);
        // If tokens are already locked, the functions extendLock or
        // increaseLockAmount should be used to make any changes
        //require(tokensLocked(_of, _reason, block.timestamp) == 0);
        require(_amount <= transferableBalanceOf(_of));
        
        if (locked[_of][_reason].amount == 0)
            lockReason[_of].push(_reason);
        
        if(tokensLocked(_of, _reason, block.timestamp) == 0){
            locked[_of][_reason] = lockToken(_amount, validUntil);    
        }else{
            locked[_of][_reason].amount += _amount;   
        }
        
        //emit Lock(_of, _reason, _amount, validUntil);
        return true;
    }
    
    /**
     * @dev Extends lock for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _time Lock extension time in seconds
     */
    function extendLock(bytes32 _reason, uint256 _time)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, _reason, block.timestamp) > 0);
        locked[msg.sender][_reason].validity += _time;
        // emit Lock(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }
    
    
    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specified time
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     * @param _time The timestamp to query the lock tokens for
     */
    function tokensLocked(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount)
    {
        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

	function transferableBalanceOf(address _of)
		public
		view
		returns (uint256 amount)
		{
			uint256 lockedAmount = 0;
			for (uint256 i=0; i < lockReason[_of].length; i++) {
				lockedAmount += tokensLocked(_of,lockReason[_of][i], block.timestamp);
			}
			// amount = balances[_of].sub(lockedAmount);
			amount = balanceOf[_of].sub(lockedAmount);
			return amount;
		}
    
    
// 	function migrate(uint256 _value) external {
		// Abort if not in Operational Migration state.
// 		if (migrationAgent == 0) throw;

		// Validate input value.
// 		if (_value == 0) throw;
// 		if (_value > balanceOf[msg.sender]) throw;

// 		balanceOf[msg.sender] -= _value;
// 		totalSupply -= _value;
// 		totalMigrated += _value;
// 		MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
// 		Migrate(msg.sender, migrationAgent, _value);
// 	}

	/// @notice Set address of migration target contract and enable migration
	/// process.
	/// @dev Required state: Operational Normal
	/// @dev State transition: -> Operational Migration
	/// @param _agent The address of the MigrationAgent contract
	function setMigrationAgent(address _agent) external {
		// Abort if not in Operational Normal state.
		if (migrationAgent != 0) throw;
		if (msg.sender != migrationMaster) throw;
		migrationAgent = _agent;
	}

	function setMigrationMaster(address _master) external {
		if (msg.sender != migrationMaster) throw;
		if (_master == 0) throw;
		migrationMaster = _master;
	}
	
	//add onlyOwner
	function setCrowdAddress(address _crowdAddress) onlyOwner{
	    crowdAddress = _crowdAddress;
	}
	
}

// /**
//  * Crowdsale START
// **/
// contract Crowdsale is Owned {
//     using SafeMath for uint256;
    
//     uint256 public fundingGoal;
//     uint256 public deadline;
//     uint256 public price;
//     uint256 public transferableToken;
//     uint8 public decimals = 4;
//     uint256 public soldToken;
//     uint256 public startTime;
//     AXLCoin public tokenReward;
//     bool public fundingGoalReached;
//     bool public isOpened;
//     address[] public participant; 
    
//     mapping (address => Property) public fundersProperty;
    
//     struct Property{
//         uint256 paymentEther;
//         uint256 reservedToken;
//         uint256 willLockedToken;
//         bytes32 reason;
//         bool withdrawed;
//     }
    
//     modifier afterDeadline() {
//         require(now >= deadline); _;
//     }
    
//     constructor (
//          uint _fundingGoalInEthers
//         ,uint _transferabletoken
//         ,AXLCoin _addressOfToken
//     ) {
//         require(_fundingGoalInEthers != 0 && _transferabletoken !=0 && _addressOfToken != address(0));
        
//         fundingGoal = _fundingGoalInEthers * 1 ether;
//         transferableToken = _transferabletoken * 10 ** uint256(decimals);
//         tokenReward = AXLCoin(_addressOfToken);
//     }
        
//     function() payable public {
//         require(isOpened && now < deadline);
        
//         require(msg.value >= 0.1 ether);
    
//         uint256 amount = msg.value;
//         uint256 token;
    
//         uint256 originPrice = 1 ether / uint256(620 * 10 ** uint256(decimals));
//         uint256 bonusPrice = 1 ether / uint256(1054 * 10 ** uint256(decimals));
        
//         uint256 originToken = amount / originPrice;
//         uint256 bonusToken = amount / bonusPrice;
//         uint256 totalToken = originToken + bonusToken;
        
//         require(totalToken != 0 && (soldToken + totalToken) <= transferableToken);
        
//         fundersProperty[msg.sender].paymentEther += amount;
//         fundersProperty[msg.sender].reservedToken += totalToken;
//         fundersProperty[msg.sender].withdrawed = false;
//         fundersProperty[msg.sender].willLockedToken += bonusToken;
//         fundersProperty[msg.sender].reason = stringToBytes32("Locked1");
//         soldToken += totalToken;
        
//         participant.push(msg.sender);    
//         //event
//     }
    
//     function start(uint256 _durationInDays) onlyOwner {
//         require(
//             fundingGoal != 0 &&
//             transferableToken != 0 &&
//             tokenReward != address(0) &&
//             _durationInDays != 0 &&
//             startTime == 0
//         );
        
//         //if(tokenReward.balanceOf(this) >= transferableToken){
//             startTime = block.timestamp;
//             deadline = block.timestamp + _durationInDays * 1 days;
//             isOpened = true;
//             //event
//         //}
//     }
    
//     function getRemainingTimeEthToken() onlyOwner view returns(uint day, uint shortage, uint remainToken){
//         if(now < deadline){
//             day = (deadline - now) / (1 days);
//         }
        
//         shortage = (fundingGoal - this.balance) / (1 ether);
//         remainToken = transferableToken - soldToken;
//     }
    
    
//     function checkGoalReached() {
//         if(isOpened){
//             if(this.balance >= fundingGoal){
//                 fundingGoalReached = true;
//             }
//         }
        
//         isOpened = false;
//         //event
//     }
    
//     function stringToBytes32(string memory source) returns (bytes32 result) {
//         bytes memory tempEmptyStringTest = bytes(source);
//         if (tempEmptyStringTest.length == 0) {
//             return 0x0;
//         }
    
//         assembly {
//             result := mload(add(source, 32))
//         }
//     }
    
//     function withdrawalOwner() onlyOwner {
        
//         uint amount = this.balance;
        
//         if(amount > 0){
//             msg.sender.call.value(amount)();
//         }
//     }
    
//     function returnToken() onlyOwner {
//         uint256 remainToken = transferableToken - soldToken;
//         if(remainToken > 0){
//             tokenReward.transfer(msg.sender, remainToken);
//         }
//     }
    
//     function withdrawal() onlyOwner{
        
//         uint256 lockTime = deadline + 90 days;
        
//         for(uint256 i=0; i<participant.length; i++){
            
//             uint paymentEther = fundersProperty[participant[i]].paymentEther;
//             uint reservedToken = fundersProperty[participant[i]].reservedToken;
//             uint willLockedToken = fundersProperty[participant[i]].willLockedToken;
//             bytes32 reason = fundersProperty[participant[i]].reason;
                
//             if(!fundersProperty[participant[i]].withdrawed && reservedToken > 0){
//                 tokenReward.transfer(participant[i], reservedToken);
//                 fundersProperty[participant[i]].withdrawed = true;
//                 tokenReward.lock(participant[i],reason, willLockedToken, lockTime);
                
//                 fundersProperty[participant[i]].reservedToken = uint256(0);
//                 fundersProperty[participant[i]].willLockedToken = uint256(0);
//                 fundersProperty[participant[i]].reason = bytes32(0);
//             }
//         }
//     }
// }
