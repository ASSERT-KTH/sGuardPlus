pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        __lock_modifier0_lock = false;
                                        
                                }
                                
                                
                bool private __lock_modifier0_lock;
                modifier __lock_modifier0() {
                        require(!__lock_modifier0_lock);
                        __lock_modifier0_lock = true;
                        _;
                        __lock_modifier0_lock = false;
                        
                }
                
                                
                                
                        }
                contract PrivateDeposit is sGuardPlus {
mapping (address  => uint ) public   balances;
uint  public   MinDeposit = 1 ether;
address  public   owner;
Log     TransferLog;
modifier onlyOwner (){
require(msg.sender==owner);
_;
}
constructor ()   {
owner=msg.sender;
TransferLog=new Log ();
}

function setLog (address    _lib)  onlyOwner  {
TransferLog=Log(_lib);
}

function Deposit () public payable {
if (msg.value>=MinDeposit)
{
balances[msg.sender]+=msg.value;
TransferLog.AddMessage(msg.sender, msg.value, "Deposit");
}

}

function CashOut (uint    _am)  __lock_modifier0  {
if (_am<=balances[msg.sender])
{
if (msg.sender.call.value(_am)())
{
balances[msg.sender]-=_am;
TransferLog.AddMessage(msg.sender, _am, "CashOut");
}

}

}

function () public payable {
}

}
contract Log  {
struct Message {
address     Sender;
string     Data;
uint     Val;
uint     Time;
}
Message [] public   History;
Message     LastMsg;
function AddMessage (address    _adr,uint    _val,string    _data) public  {
LastMsg.Sender=_adr;
LastMsg.Time=now;
LastMsg.Val=_val;
LastMsg.Data=_data;
History.push(LastMsg);
}

}
