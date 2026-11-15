local _, ns = ...
local Stealth = gUI:NewModule("StealthDetector", "AceEvent-3.0")
Stealth:SetDefaultModuleState(false)

function Stealth:OnEnable()
    self.lastState = false
    self:RegisterEvent("UPDATE_STEALTH", "UpdateStealth")
end

function Stealth:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Detecta si el jugador está en sigilo
function Stealth:UpdateStealth(force)
    local currentState = IsStealthed() or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        gUI:GetModule("Events"):RegisterEvent("STEALTH", currentState)
    end
end

function Stealth:Refresh()
    self:UpdateStealth(true)
end