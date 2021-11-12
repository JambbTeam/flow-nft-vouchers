import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

pub fun main(address: Address): [UInt64]? {
    let collectionRef = getAccount(address).getCapability(Vouchers.RedeemedCollectionPublicPath)
        .borrow<&{Vouchers.CollectionPublic}>()
        ?? panic("Could not borrow RedeemedCollectionPublic capability")

    return collectionRef.getIDs()
}
