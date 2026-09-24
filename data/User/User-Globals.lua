--Place for your settings and custom functions that are meant to affect all of your jobs and characters.
latency = .25
--If this is set to true it will prevent you from casting shadows when you have more up than that spell would generate.
conserveshadows = false
--Display related settings.

--Options for automation.
state.ReEquip 		  		= M(true, 'ReEquip Mode')		 --Set this to false if you don't want to equip your current Weapon set when you aren't wearing any weapons.
state.AutoArts 		  		= M(true, 'AutoArts') 		 --Set this to false if you don't want to automatically try to keep up Solace/Arts.
state.AutoLockstyle	 	    = M(true, 'AutoLockstyle Mode') --Set this to false if you don't want gearswap to automatically lockstyle on load and weapon change.
state.CancelStoneskin 		= M(true, 'Cancel Stone Skin') --Set this to false if you don't want to automatically cancel stoneskin when you're slept.
state.SkipProcWeapons 		= M(true, 'Skip Proc Weapons') --Set this to false if you want to display weapon sets fulltime rather than just Aby/Voidwatch.
state.NotifyBuffs	  		= M(false, 'Notify Buffs') 	 --Set this to true if you want to notify your party when you recieve a specific buff/debuff. (List Below)

--[[Binds you may want to change.
	Bind special characters.
	@ = Windows Key
	% = Works only when text bar not up.
	$ = Works only when text bar is up.
	^ = Control Key
	! = Alt Key
	~ = Shift Key
	# = Apps Key
]]
send_command('bind f9 gs c cycle Weapons')           --Cycle through weapons sets.
send_command('bind f10 gs c cycle OffenseMode')      --Changes offense settings such as accuracy.
send_command('bind ^f10 gs c cycle HybridMode')      --Changes defense settings for melee such as PDT.
send_command('bind f11 gs c toggle AutoWSMode')      --Turns auto-ws mode on and off.
send_command('bind ^f11 gs c cycle WeaponskillMode') --Changes weaponskill offense settings such as accuracy.
send_command('bind f12 gs c cycle AutoBuffMode')     --Automatically keeps certain buffs up, job-dependant.
send_command('bind ^!home gs c update user')         --Runs a quick check to make sure you have the right gear on and checks variables.

NotifyBuffs = S{'doom','petrification'}
