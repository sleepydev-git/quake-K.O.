void() CheckSmashmode() {
	entity spot;
	spot = find(world, classname, "func_killsky"); //If "func_killsky", the boundary entity, is detected
	if (spot) smashmode = 1; else smashmode = 0; //Change map to Smashmode instead of HP mode.
}

void() HordeHelp;
void() DisplayHelp {
    HordeHelp();
}

void(vector kdir, float kdam) s_knockback {
    if (smashmode == 1)
    {
        self.velocity = self.velocity+('0 0 150')+(((kdir*self.health*knockback)+(kdir*kdam*knockback))); //If Smashmode = 1, knockback is calculated by how high health is.
    }
        
    else if (smashmode == 0)
    {
        local float hp = self.health;
        if (self.health >= 250) hp = 250;
        self.velocity = self.velocity+('0 0 150')+(((kdir*(250-hp)*knockback)+(kdir*kdam*knockback))); //If Smashmode = 0, knockback is calcualted by how close player health is to 0.
    }
    if (self.flags & FL_ONGROUND) //Remove entities from ground.
    {
        self.velocity_z = fabs(self.velocity_z);
        self.flags = self.flags - FL_ONGROUND;
    }
    //Enable dash cooldown period and bounce.
    self.bounce = 1; 
    //Dash cooldown is calculated by adding the current cooldown value + damage + current health. Making combos ridiculously effective.
    if (smashmode == 1) self.dashcooldown = self.dashcooldown + kdam + (self.health / 15);
    if (smashmode == 0) self.dashcooldown = self.dashcooldown + kdam + ((250-self.health) / 5);
    self.prevvel = self.velocity_z;
}

void() CheckBounce {
    if (self.bounce == 1) {
        particle(self.origin,'10 10 10',7+(random()*5),5); //Smoke trails for recently knocked entities.
        if (self.flags & FL_ONGROUND) {
            if (fabs(self.prevvel) >= 100) { //If z velocity is over 100 in either direction
                self.flags = self.flags - FL_ONGROUND;
                self.velocity_z = (fabs(self.prevvel) * 0.5) + 20; //Bounce!
                self.prevvel = self.velocity_z;
            }
        }
    }
}

void() CheckDash {
    if (self.flags & FL_ONGROUND && self.dashcount != 2)  {
        self.dashcount = 2; //If on ground, dash count is refilled.
        sound(self,CHAN_VOICE,"player/land.wav",1,ATTN_NORM);
    }
    if (self.impulse == 100) { //Dash impulse
        if (self.dashcount > 0 && self.dashok == 1) {
            makevectors(self.v_angle);
            self.velocity = (v_forward * 750) + ('0 0 200');
            self.velocity_z = self.velocity_z * 0.5;
            self.dashcount = self.dashcount - 1;
            sound(self,CHAN_VOICE,"dash1.wav",1,ATTN_NORM);
        }
        self.impulse = 0;
    }
    if (self.dashcooldown == 35) sound(self,CHAN_ITEM,"recharge.wav",1,ATTN_NORM);
    if (self.dashcooldown <= 0 && self.dashok == 0) {
        self.bounce = 0;
        self.dashok = 1;
        if (self.dashcount == 2) sound(self,CHAN_ITEM,"2dash.wav",1,ATTN_NORM);
        if (self.dashcount == 1) sound(self,CHAN_ITEM,"1dash.wav",1,ATTN_NORM);
    }
    if (self.dashcooldown > 0) {
        self.dashcooldown = self.dashcooldown - 1;
        self.dashok = 0;
        self.bounce = 1;
    }
}

void() Parry {
    if (other.classname != "player") {
        if (!other.speed) other.speed = 1000;
        if (other.nadetime) other.nadetime = other.nadetime + 2.5;
        other.speed = other.speed * 1.5;
        particle(other.origin+'0 0 10','10 10 10',95,25);
        other.velocity = self.forward * other.speed;
        other.angles = vectoangles(other.velocity);
        other.owner = self;
        sound(self,CHAN_VOICE,"player/axhit2.wav",1,ATTN_NORM);
        SUB_Remove();
    }
}

void() SafeRemove {
    self.owner = self;
    self.touch = SUB_Null;
    self.model = string_null;
    self.solid = SOLID_NOT;
}

void(float swap) SwapWeaponMods {
    if (swap == 0) {
        if (self.weapon == IT_SUPER_NAILGUN) {
            if (self.weapmod_nailgun == 2) {
                self.weapmod_nailgun = 1;
                sprint(self,"Nailgun Mode\n");
                return;
            }
            if (self.weapmod_nailgun == 1) {
                self.weapmod_nailgun = 2;
                sprint(self,"Shotty Mode\n");
                return;
            }
            if (self.weapmod_nailgun == 0) {
                self.weapmod_nailgun = 1;
                return;
            }
        }
        if (self.weapon == IT_ROCKET_LAUNCHER) {
            if (self.weapmod_rocket == 2) {
                self.weapmod_rocket = 1;
                sprint(self,"Rocket Mode\n");
                return;
            }
            if (self.weapmod_rocket == 1) {
                self.weapmod_rocket = 2;
                sprint(self,"Grenade Mode\n");
                return;
            }
            if (self.weapmod_rocket == 0) {
                self.weapmod_rocket = 1;
                return;
            }
        }
    }
    if (swap >= 1) {
        if (self.weapon == IT_SUPER_NAILGUN) self.weapmod_nailgun = swap;
        if (self.weapon == IT_ROCKET_LAUNCHER) self.weapmod_rocket = swap;
    }
}

void() CheckKOImpulse {
	if (self.impulse == 101) { //Swap weapon mods
        SwapWeaponMods(0);
	}
    if (self.impulse == 200) {
        DisplayHelp();
    }
    if (self.impulse == 201) {
        centerprint(self,ftos(globalscore));
    }
}

void() ItemLaunch {
    vector dir;
    dir = self.origin - other.origin;
    normalize(dir);
    self.damagevel = fabs(self.velocity_x) + fabs(self.velocity_y) + fabs(self.velocity_z); //this should get a approximation of the speed of the head
    if (self.classname != "player" && other.solid != SOLID_BSP) {
        self.think = SafeRemove;
        self.nextthink = time + 10;
        self.lasttouch = other; //this is saved to determine who gets the kill if the head vel kills somebody
        self.flags = self.flags - (self.flags & FL_ONGROUND);
        if (!other.savevel) self.velocity = self.velocity + other.velocity + '0 0 200';
        else self.velocity = self.velocity + other.savevel + '0 0 600'; //insanely hacky but it works
        if (self.velocity_x >= 3000) self.velocity_x = 3000;
        if (self.velocity_x <= -3000) self.velocity_x = -3000;
        if (self.velocity_y >= 3000) self.velocity_y = 3000;
        if (self.velocity_y <= -3000) self.velocity_y = -3000;
        self.velocity_z = fabs(self.velocity_z);
        if (self.damagevel >= 1500 && other != self.lasttouch) {
            T_Damage(other,self,self.lasttouch,(self.damagevel-1500)/100);
            self.velocity = -dir * self.velocity*'0.5 0.5 0.5'; //bounce off otherwise it causes issues
            //sprint(other,"bounce\n");
        }
    }
}

void centerprint_all(string s) { //Lifted from Quake Rerelease QC
	entity e = find(world, classname, "player");
	while(e) {
		centerprint(e, s);
		e = find(e, classname, "player");
	}
	/*
	entity e = nextent(world);
	while(e)
	{
		if(e.flags & FL_CLIENT)
		{
			centerprint(e, s);
		}
		e = nextent(e);
	}
	*/
}
