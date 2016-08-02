local SP_DEFAULT_BACKDROP = {
    bgFile=[[Interface\AddOns\SPanels\textures\bg.tga]],
    edgeFile=[[Interface\AddOns\SPanels\textures\border.tga]],
    tile = true,
    tileSize = 256,
    edgeSize = 16,
    insets = {
        left = 6,
        right = 6,
        top = 6,
        bottom = 6,
    },
};

local SP_DARKMETAL_BACKDROP = {
    bgFile=[[Interface\AddOns\SPanels\textures\bg.tga]],
    edgeFile=[[Interface\AddOns\SPanels\textures\darkmetal.tga]],
    tile = true,
    tileSize = 256,
    edgeSize = 16,
    insets = {
        left = 6,
        right = 6,
        top = 6,
        bottom = 6,
    },
};

local SP_GOLDEN_BACKDROP = {
    bgFile=[[Interface\AddOns\SPanels\textures\bg.tga]],
    edgeFile=[[Interface\AddOns\SPanels\textures\golden.tga]],
    tile = true,
    tileSize = 256,
    edgeSize = 16,
    insets = {
        left = 6,
        right = 6,
        top = 6,
        bottom = 6,
    },
};

local SP_IRON_BACKDROP = {
    bgFile=[[Interface\AddOns\SPanels\textures\bg.tga]],
    edgeFile=[[Interface\AddOns\SPanels\textures\iron.tga]],
    tile = true,
    tileSize = 256,
    edgeSize = 16,
    insets = {
        left = 6,
        right = 6,
        top = 6,
        bottom = 6,
    },
};

local SP_ELVUI_BACKDROP = {
    bgFile=[[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
    edgeFile=[[Interface\AddOns\SPanels\textures\elv.tga]],
    tile = true,
    tileSize = 16,
    edgeSize = 2,
    insets = {
        left = 1,
        right = 1,
        top = 1,
        bottom = 1,
    },
};

local SP_DRAGGABLE_BACKDROP = {
    bgFile=[[Interface\DialogFrame\UI-DialogBox-Background]],
    edgeFile=[[Interface\AddOns\SPanels\textures\border_green.tga]],
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 8,
        right = 8,
        top = 8,
        bottom = 8,
    },
};

SP_PANEL_BACKDROPS = {
    [0] = SP_DRAGGABLE_BACKDROP,
    [1] = SP_DEFAULT_BACKDROP,
    [2] = SP_DARKMETAL_BACKDROP,
    [3] = SP_GOLDEN_BACKDROP,
    [4] = SP_IRON_BACKDROP,
    [5] = SP_ELVUI_BACKDROP,
};

-- Creates a new Panel with given settings
function SPanels_CreatePanel(ID, x, y, w , h, p, rp, tid)
    -- Register it to the current panel list
    SP_GAME_PANELS[ID] = CreateFrame('Frame', nil, UIParent);

    local panel = SP_GAME_PANELS[ID];
    panel:SetFrameStrata('BACKGROUND');
    panel:ClearAllPoints();

    -- Set dimension / location back
    panel:SetPoint(p , x, y, rp);
    panel:SetSize(w, h);

    panel.texID = tid;

    -- ID Text settings
    panel.text = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
    panel.text:SetTextColor(1, 1, 1, 1);
    panel.text:SetJustifyH('LEFT');
    panel.text:SetPoint('TOPLEFT', 12, 12, 'TOPLEFT');
    panel.text:SetText('ID: ' .. ID);

    -- Panel method to set / change panel texture (backdrop)
    panel.SPanels_SetBackdrop = function (ID)
        if ( SP_PANEL_BACKDROPS[ID] ) then
            -- Hotfix 0a (08.01.16)
            -- Only save texture ID if not moving
            if ( ID ~= 0 ) then
                panel.texID = ID;
            end

            panel:SetBackdrop(SP_PANEL_BACKDROPS[ID]);

            if ( ID == 5 ) then
                panel:SetBackdropColor(0.2, 0.2, 0.2, 1);
            else
                panel:SetBackdropColor(1, 1, 1, 1);
            end
        else
            panel.texID = 0;
            panel:SetBackdrop(SP_DEFAULT_BACKDROP);
        end
    end;

    -- Panel method to set / unset Movable status
    panel.SPanels_SetMovable = function(bool)
        if ( not bool ) then
            -- Disable mouse events and ID text
            panel:EnableMouse(false);
            panel.text:Hide();

            -- Restore texture back to what it was
            panel.SPanels_SetBackdrop(panel.texID);

        else
            -- Enable mouse events
            panel:EnableMouse(true);
            panel:SetMovable(true);
            panel:SetResizable(true);

            -- Display ID text on movable state
            panel.text:Show();

            -- Visible color update to green
            panel.SPanels_SetBackdrop(0);

            -- Set action scripts for registered mouse events
            --------------------------------------------------------------------
            panel:SetScript("OnMouseDown", function(self, button)
                if ( ( button == "LeftButton" ) and ( not self.isMoving ) ) then
                    self:StartMoving();
                    self.isMoving = true;
                elseif ( button == "RightButton" ) then
                    self:StartSizing()
                    self.isMoving = true
                    self.hasMoved = false
                end
            end)

            panel:SetScript("OnMouseUp", function(self, button)
                if ( ( button == "LeftButton" ) and ( self.isMoving ) ) then
                    self:StopMovingOrSizing();
                    self.isMoving = false;
                elseif ( button == 'RightButton' ) then
                    self:StopMovingOrSizing();
                end
            end)

            panel:SetScript("OnHide", function(self)
                if ( self.isMoving ) then
                    self:StopMovingOrSizing();
                    self.isMoving = false;
                end
            end)
            -- Script end
            --------------------------------------------------------------------
        end
    end;

    -- Signature:
    -- x, y, w, h = panel.SPanels_GetSave();
    -- Saves the
    panel.SPanels_GetSave = function ()
        local p, _, rp, x, y = panel:GetPoint();
        return {
            ['x']  = x,
            ['y']  = y,
            ['w']  = panel:GetWidth(),
            ['h']  = panel:GetHeight(),
            ['p']  = p,
            ['rp'] = rp,
            ['id'] = panel.texID,
        };
    end;

    panel.SPanels_SetMovable(false);
    panel:Show();

    -- Why not ?
    return panel;
end
