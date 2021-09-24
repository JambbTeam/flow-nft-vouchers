# Vouchers.cdc
## Redeemable Voucher Contract

## Implementation Overview
### Vouchers
Vouchers are a fork of the CategorizedCollectibles concept where there is shared metadata across a given type of collectible, but with the added functionality of being able to Redeem your Voucher NFT and an admin can Consume it - to hopefully give you a reward in return ;) 
### Workflow
- Vouchers are Minted and sent to Users
- Collectibles are Minted and held by Admins
- Users Redeem their Vouchers for Rewards (which are described in plain text by the RedeemableMetadata)
- Admins consume the Redeemed Vouchers and send the Redeemer their deserved Reward*
-- A notable decision was made to withdraw the "force admin to pay reward when consuming" code that was originally here, because it was obtusely restrictive and if vouchers aren't being honored by a given distributor I don't see them getting many customers again... contract purists will call this centralized, I call it adequately managed :)

## Collectibles
Collectibles is a straight-forward implementation of an NFT featuring individualized metadata per NFT.
### Use-Case
Collectibles are ALL unique, and therefore should be used when there is not an overarching connection between them. They are a generic and simple implementation of an NFT.

### To Be Added - Transaction-by-transaction walkthrough, code clean-up & comment clean-up.
#### Open to comments & prs!