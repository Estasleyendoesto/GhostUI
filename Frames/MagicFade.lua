local _, ns = ...
local MagicFade = gUI:NewModule("MagicFade")

local THRESHOLD = 0.01

-- Mueve el alpha de un frame un paso hacia su objetivo sin usar UIFrameFade
function MagicFade:Step(frame, targetAlpha, duration, dt)
    if not frame then return end

    local current = frame:GetAlpha()
    if current == targetAlpha then return end

    local step = (dt or 0.1) / math.max(0.01, duration or 0.3)
    local diff = targetAlpha - current

    if math.abs(diff) <= math.max(step, THRESHOLD) then
        frame:SetAlpha(targetAlpha)
        return
    end

    frame:SetAlpha(current + (diff > 0 and step or -step))
end
