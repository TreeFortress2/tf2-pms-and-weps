if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "backpack/weapons/w_models/w_scattergun" )
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
killicon.Add( "tf2_weapon_scattergun", "hud/dneg_image_scatgun", Color( 255, 255, 255, 255 ) )
end

SWEP.PrintName = "Scattergun"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable= false
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false
 

SWEP.ViewModel = "models/weapons/v_models/v_pistol_scout.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_scattergun.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
 
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 3
SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.UseHands = false
SWEP.HoldType = "shotgun"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "tf2_weapon_pistol"

SWEP.WalkSpeed = 400
SWEP.RunSpeed = 532

SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.Recoil = 0
SWEP.RecoilTimer = CurTime()

SWEP.Primary.Sound = Sound( "Weapon_Scatter_Gun.Single" )
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 38
SWEP.Primary.MaxAmmo = 32
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Damage = 6
SWEP.Primary.Spread = 0.0675
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 10
SWEP.Primary.Delay = 0.625
SWEP.Primary.Force = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
-- Initialize the weapon as a TF item
tf_items.InitializeAsBaseItem(SWEP)

function SWEP:Initialize()
self:SetWeaponHoldType( self.HoldType )
self.Idle = 0
self.IdleTimer = CurTime() + 1
end

function SWEP:DrawHUD()
if CLIENT then
local x, y
if ( self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() ) then
local tr = util.GetPlayerTrace( self.Owner )
local trace = util.TraceLine( tr )
local coords = trace.HitPos:ToScreen()
x, y = coords.x, coords.y
else
x, y = ScrW() / 2, ScrH() / 2
end
surface.SetTexture( surface.GetTextureID( "sprites/crosshair_1" ) )
surface.SetDrawColor( 255, 255, 255, 255 )
surface.DrawTexturedRect( x - 16, y - 16, 32, 32 )
end
end

function SWEP:Deploy()
self:SetWeaponHoldType( self.HoldType )
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
self.Owner:GetViewModel():SetPlaybackRate(1.4)
self:SetNextPrimaryFire( CurTime() + 0.5 )
self:SetNextSecondaryFire( CurTime() + 0.5 )
self.Reloading = 0
self.ReloadingTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Recoil = 0
self.RecoilTimer = CurTime()
self.Owner:SetWalkSpeed( self.WalkSpeed )
self.Owner:SetRunSpeed( self.RunSpeed )
return true
end

function SWEP:Holster()
self.Reloading = 0
self.ReloadingTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime()
self.Recoil = 0
self.RecoilTimer = CurTime()
self.Owner:SetWalkSpeed( 200 )
self.Owner:SetRunSpeed( 400 )
return true
end

function SWEP:PrimaryAttack()
if self.Reloading == 1 then
self.Reloading = 2
else
if !( self.Reloading == 0 ) then return end
if self.Weapon:Clip1() <= 0 and self.Weapon:Ammo1() <= 0 then
self.Weapon:EmitSound( "Weapon_Scatter_Gun.Empty" )
self:SetNextPrimaryFire( CurTime() + 0.2 )
self:SetNextSecondaryFire( CurTime() + 0.2 )
end
if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then
self.Weapon:EmitSound( "Weapon_Scatter_Gun.Empty" )
self:SetNextPrimaryFire( CurTime() + 0.2 )
self:SetNextSecondaryFire( CurTime() + 0.2 )
end
if self.Weapon:Clip1() <= 0 then
self:Reload()
end
if self.Weapon:Clip1() <= 0 then return end
if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then return end
local bullet = {}
bullet.Num = self.Primary.NumberofShots
bullet.Src = self.Owner:GetShootPos()
bullet.Dir = self.Owner:GetAimVector()
bullet.Spread = Vector( 1 * self.Primary.Spread, 1 * self.Primary.Spread, 0 )
bullet.Tracer = 1
bullet.Force = self.Primary.Force
bullet.Damage = self.Primary.Damage
bullet.AmmoType = self.Primary.Ammo
self.Owner:FireBullets( bullet )
self:EmitSound( self.Primary.Sound )
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self.Owner:MuzzleFlash()
self:TakePrimaryAmmo( self.Primary.TakeAmmo )
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Recoil = 1
self.RecoilTimer = CurTime() + 0.2
self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( -3, 0, 0 ) )
end
end

function SWEP:SecondaryAttack()
if self.Owner:KeyDown( IN_USE ) and self.Owner:KeyDown( IN_RELOAD ) then
if SERVER then
self.Owner:StopSound( "player/scout_laugh.wav", 95, 100, 1, CHAN_VOICE )
self.Owner:EmitSound( "player/scout_laugh.wav", 95, 100, 1, CHAN_VOICE )
end
self:SetNextSecondaryFire( CurTime() + 5 )
end
end