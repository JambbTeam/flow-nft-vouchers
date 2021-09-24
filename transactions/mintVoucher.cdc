import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&Vouchers.AdminProxy>(from: Vouchers.AdminProxyStoragePath)
            ?? panic("Signer has no Admin Proxy")

        let recipCollection = signer.borrow<&{NonFungibleToken.CollectionPublic}>(from: Vouchers.CollectionStoragePath)!

        // DEV-NOTE:: update these with args in FCL transaction use
        let metadata: Vouchers.RedeemableMetadata = Vouchers.RedeemableMetadata(
            name: "Test Voucher",
            description: "Voucher descrip",
            mediaType: "image/png",
            mediaHash: "hash",
            mediaURI: "mediaURI.com"
        )
        // DEV-NOTE:: use type arg, could batch mint etc...
        minter.mintNFT(recipient: recipCollection, redeemableType: 0)
        minter.registerRedeemableMetadata(redeemableType:0, redeemableMetadata: metadata)
    }
}
