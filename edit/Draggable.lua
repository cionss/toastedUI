local User = plugin or game.Players.LocalPlayer;
local mouse = User:GetMouse();

local hoveringHandle = false;
local holdingHandle = false;

script.Parent.MouseEnter:Connect(function()
	hoveringHandle = true;
end);

script.Parent.MouseLeave:Connect(function()
	hoveringHandle = false;
end);

mouse.Button1Down:Connect(function()
	if hoveringHandle then
		holdingHandle = true
		local mousePos = Vector2.new(mouse.X, mouse.Y);
		local mouseOffset = mousePos - script.Parent.Parent.AbsolutePosition;
		repeat
			local newMousePos = Vector2.new(mouse.X, mouse.Y);
			local targetPosition = newMousePos - mouseOffset;

			script.Parent.Parent.Position = UDim2.new(0,  targetPosition.X, 0, targetPosition.Y);
			task.wait();
		until holdingHandle == false
	end
end);

mouse.Button1Up:Connect(function()
	holdingHandle = false;
end);