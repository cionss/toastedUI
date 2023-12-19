local EditCore = require(script.Parent.EditCore);

local InputField = {};
InputField.__index = InputField;
InputField.__call = function(t: table): any
    return t.Value;
end

type InputField = {
    ["propertyName"]: string,
    ["value"]: any,
    ["itemClassType"]: string,
    ["inst"]: GuiBase2d,
    ["links"]: table,
};

function InputField:ValidateValue(valueType: string, value: any, min: number, max: number): any
    if value == "__%%%%mixedinput" then
        return value;
    end

    if valueType == "boolean" then

        if typeof(value) == valueType then
            return value;
        else
            warn("Invalid type for toggle button, expected boolean got "..typeof(value));
        end

    elseif valueType == "Color3" then

        local formatSuccess = true;
        local result, newColor;
        local success = pcall(function(): nil
            local split = table.pack(string.split(value, ","));
            if #split[1] ~= 3 then
                formatSuccess = false;
            else
                local r, g, b = table.unpack(split[1]);

                r = tostring(math.round(math.clamp(tonumber(r), 0, 255)));
                g = tostring(math.round(math.clamp(tonumber(g), 0, 255)));
                b = tostring(math.round(math.clamp(tonumber(b), 0, 255)));

                result = r..", "..g..", "..b;

                newColor = Color3.fromRGB(r, g, b);
            end
        end);

        if success and formatSuccess then
            return {result, newColor};
        else
            if typeof(value) == "string" then
                warn("Invalid string format for Color3 input, use r, g, b");
            else
                warn("Invalid type for Color3 input, got ".. typeof(value));
            end
            return false;
        end

    elseif valueType == "number" then

        if tonumber(value) == nil then
            warn("Unable to convert "..value.." to number from "..min.." to "..max);
            return false;
        end
        if typeof(tonumber(value)) == "number" then
            return math.clamp(tonumber(value), min, max);
        else
            warn("Invalid type for number input, got ".. typeof(value));
        end

    elseif valueType == "string" then

        if typeof(value) == valueType then
            return value;
        else
            warn("Invalid type for string input, got ".. typeof(value));
        end
    end
end

function InputField:Link(inst: Instance, property: string, mixedValue: any): nil
    table.insert(self.Links, {inst, property, mixedValue});
end

function InputField:UpdateLinks(): nil
    if self.Links == nil or self.Links == {} then return; end
    if self.Value == "__%%%%mixedinput" then
        for i, link in ipairs(self.Links) do
            link[1].link[2] = link[3];
        end
    else
        for i, link in ipairs(self.Links) do
            link[1][link[2]] = self.Value;
        end
    end
end

function InputField:AttachHelpWindow(hovers: table, window: GuiObject): nil
    local hoveringPieces = false;
    local hoveringHelpWindow = false;

    for i, piece: GuiObject in pairs(hovers) do
        piece.MouseEnter:Connect(function(): nil
            hoveringPieces = true;

            for timeout = 5, 0, -1 do
                task.wait(0.1);
                if not hoveringPieces then return; end
            end

            window.Visible = true;
        end);

        piece.MouseLeave:Connect(function(): nil
            hoveringPieces = false;

            task.wait(0.1);
            if not hoveringHelpWindow then
                window.Visible = false;
            end
        end);
    end

    window.MouseEnter:Connect(function(): nil
        hoveringHelpWindow = true;
    end);

    window.MouseLeave:Connect(function(): nil
        hoveringHelpWindow = false;

        task.wait(0.1);
        if not hoveringPieces then
            window.Visible = false;
        end
    end);
end

function InputField:Apply(): nil
    EditCore:Apply(self.Name, self.Value, self.ClassType);
end

local Selection = game:GetService("Selection");

function InputField.OnNewSelection(obj: InputField): nil
    if not plugin then return; end
    local newSelection = Selection:Get();

    local count = 0;
    local compareTo = newSelection[1];
    local mixed = false;
    for i, v in pairs(newSelection) do
        if v == compareTo then
            count += 1;
        else
            mixed = true;
            break;
        end
    end

    if mixed then
        obj:Update("__%%%%mixedinput");
    else
        obj:Update(compareTo);
    end
end;

--| Toggle Button (true/false)

local ToggleButton = {
    ["imgs"] = {
        [true] = "http://www.roblox.com/asset/?id=6031068421",
        [false] = "http://www.roblox.com/asset/?id=6031068420",
        ["__%%%%mixedinput"] = "http://www.roblox.com/asset/?id=6031068445"
    }
};
ToggleButton.__index = ToggleButton;
setmetatable(ToggleButton, InputField);

function ToggleButton.new(propertyName: string, value: any, itemClassType: string, inst: GuiBase2d, links: table): InputField
    local self = setmetatable({}, ToggleButton);

    self.Name = propertyName;

    self.ClassType = itemClassType;
    self.Instance = inst;

    self.Links = links or {};
    self:Update(value);

    self.Instance.MouseButton1Click:Connect(function(): nil
        if self.Value == true or self.Value == "__%%%%mixedinput" then
            self:Update(false);
        else
            self:Update(true)
        end
    end);

    Selection.SelectionChanged:Connect(function(): nil
        InputField.OnNewSelection(self);
    end);

    return self;
end

function ToggleButton:Update(newValue: any): nil
    if self:ValidateValue(self.ClassType, newValue) == nil then
        return;
    end
    self.Value = newValue;
    self.Instance.Image = self.imgs[self.Value];
    self:UpdateLinks();
end

--| Number input

local NumberInput = {};
NumberInput.__index = NumberInput;
setmetatable(NumberInput, InputField);

function NumberInput.new(propertyName: string, value: any, min: number, max: number, itemClassType: string, inst: GuiObject, links: table): InputField
    local self = setmetatable({}, NumberInput);

    self.Name = propertyName;

    self.ClassType = itemClassType;
    self.Instance = inst;
    self.Min = min;
    self.Max = max;

    self.Links = links or {};
    self:Update(value);

    self.Instance.FocusLost:Connect(function(): nil
        local text = self.Instance.Text;
        if tostring(text) ~= nil then
            local newNumber = math.clamp(math.round(tonumber(text) * 1000) / 1000, self.Min, self.Max);
            self:Update(newNumber);
        end
    end);

    Selection.SelectionChanged:Connect(function(): nil
        InputField.OnNewSelection(self);
    end);

    return self;
end

function NumberInput:Update(newValue: any): nil
    local validNum = self:ValidateValue(self.ClassType, newValue, self.Min, self.Max);
    if validNum then
        if validNum == "__%%%%mixedinput" then
            self.Value = "__%%%%mixedinput";
            self.Instance.Text = "-";
        else
            self.Value = validNum;
            self.Instance.Text = tostring(math.round(validNum * 100) / 100);
        end
        self:UpdateLinks();
    end
end

--| Color3 input (rgb)

local Color3Input = {};
Color3Input.__index = Color3Input;
setmetatable(Color3Input, InputField);

function Color3Input.new(propertyName: string, value: any, itemClassType: string, inst: GuiObject, links: table): InputField
    local self = setmetatable({}, Color3Input);

    self.Name = propertyName;

    self.ClassType = itemClassType;
    self.Instance = inst;

    self.Links = links or {};
    self:Update(value);

    self.Instance.FocusLost:Connect(function(): nil
        self:Update(self.Instance.Text);
    end);

    Selection.SelectionChanged:Connect(function(): nil
        InputField.OnNewSelection(self);
    end);

    return self;
end

function Color3Input:Update(newValue: any): nil
    local convertColor = self:ValidateValue(self.ClassType, newValue);
    if convertColor then
        if convertColor == "__%%%%mixedinput" then
            self.Instance.Text = "mixed";
            self.Value = "__%%%%mixedinput";
        else
            self.Instance.Text = convertColor[1];
            self.Value = convertColor[2];
        end
        self:UpdateLinks();
    end
end

--| Dropdown input (select)

local DropdownInput = {};
DropdownInput.__index = DropdownInput;
setmetatable(DropdownInput, InputField);

function DropdownInput.new(propertyName: string, value: any, itemClassType: string, inst: GuiButton, dropdown: GuiObject, links: table): InputField
    local self = setmetatable({}, DropdownInput);

    self.Name = propertyName;

    self.ClassType = itemClassType;
    self.Instance = inst;
    self.dropdown = dropdown;

    self.Links = links or {};
    self:Update(value);

    self.Instance.MouseButton1Click:Connect(function(): nil
        self.dropdown.DropDownWindow.Visible = not self.dropdown.DropDownWindow.Visible;
    end);

    for i, v: GuiButton in pairs(self.dropdown.DropDownWindow:GetChildren()) do
        v.MouseButton1Click:Connect(function(): nil
            self:Update(v.Name);
            self.dropdown.DropDownWindow.Visible = false;
        end);
    end

    Selection.SelectionChanged:Connect(function(): nil
        InputField.OnNewSelection(self);
    end);

    return self;
end

function DropdownInput:Update(newValue: any): nil
    local validValue = self:ValidateValue(self.ClassType, newValue);
    if validValue then
        if validValue == "__%%%%mixedinput" then
            self.dropdown.Text = "mixed";
            self.Value = "__%%%%mixedinput";
        else
            self.dropdown.Text = validValue;
            self.Value = validValue;
        end
        self:UpdateLinks();
    end
end

return {
    ["InputField"] = InputField,
    ["ToggleButton"] = ToggleButton,
    ["NumberInput"] = NumberInput,
    ["Color3Input"] = Color3Input,
    ["DropdownInput"] = DropdownInput
};
