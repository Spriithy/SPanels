
-- Registers the /spn command for our addon
SLASH_SPN1, SLASH_SPN2 = '/spn', '/spanels';
SlashCmdList['SPN'] = function (msg, editbox)
    local command, args = msg:match("^(%S*)%s*(.-)$");
    SPanels_ProcessCommand(command, args);
end;

-- Used when the /spn command is triggered and reacts to any given command
function SPanels_ProcessCommand(action, args)

    -- Converts an iterator to a table
    local function to_array(...)
        local arr = {};
        for v in ... do
            arr[#arr + 1] = v;
        end
        return arr;
    end

    -- Unpacks the arguments passed to arg1, arg2
    local arg_a = to_array(string.gmatch(args, "([^"..' '.."]+)"));
    local arg1, arg2 = unpack(arg_a);

    -- /spn help
    if ( action == 'help' ) then
        SPanels_ShowHelp();

    -- /spn reset
    elseif ( action == 'reset' ) then
        SPanels_print('Profile successfully reset!');
        SPConfig = DefaultConfig;
        ReloadUI();

    -- /spn move
    elseif ( action == 'move' ) then
        SPanels_print('Left click to move frames, Right click to resize them.');
        if ( arg1 ) then
            local fID = tonumber(arg1);
            if ( fID and (fID < SPConfig.PanelCount-1 ) and ( fID >= 0 ) ) then
                SPanels_print('Panel ' .. fID .. ' is now movable.');
                SP_GAME_PANELS[fID]:SPanels_SetMovable(true);
            else
                SPanels_print('Argument must be a valid frame ID or nothing!')
            end
        else
            for i=0,SPConfig.PanelCount-1 do
                SP_GAME_PANELS[i].SPanels_SetMovable(true);
            end
        end

    -- /spn lock
    elseif ( action == 'lock' ) then
        if ( arg1 ) then
            local fID = tonumber(arg1);
            if ( fID and (fID < SPConfig.PanelCount-1 ) and ( fID >= 0 ) ) then
                SPanels_print('Panel ' .. fID .. ' is now locked.');
                SP_GAME_PANELS[fID]:SPanels_SetMovable(false);
            else
                SPanels_print('Argument must be a valid frame ID or nothing!')
            end
        else
            SPanels_print('All panels are now locked');
            for i=0,SPConfig.PanelCount-1 do
                SP_GAME_PANELS[i].SPanels_SetMovable(false);
            end
        end

    -- /spn add
    elseif ( action == 'add' ) then
        SPanels_print('Added a new frame with ID ' .. SPConfig.PanelCount);
        -- Create a frame with default and hard coded values
        SPanels_CreatePanel(SPConfig.PanelCount, 0, 0, 256, 128, 'CENTER', 'CENTER', 1);
        SPConfig.PanelCount = SPConfig.PanelCount + 1;

    -- /spn [rem|remove] <ID>
    elseif ( action == 'rem' or action == 'remove' ) then
        if ( tonumber(arg1) ) then
            SPanels_print('Removed frame number ' .. arg1);

            SP_GAME_PANELS[tonumber(arg1)]:Hide();

            -- Shift every frame left in the table and update their text
            for i=tonumber(arg1)+1,SPConfig.PanelCount-1 do
                SP_GAME_PANELS[i].text:SetText(i);
                SP_GAME_PANELS[i-1] = SP_GAME_PANELS[i];
            end

            SPConfig.PanelCount = SPConfig.PanelCount - 1
        elseif ( arg1 == 'all' ) then
            SP_GAME_PANELS = {};
            ReloadUI();
        else
            -- Cannot successfully remove frame
            SPanels_print('ERROR: first argument after ' .. command .. ' must be an integer (frame ID).');
        end

    -- /spn hide
    elseif ( action == 'hide' ) then
        if ( arg1 ~= '' ) then
            local fID = tonumber(arg1);
            if ( fID and (fID < SPConfig.PanelCount-1 ) and ( fID >= 0 ) ) then
                SP_GAME_PANELS[fID]:SetAlpha(0);
            end
        else
            for i=0,SPConfig.PanelCount-1 do
                SP_GAME_PANELS[i]:SetAlpha(0);
            end
        end

    -- /spn show
    elseif ( action == 'show' ) then
        if ( arg1 ~= '' ) then
            local fID = tonumber(arg1);
            if ( fID and (fID < SPConfig.PanelCount-1 ) and ( fID >= 0 ) ) then
                SP_GAME_PANELS[fID]:SetAlpha(1);
            end
        else
            for i=0,SPConfig.PanelCount-1 do
                SP_GAME_PANELS[i]:SetAlpha(1);
            end
        end

    -- /spn toggle
    elseif ( action == 'toggle' ) then
        for i=0,SPConfig.PanelCount-1 do
            -- Simple value swap for [0-1] values. (x = 0|1; swap=1-x)
            SP_GAME_PANELS[i]:SetAlpha(1 - SP_GAME_PANELS[i]:GetAlpha());
        end
        if ( arg1 ) then
            local fID = tonumber(arg1);
            if ( fID and (fID < SPConfig.PanelCount-1 ) and ( fID >= 0 ) ) then
                SP_GAME_PANELS[fID]:SetAlpha(1 - SP_GAME_PANELS[fID]);
            else
                SPanels_print('Argument must be a valid frame ID or nothing!')
            end
        else
            for i=0,SPConfig.PanelCount-1 do
            SP_GAME_PANELS[i]:SetAlpha(1 - SP_GAME_PANELS[i]:GetAlpha());
            end
        end

    -- /spn texture <frameID|all> <textureID>
    elseif ( action == 'texture' ) then
        if ( ( arg1 ~= '' ) and ( arg2 ~= '' ) ) then
            local frameID = tonumber(arg1);
            local textureID = tonumber(arg2);

            if ( arg1 == 'all' ) then
                frameID = arg1;
            end

            if ( frameID and textureID ) then
                if ( textureID == 0 ) then
                    -- We don't want the user to set the moving backdrop for
                    -- his regular frames.
                    return;
                end

                -- Applies texture to desired frames
                if ( frameID == 'all' ) then
                    -- Cycles through the panel list and applies texture to them
                    for i=0,#SP_GAME_PANELS do
                        SP_GAME_PANELS[i].SPanels_SetBackdrop(textureID);
                    end

                -- Well, that didn't go as planned ...
                elseif ( frameID >= SPConfig.PanelCount ) then
                    SPanels_print('Couldn\'t find frame!');
                    return;
                elseif ( not SP_PANEL_BACKDROPS[textureID] ) then
                    SPanels_print('Could\'t find texture!')
                    return;

                -- Regular frame texture update
                else
                    SP_GAME_PANELS[frameID].SPanels_SetBackdrop(textureID);
                end

            -- RIP
            else
                SPanels_print('Arguments passed must be integers:\n/spn texture <frameID> <textureID>')
            end
        else
            SPanels_print('Please specify the frame ID then the texture ID!\n/spn texture <frameID> <textureID>');
            return;
        end

    elseif ( action == 'list' ) then
        SPanels_print('Currently active panels:');
        for i=0,SPConfig.PanelCount-1 do
            SPanels_print('   '.. i)
        end

    else
        -- If command wasn't recognized
        if ( action ~= '' ) then
            -- Did you only type /spn ? really ?
            SPanels_print('Unregistered SPanels command : ' .. action);
        end

        SPanels_Usage();
    end

end

-- Command usage display
function SPanels_Usage()
    SPanels_print('SPanels command usage:\n');
    print('/spn [help|reset|add|rem, remove|move|lock|hide|show|toggle] <args>');
end

-- Shows help ?
function SPanels_ShowHelp()
    SPanels_Usage();
    SPanels_print('HELP:\n' ..
        '- |cFFFFBF00help|r prints help to the user\n' ..
        '- |cFFFFBF00reset|r removes every existing frame for the current profile\n' ..
        '- |cFFFFBF00add|r adds a new frame\n' ..
        '- |cFFFFBF00rem|r <ID|all> removes the frame with the given ID (or all)\n' ..
        '- |cFFFFBF00remove|r <ID|all> see rem\n' ..
        '- |cFFFFBF00texture|r <frameID|all> <textureID> updates the selected frame texture (or all) to the given texture (ID=[1-3])\n' ..
        '- |cFFFFBF00move|r enables moving frames (frames are now shown green and ID is written in TOPLEFT corner)\n' ..
        '- |cFFFFBF00lock|r locks the frames again\n' ..
        '- |cFFFFBF00hide|r hides every frame\n' ..
        '- |cFFFFBF00show|r shows every frame again\n' ..
        '- |cFFFFBF00toggle|r toggles every frame show state\n'
    );
end
