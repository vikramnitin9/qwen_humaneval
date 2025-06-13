import requests
from human_eval.data import read_problems
import json

problems = read_problems()

URL = "http://localhost:8000/v1/chat/completions"

def generate(messages):
    response = requests.post(
                    URL,
                    json={
                        "model": "Qwen/Qwen2.5-Coder-0.5B-Instruct",
                        "messages": messages,
                        "temperature": 0.1,
                        "max_tokens": 2048,
                    },
                    headers={
                        'content-type': 'application/json',
                    }
                )
    if response.status_code != 200:
        return None
    
    return response.json()['choices'][0]['message']['content']

output_file = "/output/solutions.jsonl"

for task_id in problems:
    print(f"Task ID: {task_id}")
    prompt = f"""Complete the following Python function:
```
{problems[task_id]['prompt']}
```
Return just the program. Don't include any additional text or comments."""
    messages = [{"role": "system", "content": "You are a helpful coding assistant"},
               {"role": "user", "content": prompt}]
    response = generate(messages)
    if response is None:
        print("Error generating response")
        continue
    if response.startswith("```python"):
        response = response[10:]
    elif response.startswith("```"):
        response = response[3:]
    if response.endswith("```"):
        response = response[:-3]
    response = response.strip()

    solution = {
        "task_id": task_id,
        "solution": response
    }
    with open(output_file, "a") as f:
        f.write(json.dumps(solution) + "\n")
    print(f"Generated response")
    