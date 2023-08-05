local function handle(state, action)
  local reservationTxId = state.reservationTxId
  local reservationTimestamp = state.reservationTimestamp
  local input = action.input
  local caller = action.caller
  local target = input.target

  assert(not reservationTxId or SmartWeave.transaction.timestamp - reservationTimestamp > 600000, "NFT is reserved for buy")
  assert(target, "No target specified.")
  assert(caller ~= target, "Invalid token transfer.")

  local qty = 1 -- Each contract is a single NFT, so non-divisible and single token.
  local balances = state.balances
  assert(balances[caller] and balances[caller] >= qty, "Caller has insufficient funds.")

  if not balances[target] then
      balances[target] = 0
  end

  balances[caller] = balances[caller] - qty
  balances[target] = balances[target] + qty

  if balances[caller] == 0 then
      balances[caller] = nil
  end

  state.owner = target
  state.balances = balances

  return { state = state }
end

return handle
