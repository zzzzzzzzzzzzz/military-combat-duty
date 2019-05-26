INSERT INTO duty_groups_log
	SELECT
		d_start as duty_start, 
		d_end as duty_end,
		s_number as equipment,
		gr_info.gr_id,
		brief
	FROM
		group_info as gr_info
	INNER JOIN
		(select * FROM get_groups(TO_TIMESTAMP('2019-04-06 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2)) as schedule
	ON gr_info.gr_id = schedule.g_id;
