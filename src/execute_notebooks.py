import sys
import os
import asyncio

if sys.platform == 'win32':
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

import nbformat
from nbclient import NotebookClient

def execute_all():
    nb_dir = r"f:\December\JP\DS_Revision\Project_DA_DS\E-Commerce-Growth-Operations-Intelligence\notebooks"
    files = sorted([f for f in os.listdir(nb_dir) if f.endswith(".ipynb")])
    print(f"Found {len(files)} notebooks to execute in {nb_dir}...")

    for fname in files:
        fpath = os.path.join(nb_dir, fname)
        print(f"Executing {fname}...")
        try:
            nb = nbformat.read(fpath, as_version=4)
            client = NotebookClient(nb, timeout=600, kernel_name="python3", resources={"metadata": {"path": nb_dir}})
            client.execute()
            with open(fpath, "w", encoding="utf-8") as f:
                nbformat.write(nb, f)
            print(f"-> Successfully executed and saved {fname}")
        except Exception as e:
            print(f"Error executing {fname}: {e}")

if __name__ == "__main__":
    execute_all()
