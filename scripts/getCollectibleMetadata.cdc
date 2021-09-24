import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

pub fun main(address: Address, collectibleID: UInt64): Collectibles.Metadata? {
    let collectionRef = getAccount(address).getCapability(Collectibles.CollectionPublicPath)
        .borrow<&{Collectibles.CollectionPublic}>()
        ?? panic("Could not borrow collection public reference")

    let ids = collectionRef.getIDs()
    let collectible = collectionRef.borrowCollectible(id: ids[collectibleID]) 
        ?? panic("Could not find that Collectible in your Collection")

    return collectible.getMetadata()
}
