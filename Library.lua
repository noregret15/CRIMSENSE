local CoreGui = game:GetService("CoreGui")
getfenv().Library = nil

local Library = {
    Theme = {
        Accent = Color3.fromRGB(0, 120, 255),
        Outline = Color3.fromRGB(45, 45, 50),
        Background = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(28, 28, 35),
        Text = Color3.fromRGB(235, 235, 245),
        TextDim = Color3.fromRGB(160, 160, 175),
        Font = Enum.Font.Code,
        FontSize = 13,
    },

    Objects = {},
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CRIMSENSE"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local function Create(class, props)
    local obj = Instance.new(class)
    pcall(function() obj.BorderSizePixel = 0 end)
    pcall(function() obj.AutoButtonColor = false end)
    pcall(function() obj.BackgroundTransparency = 1 end)
    pcall(function() obj.TextXAlignment = Enum.TextXAlignment.Left end)

    if props then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

function Library:CreateWindow(name)
    local Frame = Create("Frame", {
        Name = name or "Window",
        Size = UDim2.new(0, 520, 0, 380),
        Position = UDim2.new(0.5, -260, 0.5, -190),
        BackgroundColor3 = Library.Theme.Background,
        BorderColor3 = Library.Theme.Outline,
        BorderSizePixel = 1,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })

    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Frame,
    })

    local Title = Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Library.Theme.Font,
        Text = name or "CRIMSENSE",
        TextColor3 = Library.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0, 4),
        BackgroundColor3 = Color3.fromRGB(190, 50, 50),
        Font = Enum.Font.SourceSansBold,
        Text = "X",
        TextColor3 = Color3.new(1,1,1),
        TextSize = 16,
        Parent = TopBar,
    })

    local TabContainer = Create("Frame", {
        Size = UDim2.new(1, -240, 1, 0),
        Position = UDim2.new(0, 220, 0, 0),
        BackgroundTransparency = 1,
        Parent = TopBar,
    })

    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabContainer,
    })

    local ContentArea = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = Frame,
    })

    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local window = {
        Frame = Frame,
        TopBar = TopBar,
        Title = Title,
        CloseButton = CloseBtn,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        ToggleKeybind = nil,
        KeybindConnection = nil,
    }

    CloseBtn.MouseButton1Click:Connect(function()
        Frame.Visible = false
        window.Visible = false
    end)

    function window:SetVisible(state)
        self.Frame.Visible = state
        self.Visible = state
    end

    function window:Toggle()
        self:SetVisible(not self.Visible)
    end

    function window:SetKeybind(key)
        if self.KeybindConnection then
            self.KeybindConnection:Disconnect()
            self.KeybindConnection = nil
        end

        if key and key.EnumType == Enum.KeyCode then
            self.ToggleKeybind = key
            self.KeybindConnection = UIS.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.KeyCode == key then
                    self:Toggle()
                end
            end)
        else
            self.ToggleKeybind = nil
        end
    end

    function window:AddTab(tabName)
        local tabButton = Create("TextButton", {
            Size = UDim2.new(0, 90, 1, -8),
            Position = UDim2.new(0, 0, 0, 4),
            BackgroundColor3 = Library.Theme.Background,
            BorderColor3 = Library.Theme.Outline,
            BorderSizePixel = 1,
            Font = Library.Theme.Font,
            Text = tabName,
            TextColor3 = Library.Theme.TextDim,
            TextSize = 13,
            Parent = self.TabContainer,
        })

        local tabContent = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.ContentArea,
        })

        local Columns = Create("Frame", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Parent = tabContent,
        })

        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            Parent = Columns,
        })

        local LeftColumn = Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = Columns,
        })

        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = LeftColumn,
        })

        local RightColumn = Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = Columns,
        })

        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = RightColumn,
        })

        local tab = {
            Button = tabButton,
            Content = tabContent,
            Left = LeftColumn,
            Right = RightColumn,
            Name = tabName,
        }

        function tab:Show()
            for _, t in ipairs(window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = Library.Theme.Background
                t.Button.TextColor3 = Library.Theme.TextDim
            end
            self.Content.Visible = true
            self.Button.BackgroundColor3 = Library.Theme.Secondary
            self.Button.TextColor3 = Library.Theme.Text
            window.ActiveTab = self
        end

        tabButton.MouseButton1Click:Connect(function()
            tab:Show()
        end)

        function tab:AddToggle(options)
            local name = options.Name or "Toggle"
            local default = options.Default or false
            local callback = options.Callback or function() end

            local toggleContainer = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = self,
            })

            local label = Create("TextLabel", {
                Size = UDim2.new(1, -36, 1, 0),
                BackgroundTransparency = 1,
                Font = Library.Theme.Font,
                Text = name,
                TextColor3 = Library.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleContainer,
            })

            local box = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -24, 0.5, -8),
                BackgroundColor3 = default and Library.Theme.Accent or Library.Theme.Outline,
                BorderColor3 = Library.Theme.Outline,
                BorderSizePixel = 1,
                Parent = toggleContainer,
            })

            local check = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSansBold,
                Text = "✓",
                TextColor3 = Color3.new(1,1,1),
                TextSize = 16,
                TextTransparency = default and 0 or 1,
                Parent = box,
            })

            local value = default

            local function updateVisual()
                if value then
                    box.BackgroundColor3 = Library.Theme.Accent
                    check.TextTransparency = 0
                else
                    box.BackgroundColor3 = Library.Theme.Outline
                    check.TextTransparency = 1
                end
            end

            local function toggle()
                value = not value
                updateVisual()
                callback(value)
            end

            toggleContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggle()
                end
            end)

            updateVisual()

            return {
                Set = function(newValue)
                    value = newValue
                    updateVisual()
                    callback(value)
                end,
                Get = function()
                    return value
                end,
                Toggle = toggle,
            }
        end

        table.insert(self.Tabs, tab)

        if #self.Tabs == 1 then
            tab:Show()
        end

        return tab
    end

    table.insert(Library.Objects, window)

    return window
end

getfenv().Library = Library
return Library
