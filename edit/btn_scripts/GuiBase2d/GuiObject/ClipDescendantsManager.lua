local curBool = false;
local button = script.Parent.ClipBooleanButton;

local editFrame = script:FindFirstAncestorWhichIsA("ScrollingFrame");
local EditCore = require(editFrame.Parent.Parent.EditCore);

button.MouseButton1Click:Connect(function()
	if curBool == true then
		curBool = false;
		button.BackgroundTransparency = 1;
	else
		curBool = true;
		button.BackgroundTransparency = 0;
	end
	EditCore:Apply("ClipDescendants", curBool, "GuiObject");
end);