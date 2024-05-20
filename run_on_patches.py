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
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=60*60)
    except subprocess.TimeoutExpired:
        return -1, '', ''
    return result.returncode, str(result.stdout), str(result.stderr)

def write_results(results_csv, res):
    with open(results_csv, 'w', newline='') as csvfile:
        for r in res:
            fieldnames = ['path', 'return_code']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writerow({
                    'path': r[0],
                    'return_code': r[1]
                })

def use_solc(version):
    install = f"solc-select install {version}"
    use = f"solc-select use {version}"
    try:
        process = subprocess.run(install, shell=True, check=True)
        process = subprocess.run(use, shell=True, check=True)

        return process.returncode == 0
    except:
        return False

def process_entry(path, outdir):

    print(path)

    els = path.split(os.path.sep)
    file = els[-1].replace(".sol", '')
    mid = els[-3:-1]
    mid = os.path.join(*mid)
    outdir = os.path.join(outdir, mid)
    os.makedirs(outdir, exist_ok=True)

    return_code, stdout, stderr = run_sguardplus(path)

    # Move and rename the patch if it exists
    patch = path + ".fixed.sol"
    if os.path.exists(patch):
        os.remove(patch)
    
    # Move the report if it exists
    report = path + "_vul_report.json"
    if os.path.exists(report):
        shutil.move(report, os.path.join(outdir, file + ".patch.bug.json"))

    return path, return_code

def get_args(smartbugs_dir, output_dir):
    args = []

    patches = os.path.join(smartbugs_dir, "valid_patches.csv")
    with open(patches, 'r') as file:
        data = file.readlines()

    for entry in data:
        args.append((os.path.join(smartbugs_dir, entry.strip()), output_dir))

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
        print(stdout_file)
        stderr_file = os.path.join(outdir, file+ ".log")
        print(stderr_file)
        with open(stdout_file, 'w') as file:
            file.write(stdout)
        with open(stderr_file, 'w') as file:
            file.write(stderr)


def main():

    if len(sys.argv) != 4:
        print("Usage: python run_on_smartbugs.py <smartbugs_directory> <output_directory> <processes>")
        sys.exit(1)

    smartbugs_dir = sys.argv[1]
    output_dir = sys.argv[2]
    processes = int(sys.argv[3])

    ret = use_solc("0.4.24")
    if not ret:
        print("Failed to use solc version")
        return

    with Pool(processes) as pool:
        res = pool.starmap(process_entry, get_args(smartbugs_dir, output_dir))
    
    csv_file = os.path.join(output_dir, 'results.csv')
    write_results(csv_file, res)
    

if __name__ == "__main__":
    main()
