local _, ns = ...
local Chatbox = gUI:NewModule("Chatbox", "AceHook-3.0")
local Wrapper = gUI:GetModule("FrameWrapper")
local MagicFade = gUI:GetModule("MagicFade")

Chatbox.__index = Chatbox
setmetatable(Chatbox, { __index = Wrapper })

-- Configuración y Constantes
local EDITBOX_MAX_ALPHA = 0.4 -- Techo de alpha en reposo/mouseover

---------------------------------------------------------------------
-- Ciclo de Vida
---------------------------------------------------------------------

function Chatbox:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    if not obj then return end

    setmetatable(obj, self)
    
    obj.childFrames = {}
    obj:RegisterChatFrames()
    obj:RegisterExtraFrames()

    obj.forceAlpha = true
    obj:Refresh(true)
    
    return obj
end

function Chatbox:Destroy()
    if self.childFrames then
        for _, frame in ipairs(self.childFrames) do
            -- Restauramos el alpha original (1.0 para chat, 0.4 para EditBox)
            local originalAlpha = self:GetFrameTargetAlpha(frame, 1.0, false)
            if frame then frame:SetAlpha(originalAlpha) end
        end
    end
    self.childFrames = nil
    self.isMouseOver = nil
end

---------------------------------------------------------------------
-- Registro de Elementos
---------------------------------------------------------------------

function Chatbox:RegisterChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local name = "ChatFrame"..i
        local chat = _G[name]
        
        if chat then
            table.insert(self.childFrames, chat)
            
            local tab = _G[name.."Tab"]
            if tab then table.insert(self.childFrames, tab) end
            
            local eb = _G[name.."EditBox"]
            if eb then table.insert(self.childFrames, eb) end
        end
    end
end

function Chatbox:RegisterExtraFrames()
    local extraFrames = { "CombatLogQuickButtonFrame_Custom" }
    for _, fName in ipairs(extraFrames) do
        local f = _G[fName]
        if f then table.insert(self.childFrames, f) end
    end
end

---------------------------------------------------------------------
-- Lógica de Estado y Animación
---------------------------------------------------------------------

function Chatbox:OnUpdate(dt)
    if not self.config or self.config.ignoreFrame then return end

    local isOver, hasFocus = self:CheckIfActive()
    local isActive = isOver or hasFocus

    if isActive ~= self.isMouseOver then
        self.isMouseOver = isActive
        self:Refresh()
    end

    local target = self.targetAlpha
    if target < 0 then return end

    local duration = self.fadeDuration or 0.3
    for _, frame in ipairs(self.childFrames) do
        MagicFade:Step(frame, self:GetFrameTargetAlpha(frame, target, hasFocus), duration, dt)
    end
end

function Chatbox:CheckIfActive()
    local over, focus = false, false

    for _, frame in ipairs(self.childFrames) do
        if frame:IsVisible() then
            -- if MouseIsOver(frame) then over = true end
            if frame:IsMouseOver() then over = true end
            if frame.HasFocus and frame:HasFocus() then focus = true end
        end
        -- Si ya encontramos ambos estados, no hace falta seguir iterando
        if over and focus then break end
    end
    return over, focus
end

---------------------------------------------------------------------
-- Cálculo de Alpha y Normalización
---------------------------------------------------------------------

function Chatbox:GetFrameTargetAlpha(frame, globalTarget, hasFocus)
    -- Si es la caja de texto, Blizzard limita su alpha a 0.4, 
    -- excepto cuando el usuario está escribiendo (Focus).
    if frame.IsObjectType and frame:IsObjectType("EditBox") then
        if hasFocus then return 1.0 end
        return math.min(globalTarget, EDITBOX_MAX_ALPHA)
    end

    return globalTarget
end

function Chatbox:Refresh(instant)
    if not self.config or not self.globals then return end

    self.targetAlpha = self:GetTargetAlpha()
    self.fadeDuration = self:GetFadeDuration()

    if instant then
        local _, hasFocus = self:CheckIfActive()
        for _, frame in ipairs(self.childFrames) do
            if frame then 
                frame:SetAlpha(self:GetFrameTargetAlpha(frame, self.targetAlpha, hasFocus)) 
            end
        end
    end
end