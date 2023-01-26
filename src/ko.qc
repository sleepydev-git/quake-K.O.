//THINGS CHANGED
//combat.qc : T_Damage original knockback removed, instead redirects to s_knockback. smashmode is called to determine whether to increase or remove health.
//soldier.qc : Experimental change to animation frames to give enemies knockback velocity

float knockback = 2;
float stacksize = 3;
float smashmode;
float ammoreload;
.float dashcooldown;
.float dashcount;
.float prevvel;
.float bounce;
.entity lastattacker;
.float rocketmode;
.float nailmode;

//if (deathmatch == 1)No Items
//if (deathmatch == 2)Random Items
//if (deathmatch == 3)Map Items

void() CheckSmashmode()
{
    entity spot;
	spot = find(world, classname, "func_killsky");
    if (spot) smashmode = 1; else smashmode = 0;
}

void(vector kdir, float kdam) s_knockback =
{
    if (smashmode == 1)
    {
        self.velocity = self.velocity+('0 0 150')+(((kdir*self.health*knockback)+(kdir*kdam*knockback)));
    }
        
    else if (smashmode == 0)
    {
        local float hp = self.health;
        if (self.health >= 250) hp = 250;
        self.velocity = self.velocity+('0 0 150')+(((kdir*(250-hp)*knockback)+(kdir*kdam*knockback)));
    }
    if (self.flags & FL_ONGROUND)
    {
        self.velocity_z = fabs(self.velocity_z);
        self.flags = self.flags - FL_ONGROUND;
    }
    self.bounce = 1;
    self.dashcooldown = self.dashcooldown + 75;
    self.prevvel = self.velocity_z;
}

void() CheckBounce
{
    if (self.bounce == 1)
    {
        if (self.flags & FL_ONGROUND)
        {
            if (fabs(self.prevvel) >= 100)
            {
                self.flags = self.flags - FL_ONGROUND;
                self.velocity_z = (fabs(self.prevvel) * 0.5) + 20;
                self.prevvel = self.velocity_z;
            }
            else self.bounce == 0;
        }
    }
}

void() CheckDash
{
    if (self.flags & FL_ONGROUND)
    {
        if (self.dashcooldown > 0) self.dashcooldown = 0;
        self.dashcount = 2;
    }
    if (self.impulse == 100)
    {
        if (self.dashcooldown <= 0 && self.dashcount >= 1)
        {
            makevectors(self.angles);
            self.velocity = (v_forward * 500) + (v_up * 250);
            self.dashcooldown = 45;
            self.dashcount = self.dashcount - 1;
            self.bounce = 0;
            sound(self,CHAN_ITEM,"dash1.wav",1,ATTN_NORM);
        }
    }
    if (self.dashcooldown >= 0) self.dashcooldown = self.dashcooldown - 1;
    if (self.dashcooldown == 0 && self.dashcount >= 1) sound(self,CHAN_ITEM,"recharge.wav",1,ATTN_NORM);
}