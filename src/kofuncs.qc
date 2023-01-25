void() Refill
{
    if (activator.ammo_nails < 100) activator.ammo_nails = activator.ammo_nails + 5;
	if (activator.ammo_rockets < 10) activator.ammo_rockets = activator.ammo_rockets + 1;
}

void() func_refill
{
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
    self.use = Refill;
}

void() CleanUp
{
    activator.model = string_null;
    activator.solid = SOLID_NOT;
}

void() KillSky
{
    T_Damage(other,other.lastattacker,other.lastattacker,-999);
};

void() func_killsky
{
	self.movetype=MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
    self.touch = KillSky;
}