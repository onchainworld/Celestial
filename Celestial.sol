// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";




interface extInterface {
    function ownerOf(uint256 _tokenId) external view returns (address);
}


                                                                 

contract Celestial is ERC721, Ownable, ReentrancyGuard {


    using Counters for Counters.Counter;
    Counters.Counter private celestialSupply;
    

    constructor() ERC721("Celestial", "CLST") {}


    address internal distortionAddress = 0x2C32A1c3123492f79707A86B6Ede12E6e4E902c8;
    string public artSeed = '0x205a10c241ca38918d3790c89f16675cc46d10a9';

    uint256 public maxSupply = 1111;
    bool internal distClaimActive = true;
    bool internal mintActive = false;
    uint256 internal price; 

    mapping(address => bool) internal onePerWallet;
    mapping(uint256 => bool) internal distortionTokenIdClaimed;

    mapping(uint256 => uint256) internal tokenTransferredTimestamp;
    mapping(uint256 => uint256) internal tokenLevels;



    /*
    *  ___ ___   _   ___    ___ _   _ _  _  ___ _____ ___ ___  _  _ ___ 
    *  | _ \ __| /_\ |   \  | __| | | | \| |/ __|_   _|_ _/ _ \| \| / __|
    *  |   / _| / _ \| |) | | _|| |_| | .` | (__  | |  | | (_) | .` \__ \
    *  |_|_\___/_/ \_\___/  |_|  \___/|_|\_|\___| |_| |___\___/|_|\_|___/
    *                                                              
    */


    function totalSupply() public view returns (uint256 supply) {
        return celestialSupply.current();
    }

    function hasDistortionClaimed(uint256 _tokenId) public view returns (bool) {
        return distortionTokenIdClaimed[_tokenId];
    }
    
    function isDistClaimActive() public view returns (bool) {
        return distClaimActive;
    }

    function isMintActive() public view returns (bool) {
        return mintActive;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }
    
    function getTokenTimeHeld(uint256 _tokenId) public view returns (uint256) {
        return block.timestamp - tokenTransferredTimestamp[_tokenId];
    }

    function getTokenLevel(uint256 _tokenId) public view returns (uint256) {
        return tokenLevels[_tokenId] + 1;
    }



    /*
    *  _____      ___  _ ___ ___   ___ _   _ _  _  ___ _____ ___ ___  _  _ ___ 
    *  / _ \ \    / / \| | __| _ \ | __| | | | \| |/ __|_   _|_ _/ _ \| \| / __|
    *  | (_) \ \/\/ /| .` | _||   / | _|| |_| | .` | (__  | |  | | (_) | .` \__ \
    *  \___/ \_/\_/ |_|\_|___|_|_\ |_|  \___/|_|\_|\___| |_| |___\___/|_|\_|___/
    *                                                                          
    */


    function setDistClaim(bool _boolean) external onlyOwner {
        distClaimActive = _boolean;
    }

    function setMint(bool _boolean) external onlyOwner {
        mintActive = _boolean;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    bool internal artistMintingPermanentlyDisabled;
    function disableArtistMinting() external onlyOwner {
        artistMintingPermanentlyDisabled = true;
    }

    bool internal holderMintingPermanentlyDisabled;
    function disableHolderMinting() external onlyOwner {
        holderMintingPermanentlyDisabled = true;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(owner()), balance);
    }



    /*
    *   __  __ ___ _  _ _____   __  __  ___  ___ ___ ___ ___ ___ ___  ___ 
    *  |  \/  |_ _| \| |_   _| |  \/  |/ _ \|   \_ _| __|_ _| __| _ \/ __|
    *  | |\/| || || .` | | |   | |\/| | (_) | |) | || _| | || _||   /\__ \
    *  |_|  |_|___|_|\_| |_|   |_|  |_|\___/|___/___|_| |___|___|_|_\|___/
    *                                                                      
    */


    modifier claimReqs(uint256 _amount) {
        require(isDistClaimActive(), "Claim is not active...");
        require(tx.origin == msg.sender);
        require(celestialSupply.current() + _amount <= maxSupply, "Max supply cap reached.");
        _;
    }

    modifier artistReqs(uint256 _amount) {
        require(celestialSupply.current() + _amount <= maxSupply, "Max supply cap reached.");
        _;
    }

    modifier mintReqs() {
        require(isMintActive(), "Mint is not active...");
        require(msg.value == getPrice());
        require(celestialSupply.current() + 1 <= maxSupply, "Max supply cap reached.");
        _;
    }



    /*
    *  __  __ ___ _  _ _____ ___ _  _  ___   ___ _   _ _  _  ___ _____ ___ ___  _  _ ___ 
    *  |  \/  |_ _| \| |_   _|_ _| \| |/ __| | __| | | | \| |/ __|_   _|_ _/ _ \| \| / __|
    *  | |\/| || || .` | | |  | || .` | (_ | | _|| |_| | .` | (__  | |  | | (_) | .` \__ \
    *  |_|  |_|___|_|\_| |_| |___|_|\_|\___| |_|  \___/|_|\_|\___| |_| |___\___/|_|\_|___/
    *                                                                                                                      
    */

    
    function distortionClaimByToken(uint256[] memory  _tokenIds) external nonReentrant claimReqs(_tokenIds.length) {

        require(!holderMintingPermanentlyDisabled, "Distortion holder minting was permanently disabled.");

        for(uint i = 0; i < _tokenIds.length; i++) {
            require(extInterface(distortionAddress).ownerOf(_tokenIds[i]) == msg.sender);
            require(!distortionTokenIdClaimed[_tokenIds[i]]);
        }

        for(uint i = 0; i < _tokenIds.length; i++) {
            uint256 tokenIdToMint = celestialSupply.current() + 1;
            !distortionTokenIdClaimed[_tokenIds[i]];
            tokenLevels[tokenIdToMint] = 3;
            tokenTransferredTimestamp[tokenIdToMint] = block.timestamp;
            _safeMint(msg.sender, tokenIdToMint);
            celestialSupply.increment();
        }

    }


    function distortionMergeClaim(uint256[] memory  _tokenIds) external nonReentrant claimReqs(_tokenIds.length) {

        require(holderMintingPermanentlyDisabled == false, "Distortion holder minting was permanently disabled.");
        require(_tokenIds.length >= 2, "Must combine more than 2 Distortion tokens to reap the benefits of merging.");


        for(uint i = 0; i < _tokenIds.length; i++) {
            require(extInterface(distortionAddress).ownerOf(_tokenIds[i]) == msg.sender);
            require(!distortionTokenIdClaimed[_tokenIds[i]]);
        }

        for(uint i = 0; i < _tokenIds.length; i++) {
            !distortionTokenIdClaimed[_tokenIds[i]];
        }

        uint256 levelMultiplier;


        if (_tokenIds.length <= 4) {
            levelMultiplier = 100;
        } else if (_tokenIds.length > 4 && _tokenIds.length <= 7) {
            levelMultiplier = 200;
        } else {
            levelMultiplier = 300;
        }
        

        uint256 tokenIdToMint = celestialSupply.current() + 1;
        tokenTransferredTimestamp[tokenIdToMint] = block.timestamp;
        _safeMint(msg.sender, tokenIdToMint);
        celestialSupply.increment();
        maxSupply = maxSupply - _tokenIds.length + 1; //maxSupply gets reduced due to Distortion claim combination.
        tokenLevels[tokenIdToMint] = ((_tokenIds.length * 3) - 1) + _tokenIds.length * (100 + levelMultiplier) / 100;

    }


    function artistMint(uint256 _amountToMint, uint256[] calldata _levels) external onlyOwner artistReqs(_amountToMint) {

        require(_amountToMint == _levels.length);
        require(artistMintingPermanentlyDisabled == false, "Artist minting was permanently disabled.");
        
        for(uint i = 0; i < _amountToMint; i++) {
            uint256 tokenIdToMint = celestialSupply.current() + 1;
            _safeMint(msg.sender, tokenIdToMint);
            tokenTransferredTimestamp[tokenIdToMint] = block.timestamp;
            tokenLevels[tokenIdToMint] = _levels[i] - 1;
            celestialSupply.increment();
        }

    }


    function publicMint() external payable mintReqs()  {

		require(!onePerWallet[msg.sender]);
        !onePerWallet[msg.sender] ;
        _safeMint(msg.sender, celestialSupply.current() + 1);
        celestialSupply.increment();
    
    }



    /*
    *    _   _ ___  ___ ___    _   ___  ___   _____ ___  _  _____ _  _ 
    *   | | | | _ \/ __| _ \  /_\ |   \| __| |_   _/ _ \| |/ / __| \| |
    *   | |_| |  _/ (_ |   / / _ \| |) | _|    | || (_) | ' <| _|| .` |
    *    \___/|_|  \___|_|_\/_/ \_\___/|___|   |_| \___/|_|\_\___|_|\_|
    *                             
    */


    function upgradeToken(uint256 _tokenId) external nonReentrant {

        require(msg.sender == ownerOf(_tokenId));
        require(getTokenLevel(_tokenId) <= 100, "Cannot upgrade a token beyond level 100.");
        require(getTokenTimeHeld(_tokenId) >= 7 days);
        tokenTransferredTimestamp[_tokenId] = block.timestamp;
        tokenLevels[_tokenId]++;
    
    }


    function bulkUpgradeTokens(uint256[] memory _tokenIds) external nonReentrant {

        for(uint i = 0; i < _tokenIds.length; i++) {
            require(getTokenLevel(_tokenIds[i]) <= 100, "Cannot upgrade a token beyond level 100.");
            require(msg.sender == ownerOf(_tokenIds[i]));
            require(getTokenTimeHeld(_tokenIds[i]) >= 7 days);
        }

        for(uint i = 0; i < _tokenIds.length; i++) {
            tokenTransferredTimestamp[_tokenIds[i]] = block.timestamp;
            tokenLevels[_tokenIds[i]]++;
        }
    }



    /*
    *    _____ ___    _   _  _ ___ ___ ___ ___   ___ _   _ _  _  ___ _____ ___ ___  _  _ ___ 
    *   |_   _| _ \  /_\ | \| / __| __| __| _ \ | __| | | | \| |/ __|_   _|_ _/ _ \| \| / __|
    *     | | |   / / _ \| .` \__ \ _|| _||   / | _|| |_| | .` | (__  | |  | | (_) | .` \__ \
    *     |_| |_|_\/_/ \_\_|\_|___/_| |___|_|_\ |_|  \___/|_|\_|\___| |_| |___\___/|_|\_|___/
    *                                                                                        
    */


    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        tokenTransferredTimestamp[tokenId] = block.timestamp;
        _safeTransfer(from, to, tokenId, _data);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        tokenTransferredTimestamp[tokenId] = block.timestamp;
        _transfer(from, to, tokenId);
    }



    /*
    *     ___ ___ _  _ ___ ___    _ _____ _____   _____     _   ___ _____ 
    *    / __| __| \| | __| _ \  /_\_   _|_ _\ \ / / __|   /_\ | _ \_   _|
    *   | (_ | _|| .` | _||   / / _ \| |  | | \ V /| _|   / _ \|   / | |  
    *    \___|___|_|\_|___|_|_\/_/ \_\_| |___| \_/ |___| /_/ \_\_|_\ |_|  
    *                                                                     
    */


    string[] internal colorNames = ['Cornsilk' ,'Burlywood','Sandybrown','Peru','Saddlebrown','Tan','Goldenrod']; 


    function generateColorNumber(string memory name, uint256 tokenId) internal view returns (uint256) {

        uint256 output;
        uint256 rand = uint256(keccak256(abi.encodePacked(name, toString(tokenId)))) % 100;

        if (keccak256(bytes(artSeed)) == keccak256(bytes(''))) {
            output = 0; //unrevealed
        } else {
            if (rand <= 15) {
                output = 1; //Burlywood with 15% rarity.
            } else if (rand > 15 && rand <= 30) {
                output = 2; //Sandybrown with 15% rarity.
            } else if (rand > 30 && rand <= 45) {
                output = 3; //Peru with 15% rarity.
            } else if (rand > 45 && rand <= 75) {
                output = 0; //Cornsilk with 30% rarity.
            } else if (rand > 75 && rand <= 80) {
                output = 4; //Saddlebrown with 5% rarity.
            } else if (rand > 80 && rand <= 90) {
                output = 5; //Tan with 10% rarity.
            } else if (rand > 90) {
                output = 6; //Goldenrod with 10% rarity.
            }
        }
        return output;
    }


    function generateNum(string memory name, uint256 tokenId, string memory genVar, uint256 low, uint256 high) internal view returns (string memory) {
        
        uint256 difference = high - low;
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(genVar, tokenId, name))) % difference + 1;
        randomnumber = randomnumber + low;
        return toString(randomnumber);

    }


    function generateNumUint(string memory name, uint256 tokenId, string memory genVar, uint256 low, uint256 high) internal view returns (uint256) {

        uint256 difference = high - low;
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(genVar, tokenId, name))) % difference + 1;
        randomnumber = randomnumber + low;
        return randomnumber;

    }


    function getX(uint256 tokenId, uint256 genVar) internal view returns (uint256) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(genVar, tokenId, "X"))) % 100;
        randomnumber = randomnumber + 250;
        return randomnumber;
    }


    function getY(uint256 tokenId, uint256 genVar) internal view returns (uint256) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(genVar, tokenId, "Y"))) % 150;
        randomnumber = randomnumber + 350;
        return randomnumber;
    }


    function getWidthAndHeight(uint256 tokenId) internal view returns (uint256) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(tokenId, "Width"))) % 50;
        randomnumber = randomnumber + 100;
        return randomnumber;
    }


    function getRotation(uint256 tokenId, uint256 genVar) internal view returns (uint256) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(genVar, tokenId, "Y"))) % 150;
        return randomnumber;
    }

    function genRect(uint256 tokenId) internal view returns (string memory) {

        string memory output2 ;
        string memory output1 ;
        string memory wh = generateNum("width", tokenId, artSeed, 1, 40);
        string memory hh = generateNum("height", tokenId, artSeed, 1, 20);
        string memory negativeSign;
        uint256 count = getTokenLevel(tokenId);

        for (uint256 i = 0; i < count; i++) {    
        
        if (i % 2 == 0) { negativeSign = '-';} else {negativeSign = '';}

        output1 = string(abi.encodePacked(
            '<rect x="',
            toString(getX(tokenId, i)),                   
            '" y="',
            toString(getY(tokenId, i)),                
            '" width="',
            wh,       
            '"  height="',
            hh,
            '" stroke-width="4" fill="none" transform="rotate(',
            negativeSign,
            toString(getRotation(tokenId, i)),  
            ' 275 275)" />'
    
            ));

         output2 = string(abi.encodePacked(output2, output1)); 

        }

        return output2;
    }
    

    function genSecond(uint256 tokenId) internal view returns (string memory) {
        
        string memory duration = generateNum("duration", tokenId, artSeed, 10, 20);

        string memory output2 ;
        string memory output1 ;

        uint256 number;

        for (uint256 i = 1; i < 5; i++) {  

        number = i * 90;



        output1 = string(abi.encodePacked(


            '<g transform="rotate(',           
            toString(number),
            ' 250 250)"> <use href="#first"/><animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 250 250" to="360 360 250" dur="',
            duration,
            's" additive="sum" repeatCount="indefinite" /> </g>'
          
            ));

         output2 = string(abi.encodePacked(output2, output1)); 


        }
        
        return output2;
    }


    function genThird(uint256 tokenId) internal view returns (string memory) {

        string memory output2 ;
        string memory output1 ;

        uint256 number;

        for (uint256 i = 1; i < 7; i++) {

            number = i * 60;
            output1 = string(abi.encodePacked(
                '<g transform="scale(0.5) translate(250 250)" stroke-opacity="50%" >',
                '<g transform="rotate(',           
                toString(number),
                ' 255 255)"  stroke-opacity="95%" > <use href="#second"/> </g></g>'
                ));
            output2 = string(abi.encodePacked(output2, output1)); 

        }

        return output2;
    }
    

    function Combine(uint256 tokenId) public view returns (string memory) {

        string memory output2 ;
        string memory output1 ;

        output1 = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" style="background-color:#000;"> <defs> <filter id="y"> <feGaussianBlur stdDeviation="9" /> <!-- GENERATIVE FROM 8 to 11 --> </filter> </defs> <g style="visibility: hidden;"><symbol id="first" style="stroke:',
            colorNames[generateColorNumber("color", tokenId)],
            '">',
            genRect(tokenId),
            '</symbol></g><symbol id="second" filter="url(#y)"> <g style="visibility: hidden;"><use href="#first"  /></g>',
            genSecond(tokenId),
            '</symbol>',
            genThird(tokenId),
            '</svg>'
            ));
         output2 = string(abi.encodePacked(output2, output1)); 

        return output2;
    }
    
    





    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        //require(_exists(tokenId), "Token doesn't exist...");

        string memory wh = generateNum("width", tokenId, artSeed, 1, 40);
        string memory hh = generateNum("height", tokenId, artSeed, 1, 20);


        string memory output = string(abi.encodePacked(Combine(tokenId)));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Celestial #', toString(tokenId),
        
       '","attributes": [ { "trait_type": "Color", "value": "',
       colorNames[generateColorNumber("color", tokenId)],
       '" }, { "display_type": "number", "trait_type": "Level", "value": ',
       toString(tokenLevels[tokenId] + 1),
       ' }, { "trait_type": "Width", "value": "', 
       wh,
       '" }, { "trait_type": "Height", "value": "',
       hh,
       '" }]',
       ', "description": "Celestial is a fully on-chain art collection.", "image": "data:image/svg+xml;base64,',
       Base64.encode(bytes(output)),
       '"}'))));
       
       
        string memory outputfinal= string(abi.encodePacked('data:application/json;base64,', json));

        return outputfinal;
    }


    
	
	
	
	 /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }





}



/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
