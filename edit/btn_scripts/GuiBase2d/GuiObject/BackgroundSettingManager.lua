local TweenService = game:GetService("TweenService");
local curColor = Color3.fromRGB(255, 255, 255);
local curAlpha = 0;

local thisColorSettings = script.Parent;
local editFrame = script:FindFirstAncestorWhichIsA("ScrollingFrame");
local EditCore = require(editFrame.Parent.Parent.EditCore);

function updateUIs()
	thisColorSettings.TransparentBackground.ColorPreview.BackgroundColor3 = curColor;
	thisColorSettings.TransparentBackground.ColorPreview.BackgroundTransparency = curAlpha;
	
	local toStringColor = tostring(math.round(curColor.R * 255))..", "..tostring(math.round(curColor.G * 255))..", "..tostring(math.round(curColor.B * 255))
	thisColorSettings.ColorRGB.Text = toStringColor;
	thisColorSettings.ColorA.Text = tostring(math.round(curAlpha * 100) / 100);

    EditCore:Apply("BackgroundColor3", curColor, "GuiObject");
    EditCore:Apply("BackgroundTransparency", curAlpha, "GuiObject");
end

function ConvertTextToRGB(text: string)
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
	local r, g, b, a = ColorPicker:Prompt(curColor, curAlpha);
	
	if r ~= nil then
		curColor = Color3.fromRGB(r, g, b);
		curAlpha = a;
		
		updateUIs();
	end
end);

script.Parent.ColorRGB.FocusLost:Connect(function() 
	ConvertTextToRGB(script.Parent.ColorRGB.Text);	
end);

script.Parent.ColorA.FocusLost:Connect(function()
	local text = script.Parent.ColorA.Text
	if tostring(text) ~= nil then
		local newNumber = math.clamp(math.round(tonumber(text) * 1000) / 1000, 0, 1);
		curAlpha = newNumber;
		text = tostring(newNumber);
		
		updateUIs();
	else
		text = curAlpha;
	end
end);

--| Help frame:

local bgTitle = script.Parent.BackgroundTitle;
local helpFrame = script.Parent.HelpFrame;

bgTitle.MouseEnter:Connect(function()
	bgTitle.MouseLeave:Connect(function()
		helpFrame.Visible = false;
		return;
	end);
	task.wait(1);
	helpFrame.Visible = true;
end);