
IDENTIFIER = "__stack_fsm"

--- 移除最新的栈状态
popState = =>
  states = rawget @, IDENTIFIER
  return print "[stack_fsm::pushState] invalid stack_fsm:#{@}" unless type(states) == "table"
  return table.remove states

--- 移除最新的栈状态
-- @param {anything} state, 状态，可以是字符串(事件名)、方法（会被执行）
-- @param {boolean} allowDuplication, 当 true 时，即便当前状态就是所要添加进入的状态的话，也会继续添加新状态
pushState = (state, allowDuplication)=>
  return if (not allowDuplication) and state == @getCurrentState!
  states = rawget @, IDENTIFIER
  return print "[stack_fsm::pushState] invalid stack_fsm:#{@}" unless type(states) == "table"
  table.insert states, state
  return @        -- chainalbe

--- 返回当前状态
getCurrentState = =>
  states = rawget(@, IDENTIFIER)
  return print "[stack_fsm::pushState] invalid stack_fsm:#{@}" unless type(states) == "table"
  return nil unless #states > 0
  return states[#states]

--- 执行当前状态
updateState = =>
  currentState = self\getCurrentState!
  return if currentState == nil

  -- 如果state 是一个可以执行的函数，那么执行这个函数
  return currentState(self) if type(currentState) == "function"

  -- 如果 self 是一个 事件触发器，那么抛出事件
  return self\emit("stack_fsm_update", currentState) if type(self.emit) == "function"

  -- 如果 self 上有通用的 stack fsm 的监听，那么调用这个事件监听方法
  return self\onStackFSMUpdate(currentState) if type(self.onStackFSMUpdate) == "function"

  -- 如果 self 上有 on 事件监听方法，那么调用这个事件监听方法
  return self["on#{currentState}"](self) if type(self["on#{currentState}"]) == "function"

  return

-- 重设状态
resetState = (state)=>
  rawset @, IDENTIFIER, {state}
  return @        -- chainalbe

return {
  -- 向给定的 table 注入 Stack Finity State Machine 功能，如果没有提给定的 table 那么会创建一个新 table
  -- @param tbl target table
  StackFSM: (tbl)->

    print "[stack_fsm::StackFSM] tbl:#{tbl}"

    tbl = {} unless type(tbl) == "table"

    return print "[stack_fsm::StackFSM] #{tbl} is already an StackFSM" if type(rawget(tbl, IDENTIFIER)) == "table"

    rawset tbl, IDENTIFIER, {}

    tbl.popState = popState
    tbl.pushState = pushState
    tbl.getCurrentState = getCurrentState
    tbl.updateState = updateState
    tbl.resetState = resetState
    return tbl
}

