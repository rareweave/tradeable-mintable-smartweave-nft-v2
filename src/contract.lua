
local transfer = require("functions/transfer")
local list = require("functions/list")
local balance = require("functions/balance")
local reserveBuyingZone = require("functions/reserve-buying-zone")
local unlist = require("functions/unlist")
local finalizeBuy = require("functions/finalize-buy")
local editNft = require("functions/edit-nft")
BN = require("bn")

function handle(state, action) 
  if (not action.input) or (type(action.input) == 'table') or (type(action.input["function"]) == 'string') then
    ContractError("Invalid input")
  end
  local functionMap={
    transfer=transfer,
    list=list,
    balance=balance,
    ["reserve-buying-zone"]=reserveBuyingZone,
    unlist=unlist,
    ["finalize-buy"]=finalizeBuy,
    ["edit-nft"]=editNft
  }
  local selectedFunction = functionMap[action.input["function"]]
  if not selectedFunction then
    error("Function "+action.input["function"]+" not found")
  end
  local res
  local status,err=pcall(function ()
    res = selectedFunction(state,action)
  end)
  if not status then
    return res
  else
    error(err)
  end
end
