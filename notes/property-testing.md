# Property Testing

You can convert a test to a property test by adding an argument to the test function where the 
value of the argument corresponds to value you're using to check against in the test.

```solidity
function testSomethingOverAnAmount(uint96 val) {
    // constrain property to greater than ether.
    vm.assume(val > 0.1 ether);
}

function testSomethingUnderAnAmount(uint96 val) {
    // constrain property to less than ether.
    vm.assume(val < 0.1 ether);
}
```