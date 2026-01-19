-- helix/plugins/fabryka/entities/entities/ix_paczka_proces/init.lua

include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- =====================================================
-- KONFIGURACJA SPAWNU MAŁEJ PACZKI
-- =====================================================
-- Zmieniając Vector(0, 30, 0) - 30 to odległość w bok (prawo/lewo)
-- Dodatnia wartość (30) to jedna strona, ujemna (-30) to druga.
local ITEM_SPAWN_OFFSET = Vector(30, 0, 5) 
-- =====================================================

function ENT:Initialize()
    self:SetModel("models/hls/alyxports/wood_crate004.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    -- Ustawiamy początkową liczbę użyć
    self:SetUses(10)

    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:EnableMotion(false)
    end
end

function ENT:Use(activator)
    if (not IsValid(activator) or not activator:IsPlayer()) then return end
    if (self:GetUses() <= 0) then return end

    activator:SetAction("Wyciąganie zawartości...", 5, function()
        if (IsValid(self) and IsValid(activator)) then
            -- Sprawdzamy dystans
            if (activator:GetPos():DistToSqr(self:GetPos()) > 15000) then
                activator:Notify("Jesteś za daleko!")
                return
            end

            -- Obliczamy pozycję spawnu obok paczki
            local spawnPos = self:LocalToWorld(ITEM_SPAWN_OFFSET)

            -- Spawnowanie przedmiotu
            ix.item.Spawn("paczka_mala", spawnPos, function(item, entity)
                if (IsValid(entity)) then
                    entity:SetAngles(self:GetAngles())
                end
            end)

            -- Zmniejszamy liczbę użyć
            local currentUses = self:GetUses()
            self:SetUses(currentUses - 1)

            activator:Notify("Wyciągnięto małą paczkę. Zostało: " .. self:GetUses())
            activator:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav")

            -- Jeśli to było ostatnie użycie - usuwamy encję ze stołu
            if (self:GetUses() <= 0) then
                activator:Notify("Paczka jest już pusta.")
                self:Remove()
            end
        end
    end)
end