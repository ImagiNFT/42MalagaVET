pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


///
/// @dev Interface for the NFT Royalty Standard
///
interface IERC2981 is IERC165 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}

contract FTMalagaVETNFT is ERC1155,  IERC2981 {
    
    address admin;
    address royaltyRecipient = 0xd3299cc47F1aFb07E06BbF9c812cC954ed75e6Cc;
    uint256 eddIa = 0;
    uint256 supply = 42;
    uint256 fee = 5; // this is for secondary markets and is a percentage 
    // uri in format: "https://game.example/api/item/{id}.json"
    // for github uri: "https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{path}"
    // You can use IPFS to host metadata files if we want to do it on a decentralized way
    // for this case we will use github for hosting this metadata for simplicity and better understanding
    // format for the metadata json file used by opensea and widely recognized: https://docs.opensea.io/docs/metadata-standards#metadata-structure


    // uri for edd.ia: "https://raw.githubusercontent.com/ImagiNFT/42MalagaVET/main/{id}.json"
    constructor(string memory _uri) ERC1155(_uri) {
        admin = msg.sender;
        _mint(msg.sender, eddIa, supply, "");
    }

    function setUri(string memory _newUri) public virtual onlyAdmin {
        //require(msg.sender == admin, "Revert: Not Admin");
        _setURI(_newUri);
    }

    function owner() public view returns (address) {
        return admin;
    }

    function setRoyaltyRecipient(address _royaltyRecipient) public virtual onlyAdmin {
        //require(msg.sender == admin, "Revert: Not Admin");
        royaltyRecipient = _royaltyRecipient;
    }

    function mint(uint256 _tokenId, uint256 _amount) public {
        _mint(msg.sender, _tokenId, _amount, "");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC1155, IERC165) returns (bool) {
        return (
            ERC1155.supportsInterface(interfaceId) 
            || interfaceId == type(IERC2981).interfaceId
            || interfaceId == type(IERC165).interfaceId
        );
    }

    function royaltyInfo(uint256 tokenId, uint256 _salePrice) virtual override external view returns (address _receiver, uint256 _royaltyAmount) {
        return (royaltyRecipient, uint256(_salePrice * fee / 100));
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Revert: Not Admin");
        _;
    }
}