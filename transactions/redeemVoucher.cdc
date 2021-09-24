import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction(voucherID: UInt64) {
    prepare(signer: AuthAccount) {
        // get the recipients public account object
        let redeemer = signer.address

        // borrow a reference to the signer's NFT collection
        let vouchers = signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's voucher")

        let nft <- vouchers.withdraw(withdrawID: voucherID) as! @Vouchers.NFT

        Vouchers.redeem(token: <- nft, address: redeemer)
    }
}