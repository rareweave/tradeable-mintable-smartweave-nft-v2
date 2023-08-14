const fs = require("fs");
const path = require("path");
const Arweave = require("arweave");
const jwk = require("./.secrets/jwk.json");


// Arweave initialization
const arweave = Arweave.init({
  host: "arweave.net",
  port: 443,
  protocol: "https",
});

async function deployCode() {
  try {
    // Loading contract source and initial state from files
    const contractSrc = fs.readFileSync(path.join(__dirname, "./bundle.lua"), "utf8");
    const initialState = JSON.parse(fs.readFileSync(path.join(__dirname, "./init-state.json"), "utf8"))

    const walletAddress = await arweave.wallets.getAddress(jwk);
    initialState.minter = walletAddress
    console.log(`Deploying contract for address ${walletAddress}`);
    const tx=await arweave.createTransaction({data:contractSrc}, jwk)
    tx.addTag("App-Name","SmartWeaveContractSource")
    tx.addTag("App-Version","0.3.0")
    tx.addTag("SDK","Glome")
    tx.addTag("Nonce",Date.now())
    tx.addTag("Content-Type","application/lua")
    // Deploying contract
    await arweave.transactions.sign(tx,jwk)
    await arweave.transactions.post(tx)
    fs.writeFileSync("code_address",tx.id)
    console.log(`Deployment completed.\nDeployer: ${walletAddress}\nContract code address: ${tx.id}`);

  } catch (error) {
    console.error("Failed to deploy contract:", error);
  }
}

deployCode();
