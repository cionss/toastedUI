local InputField = require(script.Parent.Parent.Parent.InputField);
local ColorPicker = require(script.Parent.Parent.Parent.ColorPicker.ColorPickerManager);





task.wait(2);
--| Appearance:
local appearance = script.Parent.Appearance;
--| GuiBase2d (NONE):
--| GuiObject:
local appearance_GuiObject = appearance.GuiBase2d.GuiObject.ClassProperties;
local a_go_bgc = InputField.Color3Input.new(
    "BackgroundColor3",
    "255, 255, 255",
    "Color3",
    appearance_GuiObject.Background.ColorRGB,
    {{appearance_GuiObject.Background.TransparentBackground.ColorPreview, "BackgroundColor3", Color3.fromRGB(255, 255, 255)}}
);
local a_go_bga = InputField.NumberInput.new(
    "BackgroundTransparency",
    0,
    0,
    1,
    "number",
    appearance_GuiObject.Background.ColorA,
    {{appearance_GuiObject.Background.TransparentBackground.ColorPreview, "BackgroundTransparency", 0}}
);
InputField.InputField:AttachHelpWindow(
    {appearance_GuiObject.Background.BackgroundTitle},
    appearance_GuiObject.Background.HelpFrame
);
appearance_GuiObject.Background.ColorPickerButtonHolder.ColorPicker.MouseButton1Click:Connect(function(): nil
	local r, g, b, a = ColorPicker:Prompt(a_go_bgc.Value, a_go_bga.Value);

	if r ~= nil then
        a_go_bgc:Update(r .. "," .. g .. "," .. b);
        a_go_bga:Update(a)
	end
end);



local a_go_br = InputField.Color3Input.new(
    "BorderColor3",
    "0, 0, 0",
    "Color3",
    appearance_GuiObject.Border.ColorRGB,
    {{appearance_GuiObject.Border.TransparentBackground.ColorPreview, "BackgroundColor3", Color3.fromRGB(0, 0, 0)}}
);
InputField.NumberInput.new(
    "BorderSizePixel",
    0,
    0,
    100000,
    "number",
    appearance_GuiObject.Border.SizeInput
);
InputField.DropdownInput.new(
    "BorderMode",
    "None",
    "string",
    appearance_GuiObject.Border.DropDownButton,
    appearance_GuiObject.Border.Mode
)
InputField.InputField:AttachHelpWindow(
    {appearance_GuiObject.Border.BorderTitle},
    appearance_GuiObject.Border.BorderHelpFrame
);
InputField.InputField:AttachHelpWindow(
    {appearance_GuiObject.Border.SizeTitle},
    appearance_GuiObject.Border.BorderSizeHelpFrame
);
InputField.InputField:AttachHelpWindow(
    {appearance_GuiObject.Border.ModeTitle},
    appearance_GuiObject.Border.BorderModeHelpFrame
);
appearance_GuiObject.Border.ColorPickerButtonHolder.ColorPicker.MouseButton1Click:Connect(function(): nil
	local r, g, b = ColorPicker:Prompt(a_go_br.Value, 0);

	if r ~= nil then
        a_go_br:Update(r .. "," .. g .. "," .. b);
	end
end);



InputField.ToggleButton.new(
    "ClipDescendants",
    false,
    "boolean",
    appearance_GuiObject.ClipDescendants.ClipBooleanButton
);
InputField.InputField:AttachHelpWindow(
    {appearance_GuiObject.ClipDescendants.ClipTitle},
    appearance_GuiObject.ClipDescendants.HelpFrame
);



InputField.ToggleButton.new(
    "Visible",
    true,
    "boolean",
    appearance_GuiObject.VisibleToggle.VisibleBooleanButton
);
InputField.InputField:AttachHelpWindow(
    {appearance_GuiObject.VisibleToggle.VisibleTitle},
    appearance_GuiObject.VisibleToggle.HelpFrame
);