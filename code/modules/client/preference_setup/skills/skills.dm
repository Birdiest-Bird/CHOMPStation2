/datum/category_item/player_setup_item/skills
	name = "Skills"
	sort_order = 1

/datum/category_item/player_setup_item/skills/load_character(list/save_data)
	pref.skills					= check_list_copy(save_data["skills"])
	pref.used_skillpoints		= save_data["used_skillpoints"]
	pref.skill_specialization	= save_data["skill_specialization"]

/datum/category_item/player_setup_item/skills/save_character(list/save_data)
	save_data["skills"]					= check_list_copy(pref.skills)
	save_data["used_skillpoints"]		= pref.used_skillpoints
	save_data["skill_specialization"]	= pref.skill_specialization

/datum/category_item/player_setup_item/skills/sanitize_character()
	if(SKILLS == null)				setup_skills()
	if(!pref.skills)				pref.skills = list()
	if(!pref.skills.len)			pref.ZeroSkills()
	if(pref.used_skillpoints < 0)	pref.used_skillpoints = 0

// Moved from /datum/preferences/proc/copy_to()
/datum/category_item/player_setup_item/skills/copy_to_mob(var/mob/living/carbon/human/character)
	character.skills			= pref.skills
	character.used_skillpoints	= pref.used_skillpoints

/datum/category_item/player_setup_item/skills/content()
	. = list()
	. += span_bold("Select your Skills") + "<br>"
	. += "Current skill level: <b>[pref.GetSkillClass(pref.used_skillpoints)]</b> ([pref.used_skillpoints])<br>"
	. += "<a href='?src=\ref[src];preconfigured=1'>Use preconfigured skillset</a><br>"
	. += "<table>"
	for(var/V in SKILLS)
		. += "<tr><th colspan = 5><b>[V]</b>"
		. += "</th></tr>"
		for(var/datum/skill/S in SKILLS[V])
			var/level = pref.skills[S.ID]
			. += "<tr style='text-align:left;'>"
			. += "<th><a href='?src=\ref[src];skillinfo=\ref[S]'>[S.name]</a></th>"
			. += skill_to_button(S, "Untrained", level, SKILL_NONE)
			// secondary skills don't have an amateur level
			if(S.secondary)
				. += "<th></th>"
			else
				. += skill_to_button(S, "Amateur", level, SKILL_BASIC)
			. += skill_to_button(S, "Trained", level, SKILL_ADEPT)
			. += skill_to_button(S, "Professional", level, SKILL_EXPERT)
			. += "</tr>"
	. += "</table>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/proc/skill_to_button(var/skill, var/level_name, var/current_level, var/selection_level)
	if(current_level == selection_level)
		return "<th>" + span_linkOn("[level_name]") + "</th>"
	return "<th><a href='?src=\ref[src];setskill=\ref[skill];newvalue=[selection_level]'>[level_name]</a></th>"

/datum/category_item/player_setup_item/skills/OnTopic(href, href_list, user)
	if(href_list["skillinfo"])
		var/datum/skill/S = locate(href_list["skillinfo"])
		var/HTML = span_bold("[S.name]") + "<br>[S.desc]"
		user << browse(HTML, "window=\ref[user]skillinfo")
		return TOPIC_HANDLED

	else if(href_list["setskill"])
		var/datum/skill/S = locate(href_list["setskill"])
		var/value = text2num(href_list["newvalue"])
		pref.skills[S.ID] = value
		pref.CalculateSkillPoints()
		return TOPIC_REFRESH

	else if(href_list["preconfigured"])
		var/selected = tgui_input_list(user, "Select a skillset", "Skillset", SKILL_PRE)
		if(!selected || !CanUseTopic(user)) return

		pref.ZeroSkills(1)
		for(var/V in SKILL_PRE[selected])
			if(V == "field")
				pref.skill_specialization = SKILL_PRE[selected]["field"]
				continue
			pref.skills[V] = SKILL_PRE[selected][V]
		pref.CalculateSkillPoints()

		return TOPIC_REFRESH

	else if(href_list["setspecialization"])
		pref.skill_specialization = href_list["setspecialization"]
		pref.CalculateSkillPoints()
		return TOPIC_REFRESH

	return ..()
