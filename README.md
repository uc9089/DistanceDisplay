# DistanceDisplay
A visual indicator for distance for Turtle WoW

Displays a distance indicator. It will be green for 30 yards or less, and red for greater than 30 yards. 

**IMPORTANTANT:** This addon uses UNITXP_SP3. Without this client mod, it will NOT work.

https://github.com/allfoxwy/UnitXP_SP3

**Ranged:** https://github.com/allfoxwy/UnitXP_SP3/releases/tag/v19 -- Recommend using this for ranged classes, as this is precise for ranged distancing. 
**Melee:** https://github.com/allfoxwy/UnitXP_SP3/releases/tag/v18 -- Recommend using this one for melee classes. The current formula does not accurately calculate melee distancing. This older formula does a better job, however it does have issues with larger enemy models. It gets the job done for the most part. 
To swap between the two, you just replace the UNITXP_SP3.dll and restart your client

Commands:
  /dd - Displays commands
  /dd <scale> -- Will scale the indicator from 0.1 to 1. Forewarning, it moves the box when it rescales, need to fix this but it works for the time being. Example: /dd 0.5 -- scales to 50%
  /dd lock
  /dd unlock
  /dd show
  /dd hide
  /dd autohide

TODO: Class specific range indicators. Will take personal request

## Known Issues
- There are issues with melee range using the new UnitXP precise distance formula. For this, I am going to add in a distance modifier. For ranges within melee range (1-10 yards), there is a 2.5 yard underestimation. This is due to melee targeting using a complex formula for estimating distances.
- There are issues with AOE spell casting. It is largely based on several complex distance formulas. Unfornuately, this cannot be fixed at the moment. However, I will consider adding in a 1.5 yard adjustment for AOE abilities. I've only tested this on a mage, but there seems to be 1.5 yards of distance that are not accounted for using UnitXP. 
