select rout.name as routine_name, ex.name as exercise_name, res.set_number, res.reps, res.weight
from RoutineExerciseSets res
join RoutineExercises re on res.routine_exercise_id = re.id
join Routines rout on re.routine_id = rout.routine_id
join Exercises ex on re.exercise_id = ex.exercise_id
where re.routine_id = 7;
