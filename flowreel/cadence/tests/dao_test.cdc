import Test

access(all) let account = Test.createAccount()

access(all) fun testContract() {
    let err = Test.deployContract(
        name: "dao",
        path: "../contracts/dao.cdc",
        arguments: [],
    )

    Test.expect(err, Test.beNil())
}