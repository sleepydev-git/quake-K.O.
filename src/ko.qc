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
.float dashok

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
    if (smashmode == 1) self.dashcooldown = self.dashcooldown + kdam + (self.health / 10);
    if (smashmode == 0) self.dashcooldown = self.dashcooldown + kdam + ((250-self.health) / 5);
    self.prevvel = self.velocity_z;
}

void() CheckBounce
{
    if (self.bounce == 1)
    {
        particle(self.origin,'10 10 10',7+(random()*5),5);
        if (self.flags & FL_ONGROUND)
        {
            self.dashcount = 2;
            if (fabs(self.prevvel) >= 100)
            {
                self.flags = self.flags - FL_ONGROUND;
                self.velocity_z = (fabs(self.prevvel) * 0.5) + 20;
                self.prevvel = self.velocity_z;
            }
        }
    }
}

void() CheckDash
{
    if (self.flags & FL_ONGROUND && self.dashcount != 2) 
    {
        self.dashcount = 2;
        sound(self,CHAN_VOICE,"player/land.wav",1,ATTN_NORM);
    }
    if (self.impulse == 100)
    {
        if (self.dashcount > 0 && self.dashok == 1)
        {
            makevectors(self.v_angle);
            self.velocity = (v_forward * 750) + ('0 0 200');
            self.dashcount = self.dashcount - 1;
            sound(self,CHAN_VOICE,"dash1.wav",1,ATTN_NORM);
        }
    }
    if (self.dashcooldown == 35) sound(self,CHAN_ITEM,"recharge.wav",1,ATTN_NORM);
    if (self.dashcooldown <= 0 && self.dashok == 0)
    {
        self.bounce = 0;
        self.dashok = 1;
        if (self.dashcount == 2) sound(self,CHAN_ITEM,"2dash.wav",1,ATTN_NORM);
        if (self.dashcount == 1) sound(self,CHAN_ITEM,"1dash.wav",1,ATTN_NORM);
    }
    if (self.dashcooldown > 0)
    {
        self.dashcooldown = self.dashcooldown - 1;
        self.dashok = 0;
        self.bounce = 1;
    }
}