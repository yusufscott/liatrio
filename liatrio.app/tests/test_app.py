import time
from unittest import mock

from liatrio import create_app


def test_index(client):
    response = client.get('/')
    assert b'Yusuf\'s Liatrio App' in response.data

def test_health(client):
    response = client.get('/_health')
    assert b'running' in response.data

@mock.patch('time.time', mock.MagicMock(return_value=12345))
def test_timestamp(client):
    response = client.get('/timestamp')
    assert response.json["message"] == "Automate all the things!"
    assert response.json["timestamp"] == 12345