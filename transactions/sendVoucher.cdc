import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction(recipient: Address, withdrawID: UInt64) {
    prepare(signer: AuthAccount) {
        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a reference to the signer's NFT collection
        let collectionRef = signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the signer's collection")

        // borrow a public reference to the recipient collection
        let depositRef = recipient.getCapability(Vouchers.CollectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipient's collection")

        // withdraw the NFT from the signer's collection
        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}