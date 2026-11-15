local _, ns = ...
local Resting = gUI:NewModule("RestingDetector", "AceEvent-3.0")
Resting:SetDefaultModuleState(false)

function Resting:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_UPDATE_RESTING", "UpdateResting")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateResting")
end

function Resting:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Detecta si el jugador está en una zona de descanso (ciudad o posada)
function Resting:UpdateResting(force)
    local currentState = IsResting() or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        gUI:GetModule("Events"):RegisterEvent("RESTING", currentState)
    end
end

function Resting:Refresh()
    self:UpdateResting(true)
end