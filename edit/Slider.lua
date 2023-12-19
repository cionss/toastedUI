local Slider = {};
local meta = {
    ["__index"] = Slider
};

type Slider = {
    ["Mouse"]: PluginMouse,
    ["Slider"]: Frame,
    ["Handle"]: TextButton,
    ["Direction"]: string
}

function Slider.new(mouse: PluginMouse, inst: Frame, handle: TextButton, direction: string): Slider
    local self = setmetatable({}, meta);

    self.Mouse = mouse;
    self.Slider = inst;
    self.Handle = handle;

    self.Direction = direction;

    if self.Direction == "X" then
        self.HandleCenter = self.Handle.Position.Y.Scale;
    elseif self.Direction == "Y" then
        self.HandleCenter = self.Handle.Position.X.Scale;
    end

    self.MouseDown = false;
    self.Hovering = false;
    self.HoveringSlider = false;

    self.Handle.MouseEnter:Connect(function(): nil
        self.Hovering = true;
    end);

    self.Handle.MouseLeave:Connect(function(): nil
        self.Hovering = false;
    end);

    self.Slider.MouseEnter:Connect(function(): nil
        self.HoveringSlider = true;
    end);

    self.Slider.MouseLeave:Connect(function(): nil
        self.HoveringSlider = false;
    end);

    mouse.Button1Down:Connect(function(): nil
        if self.Hovering or self.HoveringSlider then
            self.MouseDown = true;
            repeat
                local mousePos = self.Mouse[self.Direction];
                local defaultAnchorPos = self.Slider.AbsolutePosition[self.Direction] + (self.Slider.AbsoluteSize[self.Direction] * self.Slider.AnchorPoint[self.Direction]);
                local mouseObjectSpace = mousePos - defaultAnchorPos;
                local unit = mouseObjectSpace / self.Slider.AbsoluteSize[self.Direction];
                self:Slide(unit);
                task.wait();
            until self.MouseDown == false;
        end
    end);

    mouse.Button1Up:Connect(function(): nil
        self.MouseDown = false;
    end);

    return self;
end

function Slider:Slide(unit: number): nil
    unit = math.clamp(unit, 0, 1);

    if self.Direction == "X" then
        self.Handle.Position = UDim2.new(unit, 0, self.HandleCenter, 0);
    elseif self.Direction == "Y" then
        self.Handle.Position = UDim2.new(self.HandleCenter, 0, unit, 0);
    end
end

return Slider;