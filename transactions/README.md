# Transaction Overview
Note: Init steps at bottom

## Vouchers Redemption & Consumption Workflow
This is the primary workflow that this contract was built to support, where
a User can Redeem a Voucher that an Admin created and will supposedly Reward
them when their Voucher is inevitably Consumed.

### Redeem Voucher
Withdraws from Voucher Collection and sends to the RedeemedCollection for Consumption
```
flow transactions send ./transactions/redeemVoucher.cdc <voucherID>
```

### Consume Voucher
#### Admin-Called, Must deliver Reward from Admin-controlled CollectiblesCollection
Admin grabs Reward from CollectiblesCollection and sends to Receiver while consuming 
their Voucher from the contract's RedeemedCollection
```
flow transactions send ./transactions/consumeVoucher.cdc <voucherID> `[rewardID1, rewardID2, ...]`
```

## Init Steps
### Setup Vouchers, Collectibles and AdminProxy
```
flow transactions send ./transactions/setupVouchers.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000

flow transactions send ./transactions/setupCollectibles.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000

flow transactions send ./transactions/setupVouchersAdminProxy.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000
```

### Admin Grants sudo
```
flow transactions send ./transactions/activateAdminProxy.cdc <proxyReceiverAddress> \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000
```

## Mint Vouchers and Collectibles
### they take arrays of strings as metadata for now
```
flow transactions send ./transactions/mintVouchers.cdc <numToMint> <typeID> '["name","descrip","mediaType","mediaHash","mediaURI"]' --signer <admin-signer>

flow transactions send ./transactions/mintCollectible.cdc '["name","descrip","mediaType","mediaHash","mediaURI"]' --signer <admin-signer>
```