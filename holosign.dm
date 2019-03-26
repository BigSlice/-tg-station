
/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	var/obj/item/holosign_creator/projector

/obj/structure/holosign/New(loc, source_projector)
	if(source_projector)
		projector = source_projector
		projector.signs += src
	..()

/obj/structure/holosign/Destroy()
	if(projector)
		projector.signs -= src
		projector = null
	return ..()

/obj/structure/holosign/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(loc, 'sound/weapons/Egloves.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] hits [src].</span>", \
						 "<span class='warning'>You hit [src].</span>" )

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"

/obj/structure/holosign/barrier
	name = "holobarrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	pass_flags = LETPASSTHROW
	density = TRUE
	var/allow_walk = 1 //can we pass through it on walk intent

/obj/structure/holosign/barrier/CanPass(atom/movable/mover, turf/target)
	if(!density)
		return 1
	if(mover.pass_flags & (PASSGLASS|PASSTABLE|PASSGRILLE))
		return 1
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(allow_walk && C.m_intent == "walk")
			return 1

/obj/structure/holosign/barrier/wetsign
	name = "wet floor holobarrier"
	desc = "When it says walk it means walk."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"

/obj/structure/holosign/barrier/engineering
	icon_state = "holosign_engi"


/obj/structure/holosign/barrier/atmos
	name = "holofirelock"
	desc = "A holographic barrier resembling a firelock. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	density = FALSE
	anchored = TRUE
	CanAtmosPass()
		return 0
	alpha = 150

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	density = TRUE
	allow_walk = 0

/obj/structure/holosign/barrier/medical
	name = "\improper PENLITE holobarrier"
	desc = "A holobarrier that uses biometrics to detect human viruses. Denies passing to personnel with easily-detected, malicious viruses. Good for quarantines."
	icon_state = "holo_medical"
	alpha = 125 //lazy :)
	var/force_allaccess = FALSE
	var/buzzcd = 0

/obj/structure/holosign/barrier/medical/examine(mob/user)
	..()
	to_chat(user,"<span class='notice'>The biometric scanners are <b>[force_allaccess ? "off" : "on"]</b>.</span>")

/obj/structure/holosign/barrier/medical/CanPass(atom/movable/mover, turf/target)
	icon_state = "holo_medical"
	if(force_allaccess)
		return TRUE
	if(ishuman(mover))
		var/mob/living/carbon/human/sickboi = mover
		var/threat = sickboi.check_virus()
		if(get_disease_severity_value(threat) > get_disease_severity_value(DISEASE_SEVERITY_MINOR))
			if(buzzcd < world.time)
				playsound(get_turf(src),'sound/machines/buzz-sigh.ogg',65,1,4)
				buzzcd = (world.time + 60)
			icon_state = "holo_medical-deny"
			return FALSE
		else
			return TRUE //nice or benign diseases!
	return TRUE

/obj/structure/holosign/barrier/medical/attack_hand(mob/living/user)
	if(CanPass(user) && user.a_intent == "help")
		force_allaccess = !force_allaccess
		to_chat(user, "<span class='warning'>You [force_allaccess ? "deactivate" : "activate"] the biometric scanners.</span>") //warning spans because you can make the station sick!
	else
		return ..()

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it."
	var/shockcd = 0

/obj/structure/holosign/barrier/cyborg/hacked/proc/cooldown()
	shockcd = FALSE

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!shockcd)
		if(ismob(user))
			var/mob/living/M = user
			M.electrocute_act(15,"Energy Barrier", safety=1)
			shockcd = TRUE

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/movable/AM)
	if(shockcd)
		return

	if(!ismob(AM))
		return

	var/mob/living/M = AM
	M.electrocute_act(15,"Energy Barrier", safety=1)
	shockcd = TRUE
