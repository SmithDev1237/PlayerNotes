addon.author = 'Fyayu'
addon.name = 'PlayerNotes'
addon.version = '1.1'
addon.desc = 'Allows you to make notes on other players and view them automatically whenever you target someone.'

require('common')
local imgui = require('imgui')
local settings = require('settings')

-- Default settings
local defaultConfig = {
    notes = {},
    ratings = {},
    linkshells = {}
}
local config = settings.load(defaultConfig)

-- Variables
local target_name, selected_player = "", ""
local new_note, advanced_note, new_player_name, new_linkshell = { "" }, { "" }, { "" }, { "" }
local display_notes, display_rating, display_linkshell = {}, 0, ""
local show_new_note_input, show_advanced_window = false, false

-- Helper Functions
local function save_config()
    settings.save()
end

local function get_star_display_and_color(rating)
    local stars = string.rep("*", rating)
    local colors = {
        [1] = {1.0, 0.0, 0.0, 1.0},
        [2] = {1.0, 0.5, 0.0, 1.0},
        [3] = {1.0, 1.0, 0.0, 1.0},
        [4] = {0.5, 1.0, 0.0, 1.0},
        [5] = {0.0, 1.0, 0.0, 1.0}
    }
    return stars, colors[rating] or {1.0, 1.0, 0.0, 1.0}
end

local function add_or_update_note_for_player(name, note, linkshell)
    if name == "" then return end
    config.notes[name] = config.notes[name] or {}
    config.notes[name][1] = note
    config.linkshells[name] = linkshell or ""
    save_config()
end

local function update_rating_for_player(name, rating)
    if name == "" then return end
    config.ratings[name] = rating
    save_config()
end

local function delete_player_notes(name)
    if name == "" then return end
    config.notes[name], config.ratings[name], config.linkshells[name] = nil, nil, nil
    save_config()
end

local function get_player_data(name)
    return config.notes[name] or {}, config.ratings[name] or 0, config.linkshells[name] or "No linkshell info"
end

-- Event Handlers
ashita.events.register('load', 'addon_load_cb', function() end)
ashita.events.register('unload', 'addon_unload_cb', function() end)

-- Display Functions
local function render_target_info()
    imgui.TextColored({0.5, 1.0, 0.5, 1.0}, "Target: " .. target_name .. " ")
    imgui.SameLine()
    local stars, color = get_star_display_and_color(display_rating)
    imgui.TextColored(color, stars)
    imgui.Text("Linkshell: " .. display_linkshell)
    imgui.Separator()
end

local function render_notes()
    imgui.Text("------------- Notes -------------")
    imgui.Separator()
    if #display_notes > 0 then
        for _, note in ipairs(display_notes) do
            imgui.TextWrapped(note)
        end
    else
        imgui.Text("No notes for this player.")
    end
end

local function render_advanced_window()
    imgui.SetNextWindowBgAlpha(0.9)
    imgui.Begin("Advanced Player Notes", true, ImGuiWindowFlags_AlwaysAutoResize)

    imgui.BeginChild("ScrollingRegion", {1140, 400}, true)
    local player_names = {}
    for player in pairs(config.notes) do table.insert(player_names, player) end
    table.sort(player_names)

    if imgui.BeginTable("PlayerNotesTable", 6, imgui.ImGuiTableFlags_Resizable) then
        imgui.TableSetupColumn("Player Name", imgui.ImGuiTableColumnFlags_WidthFixed, 150)
        imgui.TableSetupColumn("Rating", imgui.ImGuiTableColumnFlags_WidthFixed, 80)
        imgui.TableSetupColumn("Linkshell", imgui.ImGuiTableColumnFlags_WidthFixed, 150)
        imgui.TableSetupColumn("Notes", imgui.ImGuiTableColumnFlags_WidthFixed, 600)
        imgui.TableSetupColumn("", imgui.ImGuiTableColumnFlags_WidthFixed, 80)
        imgui.TableSetupColumn("", imgui.ImGuiTableColumnFlags_WidthFixed, 80)
        imgui.TableHeadersRow()

        for i, player in ipairs(player_names) do
            local notes, rating, linkshell = get_player_data(player)
            local stars, color = get_star_display_and_color(rating)
            local row_color = imgui.GetColorU32({i % 2 == 0 and 0.3 or 0.5, 0.3, 0.3, 0.2})
            imgui.TableNextRow()
            imgui.TableSetBgColor(ImGuiTableBgTarget_RowBg0, row_color)

            imgui.TableNextColumn() imgui.Text(player)
            imgui.TableNextColumn() imgui.TextColored(color, stars)
            imgui.TableNextColumn() imgui.TextWrapped(linkshell)
            imgui.TableNextColumn() imgui.TextWrapped(notes[1] or "No notes available")

            imgui.TableNextColumn()
            if imgui.Button("Edit##" .. i, {60, 25}) then
                selected_player, advanced_note[1], advanced_rating, new_linkshell[1] = player, notes[1] or "", rating, linkshell
            end

            imgui.TableNextColumn()
            if imgui.Button("Delete##" .. i, {60, 25}) then
                delete_player_notes(player)
            end
        end

        imgui.EndTable()
    end

    imgui.EndChild()
    imgui.Separator()

    if selected_player == "" then
        imgui.Text("Enter New Player:")
        imgui.InputText("##NewPlayerName", new_player_name, 64)
        imgui.SameLine()
        if imgui.Button("Create") then
            selected_player, advanced_note[1], advanced_rating = new_player_name[1], "", 0
            new_player_name[1] = ""
            new_linkshell[1] = ""
        end
        imgui.SameLine()
        if imgui.Button("Close") then show_advanced_window = not show_advanced_window end
    else
        imgui.Text("Editing notes for: " .. selected_player)
        imgui.Text("")
        for i, label in ipairs({"Terrible", "Bad", "Average", "Good", "Great"}) do
            if imgui.RadioButton(label .. "##advancedRating" .. i, advanced_rating == i) then
                advanced_rating = i
                update_rating_for_player(selected_player, advanced_rating)
            end
            imgui.SameLine()
        end
        imgui.Text("")
        imgui.InputText("Linkshell", new_linkshell, 64)
        imgui.Text("")
        imgui.InputTextMultiline("Note##AdvancedNote", advanced_note, 256, 100)
        if imgui.Button("Save Note") then
            add_or_update_note_for_player(selected_player, advanced_note[1], new_linkshell[1])
            selected_player = ""
        end
        imgui.SameLine()
        if imgui.Button("Cancel") then selected_player = "" end
    end

    imgui.End()
end

ashita.events.register('d3d_present', 'present_cb', function()
    local memMgr, targetMgr, entityMgr, target = AshitaCore:GetMemoryManager(), AshitaCore:GetMemoryManager():GetTarget(), nil, nil
    if targetMgr then
        local targetIndex = targetMgr:GetTargetIndex(targetMgr:GetIsSubTargetActive())
        if targetIndex and targetIndex > 0 then
            entityMgr = memMgr:GetEntity()
            if entityMgr then
                target = entityMgr:GetRace(targetIndex) >= 1 and entityMgr:GetRace(targetIndex) <= 8 and entityMgr:GetName(targetIndex) or ""
            end
        end
    end

    target_name = target or ""
    display_notes, display_rating, display_linkshell = get_player_data(target_name)

    imgui.SetNextWindowBgAlpha(0.8)
    imgui.Begin("Player Notes", false, ImGuiWindowFlags_AlwaysAutoResize)

    if target_name ~= "" then
        render_target_info()
        render_notes()
    else
        imgui.TextColored({1.0, 0.5, 0.5, 1.0}, "No player target selected")
    end

    if imgui.Button("Config") then show_advanced_window = not show_advanced_window end
    imgui.End()

    if show_advanced_window then render_advanced_window() end
end)

settings.register('settings', 'settings_update', function (s)
    config = s or config
end)
