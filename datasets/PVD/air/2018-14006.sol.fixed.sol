pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint256 c = a * b;
                                assert(c / a == b);
                                return c;
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
                                
                                
                                
                        }
                interface ERC20  {
function name () public view returns (string    );
function symbol () public view returns (string    );
function decimals () public view returns (uint8    );
function totalSupply () public view returns (uint256    );
function balanceOf (address    _owner) public view returns (uint256    );
function transfer (address    _to,uint256    _value) public  returns (bool    success);
function transferFrom (address    _from,address    _to,uint256    _value) public  returns (bool    success);
function approve (address    _spender,uint256    _value) public  returns (bool    success);
function allowance (address    _owner,address    _spender) public view returns (uint256    );
event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value);
event Approval (address  indexed  _owner,address  indexed  _spender,uint256    _value);
}
interface TokenRecipient  {
function receiveApproval (address    _from,uint256    _value,address    _token,bytes    _extraData) public  ;
}
interface ERC223Receiver  {
function tokenFallback (address    _from,uint256    _value,bytes    _data) public  ;
}
contract ERC223 is ERC20 {
function transfer (address    _to,uint256    _value,bytes    _data) public  returns (bool    success);
function transfer (address    _to,uint256    _value,bytes    _data,string    _customFallback) public  returns (bool    success);
event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value,bytes    _data);
}
contract NGToken is sGuardPlus,ERC223 {
string  private constant  NAME = "NEO Genesis Token";
string  private constant  SYMBOL = "NGT";
uint8  private constant  DECIMALS = 18;
uint256  private constant  INITIAL_SUPPLY = 20000000000*(10**uint256 (DECIMALS));
uint256  private   totalBurned = 0;
mapping (address  => uint256 ) private   balances;
mapping (address  => mapping (address  => uint256 )) private   allowed;
constructor () public  {
balances[msg.sender]=INITIAL_SUPPLY;
}

function name () public view returns (string    ){
return NAME;
}

function symbol () public view returns (string    ){
return SYMBOL;
}

function decimals () public view returns (uint8    ){
return DECIMALS;
}

function totalSupply () public view returns (uint256    ){
return INITIAL_SUPPLY-totalBurned;
}

function balanceOf (address    _owner) public view returns (uint256    ){
return balances[_owner];
}

function transfer (address    _to,uint256    _value) public  returns (bool    success){
if (isContract(_to))
{
bytes    memory empty;
return transferToContract(_to, _value, empty);
}
 else 
{
require(_to!=address (0x0));
require(balances[msg.sender]>=_value);
balances[msg.sender]-=_value;
balances[_to]+=_value;
Transfer(msg.sender, _to, _value);
}

return true;
}

function multipleTransfer (address []   _to,uint256    _value) public  returns (bool    success){
require(mul_uint256(_value, _to.length)>0);
require(balances[msg.sender]>=mul_uint256(_value, _to.length));
balances[msg.sender]=sub_uint256(balances[msg.sender], mul_uint256(_value, _to.length));
for(uint256     i = 0;i<_to.length; i=add_uint256(i, 1)){
balances[_to[i]]=add_uint256(balances[_to[i]], _value);
Transfer(msg.sender, _to[i], _value);
}

return true;
}

function batchTransfer (address []   _to,uint256 []   _value) public  returns (bool    success){
require(_to.length>0);
require(_value.length>0);
require(_to.length==_value.length);
for(uint256     i = 0;i<_to.length; i=add_uint256(i, 1)){
address     to = _to[i];
uint256     value = _value[i];
require(balances[msg.sender]>=value);
balances[msg.sender]=sub_uint256(balances[msg.sender], value);
balances[to]=add_uint256(balances[to], value);
Transfer(msg.sender, to, value);
}

return true;
}

function transferFrom (address    _from,address    _to,uint256    _value) public  returns (bool    success){
require(_to!=address (0x0));
require(balances[_from]>=_value&&allowed[_from][msg.sender]>=_value);
balances[_from]-=_value;
balances[_to]+=_value;
allowed[_from][msg.sender]-=_value;
Transfer(_from, _to, _value);
bytes    memory empty;
Transfer(_from, _to, _value, empty);
return true;
}

function approve (address    _spender,uint256    _value) public  returns (bool    success){
require((_value==0)||(allowed[msg.sender][_spender]==0));
allowed[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
return true;
}

function approveAndCall (address    _spender,uint256    _value,bytes    _extraData) public  returns (bool    success){
TokenRecipient     spender = TokenRecipient(_spender);
if (approve(_spender, _value))
{
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}

return false;
}

function increaseApproval (address    _spender,uint256    _addValue) public  returns (bool    ){
allowed[msg.sender][_spender]=add_uint256(allowed[msg.sender][_spender], _addValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}

function decreaseApproval (address    _spender,uint256    _subValue) public  returns (bool    ){
if (_subValue>allowed[msg.sender][_spender])
{
allowed[msg.sender][_spender]=0;
}
 else 
{
allowed[msg.sender][_spender]-=_subValue;
}

Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}

function allowance (address    _owner,address    _spender) public view returns (uint256    ){
return allowed[_owner][_spender];
}

function transfer (address    _to,uint256    _value,bytes    _data) public  returns (bool    success){
if (isContract(_to))
{
return transferToContract(_to, _value, _data);
}
 else 
{
return transferToAddress(_to, _value, _data);
}

}

function transfer (address    _to,uint256    _value,bytes    _data,string    _customFallback) public  returns (bool    success){
if (isContract(_to))
{
require(_to!=address (0x0));
require(balances[msg.sender]>=_value);
balances[msg.sender]-=_value;
balances[_to]+=_value;
assert(_to.call.value(0)(bytes4 (keccak256(_customFallback)), msg.sender, _value, _data));
Transfer(msg.sender, _to, _value);
Transfer(msg.sender, _to, _value, _data);
return true;
}
 else 
{
return transferToAddress(_to, _value, _data);
}

}

function transferToAddress (address    _to,uint256    _value,bytes    _data) private  returns (bool    success){
require(_to!=address (0x0));
require(balances[msg.sender]>=_value);
balances[msg.sender]-=_value;
balances[_to]+=_value;
Transfer(msg.sender, _to, _value);
Transfer(msg.sender, _to, _value, _data);
return true;
}

function transferToContract (address    _to,uint256    _value,bytes    _data) private  returns (bool    success){
require(_to!=address (0x0));
require(balances[msg.sender]>=_value);
balances[msg.sender]-=_value;
balances[_to]+=_value;
ERC223Receiver     receiver = ERC223Receiver(_to);
receiver.tokenFallback(msg.sender, _value, _data);
Transfer(msg.sender, _to, _value);
Transfer(msg.sender, _to, _value, _data);
return true;
}

function isContract (address    _addr) private view returns (bool    ){
uint256     length;
assembly{
length := extcodesize(_addr)
}
return (length>0);
}

event Burn (address  indexed  burner,uint256    value,uint256    currentSupply,bytes    data);
function burn (uint256    _value,bytes    _data) public  returns (bool    success){
require(balances[msg.sender]>=_value);
balances[msg.sender]-=_value;
totalBurned+=_value;
Burn(msg.sender, _value, totalSupply(), _data);
return true;
}

function burnFrom (address    _from,uint256    _value,bytes    _data) public  returns (bool    success){
if (transferFrom(_from, msg.sender, _value))
{
return burn(_value, _data);
}

return false;
}

function initialSupply () public pure returns (uint256    ){
return INITIAL_SUPPLY;
}

function currentBurned () public view returns (uint256    ){
return totalBurned;
}

function () public  {
require(false);
}

}
