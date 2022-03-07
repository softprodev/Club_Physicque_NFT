
pragma solidity ^0.5.0;

contract BuilderShop {
   address[] builderInstances;
   uint contractId = 0;

   //clubphysique registry is hard coded
   address clubphysiqueRegistryContract = '';

   modifier onlyValidSender() {
       ClubphysiqueRegistry nftg_registry = ClubphysiqueRegistry(clubphysiqueRegistryContract);
       bool is_valid = nftg_registry.isValidClubphysiqueSender(msg.sender);
       require(is_valid==true);
       _;
   }

   mapping (address => bool) public BuilderShops;

   function isValidBuilderShop(address builder_shop) public view returns (bool isValid) {
       //public function, allowing anyone to check if a contract address is a valid clubphysique gateway contract
       return(BuilderShops[builder_shop]);
   }

   event BuilderInstanceCreated(address new_contract_address, uint contractId);

   function createNewBuilderInstance(
       string memory _name,
       string memory _symbol,
       uint num_clubphysiques,
       string memory token_base_uri,
       string memory creator_name)
       public returns (ClubphysiqueBuilderInstance tokenAddress) { // <- must replace this !!!
   //public onlyValidSender returns (ClubphysiqueBuilderInstance tokenAddress) {

       contractId = contractId + 1;

       ClubphysiqueBuilderInstance new_contract = new ClubphysiqueBuilderInstance(
           _name,
           _symbol,
           contractId,
           num_clubphysiques,
           token_base_uri,
           creator_name
       );

       address externalId = address(new_contract);

       BuilderShops[externalId] = true;

       emit BuilderInstanceCreated(externalId, contractId);

       return (new_contract);
    }
}


/*
* @dev Provides information about the current execution context, including the
* sender of the transaction and its data. While these are generally available
* via msg.sender and msg.data, they should not be accessed in such a direct
* manner, since when dealing with GSN meta-transactions the account sending and
* paying for execution may not be the actual sender (as far as an application
* is concerned).
*
* This contract is only required for intermediate, library-like contracts.
*/
contract Context {
   // Empty internal constructor, to prevent people from mistakenly deploying
   // an instance of this contract, which should be used via inheritance.
   constructor () internal { }
   // solhint-disable-previous-line no-empty-blocks

   function _msgSender() internal view returns (address payable) {
       return msg.sender;
   }

   function _msgData() internal view returns (bytes memory) {
       this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
       return msg.data;
   }
}

/**
* @dev Interface of the ERC165 standard, as defined in the
* https://eips.ethereum.org/EIPS/eip-165[EIP].
*
* Implementers can declare support of contract interfaces, which can then be
* queried by others ({ERC165Checker}).
*
* For an implementation, see {ERC165}.
*/
interface IERC165 {
   /**
    * @dev Returns true if this contract implements the interface defined by
    * `interfaceId`. See the corresponding
    * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
    * to learn more about how these ids are created.
    *
    * This function call must use less than 30 000 gas.
    */
   function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
* @dev Implementation of the {IERC165} interface.
*
* Contracts may inherit from this and call {_registerInterface} to declare
* their support of an interface.
*/
contract ERC165 is IERC165 {
   /*
    * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
    */
   bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

   /**
    * @dev Mapping of interface ids to whether or not it's supported.
    */
   mapping(bytes4 => bool) private _supportedInterfaces;

   constructor () internal {
       // Derived contracts need only register support for their own interfaces,
       // we register support for ERC165 itself here
       _registerInterface(_INTERFACE_ID_ERC165);
   }

   /**
    * @dev See {IERC165-supportsInterface}.
    *
    * Time complexity O(1), guaranteed to always use less than 30 000 gas.
    */
   function supportsInterface(bytes4 interfaceId) external view returns (bool) {
       return _supportedInterfaces[interfaceId];
   }

   /**
    * @dev Registers the contract as an implementer of the interface defined by
    * `interfaceId`. Support of the actual ERC165 interface is automatic and
    * registering its interface id is not required.
    *
    * See {IERC165-supportsInterface}.
    *
    * Requirements:
    *
    * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
    */
   function _registerInterface(bytes4 interfaceId) internal {
       require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
       _supportedInterfaces[interfaceId] = true;
   }
}


/**
* @dev Required interface of an ERC721 compliant contract.
*/
contract IERC721 is IERC165 {
   event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
   event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
   event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

   /**
    * @dev Returns the number of NFTs in `owner`'s account.
    */
   function balanceOf(address owner) public view returns (uint256 balance);

   /**
    * @dev Returns the owner of the NFT specified by `tokenId`.
    */
   function ownerOf(uint256 tokenId) public view returns (address owner);

   /**
    * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
    * another (`to`).
    *
    *
    *
    * Requirements:
    * - `from`, `to` cannot be zero.
    * - `tokenId` must be owned by `from`.
    * - If the caller is not `from`, it must be have been allowed to move this
    * NFT by either {approve} or {setApprovalForAll}.
    */
   function safeTransferFrom(address from, address to, uint256 tokenId) public;
   /**
    * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
    * another (`to`).
    *
    * Requirements:
    * - If the caller is not `from`, it must be approved to move this NFT by
    * either {approve} or {setApprovalForAll}.
    */
   function transferFrom(address from, address to, uint256 tokenId) public;
   function approve(address to, uint256 tokenId) public;
   function getApproved(uint256 tokenId) public view returns (address operator);

   function setApprovalForAll(address operator, bool _approved) public;
   function isApprovedForAll(address owner, address operator) public view returns (bool);


   function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}



/**
* @title ERC721 token receiver interface
* @dev Interface for any contract that wants to support safeTransfers
* from ERC721 asset contracts.
*/
contract IERC721Receiver {
   /**
    * @notice Handle the receipt of an NFT
    * @dev The ERC721 smart contract calls this function on the recipient
    * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
    * otherwise the caller will revert the transaction. The selector to be
    * returned can be obtained as `this.onERC721Received.selector`. This
    * function MAY throw to revert and reject the transfer.
    * Note: the ERC721 contract address is always the message sender.
    * @param operator The address which called `safeTransferFrom` function
    * @param from The address which previously owned the token
    * @param tokenId The NFT identifier which is being transferred
    * @param data Additional data with no specified format
    * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    */
   function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
   public returns (bytes4);
}

/**
* @title ERC721 Non-Fungible Token Standard basic implementation
* @dev see https://eips.ethereum.org/EIPS/eip-721
*/
contract ERC721 is Context, ERC165, IERC721 {
   using SafeMath for uint256;
   using Address for address;
   using Counters for Counters.Counter;

   // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
   bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

   // Mapping from token ID to owner
   mapping (uint256 => address) private _tokenOwner;

   // Mapping from token ID to approved address
   mapping (uint256 => address) private _tokenApprovals;

   // Mapping from owner to number of owned token
   mapping (address => Counters.Counter) private _ownedTokensCount;

   // Mapping from owner to operator approvals
   mapping (address => mapping (address => bool)) private _operatorApprovals;

   bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

   constructor () public {
       // register the supported interfaces to conform to ERC721 via ERC165
       _registerInterface(_INTERFACE_ID_ERC721);
   }

   /**
    * @dev Gets the balance of the specified address.
    * @param owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
   function balanceOf(address owner) public view returns (uint256) {
       require(owner != address(0), "ERC721: balance query for the zero address");

       return _ownedTokensCount[owner].current();
   }

   /**
    * @dev Gets the owner of the specified token ID.
    * @param tokenId uint256 ID of the token to query the owner of
    * @return address currently marked as the owner of the given token ID
    */
   function ownerOf(uint256 tokenId) public view returns (address) {
       address owner = _tokenOwner[tokenId];
       require(owner != address(0), "ERC721: owner query for nonexistent token");

       return owner;
   }

   /**
    * @dev Approves another address to transfer the given token ID
    * The zero address indicates there is no approved address.
    * There can only be one approved address per token at a given time.
    * Can only be called by the token owner or an approved operator.
    * @param to address to be approved for the given token ID
    * @param tokenId uint256 ID of the token to be approved
    */
   function approve(address to, uint256 tokenId) public {
       address owner = ownerOf(tokenId);
       require(to != owner, "ERC721: approval to current owner");

       require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
           "ERC721: approve caller is not owner nor approved for all"
       );

       _tokenApprovals[tokenId] = to;
       emit Approval(owner, to, tokenId);
   }

   /**
    * @dev Gets the approved address for a token ID, or zero if no address set
    * Reverts if the token ID does not exist.
    * @param tokenId uint256 ID of the token to query the approval of
    * @return address currently approved for the given token ID
    */
   function getApproved(uint256 tokenId) public view returns (address) {
       require(_exists(tokenId), "ERC721: approved query for nonexistent token");

       return _tokenApprovals[tokenId];
   }

   /**
    * @dev Sets or unsets the approval of a given operator
    * An operator is allowed to transfer all tokens of the sender on their behalf.
    * @param to operator address to set the approval
    * @param approved representing the status of the approval to be set
    */
   function setApprovalForAll(address to, bool approved) public {
       require(to != _msgSender(), "ERC721: approve to caller");

       _operatorApprovals[_msgSender()][to] = approved;
       emit ApprovalForAll(_msgSender(), to, approved);
   }

   /**
    * @dev Tells whether an operator is approved by a given owner.
    * @param owner owner address which you want to query the approval of
    * @param operator operator address which you want to query the approval of
    * @return bool whether the given operator is approved by the given owner
    */
   function isApprovedForAll(address owner, address operator) public view returns (bool) {
       return _operatorApprovals[owner][operator];
   }

   /**
    * @dev Transfers the ownership of a given token ID to another address.
    * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
    * Requires the msg.sender to be the owner, approved, or operator.
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
   function transferFrom(address from, address to, uint256 tokenId) public {
       //solhint-disable-next-line max-line-length
       require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

       _transferFrom(from, to, tokenId);
   }

   /**
    * @dev Safely transfers the ownership of a given token ID to another address
    * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    * Requires the msg.sender to be the owner, approved, or operator
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
   function safeTransferFrom(address from, address to, uint256 tokenId) public {
       safeTransferFrom(from, to, tokenId, "");
   }

   /**
    * @dev Safely transfers the ownership of a given token ID to another address
    * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    * Requires the _msgSender() to be the owner, approved, or operator
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    * @param _data bytes data to send along with a safe transfer check
    */
   function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
       require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
       _safeTransferFrom(from, to, tokenId, _data);
   }

/**
    * @dev Safely transfers the ownership of a given token ID to another address
    * If the target address is a contract, it must implement `onERC721Received`,
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    * Requires the msg.sender to be the owner, approved, or operator
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    * @param _data bytes data to send along with a safe transfer check
    */
   function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
       _transferFrom(from, to, tokenId);
       require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
   }

   /**
    * @dev Returns whether the specified token exists.
    * @param tokenId uint256 ID of the token to query the existence of
    * @return bool whether the token exists
    */
   function _exists(uint256 tokenId) internal view returns (bool) {
       address owner = _tokenOwner[tokenId];
       return owner != address(0);
   }

   /**
    * @dev Returns whether the given spender can transfer a given token ID.
    * @param spender address of the spender to query
    * @param tokenId uint256 ID of the token to be transferred
    * @return bool whether the msg.sender is approved for the given token ID,
    * is an operator of the owner, or is the owner of the token
    */
   function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
       require(_exists(tokenId), "ERC721: operator query for nonexistent token");
       address owner = ownerOf(tokenId);
       return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
   }

   /**
    * @dev Internal function to safely mint a new token.
    * Reverts if the given token ID already exists.
    * If the target address is a contract, it must implement `onERC721Received`,
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    * @param to The address that will own the minted token
    * @param tokenId uint256 ID of the token to be minted
    */
   function _safeMint(address to, uint256 tokenId) internal {
       _safeMint(to, tokenId, "");
   }

   /**
    * @dev Internal function to safely mint a new token.
    * Reverts if the given token ID already exists.
    * If the target address is a contract, it must implement `onERC721Received`,
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    * @param to The address that will own the minted token
    * @param tokenId uint256 ID of the token to be minted
    * @param _data bytes data to send along with a safe transfer check
    */
   function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
       _mint(to, tokenId);
       require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
   }

   /**
    * @dev Internal function to mint a new token.
    * Reverts if the given token ID already exists.
    * @param to The address that will own the minted token
    * @param tokenId uint256 ID of the token to be minted
    */
   function _mint(address to, uint256 tokenId) internal {
       require(to != address(0), "ERC721: mint to the zero address");
       require(!_exists(tokenId), "ERC721: token already minted");

       _tokenOwner[tokenId] = to;
       _ownedTokensCount[to].increment();

       emit Transfer(address(0), to, tokenId);
   }

   /**
    * @dev Internal function to burn a specific token.
    * Reverts if the token does not exist.
    * Deprecated, use {_burn} instead.
    * @param owner owner of the token to burn
    * @param tokenId uint256 ID of the token being burned
    */
   function _burn(address owner, uint256 tokenId) internal {
       require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

       _clearApproval(tokenId);

       _ownedTokensCount[owner].decrement();
       _tokenOwner[tokenId] = address(0);

       emit Transfer(owner, address(0), tokenId);
   }
   
   /**
    * @dev Internal function to burn a specific token.
    * Reverts if the token does not exist.
    * @param tokenId uint256 ID of the token being burned
    */
   function _burn(uint256 tokenId) internal {
       _burn(ownerOf(tokenId), tokenId);
   }

   /**
    * @dev Internal function to transfer ownership of a given token ID to another address.
    * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
   function _transferFrom(address from, address to, uint256 tokenId) internal {
       require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
       require(to != address(0), "ERC721: transfer to the zero address");

       _clearApproval(tokenId);

       _ownedTokensCount[from].decrement();
       _ownedTokensCount[to].increment();

       _tokenOwner[tokenId] = to;

       emit Transfer(from, to, tokenId);
   }

   /**
    * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
    * The call is not executed if the target address is not a contract.
    *
    * This function is deprecated.
    * @param from address representing the previous owner of the given token ID
    * @param to target address that will receive the tokens
    * @param tokenId uint256 ID of the token to be transferred
    * @param _data bytes optional data to send along with the call
    * @return bool whether the call correctly returned the expected magic value
    */
   function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
       internal returns (bool)
   {
       if (!to.isContract()) {
           return true;
       }

       bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
       return (retval == _ERC721_RECEIVED);
   }

   /**
    * @dev Private function to clear current approval of a given token ID.
    * @param tokenId uint256 ID of the token to be transferred
    */
   function _clearApproval(uint256 tokenId) private {
       if (_tokenApprovals[tokenId] != address(0)) {
           _tokenApprovals[tokenId] = address(0);
       }
   }
}

/**
* @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
* @dev See https://eips.ethereum.org/EIPS/eip-721
*/
contract IERC721Enumerable is IERC721 {
   function totalSupply() public view returns (uint256);
   function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

   function tokenByIndex(uint256 index) public view returns (uint256);
}



/**
* @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
* @dev See https://eips.ethereum.org/EIPS/eip-721
*/
contract IERC721Enumerable is IERC721 {
   function totalSupply() public view returns (uint256);
   function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

   function tokenByIndex(uint256 index) public view returns (uint256);
}


// for next
/**
* @title ERC-721 Non-Fungible Token with optional enumeration extension logic
* @dev See https://eips.ethereum.org/EIPS/eip-721
*/
contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {
   // Mapping from owner to list of owned token IDs
   mapping(address => uint256[]) private _ownedTokens;

   // Mapping from token ID to index of the owner tokens list
   mapping(uint256 => uint256) private _ownedTokensIndex;

   // Array with all token ids, used for enumeration
   uint256[] private _allTokens;

   // Mapping from token id to position in the allTokens array
   mapping(uint256 => uint256) private _allTokensIndex;

   /*
    *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
    *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
    *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
    *
    *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
    */
   bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63; // need to change

   /**
    * @dev Constructor function.
    */
   constructor () public {
       // register the supported interface to conform to ERC721Enumerable via ERC165
       _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
   }

   /**
    * @dev Gets the token ID at a given index of the tokens list of the requested owner.
    * @param owner address owning the tokens list to be accessed
    * @param index uint256 representing the index to be accessed of the requested tokens list
    * @return uint256 token ID at the given index of the tokens list owned by the requested address
    */
   function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
       require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
       return _ownedTokens[owner][index];
   }

   /**
    * @dev Gets the total amount of tokens stored by the contract.
    * @return uint256 representing the total amount of tokens
    */
   function totalSupply() public view returns (uint256) {
       return _allTokens.length;
   }

   /**
    * @dev Gets the token ID at a given index of all the tokens in this contract
    * Reverts if the index is greater or equal to the total number of tokens.
    * @param index uint256 representing the index to be accessed of the tokens list
    * @return uint256 token ID at the given index of the tokens list
    */
   function tokenByIndex(uint256 index) public view returns (uint256) {
       require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
       return _allTokens[index];
   }

   /**
    * @dev Internal function to transfer ownership of a given token ID to another address.
    * As opposed to transferFrom, this imposes no restrictions on msg.sender.
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    */
   function _transferFrom(address from, address to, uint256 tokenId) internal {
       super._transferFrom(from, to, tokenId);

       _removeTokenFromOwnerEnumeration(from, tokenId);

       _addTokenToOwnerEnumeration(to, tokenId);
   }

   /**
    * @dev Internal function to mint a new token.
    * Reverts if the given token ID already exists.
    * @param to address the beneficiary that will own the minted token
    * @param tokenId uint256 ID of the token to be minted
    */
   function _mint(address to, uint256 tokenId) internal {
       super._mint(to, tokenId);

       _addTokenToOwnerEnumeration(to, tokenId);

       _addTokenToAllTokensEnumeration(tokenId);
   }

   /**
    * @dev Internal function to burn a specific token.
    * Reverts if the token does not exist.
    * Deprecated, use {ERC721-_burn} instead.
    * @param owner owner of the token to burn
    * @param tokenId uint256 ID of the token being burned
    */
   function _burn(address owner, uint256 tokenId) internal {
       super._burn(owner, tokenId);

       _removeTokenFromOwnerEnumeration(owner, tokenId);
       // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
       _ownedTokensIndex[tokenId] = 0;

       _removeTokenFromAllTokensEnumeration(tokenId);
   }

   /**
    * @dev Gets the list of token IDs of the requested owner.
    * @param owner address owning the tokens
    * @return uint256[] List of token IDs owned by the requested address
    */
   function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
       return _ownedTokens[owner];
   }

   /**
    * @dev Private function to add a token to this extension's ownership-tracking data structures.
    * @param to address representing the new owner of the given token ID
    * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
   function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
       _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
       _ownedTokens[to].push(tokenId);
   }
}
