import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction(recipients: [Address], rewards: {Address: [UInt64]}) {
    let adminCollection: &Vouchers.Collection
    let recipientCollections: {Address: &{Vouchers.CollectionPublic}}
    prepare(signer: AuthAccount) {
        self.recipientCollections = {}
        // get the recipients public account object
        for address in recipients {
            self.recipientCollections[address] = getAccount(address).getCapability(Vouchers.CollectionPublicPath).borrow<&{Vouchers.CollectionPublic}>()
                ?? panic("Could not borrow a reference to the recipient's collection")
        }

        // borrow a reference to the signer's NFT collection
        self.adminCollection = signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the signer's collection")
    }

    execute {
        for address in recipients {
            if (rewards[address] != nil) {
                let rewards = rewards[address] as! [UInt64]
                for reward in rewards {
                    self.recipientCollections[address]!.deposit(token: <- self.adminCollection.withdraw(withdrawID: reward))
                }
            }
        }
    }
}
 