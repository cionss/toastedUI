local max = 10;
local cur = 5;

local outline = script.Parent.Outline.Block;
local middle = script.Parent.Middle.Block;
local inset = script.Parent.Inset.Block;
local size = script.Parent.SizeDisplay;

while true do
    task.wait(0.5);
    if script.Parent.Visible then
        if cur == max then
            cur = 1;
        else
            cur += 1;
        end

        outline.BorderSizePixel = cur;
        middle.BorderSizePixel = cur;
        inset.BorderSizePixel = cur;
        size.Text = "Size: "..cur.."px";
    end
end