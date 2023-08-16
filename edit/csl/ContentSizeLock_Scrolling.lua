local UIListLayout = script.Parent;
local ParentFrame = UIListLayout.Parent;

local lockDirection = "Y"; --| X, Y, or XY

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	local newContentSize = UIListLayout.AbsoluteContentSize;
	
	if lockDirection == "X" then
		ParentFrame.CanvasSize = UDim2.new(0, newContentSize.X, 0, 0);
	elseif lockDirection == "Y" then
		ParentFrame.CanvasSize = UDim2.new(0, 0, 0, newContentSize.Y);
	elseif lockDirection == "XY" then
		ParentFrame.CanvasSize = UDim2.new(0, newContentSize.X, 0, newContentSize.Y);
	end
end);