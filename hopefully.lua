local CurrentCamera = game:GetService("Workspace").CurrentCamera
local Inset = game:GetService("GuiService"):GetGuiInset().Y
local RunService = game:GetService("RunService")

local Mouse = game.Players.LocalPlayer:GetMouse()
local LocalPlayer = game.Players.LocalPlayer

local Line = Drawing.new("Line")
local Circle = Drawing.new("Circle")

local Plr = game.Players.LocalPlayer

Mouse.KeyDown:Connect(function(KeyPressed)
    if KeyPressed == getgenv().SilentKey then
        if getgenv().SilentEnabled == true then
            getgenv().SilentEnabled = false
            if getgenv().SilentNotifs == true then
                Plr = FindClosestPlayer()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "p",
                    Text = "Unlocked"
                })
            end
        else
            Plr = FindClosestPlayer()
            getgenv().SilentEnabled = true
            if getgenv().SilentNotifs == true then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "p",
                    Text = "Locked On :  " .. tostring(Plr.Character.Humanoid.DisplayName)
                })
            end
        end
    end
end)

function FindClosestPlayer()
    local ClosestDistance, ClosestPlayer = math.huge, nil;
    for _, Player in next, game:GetService("Players"):GetPlayers() do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character.Humanoid.Health > 1 then 
                local Position, IsVisibleOnViewPort = CurrentCamera:WorldToViewportPoint(Character.HumanoidRootPart
                                                                                             .Position)
                if IsVisibleOnViewPort then
                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude
                    if Distance < ClosestDistance then
                        ClosestPlayer = Player
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end
    return ClosestPlayer, ClosestDistance
end

RunService.Heartbeat:connect(function()
    if getgenv().SilentEnabled == true then
        local Vector = CurrentCamera:WorldToViewportPoint(Plr.Character[getgenv().SilentAimpart].Position +
                                                              (Plr.Character[getgenv().SilentAimpart].Velocity *
                                                              getgenv().SilentPrediction))
        Line.Color = Settings.Settings.Color
        Line.Transparency = Settings.Settings .Transparency
        Line.Thickness = Settings.Settings .Thickness
        Line.From = Vector2.new(Mouse.X, Mouse.Y + Inset)
        Line.To = Vector2.new(Vector.X, Vector.Y)
        Line.Visible = true
        Circle.Position = Vector2.new(Mouse.X, Mouse.Y + Inset)
        Circle.Visible = getgenv().SilentFov
        Circle.Thickness = 1.5
        Circle.Thickness = 2
        Circle.Radius = 60
        Circle.Color = Settings.Settings.Color
    elseif getgenv().SilentFov == true then
        Circle.Visible = true
    else
        Circle.Visible = false
        Line.Visible = false
    end
end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    if getgenv().SilentEnabled and getnamecallmethod() == "FireServer" and args[2] == "MousePos" then
        args[3] = Plr.Character[getgenv().SilentAimpart].Position +
                      (Plr.Character[getgenv().SilentAimpart].Velocity * getgenv().SilentPrediction)

        return old(unpack(args))
    end
    return old(...)
end)
