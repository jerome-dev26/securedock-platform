from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/api/hello")
def hello_world():
    return jsonify(message="Hello from SecureDock Backend!")

@app.route("/api/status")
def status():
    return jsonify(status="Backend is running.")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
