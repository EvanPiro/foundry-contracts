# Testing Events

```solidity
contract Contract {
    event DataUpdated(address sender);
    
    function updateData() {
        emit DataUpdated(msg.sender);
    }
}

contract EventTester {
    event DataUpdated(address sender);
    Contract instance;
    
    function setUp() {
        instance = new Contract();
    }
    
    function testEvent() {
        // Sets up the expectation of the test where the explicitly emitted event 
        // is the expected event.
        // The `expectEmit` function's first three arguments tell the checker whether or not 
        // to check 3 optional indexed values and the forth argument tells it whether or not 
        // to check the value of the data. All data that is not indexed is encapsulated here.
        vm.expectEmit(false, false, false, true);
        emit DataUpdated(sender.msg);
        
        
        instance.updateData();
    }
}


```