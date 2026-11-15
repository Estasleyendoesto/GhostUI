local _, ns = ...
local Target = gUI:NewModule("TargetDetector", "AceEvent-3.0")
Target:SetDefaultModuleState(false)

function Target:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTarget")
end

function Target:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Detecta si el jugador tiene cualquier objetivo seleccionado
function Target:UpdateTarget(force)
    local currentState = UnitExists("target") or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        gUI:GetModule("Events"):RegisterEvent("TARGET", currentState)
    end
end

function Target:Refresh()
    self:UpdateTarget(true)
end