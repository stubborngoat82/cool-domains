//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

//Import openzeppelin contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//import helper functions
import "@openzeppelin/contracts/utils/Base64.sol";
import { StringUtils } from  "./libraries/StringUtils.sol";
import "hardhat/console.sol";

error Unauthorized();
error AlreadyRegistered();
error InvalidName (string name);


//We inherit the contract we imported. This means we have access
//to the inherited contracts methods.
contract Domains is ERC721URIStorage {

    //Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //domain TLD
    string public tld;

    //Storing NFT images on chain as SVGs
    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#a)" d="M0 0h270v270H0z"/><defs><filter id="b" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path fill="#fff" d="M20.234 25.887a5.308 5.308 0 0 0 3.301 2.41v-2.875l-4.687-3.125a11.402 11.402 0 0 0 1.386 3.59Zm27.871 3.793V18.625H42.98a7.21 7.21 0 0 0-5.062 2.094l-.867.87-.871-.87a7.204 7.204 0 0 0-5.063-2.094h-5.125V29.68c0 6.097 4.961 11.054 11.059 11.054 6.097 0 11.054-4.957 11.054-11.054ZM29.45 26.613c-.914-.832-1.23-2.058-.824-3.175l.414-1.13 4.324 1.965v.864c0 1.152-1.027 2.086-2.293 2.086a2.418 2.418 0 0 1-1.62-.61Zm7.602 10.438a4.918 4.918 0 0 1-4.914-4.914h2.457a2.459 2.459 0 0 0 2.457 2.457 2.459 2.459 0 0 0 2.457-2.457h2.457a4.918 4.918 0 0 1-4.914 4.914Zm5.976-9.828c-1.265 0-2.293-.934-2.293-2.086v-.864l4.325-1.964.414 1.128c.41 1.118.09 2.344-.825 3.176-.43.39-1.011.61-1.62.61Zm0 0"/><g clip-path="url(#a44b20e8de)"><path fill="#fff" d="M23.715 44.363 25.512 44l-1.715-2.742a21.855 21.855 0 0 0-9.695-8.422c-3.2-1.422-6-3.469-8.325-6.086l-4.324-4.863a19.862 19.862 0 0 0 3.317 9.98 9.308 9.308 0 0 1 1.57 5.184 9.27 9.27 0 0 1-1.121 4.386 27.662 27.662 0 0 1 18.496 2.926Zm0 0"/></g><path fill="#fff" d="M50.563 28.297a5.298 5.298 0 0 0 3.3-2.41 11.317 11.317 0 0 0 1.39-3.59l-4.69 3.125Zm-10.09 23.039c1.777-2.063 2.55-5.484 2.718-6.988v-2.649a13.394 13.394 0 0 1-12.285 0v2.645c.176 1.504.953 4.926 2.723 6.988a3.294 3.294 0 0 1 3.023-1.996h.793c1.36 0 2.524.824 3.028 2Zm-3.821.457a.832.832 0 0 0-.832.828c0 .11.024.211.063.313l1.168 2.921 1.168-2.921a.83.83 0 0 0-.773-1.14Zm17.793-6.621 2.72.543a8.615 8.615 0 0 1 5.812 4.25 21.04 21.04 0 0 1 5.32-6.137 25.268 25.268 0 0 0-13.852 1.344Zm0 0"/><g clip-path="url(#325d6de948)"><path fill="#fff" d="m72.648 21.887-4.324 4.863A24.204 24.204 0 0 1 60 32.836a21.855 21.855 0 0 0-9.695 8.422L48.59 44l1.797.363a27.654 27.654 0 0 1 18.496-2.925 9.27 9.27 0 0 1-1.121-4.387c0-1.852.543-3.645 1.566-5.184a19.854 19.854 0 0 0 3.32-9.98Zm0 0"/></g><path fill="#fff" d="m16.938 45.715 2.714-.543a25.187 25.187 0 0 0-13.851-1.34 21.045 21.045 0 0 1 5.324 6.133 8.598 8.598 0 0 1 5.813-4.25Zm0 0"/><g clip-path="url(#69622b283e)"><path fill="#fff" d="M22.309 10.023c.394.133.785.25 1.18.372a14.651 14.651 0 0 0-1.18 5.773v5.484l1.226.82v-6.304h7.582a9.7 9.7 0 0 1 5.934 2.047 9.682 9.682 0 0 1 5.93-2.047h7.581v6.305l1.231-.82v-5.485c0-2.05-.422-4-1.184-5.773.395-.122.79-.239 1.184-.372a8.892 8.892 0 0 0 4.914-7.949v-.648a14.652 14.652 0 0 1-8.117 2.457h-3.41a14.63 14.63 0 0 0-8.13-2.457c-3.003 0-5.8.906-8.132 2.457h-3.41a14.63 14.63 0 0 1-8.113-2.457v.648a8.884 8.884 0 0 0 4.914 7.95Zm0 0"/></g><defs><linearGradient id="a" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop/><stop offset="1" stop-color="red" stop-opacity=".99"/></linearGradient></defs><text x="50" y="50%" font-size="27" fill="#fff" filter="url(#b)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text><text x="115" y="235" font-size="30" fill="#fff" filter="url(#b)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartThree = '</text></svg>';

    //A "mapping" data type to store their values
    mapping(string => address) public domains;
    mapping(string => string) public records;
    mapping(string => string) public emails;
    mapping(string => string) public webpages;
    mapping(uint => string) public names;

    address payable public owner;


    constructor (string memory _tld) payable ERC721("(dot).hell Name Service" , "DHNS"){
        owner = payable(msg.sender);
        tld = _tld;
        console.log("%s name service deployed", _tld);
    }

    function price(string calldata name) public pure returns(uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
            return 5 * 10 ** 17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals).  We are going with .5 cause faucets dont give a lot
        } else if (len == 4) {
            return 3 * 10 ** 17; // to charge smaller amounts reduce the decimals. This is .3
        } else{
            return 1 * 10**17;
        }
    }
    

    // A register funciton that adds their names to our mapping
    function register (string calldata name) public payable {
        if (domains[name] != address(0)) revert AlreadyRegistered();
        if (!valid(name)) revert InvalidName(name);
        require(domains[name] == address(0));

        uint _price = price(name);

        //check if enough matic was paid in the transaction
        require(msg.value >= _price, "Not enough Matic paid");

        //Combine the name passed into the function with the TLD
        string memory _name = string(abi.encodePacked(name, ".", tld));
        string memory _svgtld = string(abi.encodePacked("(dot).", tld));
        //create the SVG (image) for the NFT with the name
        string memory finalSvg = string(abi.encodePacked(svgPartOne, name, svgPartTwo, _svgtld, svgPartThree));
        uint256 newRecordID = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordID);

        //create the JSON metadata of our NFT.  We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                _name,
                '", "description": "A domain on the Tokers TLD Name Service", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '","length":"',
                strLen,
                '"}'
            )
        );

        string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));
        
        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordID);
        _setTokenURI(newRecordID, finalTokenUri);
        domains[name] = msg.sender;
        names[newRecordID] = name;
        _tokenIds.increment();
    }

    function getAllNames() public view returns (string[] memory) {
        console.log("Getting all names from contract.");
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint i = 0; i < _tokenIds.current(); i++) {
            allNames[i];
            console.log("Name for token %d is %s", i, allNames[i]);
        }
        
        return allNames;
    }

    function valid(string calldata name) public pure returns(bool) {
        return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
    }


    //This will give us the domain owners address
    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        //check that the owner is the transaction sender
        if (msg.sender != domains[name]) revert Unauthorized();
        records[name] = record;
    }

    function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
    }

    function setEmail(string calldata name, string calldata email) public {
        //check that the owner is the transaction sender
        require(domains[name] == msg.sender);
        emails[name] = email;
        console.log("Email address set!", msg.sender);
    }

    function getEmail(string calldata name) public view returns (string memory) {
        return emails[name];
    }

    function setWebpage(string calldata name, string calldata webpage) public {
        require(domains[name] == msg.sender);
        webpages[name] = webpage;
    }

    function getWebpage(string calldata name) public view returns (string memory) {
        return webpages[name];
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }
    function withdraw() public onlyOwner {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw MATIC.");
    
    }
    
    

    
}

