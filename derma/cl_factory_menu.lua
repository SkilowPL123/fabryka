local PANEL = {}

function PANEL:Init()
    local parent = self
    self:SetSize(600, 500) -- Zwiększono nieco wysokość
    self:SetTitle("Zaawansowany Panel Sterowania")
    self:MakePopup()
    self:Center()

    -- Kontener lewej strony (Lista + Dodawanie)
    self.leftPanel = self:Add("DPanel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:SetWide(200)
    self.leftPanel.Paint = nil

    -- LISTA FABRYK
    self.factoryList = self.leftPanel:Add("DListView")
    self.factoryList:Dock(FILL)
    self.factoryList:SetMultiSelect(false)
    self.factoryList:AddColumn("ID Przypisanych Fabryk")

    -- PANEL DODAWANIA ID
    self.addSection = self.leftPanel:Add("DPanel")
    self.addSection:Dock(BOTTOM)
    self.addSection:SetTall(60)
    self.addSection:DockMargin(0, 5, 0, 0)
    self.addSection.Paint = nil

    self.addLabel = self.addSection:Add("DLabel")
    self.addLabel:SetText("Dodaj fabrykę po ID:")
    self.addLabel:Dock(TOP)
    self.addLabel:SetTextColor(color_white)

    self.addEntry = self.addSection:Add("DTextEntry")
    self.addEntry:Dock(TOP)
    self.addEntry:DockMargin(0, 5, 0, 0)
    self.addEntry:SetPlaceholderText("np. F-1")
    self.addEntry.OnEnter = function(s)
        local val = s:GetValue()
        if (val and val ~= "" and IsValid(parent.entity)) then
            -- Wysyłanie prośby o linkowanie do serwera
            net.Start("ix_FactoryLink")
                net.WriteEntity(parent.entity)
                net.WriteString(val)
            net.SendToServer()
            s:SetText("")
        end
    end

    -- PANEL KONTROLNY (Prawa strona)
    self.controlPanel = self:Add("DPanel")
    self.controlPanel:Dock(FILL)
    self.controlPanel:DockMargin(10, 0, 0, 0)
    self.controlPanel.Paint = nil

    -- PRZEŁĄCZNIK: Wszystkie vs Zaznaczona
    self.modeSwitch = self.controlPanel:Add("DCheckBoxLabel")
    self.modeSwitch:Dock(TOP)
    self.modeSwitch:SetText("Zastosuj dla wszystkich połączonych fabryk")
    self.modeSwitch:SetValue(1)
    self.modeSwitch:DockMargin(0, 0, 0, 10)

    -- PRZYCISK STOP
    self.stopBtn = self.controlPanel:Add("DButton")
    self.stopBtn:Dock(TOP)
    self.stopBtn:SetTall(30)
    self.stopBtn:SetText("ZATRZYMAJ PRODUKCJĘ")
    self.stopBtn:SetTextColor(Color(255, 50, 50))
    self.stopBtn:DockMargin(0, 0, 0, 20)
    self.stopBtn.DoClick = function()
        parent:SendProductionOrder("STOP")
    end

    -- LISTA RECEPTUR
    self.recipeScroll = self.controlPanel:Add("DScrollPanel")
    self.recipeScroll:Dock(FILL)

    self:LoadRecipes()
end

-- Funkcja pomocnicza do wysyłania rozkazów
function PANEL:SendProductionOrder(recipeID)
    local applyToAll = self.modeSwitch:GetChecked()
    local selectedID = ""
    
    if (!applyToAll) then
        local selectedLine = self.factoryList:GetLine(self.factoryList:GetSelectedLine())
        if (selectedLine) then
            selectedID = selectedLine:GetValue(1)
        else
            LocalPlayer():Notify("Musisz najpierw zaznaczyć fabrykę na liście!")
            return
        end
    end

    if (recipeID == "STOP") then
        net.Start("ix_FactoryStop")
    else
        net.Start("ix_FactoryProduce")
        net.WriteString(recipeID)
    end
    
    net.WriteEntity(self.entity)
    net.WriteBool(applyToAll)
    net.WriteString(selectedID)
    net.SendToServer()
    
    surface.PlaySound("buttons/combine_button1.wav")
end

function PANEL:LoadRecipes()
    local parent = self
    if (not ix.production or not ix.production.recipes) then return end

    for id, recipe in pairs(ix.production.recipes) do
        local rid = id
        local btn = self.recipeScroll:Add("DButton")
        btn:Dock(TOP)
        btn:SetTall(35)
        btn:SetText(recipe.name)
        btn:DockMargin(0, 0, 0, 5)
        btn.DoClick = function()
            parent:SendProductionOrder(rid)
        end
    end
end

function PANEL:SetEntity(ent) self.entity = ent end

function PANEL:PopulateLinkedFiles(ids)
    self.factoryList:Clear()
    if (ids) then 
        for _, id in ipairs(ids) do 
            self.factoryList:AddLine(id) 
        end 
    end
end

vgui.Register("ixProductionConsole", PANEL, "DFrame")