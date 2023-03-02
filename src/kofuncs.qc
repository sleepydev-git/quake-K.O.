void() Refill
{
    if (activator.ammo_nails < 100) activator.ammo_nails = activator.ammo_nails + 5;
	if (activator.ammo_rockets < 10) activator.ammo_rockets = activator.ammo_rockets + 1;
	ammoreload = 1;
}

void() func_refill
{
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
    self.use = Refill;
}

void() killsky
{
    T_Damage(other,other.lastattacker,other.lastattacker,-999);
}

void() func_killsky
{
	self.movetype=MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
    self.touch = killsky;
}

void() func_randomitem
{
	local void randoitem()
	{
		float a;
		a = random();
		if (a < 0.9) item_health();
		else item_armor1();
	}
	self.think = randoitem;
	self.nextthink = time + random()*20;
}