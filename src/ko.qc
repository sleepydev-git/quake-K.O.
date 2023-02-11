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
.float dashok;
.float parry;
.vector forward;
.float nadetime;
.string entity_type;
.float weight;
.float damagevel;
.entity lasttouch;
.vector savevel;

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
            self.velocity_z = self.velocity_z * 0.5;
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

void() Parry
{
    if (other.classname != "player")
    {
        if (!other.speed)
            other.speed = 1000;
        if (other.nadetime)
            other.nadetime = other.nadetime + 2.5;
        other.speed = other.speed * 1.5;
        particle(other.origin+'0 0 10','10 10 10',95,25);
        other.velocity = self.forward * other.speed;
        other.angles = vectoangles(other.velocity);
        other.owner = self;
        sound(self,CHAN_VOICE,"player/axhit2.wav",1,ATTN_NORM);
        SUB_Remove();
    }
}

void() ItemLaunch
{
    vector dir;
    //self.nextthink = time + 5;
    dir = self.origin - other.origin;
    normalize(dir);
    self.damagevel = fabs(self.velocity_x) + fabs(self.velocity_y) + fabs(self.velocity_z); //this should get a approximation of the speed of the head
    if (self.classname != "player" && other.solid != SOLID_BSP)
    {
        self.lasttouch = other; //this is saved to determine who gets the kill if the head vel kills somebody
        self.flags = self.flags - (self.flags & FL_ONGROUND);
        if (!other.savevel) self.velocity = self.velocity + other.velocity + '0 0 200';
        else self.velocity = self.velocity + other.savevel + '0 0 600'; //insanely hacky but it works
        self.velocity_z = fabs(self.velocity_z);
//        self.owner = other;
        if (self.damagevel >= 1000)
        {
            T_Damage(other,self,self.lasttouch,self.damagevel/20);
            self.velocity = -dir * self.velocity; //bounce off otherwise it causes issues
        }
    }
}