import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Collectibles.Collection>(from: Collectibles.CollectionStoragePath) == nil {

            let collection <- Collectibles.createEmptyCollection() as! @Collectibles.Collection

            signer.save(<-collection, to: Collectibles.CollectionStoragePath)

            signer.link<&{Collectibles.CollectionPublic, NonFungibleToken.Receiver}>(
                Collectibles.CollectionPublicPath,
                target: Collectibles.CollectionStoragePath)
        }
    }
}
