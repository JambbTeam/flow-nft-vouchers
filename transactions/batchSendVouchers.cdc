import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction(recipient: Address, withdrawStartingID: UInt64, count: Int) {
    let adminCollection: &Vouchers.Collection
    let recipient: &{Vouchers.CollectionPublic}
    prepare(signer: AuthAccount) {
        // get the recipients public account object
        self.recipient = getAccount(recipient).getCapability(Vouchers.CollectionPublicPath).borrow<&{Vouchers.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipient's collection")

        // borrow a reference to the signer's NFT collection
        self.adminCollection = signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the signer's collection")
    }

    execute {
        var i = 0
        var id = withdrawStartingID
        while i < count {
            // Deposit the NFT in the recipient's collection
            self.recipient.deposit(token: <- self.adminCollection.withdraw(withdrawID: id))
            i = i + 1
            id = id + 1
        }
    }
}