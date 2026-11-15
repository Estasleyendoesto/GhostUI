local _, ns = ...
local Dead = gUI:NewModule("DeadDetector", "AceEvent-3.0")
Dead:SetDefaultModuleState(false)

function Dead:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_DEAD", "UpdateDead")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateDead")
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateDead")
end

function Dead:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Detecta si el jugador está muerto o en forma de fantasma
function Dead:UpdateDead(force)
    local currentState = UnitIsDeadOrGhost("player") or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        gUI:GetModule("Events"):RegisterEvent("DEAD", currentState)
    end
end

function Dead:Refresh()
    self:UpdateDead(true)
end