include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- =====================================================
-- KONFIGURACJA MIEJSCA SPAWNU KANISTRA
-- =====================================================
-- Vector(do przodu/tyłu, w lewo/prawo, góra/dół)
-- Zmieniaj te wartości, aby kanister nie spawnował się w środku modelu
local FUEL_SPAWN_OFFSET = Vector(65, 0, 30) 

-- Angle(pitch, yaw, roll) - rotacja kanistra po zrespieniu
local FUEL_SPAWN_ANGLE = Angle(0, 0, 0)
-- =====================================================

function ENT:Initialize()
    self:SetModel("models/props_wasteland/fuel_storage01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:EnableMotion(false)
    end

    self.nextSpawn = 0 
end

function ENT:Use(activator)
    if (not IsValid(activator) or not activator:IsPlayer()) then return end

    if (CurTime() < self.nextSpawn) then
        activator:Notify("Dystrybutor przesyła paliwo, poczekaj chwilę...")
        return
    end

    self.nextSpawn = CurTime() + 2

    -- Obliczamy pozycję i rotację na podstawie Twojej konfiguracji powyżej
    local spawnPos = self:LocalToWorld(FUEL_SPAWN_OFFSET)
    local spawnAng = self:GetAngles() + FUEL_SPAWN_ANGLE
    
    ix.item.Spawn("paliwo", spawnPos, function(item, ent)
        if (IsValid(ent)) then
            ent:SetAngles(spawnAng)
            
            -- Opcjonalnie: lekki popchnięcie kanistra, żeby nie stał idealnie w miejscu
            local phys = ent:GetPhysicsObject()
            if (IsValid(phys)) then
                phys:ApplyForceCenter(self:GetForward() * 50)
            end
        end
    end)

    -- Efekty dźwiękowe
    self:EmitSound("ambient/machines/gas_leak_loop1.wav", 70, 110, 0.4)
    
    timer.Simple(0.6, function()
        if (IsValid(self)) then
            self:StopSound("ambient/machines/gas_leak_loop1.wav")
            self:EmitSound("buttons/light_switch_on.wav", 60, 120)
        end
    end)

    activator:Notify("Pobrano kanister z paliwem.")
end