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

async function deployContract() {
  try {
    // Loading contract source and initial state from files
    const initialState = JSON.parse(fs.readFileSync(path.join(__dirname, "./init-state.json"), "utf8"))
    const walletAddress = await arweave.wallets.getAddress(jwk);
    const codeAddress=fs.readFileSync("./code_address","utf-8")
    console.log(`Deploying contract for address ${walletAddress}, contract source id: ${codeAddress}`);
    const tx=await arweave.createTransaction({data:"Glome contract deployment"}, jwk)
    tx.addTag("App-Name","SmartWeaveContract")
    tx.addTag("App-Version","0.3.0")
    tx.addTag("SDK","Glome")
    tx.addTag("Nonce",Date.now())
    tx.addTag("Contract-Src",codeAddress)
    tx.addTag("Content-Type","text/plain")
    tx.addTag("Init-State",JSON.stringify(initialState))
    // Deploying contract
    await arweave.transactions.sign(tx,jwk)
    await arweave.transactions.post(tx)
   
    console.log(`Deployment completed.\nDeployer: ${walletAddress}\nContract address: ${tx.id}`);

  } catch (error) {
    console.error("Failed to deploy contract:", error);
  }
}

deployContract();
