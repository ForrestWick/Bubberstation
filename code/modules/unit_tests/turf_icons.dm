/// Makes sure turf icons actually exist. :)
/datum/unit_test/turf_icons
	var/modular_mineral_turf_file = 'modular_skyrat/modules/xenoarch/icons/mining.dmi' //= 'icons/turf/mining.dmi' //MODULARITY SUPPORT - insert your snowflake MAP_SWITCH icon file here if you use that define. // SKYRAT EDIT - Added our modular file here (thanks)

/datum/unit_test/turf_icons/Run()
	for(var/turf/turf_path as anything in (subtypesof(/turf) - typesof(/turf/closed/mineral)))

		var/icon_state = initial(turf_path.icon_state)
		var/icon_file = initial(turf_path.icon)
		if(isnull(icon_state) || isnull(icon_file))
			continue
		if(!(icon_state in icon_states(icon_file)))
			TEST_FAIL("[turf_path] using invalid icon_state - \"[icon_state]\" in icon file, '[icon_file]")

	for(var/turf/closed/mineral/turf_path as anything in typesof(/turf/closed/mineral)) //minerals use a special (read: snowflake) MAP_SWITCH definition that changes their icon based on if we're just compiling or if we're actually PLAYING the game.

		var/icon_state = initial(turf_path.icon_state)
		var/icon_file = initial(turf_path.icon)
		if(isnull(icon_state) || isnull(icon_file))
			continue
		if(!(icon_state in icon_states(icon_file)))
			if(modular_mineral_turf_file && (icon_state in icon_states(modular_mineral_turf_file, 1)))
				continue
			if(!(icon_state in icon_states('icons/turf/mining.dmi', 1)))
				TEST_FAIL("[turf_path] using invalid icon_state - \"[icon_state]\" in icon file, '[icon_file]")

	var/turf/initial_turf_type = run_loc_floor_bottom_left.type

	var/list/ignored_types = list()
	//ignored_types += typesof(YOUR_DOWNSTREAM_TYPEPATH(s)_HERE) //MODULARITY SUPPORT. If you have snowflake typepaths that are blacklisted in, for example, create & destroy unit test because they require certain SS's being init, use this to blacklist them.
	//SKYRAT EDIT START
	ignored_types += typesof(/turf/open/openspace/ocean)
	ignored_types += typesof(/turf/open/floor/plating/ocean_plating) // Effigy promo note: this isn't tenable long-term; but I'm being consistent.
	ignored_types += typesof(/turf/open/misc/ocean)
	ignored_types += typesof(/turf/open/misc/ironsand/oceans)
	ignored_types += typesof(/turf/open/floor/iron/oceans)
	ignored_types += typesof(/turf/open/floor/iron/solarpanel/ocean)
	ignored_types += typesof(/turf/open/floor/engine/hull/ocean)
	ignored_types += typesof(/turf/open/floor/engine/hull/reinforced/ocean)
	ignored_types += typesof(/turf/open/floor/glass/reinforced/ocean)
	ignored_types += typesof(/turf/open/floor/glass/plasma/ocean)
	ignored_types += typesof(/turf/open/floor/glass/reinforced/plasma/ocean)
	ignored_types += typesof(/turf/open/misc/canal)
	ignored_types += typesof(/turf/open/misc/canal_mutable)
	// SKYRAT EDIT END


	for(var/turf/open/open_turf_path as anything in (subtypesof(/turf/open) - ignored_types))

		var/damaged_dmi = initial(open_turf_path.damaged_dmi)
		if(isnull(damaged_dmi))
			continue


		run_loc_floor_bottom_left.ChangeTurf(open_turf_path)
		run_loc_floor_bottom_left = get_turf(locate(/obj/effect/landmark/unit_test_bottom_left) in GLOB.landmarks_list) //in case the turf path changed the final turf in Initialize() without passing the final turf to ChangeTurf()....
		if(!isopenturf(run_loc_floor_bottom_left))
			continue
		var/turf/open/instanced_turf = run_loc_floor_bottom_left

		var/list/burnt_states = instanced_turf.burnt_states()
		for(var/state in burnt_states)
			if(!(state in icon_states(damaged_dmi)))
				TEST_FAIL("[open_turf_path] has an invalid icon in burnt_states - \"[state]\", in '[damaged_dmi]'")


		var/list/broken_states = instanced_turf.broken_states()
		for(var/state in broken_states)
			if(!(state in icon_states(damaged_dmi)))
				TEST_FAIL("[open_turf_path] has an invalid icon in broken_states - \"[state]\", in '[damaged_dmi]'")

	run_loc_floor_bottom_left = run_loc_floor_bottom_left.ChangeTurf(initial_turf_type) //cleanup.
