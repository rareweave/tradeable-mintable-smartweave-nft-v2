local function handle(state, action)
    assert(not state.forSale, "NFT is already listed for sale. Use 'change-price' function to change price and 'unlist' to unlist")

    local price = action.input.price
    local priceIsValid = (type(price) == "number" or type(price) == "string") and BN(price) > BN(1)

    assert(priceIsValid, "Invalid price")
    assert(state.owner == action.caller, "Caller should own NFT")
    assert(type(state.royaltyAddresses[action.input.listingChain or ""]) == "string", "Chain not supported by minter")
    assert(type(action.input.listingCoin or "") == "string", "No listing coin provided")
    assert(type(action.input.listingAddress or "") == "string", "No listing address provided")

    if type(price) == "number" then
        action.input.price = tostring(action.input.price)
    end

    state.forSale = true
    state.price = action.input.price
    state.listingChain = action.input.listingChain
    state.listingCoin = action.input.listingCoin
    state.listingAddress = action.input.listingAddress

    return { state = state }
end

return handle