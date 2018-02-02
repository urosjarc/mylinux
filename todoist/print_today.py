# Use the todoist API to get tasks from the current day

import json
import todoist
from datetime import datetime

# Log user in; switch to OAuth eventually...
api = todoist.TodoistAPI()


def get_todays_tasks(email, password):
	"""
	Get tasks due on the current utc day
	:return: list of task dicts
	"""
	# user = api.user.login(email, password)
	api.user.login(email, password)
	tasks_today = []

	# Sync (load) data
	response = api.sync()

	# Get "today", only keep Day XX Mon, which Todoist uses
	today = datetime.utcnow().strftime("%a %d %b")

	return response


	# for item in response['items']:
	# 	due = item['due_date_utc']
	# 	if due:
	# 		Slicing :10 gives us the relevant parts
			# if due[:10] == today:
			# 	tasks_today.append(item)
	#
	# return tasks_today

if __name__ == '__main__':

	with open('response.json', 'w') as file:
		json.dump(get_todays_tasks('', '')['items'], file)
