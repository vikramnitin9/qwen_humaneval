# HumanEval Inference with Qwen

## Instructions to Reproduce

First launch the dockerized vLLM server on CPU. Make sure that port 8000 on the host is available.
```bash
bash run_vllm_cpu.sh
```

Then build and run our own Docker image for inference:
```bash
bash build.sh
bash run_inference.sh
```
You should see output like this:
```
Task ID: HumanEval/0
Generated response
Task ID: HumanEval/1
Generated response
Task ID: HumanEval/2
...
```
The solutions will be written to `output/solutions.jsonl`. Once this is done, run evaluation
```bash
bash run_eval.sh
```
You will see output like this:
```
Evaluating task HumanEval/0...
Evaluating task HumanEval/1...
Evaluating task HumanEval/2...
Evaluating task HumanEval/3...
```
The results will be written to `output/results.jsonl`. Finally, it reports the success rate:
```
Evaluation completed. Successful tasks: 90/164
Success rate: 54.88%
```

## Questions to answer:

**1. How can we improve the HumanEval’s metric?**
   
**2. How can we enhance the performance of the inference and evaluation processes? How can we scale this evaluation process and make it run faster?**
