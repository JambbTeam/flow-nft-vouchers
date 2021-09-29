import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

pub fun main(address: Address): {UInt64: Vouchers.Metadata} {
    let collectionRef = getAccount(address).getCapability(Vouchers.CollectionPublicPath)
        .borrow<&{Vouchers.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
   
    var vouchers: {UInt64: Vouchers.Metadata} = {}
    for id in ids {
        let voucher = collectionRef.borrowVoucher(id: id)
            ?? panic("Could not find that Voucher in your Collection")
        let metadata = voucher.getMetadata()!
        vouchers[id] = metadata
    }
    return vouchers
}
