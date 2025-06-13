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

Here are some different suggestions:
- Chain of Thought Reasoning: Ask the model to think before generating code. However, this might not yield much improvement for such a small model.
- Self-reflection: After generating, ask the model to simulate running the code on the provided tests, and refining the answer if correct.
- Fine-tuning: Collect a large database of other similar problems, sourced from Geeks4Geeks, CodeNet, etc. Fine-tune the model on this data. Alternatively, generate synthetic examples from HumanEval by mutating each example using some rule-based transformations. Use this as a fine-tuning dataset.
- Distillation from a more powerful model: Collect other competitive programming datasets, collect the output of a larger model (like Claude 3.7) on this data, and use this as a training dataset for the smaller Qwen model.
- Execution-based filtering: Ask the model to generate a test case along with the code (or parse the prompt docstrings to extract the provided test cases). Run the code and check if the output matches the expect test output. Something like the paper "CodeT: Code Generation with Generated Tests".

**2. How can we enhance the performance of the inference and evaluation processes? How can we scale this evaluation process and make it run faster?**

- Inference: The usual techniques to speed up inference are speculative decoding, KV caching, and prompt caching. However, vLLM *already implements* all three of these techniques internally. Instead, we could implement paralellization by *batching* intelligently. We could group inputs of similar size in a batch and feed them for simultaneous inference. This would yield large speedups if we optimize the hyperparameters.
- Evaluation: Multi-threaded execution is the best way to speed-up evaluation. We could dispatch each evaluation task to a separate worker thread, and then join them to collect the results. We would have to choose the number of threads carefully depending on the system configuration. However, since HumanEval is a small dataset, this would only be necessary if we were running evaluation repeatedly.
