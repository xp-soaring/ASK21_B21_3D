-- B21
-- 
print("b21_spin_kit.lua starting")

local SPIN_KIT_KG = 25 -- weight of spin kit

-- WRITE datarefs
-- b21/no_spin_kit is used to HIDE the spin kit object on the glider
local DATAREF_NO_SPIN_KIT = createGlobalPropertyi("b21/no_spin_kit", 1.0, false, true, true) -- -90..90
local DATAREF_BALLAST_KG = globalPropertyf("sim/flightmodel/weight/m_jettison") -- Kg water ballast = spin kit

-- READ datarefs
local DATAREF_ONGROUND = globalPropertyi("sim/flightmodel/failures/onground_any") -- =1 when on the ground (unreliable at startup)
local DATAREF_ALT_AGL_FT = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")

-- COMMANDS
local command_spin_kit_toggle = sasl.createCommand("b21/spin_kit/toggle", "Toggle Spin Kit")
local command_spin_kit_on = sasl.createCommand("b21/spin_kit/on", "Install Spin Kit")
local command_spin_kit_off = sasl.createCommand("b21/spin_kit/off", "Remove Spin Kit")

-- READ datarefs
local DATAREF_TIME_S = globalPropertyf("sim/network/misc/network_time_sec")

local command_time_s = 0.0

function clicked_spin_kit_on(phase)
  if phase == SASL_COMMAND_BEGIN
  then
    set(DATAREF_NO_SPIN_KIT,0)
    print("spin kit set", SPIN_KIT_KG)
  end
end

function clicked_spin_kit_off(phase)
  if phase == SASL_COMMAND_BEGIN
  then
    set(DATAREF_NO_SPIN_KIT,1)
    print("spin kit disabled")
  end
end

function clicked_spin_kit_toggle(phase)
  local time_now_s = get(DATAREF_TIME_S) -- use time delay to protect from switch bounce
  if time_now_s > command_time_s + 0.2 and phase == SASL_COMMAND_BEGIN
  then
    command_time_s = time_now_s
    if get(DATAREF_NO_SPIN_KIT) <= 0.1
    then
      set(DATAREF_NO_SPIN_KIT,1)
      print("spin kit disabled")
    else
      set(DATAREF_NO_SPIN_KIT,0)
      print("spin kit set", SPIN_KIT_KG)
	  end
  end
  return 0
end

sasl.registerCommandHandler(command_spin_kit_toggle, 0, clicked_spin_kit_toggle)
sasl.registerCommandHandler(command_spin_kit_on, 0, clicked_spin_kit_on)
sasl.registerCommandHandler(command_spin_kit_off, 0, clicked_spin_kit_off)

local init_completed = false

local prev_no_spin_kit -- will be set during init()

function init()
  prev_no_spin_kit = get(DATAREF_NO_SPIN_KIT)

  -- if we start on the ground, then disable spin kit (pilot can still request via button)
  if get(DATAREF_ALT_AGL_FT) < 10
  then
    set(DATAREF_NO_SPIN_KIT,1)
    prev_no_spin_kit = 1
    set(DATAREF_BALLAST_KG, 0)
    print("spin kit disabled")
  end

end

function update()
  if not init_completed
  then
    init()
    init_completed = true
  end

  if get(DATAREF_NO_SPIN_KIT) ~= prev_no_spin_kit
  then
    -- no_spin_kit has changed
    if prev_no_spin_kit == 0
    then
      set(DATAREF_BALLAST_KG, 0)
      prev_no_spin_kit = 1
    else
      set(DATAREF_BALLAST_KG, SPIN_KIT_KG)
      prev_no_spin_kit = 0
    end
  end

end