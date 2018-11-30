// browserify index.js --standalone script > eos.js
module.exports = {
    /**
     * 
     * @param {Object} params = {chainId: String, transaction: Object, privateKey: String, method: Object}
     */
    pack: function(params) {
        try{
            function methodNameToAbi(method) {
                let name  = method.split('(')[0] // "transfer"
                let regex = /\((.*)\)/
                let args  = method.match(regex)[1] // "to:name,quantity:asset"
                    .split(',') // ["to:name","quantity:asset]
                    .map(x => x.split(':')) // [["to","name"],["quantity","asset"]]
                    .map(x => ({ type: x.pop(), name: x.length ? x.pop() : undefined }))
                return {
                    version: "eosio::abi/1.0",
                    types: [],
                    structs: [{
                        name: name,
                        base: "",
                        fields: args
                    }],
                    actions: [{
                        name: name,
                        type: name,
                        ricardian_contract: ""
                    }],
                    tables: [],
                    ricardian_clauses: [],
                    abi_extensions: []
                }
            }

            const { Api, JsSignatureProvider, Serialize } = require('eosjs')
            const { TextDecoder, TextEncoder } = require('text-encoding')

            const api = new Api({
                chainId: params.chainId,
                signatureProvider: new JsSignatureProvider([params.privateKey]),
                textDecoder: new TextDecoder(), 
                textEncoder: new TextEncoder()
            });

            // convert abi in json form to binary form
            const abiDefinition = api.abiTypes.get(`abi_def`)
            var abi = abiDefinition.fields.reduce(
                (acc, { name: fieldName }) =>
                  Object.assign(acc, { [fieldName]: acc[fieldName] || [] }),
                methodNameToAbi(params.method)
            )
            const buffer = new Serialize.SerialBuffer({
                textEncoder: api.textEncoder,
                textDecoder: api.textDecoder,
            })
            abiDefinition.serialize(buffer, abi)
            const abiRawHex = Buffer.from(buffer.asUint8Array()).toString(`hex`)

            // specify local authority provider for working offline
            api.authorityProvider = {
                getRequiredKeys: function(args) {
                    return api.signatureProvider.getAvailableKeys()
                }
            }

            // specify local abi provider for working offline
            api.abiProvider = {
                getRawAbi: function(accountName) {
                    return new Promise(function(resolve, reject) {
                        resolve({
                            accountName: accountName,
                            abi: Serialize.hexToUint8Array(abiRawHex)
                        })
                    })
                },
            }

            // generate transaction
            api.transact(params.transaction, { broadcast: false }).then(function(result) {
                return {
                    signatures: [result.signatures[0]],
                    compression: 0,
                    packed_context_free_data: "",
                    packed_trx: Serialize.arrayToHex(result.serializedTransaction)
                }
            }).then(function(tx) {
                // ios.report(JSON.stringify(tx))
                console.ios(JSON.stringify(tx))
            })
            return true
        } catch (e) {
            console.log(e)
            return e
        }
    }
}