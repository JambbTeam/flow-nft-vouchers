import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

// DISCLAIMER :: STRUCTS DONT WORK FROM CLI
// ONLY WORKS IN FCL
pub struct SharedVoucherMetadata { 
    pub let ids: [UInt64]
    pub let metadata: Vouchers.Metadata
    init(ids: [UInt64], metadata: Vouchers.Metadata) {
       self.ids = ids
       self.metadata = metadata
    }
}

pub fun main(address: String): SharedVoucherMetadata {
    let collectionRef = getAccount(Address.parseAddress(address)).getCapability(Vouchers.CollectionPublicPath)
        .borrow<&{Vouchers.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
    let sharedMetadata = SharedVoucherMetadata(ids: ids, metadata: collectionRef.borrowVoucher(id: ids[0])!.getMetadata()!)
    
    return sharedMetadata
}
