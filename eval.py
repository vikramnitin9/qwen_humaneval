from human_eval.data import read_problems
import json
from proj.execution import check_correctness

if __name__ == "__main__":

    problems = read_problems()
    solutions_file = "/output/solutions.jsonl"
    results_file = "/output/results.jsonl"

    with open(solutions_file, "r") as f:
        solutions = [json.loads(line) for line in f.readlines()]

    success = 0

    for solution in solutions:
        task_id = solution["task_id"]
        solution = solution["solution"]
        problem = problems[task_id]
        print(f"Evaluating task {task_id}...")

        result = check_correctness(problem, solution, timeout=10.0)
        if result['passed']:
            success += 1

    print(f"Evaluation completed. Successful tasks: {success}/{len(solutions)}")
    print(f"Success rate: {success / len(solutions) * 100:.2f}%")