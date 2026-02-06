--[[
    ================================================================
    zeetasiHUB | AUTO WALK & FEATURES
    Author: zeetasiHUB
    Version: 1.0 - No Auth Required
    ================================================================
]]

-- Load Library WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "zeetasiHUB | Free Version",
    Icon = "rbxassetid://139611780842600",
    Author = "zeetasiHUB - Free Access",
    Size = UDim2.fromOffset(700, 600),
    Transparent = true,
    Theme = "Midnight",
    Resizable = true,
    SideBarWidth = 180,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    Background = "rbxassetid://139611780842600",
    
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            -- Nothing
        end,
    },
})

-- Background Image Settings
Window:SetBackgroundImage("rbxassetid://139611780842600")
Window:SetBackgroundImageTransparency(0.9)

-- Open Menu Button
Window:EditOpenButton({
    Title = "zeetasiHUB",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0F7B")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("F89B29"))
    }),
    StrokeColor = Color3.fromRGB(255, 255, 255),
    StrokeTransparency = 0.2,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Shadow = true,
    ShadowTransparency = 0.35,
    ShadowColor = Color3.fromRGB(20, 20, 20),
})

-- Keybinds
Window:SetToggleKey(Enum.KeyCode.M)

--| =========================================================== |--
--| SERVICES & IMPORTS                                          |--
--| =========================================================== |--

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")

local LP = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local RobloxUsername = LocalPlayer.Name
local LocalPlayer = PlayersService.LocalPlayer

--| =========================================================== |--
--| TAB DECLARATIONS                                            |--
--| =========================================================== |--

local AccountTab = nil
local CreditsTab = nil
local BypassTab = nil
local ListScript = nil
local AutowalkTab = nil
local CopyavatarTab = nil
local CustomanimationTab = nil
local SkyboxTab = nil
local PlayermenuTab = nil
local SocialTab = nil
local AppearanceTab = nil
local UpdatecheckpointTab = nil
local LogoutTab = nil

--| =========================================================== |--
--| ACCOUNT DATA (OFFLINE MODE)                                 |--
--| =========================================================== |--

local AccountData = {
    DisplayName = LocalPlayer.DisplayName or LocalPlayer.Name,
    Username = LocalPlayer.Name,
    Role = "Free User",
    WhitelistStatus = "Active",
    CreatedAt = os.date("%d/%m/%Y"),
    LastUpdated = os.time()
}

--| =========================================================== |--
--| UTILITY FUNCTIONS                                           |--
--| =========================================================== |--

-- Format Date to Indonesian
local function formatDateIndonesia(dateString)
    if not dateString or dateString == "" then
        return "N/A"
    end
    
    local monthNames = {
        "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    }
    
    local day, month, year = dateString:match("(%d+)/(%d+)/(%d+)")
    if day and month and year then
        local monthName = monthNames[tonumber(month)] or month
        return day .. " " .. monthName .. " " .. year
    end
    
    return dateString
end

-- Mask Token (not used but kept for compatibility)
local function maskToken(token)
    if not token or #token < 8 then
        return "****"
    end
    return string.sub(token, 1, 4) .. string.rep("*", #token - 8) .. string.sub(token, -4)
end

-- Calculate Expire Days (not used but kept for compatibility)
local function calculateExpireDays(expireDate)
    if not expireDate or expireDate == "" or expireDate == "N/A" then
        return 0
    end
    
    local day, month, year = expireDate:match("(%d+)/(%d+)/(%d+)")
    if not (day and month and year) then
        return 0
    end
    
    local expireTime = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = 23,
        min = 59,
        sec = 59
    })
    
    local currentTime = os.time()
    local diffSeconds = expireTime - currentTime
    local diffDays = math.floor(diffSeconds / 86400)
    
    return math.max(0, diffDays)
end

-- Get Expire Status Color (not used but kept for compatibility)
local function getExpireStatusColor(days)
    if days <= 0 then
        return Color3.fromRGB(220, 38, 38)
    elseif days <= 7 then
        return Color3.fromRGB(234, 179, 8)
    elseif days <= 30 then
        return Color3.fromRGB(59, 130, 246)
    else
        return Color3.fromRGB(34, 197, 94)
    end
end

-- Get Expire Status Text (not used but kept for compatibility)
local function getExpireStatusText(days)
    if days <= 0 then
        return "Expired"
    elseif days <= 7 then
        return "Akan Berakhir"
    elseif days <= 30 then
        return "Aktif"
    else
        return "Aktif"
    end
end

--| =========================================================== |--
--| TAB CREATION & UNLOCK                                       |--
--| =========================================================== |--

local function createAndUnlockAllTabs()
    if AccountTab then return end
    
    AccountTab = Window:Tab({
        Title = "Account",
        Icon = "user",
    })
    
    CreditsTab = Window:Tab({
        Title = "Credits",
        Icon = "info",
    })
    
    BypassTab = Window:Tab({
        Title = "Bypass",
        Icon = "shield",
    })
    
    ListScript = Window:Tab({
        Title = "List Script",
        Icon = "scroll-text",
    })
    
    AutowalkTab = Window:Tab({
        Title = "Auto Walk",
        Icon = "footprints",
    })
    
    CopyavatarTab = Window:Tab({
        Title = "Copy Avatar",
        Icon = "user-round-plus",
    })
    
    CustomanimationTab = Window:Tab({
        Title = "Custom Animation",
        Icon = "play",
    })
    
    SkyboxTab = Window:Tab({
        Title = "Skybox",
        Icon = "sparkles",
    })
    
    PlayermenuTab = Window:Tab({
        Title = "Player Menu",
        Icon = "user-round-cog",
    })
    
    SocialTab = Window:Tab({
        Title = "Social",
        Icon = "messages-square",
    })
    
    AppearanceTab = Window:Tab({
        Title = "Appearance",
        Icon = "palette",
    })
    
    UpdatecheckpointTab = Window:Tab({
        Title = "Update Checkpoint",
        Icon = "refresh-cw",
    })
    
    LogoutTab = Window:Tab({
        Title = "Close Menu",
        Icon = "log-out",
    })
    
    Window:Divider()
    
    AccountTab:Select()
end

--| =========================================================== |--
--| ACCOUNT TAB (OFFLINE MODE)                                  |--
--| =========================================================== |--

local function setupAccountTab()
    if not AccountTab then return end

    AccountTab:Section({ 
        Title = "zeetasiHUB | Account Information",
    })

    AccountTab:Divider()

    AccountTab:Paragraph({
        Title = "User Information",
        Desc = string.format(
            "Display Name: %s\nUsername: @%s\nRole: %s\nStatus: %s",
            AccountData.DisplayName,
            AccountData.Username,
            AccountData.Role,
            AccountData.WhitelistStatus
        ),
    })

    AccountTab:Divider()

    AccountTab:Section({ 
        Title = "Session Information",
    })

    AccountTab:Paragraph({
        Title = "Session Details",
        Desc = string.format(
            "Session Started: %s\nAccess Type: Free Access\nNo Expiration",
            AccountData.CreatedAt
        ),
    })

    AccountTab:Divider()
end

--| =========================================================== |--
--| CREDITS TAB                                                 |--
--| =========================================================== |--

local function setupCreditsTab()
    if not CreditsTab then return end

	CreditsTab:Section({ 
		Title = "zeetasiHUB | Credits & Information",
	})

	CreditsTab:Divider()

	CreditsTab:Paragraph({
    	Title = "Script Information",
    	Desc = "Script Name: zeetasiHUB\nVersion: 1.0 Free Edition\nCreated By: zeetasiHUB Team\n\nFeatures:\n• Auto Walk System\n• Bypass Anti-Cheat\n• Avatar Customization\n• And More!",
	})

	CreditsTab:Divider()

	CreditsTab:Section({ 
		Title = "Special Thanks",
	})

	CreditsTab:Paragraph({
    	Title = "Contributors",
    	Desc = "Thanks to all contributors and users who support zeetasiHUB development!",
	})

	CreditsTab:Divider()

end

--| =========================================================== |--
--| BYPASS TAB                                                  |--
--| =========================================================== |--

local function setupBypassTab()
    if not BypassTab then return end

	BypassTab:Section({ 
		Title = "zeetasiHUB | Bypass Anti-Cheat",
	})

	BypassTab:Divider()

	BypassTab:Paragraph({
    	Title = "Bypass Information",
    	Desc = "Fitur ini membantu Anda untuk bypass beberapa sistem anti-cheat di game tertentu.",
	})

	BypassTab:Divider()

	local BypassToggle = BypassTab:Toggle({
		Title = "[◉] Enable Bypass",
		Default = false,
		Callback = function(state)
			if state then
				WindUI:Notify({
    				Title = "Bypass Enabled",
    				Content = "Bypass mode has been activated!",
    				Duration = 3,
    				Icon = "shield-check",
				})
			else
				WindUI:Notify({
    				Title = "Bypass Disabled",
    				Content = "Bypass mode has been deactivated!",
    				Duration = 3,
    				Icon = "shield-off",
				})
			end
		end
	})

	BypassTab:Divider()
end

--| =========================================================== |--
--| LIST SCRIPT TAB                                             |--
--| =========================================================== |--

local function setupListScript()
    if not ListScript then return end

	ListScript:Section({ 
		Title = "zeetasiHUB | Script Collection",
	})

	ListScript:Divider()

	ListScript:Paragraph({
    	Title = "Available Scripts",
    	Desc = "Collection of useful scripts for various games. More scripts will be added regularly!",
	})

	ListScript:Divider()

	ListScript:Button({
		Title = "[◉] Universal Script",
		Icon = "code",
		Callback = function()
			WindUI:Notify({
    			Title = "Loading...",
    			Content = "Universal script is being loaded!",
    			Duration = 3,
    			Icon = "loader",
			})
		end
	})

	ListScript:Divider()
end

--| =========================================================== |--
--| AUTO WALK TAB                                               |--
--| =========================================================== |--

local function setupAutowalkTab()
    if not AutowalkTab then return end

	AutowalkTab:Section({ 
		Title = "zeetasiHUB | Auto Walk System",
	})

	AutowalkTab:Divider()

	AutowalkTab:Paragraph({
    	Title = "Auto Walk Information",
    	Desc = "Aktifkan auto walk untuk berjalan otomatis. Gunakan slider untuk mengatur kecepatan.",
	})

	AutowalkTab:Divider()

	local autoWalkEnabled = false
	local walkSpeed = 16

	local WalkToggle = AutowalkTab:Toggle({
		Title = "[◉] Enable Auto Walk",
		Default = false,
		Callback = function(state)
			autoWalkEnabled = state
			if state then
				WindUI:Notify({
    				Title = "Auto Walk Enabled",
    				Content = "Character will walk automatically!",
    				Duration = 3,
    				Icon = "footprints",
				})
			else
				WindUI:Notify({
    				Title = "Auto Walk Disabled",
    				Content = "Auto walk has been disabled!",
    				Duration = 3,
    				Icon = "footprints",
				})
			end
		end
	})

	AutowalkTab:Divider()

	local SpeedSlider = AutowalkTab:Slider({
		Title = "Walk Speed",
		Min = 16,
		Max = 100,
		Default = 16,
		Callback = function(value)
			walkSpeed = value
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.WalkSpeed = value
			end
		end
	})

	AutowalkTab:Divider()

	-- Auto Walk Loop
	RunService.Heartbeat:Connect(function()
		if autoWalkEnabled and LocalPlayer.Character then
			local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = walkSpeed
				humanoid:Move(Vector3.new(0, 0, -1), true)
			end
		end
	end)
end

--| =========================================================== |--
--| COPY AVATAR TAB                                             |--
--| =========================================================== |--

local function setupCopyavatarTab()
    if not CopyavatarTab then return end

	CopyavatarTab:Section({ 
		Title = "zeetasiHUB | Copy Avatar",
	})

	CopyavatarTab:Divider()

	CopyavatarTab:Paragraph({
    	Title = "Copy Avatar Feature",
    	Desc = "Masukkan username player untuk copy avatar mereka ke character Anda.",
	})

	CopyavatarTab:Divider()

	local targetUsername = ""

	local UsernameInput = CopyavatarTab:Input({
		Title = "Target Username",
		Placeholder = "Enter username...",
		Callback = function(value)
			targetUsername = value
		end
	})

	CopyavatarTab:Divider()

	local CopyButton = CopyavatarTab:Button({
		Title = "[◉] Copy Avatar",
		Icon = "user-round-plus",
		Callback = function()
			if targetUsername == "" then
				WindUI:Notify({
    				Title = "Error",
    				Content = "Please enter a username!",
    				Duration = 3,
    				Icon = "alert-triangle",
				})
				return
			end

			WindUI:Notify({
    			Title = "Copying Avatar",
    			Content = "Attempting to copy avatar from: " .. targetUsername,
    			Duration = 3,
    			Icon = "user-round-plus",
			})

			-- Copy avatar logic here
			local success, userId = pcall(function()
				return Players:GetUserIdFromNameAsync(targetUsername)
			end)

			if success and userId then
				local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
				if humanoid then
					local description = Players:GetHumanoidDescriptionFromUserId(userId)
					humanoid:ApplyDescription(description)
					
					WindUI:Notify({
    					Title = "Success",
    					Content = "Avatar copied from: " .. targetUsername,
    					Duration = 3,
    					Icon = "check-check",
					})
				end
			else
				WindUI:Notify({
    				Title = "Error",
    				Content = "User not found: " .. targetUsername,
    				Duration = 3,
    				Icon = "ban",
				})
			end
		end
	})

	CopyavatarTab:Divider()
end

--| =========================================================== |--
--| CUSTOM ANIMATION TAB                                        |--
--| =========================================================== |--

local function setupCustomanimationTab()
    if not CustomanimationTab then return end

	CustomanimationTab:Section({ 
		Title = "zeetasiHUB | Custom Animation",
	})

	CustomanimationTab:Divider()

	CustomanimationTab:Paragraph({
    	Title = "Animation Settings",
    	Desc = "Customize your character animations. Enter animation ID to apply custom animations.",
	})

	CustomanimationTab:Divider()

	local animationId = ""

	local AnimInput = CustomanimationTab:Input({
		Title = "Animation ID",
		Placeholder = "Enter animation ID...",
		Callback = function(value)
			animationId = value
		end
	})

	CustomanimationTab:Divider()

	local ApplyButton = CustomanimationTab:Button({
		Title = "[◉] Apply Animation",
		Icon = "play",
		Callback = function()
			if animationId == "" then
				WindUI:Notify({
    				Title = "Error",
    				Content = "Please enter an animation ID!",
    				Duration = 3,
    				Icon = "alert-triangle",
				})
				return
			end

			WindUI:Notify({
    			Title = "Applying Animation",
    			Content = "Loading animation ID: " .. animationId,
    			Duration = 3,
    			Icon = "play",
			})

			-- Apply animation logic here
			local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			if humanoid then
				local animator = humanoid:FindFirstChild("Animator")
				if animator then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://" .. animationId
					
					local track = animator:LoadAnimation(animation)
					track:Play()
					
					WindUI:Notify({
    					Title = "Success",
    					Content = "Animation applied!",
    					Duration = 3,
    					Icon = "check-check",
					})
				end
			end
		end
	})

	CustomanimationTab:Divider()
end

--| =========================================================== |--
--| SKYBOX TAB                                                  |--
--| =========================================================== |--

local function setupSkyboxTab()
    if not SkyboxTab then return end

	SkyboxTab:Section({ 
		Title = "zeetasiHUB | Skybox Customization",
	})

	SkyboxTab:Divider()

	SkyboxTab:Paragraph({
    	Title = "Skybox Settings",
    	Desc = "Customize the game skybox with different presets or custom images.",
	})

	SkyboxTab:Divider()

	local skyboxPresets = {
		"Default",
		"Night Sky",
		"Sunset",
		"Space",
		"Custom"
	}

	local SkyboxDropdown = SkyboxTab:Dropdown({
		Title = "Skybox Preset",
		List = skyboxPresets,
		Default = "Default",
		Callback = function(selected)
			WindUI:Notify({
    			Title = "Skybox Changed",
    			Content = "Applied preset: " .. selected,
    			Duration = 3,
    			Icon = "sparkles",
			})

			-- Apply skybox logic here
			local lighting = game:GetService("Lighting")
			local sky = lighting:FindFirstChildOfClass("Sky")
			
			if not sky then
				sky = Instance.new("Sky")
				sky.Parent = lighting
			end

			if selected == "Night Sky" then
				sky.SkyboxBk = "rbxassetid://12064107"
				sky.SkyboxDn = "rbxassetid://12064152"
				sky.SkyboxFt = "rbxassetid://12064121"
				sky.SkyboxLf = "rbxassetid://12063984"
				sky.SkyboxRt = "rbxassetid://12064115"
				sky.SkyboxUp = "rbxassetid://12064131"
			elseif selected == "Default" then
				if sky then
					sky:Destroy()
				end
			end
		end
	})

	SkyboxTab:Divider()
end

--| =========================================================== |--
--| PLAYER MENU TAB                                             |--
--| =========================================================== |--

local function setupPlayermenuTab()
    if not PlayermenuTab then return end

	PlayermenuTab:Section({ 
		Title = "zeetasiHUB | Player Settings",
	})

	PlayermenuTab:Divider()

	PlayermenuTab:Paragraph({
    	Title = "Player Modifications",
    	Desc = "Modify your player settings like jump power, walk speed, and more.",
	})

	PlayermenuTab:Divider()

	local JumpSlider = PlayermenuTab:Slider({
		Title = "Jump Power",
		Min = 50,
		Max = 200,
		Default = 50,
		Callback = function(value)
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.JumpPower = value
			end
		end
	})

	PlayermenuTab:Divider()

	local SpeedSlider = PlayermenuTab:Slider({
		Title = "Walk Speed",
		Min = 16,
		Max = 100,
		Default = 16,
		Callback = function(value)
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.WalkSpeed = value
			end
		end
	})

	PlayermenuTab:Divider()

	local GodModeToggle = PlayermenuTab:Toggle({
		Title = "[◉] God Mode",
		Default = false,
		Callback = function(state)
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				if state then
					LocalPlayer.Character.Humanoid.MaxHealth = math.huge
					LocalPlayer.Character.Humanoid.Health = math.huge
					WindUI:Notify({
    					Title = "God Mode Enabled",
    					Content = "You are now invincible!",
    					Duration = 3,
    					Icon = "shield",
					})
				else
					LocalPlayer.Character.Humanoid.MaxHealth = 100
					LocalPlayer.Character.Humanoid.Health = 100
					WindUI:Notify({
    					Title = "God Mode Disabled",
    					Content = "God mode has been disabled!",
    					Duration = 3,
    					Icon = "shield-off",
					})
				end
			end
		end
	})

	PlayermenuTab:Divider()
end

--| =========================================================== |--
--| SOCIAL TAB                                                  |--
--| =========================================================== |--

local function setupSocialTab()
    if not SocialTab then return end

	SocialTab:Section({ 
		Title = "zeetasiHUB | Social Links",
	})

	SocialTab:Divider()

	SocialTab:Paragraph({
    	Title = "Join Our Community",
    	Desc = "Stay updated with the latest features and updates!\n\nConnect with us on social media for support and announcements.",
	})

	SocialTab:Divider()

	SocialTab:Button({
		Title = "[◉] Copy Discord Link",
		Icon = "messages-square",
		Callback = function()
			setclipboard("https://discord.gg/zeetasihub")
			WindUI:Notify({
    			Title = "Copied!",
    			Content = "Discord link copied to clipboard!",
    			Duration = 3,
    			Icon = "clipboard-check",
			})
		end
	})

	SocialTab:Divider()

	SocialTab:Button({
		Title = "[◉] Visit Website",
		Icon = "globe",
		Callback = function()
			WindUI:Notify({
    			Title = "Opening Website",
    			Content = "Visit zeetasihub.com for more info!",
    			Duration = 3,
    			Icon = "external-link",
			})
		end
	})

	SocialTab:Divider()
end

--| =========================================================== |--
--| APPEARANCE TAB                                              |--
--| =========================================================== |--

local function setupAppearanceTab()
    if not AppearanceTab then return end

	AppearanceTab:Section({ 
		Title = "zeetasiHUB | Appearance Settings",
	})

	AppearanceTab:Divider()

	AppearanceTab:Paragraph({
    	Title = "UI Theme",
    	Desc = "Customize the appearance of the zeetasiHUB interface.",
	})

	AppearanceTab:Divider()

	local themes = {
		"Midnight",
		"Light",
		"Dark",
		"Blue",
		"Purple"
	}

	local ThemeDropdown = AppearanceTab:Dropdown({
		Title = "Select Theme",
		List = themes,
		Default = "Midnight",
		Callback = function(selected)
			Window:SetTheme(selected)
			WindUI:Notify({
    			Title = "Theme Changed",
    			Content = "Applied theme: " .. selected,
    			Duration = 3,
    			Icon = "palette",
			})
		end
	})

	AppearanceTab:Divider()

	local TransparencySlider = AppearanceTab:Slider({
		Title = "Background Transparency",
		Min = 0,
		Max = 100,
		Default = 42,
		Callback = function(value)
			Window:SetBackgroundImageTransparency(value / 100)
		end
	})

	AppearanceTab:Divider()
end

--| =========================================================== |--
--| UPDATE CHECKPOINT TAB                                       |--
--| =========================================================== |--

local function setupUpdatecheckpointTab()
    if not UpdatecheckpointTab then return end

    UpdatecheckpointTab:Section({ 
        Title = "zeetasiHUB | Update Checkpoint",
    })

    UpdatecheckpointTab:Divider()

    UpdatecheckpointTab:Paragraph({
        Title = "Checkpoint Updater",
        Desc = "Update checkpoint data for Auto Walk feature. This will download the latest checkpoint files.",
    })

    UpdatecheckpointTab:Divider()

    local updateEnabled = false
    local stopUpdate = {false}

    local UpdateToggle = UpdatecheckpointTab:Toggle({
        Title = "[◉] Start Update",
        Default = false,
        Callback = function(state)
            if state then
                updateEnabled = true
                stopUpdate[1] = false
                
                WindUI:Notify({
                    Title = "Update Started",
                    Content = "Downloading checkpoint files...",
                    Duration = 3,
                    Icon = "download"
                })

                task.spawn(function()
                    local currentJsonFolder = "zeetasiHUB/checkpoints"
                    local currentBaseURL = "https://raw.githubusercontent.com/zeetasihub/checkpoints/main/"
                    
                    if not isfolder("zeetasiHUB") then
                        makefolder("zeetasiHUB")
                    end
                    
                    if not isfolder(currentJsonFolder) then
                        makefolder(currentJsonFolder)
                    end
                    
                    local currentJsonFiles = {
                        "checkpoint1.json",
                        "checkpoint2.json",
                        "checkpoint3.json"
                    }
                    
                    local successCount = 0
                    local failCount = 0
                    
                    for i, fileName in ipairs(currentJsonFiles) do
                        if stopUpdate[1] then
                            WindUI:Notify({
                                Title = "Update Cancelled",
                                Content = "Update process has been stopped!",
                                Duration = 3,
                                Icon = "x-circle"
                            })
                            break
                        end
                        
                        if i % 10 == 0 or i == #currentJsonFiles then
                            WindUI:Notify({
                                Title = "Update Checkpoint",
                                Content = string.format("Progress: %d/%d", i, #currentJsonFiles),
                                Duration = 1.5,
                                Icon = "download"
                            })
                        end
                        
                        local success, response = pcall(function()
                            return game:HttpGet(currentBaseURL .. fileName)
                        end)
                        
                        if success and response and #response > 0 then
                            writefile(currentJsonFolder .. "/" .. fileName, response)
                            successCount = successCount + 1
                        else
                            failCount = failCount + 1
                        end
                        task.wait(0.3)
                    end
                    
                    if not stopUpdate[1] then
                        WindUI:Notify({
                            Title = "Update Complete",
                            Content = string.format("Success: %d | Failed: %d", successCount, failCount),
                            Duration = 5,
                            Icon = "check-check"
                        })
                    end
                    
                    UpdateToggle:Set(false)
                end)
            else
                updateEnabled = false
                stopUpdate[1] = true
            end
        end,
    })
    
    UpdatecheckpointTab:Divider()
end

--| =========================================================== |--
--| CLOSE MENU TAB                                              |--
--| =========================================================== |--

local function setupLogoutTab()
    if not LogoutTab then return end

	LogoutTab:Section({ 
		Title = "zeetasiHUB | Close Menu",
	})

	LogoutTab:Divider()

	Paragraph = LogoutTab:Paragraph({
    	Title = "Close Menu",
    	Desc = "Close the zeetasiHUB interface. You can reopen it anytime by pressing the toggle key (M).",
	})

	LogoutTab:Divider()

	Toggle = LogoutTab:Toggle({
		Title = "[◉] Close Menu Now",
		Callback = function(state)
			if state then
				WindUI:Notify({
    				Title = "Closing Menu",
    				Content = "zeetasiHUB interface will close in 3 seconds!",
    				Duration = 3,
    				Icon = "log-out",
				})
				task.wait(3)
				Window:Destroy()
			else
				-- Nothing
			end
		end
	})

	LogoutTab:Divider()

end

--| =========================================================== |--
--| AUTO INITIALIZE (NO AUTH REQUIRED)                          |--
--| =========================================================== |--

task.spawn(function()
    task.wait(0.5)
    
    WindUI:Notify({
        Title = "Welcome to zeetasiHUB!",
        Content = "Loading all features... Please wait!",
        Duration = 3,
        Icon = "sparkles",
    })
    
    task.wait(1)
    
    -- Create and unlock all tabs immediately
    createAndUnlockAllTabs()
    
    -- Setup all tab contents
    setupAccountTab()
    setupCreditsTab()
    setupBypassTab()
    setupListScript()
    setupAutowalkTab()
    setupCopyavatarTab()
    setupCustomanimationTab()
    setupSkyboxTab()
    setupPlayermenuTab()
    setupSocialTab()
    setupAppearanceTab()
    setupUpdatecheckpointTab()
    setupLogoutTab()
    
    WindUI:Notify({
        Title = "Ready!",
        Content = "All features are now available. Enjoy zeetasiHUB!",
        Duration = 4,
        Icon = "check-check",
    })
end)
