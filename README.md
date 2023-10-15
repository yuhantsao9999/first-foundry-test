## how to run test

### clone

```shell
$ git clone https://github.com/andylinee/aws-smart-contract.git
```

### find WETH.t.sol

```shell
$ cd test
```

### Test

```shell
$ forge test
```

### (Optional) Run test for specific Test function

// forge test --mt {Test function name} -vvv
example: forge test --mt test_Deposit_should_transfer_correct_ether_amount -vvv
