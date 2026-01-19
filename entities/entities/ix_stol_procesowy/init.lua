include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- =====================================================
-- KONFIGURACJA POZYCJI (TU ZMIENIAJ WARTOŚCI)
-- =====================================================
local SPAWN_OFFSET = Vector(0, 0, 15) -- X, Y, Z (Z: 45 to wysokość nad środkiem modelu)
local SPAWN_ANGLE = Angle(0, 0, 0)    -- Kąt obrotu paczki
-- =====================================================

function ENT:Initialize()
    self:SetModel("models/hls/alyxports/table_proccesing.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetTrigger(true)

    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:EnableMotion(false) -- Stół powinien być nieruchomy
    end
end

-- Funkcja sprawdzająca kolizję z przedmiotem
function ENT:StartTouch(entity)
    if (IsValid(entity) and entity:GetClass() == "ix_item") then
        local itemTable = entity:GetItemTable()
        
        if (itemTable and itemTable.uniqueID == "paczka") then
            local spawnPos = self:LocalToWorld(SPAWN_OFFSET)
            local spawnAng = self:GetAngles() + SPAWN_ANGLE

            entity:Remove()

            -- Tworzymy encję - ona sama załaduje model z własnego pliku init.lua
            local nowaPaczka = ents.Create("ix_paczka_proces")
            if (IsValid(nowaPaczka)) then
                nowaPaczka:SetPos(spawnPos)
                nowaPaczka:SetAngles(spawnAng)
                nowaPaczka:Spawn()
                nowaPaczka:Activate() -- To wymusza na silniku odświeżenie stanu fizyki
            end
        end
    end
end