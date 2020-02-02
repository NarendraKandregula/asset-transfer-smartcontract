pragma solidity >=0.4.21 <0.7.0;

contract PropertyTransfer {
    address public DA;
    uint public totalNoOfProperty;


    constructor() public {
        DA = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender == DA) _;
    }

    struct Property{
        string name;
        string _address;
        string location;
        string floor;
        bool isSold;
    }

    // we shall have the properties mapped against each address by its name and it's individual count.
    mapping(address => mapping(uint => Property)) public  propertiesOwner;
    // how many property does a particular person hold
    mapping(address => uint)  individualCountOfPropertyPerOwner;

    event PropertyAlloted(address indexed _verifiedOwner, uint indexed  _totalNoOfPropertyCurrently,
    string _nameOfProperty,string _propertyAddress,string _propertyLocation,string _propertyFloor, string _msg);
    event PropertyTransferred(address indexed _from, address indexed _to, string _propertyName, string _msg);
    uint public totalOwnedByDA;
    uint public totalOwnedByOthers;

    // this shall give us the exact property count which any address own at any point of time
    function getPropertyCountOfAnyAddress(address _ownerAddress) public returns (uint){
        uint count = 0;
        for(uint i = 0; i<individualCountOfPropertyPerOwner[_ownerAddress];i++){
            if(propertiesOwner[_ownerAddress][i].isSold != true)
            count++;
        }
        return count;
    }

    function getPropertyCountOfDA() public returns (uint){
        uint count = 0;
        for(uint i = 0; i<individualCountOfPropertyPerOwner[DA];i++){
            if(propertiesOwner[DA][i].isSold != true)
            count++;
        }
        return count;
    }


    // this function shall be called by DA only after verification
    function allotProperty(address _verifiedOwner, string memory _propertyName, string memory _propertyAddress,
     string memory _propertyLocation, string memory _propertyFloor) public onlyOwner
    {
        propertiesOwner[_verifiedOwner][individualCountOfPropertyPerOwner[_verifiedOwner]++].name = _propertyName;
        propertiesOwner[_verifiedOwner][individualCountOfPropertyPerOwner[_verifiedOwner]]._address = _propertyAddress;
        propertiesOwner[_verifiedOwner][individualCountOfPropertyPerOwner[_verifiedOwner]].location = _propertyLocation;
        propertiesOwner[_verifiedOwner][individualCountOfPropertyPerOwner[_verifiedOwner]].floor = _propertyFloor;
        totalNoOfProperty++;
        totalOwnedByDA = getPropertyCountOfDA();
        emit PropertyAlloted(_verifiedOwner,individualCountOfPropertyPerOwner[_verifiedOwner], _propertyName, _propertyAddress,
        _propertyLocation, _propertyFloor, "property allotted successfully");
    }
    // check whether the owner have the said property or not. if yes, return the index
    function isOwner(address _checkOwnerAddress, string memory _propertyName) public returns (uint){
        uint i;
        bool flag;
        for(i = 0 ; i<individualCountOfPropertyPerOwner[_checkOwnerAddress]; i++){
            if(propertiesOwner[_checkOwnerAddress][i].isSold == true){
                break;
            }
         flag = stringsEqual(propertiesOwner[_checkOwnerAddress][i].name,_propertyName);
            if(flag == true){
                break;
            }
        }
        if(flag == true){
            return i;
        }
        else {
            return 999999999;// We're expecting that no individual shall be owning this much properties
        }
    }
    // functionality to check the equality of two strings in Solidity
    function stringsEqual (string memory _a1, string memory _a2) public returns (bool){
            return keccak256(abi.encode(_a1)) == keccak256(abi.encode(_a2))? true:false;
    }

    // transfer the property to the new owner
    function transferProperty (address _to, string memory _propertyName) public
      returns (bool ,  uint )
    {
        uint checkOwner = isOwner(msg.sender, _propertyName);
        bool flag;

        if(checkOwner != 999999999 && propertiesOwner[msg.sender][checkOwner].isSold == false){
            // step 1 . remove the property from the current owner and decrase the counter.
            // step 2 . assign the property to the new owner and increase the counter
            propertiesOwner[msg.sender][checkOwner].isSold = true;
            propertiesOwner[msg.sender][checkOwner].name = "Sold";// really nice finding. we can't put empty string
            propertiesOwner[_to][individualCountOfPropertyPerOwner[_to]++].name = _propertyName;
            flag = true;
            emit PropertyTransferred(msg.sender , _to, _propertyName, "Owner has been changed." );
        }
        else {
            flag = false;
            emit PropertyTransferred(msg.sender , _to, _propertyName, "Owner doesn't own the property." );
        }
        totalOwnedByDA = getPropertyCountOfDA();
        totalOwnedByOthers = totalNoOfProperty - totalOwnedByDA;
        return (flag, checkOwner);
    }

}
