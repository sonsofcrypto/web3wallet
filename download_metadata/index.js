const { ethers } = require("ethers");
const { EtherscanProvider } = require("@ethersproject/providers");
const fs = require('fs');
require('dotenv').config()

apiKey = process.env.ETHER_SCAN

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    let rawdata = fs.readFileSync('cache_currencies.json');
    let currencies = JSON.parse(rawdata);
    let count = currencies.length
    let failed = []
    for (const [idx, currency] of currencies.entries()) {
        const address = currency['address']
        if (address != null) {
            try {
                const provider = new EtherscanProvider(network = 1, apiKey = apiKey)
                const abi = [ "function decimals() view returns (uint8)" ];
                const erc20 = new ethers.Contract(address, abi, provider);
                const decimals = await erc20.decimals();
                process.stdout.write(idx + "/" + count + " " + decimals + " \r")
                if (decimals != 18) {
                    currency['decimals'] = decimals
                    let data = JSON.stringify(currencies);
                    fs.writeFileSync('tmp_step_08.json', data);
                }
            }
            catch(e) {
                let msg = idx + "/" + count + " " + currency['coingGeckoId'] + " \r"
                process.stdout.write(msg)
                failed.push(currency)
            }
            await sleep(210);
        }
    }

    let data = JSON.stringify(currencies);
    fs.writeFileSync('cache_currencies_with_decimals.json', data);

    for (const currency in failed) {
        console.log(currency)
    }

    console.log("Failed count:" + failed.length)
}

main()