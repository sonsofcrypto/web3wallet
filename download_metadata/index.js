const { ethers } = require("ethers");
const { EtherscanProvider } = require("@ethersproject/providers");
const fs = require('fs');

apiKey = ""

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    let rawdata = fs.readFileSync('cache_currencies.json');
    let currencies = JSON.parse(rawdata);
    let count = currencies.length
    for (const [idx, currency] of currencies.entries()) {
        const address = currency['address']
        if (address != null) {
            const provider = new EtherscanProvider(network = 1, apiKey = apiKey)
            const abi = [ "function decimals() view returns (uint8)" ];
            const erc20 = new ethers.Contract(address, abi, provider);
            const decimals = await erc20.decimals();
            process.stdout.write(idx + "/" + count + " " + decimals + "     \r")
            if (decimals != 18) {
                currency['decimals'] = decimals
                let data = JSON.stringify(currencies);
                fs.writeFileSync('tmp_step_08.json', data);
            }
            await sleep(210);
        }
    }
    let data = JSON.stringify(currencies);
    fs.writeFileSync('cache_currencies.json', data);
}

main()