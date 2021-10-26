import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

// DEV WARNING: THIS TRANSACTION DOES NOT CHECK FOR ID EXISTING OR NOT AND DOES NOT UPDATE METADATA
// YOU MUST ESTABLISH METADATA USING: registerVoucherMetadata.cdc
transaction(count: Int, typeID: UInt64) {
    prepare(signer: AuthAccount) {
        let proxy = signer
            .borrow<&Vouchers.AdminProxy>(from: Vouchers.AdminProxyStoragePath)
            ?? panic("Signer has no Admin Proxy")
        let minter = proxy.borrowSudo()

        let recipCollection = signer.borrow<&{NonFungibleToken.CollectionPublic}>
            (from: Vouchers.CollectionStoragePath)!
        
        minter.batchMintNFT(recipient: recipCollection, typeID: typeID, count: count)
    }
}
 
