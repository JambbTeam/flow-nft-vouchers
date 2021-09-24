import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

pub fun main(address: Address): Collectibles.Metadata? {
    let collectionRef = getAccount(address).getCapability(Collectibles.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic, Collectibles.CollectionPublic}>()
        ?? panic("Could not borrow collection public reference")

    let ids = collectionRef.getIDs()
    let collectible = collectionRef.borrowCollectible(id: ids[0])!

    return collectible.getMetadata()
}
