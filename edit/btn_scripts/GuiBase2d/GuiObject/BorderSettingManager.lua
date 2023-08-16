local curColor = Color3.fromRGB(0, 0, 0);
local curSize = 0;
local curMode = "Outline";

local thisColorSettings = script.Parent;
local editFrame = script:FindFirstAncestorWhichIsA("ScrollingFrame");
local EditCore = require(editFrame.Parent.Parent.EditCore);

function updateUIs()
	thisColorSettings.TransparentBackground.ColorPreview.BackgroundColor3 = curColor;

	local toStringColor = tostring(math.round(curColor.R * 255))..", "..tostring(math.round(curColor.G * 255))..", "..tostring(math.round(curColor.B * 255))
	thisColorSettings.ColorRGB.Text = toStringColor;

	EditCore:Apply("BorderColor3", curColor, "GuiObject");
	EditCore:Apply("BorderSizePixel", curSize, "GuiObject");
	EditCore:Apply("BorderMode", Enum.BorderMode[curMode], "GuiObject");
end

function ConvertTextToRGB(text)
	local formatSuccess = true;
	local result;
	local success, err = pcall(function()
		local split = table.pack(string.split(text, ","));
		if #split[1] ~= 3 then
			formatSuccess = false;
		else
			local r, g, b = table.unpack(split[1]);
			print(r, g, b);

			r = tostring(math.round(math.clamp(tonumber(r), 0, 255)));
			g = tostring(math.round(math.clamp(tonumber(g), 0, 255)));
			b = tostring(math.round(math.clamp(tonumber(b), 0, 255)));

			result = r..", "..g..", "..b;

			curColor = Color3.fromRGB(r, g, b); 
		end
	end);

	if success and formatSuccess then
		text = result;
		updateUIs();
	else
		warn(err);
	end
end

script.Parent.ColorPickerButtonHolder.ColorPicker.MouseButton1Click:Connect(function()
	local ColorPicker = require(editFrame.Parent.Parent.ColorPicker.ColorPickerManager);
	local r, g, b, a = ColorPicker:Prompt(curColor, 0);

	if r ~= nil then
		curColor = Color3.fromRGB(r, g, b);

		updateUIs();
	end
end);

script.Parent.ColorRGB.FocusLost:Connect(function() 
	ConvertTextToRGB(script.Parent.ColorRGB.Text);
end);

local dropDownButton = script.Parent.DropDownButton;
local droppedDown = false;
local modeGui = script.Parent.Mode;
local dropDownWindow = modeGui.DropDownWindow;

local sizeTitleGui = script.Parent.SizeTitle;
local sizeGui = script.Parent.SizeInput;

dropDownButton.MouseButton1Click:Connect(function()
	if droppedDown == true then
		droppedDown = false;
		dropDownButton.Rotation = 0;
		dropDownWindow.Visible = false;
	elseif droppedDown == false then
		droppedDown = true;
		dropDownButton.Rotation = 180;
		dropDownWindow.Visible = true;
	end
end);

for i, choice in pairs(dropDownWindow:GetChildren()) do
	choice.MouseButton1Click:Connect(function()
		local optionChosen = choice.Name;
		if optionChosen == "None" then
			sizeTitleGui.TextColor3 = Color3.fromRGB(55, 62, 79);
			sizeTitleGui.Text = "<s>size:</s>";
			sizeGui.TextColor3 = Color3.fromRGB(34, 39, 49);
			sizeGui.TextEditable = false;
			curSize = 0;
			
			modeGui.Text = optionChosen;
			droppedDown = false;
			dropDownButton.Rotation =  0;
			dropDownWindow.Visible = false;
		else
			sizeTitleGui.TextColor3 = Color3.fromRGB(255, 255, 255);
			sizeTitleGui.Text = "size:";
			sizeGui.TextColor3 = Color3.fromRGB(255, 255, 255);
			sizeGui.TextEditable = true;
			
			modeGui.Text = optionChosen;
			droppedDown = false;
			dropDownButton.Rotation =  0;
			dropDownWindow.Visible = false;
		end

		updateUIs();
	end);
end