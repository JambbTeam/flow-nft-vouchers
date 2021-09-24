import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath) == nil {

            let collection <- Vouchers.createEmptyCollection() as! @Vouchers.Collection

            signer.save(<-collection, to: Vouchers.CollectionStoragePath)

            signer.link<&{Vouchers.CollectionPublic}>(
                Vouchers.CollectionPublicPath,
                target: Vouchers.CollectionStoragePath)
            }
    }
}
