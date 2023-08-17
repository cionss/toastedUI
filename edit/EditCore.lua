local EditCore = {};
EditCore.Selection = {};

local EditWindow = script.Parent.EditMain;
local EditingWindow = EditWindow.EditingWindow;

local ClassHierarchy = {
    ["GuiBase2d"] = {
        ["GuiObject"] = {
            ["TextObject"] = {
                ["TextButton"] = {},
                ["TextBox"] = {}
            },
            ["ImageObject"] = {
                ["ImageButton"] = {}
            },
            ["Frame"] = {},
            ["ScrollingFrame"] = {}
        }
    },
    ["UIObject"] = {
        
    }
};

function GetClassesOfInstance(inst: Instance)
    local classes = {};
    if inst:IsA("GuiBase2d") then
        table.insert(classes, "GuiBase2d");
    end
    if inst:IsA("GuiObject") then
        table.insert(classes, "GuiObject");
    end
    if inst:IsA("TextLabel") then
        table.insert(classes, "TextObject");
    end
    if inst:IsA("TextButton") then
        table.insert(classes, "TextObject");
        table.insert(classes, "TextButton");
    end
    if inst:IsA("TextBox") then
        table.insert(classes, "TextObject");
        table.insert(classes, "TextBox");
    end
    if inst:IsA("ImageLabel") then
        table.insert(classes, "ImageObject");
    end
    if inst:IsA("ImageButton") then
        table.insert(classes, "ImageObject");
        table.insert(classes, "ImageButton");
    end
    if inst:IsA("Frame") then
        table.insert(classes, "Frame");
    end
    if inst:IsA("ScrollingFrame") then
        table.insert(classes, "ScrollingFrame");
    end

    return classes;
end

function recurseClasses(classes: table, t: table, inst: Instance)
    for key, value in pairs(t) do
        for _, class: string in pairs(classes) do
            if class == key then
                inst[key].Visible = true;
                recurseClasses(classes, value, inst[key]);
            end
        end
    end
end

function EditCore:Select(selection: table)
    table.clear(EditCore.Selection);
    for index: number, v: Instance in pairs(selection) do
        --| Get selection classes:
        local classes = GetClassesOfInstance(v);

        table.insert(EditCore.Selection, {
            ["Inst"] = v,
            ["Classes"] = classes
        });

        --| Show sections of the UI by each elements classes:

        for _, category: Instance in pairs(EditingWindow:GetChildren()) do
            recurseClasses(classes, ClassHierarchy, category);
        end
    end
end

function EditCore:Apply(property: string, value: any, classType: string)
    for _, item: table in pairs(EditCore.Selection) do
        local inst, classes = table.unpack(item);

        for i, class: string in pairs(classes) do
            if class == classType then
                inst[property] = value;
            end
        end
    end
end

return EditCore;