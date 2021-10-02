import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

transaction(voucherID: UInt64, rewardIDs: [UInt64]) {
    
    // this transaction can only be called by Vouchers.Administrator account
    prepare(admin: AuthAccount) {
        // establish administrative resource => make this use the Proxy instead for regular admins
        let administrator = admin.borrow<&Vouchers.Administrator>(from: Vouchers.AdministratorStoragePath)!
        
        // consume their voucher and get their address
        let redeemer = administrator.consume(voucherID)

        // get the recipients public account object
        let recipient = getAccount(redeemer)

        // borrow a public reference to the receivers collection
        let receiver = recipient.getCapability(Collectibles.CollectionPublicPath).borrow<&{Collectibles.CollectionPublic}>() 
            ?? panic("Could not borrow a reference to the recipient's collection")

        // get admin's Collection
        let adminCollection = admin.borrow<&NonFungibleToken.Collection>(from: Collectibles.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the admin's collection")
       
        // redeemer is deposited [NFT.rewardIDs] from admin's Collection
        for rewardID in rewardIDs {
            receiver.deposit(token: <- adminCollection.withdraw(withdrawID: rewardID))
        }
    }
}