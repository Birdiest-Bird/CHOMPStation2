/mob/observer/dead/Logout()
	..()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
		else
			if(mind && mind.assigned_role) //CHOMPEdit
				return //CHOMPEdit
			cleanup_timer = QDEL_IN(src, 10 MINUTES)
