import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

pub fun main(address: Address, voucherID: UInt64): Vouchers.Metadata? {
    let collectionRef = getAccount(address).getCapability(Vouchers.CollectionPublicPath)
        .borrow<&{Vouchers.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
    let voucher = collectionRef.borrowVoucher(id: ids[voucherID])
        ?? panic("Could not find that Voucher in your Collection")

    return voucher.getMetadata()
}
