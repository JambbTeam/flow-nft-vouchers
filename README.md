# Vouchers.cdc
#### A Redeemable Voucher Contract

### Implementation Overview
#### Vouchers
Vouchers implement the concept of shared metadata across a given type (per-ID), but with the added functionality of being able to Redeem your 'Voucher' NFT and an Admin can Consume it and grant them a Reward.

It uses the NFT standard and has no dependency on Collectibles as its reward type, that is merely what is used in the transaction examples given. 
It is intended to be used for any workflow that involves a user redeeming a transient asset, supposedly for something in return.

### Redeem & Consume Workflow
- Vouchers are Minted and sent to Users
- Collectibles are Minted and held by Admins
- Users Redeem their Vouchers (which are described in plain text by the per-type Metadata)
- Admins consume the Redeemed Vouchers and send the Redeemer their deserved Reward
  - A notable decision was made to remove some "force admin to pay reward when consuming" code that was originally here, because it was obtusely restrictive it can be adequately managed as-is
  - They do receive the Redeemer address when consuming, so it would be hard to ignore
  the redeemer after that ;)

### Collectibles
#### Sample NFT for Rewarding in Tests
Collectibles is a straight-forward implementation of an NFT featuring individualized metadata per NFT.
