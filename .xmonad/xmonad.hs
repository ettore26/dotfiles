--XMonad:
import XMonad
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.Script
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.NoBorders
--import XMonad.Layout
--import XMonad.Layout.BinarySpacePartition
--import XMonad.Layout.Fullscreen
import XMonad.Layout.ResizableTile
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import System.IO

main = do
    xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar/.xmobarrc"
    --xmonad $ fullscreenSupport
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        --, layoutHook = avoidStruts  $  layoutHook defaultConfig
        --, startupHook = setWMName "LG3D"
        , startupHook = do
                        spawn "/usr/bin/feh  --bg-fill Desktop/arch_ribbons.png"
                        spawn "compton -cC -fF -i 0.8 -bc -t -8 -l -9 -r 6 -o 0.7 -m 1.0"
                        -- execScriptHook "startup"
                        setWMName "LG3D"
        , layoutHook =  toggleLayouts (avoidStruts $ noBorders Full) $ gaps [(U,25), (D,25), (R,25), (L,25)] $ avoidStruts $ spacing 25 $ ResizableTall 1 (1/10) 1 [] ||| Full -- Tall 1 (3/100) (1/2) ||| Full
        --, layoutHook = avoidStruts $ spacing 25 $ Tall 1 (3/100) (1/2)
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , borderWidth        = 2
        , terminal           = "urxvt"
        , modMask            = mod4Mask
        , normalBorderColor  = "#cccccc"
        , focusedBorderColor = "#cd8b00"
        }
        `additionalKeysP`
        [ ("M-p", spawn "rofi -show drun")
      
        , ("M-g", sendMessage $ ToggleGaps)  -- toggle all gaps
        --, ("M-t", sendMessage $ ToggleGap U) -- toggle the top gap
        --, ("M-t", sendMessage $ Toggle Full)
        , ("M-t", sendMessage ToggleLayout)
        , ("M-w", do
                  sendMessage $ IncGap 5 R
                  sendMessage $ IncGap 5 U
                  sendMessage $ IncGap 5 D
                  sendMessage $ IncGap 5 L
          )  -- increment gaps
        , ("M-q", do
                  sendMessage $ DecGap 5 R
                  sendMessage $ DecGap 5 U
                  sendMessage $ DecGap 5 D
                  sendMessage $ DecGap 5 L
          )  -- decrement gaps
        , ("M-a", incSpacing 5) -- increment spacing
        , ("M-s", incSpacing (-5))  -- decrement spacing

        , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +1.5%")
        , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -1.5%")
        , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

        , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10")    
        , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10")

        , ("M-C-l",  sendMessage Expand) 
        , ("M-C-h",  sendMessage Shrink)
        
        , ("M-C-k",  sendMessage MirrorExpand) 
        , ("M-C-j", sendMessage MirrorShrink)

        --, ("M-M1-<Left>",    sendMessage $ ExpandTowards L)
        --, ("M-M1-<Right>",   sendMessage $ ShrinkFrom L)
        --, ("M-M1-<Up>",      sendMessage $ ExpandTowards U)
        --, ("M-M1-<Down>",    sendMessage $ ShrinkFrom U)
        --, ("M-M1-C-<Left>",  sendMessage $ ShrinkFrom R)
        --, ("M-M1-C-<Right>", sendMessage $ ExpandTowards R)
        --, ("M-M1-C-<Up>",    sendMessage $ ShrinkFrom D)
        --, ("M-M1-C-<Down>",  sendMessage $ ExpandTowards D)
        --, ("M-s",            sendMessage $ Swap)
        --, ("M-M1-s",         sendMessage $ Rotate)
        --, ("M-M1-C-<Left>",  sendMessage $ ShrinkFrom R)
        --, ("M-M1-C-<Right>", sendMessage $ ExpandTowards R)
        --, ("M-M1-C-<Up>",    sendMessage $ ShrinkFrom D)
        --, ("M-M1-C-<Down>",  sendMessage $ ExpandTowards D)
        
        --, ("M-d", sendMessage $ FullscreenChanged)  -- increment gaps
 
        --, ("M-u", sendMessage MirrorShrink)
        --, ("M-i", sendMessage MirrorExpand)
        ] 
