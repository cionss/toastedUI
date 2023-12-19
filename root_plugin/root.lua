local tGuiToolbar = plugin:CreateToolbar("toastedUI");
local editToolbarButton = tGuiToolbar:CreateButton("Edit", "Open editing tools", "rbxassetid://0");

local editWindowOpen = false;
local editUI = script:WaitForChild("toastedUIEdit", 5);
local EditCore = require(editUI:WaitForChild("EditCore", 5));

function EditToolbarButtonClicked(): nil
    if editWindowOpen == false then
		editWindowOpen = true;
		editUI.Parent = game:GetService("CoreGui");

		local function selectionChanged(): nil
			local selection = game.Selection;
			EditCore:Select(selection);
		end

		game:GetPropertyChangedSignal("Selection"):Connect(function(): nil
			
		end);
	else
		editWindowOpen = false;
		editUI.Parent = script.Parent;
	end
end

editToolbarButton.Click:Connect(EditToolbarButtonClicked);