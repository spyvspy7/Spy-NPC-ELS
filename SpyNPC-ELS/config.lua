--[[
    NPC ELS Pattern Controller
    Generic Config Template
    ─────────────────────────────────────────────────────────────────────────────

    PURPOSE:
    This config controls flashing EXTRA patterns for NPC / AI vehicles.

    Any vehicle model listed in NPC_ELS.vehicles will automatically cycle
    through a flashing pattern using GTA vehicle extras.

    Vehicles NOT listed here are completely ignored.

    ─────────────────────────────────────────────────────────────────────────────
    HOW EXTRAS WORK
    ─────────────────────────────────────────────────────────────────────────────

    GTA vehicle extras are numbered components attached to a vehicle model.

        Extra 1
        Extra 2
        Extra 3
        etc...

    A pattern frame decides which extras are ON during that moment.

    Example:

        { on = { 1, 2 } }

    Means:
        Extra 1 = ON
        Extra 2 = ON
        Everything else = OFF

    Blank frame example:

        { on = {} }

    Means:
        ALL extras OFF

    ─────────────────────────────────────────────────────────────────────────────
    HOW TO FIND EXTRA NUMBERS
    ─────────────────────────────────────────────────────────────────────────────

    Use a trainer or vehicle dev tool to toggle extras manually and determine
    which lights correspond to which extra numbers.

    ─────────────────────────────────────────────────────────────────────────────
    HOW TO FIND VEHICLE MODEL NAMES
    ─────────────────────────────────────────────────────────────────────────────

    Enable:

        NPC_ELS.debugMode = true

    Then enter a vehicle in-game.
    The model name will print to your F8 console.

    Example output:
        [NPC ELS] Detected vehicle model: police3

    Use THAT exact lowercase name in NPC_ELS.vehicles.

    ─────────────────────────────────────────────────────────────────────────────
    PERFORMANCE NOTES
    ─────────────────────────────────────────────────────────────────────────────

    scanRadius:
        Smaller radius = better performance

    scanInterval:
        Higher interval = fewer scans = better performance

    Recommended:
        Radius: 100-200
        Interval: 1000-3000

    ─────────────────────────────────────────────────────────────────────────────
    PATTERN SPEED GUIDE
    ─────────────────────────────────────────────────────────────────────────────

    patternSpeed is milliseconds PER FRAME.

        60-70ms   = very fast pursuit flash
        80-100ms  = standard police flash
        120-160ms = slower scene lighting
        180ms+    = utility / amber style

    Lower number = faster flashing

    ─────────────────────────────────────────────────────────────────────────────
    TWO WAYS TO ASSIGN PATTERNS
    ─────────────────────────────────────────────────────────────────────────────

    OPTION 1 — Use shared pattern set:
        ["police"] = { patternSetName = "normalSplit" }

    OPTION 2 — Define inline custom pattern:
        ["firetruk"] = {
            patternSet = {
                patternSpeed = 100,
                frames = {
                    { on = { 1, 2 } },
                    { on = { 3, 4 } },
                }
            }
        }

    ─────────────────────────────────────────────────────────────────────────────
    IMPORTANT NOTES
    ─────────────────────────────────────────────────────────────────────────────

    ✔ Vehicle names MUST be lowercase
    ✔ Vehicle names MUST match spawn names exactly
    ✔ Extras not listed in a frame are automatically turned OFF
    ✔ Patterns loop forever while the NPC vehicle exists
    ✔ Vehicles not listed are untouched

]]


NPC_ELS = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- GLOBAL SETTINGS
-- ─────────────────────────────────────────────────────────────────────────────

NPC_ELS.scanInterval = 2000
-- Time (milliseconds) between scans for nearby NPC vehicles

NPC_ELS.scanRadius = 150.0
-- Radius around player to search for NPC vehicles

NPC_ELS.debugMode = false
-- true  = print detected vehicle model names to F8 console
-- false = disable debug logging


-- ─────────────────────────────────────────────────────────────────────────────
-- SHARED PATTERN SETS
-- Reusable flash patterns
--
-- Create your patterns here once,
-- then assign them to multiple vehicles later.
-- ─────────────────────────────────────────────────────────────────────────────

NPC_ELS.patternSets = {

    -- ─────────────────────────────────────────────────────────────────────
    -- BASIC ALTERNATING PATTERN
    -- Left side flashes, then right side flashes
    -- ─────────────────────────────────────────────────────────────────────
    normalSplit = {
        patternSpeed = 80,

        frames = {
            { on = { 1, 2 } },
            { on = { 1, 2 } },
            { on = {} },

            { on = { 3, 4 } },
            { on = { 3, 4 } },
            { on = {} },
        }
    },

    -- ─────────────────────────────────────────────────────────────────────
    -- DOUBLE FLASH PATTERN
    -- Quick double-pop before swapping sides
    -- ─────────────────────────────────────────────────────────────────────
    doubleFlash = {
        patternSpeed = 70,

        frames = {
            { on = { 1, 2 } },
            { on = {} },
            { on = { 1, 2 } },
            { on = {} },

            { on = { 3, 4 } },
            { on = {} },
            { on = { 3, 4 } },
            { on = {} },
        }
    },

    -- ─────────────────────────────────────────────────────────────────────
    -- WIG WAG
    -- Common ambulance style pattern
    -- ─────────────────────────────────────────────────────────────────────
    wigWag = {
        patternSpeed = 90,

        frames = {
            { on = { 1 } },
            { on = { 2 } },
            { on = { 1 } },
            { on = { 2 } },
        }
    },

    -- ─────────────────────────────────────────────────────────────────────
    -- SLOW PULSE
    -- Good for scene / command / coroner vehicles
    -- ─────────────────────────────────────────────────────────────────────
    slowPulse = {
        patternSpeed = 150,

        frames = {
            { on = { 1, 2, 3, 4 } },
            { on = { 1, 2, 3, 4 } },
            { on = {} },
            { on = {} },
            { on = {} },
        }
    },

    -- ─────────────────────────────────────────────────────────────────────
    -- CALIFORNIA STYLE SWEEP
    -- Sweeps across the lightbar
    -- ─────────────────────────────────────────────────────────────────────
    calSweep = {
        patternSpeed = 60,

        frames = {
            { on = { 1 } },
            { on = { 1, 2 } },
            { on = { 2, 3 } },
            { on = { 3, 4 } },
            { on = { 4 } },
            { on = {} },
        }
    },



    -- ─────────────────────────────────────────────────────────────────────
    -- CUSTOM PATTERN TEMPLATE
    -- Copy this block to create your own pattern
    -- ─────────────────────────────────────────────────────────────────────
    --[[
    myCustomPattern = {
        patternSpeed = 80,

        frames = {

            -- Frame 1
            { on = { 1, 2 } },

            -- Frame 2
            { on = {} },

            -- Frame 3
            { on = { 3, 4 } },

            -- Frame 4
            { on = {} },
        }
    },
    ]]
}


-- ─────────────────────────────────────────────────────────────────────────────
-- VEHICLE DEFINITIONS
-- Add vehicles here that should use NPC ELS patterns
-- ─────────────────────────────────────────────────────────────────────────────

NPC_ELS.vehicles = {

    -- ─────────────────────────────────────────────────────────────────────
    -- EXAMPLES
    -- Uncomment and edit these for your own fleet
    -- ─────────────────────────────────────────────────────────────────────

    -- Basic police vehicles
    -- ["police"]  = { patternSetName = "normalSplit" },
    -- ["police2"] = { patternSetName = "normalSplit" },

    -- Faster pursuit units
    -- ["fbi"]     = { patternSetName = "doubleFlash" },

    -- Ambulance
    -- ["ambulance"] = { patternSetName = "wigWag" },

    -- Utility / command
    -- ["utilitytruck"] = { patternSetName = "slowPulse" },



    -- ─────────────────────────────────────────────────────────────────────
    -- INLINE PATTERN EXAMPLE
    -- Use this if ONLY ONE vehicle uses the pattern
    -- ─────────────────────────────────────────────────────────────────────

    --[[
    ["mycustomvehicle"] = {

        patternSet = {

            patternSpeed = 100,

            frames = {

                { on = { 1, 2 } },
                { on = {} },

                { on = { 3, 4 } },
                { on = {} },
            }
        }
    },
    ]]



    -- ─────────────────────────────────────────────────────────────────────
    -- YOUR VEHICLES GO BELOW
    -- ─────────────────────────────────────────────────────────────────────



}