import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Collectibles from "../contracts/Collectibles.cdc"

/** Sample Metadata Struct
Collectibles.Metadata(
    name: "A Very Unique and Special Name",
    description: "This NFT is one-of-a-kind, probably",
    mediaType: "image/png",
    mediaHash: "0x64EC88CA00B268E5BA1A35678A1B5316D212F4F366B2477232534A8AECA37F3C",
    mediaURI: "https://static.wikia.nocookie.net/pixar/images/a/aa/Nemo-FN.png"
)
**/
transaction(count: Int, metadata: [String]) {
    let minter: &Collectibles.NFTMinter
    let nftCollectionRef: &{NonFungibleToken.CollectionPublic}
    let collectibleMetadata: Collectibles.Metadata
    prepare(signer: AuthAccount) {
        self.minter = signer
            .borrow<&Collectibles.NFTMinter>(from: Collectibles.MinterStoragePath)
            ?? panic("Signer is not the admin")

        self.nftCollectionRef = signer.borrow<&{NonFungibleToken.CollectionPublic}>(from: Collectibles.CollectionStoragePath)!
        
        // this is hokey, but functional for the time being, but not tenable for long-term pattern
        self.collectibleMetadata = Collectibles.Metadata(name: metadata[0], description: metadata[1], 
            mediaType: metadata[2], mediaHash: metadata[3], mediaURI: metadata[4])
    }
    execute {
        var i = 0
        while i < count {
            self.minter.mintNFT(recipient: self.nftCollectionRef, metadata: self.collectibleMetadata)
            i = i + 1
        }
    }
}
 