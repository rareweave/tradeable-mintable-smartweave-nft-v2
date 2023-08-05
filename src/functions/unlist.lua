local function handle(state, action)
  assert(not state.reservationTxId or (SmartWeave.transaction.timestamp - state.reservationTimestamp) > 600000, "NFT is reserved for buy")
  assert(state.forSale, "This NFT is not for sale. Use 'list' function to list NFT")
  assert(state.owner == action.caller, "Should own NFT")

  state.forSale = false
  state.price = 0
  state.reservationTxId = nil
  state.reservationTimestamp = 0
  state.reserver = nil

  return { state = state }
end

return handle
