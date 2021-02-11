pragma solidity 0.7.5;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/AccessControl.sol";
import "openzeppelin-solidity/contracts/utils/Pausable.sol";
import "./IChildToken.sol";
import "./NativeMetaTransaction.sol";


contract ChilliToken is
    ERC20,
    IChildToken,
    AccessControl,
    NativeMetaTransaction,
    Pausable
{
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");
    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    modifier only(bytes32 role) {
        require(
            hasRole(role, _msgSender()),
            "Sender does not have required privileges!!"
        );
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address childChainManager,
        uint256 amount
    ) public ERC20(name_, symbol_) NativeMetaTransaction(name_) {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEPOSITOR_ROLE, childChainManager);
        _mint(_msgSender(), amount);
    }

    /**
     * @dev Triggers an approval from owner to spender
     * @param owner The address to approve from
     * @param spender The address to be approved
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {

        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeperator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "ChiliToken::permit: invalid signature"
        );
        require(
            signatory == owner,
            "ChilliTOken::permit: unauthorized"
        );
        require(
            block.timestamp <= deadline,
            "ChilliTOken::permit: signature expired"
        );

        _approve(owner, spender, amount);
    }

    /**
     * @notice called when token is deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required amount for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded amount
     */
    function deposit(address user, bytes calldata depositData)
        external
        override
        only(DEPOSITOR_ROLE)
    {
        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    /**
     * @notice called when user wants to withdraw tokens back to root chain. Only DAO can call this method
     * User will have to submit the request to the DAO and then DAO will have to approve it
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @dev user Account from which tokens will be burned
     * @param amount amount of tokens to withdraw
     */
    function withdraw(
        address user,
        uint256 amount
    )
        external
        only(DEFAULT_ADMIN_ROLE)
    {
        _burn(user, amount);
    }

    function pause() external only(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external only(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function mint(
        address user,
        uint256 amount
    )
        external
        only(DEFAULT_ADMIN_ROLE)
    {
        _mint(user, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override
    {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ChiliToken: token transfer while paused");
    }

    function _msgSender()
     internal view override returns (address payable sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}