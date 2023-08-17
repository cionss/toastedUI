local curBool = false;
local button = script.Parent.ClipBooleanButton;

local editFrame = script:FindFirstAncestorWhichIsA("ScrollingFrame");
local EditCore = require(editFrame.Parent.Parent.EditCore);

button.MouseButton1Click:Connect(function()
	if curBool == true then
		curBool = false;
		button.BackgroundColor3 = Color3.fromRGB(25, 28, 36);
	else
		curBool = true;
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	end
	EditCore:Apply("ClipDescendants", curBool, "GuiObject");
end);