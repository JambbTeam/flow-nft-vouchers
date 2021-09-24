import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction(typeID: UInt64) {
    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&Vouchers.AdminProxy>(from: Vouchers.AdminProxyStoragePath)
            ?? panic("Signer has no Admin Proxy")

        let recipCollection = signer.borrow<&{NonFungibleToken.CollectionPublic}>(from: Vouchers.CollectionStoragePath)!

        // DEV-NOTE:: update these with args in FCL transaction use
        let metadata: Vouchers.Metadata = Vouchers.Metadata(
            name: "Test Vouchers Metadata",
            description: "Description of this group of Vouchers",
            mediaType: "image/png",
            mediaHash: "hash",
            mediaURI: "mediaURI.com"
        )
        // DEV-NOTE:: use type arg, could batch mint etc...
        minter.mintNFT(recipient: recipCollection, typeID: typeID)
        minter.registerMetadata(typeID:typeID, metadata: metadata)
    }
}
