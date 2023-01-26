# Testing Contracts in Foundry

To write tests in Foundry, you need to write a contract that extends the `Foundry.sol` test contract. The functions 
that the test runner will run need to be prefixed with `test`, and `testFail`. Running `forge test` 
will execute the runner. `forge test --watch` 

```solidity
import "forge-std/test/Test.dol";

contract MyContractTest is Test {
    function setUp() {
        
    }
    
    function testExpectSuccess() {
        assertEq(/*...*/);
    }
    
    function testFailSomething() {
        // do something that should fail
    }
    
    function testCannotSomething() {
        vm.expectRevert(stdError.arithmeticError);
        // do something that will revert
    }
}
```