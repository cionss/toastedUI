local ColorPicker = {};
local ColorPickerGui = script.Parent;

local TweenService = game:GetService("TweenService");
local Slider = require(ColorPickerGui.Parent:WaitForChild("Slider", 5));
local user = plugin or game.Players.LocalPlayer;
local mouse = user:GetMouse();

local currentColorMode = "HSV";
local hue = 0;
local saturation = 0;
local value = 1;
local red = 255;
local green = 255;
local blue = 255;
local alpha = 0;
local hex = "FFFFFF"

local function ConvertMode(val1: number, val2: number, val3: number, target: string): any
	if target == "HSV" then
		--| RGB to HSV:
		local r, g, b = val1 / 255, val2 / 255, val3 / 255;

		local max, min = math.max(r, g, b), math.min(r, g, b);
		local h, s, v;
		v = max;

		local d = max - min;
		if max == 0 then s = 0; else s = d / max; end

		if max == min then
			h = 0;
		else
			if max == r then
				h = (g - b) / d;
				if g < b then h = h + 6; end
			elseif max == g then h = (b - r) / d + 2;
			elseif max == b then h = (r - g) / d + 4;
			end
			h = h / 6;
		end

		return h * 360, s, v;
	elseif target == "RGB" then
		--| HSV to RGB:
		local h, s, v = val1 / 360, val2, val3;

		local r, g, b;

		local i = math.floor(h * 6);
		local f = h * 6 - i;
		local p = v * (1 - s);
		local q = v * (1 - f * s);
		local t = v * (1 - (1 - f) * s);

		i = i % 6;

		if i == 0 then r, g, b = v, t, p;
		elseif i == 1 then r, g, b = q, v, p;
		elseif i == 2 then r, g, b = p, v, t;
		elseif i == 3 then r, g, b = p, q, v;
		elseif i == 4 then r, g, b = t, p, v;
		elseif i == 5 then r, g, b = v, p, q;
		end

		return r * 255, g * 255, b * 255;
	end
end

local function RGBtoHex(r: number, g: number, b: number): string
	local hexadecimal = "#";

	for _, v: number in pairs({r, g, b}) do
		local newhex = "";

		while v > 0 do
			local index = math.fmod(v, 16) + 1;
			v = math.floor(v / 16);
			newhex = string.sub("0123456789abcdef", index, index)..newhex;
		end

		if string.len(newhex) == 0 then
			newhex = "00";
		elseif string.len(newhex) == 1 then
			newhex = "0"..newhex;
		end

		hexadecimal = hexadecimal..newhex;
	end

	return hexadecimal;
end

local function HextoRGB(hex: string): any
	hex = hex:gsub("#", "");
	return tonumber("0x"..hex:sub(1, 2)), tonumber("0x"..hex:sub(3, 4)), tonumber("0x"..hex:sub(5, 6));
end

--| Create sliders and varialbes for ui elements:

local globalGuis = ColorPickerGui.GlobalGuis;
local ColorPreview = globalGuis.TransparentBackground.ColorPreview;

local alphaSlider = Slider.new(mouse, globalGuis.AlphaSlider, globalGuis.AlphaSlider.SliderHandle, "X");
local alphaInput = globalGuis.AlphaInput;

local hexInput = globalGuis.HexInput;



local ColorWheel = ColorPickerGui.ColorWheel;

local InteractiveWheel = ColorWheel.ColorWheelImage;
local InteractiveWheelCursor = InteractiveWheel.Cursor;
local mouseClickingWheel = false;
local mouseHoveringWheel = false;

local WheelRadius = InteractiveWheel.AbsoluteSize.Y / 2;
InteractiveWheel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function(): nil
	WheelRadius = InteractiveWheel.AbsoluteSize.Y / 2;
end);

local valueSlider = Slider.new(mouse, ColorWheel.ValueSlider, ColorWheel.ValueSlider.SliderHandle, "Y");
local valueInput = ColorWheel.ValueInput



local RGBWindow = ColorPickerGui.RGB;

local redSlider = Slider.new(mouse, RGBWindow.RedSlider, RGBWindow.RedSlider.SliderHandle, "X");
local redInput = RGBWindow.RedInput;

local blueSlider = Slider.new(mouse, RGBWindow.BlueSlider, RGBWindow.BlueSlider.SliderHandle, "X");
local blueInput = RGBWindow.BlueInput;

local greenSlider = Slider.new(mouse, RGBWindow.GreenSlider, RGBWindow.GreenSlider.SliderHandle, "X");
local greenInput = RGBWindow.GreenInput;



local HSVWindow = ColorPickerGui.HSV;

local hueSlider = Slider.new(mouse, HSVWindow.HueSlider, HSVWindow.HueSlider.SliderHandle, "X");
local hueInput = HSVWindow.HueInput;

local saturationSlider = Slider.new(mouse, HSVWindow.SaturationSlider, HSVWindow.SaturationSlider.SliderHandle, "X");
local saturationInput = HSVWindow.SaturationInput;

local hsvValueSlider = Slider.new(mouse, HSVWindow.ValueSlider, HSVWindow.ValueSlider.SliderHandle, "X");
local hsvValueInput = HSVWindow.ValueInput;



--| Functions for adjusting all sliders and things to the current color, as well as rendering the color in the color preview:



function round(num: number, decimalPoints: number): number
	local inc = 10 ^ decimalPoints;
	return (math.round(num * inc)) / inc;
end

local function RenderColor(): nil
	if currentColorMode == "HSV" then
		ColorPreview.BackgroundColor3 = Color3.fromHSV(hue / 360, saturation, value);
		red, green, blue = ConvertMode(hue, saturation, value, "RGB");
		hex = RGBtoHex(red, green, blue);
	elseif currentColorMode == "RGB" then
		ColorPreview.BackgroundColor3 = Color3.fromRGB(red, green, blue);
		hue, saturation, value = ConvertMode(red, green, blue, "HSV");
		hex = RGBtoHex(red, green, blue)
	elseif currentColorMode == "Hex" then
		ColorPreview.BackgroundColor3 = Color3.fromHex(hex);
		red, green, blue = HextoRGB(hex);
		hue, saturation, value = ConvertMode(red, green, blue, "HSV");
	end
end

local updateDebounce = false;

function UpdateColorSystems(exclusion: Instance): nil
	if updateDebounce then
		return;
	end

	updateDebounce = true;
	RenderColor();
	task.wait();
	InteractiveWheel.ImageColor3 = Color3.fromHSV(0, 0, value);
	if exclusion ~= valueSlider then
		valueSlider:Slide(1 - value);
	end
	valueInput.Text = tostring(round(value, 2));

	if exclusion ~= redSlider then
		redSlider:Slide(red / 255);
	end
	redInput.Text = tostring(round(red, 0));
	redSlider.Slider.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, green, blue)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, green, blue))
	};

	if exclusion ~= greenSlider then
		greenSlider:Slide(green / 255);
	end
	greenInput.Text = tostring(round(green, 0));
	greenSlider.Slider.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(red, 0, blue)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(red, 255, blue))
	};

	if exclusion ~= blueSlider then
		blueSlider:Slide(blue / 255);
	end
	blueInput.Text = tostring(round(blue, 0));
	blueSlider.Slider.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(red, green, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(red, green, 255))
	};

	if exclusion ~= hueSlider then
		hueSlider:Slide(hue / 360);
	end
	hueInput.Text = tostring(round(hue, 0)).."°";
	hueSlider.Slider.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, saturation, value)),
		ColorSequenceKeypoint.new(0.1, Color3.fromHSV(0.1, saturation, value)),
		ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, saturation, value)),
		ColorSequenceKeypoint.new(0.3, Color3.fromHSV(0.3, saturation, value)),
		ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, saturation, value)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, saturation, value)),
		ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, saturation, value)),
		ColorSequenceKeypoint.new(0.7, Color3.fromHSV(0.7, saturation, value)),
		ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, saturation, value)),
		ColorSequenceKeypoint.new(0.9, Color3.fromHSV(0.9, saturation, value)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, saturation, value))
	};

	if exclusion ~= saturationSlider then
		saturationSlider:Slide(saturation);
	end
	saturationInput.Text = tostring(round(saturation, 2));
	saturationSlider.Slider.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, Color3.fromHSV(hue / 360, 0, value)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(hue / 360, 1, value ))
	};

	if exclusion ~= hsvValueSlider then
		hsvValueSlider:Slide(value);
	end
	hsvValueInput.Text = tostring(round(value, 2));
	hsvValueSlider.Slider.UIGradient.Color = ColorSequence.new
	{
		ColorSequenceKeypoint.new(0, Color3.fromHSV(hue / 360, saturation, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(hue / 360, saturation, 1))
	};

	if exclusion ~= hexInput then
		hexInput.Text = hex;
	end
	--| Big wheel:

	if exclusion ~= InteractiveWheel then
		local length = saturation * WheelRadius;
		local angle = hue;

		local x = length * math.cos(math.rad(angle));
		local y = length * math.sin(math.rad(angle));

		local unitX = ((x / WheelRadius) / 2) + 0.5;
		local unitY = ((y / WheelRadius) / 2) + 0.5;

		InteractiveWheelCursor.Position = UDim2.new(unitX, 0, unitY, 0);
		InteractiveWheel.ImageColor3 = Color3.fromHSV(0, 0, value);
	end

	updateDebounce = false;
end

--| All slider and text box updating:

--| Color wheel:

InteractiveWheel.MouseEnter:Connect(function(): nil
	mouseHoveringWheel = true;
end);

InteractiveWheel.MouseLeave:Connect(function(): nil
	mouseHoveringWheel = false;
end);

mouse.Button1Down:Connect(function(): nil
	if mouseHoveringWheel then
		mouseClickingWheel = true;
		repeat
			local x, y = mouse.X, mouse.Y;

			local anchorX = InteractiveWheel.AbsolutePosition.X + (InteractiveWheel.AbsoluteSize.X * InteractiveWheel.AnchorPoint.X);
			local anchorY = InteractiveWheel.AbsolutePosition.Y + (InteractiveWheel.AbsoluteSize.Y * InteractiveWheel.AnchorPoint.Y);

			local objectX = x - anchorX;
			local objectY = y - anchorY;

			local length = math.sqrt((objectX ^ 2) + (objectY ^ 2));
			local angle = math.deg(math.atan2(objectY, objectX));
			if length <= WheelRadius then
				local unitX = ((objectX / WheelRadius) / 2) + 0.5;
				local unitY = ((objectY / WheelRadius) / 2) + 0.5;

				InteractiveWheelCursor.Position = UDim2.new(unitX, 0, unitY, 0);

				currentColorMode = "HSV";
				if angle < 0 then
					hue = angle + 360;
				elseif angle >= 0 then
					hue = angle;
				end
				saturation = length / WheelRadius;
				UpdateColorSystems(InteractiveWheel);
			elseif length > WheelRadius then

				local newX = WheelRadius * math.cos(math.rad(angle));
				local newY = WheelRadius * math.sin(math.rad(angle));

				local unitX = ((newX / WheelRadius) / 2) + 0.5;
				local unitY = ((newY / WheelRadius) / 2) + 0.5;

				InteractiveWheelCursor.Position = UDim2.new(unitX, 0, unitY, 0);

				currentColorMode = "HSV";
				if angle < 0 then
					hue = angle + 360;
				elseif angle >= 0 then
					hue = angle;
				end
				saturation = 1;

				UpdateColorSystems(InteractiveWheel);
			end

			task.wait();
		until mouseClickingWheel == false;
	end
end);

mouse.Button1Up:Connect(function(): nil
	mouseClickingWheel = false;
end);

--| Alpha slider and input:

alphaSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	alpha = alphaSlider.Handle.Position.X.Scale;
	alphaInput.Text = tostring(round(alpha, 2));
	ColorPreview.BackgroundTransparency = alpha;
end);

alphaInput.FocusLost:Connect(function(): nil
	local newText = alphaInput.Text;
	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 1);
		newText = tostring(number);
	else
		alphaInput.Text = tostring(round(alpha, 2));
	end
end);

--| Hex input:

hexInput.FocusLost:Connect(function(): nil
	local success = pcall(function(): nil
		local try = Color3.fromHex(hexInput.Text);
		try = nil;
	end);

	if success then
		currentColorMode = "Hex";
		UpdateColorSystems(hexInput);
	else
		hexInput.Text = hex;
	end
end)

--| Value slider and input:

valueSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	value = 1 - valueSlider.Handle.Position.Y.Scale;
	currentColorMode = "HSV";
	UpdateColorSystems(valueSlider);
end);

valueInput.FocusLost:Connect(function(): nil
	local newText = valueInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 1);
		newText = tostring(number);
		value = number;
		UpdateColorSystems();
	else
		valueInput.Text = tostring(round(value, 2));
	end
end);

--| RGB sliders and inputs:

redSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	red = redSlider.Handle.Position.X.Scale * 255;
	currentColorMode = "RGB";
	UpdateColorSystems(redSlider);
end);

redInput.FocusLost:Connect(function(): nil
	local newText = redInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 255);
		newText = tostring(number);
		red = number;
		currentColorMode = "RGB";
		UpdateColorSystems();
	else
		redInput.Text = tostring(round(red, 0));
	end
end);

greenSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	green = greenSlider.Handle.Position.X.Scale * 255;
	currentColorMode = "RGB";
	UpdateColorSystems(greenSlider);
end);

greenInput.FocusLost:Connect(function(): nil
	local newText = greenInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 255);
		newText = tostring(number);
		green = number;
		currentColorMode = "RGB";
		UpdateColorSystems();
	else
		greenInput.Text = tostring(round(green, 0));
	end
end);

blueSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	blue = blueSlider.Handle.Position.X.Scale * 255;
	currentColorMode = "RGB";
	UpdateColorSystems(blueSlider);
end);

blueInput.FocusLost:Connect(function(): nil
	local newText = blueInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 255);
		newText = tostring(number);
		blue = number;
		currentColorMode = "RGB";
		UpdateColorSystems();
	else
		blueInput.Text = tostring(round(blue, 0));
	end
end);

--| HSV sliders and inputs:

hueSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	hue = hueSlider.Handle.Position.X.Scale * 360;
	currentColorMode = "HSV";
	UpdateColorSystems(hueSlider);
end);

hueInput.FocusLost:Connect(function(): nil
	local newText = hueInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 360);
		newText = tostring(number);
		hue = number;
		currentColorMode = "HSV";
		UpdateColorSystems();
	else
		hueInput.Text = tostring(round(hue, 0)).."°";
	end
end);

saturationSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	saturation = saturationSlider.Handle.Position.X.Scale;
	currentColorMode = "HSV";
	UpdateColorSystems(saturationSlider);
end);

saturationInput.FocusLost:Connect(function(): nil
	local newText = saturationInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 1);
		newText = tostring(number);
		saturation = number;
		currentColorMode = "HSV";
		UpdateColorSystems();
	else
		saturationInput.Text = tostring(round(saturation, 2));
	end
end);

hsvValueSlider.Handle:GetPropertyChangedSignal("Position"):Connect(function(): nil
	value = hsvValueSlider.Handle.Position.X.Scale;
	currentColorMode = "HSV";
	UpdateColorSystems(hsvValueSlider);
end);

hsvValueInput.FocusLost:Connect(function(): nil
	local newText = hsvValueInput.Text;

	if tonumber(newText) ~= nil then
		local number = tonumber(newText);
		number = math.clamp(number, 0, 1);
		newText = tostring(number);
		value = number;
		currentColorMode = "HSV";
		UpdateColorSystems();
	else
		hsvValueInput.Text = tostring(round(value, 2));
	end
end);

--| Buttons for switching windows:

local Buttons = ColorPickerGui.TabButtons;
local Windows = {ColorWheel, RGBWindow, HSVWindow}

for i, v: GuiObject in pairs(Buttons:GetChildren()) do
	v.MouseButton1Click:Connect(function(): nil
		for _, window: Instance in pairs(Windows) do
			if window.Name == v.Name then
				window.Visible = true;
			else
				window.Visible = false;
			end
		end
	end);
end

--| Handle dragging:

local handle = ColorPickerGui.Handle;
local hoveringHandle = false
local holdingHandle = false

handle.MouseEnter:Connect(function(): nil
	hoveringHandle = true;
end);

handle.MouseLeave:Connect(function(): nil
	hoveringHandle = false;
end);

mouse.Button1Down:Connect(function(): nil
	if hoveringHandle then
		holdingHandle = true;
		local mousePos = Vector2.new(mouse.X, mouse.Y);
		local mouseOffset = mousePos - ColorPickerGui.AbsolutePosition;
		repeat
			local newMousePos = Vector2.new(mouse.X, mouse.Y);
			local targetPosition = newMousePos - mouseOffset;

			ColorPickerGui.Position = UDim2.new(0,  targetPosition.X, 0, targetPosition.Y);
			task.wait();
		until holdingHandle == false;
	end
end);

mouse.Button1Up:Connect(function(): nil
	holdingHandle = false;
end)

--| Confirm / cancel button:

local FinishedEvent = ColorPickerGui.Finished;
local closeX = handle.Cancel
local confirmButtons = {ColorPickerGui.ConfirmButtons.Confirm, ColorPickerGui.ConfirmButtons.Cancel, closeX};

local closeXTweenIn = TweenService:Create(closeX, TweenInfo.new(0.2), {
	["BackgroundColor3"] = Color3.new(1, 0, 0),
	["TextColor3"] = Color3.new(1, 1, 1);
});

local closeXTweenOut = TweenService:Create(closeX, TweenInfo.new(0.2), {
	["BackgroundColor3"] = Color3.new(1, 1, 1),
	["TextColor3"] = Color3.new(0, 0, 0);
});

local hoveringCloseX = false;

closeX.MouseEnter:Connect(function(): nil
	closeXTweenIn:Play();
	hoveringCloseX = true;
end);

closeX.MouseLeave:Connect(function(): nil
	closeXTweenOut:Play();
	hoveringCloseX = false;
end);

mouse.Button1Up:Connect(function(): nil
	if hoveringCloseX then
		FinishedEvent:Fire("x");
	end
end);

for _, button: GuiObject in pairs(confirmButtons) do
	local hovering = false;
	button.MouseEnter:Connect(function(): nil
		hovering = true;
	end);

	button.MouseLeave:Connect(function(): nil
		hovering = false;
	end);

	mouse.Button1Up:Connect(function(): nil
		if hovering then
			FinishedEvent:Fire(button.Name);
		end
	end);
end

UpdateColorSystems();

--| Prompting color picker and returning values:

function ColorPicker:Prompt(curColor: Color3, curAlpha: number): any
	currentColorMode = "RGB";
	red, green, blue = curColor.R * 255, curColor.G * 255, curColor.B * 255;
	alpha = curAlpha;
	UpdateColorSystems();
	alphaSlider:Slide(alpha);

	ColorPickerGui.Visible = true;

	local exitType = FinishedEvent.Event:Wait();

	if exitType == "Confirm" then
		ColorPickerGui.Visible = false;
		return red, green, blue, alpha;
	else
		ColorPickerGui.Visible = false;
		return nil;
	end
end

return ColorPicker;