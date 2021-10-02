import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Vouchers from "../contracts/Vouchers.cdc"

transaction(proxy: Address) {
    prepare(admin: AuthAccount) {
        let proxyAcct = getAccount(proxy)
        let client = proxyAcct.getCapability<&{Vouchers.AdminProxyPublic}>(Vouchers.AdminProxyPublicPath)
            .borrow()!
        let adminCap = admin.getCapability<&Vouchers.Administrator>(Vouchers.AdministratorPrivatePath)
        client.addCapability(adminCap)
    }
}
