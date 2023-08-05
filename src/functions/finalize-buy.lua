local function handle(state, action)
    assert(state.forSale, "NFT is not listed for sale")
    assert(state.reserver == action.caller, "Only the reserver can finalize the buy")
    assert(state.reservationTxId and SmartWeave.transaction.timestamp - state.reservationTimestamp < 600000, "NFT is not reserved for buy")
    assert(state.reservationTxId == action.input.reservationTxId, "Provided reservation txid is invalid")
    assert(SmartWeave.extensions[state.listingChain] and type(SmartWeave.extensions[state.listingChain].readTxById) == "function", "No " .. state.listingChain .. " plugin installed.")

    -- Uncomment these lines if needed, making sure that the BN function is used appropriately.
    -- assert(BN(action.input.price) >= BN(state.price), "Wanted price doesn't match listing price")
    -- assert(SmartWeave.transaction.target == state.owner and BN(SmartWeave.transaction.quantity) >= BN(state.price), "Invalid transfer")

    assert(type(action.input.transferTxID) == "string", "No transfer tx")
    local fetchedTransferTx = SmartWeave.extensions[state.listingChain].readTxById(action.input.transferTxID)
    assert(fetchedTransferTx.to == state.listingAddress, "Invalid transfer (address)")
    assert(fetchedTransferTx.coin == state.listingCoin, "Incorrect transfer coin")
    assert(BN(fetchedTransferTx.amount) >= BN(state.price), "Invalid royalty transfer amount")

    state.reservationTimestamp = 0
    state.reservationTxId = nil
    state.reserver = nil
    state.owner = action.caller
    state.forSale = false
    state.price = "0"
    state.balances = { [action.caller] = 1 }

    return { state = state }
end

return handle