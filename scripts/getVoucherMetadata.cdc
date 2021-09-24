import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

pub fun main(address: Address): Vouchers.Metadata? {
    let collectionRef = getAccount(address).getCapability(Vouchers.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic, Vouchers.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
    let voucher = collectionRef.borrowVoucher(id: ids[0])!

    return voucher.getMetadata()
}
