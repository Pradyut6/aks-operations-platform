import os
from datetime import UTC, datetime

from flask import Flask, abort, jsonify, render_template
from kubernetes import client, config
from kubernetes.client.exceptions import ApiException
from kubernetes.config.config_exception import ConfigException

app = Flask(__name__)
VERSION = "1.0.0"


@app.get("/")
def home():
    return jsonify(application="AKS Operations Platform", status="Running", version=VERSION)


@app.get("/health")
def health():
    return jsonify(status="Healthy", timestamp=datetime.now(UTC).isoformat())


@app.get("/version")
def version():
    return jsonify(version=VERSION)


@app.get("/info")
def info():
    return jsonify(environment=os.getenv("ENVIRONMENT", "development"))


def get_kubernetes_clients():
    configuration = client.Configuration()
    config.load_incluster_config(client_configuration=configuration)
    api_client = client.ApiClient(configuration)
    return client.CoreV1Api(api_client), client.AppsV1Api(api_client), client.NetworkingV1Api(api_client)


@app.get("/dashboard")
def dashboard():
    if os.getenv("DASHBOARD_ENABLED", "false").lower() != "true":
        abort(404)

    namespace = os.getenv("POD_NAMESPACE")
    if not namespace:
        abort(503)

    try:
        core, apps, network = get_kubernetes_clients()
        pods = core.list_namespaced_pod(namespace, _request_timeout=5).items
        deployments = apps.list_namespaced_deployment(namespace, _request_timeout=5).items
        services = core.list_namespaced_service(namespace, _request_timeout=5).items
        ingresses = network.list_namespaced_ingress(namespace, _request_timeout=5).items
    except (ApiException, ConfigException):
        app.logger.warning("Dashboard Kubernetes API request failed", exc_info=True)
        return "Dashboard temporarily unavailable", 503

    deployment_data = [
        {"name": item.metadata.name, "namespace": namespace,
         "desired": item.spec.replicas or 0, "ready": item.status.ready_replicas or 0}
        for item in deployments
    ]
    healthy = sum(item["ready"] >= item["desired"] for item in deployment_data)

    return render_template(
        "dashboard.html",
        version=VERSION,
        timestamp=datetime.now(UTC).isoformat(),
        overall_status=("Healthy" if healthy == len(deployments) else "Degraded") if deployments else "Unknown",
        pod_count=len(pods),
        running_pod_count=sum(item.status.phase == "Running" for item in pods),
        deployment_count=len(deployments),
        healthy_deployment_count=healthy,
        service_count=len(services),
        ingress_count=len(ingresses),
        pods=[{"name": item.metadata.name, "namespace": namespace,
               "status": item.status.phase or "Unknown"} for item in pods],
        deployments=deployment_data,
        services=[{"name": item.metadata.name, "namespace": namespace,
                   "type": item.spec.type, "cluster_ip": item.spec.cluster_ip or "-"} for item in services],
        ingresses=[{"name": item.metadata.name, "namespace": namespace, "address": "-"} for item in ingresses],
        availability=f"{100 * healthy / len(deployments):.2f}%" if deployments else "—",
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
