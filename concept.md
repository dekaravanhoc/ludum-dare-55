Ludum Dare 55

Theme Summoning

Game Loop: Auto Battle

Story: You are a demon that is summoned and fights against enemies.

Step 1: Demon sits in the Netherworld and gets summoning requests. Demon decides on a request.
Step 2: Demon gets summoned and fights.
Step 3: Demon increases stats and gets skills.
Step 1...


Requests give blood/soul and blood/soul is used to increase stats and get skills.


Requests are based on demon level and reputation/coolness.
Low reputation: Only low blood request that are no challange.
High reputation: Many Requests including level fitting high blood requests.


Stats Player and Enemy:
- Strength: Damage
- Agility: Attack Speed
- Stamina: HP
- Luck: Crit Chance für Damage Input und Output
- Defense: Damage Reduction


Skills passive and activate by themselves:
- Shield: adds additonal secondary armor based on Defense
- Bleeding Damage: Damage over Time based on Attack Damage
- Extra Damage: Extra Damage per Attack (based on Attack Damage and Speed)
- Dodge: dodge x attack based on Agility
- Invulnerability: Cant take Damage x ms at the beginning of the fight based on Luck
 

Growth:
- very fast 
    - Beginning 100 DPS
    - Enemy HP 1000
    - After 5 Minutes 10x
    - After 10 Minutes 1000x
    - After 15 Minutes 1000000x


Structure:
- Main Menu
- Credits
- Combat
    - Summoner
    - Demon
    - Enemy
    - Flying Damage Numbers and Effects
    - UI
        - Enemy HP
        - Demon HP
        - Demon Shield
- Demon Realm
    - Demon
    - Demon Realm Environment
    - UI
        - Reputation
        - Earned Blood
        - Current Blood
        - Level Up UI
            - Stats
            - Skills
        - Request Menu
            - Card Selection is based on Reputation
            - Request Cards
                - Blood on Success
                - Difficulty (Based on Earned Blood vs Blood On Success)
                - ?

Objects:
- Demon
    - Stats (import base stat system from prev game - Resources accessable from everywhere)
        - Blood
        - Reputation
        - Strength
        - Agility
        - Stamina
        - Luck
        - Defense
    - States
        - Demon Realm
            - Chills
        - Fight
            - Attacks Enemy
        - Loss
            - Loses Fight
        - Win
            - Wins Fight
    - 3 Optical Level (Or more depends on time)
        - Imp (1m)
        - Lesser Demon (3m)
        - Higher Demon (10m)
        - King Demon (100m) ?    
    - Current Skills
    - Public Functions
        - gain_skill(skill: Skill)
        - hit(damage: int)
        

- Enemy
    - Types (Enum)
        - Base Stats for Enemy that are the same and muliplied by modificators for the types
            - Armys mix there multiplicators
        - Soldier
            Normal Def and High HP, Normal Damage
        - Archer
            Low Def, Normal HP, Fast and Normal Damage
        - Peasant
            Normal on every Scale
        - Knight
            High Def, High HP, Slow and High Damage
        - Crossbow
            Normal Def and HP, Slow and Very High Damage
        - Best to use Subclass for the Types
            - Stat Multiplicators
            - Name
            - Mesh
    - Stats
        - Strength
        - Agility
        - Defense
        - Health
        - Luck
    - States
        - Fight
            - Attacks Demon
        - Loss
            - Fight lost
        - Win
            - Fight won
    - Multimesh Army Builder
        - Builds Enemy Army based on Input Meshes and Blood To Eearn
    - Public Functions
        - build_enemy(Array\[Type\], blood_to_earn: int)
            - set stats based on blood_to_earn
            - multiplicators on stats based on types
            - uses multimesh to visually build enemy army
        - hit(damage: int)


- Request
    - Array of Enemy Types
    - Blood To Earn


- Combat
    - Public Functions
        - setup_fight(request: Request)
            - place demon and enemy
            - sets enemy types


- Skill
    - Public Functions
        - activate(demon: Demon)
            - activates the skill to do stuff
