local gutil = ...
local addon = LibStub("AceAddon-3.0"):NewAddon("gutil", "AceConsole-3.0")
local icon = LibStub("LibDBIcon-1.0")
local gui = LibStub("AceGUI-3.0")

local f = gui:Create("Frame")
f:SetTitle("gutil")
f:SetLayout("Flow")
f:Hide()

local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("gutil", {
    type = "data source",
    text = "gutil",
    icon = gutil.settings.enabled and "Interface/ICONS/Ability_BackStab" or "Interface/ICONS/Ability_Ambush",
    OnTooltipShow = function(tt)
        tt:AddLine("|cffffffffgutil|r")
        tt:AddLine("Left click to enable")
        tt:AddLine("Right click for menu")
    end,
    OnClick = function(self, button)
        if button == "RightButton" then
            if not f:IsVisible() then
                f:Show()
                f.add_general_tab()
            else
                f:Hide()
            end
        else
            if IsShiftKeyDown() then
                -- gutil.load_addon()
                -- return
            end
            if gutil.settings.active.profile then
                gutil.settings.enabled = not gutil.settings.enabled
            end
            local btn = icon:GetMinimapButton("gutil").icon
            btn:SetTexture(gutil.settings.enabled and "Interface/ICONS/Ability_BackStab" or "Interface/ICONS/Ability_Ambush")
        end
    end
})
icon:Register("gutil", ldb, nil)
-- addon:RegisterChatCommand("gutil reload", gutil.load_addon)

local function draw_general(container)
    local pulse_slider = gui:Create("Slider")
    pulse_slider:SetLabel("Rotation pulse rate")
    pulse_slider:SetValue(gutil.settings.pulse_rate)
    pulse_slider:SetFullWidth(true)
    pulse_slider:SetSliderValues(0.1, 1, 0.1)
    pulse_slider:SetCallback("OnMouseUp", function(_, _, value)
        gutil.settings.pulse_rate = value
    end)
    container:AddChild(pulse_slider)

    local profile_selector = gui:Create("Dropdown")
    profile_selector:SetLabel("Active profile")
    for k, v in gutil.api.pairs(gutil.managers.profile.get_profiles()) do
        profile_selector:AddItem(k, k)
    end
    profile_selector:SetValue(gutil.settings.active.profile)
    profile_selector:SetCallback("OnValueChanged", function(_, _, key)
        if gutil.settings.active.profile then gutil.managers.settings.save(false) end
        gutil.settings.active.profile = key
        gutil.managers.profile.load_profile()
    end)
    container:AddChild(profile_selector)

    local cb_debug = gui:Create("CheckBox")
    cb_debug:SetLabel("Print cast information")
    cb_debug:SetValue(gutil.settings.debug)
    cb_debug:SetCallback("OnValueChanged", function()
        gutil.settings.debug = not gutil.settings.debug
    end)
    container:AddChild(cb_debug)

    -- local cb_tracker = gui:Create("CheckBox")
    -- cb_tracker:SetLabel("Enable tracker")
    -- cb_tracker:SetValue(gutil.settings.tracker)
    -- cb_tracker:SetCallback("OnValueChanged", function()
    --     gutil.settings.tracker = not gutil.settings.tracker
    -- end)
    -- container:AddChild(cb_tracker)
end

local function select_profile_version(container, event, version)
    container:ReleaseChildren()
    for k, v in gutil.api.pairs(gutil.settings.profiles[gutil.settings.active.profile][version]) do
        local w = nil
        if type(v.value) == "number" then
            w = gui:Create("EditBox")
            w:SetLabel(gutil.settings.profiles[gutil.settings.active.profile][version][k].name)
            w:SetText(gutil.settings.profiles[gutil.settings.active.profile][version][k].value)
            w:SetCallback("OnEnterPressed", function()
                gutil.settings.profiles[gutil.settings.active.profile][version][k].value = tonumber(w:GetText())
                gutil.managers.profile.set_profile_settings(version)
            end)
        elseif type(v.value) == "boolean" then
            w = gui:Create("CheckBox")
            w:SetLabel(v.name)
            w:SetValue(v.value)
            w:SetCallback("OnValueChanged", function()
                gutil.settings.profiles[gutil.settings.active.profile][version][k].value = w:GetValue()
                gutil.managers.profile.set_profile_settings(version)
            end)
        end
        if w then container:AddChild(w) end
    end
end

local function draw_profile(container)
    if not gutil.settings.active.profile then
        local label = gui:Create("Label")
        label:SetText("No profile selected...")
        container:AddChild(label)
        return
    end
    local h = gui:Create("Heading")
    h:SetText(gutil.profile.name)
    h:SetFullWidth(true)
    container:AddChild(h)

    local desc = gui:Create("Label")
    desc:SetText(gutil.profile.description)
    desc:SetFullWidth(true)
    container:AddChild(desc)

    local tab = gui:Create("TabGroup")
    tab:SetTitle(" ")
    tab:SetLayout("Flow")
    tab:SetTabs({{value="general", text = "General"}, {value="dungeon", text = "Dungeon"}, {value="raid", text="Raid"}})
    tab:SetCallback("OnGroupSelected", select_profile_version)
    tab:SelectTab(true and gutil.settings.active.version or "general")
    tab:SetFullWidth(true)
    container:AddChild(tab)
end

local function draw_tracker(container)
    local quests = gui:Create("CheckBox")
    quests:SetLabel("Draw quest objectives (Requires Questie)")
    quests:SetFullWidth(true)
    quests:SetValue(gutil.settings.tracker)
    quests:SetCallback("OnValueChanged", function()
        gutil.settings.tracker_quests = not gutil.settings.tracker_quests
    end)
    container:AddChild(quests)
end

local function select_group(container, event, group)
    container:ReleaseChildren()
    if group == "general" then
        draw_general(container)
    elseif group == "profile" then
        draw_profile(container)
    elseif group == "tracker" then
        draw_tracker(container)
    end
end

local g_tab = gui:Create("TabGroup")
g_tab:SetTabs({{value = "general", text="General"}, {value = "profile", text="Profile"}, {value = "debug", text="Debug"}})-- {value = "tracker", text="Tracker"})
g_tab:SelectTab("general")
g_tab:SetLayout("Flow")
g_tab:SetFullHeight(true)
g_tab:SetFullWidth(true)
g_tab:SetCallback("OnGroupSelected", select_group)
f:AddChild(g_tab)

local general_initialized = false
function f.add_general_tab()
    if not general_initialized then
        draw_general(g_tab)
        general_initialized = true
    end
end

function f.set_minimap_icon()
    local btn = icon:GetMinimapButton("gutil").icon
    btn:SetTexture(gutil.settings.enabled and "Interface/ICONS/Ability_BackStab" or "Interface/ICONS/Ability_Ambush")
end

function f.create_spell_warning_frame()
    local list = {}
    for k, v in gutil.api.pairs(gutil.profile.spells) do
        if v.not_found then
            table.insert(list, v)
        end
    end

    if #list > 0 then
        local wf = gui:Create("Window")
        wf:SetTitle("Profile Warning!")
        wf:SetHeight(200)
        wf:SetWidth(200)
        wf:EnableResize(false)
        local text = gui:Create("Label")
        text:SetText("Spells not found:")
        wf:AddChild(text)
        local y = "\n"
        for k,v in gutil.api.pairs(list) do
            y = y .. (v.name or v.id) .. "\n"
        end
        local x = gui:Create("Label")
        x:SetText(y)
        wf:AddChild(x)
    end

end

gutil.ui = f