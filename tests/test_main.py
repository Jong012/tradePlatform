from starlette.testclient import TestClient


def test_root_endpoint(testclient: TestClient):
    r = testclient.get("/")
    assert r.status_code == 200


def test_read_item(testclient: TestClient):
    r = testclient.get("/hello/visitor")
    assert r.status_code == 200
    assert r.json() == {"message": "Hello visitor"}
