//Player vars
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
.float weapmod_nailgun;
.float weapmod_rocket;
.entity lasttouch;
.vector savevel;
.float lastweap;

//World vars
float knockback = 2;
float stacksize = 3;
float smashmode;
float ammoreload;

//Horde vars
.float score;
.float worth;
.float lastkilltime;
.float multiplier;
.float hordedead;
float globalscore;
float wave;
float monstercount;
float spawnercount;
float spawnsleft;
float lastcount;
float kills;
float monster_chance;
float hordeplayercount;
float countdown;