import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

transaction() {

    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&Collectibles.NFTMinter>(from: Collectibles.MinterStoragePath)
            ?? panic("Signer is not the admin")

        let nftCollectionRef = signer.borrow<&{NonFungibleToken.CollectionPublic}>(from: Collectibles.CollectionStoragePath)!
        
        // DEV-NOTE:: update these with args in FCL transaction use
        let metadata: Collectibles.Metadata = Collectibles.Metadata(
            name: "Test NFT",
            description: "Description of Test NFT",
            mediaType: "image/png",
            mediaHash: "hash",
            mediaURI: "mediaURI.com"
        )

        minter.mintNFT(recipient: nftCollectionRef, metadata: metadata)
    }
}
