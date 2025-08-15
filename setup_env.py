import os, sys, subprocess, time, ctypes, requests, json

# ========================= CONFIG =========================
PROJECT_ROOT = os.path.abspath("hug-phz-bday")
VERCEL_TOKEN = ""  # <--- OPTIONAL: Put your Vercel token here for auto-deploy
FRONTEND_HTML = """<!DOCTYPE html>
<html><head><title>HuggingPhaze</title></head>
<body><h1>Welcome to HuggingPhaze</h1></body></html>
"""
BACKEND_MAIN = """from fastapi import FastAPI
app = FastAPI()
@app.get("/")
def read_root():
    return {"message": "Welcome to HuggingPhaze backend MVP"}
"""
# ==========================================================

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def disable_defender():
    print("🛡 Disabling Windows Defender real-time scanning...")
    try:
        subprocess.run([
            "powershell", "-Command",
            "Set-MpPreference -DisableRealtimeMonitoring $true"
        ], check=True, capture_output=True)
        print("✅ Defender real-time scanning disabled.")
        return True
    except subprocess.CalledProcessError:
        print("⚠ Could not disable Defender. Run as admin if needed.")
        return False

def enable_defender():
    print("🛡 Re-enabling Windows Defender real-time scanning...")
    try:
        subprocess.run([
            "powershell", "-Command",
            "Set-MpPreference -DisableRealtimeMonitoring $false"
        ], check=True, capture_output=True)
        print("✅ Defender real-time scanning enabled.")
    except subprocess.CalledProcessError:
        print("⚠ Could not re-enable Defender. Please check manually.")

def create_files():
    os.makedirs(os.path.join(PROJECT_ROOT, "frontend", "public"), exist_ok=True)
    os.makedirs(os.path.join(PROJECT_ROOT, "backend", "app"), exist_ok=True)
    with open(os.path.join(PROJECT_ROOT, "frontend", "public", "index.html"), "w") as f:
        f.write(FRONTEND_HTML)
    with open(os.path.join(PROJECT_ROOT, "backend", "app", "main.py"), "w") as f:
        f.write(BACKEND_MAIN)
    print("📁 Project structure and base files created.")

def run_cmd(cmd, env=None, retries=1):
    for attempt in range(retries):
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, text=True)
        output = []
        for line in proc.stdout:
            print(line, end="")
            output.append(line)
        proc.wait()
        if proc.returncode == 0:
            return True, "".join(output)
        elif any("WinError 32" in l or "timed out" in l for l in output):
            print("🔁 Retrying after lock/timeout issue...")
            time.sleep(3)
        else:
            return False, "".join(output)
    return False, "".join(output)

def setup_env():
    venv_dir = os.path.join(PROJECT_ROOT, "venv")
    run_cmd([sys.executable, "-m", "venv", venv_dir])
    pip_path = os.path.join(venv_dir, "Scripts", "pip.exe")
    run_cmd([pip_path, "install", "--upgrade", "pip"])
    ok, out = run_cmd([pip_path, "install", "fastapi", "uvicorn[standard]"], retries=3)
    return ok, out, pip_path

def verify_local_server(pip_path):
    uvicorn_path = os.path.join(os.path.dirname(pip_path), "uvicorn.exe")
    proc = subprocess.Popen([uvicorn_path, "app.main:app", "--host", "127.0.0.1", "--port", "8000"],
                            cwd=os.path.join(PROJECT_ROOT, "backend"), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    print("🚀 Starting backend for verification...")
    time.sleep(3)
    try:
        r = requests.get("http://127.0.0.1:8000")
        proc.terminate()
        if r.status_code == 200 and "Welcome" in r.text:
            print("✅ Backend running and responded correctly.")
            return True
    except Exception as e:
        print(f"❌ Verification failed: {e}")
    proc.terminate()
    return False

def deploy_vercel():
    if not VERCEL_TOKEN:
        print("⚠ No Vercel token provided, skipping deployment.")
        return False
    try:
        payload = {"name": "hug-phz-bday", "public": True}
        headers = {"Authorization": f"Bearer {VERCEL_TOKEN}", "Content-Type": "application/json"}
        resp = requests.post("https://api.vercel.com/v13/deployments", headers=headers, data=json.dumps(payload))
        if resp.status_code in (200, 201):
            url = resp.json().get("url")
            print(f"✅ Deployed to Vercel: https://{url}")
            return True
        else:
            print(f"❌ Vercel deploy failed: {resp.text}")
    except Exception as e:
        print(f"❌ Vercel deploy error: {e}")
    return False

def main():
    if not is_admin():
        print("❌ Please run this script as Administrator for full functionality.")
        sys.exit(1)
    defender_disabled = disable_defender()
    create_files()
    ok, out, pip_path = setup_env()
    if not ok:
        print("\n🚨 Setup failed — paste this: HUG-PHZ-BDAY-SETUP-FAIL")
        if defender_disabled:
            enable_defender()
        sys.exit(1)
    if verify_local_server(pip_path):
        if deploy_vercel():
            print("\n🎯 ALL LAYERS OK — paste this: HUG-PHZ-BDAY-READY-CLOUD")
        else:
            print("\n🎯 ALL LAYERS OK — paste this: HUG-PHZ-BDAY-READY-LOCAL")
    else:
        print("\n🚨 Verification failed — paste this: HUG-PHZ-BDAY-VERIFY-FAIL")
    if defender_disabled:
        enable_defender()

if __name__ == "__main__":
    main()
