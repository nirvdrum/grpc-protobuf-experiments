import glob
import os
import pathlib
import subprocess

DIR = pathlib.Path(__file__).parent.resolve()
PROTO_PATH = DIR.parent.joinpath('proto')
GEN_DIR = DIR.joinpath('gen/protobuf')

def compile_protos():
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    cmd = ['protoc', '-I', '.', '--python_out', GEN_DIR]
    cmd.extend(glob.glob("*.proto", root_dir=PROTO_PATH))
    subprocess.run(cmd, cwd=PROTO_PATH)

def rss_in_kb():
    res = subprocess.run(['ps', '-p', str(os.getpid()), '-o', 'rss='], capture_output=True, text=True)
    return int(res.stdout)
