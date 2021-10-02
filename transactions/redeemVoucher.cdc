import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

// this function includes initializations needed to handle 
// the Rewards they will get after redeeming
transaction(voucherID: UInt64) {
    prepare(signer: AuthAccount) {
        // if the account doesnt already have Collectibles setup
        if signer.borrow<&Collectibles.Collection>(from: Collectibles.CollectionStoragePath) == nil {
                let collection <- Collectibles.createEmptyCollection() as! @Collectibles.Collection

                signer.save(<-collection, to: Collectibles.CollectionStoragePath)

                signer.link<&{Collectibles.CollectionPublic, NonFungibleToken.Receiver}>(
                    Collectibles.CollectionPublicPath,
                    target: Collectibles.CollectionStoragePath)
        }
        
        // get the recipients public account object
        let redeemer = signer.address

        // borrow a reference to the signer's NFT collection
        let vouchers = signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's voucher")

        Vouchers.redeem(collection: vouchers, voucherID: voucherID)
    }
}