//Space bears!
/mob/living/simple_animal/hostile/bear
	name = "space bear"
	desc = "RawrRawr!!"
	icon = 'icons/mob/simple_animal/bear_space.dmi'
	speak_emote  = list("growls", "roars")
	emote_speech = list("RAWR!","Rawr!","GRR!","Growl!")
	emote_hear   = list("rawrs","grumbles","grawls")
	emote_see    = list("stares ferociously", "stomps")
	speak_chance = 0.5
	turns_per_move = 5
	see_in_dark = 6
	response_harm = "pokes"
	stop_automated_movement_when_pulled = 0
	max_health = 60
	natural_weapon = /obj/item/natural_weapon/claws/strong
	can_escape = TRUE
	faction = "russian"
	base_animal_type = /mob/living/simple_animal/hostile/bear

	//Space bears aren't affected by atmos.
	min_gas = null
	max_gas = null
	minbodytemp = 0

	butchery_data = /decl/butchery_data/animal/space_bear

	var/stance_step = 0

//SPACE BEARS! SQUEEEEEEEE~	 OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/hostile/bear/Hudson
	name = "Hudson"
	desc = ""
	response_harm = "pokes"

/mob/living/simple_animal/hostile/bear/do_delayed_life_action()
	..()
	if(isspaceturf(loc))
		icon_state += "-space"

	switch(stance)

		if(HOSTILE_STANCE_TIRED)
			stop_automated_movement = 1
			stance_step++
			if(stance_step >= 10) //rests for 10 ticks
				if(target_mob && (target_mob in ListTargets(10)))
					stance = HOSTILE_STANCE_ATTACK //If the mob he was chasing is still nearby, resume the attack, otherwise go idle.
				else
					stance = HOSTILE_STANCE_IDLE

		if(HOSTILE_STANCE_ALERT)
			stop_automated_movement = 1
			var/found_mob = 0
			if(target_mob && (target_mob in ListTargets(10)))
				if(!(SA_attackable(target_mob)))
					stance_step = max(0, stance_step) //If we have not seen a mob in a while, the stance_step will be negative, we need to reset it to 0 as soon as we see a mob again.
					stance_step++
					found_mob = 1
					src.set_dir(get_dir(src,target_mob))	//Keep staring at the mob

					if(stance_step in list(1,4,7)) //every 3 ticks
						var/action = pick( list( "growls at [target_mob]", "stares angrily at [target_mob]", "prepares to attack [target_mob]", "closely watches [target_mob]" ) )
						if(action)
							custom_emote(1,action)
			if(!found_mob)
				stance_step--

			if(stance_step <= -20) //If we have not found a mob for 20-ish ticks, revert to idle mode
				stance = HOSTILE_STANCE_IDLE
			if(stance_step >= 7)   //If we have been staring at a mob for 7 ticks,
				stance = HOSTILE_STANCE_ATTACK

		if(HOSTILE_STANCE_ATTACKING)
			if(stance_step >= 20)	//attacks for 20 ticks, then it gets tired and needs to rest
				custom_emote(1, "is worn out and needs to rest." )
				stance = HOSTILE_STANCE_TIRED
				stance_step = 0
				walk(src, 0) //This stops the bear's walking
				return



/mob/living/simple_animal/hostile/bear/attackby(var/obj/item/O, var/mob/user)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		stance = HOSTILE_STANCE_ALERT
		stance_step = 6
		target_mob = user
	..()

/mob/living/simple_animal/hostile/bear/attack_hand(mob/user)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		stance = HOSTILE_STANCE_ALERT
		stance_step = 6
		target_mob = user
	return ..()

/mob/living/simple_animal/hostile/bear/FindTarget()
	. = ..()
	if(.)
		custom_emote(1,"stares alertly at [.]")
		stance = HOSTILE_STANCE_ALERT

/mob/living/simple_animal/hostile/bear/LoseTarget()
	..(5)

/mob/living/simple_animal/hostile/bear/attack_target(mob/target)
	if(!Adjacent(target_mob))
		return
	custom_emote(1, pick( list("slashes at [target_mob]", "bites [target_mob]") ) )

	var/damage = rand(20,30)

	if(ishuman(target_mob))
		var/mob/living/carbon/human/H = target_mob
		var/dam_zone = pick(BP_CHEST, BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG)
		var/obj/item/organ/external/affecting = GET_EXTERNAL_ORGAN(H, ran_zone(dam_zone, target = H))
		H.apply_damage(damage, BRUTE, affecting, DAM_SHARP|DAM_EDGE) //TODO damage_flags var on simple_animals, maybe?
		return H
	else if(isliving(target_mob))
		var/mob/living/L = target_mob
		L.take_damage(damage)
		return L
