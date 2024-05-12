## USDC gasless sender

***Enable send USDC gasless and the user don't have to pay gas fees and with the relayer you pay using USDC***

### How it works

The user will sign an off-chain permit signature allowing the token contract to spend and send specified amount of USDC.

The function arguments, along with the signature, are submitted to Gelato using the Gelato Relay SDK and are executed on-chain by a relayer.


## Contracts
```
src
    ├─ Sender -> Enable send USDC gasless with ERC2771
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

