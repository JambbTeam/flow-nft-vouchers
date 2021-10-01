import NonFungibleToken from "./standard/NonFungibleToken.cdc"

pub contract Vouchers: NonFungibleToken {
    // Public Events
    // Basics
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64)

    // Voucher Actions
    // Redeemed: Address to grant reward after consume
    pub event Redeemed(id: UInt64, from: Address?) 
    // Consumed: Notice, Reward is not tracked. This is to simplify contract.
    // It is to be administered in the consume() tx, else thoust be punished by thine users.
    pub event Consumed(id: UInt64)

    // Public Voucher Collection Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    // Contract Singletone Redeemed Voucher Collection
    pub let RedeemedCollectionPublicPath: PublicPath
    pub let RedeemedCollectionStoragePath: StoragePath

    // AdminUser Proxy Receiver
    pub let AdminProxyStoragePath: StoragePath
    pub let AdminProxyPublicPath: PublicPath

    // Contract Owner Root Administrator Resource
    pub let AdministratorStoragePath: StoragePath
    pub let AdministratorPrivatePath: PrivatePath

    // totalSupply
    // The total number of Vouchers that have been minted
    //
    pub var totalSupply: UInt64

    // 
    access(contract) var metadata: {UInt64: Metadata}

    // Voucher Type Metadata Definitions
    // 
    pub struct Metadata {
        pub let name: String
        pub let description: String
        // MIME type: image/png, image/jpeg, video/mp4, audio/mpeg
        pub let mediaType: String 
        // IPFS storage hash
        pub let mediaHash: String
        // URI to NFT media - incase IPFS not in use/avail
        pub let mediaURI: String

        init(name: String, description: String, mediaType: String, mediaHash: String, mediaURI: String) {
            self.name = name
            self.description = description
            self.mediaType = mediaType
            self.mediaHash = mediaHash
            self.mediaURI = mediaURI
        }
    }

    // redeem
    // a Voucher-holder can redeem their Voucher by depositing it into
    // the Redeemed Collection of the admins of this contract
    pub fun redeem(token: @Vouchers.NFT, address: Address) {
         // emit redemption
        emit Redeemed(id:token.id, from: address)
        
        // establish the receiver for Redeeming Vouchers
        let receiver = Vouchers.account.getCapability<&{Vouchers.CollectionPublic}>(Vouchers.RedeemedCollectionPublicPath).borrow()!
        
        // deposit for consumption & reward
        receiver.deposit(token: <- token)
    }

    // NFT
    // Voucher
    //
    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID
        pub let id: UInt64

        // The token's typeID
        pub let typeID: UInt64

        // Expose metadata
        pub fun getMetadata(): Metadata? {
            return Vouchers.metadata[self.typeID]
        }

        // initializer
        //
        init(initID: UInt64, typeID: UInt64) {
            self.id = initID
            self.typeID = typeID
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowVoucher(id: UInt64): &Vouchers.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Vouchers reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of Vouchers NFTs owned by an account
    //
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Vouchers.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowVoucher
        // Gets a reference to an NFT in the collection as a Vouchers.NFT,
        // exposing all of its fields.
        // This is safe as there are no functions that can be called on the Vouchers.
        //
        pub fun borrowVoucher(id: UInt64): &Vouchers.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Vouchers.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // AdminProxy
    //
    // AdminProxy is a 1:1 shim for the Administrator resource, of which
    // only one exists, and it is managed by the Contract Owner.
    // 
    // Prospective AdminUsers will create a Proxy and be granted
    // access to the Administrator resource through their receiver.
    // They will then simply route like-calls to that resource, which will
    // perform the ultimately privileged actions.
    //
    pub fun createAdminProxy(): @AdminProxy { 
        return <- create AdminProxy()
    }
    
    pub resource interface AdminProxyPublic {
        pub fun addCapability(_ cap: Capability<&Vouchers.Administrator>)
    }

    pub resource AdminProxy: AdminProxyPublic {
        access(self) var sudo: Capability<&Vouchers.Administrator>?
        init () {
            self.sudo = nil
        }

        // must receive capability to take administrator actions
        pub fun addCapability(_ cap: Capability<&Vouchers.Administrator>){ 
            pre {
                cap.check() : "Invalid Administrator capability"
                self.sudo == nil : "Administrator capability already set"
            }
            self.sudo = cap
        }

        //
        // these are direct passthroughs to the actual administrator resource
        //

        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, typeID: UInt64) {
            pre {
                self.sudo != nil : "Your AdminProxy has no Administrator capabilities."
            }
            self.sudo!.borrow()!.mintNFT(recipient: recipient, typeID: typeID)
        }

        pub fun consume(_ voucherID: UInt64) {
            pre {
                self.sudo != nil : "Your AdminProxy has no Administrator capabilities."
            }
            self.sudo!.borrow()!.consume(voucherID)
        }

        pub fun registerMetadata(typeID: UInt64, metadata: Metadata) {
            pre {
                self.sudo != nil : "Your AdminProxy has no Administrator capabilities."
            }
            self.sudo!.borrow()!.registerMetadata(typeID: typeID, metadata: metadata)
        }
    }

    // Administrator - Root-owned resource, Privately grants Capabilities to Public Receivers
    pub resource Administrator {
        // mintNFT
        // Mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        //
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, typeID: UInt64) {
            emit Minted(id: Vouchers.totalSupply)

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <- create Vouchers.NFT(initID: Vouchers.totalSupply, typeID: typeID))
            Vouchers.totalSupply = Vouchers.totalSupply + (1 as UInt64)
        }

        // batchMintNFT
        // Mints a batch of new NFTs
        // and deposit it in the recipients collection using their collection reference
        //
        pub fun batchMintNFT(recipient: &{NonFungibleToken.CollectionPublic}, typeID: UInt64, count: Int) {
            var index = 0
        
            while index < count {
                self.mintNFT(
                    recipient: recipient,
                    typeID: typeID
                )

                index = index + 1
            }
        }

        // registerMetadata
        // Registers metadata for a typeID
        //
        pub fun registerMetadata(typeID: UInt64, metadata: Metadata) {
            Vouchers.metadata[typeID] = metadata
        }

        // consume
        // consumes a Voucher from the Redeemed Collection by destroying it
        // NOTE: it is expected the consumer also rewards the redeemer their due
        //          in the case of this repository, an NFT is included in the consume transaction
        pub fun consume(_ voucherID: UInt64) {
            // grab the voucher from the redeemed collection
            let redeemedCollection = Vouchers.account.borrow<&Vouchers.Collection>(from: Vouchers.RedeemedCollectionStoragePath)!
            let voucher <- redeemedCollection.withdraw(withdrawID: voucherID)!
            
            // discard the empty collection and the voucher
            destroy voucher

            emit Consumed(id:voucherID)
        }
    }

    // fetch
    // Get a reference to a Vouchers from an account's Collection, if available.
    // If an account does not have a Vouchers.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &Vouchers.NFT? {
        let collection = getAccount(from)
            .getCapability(Vouchers.CollectionPublicPath)!
            .borrow<&Vouchers.Collection>()
            ?? panic("Couldn't get collection")
        // We trust Vouchers.Collection.borrowVoucher to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowVoucher(id: itemID)
    }

    // getMetadata
    // Get the metadata for a specific  of Vouchers
    //
    pub fun getMetadata(typeID: UInt64): Metadata? {
        return Vouchers.metadata[typeID]
    }

    // initializer
    //
    init() {
        // these paths are for any user to hold a Collection of Vouchers
        self.CollectionStoragePath = /storage/vouchersCollection
        self.CollectionPublicPath = /public/vouchersCollection
		
        // only one redeemedCollection should ever exist, in the Administrator/Root storage
        self.RedeemedCollectionStoragePath = /storage/redeemedCollection
        // the public path will only be for nft deposits
        self.RedeemedCollectionPublicPath = /public/redeemedCollection
        
        self.AdministratorStoragePath = /storage/vouchersAdministrator
        self.AdministratorPrivatePath = /private/vouchersAdministrator

        self.AdminProxyPublicPath = /public/adminProxy
        self.AdminProxyStoragePath = /storage/adminProxy

        // Initialize the total supply
        self.totalSupply = 0

        // Initialize predefined metadata
        self.metadata = {}

        // Create a NFTAdministrator resource and save it to storage
        let admin <- create Administrator()
        self.account.save(<- admin, to: self.AdministratorStoragePath)
        // Link it to provide shareable access route to capabilities
        self.account.link<&Vouchers.Administrator>(self.AdministratorPrivatePath, target: self.AdministratorStoragePath)

        // this contract will hold a Collection that Vouchers can be deposited to and Admins can Consume them to grant rewards
        // to the depositing account
        let redeemedCollection <- create Collection()
        // establish the collection users redeem into
        self.account.save(<- redeemedCollection, to: self.RedeemedCollectionStoragePath) 
        // set up a public link to the redeemed collection so they can deposit/view
        self.account.link<&{Vouchers.CollectionPublic}>(self.RedeemedCollectionPublicPath, target: self.RedeemedCollectionStoragePath)
        // set up a private link to the redeemed collection as a resource, so 

        // create a personal collection just in case contract ever holds Vouchers to distribute later etc
        let collection <- create Collection()
        self.account.save(<- collection, to: self.CollectionStoragePath)
        self.account.link<&{Vouchers.CollectionPublic}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
        
        emit ContractInitialized()
    }
}
 
