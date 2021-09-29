import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Vouchers.AdminProxy>(from: Vouchers.AdminProxyStoragePath) == nil {
            // maybe dont do this by default haha but its harmless mostly
            let adminProxy <- Vouchers.createAdminProxy()

            signer.save(<-adminProxy, to: Vouchers.AdminProxyStoragePath)

            // link receiver for admin to activate me as a proxy
            signer.link<&{Vouchers.AdminProxyPublic}>(
                Vouchers.AdminProxyPublicPath, 
                target: Vouchers.AdminProxyStoragePath)
        }
    }
}
