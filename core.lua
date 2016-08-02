-- Addon infos
local ADDON_NAME = 'SPanels';
local ADDON_VERSION = '0.2';

-- Default config to use
local DefaultConfig = {
    Version = ADDON_VERSION,
    PanelCount = 0,
    Panels = {
        -- Saved panels should look like that
        -- [0] = {
        --     x = ?, y = ?,
        --     w = ?, h = ?,
        --     p = ?, rp = ?,
        --     id = ?,
        -- },
    },
};

SP_GAME_PANELS = {};
local this;

-- Custom addon print function
function SPanels_print(msg)
    print('|cFF009700SPanels|r - ' .. msg);
end

-- Registered events triggers are redirected to that function
local function SPanels_OnEvent(self, event, arg1)
--    print(event .. ' -> ' .. tostring(arg1));
    if ( event == 'ADDON_LOADED' ) then
        if ( arg1 == ADDON_NAME ) then
            if ( SPConfig ) then
                -- Basic compatibility check
                if ( SPConfig.Version == ADDON_VERSION ) then
--                    SPanels_print('Count: ' .. SPConfig.PanelCount)

                    -- If addon is loaded and profile existing,
                    -- recovers every frame and updates it to
                    -- previous saved location
                    for i=0,SPConfig.PanelCount-1 do
                        local info = SPConfig.Panels[i];
                        SPanels_CreatePanel(i, info.x, info.y, info.w, info.h, info.p, info.rp, info.id);
                    end

                else
                    -- Incompatible addon version with saved data
                    error('|cFF009700SPanels|r - Incompatible saved variables version! Reseting profile to default.');
                    SPConfig = DefaultConfig;
                end
            else
                -- First login ?
                SPanels_print('Creating new profile for you <3');
                SPConfig = DefaultConfig;
            end
        end
    elseif ( event == 'PLAYER_LOGOUT' ) then
        -- Saving panels data to SPConfig for later use
        for i=0,SPConfig.PanelCount-1 do
            SPConfig.Panels[i] = SP_GAME_PANELS[i].SPanels_GetSave();
        end
    end
end

-- Triggered when addon is being launched
local function SPanels_OnLoad()
    -- Creates a frame to register events
    this = CreateFrame('Frame');
    this:RegisterEvent('ADDON_LOADED');
    this:RegisterEvent('PLAYER_LOGOUT');
    this:SetScript('OnEvent', SPanels_OnEvent);
end

SPanels_OnLoad();
