local function handle(state, action)
    assert(not state.reservationTxId or (SmartWeave.transaction.timestamp - state.reservationTimestamp) > 600000, "NFT is reserved for buy")
    assert(state.owner == action.caller, "Caller should own NFT")

    local price = action.input.price
    local priceIsValid = (type(price) == "number" or type(price) == "string") and BN(price) > BN(1)

    assert(priceIsValid, "Invalid price: must be a positive number")
    assert(type(action.input.description) == "string", "Description should be string")
    assert(type(action.input.forSale) == "boolean", "forSale should be boolean")

    if type(price) == "number" then
        action.input.price = tostring(action.input.price)
    end

    state.price = action.input.price
    state.description = action.input.description
    state.forSale = action.input.forSale

    return { state = state }
end

return handle
