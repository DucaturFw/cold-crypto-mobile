const { JsonRpc, Serialize } = require('eosjs');
const fetch = require('node-fetch');
const script = require("./index");

(async function() {
    const rpc   = new JsonRpc('http://jungle.eosgen.io:80', { fetch });
    const info  = await rpc.get_info();
    const block = await rpc.get_block(info.head_block_num - 3);
    var fromServer = {
        method: "transfer(from:name,to:name,quantity:asset,memo:string)",
        chainId: "e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473",
        transaction: {
            actions: [{
                account: 'eosio.token',
                name: 'transfer',
                authorization: [{
                    actor: 'cryptoman111',
                    permission: 'active',
                }],
                data: {
                    from: 'cryptoman111',
                    to: 'cryptoman222',
                    quantity: '0.0002 EOS',
                    memo: 'example',
                }
            }]
        }
    }
    fromServer.transaction = { ...Serialize.transactionHeader(block, 30), ...fromServer.transaction }
    console.log("\n\n")
    console.log(JSON.stringify(fromServer))
    console.log("\n\n")

    const tx = await client.pack({
        method: fromServer.method,
        chainId: fromServer.chainId,
        privateKey: "5JhtgJUTWL5ftQdCQJar2NxV6mWh3ogkeFtjcNV5yoJ9dpQsQhT",
        transaction: fromServer.transaction
    })

    console.log("\n\n")
    console.log(tx)
    console.log("\n\n")
})()