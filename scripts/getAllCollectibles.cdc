import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

pub fun main(address: Address): {UInt64: Collectibles.Metadata} {
    let collectionRef = getAccount(address).getCapability(Collectibles.CollectionPublicPath)
        .borrow<&{Collectibles.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
   
    var collectibles: {UInt64: Collectibles.Metadata} = {}
    for id in ids {
        let collectible = collectionRef.borrowCollectible(id: id)
            ?? panic("Could not find that Voucher in your Collection")
        let metadata = collectible.getMetadata()
        collectibles[id] = metadata
    }
    return collectibles
}
