import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

// transaction(recipients: [Address], withdrawIDs: [UInt64]) { TODO
transaction () { // TESTING THROUGHPUT
    let adminCollection: &Vouchers.Collection
    let recipient: &{Vouchers.CollectionPublic}
    prepare(signer: AuthAccount) {
        // get the recipients public account object
        self.recipient = getAccount(0xe94a6e229293f196).getCapability(Vouchers.CollectionPublicPath).borrow<&{Vouchers.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipient's collection")

        // borrow a reference to the signer's NFT collection
        self.adminCollection = signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the signer's collection")
    }

    execute {
        var i = 0
        while i < 500 {
            // Deposit the NFT in the recipient's collection
            self.recipient.deposit(token: <- self.adminCollection.withdraw(withdrawID: UInt64(i)))
            i = i + 1
        }
    }
}