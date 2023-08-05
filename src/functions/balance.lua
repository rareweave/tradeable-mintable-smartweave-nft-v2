local function handle(state, action)
  local input = action.input or {}
  local caller = action.caller
  local target = input.target

  if not target then
    error("Must specify target to retrieve balance for.")
  end

  local ticker = state.ticker
  local balances = state.balances

  local balance = balances[target] or 0

  return {
    result = {
      target = target,
      ticker = ticker,
      balance = balance,
    }
  }
end

return handle
