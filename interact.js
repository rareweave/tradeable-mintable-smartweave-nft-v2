const fs = require("fs");
const path = require("path");
const Arweave = require("arweave");
const prompt=require("prompt")
const jwk = require("./.secrets/jwk.json");
const Bundlr=require("@bundlr-network/client")
const bundlr = new Bundlr("http://node2.bundlr.network", "arweave", jwk);
// Arweave initialization
prompt.start();
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
    console.log(`Interacting from ${walletAddress}`);
    const tags= [{ name: "Content-Type", value: "application/json"},
    {name:"App-Name",value:"SmartWeaveAction"},
    {name:"SDK",value:"Glome"},
    {name:"App-Version",value:"0.3.0"},
    {name:"Contract",value:(await prompt.get(['Contract'])).Contract},
    {name:"Input",value:(await prompt.get(['Input'])).Input}]
    const tx=await bundlr.upload("Glome contract call",{tags})
   
    console.log(`Deployment completed.\nDeployer: ${walletAddress}\nInteraction ID: ${tx.id}`);

  } catch (error) {
    console.error("Failed to deploy contract:", error);
  }
}

deployContract();
