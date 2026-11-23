import os
import unittest
from types import SimpleNamespace
from unittest.mock import Mock, patch

from kubernetes.config.config_exception import ConfigException

import app


class DashboardTests(unittest.TestCase):
    def setUp(self):
        self.client = app.app.test_client()

    @patch.dict(os.environ, {"DASHBOARD_ENABLED": "false"})
    @patch("app.get_kubernetes_clients")
    def test_public_endpoints_do_not_connect_to_kubernetes(self, clients):
        self.assertEqual(self.client.get("/health").status_code, 200)
        self.assertEqual(self.client.get("/dashboard").status_code, 404)
        clients.assert_not_called()

    @patch.dict(os.environ, {"DASHBOARD_ENABLED": "true", "POD_NAMESPACE": "aks-operations"})
    @patch("app.get_kubernetes_clients")
    def test_dashboard_lists_only_its_namespace(self, clients):
        core, deployments, networking = Mock(), Mock(), Mock()
        clients.return_value = core, deployments, networking
        requests = (
            core.list_namespaced_pod,
            core.list_namespaced_service,
            deployments.list_namespaced_deployment,
            networking.list_namespaced_ingress,
        )
        for request in requests:
            request.return_value = SimpleNamespace(items=[])
        self.assertEqual(self.client.get("/dashboard").status_code, 200)
        for request in requests:
            request.assert_called_once_with("aks-operations", _request_timeout=5)

    @patch.dict(os.environ, {"DASHBOARD_ENABLED": "true", "POD_NAMESPACE": "aks-operations"})
    @patch("app.get_kubernetes_clients", side_effect=ConfigException("private endpoint"))
    def test_dashboard_hides_kubernetes_error_details(self, clients):
        with self.assertLogs(app.app.logger, "WARNING"):
            response = self.client.get("/dashboard")
        self.assertEqual(response.status_code, 503)
        self.assertNotIn(b"private endpoint", response.data)
