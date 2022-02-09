// SPDX-License-Identifier: MIT
/*

36 Bear Doodles are unique characters to help children learn to draw while singing.

  ____    __    ____                    _____                  _ _
 |___ \  / /   |  _ \                  |  __ \                | | |
   __) |/ /_   | |_) | ___  __ _ _ __  | |  | | ___   ___   __| | | ___  ___
  |__ <| '_ \  |  _ < / _ \/ _` | '__| | |  | |/ _ \ / _ \ / _` | |/ _ \/ __|
  ___) | (_) | | |_) |  __/ (_| | |    | |__| | (_) | (_) | (_| | |  __/\__ \
 |____/ \___/  |____/ \___|\__,_|_|    |_____/ \___/ \___/ \__,_|_|\___||___/
                      by @defyma / 0x0E060cC23C6791a06c6B6cDeBC988FB2C4cf7d7A
                      from Bandung, Indonesia
                      9 Feb 2022
*/

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContextMixin.sol";

contract ThirtySixBearDoodles is ERC721, ERC721Enumerable, Ownable, ContextMixin {
    string private _customBaseUri = 'https://defyma.github.io/project/36-bear-doodles/meta/';
    uint256 public constant MAX_SUPPLY = 10001;

    constructor() ERC721("Thirty Six Bear Doodles", "TSBD") {}

    function safeMint(address to) public onlyOwner {
        uint256 ts = totalSupply();
        require(ts + 1 <= MAX_SUPPLY, "Not enough tokens left");

        _safeMint(to, ts + 1);
    }

    function safeMintBulk(address to, uint _num) public onlyOwner {
        uint256 ts = totalSupply();
        require(_num > 0 && _num < 1001, "Can only mint between 1 and 1000 tokens at once");
        require(ts + _num <= MAX_SUPPLY, "Not enough tokens left");

        for (uint256 i = 1; i <= _num; i++) {
            _safeMint(to, ts + i);
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _customBaseUri = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _customBaseUri;
    }

    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    /**
    * Override isApprovedForAll to auto-approve OS's proxy contract
    */
    function isApprovedForAll(address _owner, address _operator) public override view returns (bool isOperator) {
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721.isApprovedForAll(_owner, _operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender() internal override view returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}
