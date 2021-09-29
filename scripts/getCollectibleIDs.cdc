import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

pub fun main(address: Address): [UInt64]? {
    let collectionRef = getAccount(address).getCapability(Collectibles.CollectionPublicPath)
        .borrow<&{Collectibles.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    return collectionRef.getIDs()
}
