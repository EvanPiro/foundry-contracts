# Testing Cheatcodes

You can hack the EVM test chain to force certain circumstances using the `vm` namespace within test functions.

```solidity
  function testSomething() {
    // Switch to different address.
    vm.prank(address(0));
  }
```