import flask
from ortools.sat.python import cp_model

# Time is in 20 minute intervals
TIME_INTERVAL = 20

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

    model = cp_model.CpModel()

    # Each variable corresponds to a task instance being done by a nurse at a specific time
    # The value of the variable is 1 if the task instance is done by the nurse at that time, and 0 otherwise
    # The time is in minutes, starting from 12am (0)
    # The maximum time is 24 hours * 60 minutes/hour = 1440 minutes
    # The minimum time is 0 minutes
    # The fourth index is the time
    variables : dict[(int, int, int, int), cp_model.BoolVar] = {}
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            for nurse in data['nurses']:
                for time in range(0, MAX_TIME, TIME_INTERVAL):
                    variables[(task['id'], task_instance, nurse['id'], time)] = model.NewBoolVar(f'x_{task["id"]}_{task_instance}_{nurse["id"]}_{time}')
                    if(time < task['earliest_start_time']):
                        model.Add(variables[(task['id'], task_instance, nurse['id'], time)] == 0)

    # Each task instance must be completed exactly once
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            model.Add(sum(variables[(task['id'], task_instance, nurse['id'], time)] for nurse in data['nurses'] for time in range(0, MAX_TIME, TIME_INTERVAL)) == 1)

    # Each nurse can only do one task at a time
    for nurse in data['nurses']:
        for time in range(0, MAX_TIME, TIME_INTERVAL):
            model.Add(sum(variables[(task['id'], task_instance, nurse['id'], time)] for task in data['tasks'] for task_instance in range(task['number_of_times'])) <= 1)

    # Keys for goal variables are the two events that are paired together so their combination can be given a weight for the objective function
    goal_variables : dict[((int, int, int, int),(int, int, int, int)), cp_model.BoolVar] = {}
    
    #goal_variable_coefficients stores the weight for each pair of tasks for the objective function
    goal_variable_coefficients : dict[((int, int, int, int),(int, int, int, int)), float] = {}
    
    #Create a goal variable for each pair of tasks. The goal variable is 1 if the two task instances are performed and 0 otherwise.
    for task in data['tasks']:
        for task_instance in range(task['number_of_times']):
            for nurse in data['nurses']:
                for time in range(0, MAX_TIME, TIME_INTERVAL):
                    for task2 in data['tasks']:
                        for task2_instance in range(task2['number_of_times']):
                            for nurse2 in data['nurses']:
                                for time2 in range(0, MAX_TIME, TIME_INTERVAL):
                                    if(task['id'] != task2['id'] or task_instance != task2_instance or time != time2):
                                        goal_variables[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))] = model.NewBoolVar(f'g_{task["id"]}_{task_instance}_{nurse["id"]}_{time}_{task2["id"]}_{task2_instance}_{nurse2["id"]}_{time2}')
                                        model.add_bool_and([variables[(task['id'], task_instance, nurse['id'], time)], variables[(task2['id'], task2_instance, nurse2['id'], time2)]]).only_enforce_if(goal_variables[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))])
                                        
                                        goal_variable_coefficients[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))] = 0


                                        #If two task intances are back to back (or concurrent) then they should be encouraged
                                        if(abs(time - time2) <= TIME_INTERVAL):
                                            goal_variable_coefficients[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))] = 80
                                        
                                        #If two task instances are within two intervals of each other, then they should be encouraged, but less so
                                        if(abs(time - time2) <= 2*TIME_INTERVAL):
                                            goal_variable_coefficients[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))] = 40

                                        #If the two tasks instances are for the same task, and happen too close together, then they should be incompatible
                                        if(task['id'] == task2['id'] and task_instance != task2_instance):
                                           if(abs(time - time2) < task['minimum_separation']):
                                            model.Add(variables[(task['id'], task_instance, nurse['id'], time)] + variables[(task2['id'], task2_instance, nurse2['id'], time2)] <= 1)
    
    print("Model set up")

    model.maximize(sum(goal_variable_coefficients[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))] * goal_variables[((task['id'], task_instance, nurse['id'], time),(task2['id'], task2_instance, nurse2['id'], time2))] for task in data['tasks'] for task_instance in range(task['number_of_times']) for nurse in data['nurses'] for time in range(0, MAX_TIME, TIME_INTERVAL) for task2 in data['tasks'] for task2_instance in range(task2['number_of_times']) for nurse2 in data['nurses'] for time2 in range(0, MAX_TIME, TIME_INTERVAL) if (task['id'], task_instance, time) != (task2['id'], task2_instance,  time2)) \
#    Bonus for completing task instances during the day (6am to 10pm)
    + 10*sum(variables[(task['id'], task_instance, nurse['id'], time)] for task in data['tasks'] for task_instance in range(task['number_of_times']) for nurse in data['nurses'] for time in range(7*60, 21*60, TIME_INTERVAL)))    
    solver = cp_model.CpSolver()
    
    status = solver.Solve(model)
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:   
        print('Solution found.')
        print('Objective value =', solver.ObjectiveValue())
        for task in data['tasks']:
            for task_instance in range(task['number_of_times']):
                for nurse in data['nurses']:
                    for time in range(0, MAX_TIME, TIME_INTERVAL):
                        if solver.Value(variables[(task['id'], task_instance, nurse['id'], time)]) == 1:
                            print(f'Task {task["id"]} instance {task_instance} started by nurse {nurse["id"]} at {time} minutes')
    else:
        print('No solution found.')
    return 'Hello Scheduler!'

if __name__ == '__main__':
    app.run(debug=True)
