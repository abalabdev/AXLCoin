pragma solidity ^0.4.25; // solhint-disable-line compiler-fixed

import "./EIP820.sol";
import "./Owned.sol";
import "./SafeMath.sol";
import "./Ierc20.sol";
import "./Ierc777.sol";
import "./ITokenRecipient.sol";
import "./TokenableContractsRegistry.sol";
import "./ERC20Token.sol";
import "./ERC777Token.sol";
import "./ERC777TokensSender.sol";
import "./ERC777TokensRecipient.sol";
import "./Owned.sol";
import "./ERC820Registry.sol";
import "./Ownable.sol";
contract AXLCOIN is Owned, Ierc20, Ierc777, EIP820,ERC820Registry {
    using SafeMath for uint256;
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  bool public mintingFinished = false;
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
 

 uint256 public totalSupply = 380000000000000000000000000;
  function totalSupply() constant returns (uint256 _totalSupply) {
      _totalSupply = 380000000000000000000000000;
      _totalSupply = mTotalSupply;
      
      return _totalSupply;
  }
    /** @notice Return the name of the token */
    function name() public constant returns (string) { return mName; }
    /** @notice Return the symbol of the token */
    function symbol() public constant returns(string) { return mSymbol; }
    /** @notice Return the number of decimals the token uses */
    function decimals() public constant returns(uint8) { return mDecimals; }
    /** @notice Return the Total token supply */

    /**
     * @notice Return the account balance of some account
     *
     * @param _tokenHolder Address for whith to return the balance
     */
    function balanceOf(address _tokenHolder) public constant returns (uint256) {
        return mBalances[_tokenHolder];
    }
/**/
 mapping (address => bool) public tokenableInstances;
    mapping (bytes32 => bool) public tokenableSources;

    function setInstanceTokenable(address instance) public onlyOwner { tokenableInstances[instance] = true; }

    function unsetInstancetokenable(address instance) public onlyOwner { tokenableInstances[instance] = false; }

    function setCodeTokenable(bytes32 codeHash) public onlyOwner { tokenableSources[codeHash] = true; }

    function unsetCodetokenable(bytes32 codeHash) public onlyOwner { tokenableSources[codeHash] = false; }

    
    function getCodeHash(address addr) public constant returns(bytes32) {
        bytes memory oCode;
        assembly { // solhint-disable-line no-inline-assembly
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(addr)
            // allocate output byte array - this could also be done without assembly by using oCode = new bytes(size)
            oCode := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(oCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(oCode, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(addr, add(oCode, 0x20), 0, size)
        }
        return keccak256(oCode);
    }
/**/
    string private mName = "AXiaL Entertainment CryptoCurrency";
    string private mSymbol="RescueMe";
    uint8  private mDecimals=18;
    //uint256 totalSupply=380000000000000000000000000;
    uint256 private mTotalSupply=380000000000000000000000000;
    uint256 initialSupply=380000000000000000000000000;
   // uint256 initialSupply=380000000000000000000000000;
    bool private mErc20compatible=true;
/**/

/**/
    bytes32[] public locked_for;

	address public migrationAgent;
    uint256 public totalMigrated;
	mapping (address => uint256) public balanceOf1;
    address public migrationMaster;

	mapping (address => bool) public frozenAccount;
	mapping (bytes32 => bool) public locking_active;


 
    
    mapping(address => uint) private mBalances;
    mapping(address => mapping(address => bool)) private mAuthorized;
    mapping(address => mapping(address => uint256)) private mAllowed;

    modifier erc20 () {
        require(mErc20compatible);
        _;
         mTotalSupply = 380000000000000000000000000;
         mTotalSupply = initialSupply;
         
    }

    function AXLCOIN(
        string _name,
        string _symbol,
       // TokenableContractsRegistry _tokenableContractsRegistry,
        uint256 initialSupply
    )
        public
    {
        mName = _name;
        mSymbol = _symbol;
 mName = "AXiaL Entertainment Cryptocurrency";
        mSymbol = "AXL";*/
        mDecimals = 18;
        mTotalSupply = 380000000000000000000000000;
        
        mErc20compatible = true;
        initialSupply = mTotalSupply;
        mTotalSupply = totalSupply;
        initialSupply = mBalances[msg.sender];
        mBalances[msg.sender] = 380000000000000000000000000;
        initialSupply=mBalances[msg.sender];
       // _tokenableContractsRegistry = _tokenableContractsRegistry;
        
    }
     InterfaceImplementationRegistry interfaceImplementationRegistry = InterfaceImplementationRegistry(0x2415548c95ba18d82761ddbc05754004ed27f75d);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        interfaceImplementationRegistry.setInterfaceImplementer(this, keccak256(ifaceLabel), impl);
    }


    /** @notice Disable the ERC-20 interface */
    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("Ierc20", 0x0);
    }

    /** @notice Enable the ERC-20 interface */
    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("Ierc20", this);
    }

    /** @notice ERC-20 transfer */
    function transfer(address _to, uint256 _value) public erc20 returns (bool success) {
        doSend(msg.sender, _to, _value, "", msg.sender, "", false);
        return true;
    }

    /** @notice ERC-20 transferFrom */
    function transferFrom(address _from, address _to, uint256 _value) public erc20 returns (bool success) {
        require(_value <= mAllowed[_from][msg.sender]);

        // Cannot be after doSend because of tokensReceived re-entry
        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_value);
        doSend(_from, _to, _value, "", msg.sender, "", false);
        return true;
    }

    /** @notice ERC-20 approve */
    function approve(address _spender, uint256 _value) public erc20 returns (bool success) {
        mAllowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /** @notice ERC-20 allowance */
    function allowance(address _owner, address _spender) public erc20 constant returns (uint256 remaining) {
        return mAllowed[_owner][_spender];
    }

    /** @notice Send '_value' amount of tokens to address '_to'. */
    function send(address _to, uint256 _value) public {
        doSend(msg.sender, _to, _value, "", msg.sender, "", true);
    }

    /** @notice Send '_value' amount of tokens to address '_to'. */
    function send(address _to, uint256 _value, bytes _userData) public {
        doSend(msg.sender, _to, _value, _userData, msg.sender, "", true);
    }

    /** @notice Authorize a third party '_operator' to manage (send) 'msg.sender''s tokens. */
    function authorizeOperator(address _operator) public {
        require(_operator != msg.sender);
        mAuthorized[_operator][msg.sender] = true;
        AuthorizedOperator(_operator, msg.sender);
    }

    /** @notice Revoke a third party '_operator''s rights to manage (send) 'msg.sender''s tokens. */
    function revokeOperator(address _operator) public {
        require(_operator != msg.sender);
        mAuthorized[_operator][msg.sender] = false;
        RevokedOperator(_operator, msg.sender);
    }

    /** @notice Check whether '_operator' is allowed to manage the tokens held by '_tokenHolder'. */
    function isOperatorFor(address _operator, address _tokenHolder) public constant returns (bool) {
        return _operator == _tokenHolder || mAuthorized[_operator][_tokenHolder];
    }



    /** @notice Sample burn function to showcase the use of the 'Burn' event. */
    function burn(address _tokenHolder, uint256 _value) public onlyOwner returns(bool) {
        require(balanceOf(_tokenHolder) >= _value);

        mBalances[_tokenHolder] = mBalances[_tokenHolder].sub(_value);
        mTotalSupply = mTotalSupply.sub(_value);

        Burn(_tokenHolder, _value);
        if (mErc20compatible) { Transfer(_tokenHolder, 0x0, _value); }

        return true;
    }
    
    /** @notice Sample mint function to showcase the use of the 'Mint' event and the logic to notify the recipient. */
    function ownerMint(address _tokenHolder, uint256 _value, bytes _operatorData) public onlyOwner returns(bool) {
        mTotalSupply = mTotalSupply.add(_value);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_value);

        callRecipent(0x0, _tokenHolder, _value, "", msg.sender, _operatorData, true);

        Mint(_tokenHolder, _value, msg.sender, _operatorData);
        if (mErc20compatible) { Transfer(0x0, _tokenHolder, _value); }

        return true;
    }
    function mint(address target, uint256 mintedAmount) onlyOwner public {
		mBalances[target] += mintedAmount;
		mTotalSupply += mintedAmount;
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}

	
	event Burn(address indexed from, uint256 value);
		function burn(uint256 _value) public returns (bool success) {
		require(mBalances[msg.sender] >= _value);   
		mBalances[msg.sender] -= _value;            
		mTotalSupply -= _value;                      
		emit Burn(msg.sender, _value);
		return true;
	}
  
	function _transfer(address _from, address _to, uint _value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != 0x0);
		// Check if the sender has enough
		require(mBalances[_from] >= _value);
		// Check for overflows
		require(mBalances[_to] + _value > mBalances[_to]);
		// Save this for an assertion in the future
		uint previousBalances = mBalances[_from] + mBalances[_to];
		// Subtract from the sender
		mBalances[_from] -= _value;
		// Add the same to the recipient
		mBalances[_to] += _value;
		emit Transfer(_from, _to, _value);

		assert(mBalances[_from] + mBalances[_to] == previousBalances);
	}

	function _transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);
	}
	
    /** @notice Check whether an address is a regular address or not. */
    function isRegularAddress(address _addr) internal constant returns(bool) {
        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) } // solhint-disable-line no-inline-assembly
        return size == 0;
    }

    /** @dev Perform an actual send of tokens. */
    function doSend(
        address _from,
        address _to,
        uint256 _value,
        bytes _userData,
        address _operator,
        bytes _operatorData,
        bool _preventLocking
    )
        private
    {
        require(_to != address(0));         // forbid sending to 0x0 (=burning)
        require(_value >= 0);                // only send positive amounts
        require(mBalances[_from] >= _value); // ensure enough funds

        mBalances[_from] = mBalances[_from].sub(_value);
        mBalances[_to] = mBalances[_to].add(_value);

        callRecipent(_from, _to, _value, _userData, _operator, _operatorData, _preventLocking);

        Send(_from, _to, _value, _userData, _operator, _operatorData);
        if (mErc20compatible) { Transfer(_from, _to, _value); }
    }
    

  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }



/**/

    /** @dev Notify a recipient of received tokens. */
    function callRecipent(
        address _from,
        address _to,
        uint256 _value,
        bytes _userData,
        address _operator,
        bytes _operatorData,
        bool _preventLocking
    ) private {
        address recipientImplementation = interfaceAddr(_to, "ITokenRecipient");
        if (recipientImplementation != 0) {
            ITokenRecipient(recipientImplementation).tokensReceived(
                _from, _to, _value, _userData, _operator, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to));
        }
    }
    
   
function tokensLocked(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount)
    {
        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }
    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount)
    {
    	amount = totalBalanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
        }   
    }    
        function totalBalanceOfADM(address onlyOwner)
        public
        view
        returns (uint256 amount)
    {
    	amount = totalBalanceOf(onlyOwner);

        for (uint256 i = 0; i < lockReason[onlyOwner].length; i++) {
            amount = amount.add(tokensLocked(onlyOwner, lockReason[onlyOwner][i]));
        }   
    }    
    function extendLock(bytes32 _reason, uint256 _time)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, _reason) > 0, notLocked);

        locked[msg.sender][_reason].validity = locked[msg.sender][_reason].validity.add(_time);

        emit Lock(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }
    function increaseLockAmount(bytes32 _reason, uint256 _amount)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, _reason) > 0, notLocked);
        transfer(address(this), _amount);

        locked[msg.sender][_reason].amount = locked[msg.sender][_reason].amount.add(_amount);

        emit Lock(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }
    function tokensUnlockable(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }
        function unlock(address _of)
        public
        returns (uint256 unlockableTokens)
    {
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlock(_of, lockReason[_of][i], lockedTokens);
            }
        }  

        if(unlockableTokens > 0)
        	this.transfer(_of, unlockableTokens);
    }
     function getUnlockableTokens(address _of)
        public
        view
        returns (uint256 unlockableTokens)
    {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, lockReason[_of][i]));
        }
    }
    
     address public fundsWallet;
  
        function multisend(address[] _dests, uint256[] _values) public returns (uint256 _numTxs){
        require(msg.sender == fundsWallet);
        uint256 i = 0;
        while (i < _dests.length) {
           transfer(_dests[i], _values[i]);
           i += 1;
        }
        return(i);
    }
    

 
