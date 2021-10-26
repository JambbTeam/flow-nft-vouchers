package main

import (
	"github.com/bjartek/go-with-the-flow/v2/gwtf"
	"github.com/onflow/cadence"
)

func main() {

	//this starts in emulator
	g := gwtf.NewGoWithTheFlowEmulator().InitializeContracts().CreateAccounts("emulator-account")
	//this starts with emulator running in same process
	//	g = gwtf.NewGoWithTheFlowInMemoryEmulator()

	g.TransactionFromFile("setupVouchers").SignProposeAndPayAsService().RunPrintEventsFull()
	g.TransactionFromFile("setupCollectibles").SignProposeAndPayAsService().RunPrintEventsFull()
	g.TransactionFromFile("setupVouchersAdminProxy").SignProposeAndPayAsService().RunPrintEventsFull()

	//here we just use the sa itself as the proxy
	g.TransactionFromFile("activateAdminProxy").SignProposeAndPayAsService().AccountArgument("account").RunPrintEventsFull()

	var typeId uint64 = 1
	metadata := []cadence.Value{
		cadence.NewString("A very Unique and Special Name"),
		cadence.NewString("This NFT is one-of-a-kind, probably"),
		cadence.NewString("image/png"),
		cadence.NewString("0x64EC88CA00B268E5BA1A35678A1B5316D212F4F366B2477232534A8AECA37F3C"),
		cadence.NewString("https://static.wikia.nocookie.net/pixar/images/a/aa/Nemo-FN.png")}

	g.TransactionFromFile("registerVoucherMetadata").
		SignProposeAndPayAsService().
		UInt64Argument(typeId).
		Argument(cadence.NewArray(metadata)).
		RunPrintEventsFull()

	g.TransactionFromFile("mintVouchers").
		SignProposeAndPayAsService().
		IntArgument(10).
		UInt64Argument(typeId).
		RunPrintEventsFull()

	g.TransactionFromFile("mintCollectible").
		SignProposeAndPayAsService().
		Argument(cadence.NewArray(metadata)).
		RunPrintEventsFull()

	//setup user

	var voucherId uint64 = 0
	g.TransactionFromFile("setupCollectibles").SignProposeAndPayAs("user1").RunPrintEventsFull()
	g.TransactionFromFile("setupVouchers").SignProposeAndPayAs("user1").RunPrintEventsFull()

	var collectibleId uint64 = 0
	g.TransactionFromFile("sendVoucher").SignProposeAndPayAsService().AccountArgument("user1").UInt64Argument(voucherId).RunPrintEventsFull()

	g.TransactionFromFile("redeemVoucher").SignProposeAndPayAs("user1").UInt64Argument(voucherId).RunPrintEventsFull()

	rewards := []cadence.Value{cadence.NewUInt64(collectibleId)}
	g.TransactionFromFile("consumeVoucher").
		UInt64Argument(voucherId).
		Argument(cadence.NewArray(rewards)).
		SignProposeAndPayAsService().
		RunPrintEventsFull()

}
