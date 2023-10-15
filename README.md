## How to run test

### Clone repo

```shell
$ git clone https://github.com/yuhantsao9999/first-foundry-test.git
```

### Find the repo and WETH.t.sol

```shell
$ cd first-foundry-test
$ cd test
```

### Test

```shell
$ forge test
```

### (Optional) Run test for specific Test function

```shell
// forge test --mt {Test function name} -vvv
example:
$ forge test --mt test_Deposit_should_transfer_correct_ether_amount -vvv
```
