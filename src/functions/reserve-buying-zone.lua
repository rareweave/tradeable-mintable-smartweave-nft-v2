local function handle(state, action)
    local target = SmartWeave.transaction.target
    local quantity = SmartWeave.transaction.quantity
    local owner = SmartWeave.transaction.owner
    local id = SmartWeave.transaction.id

    -- Uncomment the following line if needed and make sure to use the BN function appropriately.
    -- assert(target == state.minter and BN(quantity) == BN(action.input.price) * BN(100 / state.royalty), "Invalid burn")

    assert(state.forSale, 'NFT is not listed for sale')
    assert(not state.reservationTxId or (SmartWeave.transaction.timestamp - state.reservationTimestamp) > 600000, "NFT is reserved for buy")
    assert(BN(action.input.price) >= BN(state.price), "Wanted price doesn't match listing price")
    assert(type(action.input.transferTxID) == "string", "No royalty tx")
    assert(SmartWeave.extensions[state.listingChain] and type(SmartWeave.extensions[state.listingChain].readTxById) == "function", "No " .. state.listingChain .. " plugin installed.")
    
    local fetchedRoyaltyTx = SmartWeave.extensions[state.listingChain].readTxById(action.input.transferTxID)
    assert(fetchedRoyaltyTx.to == state.royaltyAddresses[state.listingChain], "Invalid transfer (address)")
    assert(BN(fetchedRoyaltyTx.amount) >= (BN(state.price) / BN(1 / state.royalty)), "Invalid royalty transfer amount")
    assert(fetchedRoyaltyTx.coin == state.listingCoin, "Incorrect transfer coin")
    
    state.reservationTimestamp = SmartWeave.transaction.timestamp
    state.reservationTxId = id
    state.reserver = owner

    return { state = state }
end

return handle