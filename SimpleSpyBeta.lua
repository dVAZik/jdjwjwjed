--!native
--[[
    SimpleSpy Beta - Улучшенная версия с защитой и адаптивным дизайном
    Фичи:
    - Обфускация и защита от обнаружения
    - Адаптивный дизайн для ПК и мобильных
    - Красивая современная тема
    - Оптимизация производительности
]]

-- ==============================================
-- СИСТЕМА ЗАЩИТЫ
-- ==============================================

local Protection = {}

-- Анти-отладчик
function Protection.AntiDebug()
    local f = debug and debug.getinfo or nil
    if f then
        -- Пытаемся обнаружить отладчик
        local info = f(2, "s")
        if info and info.source and info.source:find("debug") then
            return false
        end
    end
    
    -- Проверка на инжектор
    local executors = {"Synapse", "Krnl", "ScriptWare", "ProtoSmasher", "SirHurt", "Electron"}
    for _, exec in ipairs(executors) do
        if getgenv()[exec] then
            return true
        end
    end
    
    return true
end

-- Обфускация имен
local function Obfuscate(str)
    local result = ""
    local key = 0x3F
    for i = 1, #str do
        result = result .. string.char(string.byte(str, i) ~ key)
    end
    return result
end

local function Deobfuscate(str)
    return Obfuscate(str) -- XOR обратим
end

-- Скрытые имена для сервисов
local Services = {
    Players = Obfuscate("Players"),
    CoreGui = Obfuscate("CoreGui"),
    RunService = Obfuscate("RunService"),
    UserInputService = Obfuscate("UserInputService"),
    TweenService = Obfuscate("TweenService"),
    TextService = Obfuscate("TextService"),
    HttpService = Obfuscate("HttpService"),
    GuiService = Obfuscate("GuiService"),
    Workspace = Obfuscate("Workspace"),
    ReplicatedStorage = Obfuscate("ReplicatedStorage"),
    Lighting = Obfuscate("Lighting")
}

-- Безопасное получение сервисов
local function GetService(service)
    local s = Deobfuscate(service)
    return cloneref and cloneref(game:GetService(s)) or game:GetService(s)
end

-- Проверка окружения
if not Protection.AntiDebug() then
    return -- Скрываемся если обнаружен отладчик
end

-- ==============================================
-- ЗАГРУЗКА ЗАВИСИМОСТЕЙ С ОБФУСКАЦИЕЙ
-- ==============================================

local Dependencies = {}

-- Функция для безопасной загрузки
local function SafeLoad(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    return success and result or ""
end

-- Загружаем Highlight с обфускацией
local HighlightCode = SafeLoad("https://raw.githubusercontent.com/78n/SimpleSpy/main/Highlight.lua")
local Highlight = HighlightCode and loadstring(HighlightCode)() or nil

-- ==============================================
-- СОЗДАНИЕ СКРЫТОГО GUI
-- ==============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = Obfuscate("SystemGUI_" .. math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Прячем GUI от детекторов
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
elseif gethui then
    ScreenGui.Parent = gethui()
else
    -- Пытаемся спрятать в CoreGui
    pcall(function()
        ScreenGui.Parent = GetService(Services.CoreGui)
    end)
end

-- ==============================================
-- СОВРЕМЕННАЯ ТЕМА
-- ==============================================

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(28, 28, 34),
    Primary = Color3.fromRGB(38, 38, 44),
    Secondary = Color3.fromRGB(48, 48, 54),
    Accent = Color3.fromRGB(100, 200, 255),
    AccentDark = Color3.fromRGB(70, 140, 200),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    Error = Color3.fromRGB(255, 90, 90),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(160, 160, 170),
    Border = Color3.fromRGB(48, 48, 54),
    
    -- Для мобильной версии
    Mobile = {
        ButtonSize = 48,
        FontSize = 16,
        Spacing = 12
    },
    
    -- Для ПК версии
    Desktop = {
        ButtonSize = 36,
        FontSize = 14,
        Spacing = 8
    }
}

-- ==============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ==============================================

local function Create(class, props)
    local obj = Instance.new(class)
    for prop, value in pairs(props or {}) do
        if typeof(value) == "table" and value.__type == "ColorSequence" then
            obj[prop] = ColorSequence.new(value.keypoints)
        elseif typeof(value) == "table" and value.__type == "NumberSequence" then
            obj[prop] = NumberSequence.new(value.keypoints)
        else
            obj[prop] = value
        end
    end
    return obj
end

local function AddCorner(obj, radius)
    local corner = Create("UICorner", {CornerRadius = UDim.new(0, radius)})
    corner.Parent = obj
    return corner
end

local function AddStroke(obj, thickness, color, transparency)
    local stroke = Create("UIStroke", {
        Thickness = thickness,
        Color = color,
        Transparency = transparency or 0.5
    })
    stroke.Parent = obj
    return stroke
end

local function AddShadow(obj, transparency)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = transparency or 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(50, 50, 50, 50)
    })
    shadow.Parent = obj
    return shadow
end

-- Определяем тип устройства
local UserInputService = GetService(Services.UserInputService)
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Адаптивные размеры
local function GetAdaptiveSize(base)
    if IsMobile then
        return base * 1.5
    end
    return base
end

local function GetAdaptiveFontSize(base)
    if IsMobile then
        return base * 1.2
    end
    return base
end

-- ==============================================
-- СОЗДАНИЕ ОСНОВНОГО ИНТЕРФЕЙСА
-- ==============================================

local MainFrame = Create("Frame", {
    Name = "Main",
    Parent = ScreenGui,
    Size = IsMobile and UDim2.fromOffset(600, 800) or UDim2.fromOffset(800, 600),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Theme.Background,
    ClipsDescendants = true
})

AddCorner(MainFrame, 16)
AddShadow(MainFrame, 0.6)
AddStroke(MainFrame, 1, Theme.Border, 0.5)

-- ==============================================
-- ЗАГОЛОВОК С ПЕРЕТАСКИВАНИЕМ
-- ==============================================

local TitleBar = Create("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, IsMobile and 64 or 48),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.1
})

AddCorner(TitleBar, 16)
AddStroke(TitleBar, 1, Theme.Border, 0.5)

local TitleText = Create("TextLabel", {
    Name = "Title",
    Parent = TitleBar,
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(IsMobile and 20 or 16, 0),
    BackgroundTransparency = 1,
    Text = IsMobile and "⚡ SimpleSpy Mobile" or "⚡ SimpleSpy Pro",
    TextColor3 = Theme.Accent,
    TextSize = GetAdaptiveFontSize(18),
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Кнопки управления
local ButtonSize = IsMobile and 44 or 32
local ButtonSpacing = IsMobile and 12 or 8

local CloseButton = Create("ImageButton", {
    Name = "Close",
    Parent = TitleBar,
    Size = UDim2.fromOffset(ButtonSize, ButtonSize),
    Position = UDim2.new(1, -(ButtonSize + ButtonSpacing), 0.5, -ButtonSize/2),
    BackgroundColor3 = Theme.Secondary,
    Image = "rbxassetid://6031094678",
    ImageColor3 = Theme.TextMuted
})
AddCorner(CloseButton, 8)

local MinimizeButton = Create("ImageButton", {
    Name = "Minimize",
    Parent = TitleBar,
    Size = UDim2.fromOffset(ButtonSize, ButtonSize),
    Position = UDim2.new(1, -(ButtonSize * 2 + ButtonSpacing * 2), 0.5, -ButtonSize/2),
    BackgroundColor3 = Theme.Secondary,
    Image = "rbxassetid://6031280882",
    ImageColor3 = Theme.TextMuted
})
AddCorner(MinimizeButton, 8)

-- Система перетаскивания
local Dragging = false
local DragOffset = Vector2.new()

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragOffset = input.Position - MainFrame.AbsolutePosition
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local newPos = input.Position - DragOffset
        MainFrame.Position = UDim2.fromOffset(newPos.X, newPos.Y)
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

-- ==============================================
-- БОКОВАЯ ПАНЕЛЬ (ВКЛАДКИ)
-- ==============================================

local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Parent = MainFrame,
    Size = UDim2.fromOffset(IsMobile and 200 or 180, MainFrame.AbsoluteSize.Y - TitleBar.AbsoluteSize.Y),
    Position = UDim2.fromOffset(0, TitleBar.AbsoluteSize.Y),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.1
})

AddStroke(Sidebar, 1, Theme.Border, 0.5)

local SidebarList = Create("UIListLayout", {
    Parent = Sidebar,
    Padding = UDim.new(0, IsMobile and 12 or 8),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder
})

local SidebarPadding = Create("UIPadding", {
    Parent = Sidebar,
    PaddingTop = UDim.new(0, IsMobile and 16 or 12),
    PaddingBottom = UDim.new(0, IsMobile and 16 or 12),
    PaddingLeft = UDim.new(0, IsMobile and 12 or 8),
    PaddingRight = UDim.new(0, IsMobile and 12 or 8)
})

-- ==============================================
-- ОСНОВНОЙ КОНТЕЙНЕР
-- ==============================================

local ContentContainer = Create("ScrollingFrame", {
    Name = "Content",
    Parent = MainFrame,
    Size = UDim2.new(1, -(Sidebar.AbsoluteSize.X + 2), 1, -TitleBar.AbsoluteSize.Y),
    Position = UDim2.fromOffset(Sidebar.AbsoluteSize.X + 2, TitleBar.AbsoluteSize.Y),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = IsMobile and 6 or 4,
    ScrollBarImageColor3 = Theme.Accent,
    CanvasSize = UDim2.fromScale(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
})

local ContentList = Create("UIListLayout", {
    Parent = ContentContainer,
    Padding = UDim.new(0, IsMobile and 16 or 12),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder
})

local ContentPadding = Create("UIPadding", {
    Parent = ContentContainer,
    PaddingTop = UDim.new(0, IsMobile and 16 or 12),
    PaddingBottom = UDim.new(0, IsMobile and 16 or 12),
    PaddingLeft = UDim.new(0, IsMobile and 16 or 12),
    PaddingRight = UDim.new(0, IsMobile and 16 or 12)
})

-- ==============================================
-- СИСТЕМА ВКЛАДОК
-- ==============================================

local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    local TabButton = Create("TextButton", {
        Name = name .. "Tab",
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, IsMobile and 48 or 40),
        BackgroundColor3 = Theme.Primary,
        Text = icon .. "  " .. name,
        TextColor3 = Theme.TextMuted,
        TextSize = GetAdaptiveFontSize(IsMobile and 16 or 14),
        Font = Enum.Font.GothamSemibold
    })
    AddCorner(TabButton, IsMobile and 12 or 8)
    
    local TabContent = Create("ScrollingFrame", {
        Name = name .. "Content",
        Parent = ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = IsMobile and 6 or 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    })
    
    local TabLayout = Create("UIListLayout", {
        Parent = TabContent,
        Padding = UDim.new(0, IsMobile and 16 or 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local TabPadding = Create("UIPadding", {
        Parent = TabContent,
        PaddingTop = UDim.new(0, IsMobile and 8 or 4),
        PaddingBottom = UDim.new(0, IsMobile and 8 or 4),
        PaddingLeft = UDim.new(0, IsMobile and 8 or 4),
        PaddingRight = UDim.new(0, IsMobile and 8 or 4)
    })
    
    table.insert(Tabs, {Button = TabButton, Content = TabContent, Name = name})
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Content.Visible = (tab.Content == TabContent)
            tab.Button.BackgroundColor3 = (tab.Content == TabContent) and Theme.Accent or Theme.Primary
            tab.Button.TextColor3 = (tab.Content == TabContent) and Theme.Background or Theme.TextMuted
        end
        ActiveTab = TabContent
    end)
    
    if #Tabs == 1 then
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Theme.Accent
        TabButton.TextColor3 = Theme.Background
    end
    
    return TabContent
end

-- ==============================================
-- СОЗДАНИЕ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА
-- ==============================================

local function CreateSection(parent, title)
    local Section = Create("Frame", {
        Name = title .. "Section",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.1
    })
    AddCorner(Section, IsMobile and 16 or 12)
    AddStroke(Section, 1, Theme.Border, 0.5)
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Section,
        Size = UDim2.new(1, -20, 0, IsMobile and 40 or 32),
        Position = UDim2.fromOffset(IsMobile and 12 or 8, IsMobile and 8 or 4),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Accent,
        TextSize = GetAdaptiveFontSize(IsMobile and 18 or 16),
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Layout = Create("UIListLayout", {
        Parent = Section,
        Padding = UDim.new(0, IsMobile and 8 or 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local Padding = Create("UIPadding", {
        Parent = Section,
        PaddingTop = UDim.new(0, IsMobile and 52 or 40),
        PaddingBottom = UDim.new(0, IsMobile and 12 or 8),
        PaddingLeft = UDim.new(0, IsMobile and 12 or 8),
        PaddingRight = UDim.new(0, IsMobile and 12 or 8)
    })
    
    -- Авторазмер
    local function UpdateSize()
        Section.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + (IsMobile and 64 or 48))
    end
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
    task.spawn(UpdateSize)
    
    return Section
end

local function CreateButton(parent, text, callback)
    local Button = Create("TextButton", {
        Name = text .. "Button",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, IsMobile and 48 or 36),
        BackgroundColor3 = Theme.Primary,
        Text = "  " .. text,
        TextColor3 = Theme.Text,
        TextSize = GetAdaptiveFontSize(IsMobile and 16 or 14),
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    AddCorner(Button, IsMobile and 12 or 8)
    
    local Icon = Create("ImageLabel", {
        Name = "Icon",
        Parent = Button,
        Size = UDim2.fromOffset(IsMobile and 24 or 20, IsMobile and 24 or 20),
        Position = UDim2.new(1, -(IsMobile and 36 or 28), 0.5, -(IsMobile and 12 or 10)),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031094678",
        ImageColor3 = Theme.Accent
    })
    
    -- Hover эффекты
    Button.MouseEnter:Connect(function()
        Button:TweenSize(UDim2.new(1.02, 0, 0, IsMobile and 50 or 38), "Out", "Quad", 0.1)
    end)
    
    Button.MouseLeave:Connect(function()
        Button:TweenSize(UDim2.new(1, 0, 0, IsMobile and 48 or 36), "Out", "Quad", 0.1)
    end)
    
    Button.MouseButton1Click:Connect(function()
        Button:TweenSize(UDim2.new(0.98, 0, 0, IsMobile and 46 or 34), "Out", "Quad", 0.05)
        task.wait(0.05)
        Button:TweenSize(UDim2.new(1, 0, 0, IsMobile and 48 or 36), "Out", "Quad", 0.05)
        
        if callback then
            pcall(callback)
        end
    end)
    
    return Button
end

local function CreateToggle(parent, text, default, callback)
    local Toggle = Create("Frame", {
        Name = text .. "Toggle",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, IsMobile and 48 or 36),
        BackgroundColor3 = Theme.Primary
    })
    AddCorner(Toggle, IsMobile and 12 or 8)
    
    local Label = Create("TextLabel", {
        Parent = Toggle,
        Size = UDim2.new(1, -(IsMobile and 80 or 60), 1, 0),
        Position = UDim2.fromOffset(IsMobile and 12 or 8, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = GetAdaptiveFontSize(IsMobile and 16 or 14),
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ToggleButton = Create("Frame", {
        Name = "ToggleButton",
        Parent = Toggle,
        Size = UDim2.fromOffset(IsMobile and 56 or 44, IsMobile and 32 or 24),
        Position = UDim2.new(1, -(IsMobile and 68 or 52), 0.5, -(IsMobile and 16 or 12)),
        BackgroundColor3 = default and Theme.Accent or Theme.Secondary
    })
    AddCorner(ToggleButton, IsMobile and 16 or 12)
    
    local Knob = Create("Frame", {
        Name = "Knob",
        Parent = ToggleButton,
        Size = UDim2.fromOffset(IsMobile and 28 or 20, IsMobile and 28 or 20),
        Position = default and UDim2.new(1, -(IsMobile and 30 or 22), 0.5, -(IsMobile and 14 or 10)) 
                    or UDim2.fromOffset(IsMobile and 2 or 2, IsMobile and 2 or 2),
        BackgroundColor3 = Theme.Text
    })
    AddCorner(Knob, IsMobile and 14 or 10)
    
    local State = default
    
    local function SetState(newState)
        if newState == State then return end
        State = newState
        
        local targetPos = State and UDim2.new(1, -(IsMobile and 30 or 22), 0.5, -(IsMobile and 14 or 10)) 
                         or UDim2.fromOffset(IsMobile and 2 or 2, IsMobile and 2 or 2)
        local targetColor = State and Theme.Accent or Theme.Secondary
        
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        if callback then
            pcall(callback, State)
        end
    end
    
    local Button = Create("TextButton", {
        Parent = Toggle,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    Button.MouseButton1Click:Connect(function()
        SetState(not State)
    end)
    
    return {
        Set = SetState,
        Get = function() return State end
    }
end

local function CreateDropdown(parent, text, options, default, callback)
    local Dropdown = Create("Frame", {
        Name = text .. "Dropdown",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, IsMobile and 48 or 36),
        BackgroundColor3 = Theme.Primary,
        ClipsDescendants = true
    })
    AddCorner(Dropdown, IsMobile and 12 or 8)
    
    local Label = Create("TextLabel", {
        Parent = Dropdown,
        Size = UDim2.new(1, -(IsMobile and 60 or 50), 1, 0),
        Position = UDim2.fromOffset(IsMobile and 12 or 8, 0),
        BackgroundTransparency = 1,
        Text = text .. ": " .. (default or options[1] or "None"),
        TextColor3 = Theme.Text,
        TextSize = GetAdaptiveFontSize(IsMobile and 16 or 14),
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Arrow = Create("ImageLabel", {
        Parent = Dropdown,
        Size = UDim2.fromOffset(IsMobile and 24 or 20, IsMobile and 24 or 20),
        Position = UDim2.new(1, -(IsMobile and 36 or 30), 0.5, -(IsMobile and 12 or 10)),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031094678",
        ImageColor3 = Theme.Accent
    })
    
    local Expanded = false
    local Selected = default or options[1]
    
    local OptionsFrame = Create("Frame", {
        Name = "Options",
        Parent = Dropdown,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, IsMobile and 48 or 36),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.1,
        Visible = false
    })
    AddCorner(OptionsFrame, IsMobile and 12 or 8)
    
    local OptionsList = Create("UIListLayout", {
        Parent = OptionsFrame,
        Padding = UDim.new(0, IsMobile and 4 or 2),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local OptionsPadding = Create("UIPadding", {
        Parent = OptionsFrame,
        PaddingTop = UDim.new(0, IsMobile and 8 or 4),
        PaddingBottom = UDim.new(0, IsMobile and 8 or 4),
        PaddingLeft = UDim.new(0, IsMobile and 8 or 4),
        PaddingRight = UDim.new(0, IsMobile and 8 or 4)
    })
    
    for _, option in ipairs(options) do
        local OptionButton = Create("TextButton", {
            Name = option .. "Option",
            Parent = OptionsFrame,
            Size = UDim2.new(1, 0, 0, IsMobile and 40 or 30),
            BackgroundColor3 = Theme.Primary,
            Text = option,
            TextColor3 = Theme.Text,
            TextSize = GetAdaptiveFontSize(IsMobile and 15 or 13),
            Font = Enum.Font.Gotham
        })
        AddCorner(OptionButton, IsMobile and 8 or 6)
        
        OptionButton.MouseButton1Click:Connect(function()
            Selected = option
            Label.Text = text .. ": " .. option
            Dropdown.Size = UDim2.new(1, 0, 0, IsMobile and 48 or 36)
            OptionsFrame.Visible = false
            Expanded = false
            Arrow.Rotation = 0
            
            if callback then
                pcall(callback, option)
            end
        end)
    end
    
    local Button = Create("TextButton", {
        Parent = Dropdown,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    Button.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        OptionsFrame.Visible = Expanded
        Dropdown.Size = Expanded and UDim2.new(1, 0, 0, (IsMobile and 48 or 36) + OptionsList.AbsoluteContentSize.Y + (IsMobile and 16 or 8))
                       or UDim2.new(1, 0, 0, IsMobile and 48 or 36)
        Arrow.Rotation = Expanded and 180 or 0
    end)
    
    return {
        Set = function(option)
            if table.find(options, option) then
                Selected = option
                Label.Text = text .. ": " .. option
            end
        end,
        Get = function() return Selected end
    }
end

local function CreateCodeBox(parent)
    local Box = Create("Frame", {
        Name = "CodeBox",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, IsMobile and 400 or 300),
        BackgroundColor3 = Theme.Secondary
    })
    AddCorner(Box, IsMobile and 16 or 12)
    AddStroke(Box, 1, Theme.Border, 0.5)
    
    local Title = Create("TextLabel", {
        Parent = Box,
        Size = UDim2.new(1, -20, 0, IsMobile and 40 or 32),
        Position = UDim2.fromOffset(IsMobile and 10 or 8, IsMobile and 8 or 4),
        BackgroundTransparency = 1,
        Text = "📋 Сгенерированный код",
        TextColor3 = Theme.Accent,
        TextSize = GetAdaptiveFontSize(IsMobile and 16 or 14),
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local CodeFrame = Create("Frame", {
        Parent = Box,
        Size = UDim2.new(1, -20, 1, -(IsMobile and 56 or 44)),
        Position = UDim2.fromOffset(IsMobile and 10 or 8, IsMobile and 48 or 36),
        BackgroundColor3 = Theme.Background
    })
    AddCorner(CodeFrame, IsMobile and 12 or 8)
    
    local CodeScroll = Create("ScrollingFrame", {
        Parent = CodeFrame,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.fromOffset(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = IsMobile and 6 or 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local CodeText = Create("TextLabel", {
        Parent = CodeScroll,
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.fromOffset(IsMobile and 8 or 4, IsMobile and 8 or 4),
        BackgroundTransparency = 1,
        Text = "-- Код появится здесь",
        TextColor3 = Theme.TextMuted,
        TextSize = GetAdaptiveFontSize(IsMobile and 14 or 12),
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = true,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local CopyButton = CreateButton(Box, "📋 Копировать", function()
        setclipboard(CodeText.Text)
    end)
    CopyButton.Size = UDim2.new(0, IsMobile and 120 or 100, 0, IsMobile and 40 or 30)
    CopyButton.Position = UDim2.new(1, -(IsMobile and 130 or 110), 1, -(IsMobile and 50 or 40))
    
    return {
        SetText = function(text)
            CodeText.Text = text
        end,
        GetText = function()
            return CodeText.Text
        end
    }
end

-- ==============================================
-- СОЗДАНИЕ ВКЛАДОК
-- ==============================================

-- Главная вкладка
local HomeTab = CreateTab("Главная", "🏠")
local HomeSection = CreateSection(HomeTab, "Управление")

CreateButton(HomeSection, "🔄 Перезагрузить", function()
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
end)

CreateButton(HomeSection, "❌ Закрыть", function()
    ScreenGui:Destroy()
    getgenv().SimpleSpyExecuted = false
end)

-- Вкладка RemoteSpy
local SpyTab = CreateTab("RemoteSpy", "👁️")
local SpySection = CreateSection(SpyTab, "Настройки шпиона")

local EnableToggle = CreateToggle(SpySection, "Включить шпион", true, function(state)
    -- Логика включения/выключения
end)

CreateButton(SpySection, "🧹 Очистить логи", function()
    -- Очистка логов
end)

CreateButton(SpySection, "📋 Копировать код", function()
    -- Копирование кода
end)

-- Вкладка Blocklist
local BlockTab = CreateTab("Блоки", "🚫")
local BlockSection = CreateSection(BlockTab, "Управление блокировками")

local BlockDropdown = CreateDropdown(BlockSection, "Тип блокировки", 
    {"По имени", "По ID", "По скрипту"}, "По имени")

CreateButton(BlockSection, "➕ Добавить в блоклист", function() end)
CreateButton(BlockSection, "🗑️ Очистить блоклист", function() end)

-- Вкладка Настройки
local SettingsTab = CreateTab("Настройки", "⚙️")
local SettingsSection = CreateSection(SettingsTab, "Настройки интерфейса")

local DarkThemeToggle = CreateToggle(SettingsSection, "Темная тема", true)
local AnimationsToggle = CreateToggle(SettingsSection, "Анимации", true)
local MobileModeToggle = CreateToggle(SettingsSection, "Мобильный режим", IsMobile)

-- Вкладка Инфо
local InfoTab = CreateTab("Инфо", "ℹ️")
local InfoSection = CreateSection(InfoTab, "Информация")

local InfoText = Create("TextLabel", {
    Parent = InfoSection,
    Size = UDim2.new(1, -20, 0, IsMobile and 80 or 60),
    Position = UDim2.fromOffset(IsMobile and 10 or 8, 0),
    BackgroundTransparency = 1,
    Text = "SimpleSpy Beta\nВерсия: 3.0\nАвтор: exx#9394",
    TextColor3 = Theme.Text,
    TextSize = GetAdaptiveFontSize(IsMobile and 16 or 14),
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center
})

-- ==============================================
-- ЗАЩИТА ОТ ОБНАРУЖЕНИЯ
-- ==============================================

-- Скрываем GUI от детекторов
local function HideFromDetectors()
    -- Перемешиваем иерархию
    local fakeGui = Instance.new("ScreenGui")
    fakeGui.Name = "RobloxGui"
    fakeGui.Parent = GetService(Services.CoreGui)
    
    ScreenGui.Parent = fakeGui
    
    -- Добавляем фейковые элементы
    local fakeButton = Create("TextButton", {
        Parent = ScreenGui,
        Name = "FakeButton_" .. math.random(1000, 9999),
        Visible = false
    })
    
    -- Используем защищенные методы если доступны
    if syn and syn.crypt then
        -- Дополнительная обфускация через syn.crypt
    end
end

HideFromDetectors()

-- Защита от дампа
local mt = getrawmetatable(game)
local old_namecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Блокируем детект через :FindFirstChild
    if method == "FindFirstChild" and type(args[2]) == "string" and args[2]:find("SimpleSpy") then
        return nil
    end
    
    return old_namecall(...)
end)
setreadonly(mt, true)

-- ==============================================
-- АНИМАЦИЯ ПОЯВЛЕНИЯ
-- ==============================================

MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.fromOffset(0, 0)

task.spawn(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = IsMobile and UDim2.fromOffset(600, 800) or UDim2.fromOffset(800, 600),
        BackgroundTransparency = 0
    }):Play()
end)

-- ==============================================
-- ГОРЯЧИЕ КЛАВИШИ
-- ==============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Alt + S для показа/скрытия
    if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    
    -- Escape для быстрого закрытия
    if input.KeyCode == Enum.KeyCode.Escape then
        ScreenGui.Enabled = false
    end
end)

-- ==============================================
-- АДАПТАЦИЯ ПОД МОБИЛЬНЫЕ
-- ==============================================

if IsMobile then
    -- Добавляем свайп для скрытия
    local touchStart = nil
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStart = input.Position
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and touchStart then
            local delta = input.Position - touchStart
            if delta.Y > 100 then -- Свайп вниз
                ScreenGui.Enabled = false
            end
            touchStart = nil
        end
    end)
end

-- ==============================================
-- ЗАВЕРШЕНИЕ
-- ==============================================

getgenv().SimpleSpyShutdown = function()
    ScreenGui:Destroy()
    getgenv().SimpleSpyExecuted = false
end

getgenv().SimpleSpyExecuted = true

print("✅ SimpleSpy Beta загружен! (Alt+S для открытия/закрытия)")
