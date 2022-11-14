pragma solidity ^0.4.4;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract Token  {
function totalSupply ()  constant returns (uint256    supply){
}

function balanceOf (address    _owner)  constant returns (uint256    balance){
}

function transfer (address    _to,uint256    _value)   returns (bool    success){
}

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
}

function approve (address    _spender,uint256    _value)   returns (bool    success){
}

function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining){
}

event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value);
event Approval (address  indexed  _owner,address  indexed  _spender,uint256    _value);
}
contract StandardToken is sGuardPlus,Token {
function transfer (address    _to,uint256    _value)   returns (bool    success){
if (balances[msg.sender]>=_value&&_value>0)
{
balances[msg.sender]=sub_uint256(balances[msg.sender], _value);
balances[_to]=add_uint256(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
 else 
{
return false;
}

}

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
if (balances[_from]>=_value&&allowed[_from][msg.sender]>=_value&&_value>0)
{
balances[_to]=add_uint256(balances[_to], _value);
balances[_from]=sub_uint256(balances[_from], _value);
allowed[_from][msg.sender]=sub_uint256(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
}
 else 
{
return false;
}

}

function distributeToken (address []   addresses,uint256    _value)   {
for(uint     i = 0;i<addresses.length; i=add_uint(i, 1)){
balances[msg.sender]=sub_uint256(balances[msg.sender], _value);
balances[addresses[i]]=add_uint256(balances[addresses[i]], _value);
Transfer(msg.sender, addresses[i], _value);
}

}

function balanceOf (address    _owner)  constant returns (uint256    balance){
return balances[_owner];
}

function approve (address    _spender,uint256    _value)   returns (bool    success){
allowed[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
return true;
}

function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining){
return allowed[_owner][_spender];
}

mapping (address  => uint256 )    balances;
mapping (address  => mapping (address  => uint256 ))    allowed;
uint256  public   totalSupply;
}
contract ERC20Token is StandardToken {
function ()   {
throw;}

string  public   name;
uint8  public   decimals;
string  public   symbol;
string  public   version = "H1.0";
constructor ()   {
totalSupply=12*10**24;
balances[msg.sender]=totalSupply;
name="EETHER";
decimals=18;
symbol="EETHER";
}

function approveAndCall (address    _spender,uint256    _value,bytes    _extraData)   returns (bool    success){
allowed[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
if ( ! _spender.call(bytes4 (bytes32 (sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData))
{
throw;}

return true;
}

}
