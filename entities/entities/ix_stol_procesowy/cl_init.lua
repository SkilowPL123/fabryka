include("shared.lua")

function ENT:PopulateTooltip(tooltip)
    -- Nagłówek tooltipa
    local name = tooltip:AddRow("name")
    name:SetText("Paczka")
    name:SetAppearance(ix.config.Get("color")) -- kolor z konfiguracji Helixa
    name:SizeToContents()

    -- Twój dopisek
    local description = tooltip:AddRow("description")
    description:SetText("paczka") -- To o co prosiłeś
    description:SizeToContents()
end