import Vouchers from "../contracts/Vouchers.cdc"

pub fun main(address: Address): Int {
    let collectionRef = getAccount(address).getCapability(Vouchers.CollectionPublicPath)
        .borrow<&{Vouchers.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    return collectionRef.getIDs().length
}
