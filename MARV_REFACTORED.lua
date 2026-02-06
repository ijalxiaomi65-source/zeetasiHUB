--[[
    ================================================================
    MarV In Your Area | AUTO WALK - REFACTORED
    Author: MarV (Refactored by Community)
    Discord: https://marvscript.my.id
    ================================================================
    CHANGELOG:
    - REMOVED: Entire authentication/key system
    - REMOVED: All HTTP requests for auth
    - ADDED: Auto Walk Record & Play system
    - ADDED: Waypoint save/load functionality
    ================================================================
]]

-- Load Library WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "MarV | https://marvscript.my.id | REFACTORED",
    Icon = "rbxassetid://139611780842600",
    Author = "Join Discord: https://marvscript.my.id",
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
    Title = "https://marvscript.my.id",
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
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local RobloxUsername = LocalPlayer.Name

--| =========================================================== |--
--| TAB DECLARATIONS                                            |--
--| =========================================================== |--

local AutowalkTab = Window:Tab({
    Title = "Auto Walk",
    Icon = "navigation",
})

local BypassTab = Window:Tab({
    Title = "Bypass",
    Icon = "shield-off",
})

local ListScript = Window:Tab({
    Title = "List Script",
    Icon = "scroll-text",
})

local CopyavatarTab = Window:Tab({
    Title = "Copy Avatar",
    Icon = "user-round",
})

local CustomanimationTab = Window:Tab({
    Title = "Custom Animation",
    Icon = "clapperboard",
})

local SkyboxTab = Window:Tab({
    Title = "Skybox",
    Icon = "sun",
})

local PlayermenuTab = Window:Tab({
    Title = "Player Menu",
    Icon = "users",
})

local SocialTab = Window:Tab({
    Title = "Social",
    Icon = "message-circle",
})

local AppearanceTab = Window:Tab({
    Title = "Appearance",
    Icon = "palette",
})

local UpdatecheckpointTab = Window:Tab({
    Title = "Update Checkpoint",
    Icon = "download",
})

local CreditsTab = Window:Tab({
    Title = "Credits",
    Icon = "heart",
})

Window:Divider()

--| =========================================================== |--
--| CONFIGURATION & VARIABLES                                   |--
--| =========================================================== |--

-- File Config for Auto Walk Paths
local AUTOWALK_CONFIG = {
    folder = "zeetasiHUB",
    filename = "autowalk_paths.json"
}

-- Auto Walk State
local AutoWalkState = {
    isRecording = false,
    isPlaying = false,
    isPaused = false,
    recordedWaypoints = {},
    currentPathName = "",
    savedPaths = {},
    currentWaypointIndex = 1,
    playConnection = nil,
    recordConnection = nil,
    recordInterval = 0.3, -- Record every 0.3 seconds
    lastRecordTime = 0,
    walkSpeed = 16,
    tweenSpeed = 3,
}

--| =========================================================== |--
--| UTILITY FUNCTIONS                                           |--
--| =========================================================== |--

-- Get Auto Walk File Path
local function getAutoWalkFilePath()
    return AUTOWALK_CONFIG.folder .. "/" .. AUTOWALK_CONFIG.filename
end

-- Save Paths to File
local function savePaths()
    local success, err = pcall(function()
        if not isfolder(AUTOWALK_CONFIG.folder) then
            makefolder(AUTOWALK_CONFIG.folder)
        end
        
        local data = {
            paths = AutoWalkState.savedPaths,
            saved_at = os.time(),
            version = "1.0"
        }
        
        writefile(getAutoWalkFilePath(), HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("[AUTO WALK] Gagal menyimpan paths: " .. tostring(err))
    end
    
    return success
end

-- Load Paths from File
local function loadPaths()
    local success, result = pcall(function()
        if not isfile(getAutoWalkFilePath()) then
            return {}
        end
        
        local content = readfile(getAutoWalkFilePath())
        local data = HttpService:JSONDecode(content)
        
        return data.paths or {}
    end)
    
    if success then
        return result
    else
        warn("[AUTO WALK] Failed to load paths: " .. tostring(result))
        return {}
    end
end

-- Get Character
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- Get Humanoid Root Part
local function getHumanoidRootPart()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Convert Vector3 to Table
local function vector3ToTable(vec)
    return {x = vec.X, y = vec.Y, z = vec.Z}
end

-- Convert Table to Vector3
local function tableToVector3(tbl)
    return Vector3.new(tbl.x, tbl.y, tbl.z)
end

--| =========================================================== |--
--| AUTO WALK FUNCTIONS                                         |--
--| =========================================================== |--

-- Start Recording
local function startRecording()
    if AutoWalkState.isRecording then
        WindUI:Notify({
            Title = "Warning",
            Content = "Sudah dalam mode recording!",
            Duration = 2,
            Icon = "alert-triangle",
        })
        return
    end
    
    AutoWalkState.isRecording = true
    AutoWalkState.recordedWaypoints = {}
    AutoWalkState.lastRecordTime = tick()
    
    WindUI:Notify({
        Title = "Recording Started",
        Content = "Mulai merekam pergerakan Anda...",
        Duration = 3,
        Icon = "video",
    })
    
    -- Record waypoints while moving
    AutoWalkState.recordConnection = RunService.Heartbeat:Connect(function()
        if not AutoWalkState.isRecording then return end
        
        local currentTime = tick()
        if currentTime - AutoWalkState.lastRecordTime >= AutoWalkState.recordInterval then
            local hrp = getHumanoidRootPart()
            if hrp then
                table.insert(AutoWalkState.recordedWaypoints, vector3ToTable(hrp.Position))
                AutoWalkState.lastRecordTime = currentTime
            end
        end
    end)
end

-- Stop Recording
local function stopRecording()
    if not AutoWalkState.isRecording then
        WindUI:Notify({
            Title = "Warning",
            Content = "Tidak dalam mode recording!",
            Duration = 2,
            Icon = "alert-triangle",
        })
        return
    end
    
    AutoWalkState.isRecording = false
    
    if AutoWalkState.recordConnection then
        AutoWalkState.recordConnection:Disconnect()
        AutoWalkState.recordConnection = nil
    end
    
    local waypointCount = #AutoWalkState.recordedWaypoints
    
    if waypointCount == 0 then
        WindUI:Notify({
            Title = "Recording Failed",
            Content = "Tidak ada waypoint yang terekam!",
            Duration = 3,
            Icon = "x-circle",
        })
        return
    end
    
    WindUI:Notify({
        Title = "Recording Stopped",
        Content = string.format("Terekam %d waypoints. Masukkan nama path!", waypointCount),
        Duration = 5,
        Icon = "check-circle",
    })
end

-- Save Current Recording
local function saveCurrentRecording(pathName)
    if #AutoWalkState.recordedWaypoints == 0 then
        WindUI:Notify({
            Title = "Error",
            Content = "Tidak ada waypoint untuk disimpan!",
            Duration = 3,
            Icon = "x-circle",
        })
        return false
    end
    
    if not pathName or pathName == "" then
        WindUI:Notify({
            Title = "Error",
            Content = "Nama path tidak boleh kosong!",
            Duration = 3,
            Icon = "x-circle",
        })
        return false
    end
    
    AutoWalkState.savedPaths[pathName] = AutoWalkState.recordedWaypoints
    
    local success = savePaths()
    
    if success then
        WindUI:Notify({
            Title = "Path Saved",
            Content = string.format("Path '%s' berhasil disimpan!", pathName),
            Duration = 3,
            Icon = "save",
        })
        AutoWalkState.recordedWaypoints = {}
        return true
    else
        WindUI:Notify({
            Title = "Save Failed",
            Content = "Gagal menyimpan path!",
            Duration = 3,
            Icon = "x-circle",
        })
        return false
    end
end

-- Play Path
local function playPath(pathName)
    if AutoWalkState.isPlaying then
        WindUI:Notify({
            Title = "Warning",
            Content = "Auto Walk sudah berjalan!",
            Duration = 2,
            Icon = "alert-triangle",
        })
        return
    end
    
    local path = AutoWalkState.savedPaths[pathName]
    if not path or #path == 0 then
        WindUI:Notify({
            Title = "Error",
            Content = "Path tidak ditemukan atau kosong!",
            Duration = 3,
            Icon = "x-circle",
        })
        return
    end
    
    AutoWalkState.isPlaying = true
    AutoWalkState.isPaused = false
    AutoWalkState.currentPathName = pathName
    
    WindUI:Notify({
        Title = "Auto Walk Started",
        Content = string.format("Memutar path '%s' (%d waypoints)", pathName, #path),
        Duration = 3,
        Icon = "play",
    })
    
    task.spawn(function()
        while AutoWalkState.isPlaying and AutoWalkState.currentWaypointIndex <= #path do
            if AutoWalkState.isPaused then
                task.wait(0.1)
                continue
            end
            
            local character = getCharacter()
            local hrp = getHumanoidRootPart()
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not humanoid then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Character tidak ditemukan!",
                    Duration = 3,
                    Icon = "x-circle",
                })
                AutoWalkState.isPlaying = false
                break
            end
            
            local waypoint = path[AutoWalkState.currentWaypointIndex]
            local targetPos = tableToVector3(waypoint)
            
            -- Calculate distance for tween time
            local distance = (hrp.Position - targetPos).Magnitude
            local tweenTime = distance / (AutoWalkState.walkSpeed * AutoWalkState.tweenSpeed)
            
            -- Create tween to move to waypoint
            local tweenInfo = TweenInfo.new(
                tweenTime,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            )
            
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()
            
            AutoWalkState.currentWaypointIndex = AutoWalkState.currentWaypointIndex + 1
            task.wait(0.1)
        end
        
        if AutoWalkState.isPlaying then
            WindUI:Notify({
                Title = "Auto Walk Completed",
                Content = string.format("Path '%s' selesai!", pathName),
                Duration = 3,
                Icon = "check-circle",
            })
        end
        
        AutoWalkState.isPlaying = false
        AutoWalkState.currentWaypointIndex = 1
    end)
end

-- Pause Path
local function pausePath()
    if not AutoWalkState.isPlaying then
        WindUI:Notify({
            Title = "Warning",
            Content = "Auto Walk tidak berjalan!",
            Duration = 2,
            Icon = "alert-triangle",
        })
        return
    end
    
    AutoWalkState.isPaused = not AutoWalkState.isPaused
    
    if AutoWalkState.isPaused then
        WindUI:Notify({
            Title = "Auto Walk Paused",
            Content = "Auto Walk dijeda.",
            Duration = 2,
            Icon = "pause",
        })
    else
        WindUI:Notify({
            Title = "Auto Walk Resumed",
            Content = "Auto Walk dilanjutkan.",
            Duration = 2,
            Icon = "play",
        })
    end
end

-- Stop Path
local function stopPath()
    if not AutoWalkState.isPlaying then
        WindUI:Notify({
            Title = "Warning",
            Content = "Auto Walk tidak berjalan!",
            Duration = 2,
            Icon = "alert-triangle",
        })
        return
    end
    
    AutoWalkState.isPlaying = false
    AutoWalkState.isPaused = false
    AutoWalkState.currentWaypointIndex = 1
    
    WindUI:Notify({
        Title = "Auto Walk Stopped",
        Content = "Auto Walk dihentikan.",
        Duration = 2,
        Icon = "square",
    })
end

-- Delete Path
local function deletePath(pathName)
    if AutoWalkState.savedPaths[pathName] then
        AutoWalkState.savedPaths[pathName] = nil
        savePaths()
        WindUI:Notify({
            Title = "Path Deleted",
            Content = string.format("Path '%s' berhasil dihapus!", pathName),
            Duration = 3,
            Icon = "trash-2",
        })
        return true
    else
        WindUI:Notify({
            Title = "Error",
            Content = "Path tidak ditemukan!",
            Duration = 3,
            Icon = "x-circle",
        })
        return false
    end
end

--| =========================================================== |--
--| AUTO WALK TAB SETUP                                         |--
--| =========================================================== |--

local function setupAutowalkTab()
    if not AutowalkTab then return end

    AutowalkTab:Section({ 
        Title = "Auto Walk System",
    })

    AutowalkTab:Divider()

    AutowalkTab:Paragraph({
        Title = "How to Use",
        Desc = "1. Klik 'Start Record' dan berjalan ke tempat tujuan\n2. Klik 'Stop Record' setelah selesai\n3. Masukkan nama path dan save\n4. Pilih path dari dropdown dan klik Play",
    })

    AutowalkTab:Divider()

    -- RECORDING SECTION
    AutowalkTab:Section({ 
        Title = "Recording",
    })

    local RecordStatusLabel = AutowalkTab:Paragraph({
        Title = "Status: Idle",
        Desc = "Tekan Start Record untuk mulai merekam.",
    })

    AutowalkTab:Button({
        Title = "[▶] Start Record",
        Icon = "video",
        Callback = function()
            startRecording()
            RecordStatusLabel:Set({
                Title = "Status: Recording",
                Desc = string.format("Merekam waypoints... (Interval: %.1fs)", AutoWalkState.recordInterval),
            })
        end
    })

    AutowalkTab:Button({
        Title = "[■] Stop Record",
        Icon = "square",
        Callback = function()
            stopRecording()
            RecordStatusLabel:Set({
                Title = "Status: Stopped",
                Desc = string.format("Terekam %d waypoints. Simpan path Anda!", #AutoWalkState.recordedWaypoints),
            })
        end
    })

    AutowalkTab:Divider()

    -- SAVE SECTION
    AutowalkTab:Section({ 
        Title = "Save Path",
    })

    local pathNameInput = ""

    AutowalkTab:Input({
        Title = "Nama Path",
        Placeholder = "Contoh: cp1, summit_path",
        Callback = function(value)
            pathNameInput = value
        end
    })

    AutowalkTab:Button({
        Title = "[💾] Save Path",
        Icon = "save",
        Callback = function()
            saveCurrentRecording(pathNameInput)
        end
    })

    AutowalkTab:Divider()

    -- PLAY SECTION
    AutowalkTab:Section({ 
        Title = "Play Path",
    })

    local selectedPath = ""
    local pathOptions = {}
    
    -- Create dropdown with initial paths
    for pathName, _ in pairs(AutoWalkState.savedPaths) do
        table.insert(pathOptions, pathName)
    end
    
    if #pathOptions == 0 then
        table.insert(pathOptions, "No paths available")
    end

    local PathDropdown = AutowalkTab:Dropdown({
        Title = "Select Path",
        List = pathOptions,
        Callback = function(value)
            if value ~= "No paths available" then
                selectedPath = value
            end
        end
    })

    AutowalkTab:Button({
        Title = "[🔄] Refresh Path List",
        Icon = "refresh-cw",
        Callback = function()
            pathOptions = {}
            for pathName, _ in pairs(AutoWalkState.savedPaths) do
                table.insert(pathOptions, pathName)
            end
            
            if #pathOptions == 0 then
                table.insert(pathOptions, "No paths available")
            end
            
            PathDropdown:Set({List = pathOptions})
            
            WindUI:Notify({
                Title = "Refreshed",
                Content = string.format("Ditemukan %d path", #pathOptions),
                Duration = 2,
                Icon = "refresh-cw",
            })
        end
    })

    AutowalkTab:Button({
        Title = "[▶] Play",
        Icon = "play",
        Callback = function()
            if selectedPath and selectedPath ~= "" and selectedPath ~= "No paths available" then
                playPath(selectedPath)
            else
                WindUI:Notify({
                    Title = "Error",
                    Content = "Pilih path terlebih dahulu!",
                    Duration = 3,
                    Icon = "x-circle",
                })
            end
        end
    })

    AutowalkTab:Button({
        Title = "[⏸] Pause / Resume",
        Icon = "pause",
        Callback = function()
            pausePath()
        end
    })

    AutowalkTab:Button({
        Title = "[■] Stop",
        Icon = "square",
        Callback = function()
            stopPath()
        end
    })

    AutowalkTab:Divider()

    -- SETTINGS SECTION
    AutowalkTab:Section({ 
        Title = "Settings",
    })

    AutowalkTab:Slider({
        Title = "Walk Speed",
        Min = 8,
        Max = 50,
        Default = 16,
        Callback = function(value)
            AutoWalkState.walkSpeed = value
        end
    })

    AutowalkTab:Slider({
        Title = "Tween Speed Multiplier",
        Min = 1,
        Max = 10,
        Default = 3,
        Callback = function(value)
            AutoWalkState.tweenSpeed = value
        end
    })

    AutowalkTab:Slider({
        Title = "Record Interval (seconds)",
        Min = 0.1,
        Max = 2,
        Default = 0.3,
        Callback = function(value)
            AutoWalkState.recordInterval = value
        end
    })

    AutowalkTab:Divider()

    -- DELETE SECTION
    AutowalkTab:Section({ 
        Title = "Manage Paths",
    })

    AutowalkTab:Button({
        Title = "[🗑] Delete Selected Path",
        Icon = "trash-2",
        Callback = function()
            if selectedPath and selectedPath ~= "" and selectedPath ~= "No paths available" then
                deletePath(selectedPath)
                
                -- Refresh dropdown
                pathOptions = {}
                for pathName, _ in pairs(AutoWalkState.savedPaths) do
                    table.insert(pathOptions, pathName)
                end
                
                if #pathOptions == 0 then
                    table.insert(pathOptions, "No paths available")
                end
                
                PathDropdown:Set({List = pathOptions})
                selectedPath = ""
            else
                WindUI:Notify({
                    Title = "Error",
                    Content = "Pilih path terlebih dahulu!",
                    Duration = 3,
                    Icon = "x-circle",
                })
            end
        end
    })

    AutowalkTab:Divider()
end

--| =========================================================== |--
--| BYPASS TAB SETUP                                            |--
--| =========================================================== |--

local function setupBypassTab()
    if not BypassTab then return end

	BypassTab:Section({ 
		Title = "Anti-AFK & Bypass",
	})

	BypassTab:Divider()

	local afkEnabled = false
	local afkConnection = nil

	BypassTab:Toggle({
		Title = "[◉] Anti-AFK",
		Desc = "Mencegah kick karena AFK",
		Callback = function(state)
			afkEnabled = state
			if state then
				if afkConnection then
					afkConnection:Disconnect()
				end
				
				local VirtualUser = game:GetService("VirtualUser")
				afkConnection = LocalPlayer.Idled:Connect(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end)
				
				WindUI:Notify({
					Title = "Anti-AFK Enabled",
					Content = "Anti-AFK telah diaktifkan!",
					Duration = 3,
					Icon = "shield-check",
				})
			else
				if afkConnection then
					afkConnection:Disconnect()
					afkConnection = nil
				end
				
				WindUI:Notify({
					Title = "Anti-AFK Disabled",
					Content = "Anti-AFK telah dinonaktifkan!",
					Duration = 3,
					Icon = "shield-off",
				})
			end
		end
	})

	BypassTab:Divider()

	BypassTab:Toggle({
		Title = "[◉] Anti-Lag (Remove Textures)",
		Desc = "Menghapus texture untuk performa lebih baik",
		Callback = function(state)
			if state then
				for _, v in pairs(workspace:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Material = Enum.Material.SmoothPlastic
					elseif v:IsA("Decal") or v:IsA("Texture") then
						v.Transparency = 1
					end
				end
				
				WindUI:Notify({
					Title = "Anti-Lag Enabled",
					Content = "Textures telah dihapus!",
					Duration = 3,
					Icon = "zap",
				})
			else
				WindUI:Notify({
					Title = "Anti-Lag",
					Content = "Reload game untuk mengembalikan textures.",
					Duration = 3,
					Icon = "info",
				})
			end
		end
	})

	BypassTab:Divider()
end

--| =========================================================== |--
--| LIST SCRIPT TAB SETUP                                       |--
--| =========================================================== |--

local function setupListScript()
    if not ListScript then return end

	ListScript:Section({ 
		Title = "External Scripts",
	})

	ListScript:Divider()

	ListScript:Paragraph({
		Title = "Popular Scripts",
		Desc = "Kumpulan script populer yang bisa di-load",
	})

	ListScript:Divider()

	ListScript:Button({
		Title = "[◉] Infinite Yield",
		Icon = "terminal",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
			WindUI:Notify({
				Title = "Script Loaded",
				Content = "Infinite Yield berhasil dimuat!",
				Duration = 3,
				Icon = "check-circle",
			})
		end
	})

	ListScript:Button({
		Title = "[◉] Dark Dex",
		Icon = "file-search",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"))()
			WindUI:Notify({
				Title = "Script Loaded",
				Content = "Dark Dex berhasil dimuat!",
				Duration = 3,
				Icon = "check-circle",
			})
		end
	})

	ListScript:Button({
		Title = "[◉] Remote Spy",
		Icon = "eye",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
			WindUI:Notify({
				Title = "Script Loaded",
				Content = "Remote Spy berhasil dimuat!",
				Duration = 3,
				Icon = "check-circle",
			})
		end
	})

	ListScript:Divider()
end

--| =========================================================== |--
--| COPY AVATAR TAB SETUP                                       |--
--| =========================================================== |--

local function setupCopyavatarTab()
    if not CopyavatarTab then return end

	CopyavatarTab:Section({ 
		Title = "Copy Avatar",
	})

	CopyavatarTab:Divider()

	CopyavatarTab:Paragraph({
		Title = "How to Use",
		Desc = "Masukkan username player yang ingin di-copy avatarnya",
	})

	local targetUsername = ""

	CopyavatarTab:Input({
		Title = "Username",
		Placeholder = "Masukkan username",
		Callback = function(value)
			targetUsername = value
		end
	})

	CopyavatarTab:Button({
		Title = "[◉] Copy Avatar",
		Icon = "user-round",
		Callback = function()
			if targetUsername == "" then
				WindUI:Notify({
					Title = "Error",
					Content = "Masukkan username terlebih dahulu!",
					Duration = 3,
					Icon = "x-circle",
				})
				return
			end
			
			local success, userId = pcall(function()
				return Players:GetUserIdFromNameAsync(targetUsername)
			end)
			
			if success and userId then
				local character = getCharacter()
				local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(userId)
				
				if character and character:FindFirstChildOfClass("Humanoid") then
					character.Humanoid:ApplyDescription(humanoidDescription)
					WindUI:Notify({
						Title = "Success",
						Content = string.format("Avatar %s berhasil di-copy!", targetUsername),
						Duration = 3,
						Icon = "check-circle",
					})
				end
			else
				WindUI:Notify({
					Title = "Error",
					Content = "Username tidak ditemukan!",
					Duration = 3,
					Icon = "x-circle",
				})
			end
		end
	})

	CopyavatarTab:Divider()
end

--| =========================================================== |--
--| CUSTOM ANIMATION TAB SETUP                                  |--
--| =========================================================== |--

local function setupCustomanimationTab()
    if not CustomanimationTab then return end

	CustomanimationTab:Section({ 
		Title = "Custom Animation",
	})

	CustomanimationTab:Divider()

	CustomanimationTab:Paragraph({
		Title = "Animation IDs",
		Desc = "Ganti animasi berjalan, berlari, dan idle Anda",
	})

	local animationIds = {
		walk = "",
		run = "",
		idle = ""
	}

	CustomanimationTab:Input({
		Title = "Walk Animation ID",
		Placeholder = "rbxassetid://...",
		Callback = function(value)
			animationIds.walk = value
		end
	})

	CustomanimationTab:Input({
		Title = "Run Animation ID",
		Placeholder = "rbxassetid://...",
		Callback = function(value)
			animationIds.run = value
		end
	})

	CustomanimationTab:Input({
		Title = "Idle Animation ID",
		Placeholder = "rbxassetid://...",
		Callback = function(value)
			animationIds.idle = value
		end
	})

	CustomanimationTab:Button({
		Title = "[◉] Apply Animations",
		Icon = "clapperboard",
		Callback = function()
			local character = getCharacter()
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			
			if not humanoid then
				WindUI:Notify({
					Title = "Error",
					Content = "Character tidak ditemukan!",
					Duration = 3,
					Icon = "x-circle",
				})
				return
			end
			
			local animator = humanoid:FindFirstChildOfClass("Animator")
			if animator then
				if animationIds.walk ~= "" then
					local walkAnim = Instance.new("Animation")
					walkAnim.AnimationId = animationIds.walk
					animator:LoadAnimation(walkAnim):Play()
				end
				
				WindUI:Notify({
					Title = "Success",
					Content = "Animasi berhasil diterapkan!",
					Duration = 3,
					Icon = "check-circle",
				})
			end
		end
	})

	CustomanimationTab:Divider()
end

--| =========================================================== |--
--| SKYBOX TAB SETUP                                            |--
--| =========================================================== |--

local function setupSkyboxTab()
    if not SkyboxTab then return end

	SkyboxTab:Section({ 
		Title = "Skybox Changer",
	})

	SkyboxTab:Divider()

	local skyboxId = ""

	SkyboxTab:Input({
		Title = "Skybox ID",
		Placeholder = "rbxassetid://...",
		Callback = function(value)
			skyboxId = value
		end
	})

	SkyboxTab:Button({
		Title = "[◉] Apply Skybox",
		Icon = "sun",
		Callback = function()
			if skyboxId == "" then
				WindUI:Notify({
					Title = "Error",
					Content = "Masukkan Skybox ID terlebih dahulu!",
					Duration = 3,
					Icon = "x-circle",
				})
				return
			end
			
			local Lighting = game:GetService("Lighting")
			local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
			
			sky.SkyboxBk = skyboxId
			sky.SkyboxDn = skyboxId
			sky.SkyboxFt = skyboxId
			sky.SkyboxLf = skyboxId
			sky.SkyboxRt = skyboxId
			sky.SkyboxUp = skyboxId
			
			WindUI:Notify({
				Title = "Success",
				Content = "Skybox berhasil diterapkan!",
				Duration = 3,
				Icon = "check-circle",
			})
		end
	})

	SkyboxTab:Button({
		Title = "[◉] Remove Skybox",
		Icon = "x-circle",
		Callback = function()
			local Lighting = game:GetService("Lighting")
			local sky = Lighting:FindFirstChildOfClass("Sky")
			
			if sky then
				sky:Destroy()
				WindUI:Notify({
					Title = "Success",
					Content = "Skybox berhasil dihapus!",
					Duration = 3,
					Icon = "check-circle",
				})
			end
		end
	})

	SkyboxTab:Divider()
end

--| =========================================================== |--
--| PLAYER MENU TAB SETUP                                       |--
--| =========================================================== |--

local function setupPlayermenuTab()
    if not PlayermenuTab then return end

	PlayermenuTab:Section({ 
		Title = "Player Controls",
	})

	PlayermenuTab:Divider()

	PlayermenuTab:Slider({
		Title = "WalkSpeed",
		Min = 16,
		Max = 200,
		Default = 16,
		Callback = function(value)
			local character = getCharacter()
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			
			if humanoid then
				humanoid.WalkSpeed = value
			end
		end
	})

	PlayermenuTab:Slider({
		Title = "JumpPower",
		Min = 50,
		Max = 500,
		Default = 50,
		Callback = function(value)
			local character = getCharacter()
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			
			if humanoid then
				humanoid.JumpPower = value
			end
		end
	})

	PlayermenuTab:Divider()

	PlayermenuTab:Toggle({
		Title = "[◉] Infinite Jump",
		Callback = function(state)
			local UserInputService = game:GetService("UserInputService")
			
			if state then
				getgenv().InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
					local character = getCharacter()
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					
					if humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end)
			else
				if getgenv().InfiniteJumpConnection then
					getgenv().InfiniteJumpConnection:Disconnect()
				end
			end
		end
	})

	PlayermenuTab:Divider()
end

--| =========================================================== |--
--| SOCIAL TAB SETUP                                            |--
--| =========================================================== |--

local function setupSocialTab()
    if not SocialTab then return end

	SocialTab:Section({ 
		Title = "Social Media",
	})

	SocialTab:Divider()

	SocialTab:Paragraph({
		Title = "Discord",
		Desc = "https://marvscript.my.id",
	})

	SocialTab:Button({
		Title = "[◉] Copy Discord Link",
		Icon = "copy",
		Callback = function()
			setclipboard("https://marvscript.my.id")
			WindUI:Notify({
				Title = "Copied!",
				Content = "Link Discord telah di-copy!",
				Duration = 3,
				Icon = "check-circle",
			})
		end
	})

	SocialTab:Divider()
end

--| =========================================================== |--
--| APPEARANCE TAB SETUP                                        |--
--| =========================================================== |--

local function setupAppearanceTab()
    if not AppearanceTab then return end

	AppearanceTab:Section({ 
		Title = "GUI Appearance",
	})

	AppearanceTab:Divider()

	local themes = {"Midnight", "Dark", "Light", "Catppuccin Mocha"}

	AppearanceTab:Dropdown({
		Title = "Select Theme",
		List = themes,
		Callback = function(value)
			Window:SetTheme(value)
			WindUI:Notify({
				Title = "Theme Changed",
				Content = string.format("Theme diubah ke %s!", value),
				Duration = 3,
				Icon = "palette",
			})
		end
	})

	AppearanceTab:Divider()
end

--| =========================================================== |--
--| UPDATE CHECKPOINT TAB SETUP                                 |--
--| =========================================================== |--

local function setupUpdatecheckpointTab()
    if not UpdatecheckpointTab then return end

	UpdatecheckpointTab:Section({ 
		Title = "Update Checkpoint Files",
	})

	UpdatecheckpointTab:Divider()

	UpdatecheckpointTab:Paragraph({
		Title = "Info",
		Desc = "Fitur ini akan mengupdate file checkpoint dari server. Pastikan koneksi internet Anda stabil.",
	})

	UpdatecheckpointTab:Divider()

	local currentJsonFolder = "MarV/JSON"
    local currentBaseURL = "https://raw.githubusercontent.com/MarVInYourArea/MarVInYourArea/refs/heads/main/JSON/"
    local currentJsonFiles = {
        "summit1.json", "summit2.json", "summit3.json", "summit4.json", "summit5.json",
        "summit6.json", "summit7.json", "summit8.json", "summit9.json", "summit10.json",
        "summit11.json", "summit12.json", "summit13.json", "summit14.json", "summit15.json",
        "summit16.json", "summit17.json", "summit18.json", "summit19.json", "summit20.json",
        "summit21.json", "summit22.json", "summit23.json", "summit24.json", "summit25.json",
        "summit26.json", "summit27.json", "summit28.json", "summit29.json", "summit30.json",
        "summit31.json", "summit32.json", "summit33.json", "summit34.json", "summit35.json",
        "summit36.json", "summit37.json", "summit38.json", "summit39.json", "summit40.json",
        "summit41.json", "summit42.json", "summit43.json", "summit44.json", "summit45.json",
        "summit46.json", "summit47.json", "summit48.json", "summit49.json", "summit50.json",
        "summit51.json", "summit52.json", "summit53.json", "summit54.json", "summit55.json",
        "summit56.json", "summit57.json", "summit58.json", "summit59.json", "summit60.json"
    }
    
    local updateEnabled = false
    local stopUpdate = {false}
    
    local UpdateToggle = UpdatecheckpointTab:Toggle({
        Title = "[◉] Start Update",
        Callback = function(state)
            if state then
                updateEnabled = true
                stopUpdate[1] = false
                
                task.spawn(function()
                    if not isfolder(currentJsonFolder) then
                        makefolder(currentJsonFolder)
                    end
                    
                    local successCount = 0
                    local failCount = 0
                    
                    for i, fileName in ipairs(currentJsonFiles) do
                        if stopUpdate[1] then
                            WindUI:Notify({
                                Title = "Update Dihentikan",
                                Content = string.format("Dihentikan pada file %d/%d", i, #currentJsonFiles),
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
                            Title = "Update Selesai",
                            Content = string.format("Berhasil: %d | Gagal: %d", successCount, failCount),
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
--| CREDITS TAB SETUP                                           |--
--| =========================================================== |--

local function setupCreditsTab()
    if not CreditsTab then return end

	CreditsTab:Section({ 
		Title = "Credits",
	})

	CreditsTab:Divider()

	CreditsTab:Paragraph({
		Title = "Developer",
		Desc = "Script created by MarV\nRefactored by Community",
	})

	CreditsTab:Divider()

	CreditsTab:Paragraph({
		Title = "Discord",
		Desc = "Join our Discord server: https://marvscript.my.id",
	})

	CreditsTab:Divider()

	CreditsTab:Paragraph({
		Title = "Version",
		Desc = "MARV Script - Refactored Edition\nNo Auth Required - Free to Use",
	})

	CreditsTab:Divider()
end

--| =========================================================== |--
--| INITIALIZATION                                              |--
--| =========================================================== |--

-- Load saved paths on startup
task.spawn(function()
    AutoWalkState.savedPaths = loadPaths()
    
    local pathCount = 0
    for _ in pairs(AutoWalkState.savedPaths) do
        pathCount = pathCount + 1
    end
    
    WindUI:Notify({
        Title = "Auto Walk Ready",
        Content = string.format("Loaded %d saved paths", pathCount),
        Duration = 3,
        Icon = "navigation",
    })
end)

-- Setup all tabs immediately (NO AUTH)
setupAutowalkTab()
setupBypassTab()
setupListScript()
setupCopyavatarTab()
setupCustomanimationTab()
setupSkyboxTab()
setupPlayermenuTab()
setupSocialTab()
setupAppearanceTab()
setupUpdatecheckpointTab()
setupCreditsTab()

-- Welcome notification
WindUI:Notify({
    Title = "Welcome!",
    Content = "MarV Script loaded successfully! No authentication required.",
    Duration = 5,
    Icon = "sparkles",
})

-- Select Auto Walk tab by default
AutowalkTab:Select()
