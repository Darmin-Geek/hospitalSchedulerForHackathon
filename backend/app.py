import flask
from ortools.linear_solver import pywraplp

TOTAL_ACTIVITY_TYPES = 5

# The maximum time is 24 hours * 60 minutes/hour = 1440 minutes
MAX_TIME = 24*60

app = flask.Flask(__name__)

@app.route('/')
def index():
    return 'Hello World!'

@app.route('/schedule', methods=['POST'])
def schedule():
    data = flask.request.get_json()
    print(data)
    # The data is has the following format:
    # {
    #     "nurses": [
    #         {
    #             "id": 1,
    #             "name": "John Doe",
    #         }
    #     ],
    #     "patients": [
    #         {
    #             "id": 1,
    #             "name": "Joe Schmoe",
    #         }
    #     "tasks": [
    #         {
    #             "id": 1,
    #             "name": "Check vitals",
    #             "patient_id": 1,
    #             "number_of_times": 3,
    #             "duration": 1,
    #             "activity_type": "1",
    #             "minimum_separation": 40,
    #             "maximum_separation": 120,
    #             "earliest_start_time": 0,
    #         }
    #     ],
    #     "already_completed_tasks":{
    #         "task_id": 1,
    #         "task_instance_id": 1,   
    #         "start_time": 0,
    #         "nurse_id": 1,
    #     }
    # }

    model = pywraplp.Solver.CreateSolver('SCIP')

    # Each variable corresponds to a task instance being completed
    # The value of the variable is the time at which the task instance is completed
    # The keys are (task_id, task_instance_id)
    variables : dict[(int, int), pywraplp.NumVar] = {}
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            variables[(task['id'], task_instance)] = model.NumVar(0, MAX_TIME, f'x_{task["id"]}_{task_instance}')

    debug_support_vars = []

    # # Each activity type can only be done once at a time
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            for task2 in data['tasks']:
                for task2_instance in range(task2['number_of_times']):
                    if((task['id'] != task2['id'] or task_instance != task2_instance) and (task['activity_type'] == task2['activity_type'])):
                        support_var_z = model.IntVar(0, 1, f'z_{task["id"]}_{task_instance}_{task2["id"]}_{task2_instance}')
                        model.Add(variables[(task['id'], task_instance)] - variables[(task2['id'], task2_instance)] >= task['duration']/2 + task2['duration']/2 - MAX_TIME * support_var_z)
                        model.Add(variables[(task2['id'], task2_instance)] - variables[(task['id'], task_instance)] >= task['duration']/2 + task2['duration']/2 - MAX_TIME * (1-support_var_z))
                        debug_support_vars.append(support_var_z)
    
    
    # Each task instance must be in range of the previous task instance
    for task in data['tasks']:
        for task_instance in range(1, task['number_of_times']):
            model.Add(variables[(task['id'], task_instance)] >= variables[(task['id'], task_instance-1)] + task['minimum_separation'])
            model.Add(variables[(task['id'], task_instance)] <= variables[(task['id'], task_instance-1)] + task['maximum_separation'])
    
    
    # # key is patient id, value is the negative of the time between the two closest pair of tasks for that patient
    per_person_closest_pairs : dict[int, pywraplp.NumVar] = {}
    
    for patient in data['patients']:
        per_person_closest_pairs[patient['id']] = model.NumVar(-MAX_TIME, MAX_TIME, f'per_person_closest_pairs_{patient["id"]}')
    
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            for task2 in data['tasks']:
                for task2_instance in range(task2['number_of_times']):
                    if((task['id'] != task2['id'] or task_instance != task2_instance) and (task['patient_id'] == task2['patient_id'])):
                        model.Add(per_person_closest_pairs[task['patient_id']] <= variables[(task['id'], task_instance)] - variables[(task2['id'], task2_instance)])
                        model.Add(per_person_closest_pairs[task['patient_id']] <= variables[(task2['id'], task2_instance)] - variables[(task['id'], task_instance)])
    

    # The objective is to minimize the time between the two closest pair of tasks for each patient
    objectiveVariable = model.NumVar(float('-inf'), float('inf'), 'objectiveVariable')
    model.Add(objectiveVariable == sum(value*-1 for value in per_person_closest_pairs.values()))
    model.Minimize(objectiveVariable)

    print("Model set up")

    model.Solve()

    
    for var in debug_support_vars:
        print(var.name(), var.solution_value())

    # Return the events
    events = []
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            events.append({
                'task_id': task['id'],
                'task_instance_id': task_instance,
                'start_time': variables[(task['id'], task_instance)].solution_value()
            })

    print(events)
    print(objectiveVariable.solution_value())
    print(model.Objective().Value())
    print(per_person_closest_pairs[0].solution_value())
    
    return events

if __name__ == '__main__':
    app.run(debug=True)
