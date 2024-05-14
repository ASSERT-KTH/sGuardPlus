import csv
import os
import subprocess
import sys
import json
import time
from multiprocessing import Pool
import shutil

def get_mid_dir(path):
    path_components = path.split(os.path.sep)
    filename = path_components[-1]
    return path_components[-2], filename.split(".")[0]

def run_sguardplus(path):
    command = f"node src/index.js {path}"
    start_time = time.time()
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=60*60)
    except subprocess.TimeoutExpired:
        return -1, -1, -1, -1
    elapsed_time = time.time() - start_time
    return result.returncode, elapsed_time, result.stdout, result.stderr

def write_results(results_csv, res):
    with open(results_csv, 'w', newline='') as csvfile:
        for r in res:
            fieldnames = ['path', 'contract', 'elapsed_time', 'return_code']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writerow({
                    'path': r[0],
                    'contract': r[1],
                    'elapsed_time': r[2],
                    'return_code': r[3]
                })

def use_solc(version):
    components = version.split(".")
    if eval(components[1]) <= 4 and eval(components[2]) < 12:
        version = '0.4.12'
    install = f"solc-select install {version}"
    use = f"solc-select use {version}"
    try:
        process = subprocess.run(install, shell=True, check=True)
        process = subprocess.run(use, shell=True, check=True)

        return process.returncode == 0
    except:
        return False

def process_entry(path, contract, outdir, version):

    mid, file = get_mid_dir(path)
    outdir = os.path.join(outdir, mid)
    outdir = os.path.join(outdir, file)
    os.makedirs(outdir, exist_ok=True)
    ret = use_solc(version)
    print(f"{path}: {ret}")
    if not ret:
        return path, contract, -1, -1, "", "Failed to use solc version"
    return_code, elapsed_time, stdout, stderr = run_sguardplus(path)

    # Move and rename the patch if it exists
    patch = path + ".fixed.sol"
    if os.path.exists(patch):
        shutil.move(patch, os.path.join(outdir, file + ".sol"))
    
    # Move the report if it exists
    report = path + "_vul_report.json"
    if os.path.exists(report):
        shutil.move(report, os.path.join(outdir, file + ".sol_vul_report.json"))
    
    stdout_file = os.path.join(outdir, file+ ".out")
    stderr_file = os.path.join(outdir, file+ ".log")
    with open(stdout_file, 'w') as file:
        file.write(stdout)
    with open(stderr_file, 'w') as file:
        file.write(stderr)

    return path, contract, elapsed_time, return_code

def get_args(smartbugs_dir, output_dir):
    args = []

    vuln_json = os.path.join(smartbugs_dir, "vulnerabilities.json")
    with open(vuln_json, 'r') as file:
        data = json.load(file)

    for entry in data:
        path = os.path.join(smartbugs_dir, entry.get('path'))
        contract = entry.get('contract_names')[0]
        version = entry.get('pragma')
        args.append((path, contract, output_dir, version))

    return args

def write_log(res, output_dir):
    for r in res:
        stdout = r[4]
        stderr = r[5]
        path = r[0]
        mid, file = get_mid_dir(path)
        outdir = os.path.join(output_dir, mid)
        outdir = os.path.join(outdir, file)
        os.makedirs(outdir, exist_ok=True)
        stdout_file = os.path.join(outdir, file+ ".out")
        stderr_file = os.path.join(outdir, file+ ".log")
        with open(stdout_file, 'w') as file:
            file.write(stdout)
        with open(stderr_file, 'w') as file:
            file.write(stderr)


def main():

    if len(sys.argv) != 3:
        print("Usage: python run_on_smartbugs.py <smartbugs_directory> <output_directory>")
        sys.exit(1)

    smartbugs_dir = sys.argv[1]
    output_dir = sys.argv[2]
    processes = 1 # TODO: adapt to multiple processes

    with Pool(processes) as pool:
        res = pool.starmap(process_entry, get_args(smartbugs_dir, output_dir))
    
    csv_file = os.path.join(output_dir, 'results.csv')
    write_results(csv_file, res)
    

if __name__ == "__main__":
    main()
